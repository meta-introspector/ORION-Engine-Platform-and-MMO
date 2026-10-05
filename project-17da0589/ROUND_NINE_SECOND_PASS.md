# ORION Round 9, second pass: your notes on the R9 reply

**Date:** 2026-10-04. **Page:** ORION R9 Live (page version 236). Text copy: `orion/r9b/PAGE_TRANSCRIPT.md`.
**New proofs:** `RequestProject/RoundNine/SecondPassNine.lean`. Everything builds with no `sorry` and only Lean's standard axioms.
"Proved" means the rule as written has the stated result. There's no game code yet.

**Spaghetti check (your standing request):** ✅ this session **had** new spaghetti: Earth or Mars as home world, in-game
instances of the Elder's Garden and the Playground, access from any device, the Meta Round 2 ideas, and about 15 notes
written into my reply. Nothing was skipped. I'll keep doing this check: if you come back with a repeat page and no new
spaghetti, I'll say so at the top.

I've kept new questions to a minimum, as you asked. Where something was unclear, I picked the most likely reading,
labelled it **"Assumed"**, and moved on. Correct it only if it's wrong.

---

## 1. Your notes, one by one

| Your note | What I did |
|---|---|
| 👍 3% tax | Locked. |
| 💎 Mutated schematics: the creator has no control, **except** when the DEV team uses their original build as a permanent part of the game. Then they decide: use it, or leave it on the open market | New 💎 rule, proved (§2). Replaces my R9 reading that "mutated = DEV team decides". |
| 😜 Editing your own open copy is free game | Agreed. That's how the 💎 lock was built: only the **official** record is protected. |
| ✋ Any orb can go in a **node slot**. Only gold-locked level-100 orbs go in the **64-grid matrix**. An orb only levels up while active in a node | Orbs v4, proved (§3). My R9 version was wrong: it let only level-100 orbs into any slot. |
| 🙋‍♀️ "Crafting, deconstructing and trading never create levels": too vague | Plain explanation in §3. |
| 👈 Marksman one-shots can earn a free gold-locked orb | Added and proved (§3). The 6,400 figure now has an exception for these. |
| 🤷‍♀️ Dragon stacking: one primary element, player's choice; the primary is the measuring stick, as fire is for the phoenix; "3 to 1.75 for each stacked skill. Does that work?" | **Yes, it works.** §4 explains why in plain words. |
| ✋ Private skybox doesn't mean owner-only; the owner can grant access to others, in tiers | Skyboxes v3, proved (§5). |
| 🤦‍♀️ Phoenix numbers are frustrating | Plain version in §4, no formulas. |
| 🤷‍♀️ RD pool | **Option A adopted** (shared pots: 3% for creators, 30% for DEV collaborators). Proved earlier: it never uses more than 33% of the pool. Plain meaning in §6. |
| 👻🌪️🏍️ ORION's Gate mockup | Noted: still in progress. |
| 🤦‍♀️ "the doves" | Dictation for **the DEVs**. Recorded everywhere. |
| 🍝🧠 KRION 25% | **Per slot.** It boosts only the orb in that slot. Proved (§3). |
| ✋ Stacking question already covered | Agreed. Your answer above settles it. Question closed. |
| 🙋‍♀️ Do chat links update as the chat continues? | §7. |
| 🍝🧠 Earth / Mars, in-game platform access, any device | Recorded as rules (§8). |
| Meta Concept Art Round 2 ("he came with ideas too") | I couldn't open it (§8). |

---

## 2. Who controls a player's design (💎, proved)

Three things can happen to a player's design:

1. **Someone changes the original itself**, including code it put into the build.
   - An active creator gets the final say.
   - If they're inactive, the whole DEV team must agree.
   - Then it goes to the Galactic council, then a human.
2. **The DEV team wants it as a permanent part of the game**: galactic property, the starting worlds, or anything added later.
   - An active creator must say yes. If they say no, it stays theirs on the open market.
   - Then the council and a human.
3. **Someone makes a mutated schematic from it.**
   - The creator has no control.
   - The original stays exactly as it was.

**Proved:**
- an active creator's "no" stops both 1 and 2 (`creator_no_blocks_official`);
- 1 and 2 always need the council and a human (`official_needs_council_and_human`);
- an inactive creator's design needs every DEV to agree (`inactive_needs_all_devs`);
- a mutation needs nobody's permission (`mutation_free`) and never changes the original (`mutation_keeps_original`);
- over any number of requests, if the creator stays active and never says yes, their design is never changed and never
  taken into the permanent game (`work_protected_v2`).

**Assumed:** for case 2, an inactive creator's build follows the same fallback as case 1, where the whole DEV team decides.

---

## 3. Skill orbs, version 4 (proved)

**The rules now:**
- **Node slots** take any orb.
- **The 64-grid matrix** takes only gold-locked (level 100) orbs. A full matrix opens the dragon grid.
- An orb **gains levels only while it's active in a node slot**. You couldn't get an orb to 100 without slotting it first.
- **Marksman one-shots:** an extreme marksman who hits the tiny target earns a free gold-locked orb.
- **KRION:** the 25% bonus is per slot. It applies only to the orb in that slot.

**Proved:**
- training an orb that isn't in a node slot does nothing (`train_needs_node`);
- a non-gold orb can't go into the matrix (`toMatrix_needs_gold`), so the matrix only ever holds gold orbs, whatever
  players do (`matrix_always_gold`);
- KRION on one slot never changes any other slot (`krion_other_slot_unchanged`), and the total extra is a quarter of the
  KRION-slotted orbs' values (`krion_total`).

**"Crafting, deconstructing and trading never create levels", in plain words.** Think of skill levels as water:
- training is the tap: each training step adds one level to one orb;
- crafting makes an empty bottle (a level-0 orb);
- deconstructing pours a bottle away;
- trading, selling or gifting hands a bottle to someone else.

None of those last three adds water. So the levels in the whole world can only come from training. **Your marksman rule
adds a second tap**: each one-shot reward adds one full gold orb (100 levels).

**What that means (proved):**
- every level in the world came from training or from a marksman reward (`levels_from_training_or_marksman`);
- a full 64-orb matrix takes **at least 6,400 training steps, minus 100 for each marksman reward**
  (`full_matrix_cost`);
- with no marksman rewards, that's exactly the old 6,400 (`full_matrix_cost_no_rewards`).

**Assumed:** "level one, level two" means a marksman can earn free gold orbs for the first two levels, and the rest are
levelled up in the wild. On that reading, a full matrix still takes **at least 6,200 training steps**
(`full_matrix_cost_two_rewards`). If a marksman can earn more, the floor drops by 100 for each.

---

## 4. Dragons and the phoenix, in plain words

**Your stacking rule:**
- an ordinary dragon has **one primary element**, chosen by the player (in a safe zone, meditating, before heading out);
- the primary is the measuring stick, the way fire is for the phoenix;
- stacked elements run at **3 to 1.75** against the primary.

**Does it work? Yes.**

Picture a scoreboard where an ordinary dragon running one element scores **100**.
- **Phoenix:** 110 with fire alone. It slips a little for each extra element and lands on 100 with all five. **It never
  goes below 100.**
- **Ordinary dragon under your rule:** the primary stays at 100. Each stacked element is about **58** (1.75 out of 3).
  Nothing ever goes **above** 100.

So the phoenix is always at least as strong, element by element. Proved (`ratio_table`, `ratio_capped`,
`phoenix_beats_ratio`).

**Why it's safe even if you tune the numbers later:** any stacking rule works as long as no ordinary dragon's element
goes above 100. That's proved too (`phoenix_ge_any_capped`). You can change 1.75 to anything up to 3 and the phoenix
stays on top.

**Assumed:** "3 to 1.75" means each stacked element is 1.75/3 as strong as the primary. If you meant something else
(for example, the primary losing between 1.75 and 3 points for each stacked element), it still works, for the same
reason: nothing goes above 100.

---

## 5. Skyboxes, version 3 (proved)

Private now means **"the owner decides who gets in"**. The owner gives each guest an access **tier** (for example: 0 =
visit, 1 = use the workshop, 2 = build). Public, level, archetype and build settings stay, and can still be combined.

**Proved:**
- the owner can do everything in their own skybox (`owner_full_access_v3`);
- a guest with a given tier can do everything at that tier or below (`guest_tier_mono`, `private_guest_gets`);
- someone not on the guest list can't get into a private skybox (`stranger_kept_out`);
- a private skybox with no guests is owner-only (`private_no_guests`);
- only the owner or a DEV can change the settings or the guest list (`setAccess_unauthorized`).

The R9 result "private means only the owner" is retired. It now holds only when the guest list is empty.

---

## 6. RD pool, option A, in plain words

When a project earns money for the RD pool:
- all the original creators **share one 3% slice**;
- all the DEV collaborators **share one 30% slice**;
- the other 67% (at least) stays in the pool.

However many people join, the two slices never take more than 33%. That's already proved (`optionA_total_le`).
If it ever clashes with something else, tell me and I'll re-check.

---

## 7. Do chat links keep updating?

- **Notion page links (like this one):** live. I always see the page as it is when I open it, so your additions show up.
- **AI chat share links (Meta AI, ChatGPT and similar):** usually a snapshot of the chat at the moment you made the
  link. Messages added afterwards usually don't appear; make a new link to include them. I can't confirm exactly how
  Meta AI handles this, so check by opening your own link after adding a message.

---

## 8. New spaghetti recorded

- **Home world:** a player's original launch-character build decides whether their home world is **Earth or Mars**.
  Earth is where things start, which fits the Kronos/Orion balance. Mars is a new civilisation the players design.
- **Elder's Garden and the Playground have in-game instances**, like the Ascent. Players can reach each platform two ways:
  - directly, from the platform itself;
  - from inside the game, by **travelling to that platform's location in the main hub**.
- **Devices:** the platform should be reachable from any publicly routed device: phone, computer or console.
- **Meta Concept Art Round 2:** I couldn't open it. Meta AI share pages need their app or a sign-in to show the chat, so
  I got only a blank shell page. That means I couldn't run "his ideas" through. To get them in, paste the ideas as text
  on the page, or add screenshots.

---

## 9. Still open (carried over, nothing new added)

- R8 Q6: is ORION's Gate the landing page, the projects page, or both?
- R8 Q7: AI companions.
- R8 Q9: skin swapping, and who crafts bioengineered skins.
- R8 Q10: the story council tick-box.
- R9 G4–G6: how long until someone counts as inactive; who the final human is; what the DeepSeek headmaster can decide for POLY.
- R9 O3: raw materials from deconstructing, and the cost of an empty orb.
- R9 S1–S2: can DEVs enter private skyboxes; is the quest/key gate still an option. (S1 is now: does a DEV need a guest tier?)

Answer any of these whenever you like. None of them blocks the work above.
