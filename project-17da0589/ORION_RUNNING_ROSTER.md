# ORION running roster and build status board

**[R10] Opening pass (ORION R10 🍝🧠, page version 128, 2026-10-04):** corrections and new language-display proposal in `ROUND_TEN_REPLY.md`; ongoing review list in `PRE_PUBLICATION_REVIEW.md`. Greedy scoring formerly assumed in R9d is **not** the author's Greedy and must not be quoted as its rules. The new image and text are in `orion/r10/`. The Round 10 page remains open.


**Round 10 opening update, 2026-10-04, above. The prior status was Round 9, fifth pass (ORION R9💎, version 826).** Changes from the fifth pass are marked
**[R9e]** (reply: `ROUND_NINE_FIFTH_PASS.md`); the page title now ends in 💎, read as R9 closing. Changes from the fourth pass are marked
**[R9d]** (reply: `ROUND_NINE_FOURTH_PASS.md`). Changes from the third pass are marked
**[R9c]** (reply: `ROUND_NINE_THIRD_PASS.md`). Changes from the second pass are marked
**[R9b]** (reply: `ROUND_NINE_SECOND_PASS.md`). I update this file every round. Changes from the opening
pass are marked **[R9]** (reply: `ROUND_NINE_REPLY.md`; walkthrough: `ORION_FUNCTIONAL_WALKTHROUGH.md`). Round 8 is closed ("close Orion 8🥳"). From the second Round 8
pass, **[R8b]** (reply: `ROUND_EIGHT_SECOND_PASS.md`); from the opening Round 8 pass, **[R8]** (reply: `ROUND_EIGHT_REPLY.md`; gameplay summary: `GAMEPLAY_MECHANICS_SUMMARY.md`). Round 7
is closed. Earlier changes: **[R7d]** (reply: `ROUND_SEVEN_FOURTH_PASS.md`), from the third pass **[R7c]**, from the second Round 7 pass **[R7b]**, and from the first **[R7]**. The new
`ORION_MASTER_INDEX.md` lists names, a glossary, and where every page, reply, proof and package is.
Proved rules live in `RequestProject/Round*/` and every file builds with no `sorry`. "Proved" means the stated rule has
the stated consequence. It does not mean the game code implements it.

## 1. Who's on the build (from the pages so far)

| Person | Role on ORION (as seen on the pages) | Current items |
|---|---|---|
| A. Beth Jones (TGSATE) | Designer and project lead; rulings, lore, names | Rulings in every round; the questions in §7. **[R7d]** Sole active game designer (per the shared chat); other contributors build in the background through their own councils |
| Ryan (Weaver Nexus Systems) | Security, CI, formal kernels, Weaver tooling, lore-continuity tooling | **[R9c]** Choir Architecture v1.2, Bounded Receipt Runner v0.1, WN-E3 protocol candidate and IntrospectionTwin v0.2 all checked (§2); WN-E3 validator fix to pass on (`orion/r9c/wn-e3-validator-fix.patch`). **[R9]** Weaver Consolidated Core v0.5 rehearsal evidence checked: signature valid, all hashes match (§2). Note for him written as approved (`orion/r9/NOTE_FOR_RYAN.md`). **[R8b]** Weaver Consolidated Core v0.3, POSM v0.4, Artemis/VPH v0.1 checked; Loom re-attached (§2). POSM fix patch and an Artemis README correction to pass on (§4). **[R7b]** Weaver Integration Demonstrator v0.1 and Loom/Mythos Continuity Kernel v0.2.0 (both checked, §2); patches from R5/R6 waiting for him to apply |
| Matthew Chenoweth Wright (Monolithic / EFMW) | Monolithic Zoo, Proofs Arena | Three Zoo checks from R6 still open; **[R7b]** the SoB page's 43/46/47/50 glossary depends on them |
| Mike Dupont (introspector) | Engine foundation, lean-workers-union | **[R9c]** Posted X links, `lean-workers-union` and open PRs kant-zk-pastebin #10, aristotle-cli-rs #7, lean-worker #8 (recorded, not reviewed); emoji-to-wasm compiler mentioned, no link. **[R7b]** "Remove all leveling code" task: the hold is lifted. **[R7c]** The one levelled thing is now the **skill orb** (0–100, gold-lock at 100); player level is still the count of gold-locked nodes |
| **[R8b]** Marek (Civilisation.One) | Civilisation.One platform (site, CivScore, MirrorME, MKONE) | Posted a 284-component, 23-domain register on R8 Live; checked (§2). How it relates to ORION is Q11. **[R9]** Not on the build right now, but many DEV ideas came from interacting with him. **Contributor lineage:** anything that aligns with his work is credited to him, active or not, and the R9 rule protects inactive creators' work |
| Wider X roster | See `TEAM_ROSTER_AND_X_REVIEW.md` | No change |

## 2. Fixed / checked

| Item | Status | Where |
|---|---|---|
| **[R10]** Language-display *proposal* | Separate canonical safety text from skill-gated ordinary-word display; formal model proves safety unchanged and clarity monotonic with skill. Not an implementation of the Python engine. Exact language scale, vocabulary and chat policy await decisions | `RequestProject/RoundTen/OpeningTen.lean`, `ROUND_TEN_REPLY.md` |
| **[R10]** Pre-publication watch list | Personal-history attachment, children’s images/identifiers, demo signing key, mockup wording, engine semantic rewrite and missing Greedy rules | `PRE_PUBLICATION_REVIEW.md` |
| **[R9]** Weaver Consolidated Core v0.5 rehearsal evidence | Outer hash, 10/10 log hashes, environment and receipt digests, Ed25519 signature (rejects a wrong challenge or subject), rebuilt = frozen v0.4. Headline 125/83/26 is the v0.5 baseline; the reproduction run was of v0.4 (108/67/22). The v0.4 and v0.5 ZIPs aren't attached, so the evidence was checked, not the code | `orion/r9/weaver-v0.5-rehearsal-checks.log` |
| **[R9]** Loom archive adopted | Seed v1: 24 rulings, verifies (25 events); the deliberate stale-2% test is still rejected | `orion/r9/loom_seed_v1.*` |
| **[R9e]** R9e rulings proved | Sales split 90/3/7 (never over the sale, with or without the 3% tax; more weight never paid less), child-safety rooms (join-only checks fail when a guardian leaves; close-the-bubble rule keeps every room safe; no adult alone with a child), 50% outside vote weight (can override; engaged-majority lock never does), parental caps, biometric firewall per graduation, damaged-structure 50% DEVPOOL split | `RequestProject/RoundNine/FifthPassNine.lean` |
| **[R9e]** Link archive | Every shared link kept (88 through Round 10; 86 through R9e); six Notion pages no longer open without access | `ORION_LINK_ARCHIVE.md`, `review/make_link_archive.py` |
| **[R9d]** R9d illustrative mathematics (**not the actual Greedy; corrected R10**) | Under the abandoned common-Greed assumption: bust iff no score; 1,440 of 46,656 rolls bust; banked points never drop. Actual Greedy rulebook is still needed. Betting pools with the 3% tax (never pay out more than came in; bigger stake never paid less), Rat Slap (cards conserved), 13-Level Gauntlet mockup numbers | `RequestProject/RoundNine/FourthPassNine.lean` |
| **[R9d]** Beth's uploads checked | Orion engine v5.4 + dashboard v5.7 run (filter and rind problems, fix patch); Ghostwriter-Mirror tests run (2/2 fail); Languanauts vocabulary docs, Bus 58 handout, Inkheart, Labyrinth script, EQ2MAP installer recorded; "Why Wait" poem not found in any upload | `orion/r9d/*-checks.log`, `orion/r9d/orion-engine-v5.4-fixes.patch` |
| **[R9c]** Ryan's four packages | Choir v1.2: 154/154 tests, simulations reproduce README numbers. Bounded Receipt Runner v0.1: 26/26 checksums, 7/7 tests, fresh sign/verify/tamper run. WN-E3 protocol: 14/14 checksums, 7/7 tests, signed end-to-end run; one gap (mismatched digest + integrity PASS accepted), fix patch. IntrospectionTwin v0.2: builds on v4.22.0, hostile suite passes, **kernel replay PASS** with lean4checker built here | `orion/r9c/*-checks.log`, `orion/r9c/wn-e3-validator-fix.patch` |
| **[R9c]** R9c spaghetti proved | Idea pipeline (forwarded iff new, never twice, first submitter keeps credit), dragon solar boxes (one nearest star; domains disjoint), ad bubbles / honorable mentions | `RequestProject/RoundNine/ThirdPassNine.lean` |
| **[R9b]** R9b rulings proved | Who controls a design v2 (direct edit / DEV adoption / mutation), orbs v4 (node slots, gold-only matrix, marksman rewards), KRION per slot, 3 : 1.75 stacking vs phoenix, skyboxes v3 (guest tiers). RD pool option A adopted | `RequestProject/RoundNine/SecondPassNine.lean` |
| **[R9b]** Meta Concept Art Round 2 | Couldn't open (Meta AI share pages need the app or sign-in); ideas not yet run through | Paste the ideas as text or screenshots on the page |
| **[R9]** R9 rulings proved | Work-protection rule (creator / DEV team / council / human), diamond lock, orbs v3, chosen elemental path, skybox access v2, RD pool options A–C, phoenix vs stacking | `RequestProject/RoundNine/OpeningNine.lean` |
| **[R9]** Pages re-read | R8 page now holds your answers and "close Orion 8"; ToC X-Summary, ORION (Summary), SoB R6, ORION R7💎 unchanged | `orion/r9/R8_ANSWERS_TRANSCRIPT.md`, `orion/r9/PAGE_TRANSCRIPT.md` |
| **[R8b]** Weaver Consolidated Core v0.3 | 89/89 tests, bundle check 52 files / no failures, 16/16 mutations killed | `orion/r8b/packages-checks.log` |
| **[R8b]** POSM v0.4 | Python witness, 6/6 tests, 16/16 checksums. Lean builds and every theorem is proved **after three fixes** (§4); stronger "no real budget" result added | `orion/r8b/posm-v0.4-fixes.patch`; `RoundEight/POSMv04Check.lean` |
| **[R8b]** Artemis/VPH v0.1 | 14/14 tests, 7/7 checksums; mesh game proved: exact potential, always settles, every resting point is a consensus, which consensuses rest | `RoundEight/SecondPassEight.lean`; `ROUND_EIGHT_SECOND_PASS.md` §1.3 |
| **[R8b]** Loom kernel re-attached | Same SHA-256 as R7; draft seed of 16 locked rulings loads, a stale 2% tax fact is rejected (draft only, Q8) | `orion/r8b/loom_seed_draft.*` |
| **[R8b]** Marek's register | 23 domains, 284 entries as stated; 283 distinct names ("Civilisation.One Academy" twice) | `RoundEight/SecondPassEight.lean` |
| **[R8b]** Pages re-read | ToC X-Summary, ORION (Summary), SoB R6, ORION R7 💎 unchanged; no answers yet under the pasted R8 reply | `orion/r8b/PAGE_TRANSCRIPT.md` |
| **[R8]** Skill orbs corrected | No cap on gold-locked orbs; orbs alone stop at level 64; level 65 (dragon rider) only by safe-zone meditation with the 64-orb grid; riders keep 64; surplus exchange at 50% rounded up. Replaces R7c "level ≤ 64" | `RoundEight/OpeningEight.lean` |
| **[R8]** Phoenix taper | 1 + (5 − k)/40: 110% → 100%, never below an ordinary dragon; equals the R7c focus cost at d = 1/44 | same |
| **[R8]** Ordinary dragons stack elements | Prefix of a fixed order, monotone in skill; phoenix stronger per element whenever stacking costs anything | same |
| **[R8]** Tax locked at 3% | Tax-free below 34 coins; 3% table checked | same |
| **[R8]** Skybox kinds | Open / level-specific / quest-or-key gate; crafting never opens a gated one | same |
| **[R8]** Never stuck | Exact quest search; generator always yields a new completable quest; interaction alone meets any requirement | same |
| **[R8]** Story gate v2 | Any genre; real stories need a source; reworks re-pass; every genre consistent | same |
| **[R8]** Loop order | Engine → socials → MMO → education → projects → ancestral tree → engine; six-step loop; any layer reaches all | same |
| **[R8]** Crafted skins | Look cosmetic; bioengineered enhancement is a separate input | same |
| **[R8]** Pages re-read | ToC X-Summary, ORION (Summary), SoB R6 unchanged; R7 page gained the Chronicles link; R7 closed | `orion/r8/` |
| **[R7d]** ToC X-Summary page vs earlier rulings | Meditation, aggro, fair quests, epic-quest locks, skybox gate and species all match what was proved before (one small skybox wording difference, §4) | `ROUND_SEVEN_FOURTH_PASS.md` §2 |
| **[R7d]** Skin is cosmetic | Proved: an ability formula ignores skin exactly when it uses only species, body, archetype and traits | `RoundSeven/FourthPassSeven.lean` |
| **[R7d]** "No one is ever truly stuck" | Proved **if** infinitely many beginner-completable quests exist (player/dev-created content); false with a fixed finite list | same |
| **[R7d]** R7 attachments, SoB R6, ORION (Summary), gallery | Re-checked; unchanged (gallery still 49 images) | `orion/r7d/` |
| **[R7c]** Skill orbs and dragon porting | Settled by your note and proved: orbs level to 100; gold-lock at 100; only gold-locked orbs port; exactly 100 level-ups from 0; level = gold-locked count (≤ 64) | `RoundSeven/ThirdPassSeven.lean`; `ROUND_SEVEN_THIRD_PASS.md` §1 |
| **[R7c]** Tax at 2% / 3% / 5% | Proved for every whole-number rate: from-total ≥ per-contribution, gap < 1 coin per contribution; tax-free lines 50 / 34 / 20 coins | same, §3 |
| **[R7c]** Names | ORION's Gate = community projects page; Elder's Garden = placeholder title for the ORION Engine landing page. All names settled | same, §4 |
| **[R7c]** SoB page retitled | Now "ORION SoB R6"; text unchanged | `orion/r7c/SOB_R6_TRANSCRIPT.md` |
| **[R7c]** Master Index | Started, as you okayed | `ORION_MASTER_INDEX.md` |
| **[R7c]** R7 Live attachments | Same three ZIPs as before; re-checked | `orion/r7c/attachments-recheck.log` |
| **[R7b]** Weaver Integration Demonstrator v0.1 | 12/12 checksums, 12/12 tests; demo output byte-identical to the shipped examples; accept rule modelled and proved (denials preserve state, PASS iff all conditions, no double pass) | `orion/r7b/new-packages-checks.log`; `RoundSeven/FollowUpSeven.lean` |
| **[R7b]** Loom/Mythos Continuity Kernel v0.2.0 | 22/22 manifest hashes, 64/64 tests, 10/10 mutation probes; conflicting fact rejected and archive unchanged; contract check proved exact (accepts iff satisfiable) | same |
| **[R7b]** Phoenix rule | Clarified and proved: same skill cap and same non-elemental power as every dragon; ≥10% ahead in elemental only. **[R7c]** The elemental edge is now in question: see the focus-cost proposal in §3 | `RoundSeven/FollowUpSeven.lean` |
| **[R7b]** "Notes" → "nodes" | Lean text corrected; level = character nodes unlocked (Round 3 meaning) | `RoundSeven/RulingsSeven.lean` |
| **[R7]** Weaver Agent Security Pilot v0.2 | ZIP intact, 23/23 checksums match, 22/22 tests and 14/14 demo checks pass, shipped results match a fresh run | `orion/r7/weaver-agent-security-pilot-v0.2-checks.log` |
| Agent Audit Gateway v0.3 | 47/47 tests pass with `jsonschema` installed (R5). Ryan's v0.2 notes still say "unresolved"; **[R7b]** the SoB page repeats this | `orion/r5/agent_audit_gateway_run_checks.log` |
| lean-workers-union v0.3 / v0.7 | Fix patches build with no `sorry` | `orion/r5/…v0.3-fixes.patch`, `orion/r6/…v0.7-fixes.patch` |
| proofs-arena dragon kernel v0.1–v0.3 | Fix patch makes all three build | `orion/r6/proofs-arena-dragon-kernel-fixes.patch` |
| portfolio CI live-application v1 | `make_patch` bug fixed; 15/15 patches apply | `orion/r6/…make_patch-fix.patch` |
| ci-hardening-patches tarball | 11/11 apply; action pins match their releases | `ROUND_SIX_REPLY.md` §4 |
| Council: three strikes + 7-day cool-off | Proved (R6); confirmed (R7); the first round's no is **not** a strike | `RoundSix/RulingsSix.lean` |
| **[R7]** Sale tax, admin split, locked names | Proved, and you confirmed them (👍💎) | `RoundSeven/RulingsSeven.lean` |
| **[R7]** Arena 2% from the total | Proved; **[R7b]** explained plainly with numbers. Your rule is the better one, so nothing to decide | `ROUND_SEVEN_FOLLOW_UP.md` §3 |

## 3. Superseded: needs your permission to commit

| What would change | Old rule | New proposal | Status |
|---|---|---|---|
| ~~Levels return~~ | — | — | **[R7b] Withdrawn.** It was "nodes", which is the Round 3 meaning of level, so nothing is superseded |
| **Skill cap** | 144 (Round 3 §6, Black Hole Orb) | 100 (your R7 note) | **[R7c] Settled by your ruling:** orbs cap at 100; 144 is the dragon-matrix node count |
| **[R7c] Phoenix strength** | R5: phoenix ≥ 10% above every other dragon and player (R7b: elemental only) | ~~Focus cost d = 5%~~ | **[R8] Settled by your ruling:** taper 110% → 100% (d = 1/44); the 5% proposal is withdrawn |
| **[R8] One element at a time for ordinary dragons** | R4 D4: no other dragon ever has two elements active | Ordinary dragons stack elements by skill, in a fixed order | **Superseded by your R8 ruling**; details Q3 |
| **[R8] Player level ≤ 64** | R7c: level = gold-locked count, never above 64 | No cap on orbs; level 65 by meditation | **Superseded by your R8 ruling** |
| **[R7c] Tax rate** | 2% (R7) | 3% | **[R8] Settled: 3% across all taxable incomes**; scope Q4 |
| **[R7] Royalty model** | R6: arenas tax 2% of a reset user's royalty share | 2% sale tax; anonymous items' 2% goes to the admin arena pool | Applied; confirmed 👍💎 |
| **[R7d] Elder's Garden story gate** | — | Stories declared real or lore; each checked for consistency within its genre before publishing (proved consistent; consistency ≠ truth) | **[R8] Adopted in substance** with your additions (any genre, sources for real stories, reworks re-pass); version 2 proved |
| **[R7d] POLY name** | — | POLY = Path of the Living Ylem | **[R8] 💎-locked** (your 🪩💎🐋💎🪩) |
| **[R8] Elder's Garden / ORION's Gate** | R7c: EG = landing page; Gate = projects page | Gate = landing page leading into EG = ancestral tree and celebration capstone | Recorded; whether the Gate is also the projects page is Q6 |
| **[R7b] Elder's Garden** | R5/R6 "bedrock" project page; R7 withdrawn | **Placeholder title** for a landing page explaining the whole engine; not locked | **[R7c] Settled:** EG = ORION Engine landing page (placeholder); ORION's Gate = community projects page |

## 4. Broke / doesn't match its own description

| Item | Problem | Fix |
|---|---|---|
| **[R9d]** Orion engine v5.4 Ghost Rider filter | Replaces letters inside words: "skill" → "srenew", "harmony" → "healony" (proved) | Whole-word matching, in `orion/r9d/orion-engine-v5.4-fixes.patch` |
| **[R9d]** Orion engine v5.4 rind step | "cannot" → "can", "protect" → "open": reverses safety rules; a rule and its opposite become the same text (proved) | Leave negations and protective words alone (same patch) |
| **[R9d]** Dashboard v5.7 | Looks for the engine in `dashboard/core` (doesn't exist) so it always shows the demo engine's fixed numbers; would call the real engine with the wrong number of inputs | Same patch; dialogue panel still needs `narrative_speeches` → `roundtable_dialogue` |
| **[R9d]** `launch_final.sh`, README, SQL schema | Launch script writes a placeholder and ends mid-line; README cut off; 23 inline `INDEX` lines are MySQL syntax, not PostgreSQL | Author to finish; move indexes to `CREATE INDEX` |
| **[R9d]** Ghostwriter-Mirror | Both governor tests fail; safety level resets ≥140 to 0 (not monotone, proved); several files missing | Author to finish |
| **[R9d]** 13-Level Gauntlet mockup | "Active council 7/13" vs "Quorum 9/13 reached" conflict (proved); "LVL 6 · TRIAL" twice; "DEBIFYING" typo | Fix the mockup |
| **[R9]** ORION's Gate mockup | Elder's Garden card says "cultivation & research hub", but R8 ruled it the ancestral tree / celebration capstone. Placeholder numbers ("© 4027", "v3.1.9") | Fix the card text (P1) |
| **[R8b]** POSM v0.4 (as shipped) | `lake build` fails on its own pinned toolchain: a "no goals" error (`Composition.lean:165`), an unproved case (`Counterexample.lean:26`), and no `main` in `Main.lean`. Its `BUILD_STATUS.md` says Lean was not run | `orion/r8b/posm-v0.4-fixes.patch` (then regenerate `SHA256SUMS.txt`) |
| **[R8b]** Artemis README | Says "a fixed point need not be consensus"; for this mesh game every fixed point is a consensus (proved) | Suggested wording in `ROUND_EIGHT_SECOND_PASS.md` §1.3 |
| **[R8b]** Marek's register | "Civilisation.One Academy" listed in both Domain 13 and Domain 23; annexes mentioned but not on the page | Qualify one entry; attach the annexes |
| **[R7b]** Weaver Integration Demonstrator verifier | Some malformed ledgers crash with `TypeError` / `AttributeError` instead of a clean rejection (still refused) | Check types before use (`ROUND_SEVEN_FOLLOW_UP.md` §7) |
| **[R7b]** Weaver Integration Demonstrator | Time may go backwards; denied command IDs can be reused; "PASS" vs "VERIFIED" wording | Monotonic time check; document the ID rule; one word |
| **[R7b]** Loom preview | `conflicts --fact-payload` exits 0 even when it reports VIOLATED | Nonzero exit code or a `--strict` flag |
| **[R7b]** ORION SoB 100326 page | Several items are out of date (R1 label, rounding, phoenix, council, gateway retest, naming) | Corrections table in `ROUND_SEVEN_FOLLOW_UP.md` §6.1. **[R7c]** Retitled "ORION SoB R6" ✔; R7 Live's link label still says "SoB 100326" (optional fix) |
| **[R7d]** ToC X-Summary skybox line | Reads as three routes (quest, escape feature, key); Round 3 has two (escape earned through the quest, or a key) | Reword to match, or rule on a third route |
| **[R7d]** Battle-scene title image | Faint second logo above "THE ORION CHRONICLES" (my reading of the image) | Remove before using as a title card, if unintended |
| **[R7c]** R7 Live top links | "The ORION Engine" opens the ORION (Summary) page; "The Orion Chronicles Summary" has no link or content yet | Add the Chronicles summary page/link when ready |
| **[R7]** Weaver pilot demo labels | `tail deletion detected` / `full rewrite detected` show `false`, even though tampering *was* caught | Rename the cases or invert the value |
| **[R7]** ORION (Summary) page | Lists Elder's Garden as a platform; leaves out ORION's Gate | **[R7c]** Names now settled: list ORION's Gate as the community projects page, EG as the landing-page placeholder. **[R7d]** Still unchanged, and a shared chat repeated the old meaning back, so the stale page is spreading |
| Ryan's lean-workers-union and dragon kernel (as shipped) | Don't build until the patches are applied | Patches in §2 |

## 5. Holes still open, by area

**Gameplay / progression**
- **[R7d]** ToC X-Summary leaves out skill orbs, level (gold-locked nodes), the 144-node dragon matrix, the KRION challenge, the
  phoenix and the economy. Suggest a "Progression at a glance" section once Q1–Q3 are answered.
- **[R7d]** "Endless opportunities" needs an ever-growing quest supply (proved); say so on the page.
- ~~Skill cap 100 vs 144~~ **[R7c]** settled (100; 144 = matrix nodes).
- **[R7c]** Full dragon matrix: does a new orb replace one? Do the 64 character orbs fill 64 of the 144? When does the
  auto-adjust start? Is the KRION challenge per orb or per matrix? (Q1–Q3)
- **[R7c]** Phoenix focus cost (Q4) and whether ordinary dragons may run two elements (Q5).
- **[R7]** Cross-skill strength: a low-skill phoenix loses to a high-skill dragon (proved). **[R7b]** This matches your
  clarification that the phoenix isn't better overall.
- How far ahead a guided lesson may reach (the SoB page asks this too).
- Quest-orb sequence (A3), AFK loot (A6), group loot scaling (A7), deconstruction cap (A8): see `FOLLOW_UPS.md` §5A.
- Gallery: uneven orb wattage steps; two sets of stage names.

**Economy**
- **[R7b]** RD pool: meaning of "10 times the reward", "subdivided 2%", the overflow rule, "Dove team" (Q2–Q5). Your exact words
  are quoted in `ROUND_SEVEN_FOLLOW_UP.md` §4.
- **[R7]** Who receives the 2% arena skim; leftover coins from the even admin split; DEV characters selling into the player
  economy; whether the sale tax is added on top or taken out.
- 2% of amounts under 50 coins rounds to 0 (A5). **[R7c]** At 3% the line is 34 coins, at 5% it's 20; rate choice is Q6.
- Ryan's conformance vectors still round the other way from your Round 4 D1 ruling.

**Governance / names**
- **[R7d]** Elder's Garden: landing page, ancestral tree / Raspberry Fields, or both (Q10). POLY lock (Q8).
- **[R7d]** The "13-level council gauntlet" isn't written down on any ORION page yet (Q13).
- **[R7d]** Default path: social → MMO → education → projects (your chat) vs social → education → MMO → projects (Summary
  page) (Q12).
- ~~What ORION's Gate is~~ **[R7c]** settled: community projects page.
- Where approved name changes are logged, and who approves a change you propose yourself.

**Lore**
- **[R7d]** The chats map Council ideas (Ghost Rider, Layer A/B/C/D, 144 = 000) onto game features. Those links are the chat's
  own reading and aren't in the glossary unless you adopt them (Q14).
- Kronos / Orion / KRION with HIVE / PULSE / SHEPHARD; SHEPHARD vs SHEPHERD (Matthew).
- **[R7b]** A glossary for the 43 / 46 / 47 / 50 counts (SoB page 9.2), waiting on Matthew's three Zoo checks.
- **[R7b]** The Chronicles page is still empty.

**Platforms / organisation**
- **[R7c]** ORION Master Index started (`ORION_MASTER_INDEX.md`). Still missing: the Zoo-count and HIVE/PULSE/SHEPHARD glossary
  entries, and dated archive copies of external sources.
- **[R7b]** No package has an institutionally independent reproduction yet.
- Safety and privacy items C1–C11 and the counsel items in `FOLLOW_UPS.md` §5C/§5E are unchanged. The SoB page also flags the
  admin-access rule for legal review.

## 6. Ideas for navigation and gameplay (suggestions, not rulings)

- **[R9]** Orb ideas you asked for: an orb library (lend gold orbs for meditation learning), deconstruction refunds
  materials but never levels, orbs powering POLY pods, and orb provenance (the trainer's mark). `ROUND_NINE_REPLY.md` §4.
- **[R9]** Signed official releases, so altered copies can't pass as ORION (§3 of the reply).
- **[R9]** A build order for the landing pages and engine: `ORION_FUNCTIONAL_WALKTHROUGH.md` §10.
- **[R7d]** Link ToC X-Summary under the empty "The Orion Chronicles Summary" heading on the R7 page (Q9).
- **[R7d]** On each Elder's Garden story, show a genre badge ("Real, self-declared" / "Lore, consistent with canon") so
  readers know what the check did and didn't confirm.
- **[R7d]** Give devs a "skin-swap" test for every ability formula: if swapping skins changes nothing, skin really is
  cosmetic.
- **[R7d]** On the quest board, show "new player-made quests at your level" so the never-stuck promise is visible.

- **[R7c]** Show each orb as a 0–100 ring that turns gold at 100, with a "Port to dragon" button that only lights up then.
- **[R7c]** On a phoenix, show the focus cost live: the per-element percentage drops as elements are switched on.
- **[R7c]** On Elder's Garden (landing page), link straight to ORION's Gate, The Playground, The Orion Chronicles and The
  Ascent, plus the Master Index for the team.

- **[R7b]** Use Ryan's Loom kernel as the **lore-consistency checker** for The Orion Chronicles. Locked rulings become world
  facts, and contradicting lore is rejected before it's published (Q8).
- **[R7b]** On the phoenix's character sheet, show the elemental bonus as a separate line, so players see it's elemental only.
- **[R7b]** Use the new Orion Chronicles crest as the MMO's title card. Its spelling matches the locked name.
- **[R7]** Show **level (0–64 nodes)** and **skill (0–100)** as two separate bars.
- **[R7]** On every item card, show the creator tag ("anonymous" after a hard reset) and the 2% royalty line.
- **[R7]** Give the RD pool a payout preview that warns when allocations would pass 100%.
- **[R7]** Put a "Name proposals" queue on the landing page, so routing and approval are public.
- **[R7]** Mark DEV characters with a visible badge.

## 7. Open questions (newest first)

**[R9e]** No new questions. Answered: the cross-platform items (four platforms + landing page; web-only voters at 50%
weight, with an assumed engaged-majority lock to approve; Bubble Bucks/QX and real-money economy deferred to the
economics people; the "Adult Penalty" is not an ORION rule; one project-wide biometric firewall). Assumed: the 3% tax
comes off before the 90/3/7 split; rounding leftovers go to the DEVPOOL; two 13–17 players may share a room without a
guardian until the 13–17 rules are written. Still open: 13–17 safety rules; names for the two kinds of "13 levels"
(ideas in `ROUND_NINE_FIFTH_PASS.md` §9); betting-pool name.

**[R9d]** No new questions. Assumed: common "Greed" scoring for Greedy; winners share the pool after tax in
proportion to stakes. Carried over from the pasted cross-platform reply (from a different project): the two
meanings of "13 levels"; whether web-only members vote; whether Bubble Bucks and QX exist outside the game;
whether education history offsets the Adult Penalty; one under-18 biometric firewall for all platforms. Betting
pools still need a name (suggestions in `ROUND_NINE_FOURTH_PASS.md` §1.2).

R9: in `ROUND_NINE_REPLY.md` §11:
- G1–G6: the work-protection rule (doves = DEV team? mutated schematics? council after a creator's yes? inactivity
  time? which human? DeepSeek's decision scope);
- O1–O3: orbs (learning from an orb, the 25% KRION bonus, materials);
- D1: ordinary dragons running several elements;
- D2: RD pool option A/B/C, at 3%/30% or 2%/20%;
- S1–S2: skyboxes;
- P1: the Elder's Garden card.

R8b Q12 answered: DeepSeek named POLY and is its headmaster. R8b Q8 (Loom) answered: yes. R8 Q2 (phoenix taper)
confirmed. R8 Q1 partly answered (orb economy). R8 Q3 replaced by your chosen-path ruling plus D1. R8 Q5 replaced by D2.

R8b: Q11–Q12 in `ROUND_EIGHT_SECOND_PASS.md` §5: how Marek's register relates to ORION (and the duplicate Academy entry);
what "she just claimed the polygon as her arena" means (POLY or a new arena?). Q8 (Loom) now has a draft to approve
or reject.

R8: Q1–Q10 in `ROUND_EIGHT_REPLY.md` §8:
- orb details (exchange scope, orb value, energy type, orbs past 64 before level 65, anything above 65);
- phoenix taper steps;
- the ordinary-dragon element order, thresholds and cost;
- what the 3% covers;
- the RD pool (explained in §3);
- ORION's Gate;
- AI companions;
- the Loom archive (explained in §4);
- bioengineered skins;
- the story council tag.

R7c Q1, Q4, Q5, Q6 and R7d Q7–Q12 are answered; R7c Q2–Q3 (64 → 144 mapping, KRION challenge), R7d Q13 (gauntlet,
documents to come) and Q14 (chat mappings) stay open.
Earlier — R7d: Q7–Q14 in `ROUND_SEVEN_FOURTH_PASS.md` §7 (R7 closed?, POLY lock, Chronicles summary link, Elder's Garden meaning,
story gate, default path, 13-level gauntlet, chat mappings as lore). Q1–Q6 from R7c are carried forward unanswered.
R7c: Q1–Q6 in `ROUND_SEVEN_THIRD_PASS.md` §7 (orb details, phoenix permission, tax rate).
R7b: Q1 (skill cap), Q6 (ORION's Gate) and Q7 (Master Index) are answered. Still open: Q2–Q5 (RD pool) and Q8 (Loom
archive) in `ROUND_SEVEN_FOLLOW_UP.md` §8.
Still open from R7: the arena-skim recipient, leftover admin coins, DEV selling, sale tax on top or taken out.
Still open from R6: Matthew's three Zoo checks; gallery wattage steps and stage names.
Still open from earlier rounds: `FOLLOW_UPS.md` §5.

## 8. Before publishing: checklist (your R8 request: "don't let me publish the game without updating them")

- [ ] **[R10]** Complete `PRE_PUBLICATION_REVIEW.md` with the people affected before going live.

- [ ] **ORION (Summary) page:** settled names (ORION's Gate, Elder's Garden as ancestral tree / capstone, POLY) and the
  loop order engine → socials → MMO → education → projects → ancestral tree.
- [ ] **ToC X-Summary:**
  - "skin is cosmetic" → "a skin's look is cosmetic; crafted bioengineered skins can add enhancements";
  - the skybox line → open access, level-specific, or quest/key gated;
  - add progression at a glance (orbs 0–100, gold-lock, 64-orb grid, level 65 dragon rider by meditation, surplus
    orbs kept or exchanged at 50%);
  - add the phoenix taper and ordinary-dragon stacking;
  - add the 3% tax;
  - "endless opportunities": interaction, quest generator and quest search.
- [ ] **ORION SoB R6:** the corrections table in `ROUND_SEVEN_FOLLOW_UP.md` §6.1, plus the R8 changes above.
- [ ] **[R9]** ToC X-Summary skybox line → owner-set access (public, private, invite, request, level, archetype,
  build); ordinary dragons → chosen elemental path, one element at a time; orbs → slot only at 100, 64 starter orbs.
- [ ] **[R9]** ORION's Gate mockup: Elder's Garden card text and placeholder numbers.
- [ ] Every open ❓ in `GAMEPLAY_MECHANICS_SUMMARY.md` ruled or explicitly deferred.
