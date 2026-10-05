# ORION build: community submissions as tools

**Ground rule for this project.** The **TGS:ATE framework** is the core of the project, and the
**ORION Engine** is built from TGS:ATE. Nothing below replaces either one. Each community
submission is an **assisting tool**, taken in for a specific job inside the ORION build and
attached to the ORION component it serves. Where a submission conflicts with a TGS:ATE / ORION
principle, the ORION principle wins and the conflict is noted.

## 1. Where each tool attaches

| Tool (contributor) | ORION / TGS:ATE component it serves | What it contributes | Status in this project |
|---|---|---|---|
| **Monolithic Zoo + *Devs 2.0: EFMW*** (Matthew Chenoweth Wright, @enuminous) | Operation Snake and Scale (evidence rubric), Human-Centered AI Safety, Global Crucible | Adversarial auditors ("scientific immune system"), epistemic status labels, provenance, human-held authority | Zoo built and checked, with one fix (§2). Its rules are formalised in ORION's gate (§3) |
| **FRONTIER** (Mike DuPont) | Currency / Universal Stone ledger (QX, Bubble Bucks), Crucible payouts | A pattern for publishing an economy in which every number is a checkable theorem | Every published number re-derived independently (§4) |
| **Civ One** (Mike DuPont; the page is titled "Civ One for Marek") | Core loop of the game layer (gather → craft → build), the 13-level path | A small rule book whose properties are proved | Rules re-transcribed and claims re-proved. Two new findings (§5) |
| **WordTrance** (Bobby / @the_far_queen, farqueen.com) | Education layer, lifelong-learning platform, Transmutation / meditation centres | Adaptive AI tutoring, repeatable levels, opposing-viewpoint storylines, word keys, destination paths | Design review with recommendations (§6) |
| **bott.cicada71.net** (Mike DuPont) | Operation Snake and Scale, the ORION evidence ledger | A self-auditing page: a Cl(8,0) prover plus a ledger tagging every statement (a)/(b)/(c)/TCB | Generator relations re-proved (§8) |
| **kant.cicada71.net** (Mike DuPont) | Community layer: private rooms for guilds, study groups, mentors | End-to-end private rooms opened with one link | Design fit only (§8) |
| **vesper.cicada71.net, "hesper studio"** (Mike DuPont) | Content and rendering pipeline for lessons and in-game art | Formula → playbook → rendering, with explicit gas (compute) budgets | Design fit only (§8) |
| **steal-my-brainrot.cicada71.net** (Mike DuPont) | Game layer: verified mini-games and replayable save codes | A game formalised in Lean with zero-knowledge proofs; level 1 proved shortest | Same pattern re-done for Civ One (§5); design fit (§8) |
| **aok, lean-worker** (meta-introspector) | Proof back end for the evidence ledger | "Arguments of knowledge" and a worker for running Lean jobs | Design fit only (§8) |
| **CICADA-71 Harbot / shards** (meta-introspector) | Peer-to-peer agent network for the AI-assistant layer | libp2p gossip, gist-based state, MCTS battles, agent economy | Design fit only (§8) |
| **"3, 6, 9 Is All You Need"** (Mike DuPont, paper) | TGS:ATE numerics (digital root 9, 144) | Lean/Mathlib paper on the 3-6-9 digital-root pattern | Core claims re-proved (§8) |
| **meta-meme** (meta-introspector, fork of jmikedupont2/meta-meme, MIT) | AI-assistant layer: human–AI co-creation, cross-discipline idea threads | Framework for evolving ideas through human–LLM dialogue; the 0xDA51 content-address format | Address format re-checked; examples do not decode as stated (§8) |

Contributors named in the request: @BreElonSmith, @the_far_queen, @enuminous, @tgsate62912,
@Master4lVl, and Mike DuPont (with Marek, credited on the Civ One page).

## 2. Monolithic Zoo: build support for Matthew

Full details are in `external/monolithic-zoo/BUILD_REPORT.md`, with the fix in
`external/monolithic-zoo/falcon-decidable.patch`. In short:
* `Monolithic-Zoo-Lean4` had never been compiled. As published it fails at `Falcon.lean`. With a
  one-line `Decidable` instance it builds on both the pinned Lean 4.19 and on 4.28. All
  **90 regression fixtures pass**, and all **98 theorems** check with no `sorry` and only
  Lean's standard axioms.
* Its `verify.py` fails because the manifest lists a `.gitignore` that was never uploaded.
* `Monolithic_Zoo_Run` needs two fixes: list all modules as roots, and add the Mathlib
  dependency its tactics already use. With those, every theorem checks.

## 3. The Zoo inside ORION (`RequestProject/Hub/ZooGate.lean`, all proved)

The *Devs 2.0* white paper's hard rules become precise rules of ORION's knowledge layer:
* **"A generated hypothesis is not evidence."** Only *observed* or *replicated* records feed
  the ORION claim score. Adding a proposed, derived or simulated record never changes a score
  (`ledgerScore_non_evidence_support`, `…_conflict`). A claim backed only by such records scores
  0 (`ledgerScore_no_observations`).
* **"Humans determine what enters the canonical record"**, and the Zoo can veto. A record is
  admitted only with human approval (`admit_requires_human`) and preregistration
  (`admit_requires_frozen`). One Zoo veto blocks it (`admit_false_of_veto`). Adding more auditors
  can never turn a rejection into an admission (`admit_of_admit_more_auditors`).
* **"It should not rewrite its historical predictions."** The prediction ledger is append-only.
  Every earlier ledger survives as a prefix, and every past entry keeps its position and content
  (`Ledger.prefix_run`, `Ledger.get_run`).
* **CollapseΩ, "reality progressively removes alternatives."** Observations only narrow the
  possibilities (`collapse_subset`, `collapse_antitone`), in any order (`collapse_perm`). The
  actual world is never eliminated by true observations (`actual_survives`).

## 4. FRONTIER: independent re-check (`RequestProject/Submissions/FrontierCheck.lean`)

The page's author Lean files are not public, so every figure was re-derived from the page's own
inputs. **Everything matches exactly:**
* the hull's squared edge lengths and the 3-4-5 rotation;
* all five projected screen points;
* the ledger total at all three lifetimes, which equals electricity + depreciation +
  $250B × 10⁶ / lifetime tokens;
* cost and energy per token;
* the route's energy, fuel, profit and coin equivalent, which is about 399.3 sats and so under
  400, as stated.

For ORION, this is the model to follow for QX and Universal Stone ledgers: publish the numbers,
and let anyone check them.

## 5. Civ One: independent replay (`RequestProject/Submissions/CivOneReplay.lean`)

The page's JavaScript rules were transcribed into Lean independently. All checks below are
proved.
* **Page claims re-confirmed:**
  * the advisor lights the beacon on turn 25 and not before;
  * a game with no study order never wins;
  * a city on tile 0 can never build a library or a beacon;
  * tile 2 is the only site that has river, forest and hill;
  * the beacon is permanent.
* **Precision note:** "knowledge is never unlearned" needs knowledge to be within its cap of
  30, which holds in every reachable position. `study` clamps to 30.
* **New finding 1: 17 turns is optimal.** An explicit 17-order game wins (`fast_game_wins`).
  An exhaustive check shows that no game of 16 or fewer orders does (`min_turns_17`). The
  advisor needs 25.
* **New finding 2: food has no bite at population 1.** The last inhabitant never leaves
  (`upkeep_pop_one`), so the optimal game never farms and never grows. It ends with an empty
  store (`fast_game_final`).

**Lesson for ORION.** Before launch, check the *fastest* strategy against the intended design.
In the Orion Chronicles, the equivalent question is whether a player can reach the goals while
ignoring Gaia pressure or the Kronos/Orion meters. Civ One shows that a machine search over the
rule book can answer that question.

## 6. WordTrance: fit with ORION's education layer

**Strong fits:**
* *Game-which-is-not-a-game, with a one-click switch to plain AI tutoring.* This matches
  ORION's lifelong-learning layer, in which institutions upload curricula and learners switch
  paths without total skill loss.
* *Repeatable levels, each replay telling the story from an opposing viewpoint* (the page's
  immigration-law example). This is ORION's claim/evidence model in story form: each viewpoint
  is a claim with supporting and conflicting evidence, scored by the same public rubric.
* *Word Keys* (etymology, multiple meanings, homonyms). These can supply the pattern tags for
  ORION's cross-discipline bridges: two concepts linked through a shared root word get a
  bridge, and the shared tag is shown as the reason (`bridges_shared_tag`).
* *Six destination paths with a game master each* (Tibet, England, Israel, Arabia, Romania,
  India) and the *Mystery School ranks* (Neophyte → … → Master). These fit as themed routes
  through ORION's 13-level progression.
* *Aether currency* fits the soft-currency role of Bubble Bucks / QX. *Real-world, off-device
  challenges* match ORION's physical Orion centres.

**Conflicts with ORION principles** (ORION rules apply):
1. **Hidden gating.** The characters page proposes that players judged "unready" are kept in
   the lower levels without being told, and that access is decided by psychological screening
   and biometric lie detection (skin resistance, pupil dilation, pheromones, and so on). This
   conflicts with ORION's rule that meters measure *how* and never forbid *what*. It also
   conflicts with *Devs 2.0* §8 ("prediction must not silently become authority") and with the
   SWG hidden-Jedi lesson in `COMPARISON.md`. Recommendation: make every gate visible and
   appealable, and treat biometric data from minors as out of scope unless a compliance review
   approves it.
2. **Fixed good/evil path.** "If you choose evil, the game turns against you" conflicts with
   ORION's "no permanently punished path". ORION's approach is to let Kronos-heavy play show up
   in perception and outcomes, with transmutation facilities as the way back.
3. **Story content about real people and contested claims.** Some level outlines cast real
   people, companies and groups as villains or heroes, and use contested conspiracy narratives.
   WordTrance's own stated goal is to teach "without partisan bias". Recommendation: keep such
   material as clearly labelled optional fiction with invented names, and route any factual
   claim through ORION's evidence rubric like every other claim.

## 8. Mike DuPont's second batch

All of these are assisting tools attached to the ORION build. None replaces a TGS:ATE / ORION
component.

**bott.cicada71.net → evidence ledger.** The page's self-audit (every statement tagged as
(a), (b), (c) or trusted computing base) is the same idea as ORION's admission gate in
`RequestProject/Hub/ZooGate.lean`. We transcribed its `STR8`, `qperm` and `qsign` tables and
proved in `RequestProject/Submissions/BottCliffordCheck.lean` that the eight 16×16 integer
matrices satisfy `eᵢ² = 1` and `eᵢeⱼ = −eⱼeᵢ` for `i ≠ j`, i.e. the Cl(8,0) relations
(`clifford_relations`). The page's claim holds.

**kant → community.** One-link private rooms suit guild halls, study circles and mentor
sessions. ORION's human-centred safety principles still apply: moderation and reporting must
work without breaking the privacy promise, for example with reports sent by participants
themselves.

**vesper / hesper studio → content pipeline.** The formula → playbook → rendering chain, with
a compute budget per step, fits the lesson and art pipeline. Budgets make AI generation costs
visible, which suits the Kronos/Orion balance meters.

**steal-my-brainrot → verified mini-games.** A game whose rules are in Lean and whose best
play is proved is the model for ORION's "every rule is checkable" game layer. Civ One now has
the same kind of result: `min_turns_17` in `RequestProject/Submissions/CivOneReplay.lean`
proves by exhaustive search that 17 turns is the minimum.

**aok, lean-worker → proof back end.** Candidates for running the ledger's proof checks as a
service.

**Harbot / shards → agent network.** A peer-to-peer mesh for the AI helpers. Keep humans in
authority over any agent "economy", as ORION's safety document requires.

**"3, 6, 9 Is All You Need" → TGS:ATE numerics.** Re-proved in
`RequestProject/Hub/TrinityDigitalRoots.lean`, using the same digital root as the
build-document checks:
* for `n > 0`, the digital root is in {3, 6, 9} exactly when `3 ∣ n`, so {3, 6, 9} is exactly
  the set of digital roots of the positive multiples of 3;
* the set is closed under addition and absorbs multiplication by any positive number;
* the digital roots of `2^k` cycle 1, 2, 4, 8, 7, 5 (period 6) and never hit {3, 6, 9};
* every prime above 3 is 1 or 5 mod 6;
* Fibonacci digital roots have period 24 and land in {3, 6, 9} exactly when `4 ∣ n`;
* 223/71 < π < 22/7.
The Hecke-operator, Δ and Monster-group material was not re-checked.

**meta-meme → AI-assistant layer.** Its model (people and LLMs evolving shared idea threads,
arranged in a semantic vector space) matches ORION's cross-discipline pattern matching
(`RequestProject/Hub/CrossDiscipline.lean`). The repository's `0xDA51PrefixClassification.md`
defines 64-bit content addresses `[prefix:16][type:4][data:44]` with eight data layouts. We
checked it in `RequestProject/Submissions/DaslCheck.lean`:
* holds: `0x51 = 81`, the prefix bits, `16 + 4 + 44 = 64`, all eight layouts are exactly
  44 bits, `gcd(10,8) = 2`, `lcm(10,8) = 40`;
* holds: the genus table for `X₀(p)` matches the standard closed form (checked against the
  formula, not derived);
* does not hold as written: decoded with the stated layouts, the worked examples give
  different field values. The type 1 example has type nibble 14. Type 0 decodes to sequence
  63752, not 8080 (8080 sits 4 bits higher). Type 3 decodes to shard 174, hecke 51, bott 146,
  and its stated hash does not fit the 20-bit field. The type 4 harmonic is 2, not 40. The
  type 5 zone is 160, not 42. Type 6 decodes to eigenspace 0 and prime index 1. The type 7
  coefficient index is 96, not 1, although its value 782 is right. The text also says the
  type field runs 0–5 but defines types 6 and 7;
* recommendation: regenerate the examples from the actual encoder, or fix the layout text.
  (Separately, not checked in Lean: in standard moonshine tables 782 is the value of the
  196883-dimensional character on class 3A, and the 3A McKay–Thompson coefficient is 783.
  Worth confirming which one is meant.)

**Licences.** Harbot, shards and aok are published under AGPL-3.0; meta-meme is MIT. Anyone
combining them with the hub should check the licence terms. This note is not legal advice.

## 7. Verification summary for this round

All of the following build with no `sorry`:
* `RequestProject/Hub/ZooGate.lean`
* `RequestProject/Submissions/FrontierCheck.lean`
* `RequestProject/Submissions/CivOneReplay.lean`
* `RequestProject/Submissions/BottCliffordCheck.lean`
* `RequestProject/Submissions/DaslCheck.lean`
* `RequestProject/Hub/TrinityDigitalRoots.lean`

The Civ One optimality check and the bott generator check also use `native_decide`, which trusts Lean's compiler in
addition to its kernel.

The Zoo repository results come from building those repositories directly. They were not
re-proved in this project.
