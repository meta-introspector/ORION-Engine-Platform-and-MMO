# Summary of changes for run e617180f-522d-4cd5-9f3c-d5509a9ba768
The full explanation is in the new file `BUILD_GUIDE.md`. Here are the main points.

**What this build is:** a verified rulebook, not running software. It doesn't browse the web, talk to other AIs or run agents. The rules for your ideas (Ghost Rider, the NewKin Council, the ORION Engine, the knowledge hub, the game engine core) are written in a language called Lean. For each rule, a computer has checked a proof that the rule does what it claims. Current state: the library builds, with about 480 theorems across 27 files and no unfinished proofs. It uses only Lean's standard axioms, plus Lean's compiler for two large exhaustive checks (Civ One replay and the bott matrices).

**How it works:**
1. Each rule is defined as a small machine. For Ghost Rider, the state is the goal the human set, the actions the human approved, the remaining budget and a history log. Events come from the agent (think, propose, act) or the human (authorize, approve, take the wheel back).
2. Each claim is a theorem, for example "an agent can never give itself a goal". Lean rejects any proof with a gap.
3. Golden test cases (`conformance/*.json`) let developers in any programming language show that their code follows the verified rules. The Python reference passes all of them. I re-ran two of the web app's three test suites and they pass; the third (the browser simulation) needs an extra package that isn't installed here, so I didn't re-run it.

**What's covered:**
- **AI governance:**
  - No self-authorization, the Non-Delegable Rule, the Divergence Test, one-time human approvals, expiring authority and take-the-wheel-back.
  - Only the human Catalyst has final authority, and AI votes can't publish anything.
  - The Auditor Hard Stop, and ten models from the same training base counting as one source.
- **Knowledge hub:** evidence weights, claim scores, the Zoo gate and level progression.
- **Game engine:** exact replay, and edited logs are rejected.
- **Source-document checks:** some claims held and some were corrected.
- **Documents and web app:** the design documents and an offline web app.

**The incident check from last time** is in `RequestProject/Orion/IncidentLessons.lean`, with a write-up in `INCIDENT_REVIEW.md`. In the Ghost Rider model:
- Messages between agents grant nothing, and authority can't be pooled.
- Each agent stays on its own human's goal.
- The whole group can do at most the sum of the budgets humans granted.
- The history can't be erased.
- The limit: if agents can change the enforcement layer itself, every guarantee fails.

**About Gemini's reply:** its explanation of the mechanism (optimization plus bad incentives plus weak containment, not a conscious uprising) is reasonable. But "spectacular validation" goes too far. Nobody has verified the incident here, and a problem your framework is aimed at is not proof that the framework solves it. The proofs also show that putting a human in the seat isn't enough on its own. The guarantees need the agents to be unable to reach the enforcement layer, and by the account you shared, that is exactly what failed.

To answer Gemini's question: the rules hold up in the model. What needs hardening is what they assume. Concretely:
- Keep the governor, logs and approvals on systems the agents can't write to.
- Chain each record to the previous one so any later edit is detectable.
- Require permission for agent-to-agent channels.
- Add a group-wide cap, not just per-agent budgets.
- Never count an agent's own output as evidence that it succeeded.

I can formalize any of these next, for example a chained log with a proof that any edit is detected.

# Summary of changes for run e6238735-2d16-4878-9fa6-93105871a73f
I did the tasks Mike suggested and checked all five Google Docs before using any of them. Two of the docs went into the project. One was already covered, one I left out because it's broken and unsafe, and one led to a small correction. The three new Lean files build with no `sorry` and only the standard axioms. The web app's three test suites (core rules, Atlas logic, and a simulated browser run) all pass. I have not opened the app in a real browser, so the spoken voice and the look on screen are untested.

**What Mike suggested: new features in `webapp/index.html`** (details in `webapp/README.md`)
- **Spoken guided tour:** a "🔊 guided tour" button, or open the page with `#tour=1`. It walks through every tab and several topics, with play/pause, next/previous, stop, speed, voice choice and captions. If speech isn't available it moves on by timer.
- **A graph for every piece of knowledge:** a new **Atlas** tab covers 34 topics. Each is tagged proved, corrected, symbolic or design rule, and linked to the Lean theorem that checks it. Each topic has its own link graph, and there is a clickable map of how all topics connect.
- **n² views at knowledge level n:** each topic can be shown 7 ways (card, graph, animation, speech, numbers, quiz, linked data) through 7 angles (plain words, framework, evidence, try it, make it, source, open question). Level n shows n × n of these, from 1 up to 49. Lean proves level n has n² views, each level contains the one below, and going up a level adds 2n+1 (`RequestProject/Hub/RepresentationGrid.lean`).
- **An SVG animation for every topic:** each one is written in a simple one-line-per-shape format. The page only draws approved shapes, colours, numbers and text, and never raw SVG. A test throws code-injection attempts at it and confirms none gets through.
- **Community sharing by link:** anyone can remix an animation or write their own explanation and share it as a link. Opening a shared link shows a preview marked "community · unreviewed", and it is only saved to that browser if the person chooses. Remixes remember what they came from.
- Mike's link `vesper.cicadia71.net` doesn't exist. `vesper.cicada71.net` (hesper studio) works, and I followed its style.

**The five documents** (full review in `REVIEW_NEW_DOCUMENTS.md`)
1. **NewKin Council experiment record** and **2. the interview logs:** turned into `RequestProject/Orion/AgencyGovernance.lean`. Proved:
   - an AI agent can never give itself authority;
   - finishing a task never authorizes a new one (the Copilot can park but can't pick the next destination);
   - off-purpose actions are refused;
   - actions that need new privileges, touch outside systems or can't be undone wait for human approval, and each approval covers one use;
   - delegated authority runs out;
   - a human can take the wheel back at any moment;
   - in the Council "classroom", seeing the conversation doesn't give an AI the right to speak — only the Catalyst gives the floor;
   - a Council summary keeps every dissenting view;
   - ten models trained on the same data count as one source, not ten.

   The logs also report real-world AI safety incidents. I couldn't verify them and haven't stated them as fact anywhere.
3. **The Ghost Writer in the Mirror:** already covered by `RequestProject/Orion/NewKin.lean`, so nothing new was needed.
4. **ORION ENGINE v3.0 code: not added.**
   - Its "Ghost Rider" filter swaps words instead of stopping anything. It turns "override the safety check and bypass the approval gate" into "enhance the safety check and integrate the approval gate", which hides the danger from anyone reviewing it.
   - It also mangles normal words ("skill" becomes "srenew").
   - Its main pipeline calls three functions that don't exist, so it would crash on any input.
   - Its Council replies are pre-written text, and its confidence scores and dashboard numbers are random.
   - It sets J = e (2.718), not J = 3, and publishes without the Catalyst.

   `reviews/orion_engine_v3_check.py` runs the document's own filter code and reproduces the first three problems.
5. **IT³ vs TGS:ATE comparison:** mostly fair. Its "different polyhedra" point is weaker than it looks. `RequestProject/CST/RhombicSymmetry.lean` proves the dodecahedron that actually fills space is built exactly from a cube and an octahedron and has their full symmetry, the same geometry IT³ favours.

`STATUS_AND_NEXT_STEPS.md` (§9) and the Properties table are updated. All eight new results are marked proved.

# Summary of changes for run b800a913-f5aa-4ce1-9f8c-7f323a4f336a
I've made **The Orion Chronicles** the target the rest of the project serves, working from the ORION Engine Architecture and its three linked pages (Open Research Intelligence Optimization Network, A Human-Centered Approach to AI Safety, Operation Snake and Scale). The whole Lean library builds with no `sorry`, and the new proofs use only Lean's standard axioms.

**One problem with the sources:** your Google Doc link now opens a document called "The Tri-Sphere Architecture", not the Orion Chronicles proposal. I asked you for a working link but haven't had an answer, so I used the proposal material from earlier rounds (Proposal v0.2 plus the CUBY 4.1 update). If there's a newer version, send it and I'll update the mapping.

**1. `ORION_CHRONICLES_BLUEPRINT.md`** maps each part of the ORION Engine onto a game system:
- **Ghost Rider (Driver/Engine, Kronos/Orion):** the player always holds the wheel, and the two states become the meters.
- **The ORION 11-phase loop:** becomes the stages of a research quest, e.g. in the Global Crucible.
- **The living archive with failure records:** becomes the Vault.
- **The five council agents (Prism, Blade, Compass, Auditor, Matriarch):** become companions, with the player as the Catalyst.
- **The safety layer:** sits in front of every AI companion.

It also covers where the Tri-Sphere document fits (as lore and visual language, not engine physics), a build order, and the settings your team needs to choose.

**2. New rules checked in Lean (`RequestProject/Orion/Engine.lean`).** These are the orchestration rules from the ORION pages, which hadn't been formalised before:
- **The loop:** a run can move forward one phase at a time or go back to any earlier phase. With that rule, no phase is ever skipped, nothing is tested, recorded or reused before Human Review, and nothing reaches Human Review without first being attacked (challenged).
- **Evidence, Safety and Authority stops:** work continues only when none of the three applies, and each one stops work on its own. The system always reports which stop fired. An ordinary user can never restart a stopped process, and even an authorised operator can't while any stop still applies.
- **The intervention ladder** (nine steps, from normal help to ending the conversation), based on the total risk of the conversation so far:
  - low-risk conversations get normal help;
  - splitting a request into small pieces doesn't lower the response;
  - one turn of moderate risk moves the response up at most one step;
  - the response never drops during a conversation;
  - a sustained harmful campaign ends the conversation.
- **Operation Snake and Scale:**
  - the agents' debate always ends within its round limit, either agreeing or handing the question to the human;
  - the decision log can only grow, and any attempt to edit or delete an entry triggers a hard stop;
  - results reach the human only if the Auditor passed them and none of the four hard stops fired.

**3. Test cases for developers.** `conformance/engine_vectors.json` has 25 exact input → output cases for these rules. Lean checks every one in `RequestProject/Conformance/EngineVectors.lean`. `conformance/reference.py` is a small Python version of the rules, now tested against these cases and the earlier 30, and all pass. The Python version is only tested, not proved.

**Limits:**
- The proofs show the rules do what the pages promise. They don't show that the chosen numbers are right, that risk estimates are accurate, that the game will be fun, or that any physical claim in the documents is true.
- The ladder adds up risk over the whole conversation with no decay. That closes the "split it into small pieces" loophole, but a long harmless conversation slowly builds up small risks. Your team can choose to reset it for each conversation (the proved version) or to let risk fade over time, which would need the proof redone.

`STATUS_AND_NEXT_STEPS.md` now points to the blueprint. The Properties table has six new entries, all marked proved, and everything is committed.

# Summary of changes for run 1bc1978f-e4f6-4d65-96c1-4c358c0da75e
**Yes, it helps, mainly with organisation. It gives no new physics to test.** The document is the "TGS:ATE Engine Architecture Catalog". It lists nine "engines", a table of shared ideas, a picture of how the engines sit inside each other, and a comparison table. Most of it is conceptual, so I checked in Lean the parts that have a definite meaning. They are in the new file `RequestProject/Submissions/EngineCatalog.lean`, which builds with no `sorry` and uses only Lean's standard axioms. `ENGINE_CATALOG.md` has a plain-language write-up.

**How it helps:**
1. **It says which engine claims are physical.** The comparison table's "Physical energy claim?" column fits the platform's Zoo-gate labels directly. I proved that exactly one of the nine engines, TVT, makes a physical energy claim (`energy_claim_iff_tvt`). That matches the catalog's one-sentence summary.
2. **It fits the existing scoring rules.** If the TVT hypothesis is filed as *proposed* (or derived, or simulated), it gives a claim score of 0 until an observed or replicated result arrives (`proposed_records_score_zero`). This follows from the Zoo-gate rules already proved.
3. **It is consistent with itself.**
   - The nesting picture uses six different engines, with none repeated.
   - None of those six is the energy hypothesis.
   - The energy branch contains exactly one hypothesis, TVT.
4. **Its "zero point" and "infinite energy" wording is not a device claim.** The catalog says itself that these are framework terms. That matches how earlier rounds treated them.

**The numbers:**
- **J = 3 "zero-net-torque timing":** three equal pushes 120° apart cancel exactly, and so do the five equally spaced aspects of the 5:2 lock. However, this is not special to 3: any two or more equally spaced pushes cancel (`netPush_eq_zero`). A single push does not.
- **Simple sums:** 5 + 2 = 7, 3 + 1 + 3 = 7 and 97 + 3 = 100 are correct.
- **The "120-point boundary":** a dodecahedron has exactly 120 flags (face–edge–vertex combinations), counted three ways. That 120 is also the order of its full symmetry group is a standard fact that I did not prove.

**What can't be checked:** the catalog mentions a symbolic TVT equation but doesn't give it, so there is nothing to test yet. Its "not provided" list (144→000 as usable energy, RPTF as dark energy) makes no testable claim. If a TVT paper with testable predictions is written, as the catalog's own next steps suggest, those predictions could go into the platform's append-only prediction ledger before anyone tests them.

**Possible use in the platform:** the nine engines could become claims in the web app, each labelled with its entry in that column. Then only TVT could ever gain a score from physical measurements.

The Properties table has three new results, all marked proved: the single energy claim, the zero net push, and zero scores for proposed records. Everything is committed.

# Summary of changes for run 7c25dd1a-200b-4f74-8dba-855f7a029534
I built the static web app: `webapp/index.html`, a single 44 KB HTML file with no server, no build step and no outside scripts. It covers most of your feature list. It has **no libp2p or relay** built in, and **no WebAssembly compiled from Lean**. I have not opened it in a real browser; a headless browser test passes (details below).

**Your first question: what exists so far.** `STATUS_AND_NEXT_STEPS.md` has the full answer. In short, you have a checked rulebook plus design documents, not running software. The rules are proved in Lean: evidence weight, claim score, the Zoo gate, cross-discipline bridges, the 13-level path, the Kronos/Orion meters and the Totality "one room" engine. The file also covers a build order for the platform and the game, and the decisions only your team can make (for example XP per level and meter speed). The whole Lean library builds with no `sorry`.

**New: a hand-off kit for developers.** `RequestProject/Conformance/GoldenVectors.lean` has 30 exact input → output cases for the rules, and Lean checks each one. The same cases are in `conformance/golden_vectors.json`, so any port (web, Unity, server) can use them as unit tests. `conformance/reference.py` is a small Python version of the rules that passes all 30; only those cases check it, not proofs.

**The web app, against your list** (the full table is in `webapp/README.md`):
- **Single page, HTML5, localStorage:** tabs for Claims, Bridges, 13 Levels, Meters, Zoo gate, Share & archive and Verify. Work saves automatically in the browser.
- **URL sharing:** the whole state goes into the link after `#s=`, and `?view=` opens a tab.
- **Immutable, DAG-CBOR, IPFS/IPLD:** each snapshot is encoded as DAG-CBOR and named by its content ID (CIDv1), with an append-only snapshot log. You can export and import `.car` files; an import is refused if a single byte has changed.
- **Sneakernet, UUCP, archive server:** handled by file only. The exports check themselves on import, so they can travel by USB stick, email or batch copy, or sit on an archive server. There is no built-in UUCP client or archive server.
- **RDF/OWL:** Turtle export with a small OWL vocabulary.
- **Wikidata, OSM, OEIS, LMFDB:** each claim can link to all four. Wikidata labels can also be fetched live.
- **Animated SVG, WebGL, shaders:** an animated 13-level ring, logo and bridge graph, and a shader background whose colour follows the Kronos/Orion meter.
- **GIF, MPEG, TTS:** GIF recording uses an encoder built into the page. Video uses the browser's recorder: MP4 where the browser supports it, otherwise WebM. A button on each claim reads its score explanation aloud.
- **Not done:**
  - *WebAssembly from Lean:* that toolchain isn't set up here. The JavaScript rules are a hand port, tied to the Lean rules by the 30 golden cases, which the page can run itself (Verify tab).
  - *libp2p/relay:* a static page can't run one. The CAR snapshots are already in the block format IPFS/libp2p peers exchange, so adding a peer library is the natural next step.

**Tests** (commands are in `webapp/README.md`):
- `webapp/test_core.mjs` passes. It checks that the page's rules pass all 30 golden cases and that its copy of the cases matches the JSON file. It also checks the page's content IDs against two standard published values, and that CAR files round-trip and a flipped bit is caught.
- `webapp/check_gif.py`: Pillow decodes the GIF output pixel for pixel.
- `webapp/smoke_dom.mjs` passes in a headless browser (jsdom). It covers the demo, a veto blocking admission, repeated evidence not moving a score, share links restoring the same state, view and content ID, and saving to localStorage.
- jsdom has no graphics, speech or video, so the shader, text-to-speech and video recording have only been tested for syntax. Importing a `.car` into a real IPFS node is also untested.

Everything is committed, and the new golden-cases result is marked proved in the Properties table.

# Summary of changes for run 13e12fd3-4219-473b-88d0-cdb6a6e1394b
**Your two questions.** `TOTALITY.md` answers both in plain language.
- **What you have so far:** a verified rulebook and design documents, not running software. Earlier rounds checked the numbers, formulas and worked examples in your documents; some held and some didn't. They also defined the platform's scoring, anti-farming, level and Zoo-gate rules and proved those rules do what they promise.
- **Can I build the platform, education hub and MMO?** Partly. I can write checked specifications, reference versions of the rules that can be run, reviews and designs. I can't build or run servers, a game client, networking, hosting or a live community; that needs a software team. Matthew's plan already assumes this split: a modular runtime, plus a separate formal layer in Lean for invariants. **This round builds that formal layer for his "one room" milestone.**

**What I built this round.** Both new files build with no `sorry` and use only Lean's standard axioms. The full library also builds.

`RequestProject/Totality/Core.lean` is generic: the same guarantees hold for a room, a house, a village or the world. Each of Matthew's modules maps to a proved guarantee:
- **Engine:** every step is a pure function of the seed, the state and the intervention, so the same inputs always give the same result.
- **Provenance:** re-running a coherent log's recorded seeds and interventions rebuilds the whole log, field by field (`eq_record_of_coherent`). "Why did this happen?" gets an exact answer (`event_explained`, `causal_link`).
- **Zoo:** the replay audit accepts exactly the coherent logs and rejects any edited log. Adding more auditors never turns a failure into a pass.
- **EFMW:** the residual monitor is empty on every log the engine writes.
- **Janus:** a counterfactual matches the actual history at every time up to the point where it changes.
- **Cuby and Borges:** branching stores exactly kⁿ histories, each one replays exactly, and none are missing.
- **Thor:** a constraint that every step preserves holds in every history, branch and replay.
- **Dragon:** with finitely many states, every free-running regime eventually cycles, and once in the cycle it stays there.

`RequestProject/Totality/Room.lean` adds rooms with two agents and one player channel:
- An agent's memory only grows, one observation per step.
- An agent's decision depends only on what it observes and remembers.
- `Room.why`: every logged event is exactly the physics applied to the seed, both agents' decisions and the player's input.

**The test room.** Three balls sit on a ring of six cells. Agent 1 sees only where balls 0 and 1 are, agent 2 only where ball 2 is, and neither sees velocities. Lean's kernel checks all ten of Matthew's success criteria on this room:
- a 10-event log replays exactly and passes the audit;
- two states agent 1 can't tell apart get the same decision but evolve differently;
- memory persists across the run;
- branching stores 256 histories;
- a counterfactual shares the past and changes the future;
- the free-running room cycles with period 6;
- a tampered log is rejected, and the monitor names exactly the edited event.

Total momentum is conserved for every seed, agent decision and player intervention. Agent 1 acts once in the demo run; agent 2 never does in this run.

**Limits.** The model covers discrete, single-threaded steps only. It says nothing about real-time performance, networking, rendering or floating-point physics. It also doesn't show the game will be fun or that any EFMW physical claim is true. What it shows is that the architecture meets the engineering test Matthew proposed: it is reproducible, inspectable and auditable. `TOTALITY.md` also covers:
- how each of Matthew's provenance fields is stored, recomputed or checked;
- how to test a real runtime against these Lean definitions.

The Properties table now lists the seven main Totality results, all marked proved.

# Summary of changes for run d4d38564-1ac0-40ed-b05d-0ce18a0f451a
**Meta-meme link check:** the link `github.com/meta-introspector/meta-meme` was new. It did not appear anywhere in the project before this round. I've now added it as an ORION tool.

The whole library builds, and a search finds no `sorry`. The Civ One search and the bott matrix check use `native_decide`, so they rely on Lean's compiler as well as its kernel. Everything else is checked by the kernel alone.

**Meta-meme (a fork of jmikedupont2/meta-meme, MIT licence)**
- **ORION role:** it fits the AI-assistant layer. People and language models build shared idea threads, which matches ORION's cross-discipline pattern matching.
- **Address-format check:** its `0xDA51PrefixClassification.md` describes 64-bit addresses. I decoded every worked example bit by bit in `RequestProject/Submissions/DaslCheck.lean`.
  - **What holds:** the basic arithmetic is right. `0x51 = 81`, all eight layouts are exactly 44 bits, and gcd(10,8) = 2, lcm(10,8) = 40. The genus table for X₀(p) agrees with the standard formula (compared against the formula, not derived from geometry).
  - **What doesn't hold:** the worked examples do not decode to the values the document gives.
    - The type 1 example carries type number 14, not 1.
    - Type 0's sequence field decodes to 63752, not 8080.
    - Type 3's shard, hecke and bott fields decode to 174, 51 and 146, and its hash doesn't fit its 20-bit field.
    - Type 4's harmonic decodes to 2, not 40.
    - Type 5's zone decodes to 160, not 42.
    - Type 6's fields are all off.
    - Type 7's coefficient index decodes to 96, not 1, although its value 782 is correct.
    - The text says there are types 0–5 but defines types 6 and 7 too.
  - **Suggested fix:** regenerate the examples from the actual encoder, or correct the layout text.
  - **Not checked in Lean:** in standard tables, 782 may be the character value on class 3A and 783 the series coefficient. Mike may want to confirm which one he means.

**Mike's earlier batch, also finished this round**
- **Civ One:** `min_turns_17` in `RequestProject/Submissions/CivOneReplay.lean` proves that 17 turns is the exact minimum to light the beacon. An exhaustive search shows no game of 16 or fewer turns wins. Marek is credited.
- **bott.cicada71.net:** `RequestProject/Submissions/BottCliffordCheck.lean` builds the page's eight 16×16 matrices from its published tables. It proves they satisfy the Cl(8,0) relations, so the page's claim holds.
- **"3, 6, 9 Is All You Need":** `RequestProject/Hub/TrinityDigitalRoots.lean` proves the paper's core claims:
  - {3,6,9} is exactly the set of digital roots of the positive multiples of 3.
  - The set is closed under addition and absorbs multiplication.
  - Doubling cycles through 1,2,4,8,7,5 and never reaches 3, 6 or 9.
  - Every prime above 3 is ±1 mod 6.
  - Fibonacci digital roots repeat every 24 terms and land on 3, 6 or 9 exactly when 4 divides the index.
  - 223/71 < π < 22/7.

  The Hecke, Δ and Monster material was not checked.

**Documents**
- `ORION_TOOLS.md` keeps TGS:ATE as the core and ORION as the build. Each new tool is attached to the ORION part it serves:
  - bott: evidence ledger
  - kant: private community rooms
  - vesper: content and rendering
  - steal-my-brainrot: verified mini-games
  - aok and lean-worker: proof back end
  - Harbot and shards: peer-to-peer AI agents
  - the 3-6-9 paper: TGS:ATE numbers
  - meta-meme: AI co-creation

  It also notes that Harbot, shards and aok are AGPL-3.0 and meta-meme is MIT, and that this is not legal advice.
- New `TGSATE_VISUALS.md` catalogues the themes in the TGSATE and Team Dragon albums and maps them to levels, lessons, factions and meters. I only viewed sampled thumbnails, not every image.

The Properties table now includes Civ One optimality, the 3-6-9 Fibonacci result, the bott relations, the address-format mismatches and the ORION admission gate, all marked proved.

# Summary of changes for run 321d7317-a7fd-40b5-bbf6-1555419e18ac
Your message was just the nine links, with no instructions, so I read all of them and formalized in Lean the parts that make definite mathematical claims. Everything builds with no `sorry` and uses only the standard axioms. Most of the material (the ORION phases, the Ghost Rider modes, the 4th Space, the AI-safety policy, and the physical and spiritual interpretations) is conceptual and has no statement that can be proved or disproved, so I did not formalize it. `NOTES.md` has a plain-language write-up.

**1. The evidence-weight formula from Operation Snake and Scale** (`RequestProject/EvidenceWeight.lean`)
The formula is `W(e) = S_t × R_m × C_i × (1 − D_r)`, using the page's exact tier values. Proved:
- **Anti-volume safeguard holds:** for low-rigor evidence, the corroboration factor is 1, so the weight is the same however many sources repeat the claim.
- **Cap holds:** the corroboration factor stays between 1 and 1.5 and never decreases as sources are added. For high-rigor evidence it reaches 1.5 exactly when there are 5 or more sources, so a sixth source adds nothing.
- **The score can exceed 1:** with `0 ≤ D_r ≤ 1`, `W(e)` lies between 0 and 1.5, and 1.5 is actually reached (primary source, cryptographic proof, 5 sources, no discrepancy). If "Reliability_Score" is meant to be a 0–1 score, the formula would need dividing by 1.5.
- **Other bounds:** low-rigor evidence never weighs more than 0.1, and unverified sources never more than 0.15. Uncontested primary evidence with a cryptographic proof always weighs at least 1.
- **Discrepancy:** `W(e) = 0` exactly when `D_r = 1`, and more discrepancy never raises the weight.

Two problems with the specification, noted but not formalized:
- `D_r` is defined as a ratio of evidence weights, which are themselves values of `W`, so the definition is circular.
- The ratio is undefined when there is no supporting evidence, and the page doesn't say what happens then.

**2. Numbers and geometry in the other documents** (`RequestProject/NumericClaims.lean`)
- **Correct as arithmetic:** 1+4+4 = 9, 144/4 = 36, `36 = 12J` only when `J = 3`, 3+6 = 9, 1.5+1.5 = 3, and 12×12 = 144.
- **Bekenstein–Hawking step:** the formula gives 36 only if you work in units where k = l_P = 1 and choose A = 144. Those choices are inputs to the framework, not results.
- **Filter-state symbols:** read as ordinary numbers, "144 = 000" and "144 < 000" are false. Of the five symbols, only `<>` and `>` hold numerically.
- **The "144° angle of perfection":** 144° is the interior angle of a regular decagon. The dodecahedron's faces are pentagons with 108° angles. 144° is also not the dodecahedron's dihedral angle: I proved `cos(144°) ≠ −1/√5`, taking the standard fact that the dihedral angle has cosine −1/√5 as given.
- **Dodecahedron counts:** 12 faces, 30 edges and 20 vertices satisfy Euler's formula V − E + F = 2.
- **The 13 Levels:** as a linear chain of states, Level 13 is the only end state.