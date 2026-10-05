# Friction Atlas

This is an interactive, spoken companion to `../FRICTION_EXAMINATION.md`. It is a static site: plain HTML, CSS and JavaScript, with no dependencies and no build step.

## Opening it

* **Quick look:** open `index.html` in a browser. Everything works except one thing. Share links made from a `file://` page point at your local file, and the page shows a hint about this.
* **Shareable:** serve the folder over HTTP. For example:
  * `cd site && python3 -m http.server 8000`, then visit `http://localhost:8000/`;
  * or publish the folder with GitHub Pages or any other static host. Share links then work for anyone.

## What is in it

* **14 knowledge elements.** Each one is a node in the knowledge graph. 13 of them correspond to Lean theorems proved in `RequestProject/Friction/*.lean`. The 14th, *Babel: where friction sits*, is marked as interpretive.
* **Knowledge level n (1–5).** At level n, each element shows an **n × n grid**:
  * the first n *depths* are the rows: Everyday, Image, Mechanism, Formal, Limits;
  * the first n *forms* are the columns: Words, Graph, Symbols, Animation, Interactive.

  That gives n² representations per element, and 14 × 25 = 350 at level 5. Raising the level from n to n+1 adds exactly 2n+1 cells, and those cells flash.
* **SVG animations.** They use SMIL, so the saved `.svg` files also animate in an `<img>` or a file viewer. The Interactive form has a parameter slider with a sweep button.
* **Spoken tour.** It has 33 steps and uses the browser's Web Speech voices. It speaks sentence by sentence with captions, and you can pause, go back, or skip. If no voice is available, captions advance on a reading timer.
* **Community submissions.**
  1. *Submit* makes either a new representation for an element (a cell) or a new element.
  2. Content can be text, a formula `y = f(x, t)` (rendered as an animated SVG), or pasted SVG.
  3. You get a link. Whoever opens it sees the submission and can keep it in their gallery. The gallery is stored in the browser's localStorage and can be exported and imported as JSON.

## Link formats

| Fragment | Meaning |
|---|---|
| `#at=<element>/<depth>/<form>&n=<level>` | opens a specific representation, e.g. `#at=goldilocks-band/mechanism/animation&n=4` |
| `#tour=<k>` | starts the tour at step k |
| `#share=z…` / `#share=u…` | a submission: JSON, deflate-raw compressed (`z`) or uncompressed (`u`), base64url |

Everything is kept in the URL fragment, so no server ever receives or stores a submission.

## Safety model

* **Formulas** are parsed by a small tree-walking parser (`js/expr.js`). It does not use `eval`, allows only whitelisted functions, and limits formula length to 400 characters and nesting depth to 64.
* **SVG** is rejected if it contains scripts, `on*` handlers, `href`/`src`, `foreignObject`, external `url(...)`, DOCTYPE/entities, and similar constructs. SVG that passes is displayed only as a `data:` URL `<img>`, where browsers do not run scripts anyway.
* **User text** is always inserted with `textContent`, never as HTML.
* **Size limits:** SVG up to 60 000 characters, notes up to 1 200 characters, links up to 200 000 characters.

## Tests

```
node test/run.mjs              # 1061 checks: grid arithmetic, distinct n² representations,
                               # SVG output finite, share round-trip, malicious SVG rejected, tour invariants
node test/run.mjs /tmp/svgs && python3 test/wellformed.py /tmp/svgs   # every emitted SVG parses as XML
NODE_PATH=<jsdom install>/node_modules node test/dom-smoke.mjs   # DOM smoke test (needs jsdom)
```

The Lean files `RequestProject/Site/Grid.lean` and `RequestProject/Site/Tour.lean` specify the grid and tour-cursor arithmetic, and the results are proved there:
* n² cells per level;
* 2n+1 new cells per level step;
* row-major numbering is a bijection;
* the tour cursor stays in range;
* the tour stage is never blank.

`run.mjs` checks that the JavaScript agrees with these results. The Lean files do not prove anything about the JavaScript directly.

## Note on the inspiration site

`vesper.cicadia71.net` does not resolve. The design ideas were taken from `vesper.cicada71.net`, which is presumably the intended address:
* sharing through URL fragments;
* a tour where every step has a picture.
