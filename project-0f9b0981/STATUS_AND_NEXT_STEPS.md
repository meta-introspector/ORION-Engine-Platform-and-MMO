# Where the project stands, and how to use it for the game and community platform

## 1. What exists today

**What this is:** a *verified rulebook*, plus design documents and review reports.
**What this is not:** running software. There is no server, game client, website, database
or live community in this repository. Those still have to be built by a software team.

The rulebook is written in Lean, a language in which rules are defined precisely and a computer
checks every claim about them. The whole library builds with no `sorry` (no unfinished proof).
It uses only Lean's standard axioms, plus Lean's compiler for two large exhaustive checks.

### A. Rules the platform and game can adopt directly (proved)

| Rule | What it guarantees | File |
|---|---|---|
| Evidence weight `W(e)` (Operation Snake and Scale) | Repeating weak evidence can't raise its weight. Corroboration is capped at 1.5, reached at 5 sources. Discrepancy only lowers weight | `RequestProject/EvidenceWeight.lean` |
| Claim reliability score | Always between 0 and 1. Duplicates or weaker extra evidence change nothing. More support never lowers a score, and more conflict never raises it. Fixes the circular `D_r` in the original page | `RequestProject/Hub/Reliability.lean` |
| Zoo gate (Devs 2.0 / EFMW) | Hypotheses and simulations never count as evidence. Nothing enters the canonical record without human approval and preregistration. One auditor veto blocks admission. The prediction ledger is append-only | `RequestProject/Hub/ZooGate.lean` |
| Cross-discipline bridges | Suggestions are symmetric, always link *different* fields, and always show a shared tag ("linked because both involve …") | `RequestProject/Hub/CrossDiscipline.lean` |
| 13-level progression | Levels run 1–13 and never drop. Resubmitting the same work earns nothing. With the stated settings, no level can be skipped | `RequestProject/Hub/Progression.lean` |
| Kronos/Orion meters | The meter stays in 0–1, spikes fade, sustained play wins, and no payment input exists (no pay-to-shift) | `RequestProject/Hub/Meters.lean` |
| Totality engine (Matthew's "one room") | Same seed + state + input gives the same result. Logs replay exactly and edited logs are rejected. Counterfactuals share the past. Branching stores every history. Conserved quantities stay conserved | `RequestProject/Totality/` |

### B. Checks of the source documents and community submissions

These are in `NOTES.md`, `ORION_TOOLS.md` and `RequestProject/Submissions/`. Some claims held,
for example the Civ One 17-turn minimum, the bott Cl(8,0) matrices, the 3-6-9 digital roots
and the CUBY numbers. Others did not: the "144° angle" is not a dodecahedron angle, the
0xDA51 worked examples don't decode as stated, `W(e)` can exceed 1, and CUBY month 3 is
66/34 rather than 2:1.

### C. Design documents
* `HUB_DESIGN.md`: architecture of the knowledge hub, education layer and game layer.
* `COMPARISON.md`: lessons from Star Wars Galaxies, Fallout, EVE Project Discovery and others.
* `TOTALITY.md`: engine architecture and the 10 success criteria.
* `ORION_TOOLS.md`: where each community tool plugs in.
* `TGSATE_VISUALS.md`: the visual themes, mapped to levels, factions and meters.

### D. New this round: a hand-off kit for developers
* `RequestProject/Conformance/GoldenVectors.lean`: 30 exact input → output cases covering
  evidence weight, claim score, level, meter and Zoo gate. Lean checks every one against the
  rule definitions.
* `conformance/golden_vectors.json`: the same cases in a format any language can read.
* `conformance/reference.py`: a small Python version of the rules that passes all the cases
  (`python3 conformance/reference.py`). It is a starting template. Only the golden cases check
  it, not proofs.

### E. Static web app (`webapp/`)
`webapp/index.html` is a single-file offline app. It runs the rules, shares state by URL,
saves to the browser, and exports immutable DAG-CBOR/IPFS CAR snapshots, RDF, GIF and video.
It links claims to Wikidata, OSM, OEIS and LMFDB. See `webapp/README.md` for what is included
and what isn't: there is no built-in libp2p or relay, and no Lean-to-WebAssembly build.

## 2. What you can do with it now

1. **Use it as the rules spec.** Give developers the table in §1A and the JSON file. Any
   language works (TypeScript for the web platform, C# for Unity, C++ for Unreal, Rust or Go
   for servers). Each port must pass `golden_vectors.json` in its automated tests (CI) before it
   ships.
2. **Publish the rules.** The scoring, level and gate formulas are short and public. That
   matches the "every number can be explained" and "no hidden Jedi unlock" lessons in
   `COMPARISON.md`. Players and members can check their own scores.
3. **Build Matthew's one-room prototype.** `TOTALITY.md` §4 describes a runtime that logs
   seed, state and intervention for each step. Its logs can then be replayed against the Lean
   test room. This is the first real piece of the game.
4. **Change rules safely.** To change a number (a tier weight, XP per level, meter speed),
   change it in Lean first. The proofs then show which guarantees still hold. Regenerate the
   golden cases, and only then update the game. This avoids the live "NGE-style" redesign
   problem.
5. **Bring in community work the same way.** Submissions like Civ One or bott are re-checked
   and attached to one ORION component (`ORION_TOOLS.md`). New submissions can follow the same
   path.

## 3. Suggested build order

| Phase | Community platform | Game | Formal layer (where I can keep helping) |
|---|---|---|---|
| 1. Pilot (weeks) | Claims + evidence + scores for a few hundred concepts, with human curators | One-room Totality prototype | Golden vectors for each new rule. Differential tests of prototype logs |
| 2. Education | Courses as paths through concepts, bridge quests as capstones | Levels 1–13 unlock areas | Proofs for course unlock rules and quest rewards |
| 3. Community | Discussion on claims, guilds, private rooms (kant) | Guild projects, public events | Anti-farming and fairness proofs for rewards and economy (QX / Bubble Bucks) |
| 4. World | Global Crucible (citizen-science tasks) | Shared MMO world: realms by discipline, portals as verified bridges | Economy invariants (no money creation from nothing), replay audit at larger scale |

## 4. Limits, stated plainly
* I can write and check the rules, specs, reviews, reference code and test cases. I cannot run
  servers, host a community, build a client, or recruit people.
* The proofs show the rules *do what they say*. They don't show the chosen numbers are the
  best, that the game will be fun, or that any physical or metaphysical claim in the source
  documents is true.
* The Totality model is discrete and single-threaded. Real-time networking, rendering and
  floating-point physics are outside it.

## 5. Decisions only your team can make
* Is the claim score's "strongest item, not the sum" choice what you want? (`HUB_DESIGN.md` §2)
* XP per level `k`, and the meter speed `α`. The golden cases use `k = 10` and `α = 1/4` as
  examples.
* Which engine or stack the game uses, and which platform (web, mobile, Discord-style) comes first.
* The licence mix. Some tools are AGPL-3.0 and one is MIT (see `ORION_TOOLS.md`). A lawyer
  should review this before anything ships.

## 6. Update: focus on The Orion Chronicles
`ORION_CHRONICLES_BLUEPRINT.md` maps each part of the ORION Engine Architecture onto the game's
systems (quests, companions, meters, the Vault, AI-companion safety). The ORION Engine's
orchestration rules are now proved in `RequestProject/Orion/Engine.lean`: the eleven-phase loop,
the Independent Stop Mechanism, the intervention ladder, and the Snake and Scale debate loop and
ledger guard. Their golden vectors are in `conformance/engine_vectors.json`.

## 7. Update: the Ghost Rider Protocol and NewKin Council Architecture
The unified Ghost Rider / NewKin Council page is checked in `RequestProject/Orion/NewKin.lean`
(write-up: `NEWKIN_COUNCIL.md`). Proved: a session can end only from Orion, and the Kronos
lockout works as the page describes. The Catalyst is the only seat with final authority, and
publication ignores AI votes (no truth by consensus). An Auditor Hard Stop cannot be issued
without a diagnosis, pauses the Council, and only the Catalyst can resolve it. The ECHOSpiral
route has the stage order the page promises. The Gaia Factor equation has no literal
non-negative solution, which matches the page's statement that it is symbolic.

## 8. Update: compiled edition of Volumes I–IV
`CST_COMPILED_EDITION.md` combines the Volume I–IV pages, the Master Documents index and three
new Google Docs into one version. It uses the newest version of each idea and lists every
conflict and correction. Checks are in `RequestProject/CST/Geometry.lean` and
`RequestProject/CST/NumbersAndRules.lean`.

## 9. Update: Mike DuPont's suggestions, and five more Google Docs
* **Web app** (`webapp/`, details in `webapp/README.md`). A new **Atlas** tab covers 34 knowledge
  elements. Each has a status, a link to the Lean theorem that checks it, an ego graph, and a place in
  a global knowledge graph. At knowledge level n it shows n² representations (7 forms × 7 lenses; the
  counts are proved in `RequestProject/Hub/RepresentationGrid.lean`). Each element has its own SVG
  animation, written in a small whitelisted playbook language. Community remixes are shared by URL
  (`#sub=`), previewed as "unreviewed", and stored by CID with lineage. A spoken guided tour
  (`#tour=1`) has captions and a timer fallback. Tests: `node webapp/test_atlas.mjs`, plus new checks
  in `webapp/smoke_dom.mjs`.
  Mike's link `vesper.cicadia71.net` does not resolve. `vesper.cicada71.net` (hesper studio) does, and
  its conventions (one statement per line, URL-hash sharing, guided demo, speak button) were followed.
* **New documents** (full review in `REVIEW_NEW_DOCUMENTS.md`):
  * The NewKin Council experiment record and its interview logs became
    `RequestProject/Orion/AgencyGovernance.lean`. It proves Ghost Rider as a governor of delegated
    agency: no self-authorization, the Non-Delegable Rule, the Divergence Test, the Reauthorization Gate,
    expiring authority, and taking the wheel back at any time. It also proves the Council classroom
    rules (visibility ≠ speaking authority, blind mode, synthesis keeps dissent) and correlated consensus.
  * *The Ghost Writer in the Mirror* was already covered by `NewKin.lean`.
  * The ORION ENGINE v3.0 code was **not** added. Its "Ghost Rider" filter disguises requests to bypass
    safety instead of stopping them, its main pipeline calls undefined functions, and its Council and
    metrics are random numbers. Reproducer: `reviews/orion_engine_v3_check.py`.
  * The IT³ comparison led to `RequestProject/CST/RhombicSymmetry.lean`. The space-filling (rhombic)
    dodecahedron is exactly cube + octahedron, with full O_h symmetry.
