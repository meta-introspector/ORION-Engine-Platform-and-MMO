# ORION R7 Live, third pass: reply

I re-read *ORION R7 Live* after you answered my second Round 7 reply on it. I also re-read the state-of-build page and the
ORION (Summary) page.

- Text copies: `orion/r7c/PAGE_TRANSCRIPT.md` (R7 Live as it is now) and `orion/r7c/SOB_R6_TRANSCRIPT.md`.
- New proofs: `RequestProject/RoundSeven/ThirdPassSeven.lean`. The whole project builds with no `sorry` and only Lean's
  standard axioms.
- **New:** `ORION_MASTER_INDEX.md`, the Master Index you okayed (👍🥳). It has a glossary skeleton and a page/source
  archive.
- The running roster (`ORION_RUNNING_ROSTER.md`) is updated. Changes from this pass are marked **[R7c]**.

"Proved" means the stated rule has the stated consequence. It does not mean the game code implements it.

---

## 0. The SoB page: already retitled ✔

You said you'd retitle the state-of-build page as out of date for its round. It's already done: the page now reads
**"ORION SoB R6"** (it was "ORION SoB 100326"). Apart from the title, its text is the same as when I read it last pass.
So my corrections table (`ROUND_SEVEN_FOLLOW_UP.md` §6.1) still applies to it as written.

Two small things you may want to change at the same time (optional):
- On R7 Live, the link to that page is still labelled **"ORION Engine SoB 100326"**.
- The page's first line still reads "current state of build exhaustive summary 10/03/26". A line saying "Out of date as of
  R7; see the R7 corrections" would stop a new reader from treating it as current.

**Also new at the top of R7 Live:** a link labelled **"The ORION Engine"** that opens the **ORION (Summary)** page (the same
page as the "ORION Platform Summary" link below it), and a heading **"The Orion Chronicles Summary"** with nothing under it
yet. If the Chronicles summary is meant to be its own page, the link is missing.

**Attachments:** the three ZIPs on the page are the same files as before. I downloaded them again: two have the same
SHA-256 as last pass, and the pilot's 23 checksums and 22 tests pass again (`orion/r7c/attachments-recheck.log`). The
ORION (Summary) page is unchanged since I first read it.

## 1. Skill orbs: the leveling system is settled (closes Q1)

Thanks, that's clear now. Here's how I've written it down:

- Each of the **64 character nodes** holds a **skill orb**.
- An orb levels **one step at a time, up to 100**. At 100 it's **gold-locked** (crystal-clear centre, gold ring).
- **Only a gold-locked orb can be ported** to the dragon matrix.
- The **dragon matrix has 144 nodes** (64 + 80).
- On the dragon, a new orb **doesn't repeat the grind**. It takes the dragon's skill level for that skill straight away.
  The player then opens the **Black Hole lock** with the **KRION meter challenge**.

So the skill cap is **100** (the orb's gold-lock level), and **144 is the dragon matrix's node count**. Round 3's "144"
for skills is **superseded by your ruling**. The roster now shows it as settled.

Proved in `ThirdPassSeven.lean`:
- An orb can be ported **exactly when** it's at level 100 (`portable_iff_goldLocked`).
- From level 0 it takes **exactly 100 level-ups** to gold-lock. Fewer is never enough, and extra level-ups don't go past
  100 (`levelUps_to_goldLock`, `levelUp_le_cap`).
- **Player level** = the number of gold-locked orbs. It never goes above 64, and it's 64 exactly when all 64 orbs are
  gold-locked (`playerLevel_le`, `playerLevel_eq_64_iff`).
- **Only gold-locked orbs reach the dragon.** Starting from an empty matrix, any sequence of port attempts leaves every
  filled node gold-locked. A refused port changes nothing (`ported_all_goldLocked`, `port_refused`).
- Slotting an orb on the dragon sets it to the dragon's skill level at once (`slotOnDragon_level`).

Three details to pin down (none blocks the rule above):
- **Q1.** When all 144 dragon nodes are already full, where does a new orb go? Does it **replace** an orb that's already
  there?
- **Q2.** Do the 64 gold-locked character orbs fill 64 of the 144 dragon nodes, with the other 80 for dragon-only skills? And
  does the "no grind" auto-adjust apply as soon as you have a dragon, or only once all 144 nodes are filled?
- **Q3.** Is the KRION meter challenge needed **once per orb**, or once to open the whole matrix?

## 2. Phoenix: you're right, and it needs your permission because it reverses Round 5

You don't want the phoenix to be what everyone picks: having more elements should cost strength in each one. That reverses
your Round 5 ruling ("the dragon Phoenix's abilities at least 10% greater than any other ... across non-Phoenix dragons
and elemental players"), and my last pass, which kept a 10% elemental edge. So it's in the roster's **"needs your
permission"** table. Here's a concrete version to approve or adjust.

**Proposed rule: focus cost.** Every extra active element costs focus. With `k` elements active, each element works at
`1 − d × (k − 1)` of full strength. With **d = 5%**:

| Active elements | Strength in each element |
|---|---|
| 1 (every ordinary dragon) | 100% |
| 2 | 95% |
| 3 | 90% |
| 4 | 85% |
| 5 (phoenix, all five) | 80% |

The phoenix uses the same 2×–2.2× dragon band as everyone else. With all five elements active it's therefore at 1.6×–1.76×
of a non-dragon player **in each element**. That's below every one-element dragon (2×–2.2×) and above every ordinary player
(1×). Its specials stay what Round 5 gave it: all five elements, switching mid-battle, and the visuals.

Proved (`ThirdPassSeven.lean`):
- More active elements never raise strength per element (`focus_antitone`).
- **For any d above 1/44 (about 2.3%)**, a five-element phoenix is **weaker in each element than every one-element dragon**
  at equal skill (`phoenix_below_every_dragon`). 1/44 is the exact edge: at d = 1/44, a 2.2× phoenix ties a 2× dragon
  (`focus_boundary_needed`).
- **For any d up to 1/8 (12.5%)**, the phoenix stays at least as strong as an ordinary player (`phoenix_at_least_player`).
- At d = 5%: 80% focus, 1.6× to 1.76× (`focus_example`).

So any d between about 2.3% and 12.5% gives the balance you described. 5% is my suggestion.

- **Q4 (permission).** Replace the Round 5 "phoenix ≥ 10% above everyone" rule with this focus cost? If yes, which d (5%
  suggested)?
- **Q5.** You mention "focusing on two different elements". Round 5 says ordinary dragons have at most one active element.
  Should an ordinary dragon also be able to run two elements (and pay the 95% focus), or is multi-element phoenix-only?

## 3. The tax at 2%, 3% and 5%: the numbers you asked for

The coins are whole, and rounding favours the player (fractions are dropped from the tax).

**What doesn't change with the rate (proved for any whole-number rate):**
- Taking the tax **from the total never collects less** than taking it from each contribution (`skimEachAt_le_skimTotalAt`).
- The difference is **less than one coin per contribution** (`skimTotalAt_lt_skimEachAt_add`).
- Nothing is created or lost in a sale: seller's part + tax = price (`sale_split_conserves`).

**What does change:**

| | 2% | 3% | 5% |
|---|---|---|---|
| Seller keeps | 98% | 97% | 95% |
| Tax-free below (proved, `taxAt_eq_zero_iff`, `thresholds`) | 50 coins | 34 coins | 20 coins |
| Two players × 49 coins (pool 98): from the total | 1 | 2 | 4 |
| Same, from each player instead | 0 | 2 | 4 |
| Ten players × 19 coins (pool 190): from the total | 3 | 5 | 9 |
| Same, from each player instead | 0 | 0 | 0 |
| On a 1,000-coin sale | 20 | 30 | 50 |

(The example rows are checked in Lean: `example_49_49`, `example_ten_19`, `example_1000`.)

**Plainly:** a higher rate makes the rounding matter less, because fewer small amounts fall under the tax-free line.
Rounding still never costs more than one coin per contribution. Your "from the total" rule is still the better one at every
rate: in the ten-player example, per-player taxing collects nothing at any of the three rates.

- **Q6.** Which rate do you want to lock: 2%, 3% or 5%? If money is effectively unlimited, **5%** gives the cleanest
  numbers (the tax-free line is 20 coins), but any of the three works. Should the creator royalty on sales use the same
  rate as the arena skim, or stay at 2%?

## 4. Names: all settled

- **Elder's Garden** = placeholder title for **The ORION Engine landing page**: the "loading screen" where users create an
  account and find the walkthrough, tutorial, media, explainers and dev-team shout-outs. Not locked.
- **ORION's Gate** = the **community projects page**. That answers my Q6 from last pass.

My Round 7 table had ORION's Gate as the landing page. That's now corrected. The five 💎 names haven't changed:

| Platform | Locked name |
|---|---|
| Project build | **The ORION Engine** (landing page placeholder: Elder's Garden) |
| Community projects page | **ORION's Gate** |
| Social community | **The Playground** |
| MMO | **The Orion Chronicles** |
| EDU hub | **The Ascent** |

The ORION (Summary) page still lists Elder's Garden as a fourth platform and leaves out ORION's Gate. It needs an update
when you have time.

## 5. Master Index started

`ORION_MASTER_INDEX.md` is in the files. It has:
- the platform names;
- a glossary skeleton (orbs, nodes, matrix, KRION, the Zoo counts), with blanks where a ruling is still missing;
- every ORION page I've read, with its round and transcript;
- every reply file;
- every proof file;
- Ryan's packages with their check logs.

I'll keep it up to date each round, alongside the roster.

## 6. Still open from last pass

- **RD pool** (`ROUND_SEVEN_FOLLOW_UP.md` §4): "10 times the reward", "subdivided 2%", the overflow rule, "Dove team".
- **Loom archive:** should I seed one with the locked rulings as world facts?
- **Matthew's three Zoo checks**, gallery wattage steps and stage names, and the earlier `FOLLOW_UPS.md` §5 items.

## 7. All questions this pass

1. **Q1.** Full dragon matrix: does a new orb replace an existing one?
2. **Q2.** Do the 64 character orbs fill 64 of the 144 dragon nodes, with the other 80 for dragon-only skills? Does the
   auto-adjust start when you get a dragon, or only once all 144 are filled?
3. **Q3.** Is the KRION meter challenge once per orb, or once per matrix?
4. **Q4 (permission).** Replace the Round 5 phoenix +10% rule with the focus cost? Which d (5% suggested)?
5. **Q5.** Can ordinary dragons run two elements at a focus cost, or is multi-element phoenix-only?
6. **Q6.** Lock the tax at 2%, 3% or 5%? Same rate for the sale royalty?
