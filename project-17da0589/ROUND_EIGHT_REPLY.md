# ORION R8 Live: first reply (Round 8)

Thanks for making the page public. It opens now. I read all of it: the links at the top, your answers written under my
pasted R7c and R7d replies, my access note, the "Oops" line, and the images.

I also re-read every page the top links point to:

- **"The Orion Chronicles Summary"** now links to the **ToC X-Summary** page. That answers Q9 (yes, that's the page for
  the heading).
- **ToC X-Summary, ORION (Summary), ORION SoB R6** and **ORION R7 💎** have the same text as last pass. The R7 page only
  gained the link under the Chronicles heading.
- **"Deep sea conversation"**: I took this to be the second DeepSeek chat from the R7 page (the one where Elder's Garden
  became the ancestral tree). Its text copy is `orion/r7d/SHARED_CHATS_TRANSCRIPT.md`.

**Files from this pass**

- **Text copy of R8 Live:** `orion/r8/PAGE_TRANSCRIPT.md`.
- **New proofs:** `RequestProject/RoundEight/OpeningEight.lean`. The whole project builds with no `sorry` and only
  Lean's standard axioms.
- **Gameplay summary you asked for:** `GAMEPLAY_MECHANICS_SUMMARY.md`. It covers every gameplay mechanic ruled so far,
  except dragon egg hatching. I'll keep it updated every round.
- **Updated:** `ORION_RUNNING_ROSTER.md` (changes marked **[R8]**), `ORION_MASTER_INDEX.md` and `CODE_MANIFEST.md`.

**Round 7 is closed** (your note: "locking around seven and moving onto around eight"). Q7 is answered. From now on
I'll treat R8 Live as the working page.

---

## 1. Your answers, and what I did with each

| Question | Your answer (short) | What I did |
|---|---|---|
| SoB link label; empty Chronicles heading | Both fixed | Checked: both are fixed ✔ |
| Player level ≤ 64? | 🌪️ No cap on gold-locked orbs. A player needs 64 of them to fill the matrix grid, then **meditates to reach level 65 and becomes a dragon rider** | **Corrected and re-proved** (§2.1). The R7c result "level is never above 64" is replaced |
| Q1–Q3 (full matrix, etc.) | 🍝🧠 Surplus gold-locked orbs can be **kept** for future builds or **exchanged at 50%** for Kronos and Orion energy | Proved (§2.1). The 64→144 mapping and the KRION challenge (rest of Q2, Q3) are still open |
| Q4 Phoenix | 💎 Fire alone beats every other fire dragon; phoenix fire **never drops below** an ordinary dragon at the same skill; adding elements narrows the gap | **Your rule needs no permission step.** It keeps the Round 5 +10% and adds a taper (§2.2). The 5% focus-cost proposal is withdrawn |
| Q5 Ordinary dragons | 💎 Only the phoenix runs all five at full power. Ordinary dragons may **stack elements by skill level, in the same order** | Proved in general (§2.2); thresholds and the order still needed |
| Q6 Tax | 🪩 **3% across all taxable incomes** (Tesla 369) | Locked at 3% and proved (§2.3) |
| Names / Elder's Garden | 🪩🎉🐋 See the DeepSeek chat: family tree and ultimate ceremony board | Recorded (§5) |
| ToC skybox wording | 💎 There are also **open-access** and **level-specific** skyboxes | Proved (§2.4) |
| Exhaustive gameplay summary | Please keep one (minus dragon egg hatching) | Done: `GAMEPLAY_MECHANICS_SUMMARY.md` |
| Skins | 💎 Special skins can be **crafted** with enhancement / skill / armour effects by bioengineering | Proved (§2.8) |
| Never stuck | 💎 Players level just by being in the world; raids, healing guilds; a quest **generator**, and a **search** for quests at your level | Proved (§2.5). The "infinite catalogue" condition is no longer needed |
| Story gate | 💎 All genres can be labelled; reworks re-pass the council; real stories must cite sources; narratives can attach social posts; run it like a publishing company | Proved, version 2 (§2.6) |
| POLY | 🪩💎🐋💎🪩 | Recorded as **💎-locked** |
| AI companions | DEVs can generate personal AI friends as any playable character and bring them in | Recorded; questions in §6 |
| Elder's Garden meaning (Q10) | 💎 ORION's Gate landing page → Elder's Garden ancestral tree and ultimate celebration capstone | Recorded (§5); one detail to confirm |
| Summary page out of date | 👍 Don't worry about it now, but don't let you publish without updating | Added to a **before-publishing checklist** in the roster |
| Loop order (Q12) | 👍💎 Engine → socials → MMO → education → projects → ancestral tree, feeding back: the toroidal engine | Proved (§2.7) |
| 13-level gauntlet (Q13) | 👍 Documents to come once Google is sorted | Waiting |
| RD pool and Loom archive | 🍝🧠👻🌪️ "Give me a thorough explanation" | §3 and §4 below |

---

## 2. New proofs (`RequestProject/RoundEight/OpeningEight.lean`)

"Proved" means the rule as written in the Lean model has the stated consequence. There is no game code yet, so none of
this is a proof about a running game.

### 2.1 Skill orbs, corrected

The model: a player has some number of gold-locked orbs (no maximum), a "dragon rider" flag, and energy from
exchanges.

- **No maximum** on gold-locked orbs (`gold_unbounded`).
- **Orbs alone stop at level 64.** A player who only gold-locks orbs is at level min(orbs, 64), and is never a dragon
  rider (`orbs_alone_level`).
- **Level 65 comes from meditation.** Meditating makes you a dragon rider exactly when you're in a safe zone with at
  least 64 gold-locked orbs (`meditate_rider_iff`).
- **A dragon rider always keeps the 64-orb grid.** Whatever a player does, a rider owns at least 64 gold-locked orbs
  (`rider_needs_grid`). This holds because I modelled exchanges as **surplus only** (orbs beyond the 64), which is how I
  read "hold onto them for extra building or exchange them". Q1 asks if that's right.
- **The 50% exchange** gives at least half the orb's value. Odd values round **up**, in the player's favour, as you
  ruled in Round 4 (D1) (`exchange_energy_bounds`).

### 2.2 Phoenix taper, and ordinary dragons stacking elements

Your rule is: fire alone is stronger than any other fire dragon, phoenix fire never drops below an ordinary dragon, and
extra elements shrink the lead. The simplest rule that does exactly that:

> With **k** active elements, a phoenix works at **1 + (5 − k)/40** times an ordinary dragon of the same skill, in
> each element.

| Active elements | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| Phoenix vs ordinary dragon | **110%** | 107.5% | 105% | 102.5% | **100%** |

Proved:
- one element = 1.1×, the Round 5 rule (`phoenixMult_one`);
- never below 1× (`one_le_phoenixMult`);
- five elements = exactly 1×, "all five at full power" (`phoenixMult_five`);
- more elements never raise it (`phoenixMult_antitone`).

This is the R7c focus cost with **d = 1/44**, the exact cut-off I found then (`phoenixMult_eq_focus`). So the 5%
proposal is withdrawn. Your rule picks the boundary value. Q2 asks you to confirm the 2.5-points-per-element steps.

**Ordinary dragons** unlock extra elements one at a time, in a fixed order, as skill grows. Proved:
- what's unlocked is always the first few elements of that order (`unlocked_prefix`);
- more skill never loses an element (`unlocked_mono`);
- if stacking costs an ordinary dragon *any* power per element, a phoenix running the same number of elements is
  stronger in each one (`phoenix_beats_stacked_dragon`). That's "only the phoenix runs all five at full power".

**This replaces a Round 4 rule** (D4: "no other dragon can ever have two elements active",
`other_at_most_one_active`). Since this is your own ruling, I've marked the old one superseded. Q3 asks for the order,
the skill thresholds, and the power cost.

### 2.3 Tax locked at 3%

- An amount pays no tax **exactly when it's below 34 coins** (`tax3_free_iff`).
- The 3% column of the table is checked in Lean (`tax3_examples`): 49 + 49 → 2 coins either way. Ten payments of 19 →
  5 from the total, 0 per payment. 1,000 coins → 30.
- Taking it from the total never collects less than per payment, and the gap is under a coin per payment (R7c, any
  rate).

Q4 asks which incomes "all taxable incomes" covers.

### 2.4 Skybox kinds

Three kinds of entry: **open access** (anyone), **level-specific** (from a given level), and the **Round 3 gate** (the
quest-earned escape, or a key). Proved:
- open always lets you in (`canEnter_open`);
- level-specific lets you in exactly at or above its level (`canEnter_level_iff`);
- **crafting still never opens a gated skybox**, however much you build (`crafting_never_opens_gated`).

### 2.5 Never stuck, without needing an endless catalogue

- **Search is exact.** It returns a quest exactly when the quest is in the right category, unfinished, and completable
  at your skill (`mem_search_iff`). No false hits, no missing quests.
- **A generator always works.** A generated quest has a new ID (`generator_fresh`) and is pitched at your skill, so you
  can complete it (`generator_completable`).
- **Just playing is enough.** If every interaction (environment, raids, healing guilds) gives at least one skill
  point, then after R interactions a beginner meets any skill requirement R (`interaction_unlocks`). So every epic gate
  eventually opens with no quests at all.

### 2.6 Story gate, version 2

- **Any genre label** (real, lore, narrative, family history, and so on).
- A genre can be marked **"needs sources"** (real stories). Such a story can't be published without at least one cited
  source.
- **Reworking** a published story takes it down; the new version must pass the gate again against everything else.

Proved, for any sequence of submissions and reworks:
- every genre's published record stays consistent (`run_canon2_satisfiable`);
- every published real story cites a source (`run_sourced`);
- a reworked story is only back up if it re-passed (`rework_requires_gate`).

The R7d limit still holds: the check confirms **consistency**, and that sources are attached. It can't confirm a source
is genuine. That's the human, publishing-house part.

### 2.7 The toroidal loop

Engine → socials → MMO → education → projects → ancestral tree → back to the engine. Proved:
- this is the default path from the engine (`default_path`);
- six steps bring every layer back to itself (`next_six`);
- from any entry point, every layer is at most five steps away (`reach_all`). "Enter at any level".

### 2.8 Crafted special skins

A skin now has a **look** (cosmetic) and may carry a **bioengineered enhancement**. Proved: an ability formula ignores
the look exactly when it uses only species, body, archetype, the skin's enhancement and traits
(`lookBlind_iff_factors`). So "skin is cosmetic" becomes "**a skin's look** is cosmetic". The ToC X-Summary line could
say: "Skin looks are cosmetic; crafted bioengineered skins can add enhancements."

---

## 3. The RD pool question, explained

**What the RD pool is.** It's the re-distribution pool for schematics. When the DEV team uses a schematic and it earns
a pool, part of that pool goes back to the players behind the schematic. Your rule from R7, word for word:

> "Any schematic that is in use by the Dove team that gains a pool the original schematic creator will automatically be
> allocated at a subdivided 2% of total pool re-distribution … If a player directly worked with the DEV team on a used
> schematic, they will be given 10 times the reward from that schematics RD pool"

**What's settled:** an original creator gets 2%, and a player who worked directly with the DEV team gets "10 times the
reward".

**Why there's a problem.** If "10 times" means 10 × 2% = **20% each**, the shares can add up to more than the whole
pool. In R7 I proved the shares fit exactly when **2 × (number of creators) + 20 × (number of DEV collaborators) ≤
100**. Example, a 1,000-coin pool:

| Who | Share | Coins |
|---|---|---|
| Original creator | 2% | 20 |
| 6 DEV collaborators | 20% each | 6 × 200 = 1,200 |
| **Total owed** | **122%** | **1,220 from a 1,000-coin pool** |

The rule as written promises coins that don't exist. Something has to give. These are the four questions:

1. **"10 times the reward" — 10 times what?**
   - (a) 10 × the creator's 2% = 20% each. This is how I read it, and it causes the overflow.
   - (b) 10 × whatever an ordinary contributor gets, with "ordinary" defined separately.
   - (c) One 20% collaborator share, split among all collaborators.
2. **"Subdivided 2%": shared or each?** If three original creators' schematics feed one pool:
   - shared: they split one 2% (about 0.67% each, 2% total);
   - each: they get 2% each (6% total).
3. **What happens if the shares pass 100%?** Two standard fixes:
   - **Cap:** at most 4 collaborators on one schematic, alongside one creator (2 + 4 × 20 = 82%; 5 would make 102%).
   - **Scale down:** everyone keeps the same proportions, shrunk to fit. I proved scaling never pays out more than the
     pool (`rdScaled_total_le`). The 122% example becomes creator ≈ 1.64% and each collaborator ≈ 16.39%, exactly 100%
     in total (`rdScaled_example`).
   - A third option is option (c) above, which can never overflow.
4. **"Dove team" = DEV team?** I assume this was a dictation slip.

**Also worth deciding at the same time:**
- Who gets what's left of the pool after the creator and collaborator shares (the DEV team? the arena? reconstruction?).
- Whether your new 3% rule changes the RD 2%. I've assumed it **doesn't**. The 2% is a share of a pool, not a tax,
  but say if you meant it to.

**What I need from you:** one line each for 1–3 (and 4 if I guessed wrong). Then I'll prove the final rule and add a
"payout preview" spec that warns before any pool is over-allocated.

## 4. The Loom archive question, explained

**What Loom is.** Ryan's *Loom / Mythos Continuity Kernel* (v0.2.0, attached on R7 Live) is a lore-consistency tool. It
keeps an **archive of world facts**, for example `phoenix.multiplier_one_element = 1.1`. It also keeps **contracts**:
rules like "this key must equal X" or "must not equal Y". Any new fact that breaks a contract is **rejected**, and the
archive stays unchanged.

In R7b I ran his package: 22/22 hashes, 64/64 tests, 10/10 mutation probes all passed. I also proved his contract check
is **exact**: it accepts a set of facts exactly when some world could make them all true at once.

**What "seeding the archive" would mean.** I would write your locked rulings into a Loom archive as world facts and
contracts, for example:

- platform names (The ORION Engine, ORION's Gate, The Playground, The Orion Chronicles, The Ascent, POLY);
- tax = 3%; skill orbs cap at 100; level 65 = dragon rider by meditation;
- phoenix taper 110% → 100%; council 4/5 with three strikes and a 7-day cool-off; 10-minute aggro;
- and so on.

**Why it's worth doing:**
1. **One source of truth.** The stale ORION (Summary) page has already been repeated back to you by another assistant.
   An archive that devs, AIs and pages are checked against stops old rulings spreading.
2. **It's the engine behind the Elder's Garden story gate.** The gate in §2.6 uses exactly this check (each genre's
   published record is a Loom contract). A seeded "canon" genre would let lore stories be checked against the official
   rules too.
3. **Change tracking.** Each change to a locked ruling becomes a new versioned fact, with a hash checkpoint, matching
   your "names change only by approved proposal" rule.

**Limits (so expectations are right):**
- Loom checks **consistency**, not truth or good design.
- It's a local Python tool, not connected to any game or page yet. Someone has to keep the archive updated after each
  round. I can do that each pass if you want.
- I don't have Ryan's package files in this project right now. To produce a seed that his tool loads directly, I'd
  need the ZIP still attached on R7 Live, or you could re-attach it on R8.

**What I need from you:** yes or no. If yes, should I include everything that's 💎-locked, or only the platform names
and economy numbers to start?

---

## 5. Elder's Garden and the loop

How I've recorded your answer:

> **ORION's Gate** is the landing page. It leads into **Elder's Garden**: the ancestral tree and ultimate celebration
> capstone. There, each user's public accomplishments, storylines and family relations can be viewed. Between users,
> bubbles branch **outward** to friends and family. Inside a user's profile, bubbles branch **inward** through their
> accomplishments and publications. It may not literally look like a tree.

**One detail to confirm (Q6):** in R7c, ORION's Gate was the **community projects page** and Elder's Garden was the
**landing page**. Your new note puts ORION's Gate as the landing page and Elder's Garden as the capstone at the end of
the loop. I've written the new version into the index. Is ORION's Gate *both* the landing page and the projects page?

## 6. AI companions for the DEV team (new)

Recorded as a new feature: DEV team members can generate a **personal AI companion** as any playable character, design
its build together with it, and bring it into the game to help keep building. You also want an endgame dragon for the
matriarch AI.

Questions before I can model it (Q7):
- Does an AI companion follow the same rules as a player (orb cap, meditation, skybox gates, council votes)?
- Does it count as one of the DEV's characters? DEVs already get one character with unlimited resources.
- Can an AI companion publish, earn royalties, or sit on a council?

## 7. Images on R8 Live

- **Astronaut and cosmic whale in a bubble** (used three times as a divider). It's the same picture as on the R7 page.
  No text.
- **New title card** (after "Oops"): "THE ORION CHRONICLES" in gold, with fairies, mech soldiers, robot beetles,
  volcanoes, earth-dragons and a starry dragon, in a rainbow jewelled border with rune-like lettering. The spelling
  matches the locked name, and I can't see a stray second logo this time.

These are my descriptions of the images, not checked results.

## 8. Conflicts and open questions

**Things that conflict with earlier rulings**

- **Round 3 vs R8:** Round 3 said "the character can progress to 64 and no further until a dragon is unlocked". R8 says
  a player can gold-lock more than 64 orbs. Can extra orbs be gold-locked **before** the dragon-rider meditation, or
  only after? (Q1)
- **Round 4 D4** ("no other dragon has two elements active") is superseded by your stacking rule (§2.2).
- **ToC X-Summary** still says skin is cosmetic and mentions only one kind of skybox gate. Both need a one-line update
  before publishing. They're on the checklist.

**Questions**

1. **Q1. Orbs.**
   - Can surplus orbs be exchanged only beyond the 64-orb grid (as modelled)?
   - What is one orb worth in energy before the 50%?
   - Does the energy go to Kronos, Orion, or split between them?
   - Can orbs past 64 be gold-locked before level 65?
   - Is there anything above level 65?
2. **Q2. Phoenix taper.** Confirm the 110 / 107.5 / 105 / 102.5 / 100% steps.
3. **Q3. Ordinary dragons stacking.**
   - "Same order" means the same element order as the phoenix?
   - What is that order (fire first)?
   - At which skill levels does each extra element unlock?
   - How much power does each extra element cost an ordinary dragon?
4. **Q4. 3%.** Does it cover the sale royalty (2% → 3%) and the arena skim (2% → 3%)? Does it leave the RD pool's 2%
   alone?
5. **Q5. RD pool.** The four questions in §3.
6. **Q6. ORION's Gate.** Landing page, projects page, or both?
7. **Q7. AI companions.** The questions in §6.
8. **Q8. Loom archive.** Yes or no, and how much (§4).
9. **Q9. Skins.**
   - Does swapping off a bioengineered skin remove its enhancement?
   - Who can craft one (the biological skill line)?
10. **Q10. Story council.** "Only those tagged for interaction at the publisher's stamp" can bring a story to a council
    meeting. Is that a box the author ticks when publishing?

Still open from earlier: the 64 → 144 mapping and the KRION challenge (R7c Q2–Q3), the 13-level gauntlet (waiting on
your documents), Q14 (chat mappings as lore), Matthew's three Zoo checks, and the older items in the roster.
