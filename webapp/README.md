# ORION Hub: static single-page web app

`index.html` is the whole app: one 104 KB file with no build step, no server, no external
scripts, fonts or CDNs. Open it straight from disk (`file://`), from any static host (GitHub
Pages, Netlify, an archive server, a USB stick), or from IPFS.

It puts the verified rules from this project in front of people: claim scores, cross-discipline
bridges, the 13-level path, the Kronos/Orion meter and the Zoo gate. It also gives them ways to
share and archive their work without any server.

## What is in it

| Item you asked for | Status | How |
|---|---|---|
| **singlepage, html5** | ✅ | One HTML5 file with inline CSS and JS. Views are tabs |
| **url args / sharing** | ✅ | The whole state is packed into `#s=…` (base64url JSON). `?view=bridges` etc. opens a tab. A share link rebuilds the exact state, with the same snapshot CID (tested) |
| **localStorage** | ✅ | Work is saved automatically in the browser |
| **immutable** | ✅ | Snapshots are content-addressed: same state → same CID, and any edit → a new CID. The snapshot log only appends. Imports are re-hashed and refused if a byte was changed |
| **dag-cbor** | ✅ | Deterministic DAG-CBOR encoder/decoder (map keys sorted length-first; fractions stored as strings, never floats) |
| **ipld / ipfs** | ✅ (file level) | CIDv1 (`dag-cbor`, sha2-256, base32 `bafy…`) plus **CARv1** export and import. A `.car` file should import with `ipfs dag import` (not tested here against a real IPFS node). The app itself can be pinned: `ipfs add --cid-version 1 --raw-leaves webapp/index.html` |
| **sneakernet, uucp, archive server** | ✅ (by file) | The `.car` / `.cbor` / `.json` exports are self-verifying files. They can go on a USB stick, by email, by UUCP-style batch copy, or to any archive server, and they're checked on import. There's no built-in UUCP client or archive server |
| **rdf / owl** | ✅ | Turtle export with a small OWL vocabulary (`orion:Claim`, `orion:Evidence`, `supportedBy`, `challengedBy`, `score`). Claims link out with `owl:sameAs wd:Q…` and `rdfs:seeAlso` |
| **wikidata** | ✅ | Per-claim Wikidata id, a link, and a live label/description lookup (the public API allows browser access) |
| **osm** | ✅ | Per-claim OpenStreetMap element (`node/…`, `way/…`, `relation/…`) as a link |
| **oeis** | ✅ | Per-claim A-number as a link (the demo uses A000045 Fibonacci and A001622 golden ratio) |
| **lmfdb** | ✅ | Per-claim LMFDB path as a link (e.g. `EllipticCurve/Q/11/a/2`) |
| **animated svg** | ✅ | Rotating 13-dot logo, pulsing 13-level ring, and an animated bridge graph (SMIL) |
| **webgl, shaders** | ✅ | Full-screen fragment shader (13 petals, rings). Its colour follows the Kronos↔Orion meter |
| **gif** | ✅ | Built-in animated-GIF encoder (LZW, 256 colours) that records the shader. Tested: Pillow decodes the output pixel for pixel, including frames large enough to reset the LZW table |
| **mpeg** | ✅ (browser-dependent) | Records the shader with the browser's MediaRecorder: MP4 where supported, otherwise WebM. No MPEG encoder is bundled |
| **tts** | ✅ | 🔊 on each claim reads its score explanation aloud (Web Speech API) |
| **spoken tour** (Mike DuPont's suggestion) | ✅ | "🔊 guided tour" (header or Atlas tab), or open with `#tour=1`. It steps through every tab and several Atlas elements, and has play/pause, previous/next, stop, speed, voice choice and live captions. With "captions only", or where speech is unavailable, it advances on a timer based on word count |
| **graph per knowledge element** | ✅ | Atlas tab. Each of the 34 elements has an ego graph of its links, plus a clickable global knowledge graph. Both use a fixed circular layout and are coloured by status (proved / corrected / symbolic / design rule) |
| **n² representations at knowledge level n** | ✅ | 7 forms (card, graph, animation, speech, numbers, quiz, linked data JSON-LD) × 7 lenses (plain words, framework, evidence, try it, make it, where it comes from, open question). Level n shows the first n × n cells: 1 at level 1, 9 at level 3 (the default), 49 at level 7. The counts are proved in `RequestProject/Hub/RepresentationGrid.lean` (`card_level`, `level_mono`, `card_level_succ_sdiff`) and tested against the page |
| **SVG animation per element** | ✅ | Each element has an animation written in a small playbook language, one statement per line, in the style of hesper studio (vesper.cicada71.net). Example: `circle r 60 stroke #7fd4ff spin 360`. It is rendered to SMIL SVG through a whitelist: numbers are clamped, colours checked, text escaped, at most 40 shapes. Raw SVG is never accepted |
| **community submissions via URL** | ✅ | The Atlas editor remixes an animation, or writes text for a lens, and builds a link `?view=atlas&el=…#sub=<base64url JSON>`. Opening the link shows a preview first, labelled "community · unreviewed". "Add to my gallery" stores it in this browser under its DAG-CBOR CID. Remixes record their parent's CID, so the gallery shows lineage. There is no server: sharing is by link |
| **wasm extracted** | ❌ not done | The rules are a hand port to JavaScript, not WebAssembly compiled from Lean. That toolchain isn't set up here. The port is instead pinned to the Lean definitions by the 30 golden cases, which the page can run itself (Verify tab) |
| **relay, libp2p** | ❌ not built in | A static page can't run a relay. The sync unit already exists: a CID-named DAG-CBOR block in a CAR file, which is what IPFS/libp2p peers exchange. Adding js-libp2p/Helia would be the next step and needs a bundled dependency |

## Tests

```
node webapp/test_core.mjs      # rules, golden cases, DAG-CBOR, CID, CAR, tamper detection, Turtle, GIF
node webapp/test_atlas.mjs     # Atlas: catalog, Lean names exist, n² grid, playbook, injection, submissions, tour
python3 webapp/check_gif.py    # decode the test GIF with Pillow, compare every pixel
NODE_PATH=/path/to/node_modules node webapp/smoke_dom.mjs   # headless UI run (needs `npm install jsdom`)
```

What the tests pin down:
- The 30 golden cases embedded in the page match `conformance/golden_vectors.json`, and the
  JavaScript rules pass them all. Lean checks the same 30 cases in
  `RequestProject/Conformance/GoldenVectors.lean`.
- The empty DAG-CBOR map gets the standard CID
  `bafyreigbtj4x7ip5legnfznufuopl4sg4knzc2cof6duas4b3q2fy6swua`, and empty raw bytes get
  `bafkreihdwdcefgh4dqkjv67uzcmw7ojee6xedzdetojuzjevtenxquvyku`.
- CAR files round-trip, and a single flipped bit is detected.
- Atlas: every element links to a real theorem (checked against the Lean file), the knowledge graph is
  connected, level n has n² distinct non-empty cells and nesting adds 2n+1, playbooks round-trip, a
  battery of injection attempts produces only whitelisted SVG tags and attributes, and submissions
  round-trip with a stable CID and lineage.
- In the UI: one veto blocks admission, extra copies of the same evidence don't move a score,
  share links restore the state and view, and localStorage persists. The Atlas shows 9 cells at level 3
  and 49 at level 7, a submission link opens in a fresh window as an escaped preview and can be added to
  the gallery, and `#tour=1` opens the tour bar, which steps through the tabs.

jsdom has no WebGL, speech, clipboard or video recorder, so those parts are only exercised in a
real browser. I have not run the page in a real browser.

## Version pin

sha256 of `index.html` in this commit:
`f3d56a01afa67f515b9dbedeaec058a21d17bed852f6b208be87397568605ed7`.
With `ipfs add --cid-version 1 --raw-leaves`, a single-chunk file like this one should get
`bafkreiht2vvadl5gp5ivxhn632xmawfcdul35wcs62zarpuhhf2wqyc624` (computed here, not checked with
an IPFS node). Any edit to the file changes both.
