// Tests for the rules/encoding core embedded in index.html.  Run: node webapp/test_core.mjs
import { readFileSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const here = path.dirname(fileURLToPath(import.meta.url));
const html = readFileSync(path.join(here, 'index.html'), 'utf8');
const src = html.match(/<script id="orion-core">([\s\S]*?)<\/script>/)[1];
new Function(src)();
const C = globalThis.OrionCore;
let fails = 0;
const ok = (cond, msg) => { if (!cond) { fails++; console.log('FAIL', msg); } };

// 1. golden vectors embedded in the page agree with conformance/golden_vectors.json
const J = JSON.parse(readFileSync(path.join(here, '..', 'conformance', 'golden_vectors.json'), 'utf8'));
const G = C.GOLDEN;
ok(JSON.stringify(G.evidence_weight) === JSON.stringify(J.evidence_weight.cases.map(c => [c.tier, c.rigor, c.sources, c.d, c.expected])), 'W table mismatch');
ok(JSON.stringify(G.evidence) === JSON.stringify(J.claim_score.evidence), 'evidence table mismatch');
ok(JSON.stringify(G.claim_score) === JSON.stringify(J.claim_score.cases.map(c => [c.support, c.conflict, c.expected])), 'score table mismatch');
ok(JSON.stringify(G.level) === JSON.stringify(J.level.cases.map(c => [c.xp, c.expected])), 'level table mismatch');
ok(JSON.stringify(G.meter) === JSON.stringify(J.meter.cases.map(c => [c.events, c.expected])), 'meter table mismatch');
ok(JSON.stringify(G.zoo_admit) === JSON.stringify(J.zoo_admit.cases.map(c => [c.human_approved, c.frozen_before_outcome, c.vetoes, c.expected])), 'zoo table mismatch');

// 2. the JavaScript rules pass every golden case
const rows = C.runGolden();
rows.filter(r => !r.ok).forEach(r => console.log('FAIL golden', r));
ok(rows.length === 30 && rows.every(r => r.ok), 'golden vectors');

// 3. DAG-CBOR / CID against known values
const hex = b => Buffer.from(b).toString('hex');
ok(hex(C.encodeDagCbor({})) === 'a0', 'empty map');
ok(hex(C.encodeDagCbor({ b: 1, aa: 2, a: 3 })) === 'a3616103616201626161' + '02', 'key order: length first, then bytes');
ok(hex(C.encodeDagCbor([1000000, -1, 'é', true, null])) === '851a000f42402062c3a9f5f6', 'ints/strings/simple');
ok(C.cidString(await C.cidOf(C.encodeDagCbor({}))) === 'bafyreigbtj4x7ip5legnfznufuopl4sg4knzc2cof6duas4b3q2fy6swua', 'CID of empty map');
ok(C.cidString(await C.cidOf(new Uint8Array(0), 0x55)) === 'bafkreihdwdcefgh4dqkjv67uzcmw7ojee6xedzdetojuzjevtenxquvyku', 'raw CID of empty bytes');

// 4. round trips and tamper detection
const state = { v: 1, k: '10', claims: [{ text: 'Fibonacci', tags: ['φ'], support: [{ tier: 'primary', rigor: 'cryptographic', sources: 5 }], conflict: [] }] };
const blk = C.encodeDagCbor(state);
ok(hex(C.encodeDagCbor(C.decodeDagCbor(blk))) === hex(blk) && C.decodeDagCbor(blk).claims[0].tags[0] === 'φ', 'cbor round trip');
const cid = await C.cidOf(blk);
const car = C.makeCar(cid, blk);
const back = await C.readCar(car);
ok(back.blocks.length === 1 && back.blocks[0].valid && hex(back.roots[0]) === hex(cid), 'car round trip');
const tampered = car.slice(); tampered[tampered.length - 3] ^= 1;
ok(!(await C.readCar(tampered)).blocks[0].valid, 'tampered car detected');
writeFileSync('/tmp/orion-test.car', car);

// 5. anti-volume, levels, bridges spot checks
const rumour = { tier: 'unverified', rigor: 'opaque', sources: 50 };
ok(C.claimScore([rumour], []).eq(C.claimScore(Array(100).fill(rumour), [])), 'anti-volume');
ok(C.experience([{ support: [rumour], conflict: [] }, { support: [rumour], conflict: [] }]).eq(C.claimScore([rumour], [])), 'anti-farming');
const br = C.bridges([{ disc: 'eco', tags: ['a', 'b'] }, { disc: 'econ', tags: ['a', 'b', 'c'] }, { disc: 'eco', tags: ['a', 'b'] }], new C.Q(1n, 2n));
ok(br.length === 2 && br.every(b => b.shared.length > 0), 'bridges');

// 6. Turtle contains the expected terms
const ttl = C.toTurtle({ claims: [{ text: 'x "y"', disc: 'd', tags: ['t'], refs: { wikidata: 'Q42', oeis: 'A000045' }, support: [], conflict: [] }] });
ok(ttl.includes('owl:sameAs wd:Q42') && ttl.includes('<https://oeis.org/A000045>') && ttl.includes('"x \\"y\\""'), 'turtle');
writeFileSync('/tmp/orion-test.ttl', ttl);

// 7. GIF: write a test animation for an external decoder check
const w = 200, h = 150, frames = []; let seed = 12345;
for (let f = 0; f < 4; f++) { const fr = new Uint8Array(w * h);
  for (let i = 0; i < fr.length; i++) { seed = (seed * 1103515245 + 12345) >>> 0; fr[i] = f % 2 ? (seed >>> 16) & 255 : ((i % w) + Math.floor(i / w) * 3 + f * 31) & 255; } frames.push(fr); }
writeFileSync('/tmp/orion-test.gif', C.encodeGif(w, h, frames, 10));
writeFileSync('/tmp/orion-test-frames.json', JSON.stringify(frames.map(f => Array.from(f))));

console.log(fails === 0 ? 'all core tests pass' : `${fails} failure(s)`);
process.exit(fails ? 1 : 0);
