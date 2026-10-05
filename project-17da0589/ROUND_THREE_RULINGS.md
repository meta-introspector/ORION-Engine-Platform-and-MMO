# Round Three rulings: demolition limits, PvP and aggro, the gift queue, and the rest

> **Update:** your follow-up answers are in `ROUND_THREE_CLARIFICATIONS.md`. That file settles both open questions
> below (forced demolitions do give resources, and aggro ends with a 10-minute timer). It also changes two rules here:
> the PvP switch can now be changed mid-encounter, taking effect when the encounter ends, and the Gold Lock is
> available at 64.

This file writes up your latest answers as rules a coder can build. The checkable parts are proved in
`RequestProject/RoundThree/Rulings.lean`. That file builds with no `sorry` and uses only the standard axioms.
As before, the proofs are about the **rules as written**. There is no game code yet.

Your "proved and yes, good wording" settles `FOLLOW_UPS.md` §1 (decaying structures: no loss for the owner,
gain only by effort). That wording is now final.

A note on wording: wherever "XP" comes up, I read it as **skill progress**. There are no levels.

---

## 1. Demolition: once a month, forcing it aggroes the local group

**The rules:**

- A structure can be set as a **deconstruction zone at most once per month**. This stops repeated demolitions
  being used for grief harvesting.
- Inside that month, a Skybox admin who wants it gone again has two choices:
  - let it **decay naturally**, or
  - **force** the demolition. That upsets the natural order and **aggroes the entire local group**: the
    demolishers can be attacked while they do it (see §2).
- A structure can also be set up as a **practice demolition**. It trains the demolition skills but gives
  **no resources**, like a training hologram.

**Proved** (`Rulings.lean`):
- `requestZone_forced_iff`: a request must be forced **exactly** when it falls inside the month after the last
  sanctioned zone on that structure.
- `sanctioned_spaced`: any two sanctioned zones on the same structure are at least a month apart, however the
  requests are timed.
- `sanctioned_count_bound`: over any stretch of `T` days, the number `k` of sanctioned zones satisfies
  `k × month < T + month`. That is about one per month, and no more, so sanctioned demolition is **not an infinite
  resource stream**.
- `practice_no_resources`: a practice demolition gives no resources and the same skill progress as a real one.
- `forced_demolition_aggro`: after a forced demolition, every player in that skybox may attack the demolition crew,
  and every asset there targets them.

**I assumed (please confirm):**
1. A **forced** demolition does not restart the monthly clock. Only sanctioned zones count.
2. A **practice** demolition doesn't use up the monthly zone, and gives the same skill progress per unit of effort as
   a real one.
3. The whole **demolition crew** is aggroed, not only the admin who asked for it.
4. "Month" is a fixed window (for example 30 days) from the last sanctioned zone, rather than a calendar month. The
   proof works for any window length; your team just picks the number.

**Still to settle:**
- **Does a forced demolition still give resources?** If it does, the once-a-month limit covers only sanctioned
  demolitions, and the cost of forcing is the risk of being attacked. That may be what you want, but it's worth
  saying explicitly.

---

## 2. PvP switch and aggro

**The rules:**

- Normally, each player chooses whether they are **open to PvP** in field encounters.
- Anyone who **aggroes a local skybox** becomes a target for **every asset** in that skybox, and **every player** in it
  may attack them if they choose, **whatever either player's PvP switch says**.
- The PvP switch **cannot be flipped during an encounter**. The encounter has to finish first.
- Otherwise there is **no cool-off timer**. If you leave a battle and you're done, you flip the switch and people stop
  attacking you.

**Proved** (`Rulings.lean`):
- `setPvp_refused_in_encounter`: the switch can't be flipped mid-encounter.
- `setPvp_no_cooldown`: outside an encounter, it can be flipped and flipped back straight away.
- `pvp_off_safe`: once a player who hasn't aggroed their skybox turns PvP off, nobody can attack them.
- `aggro_overrides`: an aggroed player can be attacked by every player in that skybox and is targeted by every asset
  in it, whatever the switches say.
- `pvp_off_keeps_aggro`: turning PvP off does not lift aggro.

**I assumed (please confirm):**
1. Outside aggro, a PvP attack needs **both** players to have the switch open. A player with PvP on can't attack
   one who has it off.
2. Aggro applies **inside the skybox that was aggroed**. A player who leaves that skybox is no longer a target there.

**Still to settle:**
- **How does aggro end?** For example: on leaving the skybox, on being defeated, when the demolition finishes, or after
  a set time. Without an end, one forced demolition makes a player a permanent target in that skybox.

---

## 3. Gifts

This replaces the gift model from `FOLLOW_UPS.md` §2. I had it wrong before: there are no "player" and "team-member"
slots, and the "not returned" warning goes to the **sender**. The old proofs in `Followups.lean` are kept for the
record but no longer describe the game.

**What a gift is.** A gift is a specific game item that the sender has **crafted or owns**. You can't give someone a
spell. You can give them a single-use LLM micro pod that casts it, if you have the skills to make or use it, or a scarf
with an enchantment that fades once it is used up. For the receiver it's an activation button: they only have to push
it.

**Giving.**
- The item moves from the sender's inventory to the receiver's **available gifts**.
- If a sender gives the same player (in an arena or field adventure) a **second** gift, the sender sees the warning
  **"gifted items are not returned"**.

**The receiver's queue.**
- The receiver has **numbered queue slots, from 1 up to 20**. How many depends on their micromanagement skill.
- Each slot holds one gift. A gift can't be queued into a slot that is already occupied. The player first takes the old
  gift out by hand, then slots the new one.
- When the queue runs, **slot 1 is always tried first**. If something prevents that gift from activating, the system
  tries slot 2, then slot 3, and so on.
- In between, the player can **use any available gift by hand**. For example, if the whole queue is single-use potions
  and they don't need one, they can pick a spell pod from their available gifts instead.

**End of the encounter.** A gift still unused when the encounter ends is turned into **excess skill points towards
loot rewards**. The gift's schematic decides **which skill** they go to.

**Who can change a queue.** Only players. A player changes their own queue. A group queue is changed only by the
group leader, or by an admin the leader assigns to micromanage it.

**Proved** (`Rulings.lean`):
- `giveGift_needs_owned`: you can only give an item you own.
- `giveGift_conserves`: giving moves exactly one item from sender to receiver. Nothing is created or lost.
- `giveGift_warning_iff`: the warning shows **exactly** when this sender has already given this player a gift in this
  encounter.
- `queueSlots_bounds`: there are always between 1 and 20 slots.
- `slotGift_occupied`: an occupied slot can't take a second gift.
- `nextSlot_spec`: when the queue activates slot `i`, that gift can activate, and every lower-numbered slot was empty or
  blocked. So it really is slot 1 first, then 2, then 3.
- `nextSlot_isSome`: if any slot holds a gift that can activate, the queue activates something.
- `endEncounter_total`: each unused gift becomes points exactly once, in the skill its schematic names. Summed over all
  skills, the points equal the total value of the unused gifts.
- `endEncounter_le_effort`: if no schematic is worth more points than the effort it takes to craft, the points from
  unused gifts are at most the crafting effort behind them. So gifting can't create skill points out of nothing.
- `maySwap_spec`: only the player changes their own queue; only the leader or their assigned admin changes a group
  queue; nothing that isn't a player changes any queue.

**I assumed (please confirm):**
1. The "not returned" warning is counted **per encounter**: the second gift from the same sender to the same player in
   the same arena or adventure.
2. The schematic sets **how many** points an unused gift is worth, as well as which skill they go to.

**My suggestion:** set each schematic's point value no higher than the effort it takes to craft. Then
`endEncounter_le_effort` applies, and two friends swapping gifts can't farm skill points.

---

## 4. Reset blueprints: no royalties, and forks show "anonymous"

**The rules:** once a hard-reset player's blueprints lose their tag, **no royalties** are paid on them any more, and
giving up the schematics carries **no penalty**. Fork histories also show **"anonymous"**, because the metadata
underneath changes.

**Proved** (`Rulings.lean`):
- `reset_no_royalty`: after the reset, no royalty from any blueprint on the board goes to the reset player.
- `anonymizeHistory_spec`: the reset player appears in no fork history, every history keeps its length, and every other
  author is kept.

This settles both questions in `FOLLOW_UPS.md` §4.

---

## 5. The AI Council and developer-secure information

**The rule:** the AI Council can **never** access developer-secure information, such as real-world identities. This is
an **absolute hard stop**. Human approval doesn't change it. Only assigned developer-team members and collaborator
admins have access. For any AI Council engagement with the build, a developer must be on the team to make sure it
doesn't break the build.

**Proved** (`Rulings.lean`):
- `aiCouncil_hard_stop`: the AI Council never has access, and human approval never changes anyone's access.
- `councilMayEngage_needs_dev`: AI Council engagement with the build is not allowed without a developer on the team.

This also answers most of `FOLLOW_UPS.md` C9, the admin-side link from a reset account to the real person. Only the
assigned developer team and collaborator admins can see it. I'd still suggest **logging every access**.

The earlier plan for the Council to work out who unnamed contributors are (C8) would need real identities, so this rule
already rules out the identity part. Contributors can still claim their own work themselves.

---

## 6. Black Hole Orb and the 144 cap: both

**The rule:** both hold. Skills cap at 144. The player's **64 Gold Lock Orb** can be activated once the character reaches 64, and the
dragon's **Black Hole Orb** can be activated in game.

**Proved** (`Rulings.lean`):
- `activateBank_spec`: activating the Black Hole bank never takes a skill past 144, and nothing is lost. What doesn't fit
  stays in the bank.
- `orb_phases`: the Gold Lock Orb can't be activated before the character reaches 64; the Black Hole Orb can be activated in game.

**I assumed (please confirm):** activating the Black Hole Orb can't push a skill past 144. Anything over the cap stays
banked. This is what makes "both" consistent.

---

## 7. ORION

**ORION = Open Research Intelligence Optimization Network.** Please use this in the glossary and the build document.
The review files that listed both versions now point here.

---

## What's still open from this round

1. Does a forced demolition still give resources? (§1)
2. How does aggro end? (§2)
3. The assumptions marked "please confirm" in §1, §2, §3 and §6. A "yes" is enough for each.

Everything else still open from earlier rounds is in `FOLLOW_UPS.md` §5. The items answered this time are marked
there.
