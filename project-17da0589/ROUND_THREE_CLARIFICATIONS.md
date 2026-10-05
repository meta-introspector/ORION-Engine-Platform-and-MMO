# Round Three clarifications

This file writes up your latest answers as rules a coder can build. The proofs are in
`RequestProject/RoundThree/Clarifications.lean`. That file builds with no `sorry` and uses only the standard axioms.
As before, the proofs cover the **rules as written**. There is no game code yet.

Answers here replace what `ROUND_THREE_RULINGS.md` said wherever the two disagree. The two older statements this
changes are marked "superseded" in `Rulings.lean`.

**ORION** is locked as **Open Research Intelligence Optimization Network**. If a note ever says it another way, treat
it as a slip and use this form.

---

## 1. The 50 % node discount (answers `FOLLOW_UPS.md` A4)

**The rule:**
- The discount is **one flat 50 %**. Every additional orb levelled in a node slot costs **half the base cost**, not
  half of the previous orb.
- The discount belongs to **the grid being trained**. Until symbiosis that's the character's 64-node grid, and the
  discount comes from the node's character lock (currently "Gold Lock").
- At **symbiosis** the discount **switches off**. It does not carry over into the dragon's grid.
- On the dragon's 144-node matrix the discount comes back for a node only once **that node's first skill** has earned
  the dragon lock (currently "Black Hole lock"). You earn it the same way you earned the character lock.

**Proved:**
- `orbCost_flat`: with the discount, every additional orb costs exactly half the base cost, however many orbs came
  before it.
- `nodeCost_discounted`: levelling \(n+1\) orbs in a discounted node costs \(c + n \cdot c/2\): the first at full
  price, the rest at half. `nodeCost_full`: with no discount, \(n\) orbs cost \(n \cdot c\).
- `bond_discount_off`: right after symbiosis the discount is off on every dragon node, even ones that were
  character-locked. The character lock itself is kept, because it carries over into the symbiosis slot.
- `dragon_discount_iff`: on the dragon matrix the discount is on **exactly** when the node holds the dragon lock, and
  earning that lock turns it back on.
- `bond_then_lock_costs`: after symbiosis, extra orbs in a node cost full price until the dragon lock is earned, then
  half price.

**Rounding (answered, see §8.5):** your team will most likely round down. §8.5 explains why rounding a *cost* up is
actually the choice that keeps the system from bloating.

## 2. The character lock is available at 64

**The rule:** 64 is as far as a character can go before unlocking a dragon. The character lock (currently "Gold
Lock") becomes available **at 64**, not at some final stage. Character-locked orbs carry over into the dragon's
symbiosis slot. To dragon-lock all 144 dragon nodes, you repeat the work you did to character-lock the first 64.

**Proved:**
- `advance_le_64`: without a dragon, progress never goes past 64.
- `charLock_at_64`: starting from zero with no dragon, 64 steps reach 64, and the character lock is then available.
  It isn't available before 64.

This replaces last round's wording, which tied the Gold Lock Orb to a final stage of the game. There is no final
stage: the platform grows organically.

**Settled: what "level" means.** "Level" means **one of the 64 character nodes being unlocked or gold-locked**. There
is no separate character-level system. "Level 64" means all 64 nodes are gold-locked. Skills are levelled separately
(see §7).

### New names for the two locks

*(Explained more plainly in §8.6.)*

You asked for alternatives to "Gold Lock" and "Black Hole lock". In the code I've used neutral names, *character
lock* and *dragon lock*, so the final names can be dropped in later. Some pairs to choose from:

| Character grid (64, now "Gold Lock") | Dragon matrix (144, now "Black Hole lock") | Idea behind it |
| --- | --- | --- |
| **Anchored** | **Eclipsed** | Gold anchors the self; the eclipse matches the dragon's dark orb. |
| **Sealed** | **Starsealed** | One verb for both. The second is clearly the "next tier". |
| **Mastered** | **Bonded** | Reads plainly. But "bonded" is also your word for dragon symbiosis, which could confuse. |
| **Crowned** | **Constellated** | Matches the cosmic theme. 144 nodes form a constellation. |

My pick is **Sealed / Starsealed**. It's short, works as a verb ("you starsealed the node") and tells a new player
right away that the second lock is the higher tier.

## 3. Demolition: three tiers

**The rule:**

| Tier | Resources | Aggro |
| --- | --- | --- |
| Practice | **none** | no |
| Scheduled (sanctioned, at most once a month) | **yes** | no |
| Unscheduled (forced) | **yes** | **aggroes the local group** |

**Proved:**
- `demolition_tiers`: practice gives no resources, and scheduled and forced both give the full yield. All three give
  the same skill progress.
- From last round: forced demolitions aggro the local group against the crew (`forced_demolition_aggro`), and
  scheduled zones are at least a month apart (`sanctioned_spaced`, `sanctioned_count_bound`).

**A consequence worth knowing.** Forced demolitions pay resources, so only **scheduled** demolitions are limited to one
a month. A crew willing to sit out the aggro can force-demolish more often. So the 10-minute aggro (§4) is the only
brake on resource farming by forcing. If that's not enough, you could have forcing pay less than a scheduled
demolition, for example half the yield.

**Answered (§8.7):** a forced demolition pays **more** than a scheduled one, because it's an inconvenience.

## 4. How aggro ends: the 10-minute timer

**The rule:**
- Aggro from a destructive (forced) demolition lasts **10 minutes**.
- While aggroed, you can cast **healing buffs** and **ORION-aligned debuffs**, and the timer keeps running down.
- **Any kinetic action**, such as an attack, counts as intentionally Kronos-aligned and **resets the timer** to a full
  10 minutes.
- When the timer reaches zero, the aggro is over.

**Proved** (time counted in seconds, 600 = 10 minutes):
- `kinetic_resets`: while aggroed, a kinetic action sets the timer back to 600 seconds.
- `heal_debuff_count_down`: healing buffs and ORION-aligned debuffs don't reset the timer.
- `aggro_ends`: 10 minutes with no kinetic action ends the aggro.
- `aggro_lasts`: within 10 minutes of the forced demolition, or of the last kinetic action, the player is still
  aggroed, whatever else they do.
- `no_aggro_stays`: a player who isn't aggroed doesn't become aggroed through ordinary actions. Only a forced
  demolition starts the timer.

**Please confirm:**
1. Leaving the skybox doesn't stop the timer. If it does stop it, that's a second way out of aggro and needs writing
   down. (Last round I assumed aggro only applies inside the aggroed skybox.)
2. A kinetic action by **any** member of the crew resets the timer only for **that** member, not for the whole crew.

**Answered (§8.8):** leaving the skybox clears the aggro, and aggro belongs to one player only.

## 5. Switching to PvE-only mid-encounter

**The rule:** if a player switches to PvE-only during an encounter, the change is recorded and **takes effect
automatically when the encounter ends**. Then they don't have to flip the switch while they're being attacked.

**Proved:**
- `request_midEncounter_unchanged`: a mid-encounter request doesn't change the switch during the encounter.
- `request_applies_at_end`: when the encounter ends, the switch takes the last value asked for. If the player changes
  their mind twice, the second choice wins.
- `request_outside_immediate`: outside an encounter the switch changes at once.
- `pve_request_safe_after`: a player who asked for PvE-only mid-encounter, and hasn't aggroed the skybox, can't be
  attacked by anyone once the encounter ends.

Aggro still overrides the switch, as before (`aggro_overrides`).

## 6. Gifts

**The rules:**
- A gift with **no applicable weight** (an empty schematic, worth nothing) is **rejected**. It never reaches the gift
  queue.
- A gifted item **can never be worth more** than the resources put into its schematic to build it.

**About the "points out of nothing" question.** I'm sorry, my wording was confusing. You answered what I was asking.
The worry was that two friends could pass items back and forth, with each unused gift turning into skill points, and
farm points that nobody earned. Your rule stops that. A gift is worth at most the resources that went into building
it, so all the points that come from gifts are paid for by resources someone gathered.

**Proved:**
- `empty_gift_rejected`: a gift worth zero is refused.
- `giveWeighted_all_weighted`: every gift that reaches a receiver has weight.
- `gift_points_from_resources`: under your rule, the points from unused gifts never exceed the resources put into
  those gifts. Also, any gift that can be given at all had resources put into it.

---

## 7. Dragons: the sun, the species, and the looks

**The rules:**
- Gold-locking the 64 nodes depends on **play, not skill levels**. A strong sharp shooter can gold-lock all 64 as soon
  as they enter the game.
- Gold-locking all 64 gives the **dragon seed**. To hatch it, the player has to **take the seed to a sun**. That needs
  the skills to **escape the planetary skybox**, so a brand-new player can't hatch a dragon straight away.
- Someone can still hatch a dragon at fairly low skill. How far they can **curate its looks** depends on their
  **biological-line** skill. A low-skill dragon looks **plain**, but it can **do everything** a better-looking one
  can. It just isn't as pretty until the player levels their skills.
- The **species build** is chosen once, from the Proofs Arena animals or the generic dragon, and **can never change**.
  A whale dragon is always a whale dragon. Every other aspect (colour, structure and so on) can change.

**Proved** (`RequestProject/RoundThree/Dragon.lean`):
- `sharpshooter_all_64`: a fresh player can gold-lock all 64 nodes with every skill still at zero.
- `sharpshooter_cannot_hatch`: that same player **can't** hatch a dragon, because they can't reach a sun yet.
  `canPlantSeed_iff`: hatching needs exactly two things, all 64 gold locks and the escape skill.
- `speciesChoices_spec`: the species roster is the 46 Core animals of the Proofs Arena, including `WHALE` and `DRAGON`
  (the generic dragon). `hatch_spec`: a hatched dragon has the species chosen at hatching, and it is on the roster.
- `species_forever`: no sequence of look changes, at any skill, changes the species.
- `any_look_reachable`: with enough skill, any look can be given to the dragon.
- `looks_monotone`: more skill only adds look options, it never removes them. `low_skill_refused`: a look above the
  player's skill is refused.
- `looks_do_not_matter`: what a dragon can do depends only on its species build, never on its look. So a plain
  low-skill dragon can do everything a fully curated dragon of the same species can.

**Please confirm:**
1. **"Biological line"**: I read this as the player's skill in the **biology skill line**. If you meant their
   in-game **bloodline/ancestry**, the model changes a little. Bloodline would set which looks are on offer, and
   skill would set how far into them the player can go.
2. **Does the species affect abilities?** I allowed for this (a whale dragon could swim better than a falcon dragon)
   without assuming it. If every species should play exactly the same, say so.
3. **The roster:** the Core list includes entries that aren't animals in the usual sense: `HIVE`, `PULSE` and
   `SHEPHERD`. It also includes the mythical `PHOENIX`, and `DRAGON` itself. Should all 46 be offered as dragon builds,
   or only the animals?
4. Does **escaping the skybox and reaching a sun** take one skill or several? The proof works with any threshold. I
   modelled it as a single escape skill.

**All four answered in §8.** (1) Yes, the biology skill line. (2) Yes, species affects abilities. (3) Only the
animals, plus the generic dragon and the phoenix; `HIVE`, `PULSE` and `SHEPHERD` become archetype upgrades. (4) It
isn't a skill threshold. It's the skybox gate (§8.4).

---

## 8. Your latest answers

The proofs are in `RequestProject/RoundThree/Curation.lean`. It builds with no `sorry` and uses only the standard
axioms. Where this section disagrees with §7, this section wins. The older statements are marked "superseded" in
`Dragon.lean`.

### 8.1 No final stage

The platform grows organically, so there's no final stage, and the term you want to avoid is gone from every file in
this project. The one rule that used it (when the Gold Lock Orb activates) now reads "activates once the character
reaches 64", which matches §2. The only remaining mentions are in the past-session summary file, which I don't edit.

### 8.2 Menus never show what a player can't do

**The rule:** every curating and crafting menu shows **only** what the player can actually do. Nothing above their
reach is ever offered, so nobody keeps hitting "you can't do that". An option is within reach in any of three ways:
- the player has the **skill** (for dragon looks and body, the biology skill line);
- the player **owns a blueprint schematic** for it;
- the player can **engage a tradesman** who has the skill (for dragons, someone with dragon master skills).

A low-skill result can still look a hot mess. Low skill limits **which** changes are offered (a haircut, not a new
scale structure). It doesn't stop the player doing the changes that are offered.

**Proved:**
- `menu_within_reach`: everything on a menu can be done through skill, a blueprint or a tradesman.
- `menu_complete`: everything within reach is on the menu. Nothing doable is hidden.
- `solo_menu_le_skill`: a player with no blueprints and no tradesman only sees options at or below their own skill.
- `menu_mono`: more skill, another blueprint or another tradesman only adds options. It never removes one.

### 8.3 Dragon builds

**The rules:**
- The **species** is chosen once at hatching and never changes. It **affects abilities**.
- Species choices are the **actual animals** of the Proofs Arena roster, plus the generic `DRAGON` build and the
  `PHOENIX`. That's 43 choices.
- `HIVE`, `PULSE` and `SHEPHERD` aren't animals. They're **archetype upgrades** to the dragon build: they change
  abilities but never the species. The base generic dragon structure can be modelled on what those three proofs do.
- **Body** aspects (structure, scales or fur, and so on) can be curated, and they **can** affect abilities.
- The **skin** is the one thing that **never** affects abilities.
- A **phoenix dragon** isn't on fire all the time. Catching fire is one of its features.

**Proved:**
- `roster_split`: 43 species, including `DRAGON`, `PHOENIX` and `WHALE`. None of the three archetypes is a species,
  all three come from the same roster, and the roster is exactly the species plus the archetypes.
- `species_forever`: no sequence of curation steps (body, skin or archetype) changes the species.
- `skin_never_matters`: changing the skin never changes what the dragon can do.
- `archetypes_valid`: a dragon's archetype upgrades are always among the three archetypes.
- `phoenix_fire`: a phoenix dragon hatches not burning, can catch fire, and can be put out again. Burning doesn't
  change its abilities. `ignite_other`: in this model only a phoenix catches fire.

### 8.4 The skybox gate

**The rule:** an **invisible gate** sits at the edge of the atmosphere, at the dodecahedron skybox lattice. Getting
through it loads the **solar level**. The gate lets a player through only if they have **either**:
- the **skybox escape feature**, which comes only from following the predetermined quest line; **or**
- a **key**.

Building a rocket that reaches the lattice is **not** enough. And "having the skills" for something means: can you
craft the right product, cast the right spells, or buy what you need.

**Proved:**
- `crafting_alone_blocked`: a player who only crafts never gets through the gate, however much they build.
- `quest_or_key`: finishing the quest line gets a player through, and so does a key.
- `sharpshooter_rocket_cannot_hatch`: a sharp shooter with all 64 gold locks who has only been crafting can't reach a
  sun, so can't hatch a dragon.

### 8.5 Halving an odd cost

You said you'd round up, but your coders would probably round down to keep the system from bloating. One thing your
team should know before deciding: **for a cost, rounding down is the generous direction.** If an orb costs 7, rounding
down charges 3 and rounding up charges 4. Rounding down lets players pay a little less every time, so progress comes
slightly cheaper overall. **Rounding up is the choice that resists bloat**, which is the direction your instinct went.

A common rule that does both jobs: **round costs up and payouts down.** Then rounding never gives away anything extra.

**Proved:**
- `rounding_spec`: the two rules differ by at most 1, and only on odd costs. Rounding up never charges less than an
  exact half, and rounding down never charges more.
- `rounding_total`: over \(n\) discounted orbs, rounding down saves the player at most \(n\) in total.

**Please confirm:** costs round **up**, payouts round **down**? A "yes" settles it. If you'd rather stick with
rounding down, that also works.

### 8.6 The lock names, explained more clearly

Sorry, I didn't explain this well. Your rules have two kinds of "lock":
- **"Gold Lock"**: what a player earns on each of the **64 character nodes**.
- **"Black Hole lock"**: what a player earns on each of the **144 dragon nodes** after symbiosis.

Earlier, I understood that you wanted other names for these two, so I suggested some (the table in §2). If you're
happy with "Gold Lock" and "Black Hole lock", **nothing needs to change.** Just say "keep them". In the proofs I
call them "character lock" and "dragon lock", so any names can be used.

### 8.7 Forced demolition pays more

**The rule:** a forced (unscheduled) demolition pays the normal yield **plus a bonus** for the inconvenience. A
scheduled one pays the normal yield. Practice pays nothing.

**Proved:** `forced_pays_more`: with any bonus above zero, forced pays more than scheduled, and scheduled pays more
than practice.

**Worth knowing:** scheduled demolitions are limited to one a month, but forced ones aren't. Paying more for forcing
makes the 10-minute aggro the only brake on forcing. If farming by forcing becomes a problem, the bonus is the easy
setting to tune.

### 8.8 Aggro in a group

**The rules:**
- **Leaving the skybox clears your aggro.**
- Aggro belongs to **one player**, even in a group. Group members who don't cast active Kronos-aligned (kinetic)
  skills stay **un-aggroed**. So no member can deliberately draw aggro and grief the group.

**Proved:**
- `no_grief`: whatever one member does, every other member's timer is unchanged.
- `stays_inactive`: a member who isn't aggroed and casts no kinetic skill stays un-aggroed, whatever the rest of the
  group does.
- `leave_clears`: leaving the skybox clears your aggro.
- `join_fight`: a member who isn't aggroed and casts a kinetic skill while a group mate is aggroed becomes aggroed
  themselves, for the full 10 minutes. Nobody else is affected.

**Please confirm:** `join_fight` is how I read "as long as the other group members do not cast active Kronos
skills". Casting one while a teammate is aggroed means joining the fight. Is that right?

### 8.9 The monthly reset (storyline addition)

**The rule:** at the start of each month, during the 24-hour shutdown while the dragons feed, every
**developer-hosted** prize pool that nobody has won resets. That covers Poly Pog and all the public arenas and
championships. The leftover energy goes to the **reconstruction**. Pools hosted by players aren't touched.

**Proved:** `monthlyReset_spec`:
- after the shutdown every developer-hosted pool is empty;
- every player-hosted pool is unchanged;
- the reconstruction fund grows by exactly the unclaimed developer-pool energy;
- **no energy is created or lost.**

## Still open

1. Rounding: costs up, payouts down? (§8.5)
2. Lock names: keep "Gold Lock" / "Black Hole lock", or pick new ones? (§8.6)
3. Joining the fight in a group (§8.8).
4. Archetype upgrades: can any species take `HIVE`, `PULSE` or `SHEPHERD`, or only the generic dragon? I allowed
   any species.

## 9. Answers received (from the *ORION Round 4* Notion page)

1. **Rounding:** "in favor of the player". So costs round **down** and payouts round **up**. This is written up and
   proved in `RequestProject/RoundFour/PlayerRounding.lean`. It conflicts with Ryan's Game Rules v1–v3, and it opens
   a loophole in the 2 % tax. Both are covered in `ROUND_FOUR_RYAN_GAMEPLAY_READOUT.md` §2.1 and decision D1.
2. **Lock names:** keep "Gold Lock" and "Black Hole lock". Nothing changes.
3. **Joining a fight:** yes. The designer added that an accidental negative effect that raises Kronos also counts,
   and that the mob turns on that player. The open details are in the readout, decision D5.
4. **Archetypes:** any species can take one. The designer also introduced Kronos / Orion / KRION builds. How they
   fit with `HIVE` / `PULSE` / `SHEPHERD` is decision D2 in the readout.

The designer's other notes (guided lessons, phoenix elements, a generic dragon overlay) are covered in the readout,
§3.2 and decisions D3–D4.
