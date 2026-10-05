// friction atlas — test suite (node test/run.mjs [outdir])
// Checks the logic modules without a browser. Pass an output directory to also
// dump every generated SVG so that test/wellformed.py can XML-parse them.
import { createRequire } from 'node:module';
import fs from 'node:fs';
import path from 'node:path';
const require = createRequire(import.meta.url);
const E = require('../js/expr.js');
const SVG = require('../js/svgkit.js');
const K = require('../js/knowledge.js');
const GR = require('../js/grid.js');
const S = require('../js/share.js');
const T = require('../js/tour.js');

let pass = 0, fail = 0;
const ok = (cond, msg) => { if (cond) pass++; else { fail++; console.error('FAIL', msg); } };
const throws = (f, msg) => { try { f(); ok(false, msg + ' (did not throw)'); } catch (e) { ok(true, msg); } };
const outDir = process.argv[2];
if (outDir) fs.mkdirSync(outDir, { recursive: true });
const dump = (name, svg) => { if (outDir) fs.writeFileSync(path.join(outDir, name.replace(/[^a-z0-9._-]/gi, '_') + '.svg'), svg); };

// ---------------------------------------------------------------- expr
ok(E.compile('sin(x) + 2^3')({ x: 0 }) === 8, 'expr arithmetic');
ok(Math.abs(E.compile('exp(-t)*cos(pi*x)')({ x: 1, t: 0 }) + 1) < 1e-12, 'expr functions/constants');
ok(E.compile('-2^2')({}) === -4, 'unary minus binds looser than ^');
ok(E.compile('2^3^2')({}) === 512, '^ is right-associative');
for (const bad of ['alert(1)', 'constructor', 'x.y', 'x; y', 'this', '__proto__(1)', '1 +', '((1)', 'a[0]', '`x`', 'x=1'])
  throws(() => E.compile(bad)({ x: 1, y: 1 }), 'expr rejects ' + bad);
throws(() => E.compile('('.repeat(100) + '1' + ')'.repeat(100)), 'expr rejects deep nesting');
throws(() => E.compile('1+'.repeat(300) + '1'), 'expr rejects long input');

// ---------------------------------------------------------------- grid (matches RequestProject/Site/Grid.lean)
ok(GR.MAX_LEVEL === 5, 'five levels');
for (let n = 1; n <= GR.MAX_LEVEL; n++) {
  const cs = GR.cells(n);
  ok(cs.length === n * n, `level ${n} has n² = ${n * n} cells`);
  ok(new Set(cs.map((c) => c.index)).size === n * n && cs.every((c) => c.index < n * n), `level ${n} indices are 0…n²-1`);
  ok(cs.every((c) => { const b = GR.cellAt(n, c.index); return b.r === c.r && b.c === c.c && GR.cellIndex(n, c.r, c.c) === c.index; }), `level ${n} index ⇄ cell`);
  if (n < GR.MAX_LEVEL) {
    const up = new Set(GR.cells(n + 1).map((c) => c.r + ',' + c.c));
    ok(cs.every((c) => up.has(c.r + ',' + c.c)), `level ${n} ⊆ level ${n + 1}`);
    ok(GR.newCells(n).length === 2 * n + 1, `level ${n}→${n + 1} adds 2n+1 cells`);
  }
}

// ---------------------------------------------------------------- every representation of every element
const finiteCoords = (svg) => !/NaN|Infinity|undefined/.test(svg);
let reps = 0;
for (const el of K.ELEMENTS) {
  ok(el.depths.length === 5, el.id + ' has five depths');
  ok(el.builds.every((b) => K.byId[b]), el.id + ' builds on known elements');
  ok(el.status === 'interpretive' || /^Friction\./.test(el.theorem), el.id + ' names its theorem');
  for (let n = 1; n <= GR.MAX_LEVEL; n++) {
    const prints = GR.cells(n).map(({ r, c }) => GR.fingerprint(el, r, c));
    ok(new Set(prints).size === n * n, `${el.id} level ${n}: all ${n * n} representations differ`);
  }
  for (let r = 0; r < 5; r++) for (let c = 0; c < 5; c++) {
    const rep = GR.render(el, r, c);
    const svg = rep.kind === 'svg' ? rep.svg : GR.interactiveSVG(el, r, rep.p[rep.param.key], null);
    ok(/^<svg /.test(svg) && svg.endsWith('</svg>'), `${el.id} ${r},${c} is an svg`);
    ok(finiteCoords(svg), `${el.id} ${r},${c} has only finite numbers`);
    if (GR.FORMS[c].id === 'animation') ok(/<animate /.test(svg), `${el.id} ${r} animation animates`);
    dump(`${el.id}__${K.DEPTHS[r].id}__${GR.FORMS[c].id}`, svg);
    reps++;
  }
}
console.log('representations rendered:', reps);
const g = SVG.graph(K.ELEMENTS.map((e) => ({ id: e.id, title: e.title, short: e.short, pos: e.pos })), K.EDGES);
ok(K.ELEMENTS.every((e) => g.includes(`data-id="${e.id}"`)), 'knowledge graph has every node');
dump('knowledge-graph', g);

// ---------------------------------------------------------------- share
const good = {
  v: 1, type: 'rep', el: 'goldilocks-band', depth: 'everyday', title: 'Swing damping', author: 'A. Reader',
  body: { kind: 'formula', expr: 'exp(-0.3*x)*sin(3*x - t)', xr: [0, 10], yr: [-1, 1], T: 6 },
};
ok(S.validate(good).ok, 'valid formula submission');
const rt = await S.decode(await S.encode(good));
ok(JSON.stringify(rt) === JSON.stringify(good), 'encode/decode round trip');
ok((await S.encode(good))[0] === 'z', 'links are compressed when possible');
const plainRt = await S.decode('u' + S._b64.bytesToB64url(new TextEncoder().encode(JSON.stringify(good))));
ok(JSON.stringify(plainRt) === JSON.stringify(good), 'plain links decode');
const sub = S.renderSubmission(good);
ok(/<animate /.test(sub) && finiteCoords(sub), 'formula submission renders an animated svg');
dump('submission-formula', sub);
const svgGood = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><linearGradient id="g"><stop offset="0" stop-color="#fff"/></linearGradient></defs><circle cx="50" cy="50" r="20" fill="url(#g)"><animate attributeName="r" values="10;30;10" dur="2s" repeatCount="indefinite"/></circle></svg>';
ok(S.validate({ ...good, body: { kind: 'svg', svg: svgGood } }).ok, 'valid svg submission');
const nasty = [
  '<svg><script>alert(1)</script></svg>',
  '<svg onload="alert(1)"></svg>',
  '<svg><a href="javascript:alert(1)"><text>x</text></a></svg>',
  '<svg><foreignObject><div/></foreignObject></svg>',
  '<svg><image href="https://tracker.example/x.png"/></svg>',
  '<svg><use xlink:href="https://evil.example/s.svg#a"/></svg>',
  '<svg><style>@import url(https://evil.example/x.css);</style></svg>',
  '<svg><rect style="fill:url(https://evil.example/p)"/></svg>',
  '<!DOCTYPE svg [<!ENTITY x "y">]><svg></svg>',
  '<svg><set attributeName="onclick" to="alert(1)"/></svg>',
  '<svg><animate attributeName="href" values="javascript:alert(1)"/></svg>',
  '<svg><rect ONMOUSEOVER = "x()"/></svg>',
  '<div><svg></svg></div>',
];
for (const n of nasty) ok(!S.validate({ ...good, body: { kind: 'svg', svg: n } }).ok, 'rejects ' + n.slice(0, 50));
ok(!S.validate({ ...good, body: { ...good.body, expr: 'x + y' } }).ok, 'rejects unknown formula variables');
ok(!S.validate({ ...good, el: 'nope' }).ok, 'rejects unknown element');
ok(!S.validate({ ...good, el: null }).ok, 'new element needs a title');
ok(S.validate({ ...good, el: null, newElement: { title: 'Stick-slip', text: 'static vs kinetic' } }).ok, 'new element submission');
ok(!S.validate({ ...good, v: 2 }).ok, 'rejects other versions');
ok(!S.validate({ ...good, body: { ...good.body, xr: [3, 1] } }).ok, 'rejects bad ranges');
let threw = false; try { await S.decode('z!!!'); } catch (e) { threw = true; } ok(threw, 'damaged link rejected');
const h = S.parseHash(S.addressHash('traction', 2, 3, 4));
ok(h.at.el === 'traction' && h.at.r === 2 && h.at.c === 3 && h.n === 4, 'address round trip');
ok(S.parseHash('#n=99').n === 5 && S.parseHash('#n=0').n === 1, 'level in links is clamped');

// ---------------------------------------------------------------- tour (matches RequestProject/Site/Tour.lean)
ok(T.STEPS.length > 20, 'tour has steps');
for (let i = -3; i < T.STEPS.length + 3; i++) {
  const tg = T.targetAt(i);
  ok(tg && (tg.view || K.byId[tg.el]), 'tour stage never blank at ' + i);
  ok(T.next(i) >= 0 && T.next(i) < T.STEPS.length && T.prev(i) >= 0 && T.prev(i) < T.STEPS.length, 'cursor stays in script at ' + i);
}
for (const s of T.STEPS) if (s.target && s.target.el) {
  const { r, c, n } = s.target;
  ok(n >= 1 && n <= 5 && r < n && c < n, 'tour target inside its level grid: ' + s.target.el);
}
ok(T.next(T.STEPS.length - 1) === T.STEPS.length - 1 && T.prev(0) === 0, 'cursor clamps at the ends');
ok(T.STEPS.every((s) => T.sentences(s.say).length >= 1), 'every step has speakable sentences');

console.log(`${pass} passed, ${fail} failed`);
process.exit(fail ? 1 : 0);
