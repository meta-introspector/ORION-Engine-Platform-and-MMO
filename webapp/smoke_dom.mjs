// Headless UI smoke test (needs `npm install jsdom`). Run: NODE_PATH=<dir>/node_modules node webapp/smoke_dom.mjs
// jsdom has no WebGL, clipboard, speech or MediaRecorder, so those paths are only checked for not crashing.
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { webcrypto } from 'node:crypto';
const require = createRequire(import.meta.url);
const { JSDOM } = require('jsdom');
const html = readFileSync(new URL('./index.html', import.meta.url), 'utf8');
let fails = 0; const ok = (c, m) => { if (!c) { fails++; console.log('FAIL', m); } };
const sleep = ms => new Promise(r => setTimeout(r, ms));

function open(url) {
  const errors = [];
  const dom = new JSDOM(html, { url, runScripts: 'dangerously', pretendToBeVisual: true,
    beforeParse(w) { Object.defineProperty(w, 'crypto', { value: webcrypto }); w.TextEncoder = TextEncoder; w.TextDecoder = TextDecoder; w.Uint8Array = Uint8Array; w.HTMLCanvasElement.prototype.getContext = () => null;
      w.addEventListener('error', e => errors.push(e.message)); } });
  return { dom, w: dom.window, d: dom.window.document, errors };
}

const A = open('https://example.org/orion/index.html');
await sleep(50);
const { d, w } = A;
ok(A.errors.length === 0, 'script errors: ' + A.errors.join('; '));
ok(d.querySelectorAll('#claimList > .card').length === 4, 'demo claims rendered');
ok(d.querySelector('#claims').classList.contains('on'), 'claims view shown by default');
ok(d.querySelector('#levelInfo').textContent.includes('level 1 of 13'), 'level shown: ' + d.querySelector('#levelInfo').textContent);
ok(d.querySelector('#bridgeList').textContent.includes('golden-ratio'), 'bridge with shared tag shown');
ok(d.querySelector('#meterInfo').textContent.includes('77/128'), 'meter matches golden value 77/128');
ok(d.querySelector('#zOut').textContent.includes('ADMITTED'), 'zoo admits by default');

// Zoo veto
d.querySelector('#zVetoes [data-z="0"]').click();
ok(d.querySelector('#zOut').textContent.includes('NOT admitted'), 'one veto blocks');

// add a claim and support; anti-volume check through the UI
d.querySelector('#nText').value = 'Test claim'; d.querySelector('#nDisc').value = 'physics'; d.querySelector('#nTags').value = 'symmetry';
d.querySelector('#nAdd').click();
ok(d.querySelectorAll('#claimList > .card').length === 5, 'claim added');
const addSupport = () => d.querySelector('[data-act="addev"][data-c="4"][data-s="support"]').click();
addSupport(); const s1 = d.querySelectorAll('#claimList .score')[4].textContent;
addSupport(); addSupport(); const s3 = d.querySelectorAll('#claimList .score')[4].textContent;
ok(s1 === s3 && s1.startsWith('11/15'), `anti-volume in UI (${s1} vs ${s3})`);

// navigation + ?view=
d.querySelector('nav button[data-v="verify"]').click();
ok(w.location.search.includes('view=verify'), 'view in URL');
d.querySelector('#runGold').click();
ok(d.querySelector('#goldOut').textContent.includes('30 / 30'), 'golden vectors pass in the page: ' + d.querySelector('#goldOut').textContent);

// snapshot (CID) and share link round trip
d.querySelector('#snap').click(); await sleep(100);
ok(/CID bafyrei[a-z2-7]+/.test(d.querySelector('#snapInfo').textContent), 'snapshot CID shown');
ok(d.querySelectorAll('#snapLog li').length === 1, 'snapshot logged');
d.querySelector('#shCopy').click(); await sleep(50);
const shared = w.location.href;
ok(shared.includes('#s='), 'share link in address bar');

// localStorage persisted
ok(JSON.parse(w.localStorage.getItem('orion-hub-state')).claims.length === 5, 'saved to localStorage');

// open the share link in a fresh window: same claims, same CID
const B = open(shared); await sleep(50);
ok(B.errors.length === 0, 'script errors in shared view');
ok(B.d.querySelectorAll('#claimList > .card').length === 5, 'shared state restored');
ok(B.d.querySelector('#verify').classList.contains('on'), 'shared link keeps the view');
B.d.querySelector('#snap').click(); await sleep(100);
ok(B.d.querySelector('#snapInfo').textContent === d.querySelector('#snapInfo').textContent, 'same state, same CID');

// Atlas: n² grid, element switch, remix, submission link round trip, tour
d.querySelector('nav button[data-v="atlas"]').click();
ok(d.querySelector('#atlas').classList.contains('on'), 'atlas view');
ok(d.querySelectorAll('#atGrid .gcell').length === 9, 'level 3 shows 9 cells');
const lv = d.querySelector('#atLvl'); lv.value = '7'; lv.dispatchEvent(new w.Event('input'));
ok(d.querySelectorAll('#atGrid .gcell').length === 49, 'level 7 shows 49 cells');
ok(w.location.search.includes('n=7'), 'level in URL');
const sel = d.querySelector('#atEl'); sel.value = 'agency'; sel.dispatchEvent(new w.Event('change'));
ok(d.querySelector('#atHead').textContent.includes('completion_not_authorization'), 'element switch');
ok(d.querySelectorAll('#atGrid svg animateTransform, #atGrid svg animate').length > 0, 'SVG animations in grid');
ok(d.querySelectorAll('#atGlobal [data-el]').length >= 30, 'global graph nodes');
d.querySelector('#sbPb').value = 'circle r 40 spin 360\ntext "<script>alert(1)</script>" size 14';
d.querySelector('#sbTitle').value = 'test remix'; d.querySelector('#sbPb').dispatchEvent(new w.Event('input'));
ok(!d.querySelector('#sbPrev').innerHTML.includes('<script'), 'preview escapes text');
w.prompt = () => null;
d.querySelector('#sbLink').click(); await sleep(50);
const subLink = d.querySelector('#sbOut').value;
ok(subLink.includes('#sub=') && subLink.includes('view=atlas'), 'submission link built');
d.querySelector('#sbSave').click(); await sleep(100);
ok(JSON.parse(w.localStorage.getItem('orion-atlas-subs')).length === 1, 'saved to gallery');
ok(d.querySelector('#atGallery').textContent.includes('community · unreviewed'), 'gallery labels unreviewed');
const Cw = open(subLink); await sleep(100);
ok(Cw.errors.length === 0, 'script errors in submission view: ' + Cw.errors.join('; '));
ok(Cw.d.querySelector('#atlas').classList.contains('on'), 'submission link opens atlas');
ok(Cw.d.querySelector('#atIncoming').textContent.includes('shared with you'), 'incoming submission previewed');
ok(!Cw.d.querySelector('#atIncoming').innerHTML.includes('<script'), 'incoming submission escaped');
Cw.d.querySelector('#inAdd').click(); await sleep(100);
ok(JSON.parse(Cw.w.localStorage.getItem('orion-atlas-subs') || '[]').length >= 1, 'incoming added on request');
const T = open('https://example.org/orion/index.html#tour=1'); await sleep(50);
ok(T.errors.length === 0, 'script errors with tour');
ok(T.d.querySelector('#tourBar').style.display === 'flex' && T.d.querySelector('#tCap').textContent.startsWith('1/'), 'tour bar opens with captions');
T.d.querySelector('#tNext').click(); T.d.querySelector('#tNext').click();
ok(T.d.querySelector('#tCap').textContent.startsWith('3/') && T.d.querySelector('#levels').classList.contains('on'), 'tour steps through views');

console.log(fails ? `${fails} failure(s)` : 'UI smoke test passes');
process.exit(fails ? 1 : 0);
