// Tests for the Knowledge Atlas logic embedded in index.html.  Run: node webapp/test_atlas.mjs
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const here = path.dirname(fileURLToPath(import.meta.url)), repo = path.join(here, '..');
const html = readFileSync(path.join(here, 'index.html'), 'utf8');
new Function(html.match(/<script id="orion-core">([\s\S]*?)<\/script>/)[1])();
new Function(html.match(/<script id="orion-atlas">([\s\S]*?)<\/script>/)[1])();
const A = globalThis.OrionAtlas;
let fails = 0, checks = 0;
const ok = (cond, msg) => { checks++; if (!cond) { fails++; console.log('FAIL', msg); } };

// 1. catalog integrity: unique ids, links resolve, Lean theorems exist in the named files
const ids = A.CATALOG.map(e => e.id);
ok(new Set(ids).size === ids.length && ids.length >= 25, 'unique ids');
for (const e of A.CATALOG) {
  e.links.forEach(l => ok(A.BY_ID[l] && l !== e.id, `${e.id} links to unknown ${l}`));
  ok(A.STATUS[e.status], `${e.id} status`);
  const src = readFileSync(path.join(repo, e.file), 'utf8');
  ok(new RegExp(`^theorem ${e.lean}\\b`, 'm').test(src), `${e.id}: theorem ${e.lean} not found in ${e.file}`);
  ok(A.neighbours(e.id).length > 0, `${e.id} is isolated`);
  ok(A.parsePlaybook(e.anim).errors.length === 0, `${e.id} built-in playbook errors: ${A.parsePlaybook(e.anim).errors}`);
  A.LENSES.forEach(([l]) => ok(A.lensText(e, l).length > 20, `${e.id}/${l} text`));
}
// graph is connected
const seen = new Set(['watermelon']), stack = ['watermelon'];
while (stack.length) A.neighbours(stack.pop()).forEach(n => { if (!seen.has(n)) { seen.add(n); stack.push(n); } });
ok(seen.size === ids.length, 'knowledge graph connected');

// 2. level n gives n² cells, nested, adding 2n+1; all cells non-empty and pairwise distinct
for (let n = 1; n <= A.MAX_LEVEL; n++) {
  const g = A.grid(n);
  ok(g.length === n * n, `grid size level ${n}`);
  if (n > 1) { const prev = A.grid(n - 1).map(c => c.form + c.lens), cur = g.map(c => c.form + c.lens);
    ok(prev.every(k => cur.includes(k)) && cur.length - prev.length === 2 * n - 1, `nesting ${n}`); }
}
ok(A.grid(0).length === 1 && A.grid(99).length === 49, 'level clamped');
for (const e of A.CATALOG) {
  const bodies = A.grid(7).map(c => { const r = A.representation(e.id, c.form, c.lens); return r.kind + '|' + r.body + '|' + (r.caption || ''); });
  ok(bodies.every(b => b.length > 10), `${e.id} empty cell`);
  ok(new Set(bodies).size === 49, `${e.id} cells not distinct (${new Set(bodies).size})`);
  const q = A.representation(e.id, 'quiz', 'plain'); ok(q.body.includes('____') && q.answer.length > 0, `${e.id} quiz`);
  JSON.parse(A.representation(e.id, 'code', 'evidence').body);
}

const canon = v => JSON.stringify(v, (k, x) => x && typeof x === 'object' && !Array.isArray(x) ? Object.fromEntries(Object.entries(x).sort()) : x);
// 3. playbook: parse ∘ serialize is stable, limits and clamping
for (const e of A.CATALOG) {
  const s1 = A.parsePlaybook(e.anim).spec, t1 = A.serializePlaybook(s1), s2 = A.parsePlaybook(t1).spec;
  ok(canon(s1) === canon(s2) && A.serializePlaybook(s2) === t1, `${e.id} round trip`);
}
const cl = A.parsePlaybook('dur 9999\ncircle r 1e9 spin -1e9\ntext "a \\"q\\" b" size 2');
ok(cl.spec.dur === 60 && cl.spec.shapes[0].r === 100 && cl.spec.shapes[0].spin === -1080 && cl.spec.shapes[1].size === 4, 'clamping');
ok(cl.spec.shapes[1].text === 'a "q" b' && A.parsePlaybook(A.serializePlaybook(cl.spec)).spec.shapes[1].text === 'a "q" b', 'quoted text');
ok(A.parsePlaybook(Array(100).fill('circle r 5').join('\n')).spec.shapes.length === 40, 'max shapes');
ok(A.parsePlaybook('bogus 1\ncircle radius 3').errors.length === 2, 'errors reported');

// 4. injection attempts never reach the SVG
const evil = [
  'text "<script>alert(1)</script>"', 'text "\\"><img src=x onerror=alert(1)>"', 'circle r 10 stroke "red" onload=alert(1)',
  'circle r 10 fill url(javascript:alert(1))', 'circle r 10 stroke #fff"/><script>alert(1)</script>', '<svg onload=alert(1)>',
  'title "</svg><script>alert(1)</script>"', 'bg red;background:url(javascript:alert(1))', 'line x1 0 y1 0 x2 javascript:alert(1)',
  'poly n 5 r 20 stroke expression(alert(1))', 'text "x" fill #fff onmouseover alert(1)'].join('\n');
const out = A.renderPlaybook(A.parsePlaybook(evil).spec);
const ALLOWED_TAGS = new Set(['svg', 'g', 'circle', 'polygon', 'line', 'text', 'rect', 'animate', 'animateTransform']);
const ALLOWED_ATTRS = new Set(['viewBox', 'width', 'height', 'style', 'role', 'aria-label', 'transform', 'r', 'cx', 'cy', 'x', 'y', 'x1', 'y1', 'x2', 'y2',
  'points', 'stroke', 'fill', 'stroke-width', 'stroke-dasharray', 'text-anchor', 'dominant-baseline', 'font-size', 'attributeName', 'type', 'values',
  'from', 'to', 'dur', 'repeatCount', 'data-el']);
const checkMarkup = (svg, label) => {
  // every tag and attribute is whitelisted, and no attribute value can load or run anything
  for (const m of svg.matchAll(/<\/?([A-Za-z][\w-]*)((?:\s+[\w:-]+="[^"<>]*")*)\s*\/?>/g)) {
    ok(ALLOWED_TAGS.has(m[1]), `${label}: tag ${m[1]}`);
    for (const a of m[2].matchAll(/([\w:-]+)="([^"]*)"/g)) {
      ok(ALLOWED_ATTRS.has(a[1]), `${label}: attribute ${a[1]}`);
      ok(!/javascript:|url\(|expression\(/i.test(a[2]), `${label}: value ${a[2]}`);
    }
  }
  // outside well-formed tags there is no '<' at all: text content is escaped
  ok(!/</.test(svg.replace(/<\/?([A-Za-z][\w-]*)((?:\s+[\w:-]+="[^"<>]*")*)\s*\/?>/g, '')), `${label}: stray <`);
};
checkMarkup(out, 'injection');
ok(!out.includes('<script') && !out.includes('<img'), 'no script/img element');
A.CATALOG.forEach(e => { checkMarkup(A.renderPlaybook(A.parsePlaybook(e.anim).spec), e.id); checkMarkup(A.egoGraphSvg(e.id, 'plain'), e.id + ' graph'); });
checkMarkup(A.globalGraphSvg('watermelon'), 'global graph');

// 5. submissions: codec round trip, sanitizing, stable CID, lineage
const sub = { el: 'watermelon', kind: 'anim', lens: 'game', title: 'Spin <b>144</b>', by: 'Mike', playbook: 'circle r 40 spin 360\ntext "144" size 20' };
const enc = A.encodeSubmission(sub), dec = A.decodeSubmission(enc);
ok(dec.el === 'watermelon' && dec.kind === 'anim' && dec.lens === 'game' && dec.title === 'Spin b144/b' && dec.by === 'Mike', 'decode fields');
ok(A.encodeSubmission(dec) === enc, 'codec idempotent');
const cid1 = await A.submissionCid(sub), cid2 = await A.submissionCid(dec);
ok(cid1 === cid2 && /^bafyrei[a-z2-7]+$/.test(cid1), 'stable CID');
ok(cid1 !== await A.submissionCid({ ...sub, title: 'other' }), 'CID changes with content');
let threw = false; try { A.decodeSubmission(A.b64uEnc(JSON.stringify({ el: 'nope', kind: 'anim' }))); } catch (e) { threw = true; }
ok(threw, 'unknown element refused');
threw = false; try { A.decodeSubmission('%%%'); } catch (e) { threw = true; } ok(threw, 'garbage refused');
const t = A.decodeSubmission(A.b64uEnc(JSON.stringify({ el: 'zoo', kind: 'text', lens: 'evil', text: 'hi\u0000 there', parent: 'javascript:alert(1)' })));
ok(t.lens === 'plain' && t.text === 'hi there' && t.parent === undefined, 'text submission sanitized');
const child = { ...sub, title: 'remix', parent: cid1 }, cidC = await A.submissionCid(child);
const gal = [{ cid: cid1, sub: A.sanitizeSubmission(sub) }, { cid: cidC, sub: A.sanitizeSubmission(child) }];
ok(JSON.stringify(A.lineage(cidC, gal)) === JSON.stringify([cidC, cid1]), 'lineage');

// 6. tour: every step names a real view and element, fallback timing is sane
const views = [...html.matchAll(/<section id="(\w+)"/g)].map(m => m[1]);
A.tourSteps().forEach((s, i) => { ok(views.includes(s.view), `tour step ${i} view ${s.view}`); ok(!s.el || A.BY_ID[s.el], `tour step ${i} element`); ok(s.say.length > 20, `tour step ${i} text`); });
ok(A.fallbackMs('one two three') === 2500 && A.fallbackMs(Array(20).fill('w').join(' '), 2) === 4000, 'fallback timing');

console.log(fails === 0 ? `all atlas tests pass (${checks} checks)` : `${fails} failure(s) of ${checks}`);
process.exit(fails ? 1 : 0);
