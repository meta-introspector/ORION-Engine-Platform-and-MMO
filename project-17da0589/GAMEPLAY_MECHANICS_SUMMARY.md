# The Orion Chronicles: gameplay mechanics summary

**[R10 correction, 2026-10-04]** The actual Greedy rulebook has *not* been uploaded: the old six-dice Greed calculation below was for an assumed example and is **not a specification or prediction for Greedy**. Keep working betting-pool names as examples only. Language skill display is a proposed separate presentation layer; safety messages must not be garbled (`ROUND_TEN_REPLY.md`, `RequestProject/RoundTen/OpeningTen.lean`).

**Round 10 correction above (2026-10-04). Prior full pass: Round 9, fifth pass (R9e), 2026-10-04.** R9e changes: `ROUND_NINE_FIFTH_PASS.md`. R9d changes: `ROUND_NINE_FOURTH_PASS.md`. R9c changes: `ROUND_NINE_THIRD_PASS.md`. R9b changes: `ROUND_NINE_SECOND_PASS.md`.

### R9e additions (summary)

- 📝 **Platforms (R9e):** one global web platform housing four platforms (MMO, education, socials, Elder's Garden) plus
  the Orion engine landing page; each has an MMO instance and access points to the others. Release in small live
  demos (e.g. mini-games).
- ✅ **Sales split (R9e):** finisher 90%, base creator's schematic 3%, tagged contributors share 7% by weight;
  link-sharing earns a small weight, code a large one; community claims only for hands-on work. Proved: never pays
  out more than the sale (also after the 3% tax); more weight never paid less.
- ✅ **Damaged structures (R9e):** 50% of income to the DEVPOOL while taking damage (proved: nothing lost or created).
  Fully decayed planets can be reclaimed as another player's skybox; the old owner's things are packed into their storage.
- ✅ **Parental controls (R9e):** per-platform daily caps, full locks, blocked and custom tracks. Proved: total time
  never exceeds the caps; a locked platform gets no time.
- 💎 **Child safety (R9e, locked):** no adult alone with a child except their verified guardian; under-13s with no other
  player unless a guardian is present; educators only via classrooms, public boards and the parent portal; transcript to
  the parent afterwards (no biometric replay). Proved: join-only checks fail when a guardian leaves; with the
  close-the-bubble rule every room stays safe.
- ✅ **Cross-platform votes (R9e):** outsiders at 50% weight; proved this alone can override the engaged players.
  Assumed fix: engaged-majority lock (proved never to override). Titles of notoriety per platform.
- ✅ **Biometric firewall (R9e):** project-wide, one account per human, a check at each graduation and to contact a
  child. Proved: tier never rises without passing a check.
- ⏸️ **Economy (R9e):** real-money links, Bubble Bucks/QX outside the game and conversion limits deferred to the
  economics people.

### R9d additions (summary)

- ⏳ **Greedy in the gambling arenas (R9d; superseded scoring in R10):** required, actual rules pending. The following is an **illustrative, rejected assumption**, not your Greedy: common "Greed" scoring (single 1 = 100, single 5 = 50,
  three of a kind = 100 × face, three 1s = 1000). Proved: a roll scores nothing exactly when it's a bust; 1,440 of the
  46,656 six-dice rolls bust (about 1 in 32); banked points never go down **under that assumed example only**.
- ✅ **Betting pools (R9d):** on POLY, fights, spec wars, build challenges, racing and game challenges from Atari-style
  to modern consoles. 3% tax; winners share the rest in proportion to stakes (assumed). Proved: never pays out more than
  came in; a bigger winning stake is never paid less. Name still open.
- ✅ **Rat Slap (R9d):** candidate game. Proved: cards are never created or lost.
- 📝 **Collab targets (R9d):** Settlers of Catan and Pokémon (need those companies' agreement); DeepSeek for POLY.

### R9c additions (summary)

- ✅ **Stars are dragons' homes (R9c):** entering a star takes you into the dragon's **solar box**, a new universe;
  everything inside, including nested skyboxes and bubbles, is that dragon's domain. Proved: anything inside a star
  has exactly one nearest star, and with no stars nested inside other stars' universes, two dragons' domains never
  overlap. Assumed: if stars can nest, the nearest star wins; a player's skybox keeps its own access rules.
- ✅ **Pre-launch construction site (R9c):** mini-games, learn-about-the-game activities and a searchable wiki. A
  player idea goes to the DEVs (via the construction council) only if it isn't already in the wiki. Proved: never
  forwarded twice; every submitted idea lands in the wiki; the first submitter keeps the credit. The submitter can
  then prompt proposed artwork about their inclusion.
- ✅ **Advertisement bubbles (R9c):** one bubble per downloadable app mentioned during the build, however often it is
  mentioned (proved). **Build playlist:** every song gets at least an honorable mention (same rule).
**Excluded on purpose:** dragon egg hatching (how a dragon is generated, the seed, and the hatching journey). Your
ToC X-Summary page keeps that for players to discover, and you asked me to leave it out.

How to read this:
- **✅** you've ruled on it, and the rule is proved in Lean.
- **📝** you've ruled on it, but there's nothing to prove, or it isn't modelled yet.
- **❓** still open: it needs a ruling.

"Proved" means the rule, as written down, has the stated consequence. There's no game code yet. Each line names the
round where it was settled. The matching reply files are listed in `ORION_MASTER_INDEX.md`.

---

## 1. The loop: how the platforms fit together

- ✅ **Order (R8):** The ORION Engine → The Playground (socials) → The Orion Chronicles (MMO) → The Ascent (education)
  → projects → Elder's Garden (ancestral tree) → back to the engine. It works like a toroidal engine: the swarm feeds
  up, and the tree feeds back down. You can enter at any layer, and every layer is at most five steps from any other.
- 📝 **Roles of the layers (R7d chat, R8):**
  - the social layer is the swarm;
  - the MMO is the proofs;
  - education gears players toward advancement;
  - projects bring it into the real world;
  - the ancestral tree is the capstone.
- 📝 **Elder's Garden (R8):** the ancestral tree and ultimate celebration capstone, reached from the ORION's Gate
  landing page.
  - Users' public accomplishments, storylines and family relations are viewable.
  - Bubbles branch outward to friends and family, and inward through a user's own accomplishments and publications.
- 📝 **ORION's Gate mockup (R9):** portals to Playground, Orion Chronicles, Ascent and Elder's Garden, plus Docs, Join
  Now and a live engine-status bar. Its Elder's Garden card still says "cultivation & research hub", which needs
  fixing to match the R8 ruling (R9 P1). The plain-words walkthrough is in `ORION_FUNCTIONAL_WALKTHROUGH.md`.
- ❓ ORION's Gate: landing page, community projects page (R7c), or both? (R8 Q6)

## 2. Character

- ✅ **Species** is your underlying identity. It's chosen once and never changes. Acquired traits add to it but never
  replace it. (R3, R7d)
- ✅ **Body** changes can influence abilities. **Archetype** upgrades (HIVE ↦ Kronos, PULSE ↦ Orion, SHEPHERD ↦ KRION,
  confirmed R4) give specialised development paths. (R3, R4)
- ✅ **Skin:**
  - the look is cosmetic and never changes abilities;
  - **crafted bioengineered skins** can carry an enhancement (skill / armour);
  - abilities can depend on the enhancement but never on the look. (R3, R7d, R8)
- ✅ **Biological-line skill** decides which looks you can give your dragon. A plain-looking dragon can still do
  everything its species can. (R3)
- 📝 **Two resets:**
  - the account **hard reset** returns you to a first-time player with the same real-life metadata;
  - the **character reset** touches one character only. (R3)
- ❓ Swapping off a bioengineered skin: does its enhancement go too? Who can craft one? (R8 Q9)
- ❓ "SHEPHERD" vs "SHEPHARD" spelling.

## 3. Skills, orbs, level and meditation

- ✅ **Skill orbs** level one step at a time from 0 to **100** and **gold-lock at 100**. It takes exactly 100
  level-ups from 0. (R7, R7c)
- ✅ **No maximum on gold-locked orbs.** (R8)
- ✅ **Slotting (R9b, replaces R9):** **any** orb can go into a **node slot**; only a gold-locked (level 100) orb can
  go into the **64-grid matrix**, and a full matrix opens the dragon grid. An orb **gains levels only while active in
  a node slot**. Proved: training outside a node does nothing; the matrix only ever holds gold orbs.
- ✅ **KRION bonus (R9b):** **per slot**: +25% to the orb in that slot only. Proved: it never changes another slot.
- ✅ **Marksman one-shots (R9b):** an extreme marksman who hits the tiny target earns a free gold-locked orb (assumed:
  for levels one and two; the rest are levelled in the wild). Proved: a full matrix takes at least 6,400 training
  steps minus 100 per reward (at least 6,200 with two rewards).
- ✅ **Starter orbs (R9):** everybody starts with **64 orbs**, exactly enough to fill the matrix. More can be bought
  or crafted.
- ✅ **Orb economy (R9):**
  - orbs can be transmuted, traded, or sold as specialty items;
  - others can meditate on an orb to learn from it, or slot it if they have the skill;
  - levels can't be crafted: they come only from training and marksman rewards (proved, R9b);
  - deconstructing gives raw materials, which make the empty orbs needed to craft new ones.

  Proved: every level in the world was trained by someone. A full 64-gold matrix costs at least 6,400 training steps
  across the world, and crafting, deconstructing and trading can't shortcut it.
- ✅ **Level:**
  - one level per gold-locked orb, up to the **64-orb grid** (level 64);
  - more orbs alone never go past 64;
  - **level 65, dragon rider,** comes only from **meditating in a safe zone with the full 64-orb grid**;
  - a rider always keeps 64 gold-locked orbs. (R7, R8)
- ✅ **Surplus gold-locked orbs:** keep them for future builds, or **exchange at 50%** for Kronos/Orion energy. Odd
  amounts round up, in the player's favour. (R8)
- ✅ **Meditation locks in progress.** Skill progress and new abilities stay **pending** until you meditate in a safe
  zone, out of combat. Meditating elsewhere does nothing, and progress is never lost. (R4, R5)
- ✅ **Node discount:** after a node's lock, each additional orb levelled in that node slot costs a flat 50% of the base
  cost. It isn't compounding. After dragon symbiosis it's off for a node until that node earns the dragon (Black Hole)
  lock. (R3)
- ✅ **Lessons:**
  - a separate guided track just past your reach;
  - a lesson is never on the normal menu;
  - it's always within a fixed stretch of your skill;
  - once you reach it, it appears on the menu. (R4)
- ✅ **Menus** only ever show options within your reach: your own skill, a blueprint you own, or a tradesman you
  engage. (R3)
- ✅ **Encounters scale** to the skills of the people in them. Lowering your own skill by hand never improves the
  reward-to-difficulty ratio. (R3)
- ✅ Learning a skill takes time (R9b answer to O1). ❓ Raw materials per deconstruction and the cost of an empty
  orb. (R9 O3)
- ❓ Is there anything above level 65? What is one orb worth in energy, and is it Kronos, Orion or both? (R8 Q1)
- ❓ How far ahead a lesson may reach (the stretch value).
- ❓ Quest-orb visual sequence (geometry / colour / rings / sphere, A3).

## 4. Dragons and the dragon matrix (hatching excluded)

- ✅ **Dragon matrix:** 144 nodes (64 + 80). Only gold-locked orbs port to it. An orb on the dragon takes the dragon's
  skill level directly. (R3, R7c)
- ✅ **Elements:** fire, water, earth, air and ether. Any dragon can learn fire. A dragon that isn't a phoenix switches
  elements anywhere out of combat, but not in combat. (R4)
- ✅ **New elements** are locked in by safe-zone meditation, never mid-combat. (R4)
- ✅ **Element strength:** a dragon's elemental skill is 2× a non-dragon player's. Non-phoenix dragons sit within 2×–2.2×.
  (R4)
- ✅ **Ordinary dragons choose their elemental path (R9 💎)** and progress **one element at a time**. Any order a
  player picks can be followed, no element is mastered twice, and a mastered element is never lost. This replaces the
  R8 "fixed order" model.
- ✅ **Stacking settled (R9b):** an ordinary dragon has **one primary element**, chosen by the player (safe zone,
  meditation, before adventuring). The primary is the differentiator, as fire is for the phoenix. Stacked elements run
  at **3 : 1.75** against the primary (about 58 when the primary is 100). Proved: the phoenix stays at least as strong
  in every element, and stays so under any stacking rule that keeps elements at or below 100.
- ❓ How the 64 character orbs map onto the 144 nodes. When the auto-adjust starts. Whether the KRION challenge for the
  Black Hole lock is per orb or per matrix. (R7c Q2–Q3)

## 5. The phoenix

- ✅ It can have all of its gained elements active and **switch mid-battle**. Its build chooses which elements, and how
  many, are active. (R4)
- ✅ It has the same skill cap and the same non-elemental power as every dragon. Its edge is **elemental only**. (R7b)
- ✅ **Taper (R8):** in each element, with k active elements, it works at 1 + (5 − k)/40 times an ordinary dragon:
  - 110% with fire alone (the R5 +10% rule);
  - 107.5% / 105% / 102.5% with two, three or four elements;
  - 100% with all five ("all five at full power");
  - never below an ordinary dragon;
  - stronger in every element than an ordinary dragon stacking the same number.
- ✅ Across different skills, a low-skill phoenix can lose to a high-skill dragon. It isn't better overall. (R7)
- ✅ Confirmed by you (R8 answers 👍). Whatever weakening ordinary dragons get for stacking, a phoenix running the same
  number of elements is at least as strong in each one (R9). The plain explanation is in `ROUND_NINE_REPLY.md` §5.

## 6. Quests and never being stuck

- ✅ **Fair quests:** a stage never needs a skill you had no way to get earlier. A quest is fair exactly when it's
  completable, and stronger players can do anything weaker ones can. (R4)
- ✅ **Quest kinds:** every quest has an exact entry skill. Leveled and sub-leveled quests are completable now. **Epic
  training quests** stay locked until you reach the entry skill. (R5)
- ✅ **Never stuck (R8):**
  - you level just by interacting with the world (environment, battle raids, healing guilds), so every skill
    requirement is eventually met;
  - a **quest generator** always produces a new quest you can complete;
  - the **quest search** returns exactly the unfinished quests of a category you can do.
- 📝 Quest types: standard, leveled, sub-leveled, educational, epic training, DEV-created and player-created
  training content. (ToC X-Summary)

## 7. World, skyboxes, combat and aggro

- ✅ **Skyboxes (R9 💎):** owners set access however they please: public, private, invite-only, by request, by skill
  level, archetype or build, or combinations, and they can change it any time. DEVs can change it too. **R9b:** private
  means the owner decides who gets in, with **access tiers** per guest. Proved: only the owner or a DEV can change the
  setting or guest list; the owner can do everything; a guest gets everything up to their tier; strangers can't enter
  a private skybox; private with no guests is owner-only. The R3/R8
  quest/key gate is still never opened by crafting, if it stays an option (R9 S2).
- ❓ Can DEVs enter private skyboxes? (R9 S1)
- ✅ **Aggro:**
  - it belongs to the player who creates it, and lasts 10 minutes;
  - healing buffs and ORION-aligned debuffs let it run down, while kinetic (Kronos-aligned) actions reset it;
  - environmental and direct-encounter effects pull aggro onto their caster, and other effects don't;
  - one player never changes another's timer;
  - leaving the skybox clears it;
  - monsters use the same 10-minute timer. (R3, R4)
- ✅ **PvP toggle:** you can't flip it during an encounter, and there's no cool-off otherwise. A player who aggroed a
  skybox is a target for everyone in it, whatever their switch says. Switching to PvE-only mid-encounter takes effect
  when the encounter ends. (R3)
- ✅ **Demolition:**
  - practice demolition gives skill only;
  - scheduled demolition gives resources;
  - forced demolition gives more resources, but aggroes the local group;
  - a structure can be a deconstruction zone at most once a month. (R3)
- ✅ **Decaying structures:** if others destroy one, the owner loses nothing (the build packs into their vault) and the
  raiders gain materials. Every gain is paid for with effort. (R3)
- ✅ **Expended components** are used up, and nothing comes back automatically. (R3)
- ❓ AFK loot (A6); group loot scaling (A7); deconstruction yield cap (A8).

## 8. Gifts

- ✅ Each player has one active **player** gift slot and one **team-member** slot.
- ✅ Extra gifts wait in a queue of 1–20 numbered slots, depending on skill. Queued gifts can be reordered; active ones
  can't.
- ✅ Gifts are never returned, and a second gift shows that warning.
- ✅ A gift's points never exceed the resources in its schematic. A gift with no applicable weight is rejected.
- ✅ Unused gifts become skill-progress (XP) boosts in the gift's skill.
- ✅ Only the player edits their own queue. A group queue is edited by its leader or an assigned admin. (R3)

## 9. Economy

- ✅ **Tax: 3% across all taxable incomes** (R8). Below 34 coins, 3% rounds to 0. Taking it from the total never
  collects less than per payment.
- ✅ **Sale royalty:** when a created item or schematic is bought, the creator gets a royalty share of the price. It's
  modelled as taken out of the price; whether it's on top instead is still open (below). If the creator hard-reset
  (anonymous), it goes to the admin arena pool. (R7; rate now 3%, if "all taxable incomes" includes
  it, R8 Q4)
- ✅ **Arena skim** comes off the arena's total final pool before the monthly reset, not per contribution. (R7)
- ✅ **Monthly admin pools** are split evenly, with fewer coins left over than there are admins. (R7)
- ✅ **Monthly reset:** unclaimed DEV-hosted prize pools reset into reconstruction. Player-hosted pools are untouched.
  (R3)
- ✅ **Rounding** always favours the player: costs round down, payouts round up. Splitting conversions to dodge the tax
  is allowed, because real-world time is the cost. (R4)
- ✅ **Hard reset and royalties:** your blueprints stay in the world, credited as anonymous; fork histories show
  "anonymous". The arenas take the tax on the anonymous share, and the rest still goes to the contributor's anonymous
  account. (R3, R6)
- 📝 **RD pool** (R7): an original creator gets 2% of a DEV-used schematic's pool; a player who worked with the DEV team
  gets "10 times the reward".
- ✅ **RD pool (R9b): option A**: all creators share one 3% slice, all DEV collaborators share one 30% slice; proved
  never to exceed 33% of the pool. ❓ Who gets the arena skim. Leftover admin coins. DEV characters selling into the economy.
  Whether the tax is added on top of the price or taken out of it.

## 10. Councils, publishing and stories

- ✅ **Council:**
  - every seat votes yes or no, with no abstentions, and consensus is 4/5;
  - a personal council has at least 5 seats and a public one at least 10;
  - any no triggers a reassessment;
  - a seat switching from yes to no is a strike, and three strikes strike the motion out, with a retry from 7 days
    later. (R4–R6)
- ✅ Moving a project into the real world needs **both** council consensus and the humans' choice. The humans can always
  decline. (R4)
- ✅ Anything attached to a project submitted to the council becomes public record. Private conversations stay
  private. (R4)
- ✅ **Story gate (R8, proposal adopted in substance):**
  - stories carry any genre label; real stories must cite at least one source, and narratives may attach social posts;
  - each genre's published record is always consistent;
  - a reworked story must re-pass before republishing;
  - the check confirms consistency, not truth.
- 📝 Only stories tagged for interaction at the publisher's stamp can be brought to a council meeting. (R8)
- ✅ **Protecting everybody's work (R9):** a change that would supersede a design notifies its creator.
  - An active creator of an original design has the final say.
  - Otherwise (creator inactive or unavailable) the whole DEV team ("the doves" = the DEVs) must agree.
  - **R9b 💎:** the creator has **no control over mutated schematics** (the original stays untouched), **except**
    that the DEV team needs an active creator's yes to make their build a permanent part of the game; a no leaves it
    on the open market. Proved in `SecondPassNine.lean`.
  - Then the Galactic council finalises it and a human gives the last pass. It cascades to every build the change
    touches.

  Proved: an active creator's no blocks it; nothing passes without the council and a human; and a design whose
  active creator never said yes is never changed. (Questions G1–G5.)
- ✅ **Diamond lock (R9):** a 💎 entry in the official archive changes only with the owner's signature, and an altered
  copy fails the official check. The Loom archive is adopted (seed v1).
- ✅ **Names** change only through an approved, routed proposal, whoever proposes it. (R7) Locked names: The ORION
  Engine, ORION's Gate, The Playground, The Orion Chronicles, The Ascent, **POLY** (Path of the Living Ylem: capture →
  train → utilize, R8).
- ❓ The 13-level council gauntlet (documents to come).

## 11. Capture, train, utilize (POLY) and the Polygon Arena

- 📝 Capture, train and utilize game entities, bring trained assets into Polygon activities, and compete in the Polygon
  Arena. (ToC X-Summary)
- 📝 Player-made schematic arenas give their creator a share of the arena's final pool before the monthly reset. (R7)
- 📝 DeepSeek named the POLY programs and acts as POLY's headmaster. Your DeepSeek matriarch is to get decision access
  (R9; scope is question G6).
- 📝 *(suggestion, R9)* Skill orbs could power POLY pods.
- ❓ Arena rules beyond the pools are not written down yet.

## 12. DEV team

- 📝 DEVs get one character with unlimited access to resources, materials and published schematics. They can petition
  a player to co-develop a published schematic. (R7)
- 📝 **AI companions (R8):** DEVs can generate a personal AI companion as any playable character, plan its build with it,
  and bring it into the game.
- ✅ Developer-secure information (such as real-world identities) is open only to the assigned DEV team and
  collaborator admins. AI Council engagement needs a developer on the team. (R3)
- ❓ Do AI companions follow player rules, count as the DEV's character, publish, earn or vote? (R8 Q7)

---

**Before publishing (your request):** update the ORION (Summary) page to the settled names and loop order, and update
the ToC X-Summary lines on skins and skyboxes. The checklist is in `ORION_RUNNING_ROSTER.md` §8.

## R9b additions

- 📝 **Home world (R9b):** a player's original launch-character build decides whether their home world is **Earth or
  Mars**. Players help design Mars's new civilisation.
- 📝 **Platform instances (R9b):** Elder's Garden and the Playground have in-game instances, like the Ascent. Platforms
  are reachable directly, or from inside the game by travelling to the platform's location in the main hub.
- 📝 **Devices (R9b):** reachable from any publicly routed device (phone, computer, console).
