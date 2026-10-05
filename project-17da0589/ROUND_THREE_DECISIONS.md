# Round Three — your decisions, written as rules

This file records the decisions you made after reading the Round Three compilation review
(`SPAGHETTI_ROUND_THREE_COMPILATION_REVIEW.md`). Each one is written as a rule a coder can build.
Where a rule has logic that can be checked, it is stated and proved in
`RequestProject/RoundThree/Decisions.lean`. That file builds with no `sorry` and uses only the standard axioms.
As before, these proofs are about the **rules as written**. There is no game code yet.

---

## 1. The decay-raid question: where it came from and where the "fix" is

> **Update.** The rule below is for encounters (raid parties, boss fights). For *decaying structures* the designer has since
> accepted a version where the owner loses nothing and raiders gain only through effort. See `FOLLOW_UPS.md` §1.

You don't need to apologise. Here is the short version:

- **I didn't change any game code, and there is none in this project to change.** Nothing I did makes
  components go back to anyone automatically.
- **The rule you dislike came from the design session in your Round Three Google Doc** (the long conversation
  under "Compilation Assessment"). That text said two things about a decaying structure that other players destroy:
  1. "the original player does not lose anything", because the whole build packs itself back into their vault; and
  2. the raiders harvest the raw materials attached to it (steel from the walls, copper from the wiring).
- **I flagged that combination as a loophole.** Taken together, the two lines give the owner everything back
  *and* give the raiders free materials. Two friends could repeat this forever and make unlimited materials with no effort.
- **What I called a "fix" is a sentence of rule text, not code.** It is in the review file, section 3.1. It says
  *what the owner gets back + what the raiders take must be no more than what went into the build*. The proof that this
  closes the loophole is `conserving_raid_bounded` in `RequestProject/RoundThree/Compilation.lean`.

**Your rule replaces mine and is stricter:**

> Components expended in an encounter are used up. They are never moved back automatically to the aggressor or to
> anyone else. You may obtain unlimited amounts of something, but every gain costs effort. There is no quick fix to
> unlimited anything.

What is proved about it (`Decisions.lean`):

- `runSteps_le`: say each action can earn at most a fixed amount per unit of effort. Then after any sequence of encounters,
  holdings are at most *starting holdings + rate × total effort*. Spending components never refunds them.
- `no_effort_no_gain`: with zero effort, no sequence of encounters ever increases holdings.
- `effort_needed`: reaching any target amount needs a matching amount of effort.
- `unlimited_with_effort`: unlimited amounts are still reachable, but only by repeating effort.
- `auto_return_unbounded`: the rejected version ("spent components come back automatically", plus any side gain)
  gives unlimited holdings for zero effort. This is the loop your rule removes.

**The same rule should be applied to three other places in the design doc:**

- "Unused gifts mutate into high-tier loot." A mutation can change the *kind* of material. It must not add value.
  *(Superseded: unused gifts now become an XP boost instead, see `FOLLOW_UPS.md` §2.)*
- Deconstruction (item → materials + an orb). It must give back no more than it cost to craft the item.
- The self-demolish refund (90 % back). This already obeys the rule, because a 10 % loss means it can't be looped for profit.

---

## 2. Gifts

**The rule:**

- Each player has **one active player gift** and **one active team-member gift**.
- Sending more gifts is **never blocked**. Sending a gift while the matching slot is already full **shows a warning**.
- This replaces the earlier "cannot submit another until the previous one has been used" lock-out.

What is proved:

- `activeCount_le_two`: no player ever has more than two active gifts.
- `party_active_le`: a party of *n* has at most 2*n* active gifts at once.
- `sendGift_total`: no gift is ever refused or lost. Every gift sent is recorded.
- `sendGift_warns_iff`: the warning appears **exactly** when the matching slot is already full.
- `sendGift_no_warning_active`: with no warning, the gift is active straight away.
- `sendGift_warning_keeps_active`: an extra gift never knocks out the active one.

**Confirmed since (see `FOLLOW_UPS.md`, §2):** extra gifts wait in a queue, queued gifts can be interchanged, gifts are never returned, and unused gifts become an XP boost. *Original question:* I assumed an extra gift **waits in line** until its slot frees up. The other
possibilities are that it replaces the active gift, or that it goes back to the sender. Tell the coders which one you want.
Whichever you choose, apply rule 1 to waiting gifts too: they must not turn into extra value.

---

## 3. Levels: removed

**The rule:** there is no leveling system. A character is a **base archetype, chosen at the load screen**, plus
**skills and abilities**. Every unlock that used to depend on a level number now depends on skill.

### What the leveling version added that now needs fixing

These are the places where my review recorded levels being added to the Round Three design. The coders should also
search the build doc for the word "level" to catch anything else.

| What was added with levels | What to do now |
|---|---|
| The 1–100 level scaffold that came with the archetype system | Drop the scaffold. Keep the archetypes, chosen at the load screen only. |
| "How to spread the 64 nodes over 100 levels" (I proposed a schedule last round) | **Withdrawn.** I deleted the schedule and its proof. Unlock each node by skill progress in that node's area instead. |
| Shout/recruit radius "unlocked at specific levels" | Tie it to the social/governance skill, as your Summary already says. |
| "Playing with lower-level players reduces the loot scale" (group scaling) | Change the wording to "lower-*skill* players". The arithmetic doesn't change. |
| Gemini's 144-level civic tier | You already rejected it. Leave it out. |
| Mike's action item "deprecate all leveling code" | It was out of date last round. It is **correct again**, so put it back on his list. |
| Mentoring described as levelling a mentor down | Describe it as capping the mentor's effective skill at the mentee's (see section 4). |
| Any "level 100" wording in the Summary | Change it to a skill or archetype description. |

The tabletop "Sanctuary Defense" mode in `GAME_LORE_CODEX.md` used to give *threats* a "level" (a d6 roll). That described monster
strength, not player levels. It is now called a "threat rank" ("tier" was already taken by the d20 roll), so the word "level" no longer appears in the game rules.

---

## 4. Solo players, mentoring and encounter scaling

**The rule:**

- Quests and encounters scale to the experience and abilities of the characters in them.
- A solo player faces their own skill.
- A player could lower themselves by hand, but it gains them nothing. Mentoring is the proper way to play with a less experienced friend.

What is proved (encounter difficulty is modelled as the party's mean skill, and reward as a fixed rate × difficulty):

- `solo_difficulty`: a solo player faces exactly their own skill. This fills in the solo case the 50/50 rule left undefined.
- `manual_lowering_no_benefit`: the reward per unit of difficulty is the same whatever skill you bring, so lowering
  yourself only lowers your reward.
- `mentoring_matches_mentee`: when the mentor's effective skill is capped at the mentee's, the pair never faces a harder
  encounter than the mentee would alone.

---

## 5. Two different resets

**The rules:**

- **Account hard reset.** The whole account goes back to exactly what a first-time player sees on first login. Only the
  real-life account metadata is kept.
- **Optional character reset.** A separate function, chosen by the player, that resets one character and leaves the rest
  of the account alone.

What is proved:

- `hardReset_is_first_login`: after a hard reset the account is exactly a first-login account.
- `hardReset_forgets`: two accounts with the same real-life metadata look identical after a hard reset, whatever they did before.
- `hardReset_keeps_realLife`: the real-life metadata is kept.
- `hardReset_idem`: doing a hard reset twice is the same as doing it once.
- `characterReset_keeps_others`: a character reset leaves every other character untouched.
- `resets_differ`: the two resets really are different functions.

**Settled since (see `FOLLOW_UPS.md`, §4):** there is no reclaim; on a hard reset every blueprint the player crafted has their tag removed and becomes an anonymous contribution. *Original note (review §1, item 8):* If a hard-reset player is allowed to reclaim their old blueprints "with zero
mutations", that reclaim publicly shows who they used to be. This contradicts the hard reset's "like a first-time player"
promise. Either make reclaims look the same as ordinary reverse-engineering, or say that a reclaim gives up the anonymity.

---

## 6. Contributor credits at launch

**The rule:**

- All contributors are identified before launch.
- A contributor who has set up a profile is credited by name in the opening ceremonies summary and on the overall game board.
- A contributor without a profile is credited as an **anonymous contributor** until they reach out for a correction.

What is proved:

- `creditList_length`: every contribution gets exactly one credit, so nobody is left off.
- `anonymous_iff_no_profile`: someone is shown as anonymous **exactly** when they have no profile.
- `correction_effect`: after a correction, that person is credited by name and nobody else's credit changes.

**A suggestion.** Identify contributors from records: submissions, commit history and people's own claims. Don't try
to work out who an unnamed contributor is from their writing style. Your rule then also matches the privacy baseline:
anyone who wants to stay anonymous simply doesn't set up a profile.
