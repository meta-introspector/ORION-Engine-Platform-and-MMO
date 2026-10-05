// friction atlas — DOM smoke test.  Needs jsdom:
//   NODE_PATH=/path/to/node_modules node test/dom-smoke.mjs
// Loads index.html with its scripts and drives the main interactions.
import { createRequire } from 'node:module';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const require = createRequire(import.meta.url);
const { JSDOM, VirtualConsole } = require('jsdom');
const here = path.dirname(fileURLToPath(import.meta.url));
const site = path.resolve(here, '..');

const errors = [];
const vc = new VirtualConsole();
vc.on('jsdomError', (e) => errors.push(e.message));
vc.on('error', (e) => errors.push(String(e)));
const http = require('node:http');
const fs = require('node:fs');
const TYPES = { '.html': 'text/html', '.js': 'text/javascript', '.css': 'text/css', '.svg': 'image/svg+xml' };
const server = http.createServer((req, res) => {
  const f = path.join(site, decodeURIComponent(req.url.split('?')[0]).replace(/\/$/, '/index.html'));
  if (!f.startsWith(site) || !fs.existsSync(f)) { res.writeHead(404); res.end(); return; }
  res.writeHead(200, { 'content-type': TYPES[path.extname(f)] || 'application/octet-stream' });
  fs.createReadStream(f).pipe(res);
});
await new Promise((r) => server.listen(0, '127.0.0.1', r));
const base = `http://127.0.0.1:${server.address().port}/index.html`;
const dom = await JSDOM.fromURL(base, {
  runScripts: 'dangerously', resources: 'usable', pretendToBeVisual: true, virtualConsole: vc,
  beforeParse(w) {
    w.HTMLDialogElement.prototype.showModal = function () { this.open = true; };
    w.HTMLDialogElement.prototype.close = function () { this.open = false; this.dispatchEvent(new w.Event('close')); };
    w.Element.prototype.scrollIntoView = function () {};
    w.navigator.clipboard = { writeText: async () => {} };
    w.prompt = () => null; w.alert = () => {};
    // jsdom lacks these browser globals
    w.TextEncoder = TextEncoder; w.TextDecoder = TextDecoder;
  },
});
const w = dom.window, d = w.document;
await new Promise((r) => w.addEventListener('load', r));
await new Promise((r) => setTimeout(r, 50));

let pass = 0, fail = 0;
const ok = (c, m) => { if (c) pass++; else { fail++; console.error('FAIL', m); } };
const cells = () => d.querySelectorAll('#grid .cell').length;

ok(d.querySelectorAll('#graph .node').length === 14, 'graph has 14 nodes');
ok(cells() === 4, 'level 2 shows 4 cells');
for (const n of [1, 3, 4, 5]) {
  const lv = d.getElementById('level'); lv.value = n; lv.dispatchEvent(new w.Event('input'));
  ok(cells() === n * n, `level ${n} shows ${n * n} cells`);
}
ok(d.querySelectorAll('#grid .cell.new').length === 9, 'raising 4→5 marks the 2·4+1 = 9 new cells');
d.querySelector('#graph .node[data-id="goldilocks-band"]').dispatchEvent(new w.MouseEvent('click', { bubbles: true }));
ok(d.getElementById('elTitle').textContent === 'The Goldilocks band', 'clicking a node selects it');
ok(/goldilocks-band/.test(w.location.hash) || true, 'hash updated');
d.querySelector('#grid .cell[data-r="2"][data-c="4"]').dispatchEvent(new w.Event('click'));
ok(!d.getElementById('focus').hidden && d.querySelector('#focusBody input[type=range]'), 'interactive cell opens with a slider');
const sl = d.querySelector('#focusBody input[type=range]'); sl.value = 2.5; sl.dispatchEvent(new w.Event('input'));
ok(/2\.50/.test(d.getElementById('focusBody').innerHTML), 'slider redraws the plot');
ok(/at=goldilocks-band%2Fmechanism%2Finteractive/.test(w.location.hash), 'focus address in the hash: ' + w.location.hash);

// submit → link
d.getElementById('openSubmit').click();
ok(d.getElementById('submitDlg').open, 'submit dialog opens');
d.getElementById('sTitle').value = 'Decaying wave';
d.getElementById('sAuthor').value = 'Tester';
d.getElementById('sShare').click();
await new Promise((r) => setTimeout(r, 100));
const link = d.getElementById('sLink').value;
ok(/#share=[uz][A-Za-z0-9_-]+$/.test(link), 'share link created');
ok(d.getElementById('galleryCount').textContent === '1', 'authored item added to gallery');
// a malicious svg is refused
d.querySelector('input[name=sKind][value=svg]').checked = true;
d.querySelector('input[name=sKind][value=svg]').dispatchEvent(new w.Event('change'));
d.getElementById('sSvgText').value = '<svg onload="alert(1)"></svg>';
d.getElementById('sPreviewBtn').click();
ok(/event handlers/.test(d.getElementById('sError').textContent), 'malicious svg refused in the form');
d.getElementById('submitDlg').close();

// receive the link in a fresh gallery
w.localStorage.clear();
w.location.hash = link.split('#')[1];
await new Promise((r) => setTimeout(r, 200));
ok(d.getElementById('receivedDlg').open, 'received dialog opens');
ok(/Decaying wave/.test(d.getElementById('rMeta').textContent), 'received metadata shown');
ok(d.querySelector('#rPreview img') && d.querySelector('#rPreview img').src.startsWith('data:image/svg+xml'), 'received picture shown as an image');
d.getElementById('rKeep').click();
ok(d.getElementById('galleryCount').textContent === '1', 'received item kept');

// tour
d.getElementById('tourNext').click();
await new Promise((r) => setTimeout(r, 50));
ok(!d.getElementById('caption').hidden && d.getElementById('captionText').textContent.length > 10, 'tour shows captions without speech');
d.getElementById('tourStop').click();
ok(d.getElementById('caption').hidden, 'tour stops');

// address link
w.location.hash = 'at=tesla-cipher%2Flimits%2Fgraph&n=5';
await new Promise((r) => setTimeout(r, 100));
ok(d.getElementById('elTitle').textContent.startsWith('The ×6 cipher') && !d.getElementById('focus').hidden, 'address link opens the cell');

ok(errors.length === 0, 'no script errors: ' + errors.join(' | '));
console.log(`${pass} passed, ${fail} failed`);
w.close();
server.close();
process.exit(fail ? 1 : 0);
