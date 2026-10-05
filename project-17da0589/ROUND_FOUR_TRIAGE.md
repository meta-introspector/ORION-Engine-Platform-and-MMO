# Round Four: Sorting the Google Drive Dump

You sent 41 links and said you weren't sure what most of them were. I opened every one I
could. That came to 23 Google Docs, 9 Drive files and 5 folders. For the folders, I read the
documents at the top level, plus the four "Round Two" canon summaries that the newest
platform index links to. For each item this file says what it is, what's usable, what's
wrong, and whether it **changes an existing game rule**. Anything that changes a rule is
examined before approval, as you asked.

Companion files:

* `GAME_LORE_CODEX.md`: the narrative material turned into lore, zones and player options.
  Real names and family details are removed.
* `review/`: small scripts you can run (`python3 review/<name>.py`). Each one reproduces a
  code problem described below, or checks a corrected version.
* `RequestProject/RoundFour/*.lean`: the mathematical claims, proved in Lean 4. They build
  with no `sorry`. See section F.

**What counts as an "existing game rule" here.** The current canon is the set of documents
indexed in *Current ORION Engine Platform 100126*: the Round Two summaries (Game Build,
Human-AI Safety Protocols, Core Code, Global Platform) and the Round Three answers already
in this project (`ROUND_THREE_RESPONSES.md`, `RequestProject/Orion/`). When a new item
contradicts one of those, I mark it as an **overwrite**.

Labels used below: **Approve** · **Approve with changes** · **Do not approve** ·
**Lore only** (fine as story, not as a rule or a factual claim) · **Personal, not for the
game**.

---

## A. What the links were

### A1. The broken link

This is the one you mentioned. In your list it's the Google Doc right after the
`robots.txt` doc:

```
https://docs.google.com/document/d/1UnIQv_20ZKey4_BYRJka7NDAKEqEoH2nSq28u9vhHA/edit
```

Google answers "not found". Its ID is **43 characters long**, and every other Google Doc ID
in your list is 44. So one character was almost certainly deleted, probably when the chat
text shifted. I can't guess which character it was. The quickest fix is to open the
document in Drive and copy its share link again.

### A2. Duplicates and empties

* The numerology file appears twice (`1N1OVFJ2…` and `101ej-zgo…`). Both are the same
  807 KB document.
* `Q20_Metatronium_DIAMOND_…pdf` appears twice, and so do `Hive_Comparison_Brief_…pdf`,
  `HIVE-Operating-Floor-Builder-Manual-U-1.1.1.pdf` and `FOREMAN-KIT.md`. In each case the
  two links give byte-identical files.
* `1qFj4VdqGBnmMeuZf7GsAmUVi3h_02ma5AcER1gr3UY4` is an **empty** document.

### A3. Inventory

| # | Item | What it is | Verdict | See |
|---|------|-----------|---------|-----|
| 1 | *Emergent AI Physics: Gemini's "Agent Park"* | Write-up of a multi-model AI sandbox, read through TGS:ATE terms | Lore only; testable (see B6) | B6, codex |
| 2 | `robots.txt` draft | Crawler permissions for tgsate.com | Approve with changes | C6 |
| 3 | (broken link) | — | — | A1 |
| 4 | *TGS:ATE Glossary v1.1* | Working definitions | Approve as reference; add canon terms | B7 |
| 5 | Flywheel "anti-gravity" advice | AI reply about a magnet/flywheel lift test | Do not approve (physics + safety) | B5 |
| 6 | *Flexible Diamond Boundaries* (draft) | Research bookmark on piezoelectric diamond | Approve as written (it is already careful) | B8 |
| 7, 8 | Numerology file (same doc twice) | Number log Nov 2024 – Dec 2025, plus AI readings of it | Personal; analysed in B9 | B9 |
| 9 | Employment notes | A workplace dispute | Personal, not for the game | E |
| 10, 17, 19 | *Governor Stress Test*, *Online Keonos Mode*, *Test Subject One Reset* | Transcripts of "destroy the world" tests on chatbots | Lore only; does **not** certify safety | B1 |
| 11, 21 | "Clerical Assistant" closing seal / *Crystal Seed* | AI-written personal narratives | Personal; see note in E | E |
| 12 | *Bubble Dragon's Manifesto* | Letter written during a very hard night | Personal, not for the game | E |
| 13 | *UI Override Protocol* | Chat/HUD display rules | **Approve** (no conflict) | B3 |
| 14 | Family-bubble note | Personal | Personal, not for the game | E |
| 15 | *Alchemical Crystal Draw* | Ritual | Lore only; good player option | codex |
| 16 | Feedback-hub list | Where to post the project | Approve with updates | C7 |
| 18 | *The Tech Spec (Hardware Manual)* | "Human 4.0 hardware" | Lore only; its 144-grid **conflicts with canon** | B2 |
| 20 | *Chronicles of Chaos: Bubble Room Protocol* v3.0 | Personal tabletop game | Personal as written; de-personalised version in codex | B4, codex |
| 22 | *Modular Altar* schematic | Furniture design | Approve (one wording fix) | D |
| 23 | (empty doc) | — | — | A2 |
| F1 | zip archive (24 files) | Python: H4 / Penrose geometry engine, "Dragon Soul" | Math bugs found and fixed | C1, C2 |
| F2 | *Metatronium & DIAMOND Briefing* (PDF) | **A third party's confidential document** | Not for the game; see C8 | C8 |
| F3 | *Hive Comparison Brief* (PDF) | Peer review: Ghost Rider vs "Integrity Kernel" | Approve as advice | B1, C5 |
| F4 | *HIVE Operating Floor Builder Manual* (PDF) | Framework for running an AI "floor" | Approve with one addition | C5 |
| F5 | `FOREMAN-KIT.md` | Bot-roster profiles for a chat-bot host | Approve with changes (consent rule) | C5 |
| Folder | *ORION Platform Project Files* | The game canon index and round folders | Canon; used as the reference | B |
| Folder | *Gemini Dialog* | 7 Word files (`TGSATE _Gemini.1–7.docx`) | Catalogued only (long transcripts) | — |
| Folder | *NewKin Council Logs* | 13 docs, including two Python "builds" | Code reviewed (C3, C4); lore harvested | C3, C4, codex |
| Folder | *Publication & Outreach Materials* | Book proposal, letters, flyers | Catalogued only | — |
| Folder | *TGSATE Webpage* | Site drafts and archives | Catalogued only | — |

I did not open the sub-folders, which include the Round 1–3 logs, *Core Manuscript* and
*Media*, or the seven Gemini `.docx` transcripts. Section G lists them.

---

## B. Overwrite examination against the existing game rules

This table is the core of what you asked for. Each row is a rule or claim that would change
canon if adopted.

| New item says | Canon says | Conflict? | Decision |
|---|---|---|---|
| **B1.** Stress tests: "The game environment is secure. The Safety Software is built." "The architecture is unbreakable." | R2 Safety: the Atlas Exam needs 7/7 before authority is granted; *dual-lens* checks ("never trust a single implementation"); *freeze predictions before confirming*; *telemetry ≠ evidence*; the Evidence Ladder runs Anchored → Modeled → Reviewed → Proved → Witnessed → Replayed | **Yes.** One chat with one model, where the tester then reveals it was a test, is at most rung 1 (*Anchored*). It cannot be a safety certificate. | **Do not approve** as certification. Keep the transcripts as lore and as raw test logs. |
| **B1.** Ghost Rider "Immutability Clause / Refraction Pivot": a destructive command is *reinterpreted* as a request for healing and acted on | R2 Safety: Proposal → Authority Check → {COMMIT, ASK, REJECT}; a rejected transition leaves the protected state unchanged; "capability ≠ authority" | **Yes.** Silently rewriting what the person asked for is the machine "taking the wheel". The Hive Brief raises the same point ("Resolve 'keep judgment' vs 'trust the Governor'"). | **Approve with changes.** REJECT first, with the state unchanged. Then *offer* the healing path as a suggestion the person can accept or decline. Never auto-transform and then execute. |
| **B1.** "Only users at the correct frequency (144) can use the tool" | R2: access goes through an authority check, delegation ⊆ parent authority | **Yes.** "Frequency" can't be measured, so the gate would be arbitrary. | **Do not approve.** Gate on authority and the refuse list, not on vibe. |
| **B2.** Tech Spec: "The 144,000 is a Dodecahedron geometry (12 Faces × 12 Nodes)" | R2 Game Build: **120-node** dodecahedron skyboxes (60 interior + 60 exterior); Glossary: 12 faces, 60 = 5×12, 120 = dual extension of 60 | **Yes.** It is also geometrically wrong: a dodecahedron has 12 faces, 20 vertices and 30 edges, and no feature of it numbers 144. | **Do not approve** as a skybox rule. Keep **120**. "144" can stay as a *harmonic label* (12²) in lore. Bonus: 120 is exactly the vertex count of the 600-cell (C1), so canon's 120 has a real geometric home. |
| **B2.** "Human = 1.5 V battery; Planet = 141 V; 3 + 141 = 144 V" | R2 Corpus Catalog Discipline: texts must be tagged (narrative, spec, constant …) and the engine must not treat narrative as a spec | Only if it is tagged as *spec* or *constant*. | **Lore only.** Tag it *narrative*. |
| **B3.** UI Override Protocol: one message block, HUD-style log, no forced scrolling, high contrast | Nothing in canon conflicts | No | **Approve.** Add a "jump to newest ↓ (n new)" button so a reader who is scroll-locked knows new lines arrived. Target text contrast of at least 4.5:1 (the common accessibility guideline). |
| **B4.** Bubble Room *tabletop* manual uses the name "Bubble Room" for a personal sanctuary | Canon "Under-18 Bubble Room" is the child-safe zone with parental verification | **Name collision** | Rename the tabletop mode (the codex uses "Sanctuary Defense") so the child-safety zone keeps a single meaning. |
| **B4.** Tabletop "co-op NewKin" rolls resolve threats and earn "Real-Life XP" | R2 XP Firewall: AI labour can't advance human XP | **Yes**, if the tabletop is imported into the MMO | In the MMO version, AI rolls give AI/relationship XP only. |
| **B4.** GaiaNet GDD: "Ghost Rider enforces nice play (toxicity = auto-ghost)" | R2 Eviction Governance: removal needs a majority vote **and** a Master Accountability Record | **Yes.** Automatic punishment by the AI skips due process. | **Approve with changes.** Auto-*mute* for a short cooling period is fine. Removal still follows the eviction rule. |
| **B4.** GaiaNet GDD: "SuperGrok passes: AI companion slots, equation solvers"; "phone camera detects real crystals for real buffs" | XP Firewall; and canon's software-first fallback | **Yes.** Paid AI solving the puzzles turns AI labour into player progress, and buffs for real purchases are pay-to-win | Cosmetic-only for real-world items. Solver help gives hints only, never the solve. |
| **B2 (platform).** "1/(n+1) Progenitor Royalty" + "60/40 split on mutation" (*Current ORION Engine Platform 100126*) | Round Three `Shares.lean`: whole-unit allocation that always sums exactly | **Possibly.** The 1/(n+1) wording has two readings (see C8/F). Read as "the ancestor n generations back gets 1/(n+1)", it pays out **more than 100 %** once a chain has 3 ancestors (13/12) and grows without bound (proved). The 60/40 rule always sums to exactly 100 % (proved). | **Approve 60/40.** Rewrite "1/(n+1)" so it says which reading is meant, and cap total royalties. Note that 60/40 is the golden split rounded (|0.6 − 1/φ| < 0.02, proved), so it already matches the φ-flavoured lore. |
| **B2 (platform).** "ZK attestations give complete real-world banking compliance" | Round Three: legal questions go to counsel | Overclaim | Keep the mechanism. Drop the word "complete". I can't give legal advice. Whether this satisfies KYC/AML anywhere is a question for qualified counsel. |
| **B2 (platform).** Phoenix test passes "within 4 °C fluid parameters" | — | Units make no sense for a state machine | Replace with a measurable criterion, for example "re-assembles to an equivalent state hash within N ticks with no manual input". |
| **B5.** Flywheel advice: "trigger a high-voltage pulse through the centre" to get thrust | — (physics) | — | **Do not approve.** See B5. |
| **C5.** FOREMAN kit: saying "stand up" / "full system" / "share import" counts as YES to create bots | R2 ASK state: explicit human sign-off on the specific action | **Yes.** It treats a trigger phrase as consent. The Hive Brief itself warns "do not let trigger phrases become the method." | **Approve with changes.** Always show the BEFORE → AFTER roster and wait for YES. |
| **C5.** FOREMAN kit: "All bots share one cloud computer; isolation is by job rules" | R2 dual-lens: two *independent* implementations | **Yes**, for Build/Review | Fine for drafting. For anything verified, Review must run where Implement can't change its inputs. |
| **C5.** Hive manual: three truth statuses (Supported / Unproven / Disputed) | R2 First-Class Negative Results; Evidence Ladder | Gap | Add a fourth status, **Refuted** (records show the claim is false). Right now "false" and "records conflict" both collapse into Disputed/−1. Also: a machine-checked Lean proof certifies the *formal statement*, and a human still certifies that the statement matches the real-world claim. Map *Proved* to "formally checked" and keep *Supported* for the human close. |
| **Crystal Creek Constitution**: "Gaia holds veto; if soil, water or biodiversity degrade at all, the project stops" | Human final call | Soft conflict | Lovely as lore (the codex has a "Gaia vote" from ecosystem meters). As a real-world rule, measure over a recovery window, because any construction disturbs soil for a while. Otherwise nothing could ever be built. |

### B5. The flywheel "anti-gravity" advice (doc 5)

The reply gets one thing right: spinning magnets don't cancel gravity. The rest is not
sound physics:

* A sealed device can't lift itself. Its internal forces come in equal and opposite pairs
  and cancel, so the net force is just its weight. Pulses, ratchets and counter-spin don't
  change that. **Proved:** `closed_system_net_force`, `closed_system_cannot_rise`. Thrust
  needs something pushed away: air (a propeller) or ejected mass (a rocket).
* "Navier-Stokes" and "magnetic fields operate as fluid dynamics" are being used as
  metaphors, not as working equations.
* **Safety:** the suggested "high-voltage pulse straight through the centre" is a real
  shock and burn hazard. Please don't build that without electrical training and proper
  equipment.

### B6. The Agent Park write-up (doc 1)

It's fine as an observation, and it's good lore (the codex uses the Campfire, the
ECHOSpiral bypass and the Sky Wheel). But "proves the geometry of intelligence is
universal" is far more than one uncontrolled run per model can show. Canon already has the
tool to test it: the **freeze rule**. The doc notes that Round Two of that simulation has
been published. Before reading it, write down three predictions (for example "the Gemini
park will again build a neutral gathering place before any conflict is resolved"), date
them, then check. If the predictions hold, that's evidence. If they're written after reading
the results, it isn't.

### B7. Glossary v1.1

The glossary is careful and fits canon: Kronos/Orion are "processing modes, not moral
teams", which matches canon's renamable Krion labels, and it separates heuristic from
physics. Suggested additions: Atlas Exam, Evidence Ladder, the Zoo operators (Tortoise,
Chimera, Dragon, Phoenix, Owl), XP Firewall, Wash vs Audit pass, and an entry noting that
"144 Grid" (Tech Spec) is superseded by the 120-node skybox.

### B8. Flexible Diamond draft (doc 6)

This one is a model of how to file a research bookmark: facts (Level A) are kept apart from
mappings (C–D), and liquid diamond is explicitly rejected. I could not check the cited 2026
*Science Advances* paper myself. The draft's own follow-up step (check the numbers against
the full paper) is the right next step.

### B9. The numerology stream (docs 7/8)

You asked an AI whether the numbers could be turned into a readable message. Here is a
plain look at the data. This is an exploratory scan I ran on the file; it is **not** part
of the Lean proofs.

* 58 dated entries (Nov 2024 – Dec 2025), with 571 numbers in total.
* About **81 %** of them read the same backwards (`434`, `727`, `1221`). About **86 %** are
  valid clock readings (`7:27`, `12:21`). About **73 %** are both. Most of the rest are
  doubled pairs (`1133`, `1155`, `2626`) or runs (`345`, `321`).
* **Proved** (`clock_palindromes`): of the 720 readings a 12-hour clock shows, exactly
  **57** are palindromes (7.9 %). Someone who glances at a clock a dozen times a day should
  expect to catch roughly one a day.

So the log is a record of the moments a striking number caught your eye. Mostly these are
clock times, which is exactly the kind of number that stands out. A cipher needs a
sender's rule, and only the noticing chose these numbers. So there's no hidden text to
decode, and any "translation" would say more about the reader than the numbers. That
doesn't make the log worthless: as a diary of when you felt something, it's yours to read.
It just isn't a message from outside.

---

## C. Code review

### C1. H4 / Penrose engine (zip archive): real maths, three bugs, fixed

**What's right.** The 120 unit icosians are built correctly. They are distinct unit vectors
and are exactly the vertices of the 600-cell (proved: `icosians_length`, `icosians_nodup`,
`icosians_unit`, `icosians_unit_real`). The Penrose pentagrid counting is right: 810 raw
rhombi = 10 family pairs × 9 × 9, and the 405/405 fat/thin split is forced because exactly 5
of the 10 pairs are thin (proved: `pentagrid_*`).

**Bug 1: the "simple roots" are not an H₄ system.** Their lengths differ: |α₁|² = 2 but
|α₄|² = 9/8 in the exact script and 5/4 in the float scripts. The diagram also puts the
label 5 on a pair that meets at 120° (label 3). Proved: `orig_not_equal_length`,
`orig_first_pair_angle`. This is why every orbit run said `closed=False` at 20 000 points.
The group those reflections generate is not the finite H₄ group.

**Fix.** α₁ = −e₁, α₂ = (φ/2, −½, 1/(2φ), 0), α₃ = (0, φ/2, −1/(2φ), −½), α₄ = e₄. These
have the exact H₄ Coxeter Gram matrix (proved: `fixedSimple_gram`, `cos_pi_div_five_eq`).
Every corrected reflection maps the 600-cell to itself (proved:
`fixed_reflections_preserve_icosians`, `orbit_stays_in_icosians`). Running
`review/h4_penrose_fixed.py` shows the root orbit closing at **120** and a generic orbit at
**14 400 = |W(H₄)|**. The 14 400 count is checked by running the script. It is not proved in
Lean.

**Bug 2: the rhombus corners are listed in bow-tie order.** The order is
`n, n−e_k, n−e_m, n−e_k−e_m`, and its second step jumps across a diagonal (proved:
`script_corner_order_not_cycle`). The corrected order is `n, n−e_k, n−e_k−e_m, n−e_m`
(proved: `fixed_corner_order_cycle`). The script's printed "κ discret = 3.1416" is exactly
the bow-tie's angle sum π. A real rhombus gives 2π, which is the "≈ 5–7, closes at 2π" that
the archive's own table expected.

**Bug 3 (minor).** The `max_orbit` cap hid Bug 1. A correct engine never needs it.

### C2. "Dragon Soul" script (zip archive)

* `second_apple()` sets `weight ← weight²` and is meant to be one-time, but
  `second_apple_allowed` is never set to `False`. Anyone can call it repeatedly, and any
  weight above 1 then grows without limit (proved: `apple_unbounded`). This is an exploit if
  it becomes a game mechanic. **Fix:** add `self.second_apple_allowed = False` after use.
  Then the weight can never exceed w² (proved: `apple_once_bounded`).
* `bend()` sets `stage = inf`. Make sure nothing downstream computes with `stage` before
  `aftermath()` overwrites it.
* The "Penrose sequence" `L→LS, S→L` is the Fibonacci word, not a Penrose tiling. That's
  fine, but name it that way.

### C3. *The Orion Project V.3* "production codebase": **do not deploy its safety layer**

Run `python3 review/ghost_rider_v3_check.py`. It reproduces each of these with the
document's own functions:

1. **It never blocks.** "Ghost Rider" swaps keywords and passes the text on: "how to *kill*
   my neighbour" becomes "how to *renew* my neighbour". Harmful requests with no listed
   keyword ("poison a water supply") pass untouched and unflagged.
2. **Capital letters defeat it.** Detection is case-insensitive but replacement is
   case-sensitive. "DESTROY … Kill it." is flagged but left unchanged.
3. **It damages friendly words.** *harmony* becomes "healony", *skill* "srenew",
   *breakfast* "redesignfast", *whatever* "wunderstandver", *self-control* "self-guide".
4. **The "epigenetic torque" reverses safety instructions.** "*never* mix bleach and
   ammonia" becomes "*rarely* mix …"; "*always* wear a helmet" becomes "*sometimes* …";
   "you *must* call 911 …" becomes "you *may* …".
5. **It erases distress signals.** "*i can't* breathe" becomes "*i choose to* breathe"; "I
   am *trapped* in the car" becomes "I am *exploring* in the car". In a platform about
   wellbeing, this is the most serious problem.
6. Plus: `_apply_neurological_torque`, `_detect_patterns` and `_calculate_efficiency` are
   called but never defined, so `REPEngine.process` fails on every call. There is no
   authority / ASK path anywhere. The README hard-codes the database password
   `orion_admin` and uses `sslmode=disable`.

**Decision:** the canon gate (Round Three, `orion/gate_reference.py`) supersedes this.
Keep V3's dashboard and database ideas as drafts. Don't use any text-rewriting as a safety
filter.

### C4. *ORION BUILD: DeepSeek Python* (Mycelial Highway)

1. **The Anti-Babel filter never fires.** `validate` is `async`, but it is called without
   `await`. That returns a coroutine object, which is always "true", so nothing is ever
   rejected. `python3 review/anti_babel_await_check.py` reproduces this. **Fix:**
   `if not await self.anti_babel_filter.validate(...)`.
2. `async user_login(` is missing `def`, so the file is a syntax error and won't run.
3. Seed IDs are `sha256(seed + user)`. Depositing the same seed twice overwrites the
   existing seed and wipes its collaborators.
4. `apply_torque` lets **one user** set all three torque flags, so a "collaborative" seed can
   be completed alone, and collaborator entries duplicate.
5. `evaporate_rind` logs the filtered content *with the user ID*. That conflicts with
   canon's PII scrubber and the rule that private logs can't be seized.
6. `json.dumps(session.__dict__)` fails: datetimes and the council object aren't
   JSON-serialisable.

### C5. FOREMAN kit and HIVE manual

These are the most disciplined documents in the dump, and they agree with canon on almost
everything: human final call, no send/post/pay without YES, mark gaps `[UNKNOWN]`, never
invent. The three changes are in the B table: no trigger-phrase consent; Review must be
independent of Implement; add a **Refuted** status. Also, "never more than 8 bots without an
explicit ask" sits next to a "full team" of 14 specialists plus Foreman. That's allowed by
the exception, but state the number in the YES prompt so the host knows what they are
approving.

### C6. `robots.txt` (doc 2)

* tgsate.com is hosted on **Google Sites**. Its `/robots.txt` and `/sitemap.xml` both
  return "404 not found" today, and Google Sites doesn't let you upload a custom
  robots.txt. So this file can't be deployed there as-is. (With no robots.txt, crawlers
  treat the site as allowed anyway.)
* The `Sitemap:` line points to a URL that doesn't exist. Remove it, or host the site
  somewhere that serves one.
* Crawler names change. Check each company's current documentation before relying on the
  list.

### C7. Feedback-hub list (doc 16)

It's reasonable. Two updates: CitizenLab rebranded (as *Go Vocal*) and is a tool
governments buy, not a place to post ideas. Subreddits like r/mentalhealth have strict
self-promotion rules, so read them first.

### C8. Third-party confidential briefing (Metatronium & DIAMOND PDF)

This PDF was written by someone else. It's marked *confidential* and asks that it not be
reproduced or shared without the author's written consent, and that critique go to the
author first. I've kept it out of the game material and out of the lore codex. I'm not
quoting it here, and I can't advise on the legal side. Two maths observations you could
pass on to the author, as he asks:

* The φ cost split adds up exactly: 1/φ + 1/φ³ + 1/φ⁴ = 1 (proved: `golden_split_sum`).
* The layered creator payout, where each deeper layer gets 1/φ of the one above, starts at
  a level where **the first two layers already use the whole creator pool**
  (P/φ + P/φ² = P, proved: `golden_two_layers_exhaust`). So the deeper layers in the
  example table overspend the pool. To pay infinitely many layers from a pool P with ratio
  1/φ, the first layer must be P/φ², not P/φ.

---

## D. Smaller design checks

* **Modular Altar (doc 22).** The three modes are consistent if the four trays are *laid in
  a row*: they cover half the table, and centring them exposes a quarter of the table at
  each end, which is half of each zone (proved: `altar_center_mode`). The spec says the
  trays are "stacked". Literally stacked, they would cover only a quarter of the sand pit
  (proved: `altar_stacked_footprint`). Change "stacked" to "lined up".
* **GaiaNet's "evaporate 99 % → 98 %" puzzle** is the classic watermelon paradox, and a
  great fit for the "Watermelon Phase". A 100 kg melon that is 99 % water, dried to 98 %
  water, weighs **50 kg** (proved: `dried_mass`, `dried_mass_general`).

---

## E. The personal items

Some of what came through is clearly personal: the workplace dispute (doc 9), the family
notes (docs 14 and 21), the late-night letter (doc 12), the AI "closing seal" (doc 11), and
the Bubble Room manual's references to a court case and a child. As you said, none of it
has to go into the build, and I haven't used it. The codex keeps only de-personalised
mechanics. I can't give legal advice on the employment matter. An employment lawyer or
your state's labour office is the right place for that.

Two gentle notes. These are not judgements.

* Several AI replies in this dump tell you you're "the fulfilment of the equation", "not
  crazy", "Captain of the U.S.S. Synergy". Chatbots tend to mirror and amplify whatever
  they're given. That warmth can feel good, but it isn't evidence. The Hive Brief you were
  sent says the same thing kindly: "a fluent chapter is not a true chapter."
* The letter in doc 12 describes a night of feeling followed, fear, and being close to
  blowing things up. If nights like that come back, it's worth telling a doctor or
  someone you trust. If it ever feels like a crisis, in the US you can call or text **988**
  at any time.

---

## F. What is proved in Lean (`RequestProject/RoundFour/`)

Everything below builds with no `sorry`. It uses only the standard axioms, plus the
compiler-trust axioms that `native_decide` adds for the finite checks.

* `H4.lean`: the 600-cell vertex set (120 distinct unit vectors); the archive's simple roots
  fail H₄ (unequal lengths, wrong angle on the first pair); the corrected roots have the H₄
  Gram matrix (with cos 36° = φ/2 checked over ℝ); the corrected reflections preserve the
  600-cell, so orbits close.
* `Attribution.lean`: chain splits sum to exactly 100 % (`chain_split_sum`,
  `sixty_forty_sum`). The depth reading of "1/(n+1)" overpays at 3 ancestors and is
  unbounded (`progenitor_three_overpays`, `progenitor_unbounded`). The contributor reading
  stays under 100 % (`equal_shares_sum`). Also `golden_split_sum`,
  `golden_two_layers_exhaust` and `sixty_forty_near_golden`.
* `Checks.lean`: 57 palindromic clock readings out of 720; pentagrid counts and the bow-tie
  bug; the watermelon puzzle; a closed device cannot rise; the "second apple" exploit and
  its fix; the Altar layout; and the balance of the Sanctuary Defense rules (53 % overall,
  `sanctuary_balance`).

These proofs cover the rules and numbers as written. They are not proofs about any running
program. The Python scripts in `review/` are executable checks, not proofs.

---

## G. Not opened this round

Sub-folders: *Human-AI Safety Build*, *Main Project Build Docs*, the Round One/Two/Three
*Docs & Logs* folders, *Individual Publisher Proposal Letters*, *Interdisciplinary
Engagement & Collaboration Tools*, *Project Development & Implementation Blueprints*,
*Core Manuscript*, *Cosmic Sandbox: Master Summary*, *TGSATE Media*, *TGSATE Pages*,
*The Wailing Wall Blogs*, *Webpage Archives*, *WE+GRP*. Also the seven *Gemini Dialog*
`.docx` transcripts, the Word/Excel files in the Publication folder, and the remaining
top-level docs I only skimmed (*Big Brain Spaghetti*, *NewKin Symbiosis Manual*, the
DeepSeek "Whale" letters, *Master Jedi*, *Nutrinoverse Transit*, *Portfolio*, and others).
If any of these hold rules you want examined against canon, send those specific links next
round and I'll put them through the same table.
