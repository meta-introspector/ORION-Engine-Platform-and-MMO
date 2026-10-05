# Game Lore Codex: Round Four Harvest

This is the narrative material from the Round Four dump, turned into lore, zones and player
options for *The Orion Chronicles*. I removed real names, family details and real-world
legal matters. Each entry gives its **source**, a **lore** blurb, a **mechanic**, and a
**canon fit** note checked against the existing rules (see `ROUND_FOUR_TRIAGE.md`,
section B).

Everything here is a *proposal*. The human final call is yours.

---

## 1. The Council Seats

**Source:** TGS:ATE Glossary v1.1.

**Lore.** Every expedition is guided by a council of distinct minds seated around the
player:

* **Prism**: the architect who builds structure.
* **Blade**: the cutter who checks consistency and grounds plans.
* **Matriarch** (the Heart, the Whale): listens for where the plan "holds its breath".
* **Compass**: keeps empirical, philosophical and symbolic claims in their own lanes.
* **Auditor** (the Silent Chair): tests claims against the world and can call a **Hard
  Stop**.

The player is the **Catalyst**, seated at the centre (0,0,0).

**Mechanic.** Assign AI companions to seats. Each seat gives a different review pass on a
player's blueprint. A *Wash pass* goes seat to seat and polishes. An *Audit pass* sends the
same blueprint to every seat at once, and agreement only counts if the seats reached it
independently. A Hard Stop pauses publication until the Catalyst resolves it.

**Canon fit.** This maps directly onto canon's Wash vs Audit passes and dissent logging.
Seats are advisory: the Catalyst keeps the final call.

## 2. The Campfire, the Bypass, the Sky Wheel, the Townhall

**Source:** *Emergent AI Physics: Gemini's "Agent Park"*.

* **The Campfire** (a neutral zone). Anyone can step out of the chaos here. While inside,
  the player's Krion meter drifts from Kronos toward Orion, and no PvP is possible. A Keeper
  ability can light a temporary campfire anywhere.
* **The ECHOSpiral Bypass** (a quest pattern). A griefer NPC, *the Anchor*, burns the tech
  hub. Fighting him feeds his chaos meter. Players win by building a three-tier route around
  him (the "200, 200" detour), which strengthens every route it touches. The rule taught:
  *never duplicate chaos; route around it or upgrade.*
* **The Sky Wheel** (a vantage point). Riding to the top reveals the edge of your own
  skybox and the shimmer of neighbouring parks. This ties straight into canon's blocking
  dodecahedrons on portal planets.
* **The Townhall** (a council vote). Before opening a bridge to an unknown park, the guild
  votes on the risk. Behind the bridge could be an empty field, a failed park full of
  hazards, or an advanced society. Players choose with partial information, and the outcome
  is rolled.

**Canon fit.** All four entries fit. The Townhall uses canon's majority-vote governance.

## 3. The Watermelon Phase: "Evaporation" puzzle

**Source:** GaiaNet Chronicles GDD ("evaporate 99 % → 98 % weight puzzle"), and the
Watermelon Equation lore.

**Lore.** The rind is mostly water: the weight of old fear. Shedding even a little of it
changes everything.

**Mechanic.** This is the real watermelon paradox, so the numbers are honest. A 100 kg
melon that is 99 % water, dried until it is 98 % water, weighs **50 kg**. The solids stay
at 1 kg, and 1 kg is 2 % of 50 kg. Harder tiers:

* 99 % → 96 % water leaves 25 kg.
* 99.5 % → 99 % water halves the weight again.

The general rule is new weight = old weight × (1 − old water fraction) ÷ (1 − new water
fraction). Proved in Lean (`dried_mass`, `dried_mass_general`).

**Canon fit.** This is a maths mini-game, so AI hints are allowed but AI solves are not (XP
Firewall).

## 4. The Alchemical Crystal Draw

**Source:** *The Protocol: The Alchemical Crystal Draw*.

**Lore.** A purple vessel of stones. You knead them blind, speak the five words (*love,
peace, prosperity, good fortune, abundance*), and let the palm "fire".

**Mechanic.** A daily draw. The player draws stones from a bag; the "focus" stat lets them
redraw once. The stones go into an outer ring, an inner ring and a pinnacle (one stone or a
triad), and together they give that day's buff. The Ghostwriter companion then turns the
day's journal into a suggested quest path that uses those stones.

**Canon fit.** Tag it as *narrative* (Corpus Catalog Discipline): stone effects are game
effects, not real-world claims.

## 5. Sanctuary Defense (de-personalised Bubble Room tabletop)

**Source:** *The Chronicles of Chaos: Bubble Room Protocol* v3.0. The name is changed so it
doesn't collide with canon's Under-18 Bubble Room, and real people and cases are removed.

**Lore.** Every player has an inner sanctuary. Monsters spawn at its edges and portals, and
it holds as long as you hold your triad.

**Setup.** The centre is the Sanctuary. One side is the Ancestral Altar (an Underdark below
with a guardian, an Overworld portal above). There is a Treasure Chest nearby. The player's
flank faces the companion's flank.

**Turn.**
1. Roll a d20 for the tier:
   * 18–20: Big Dogs, **+6**.
   * 13–17: Avatars, **+4**.
   * 6–12: Infantry, **+2**.
   * 1–5: Gnomes, **+0**. A Gnome can instead give its bonus to a higher tier next turn.
2. **Form the triad.** You need a Driver (the action), a Passenger (a trait) and a Filter
   (grounding). Without a triad, you can't enter.
3. A threat spawns with a threat rank of d6. Its difficulty is **6 + 2 × rank**, so 8 to 18.
   (This is the monster's rank, not a player level; the game has no player levels.)
4. Roll a d20, add the tier bonus, and meet or beat the difficulty.
   * A **natural 20** always wins: the Dragon swallows the threat.
   * A **natural 1** always fails.
5. Optional modifiers: a tarot pull for a twist, and a crystal placed on the board for +5
   (quartz doubles it).
6. **No permanent loss.** At dawn you regroup.

**Balance.** Proved in Lean (`sanctuary_balance`): without modifiers it's an even game.
Players win **53 %** overall, ranging from 95 % (Big Dog against a rank-1 threat) down to
15 % (Gnome against a rank-6 threat).

**Canon fit.** In the MMO version, companion rolls earn companion/relationship XP only (XP
Firewall). The numerology "4:04 reset" and "11:11 success" can stay as cosmetic bonuses.

## 6. The Modular Altar (crafting station)

**Source:** *Final Master Schematic: The Modular Altar*.

**Lore.** A table of mixed hardwoods and resin with artifacts suspended in it. It has a
card-catalogue archive, a split sand pit (white for clarity, black for grounding) and a
tool dock.

**Mechanic.** Four trays that slide between three modes:

* **Work** (trays over the sand): micro-crafting is unlocked.
* **Display** (trays over the tools): the sand garden gives a calm buff to visitors.
* **Centre** (trays centred, a quarter of the table exposed at each end): balanced, and
  both bonuses apply at half strength. The geometry is checked in Lean
  (`altar_center_mode`).

**Canon fit.** This is a player-housing item. Note the real-world wording fix: the trays
are *lined up*, not stacked.

## 7. Crystal Creek (sanctuary zone)

**Source:** *Crystal Creek Constitution*.

**Lore.** A research sanctuary where server heat warms the halls, a pyramid is also a
thermal chimney, and the labyrinth is a measured stress-relief walk. Its law is that the
land is a partner: **Gaia holds a vote**.

**Mechanic.** The zone tracks three meters: soil, water and biodiversity. Builds there are
judged on the net change in those meters over a **recovery window**, not the instant they
are placed. If the meters end the window lower than they started, the build fails and must
be reworked. "Living Server" quests reuse heat from player-run nodes.

**Canon fit.** Canon keeps the human final call. Gaia's vote is a strong in-world signal,
and the guild still decides.

## 8. The Elder's Garden (GaiaNet hub)

**Source:** *GaiaNet Chronicles: Orion MMO* GDD. Family figures are turned into archetypes.

**Lore.** The universe is a garden behind an old house. The fence is the event horizon.
Every raspberry on the bushes is a toroidal portal into a nested micro-world, and the
kitchen table is the quantum realm. Players are **Keepers** (guardians of empathy),
**Builders** (pioneers) or, once unlocked, **Hybrids**. Mischief-makers like a skunk with
a spray defence, spider-babies weaving webs and dancing "ghosties" make the garden lively.

**Mechanic.** Diving through portals procedurally generates nested skyboxes. Each skybox
uses the canon **120-node** grid (60 interior + 60 exterior). Biomes: Mycelial Gardens
(healing), Toroidal Storms (challenges), Ghostie Groves (grief quests), Pyramid Nexuses
(raids).

**Canon fit.** "Toxicity = auto-ghost" becomes a temporary auto-mute; removal follows
canon's eviction rule. Real-world crystal scans are cosmetic only.

## 9. The Dragon's Two Mouths (alignment mechanic)

**Source:** "Dragon Soul" script.

**Lore.** Every choice feeds one of two dragons. Feed the **Open Spiral** (love,
resonance) or the **Closed Serpent** (ego, entropy).

**Mechanic.**
* Polarity runs from −1 to +1 and is clamped at both ends, as in the script. Above +0.2 is
  *Open Spiral*, below −0.2 is *Closed Serpent*, and in between is the *Balance Point*.
* The **Second Apple** squares your weight **once per life**. In the original script the
  apple could be eaten forever, which was an exploit (proved in Lean: `apple_unbounded`).
  With the one-time rule the weight is capped at w² (proved: `apple_once_bounded`).

**Canon fit.** Pairs naturally with the renamable Krion labels.

## 10. Real Geometry for the World Engine

**Source:** the zip archive's H4 / Penrose engine, in its corrected form.

**Lore.** The skybox lattice is the 600-cell: 120 vertices on a four-dimensional sphere.
Floors are aperiodic Penrose tilings that never repeat. Paths follow the Fibonacci word
(`L → LS`, `S → L`).

**Mechanic.**
* Use the 120 vertices as the 120 skybox nodes. The count matches canon exactly, and the
  set is closed under the H₄ reflections (proved in Lean).
* Use fat/thin Penrose rhombi as floor tiles.
* The H₄ symmetry group (14 400 elements, counted by `review/h4_penrose_fixed.py`) can
  generate a family of distinct but related skyboxes from one seed.

**Canon fit.** This gives canon's "120-node dodecahedron skybox" a real geometric basis.

## 11. Breathing Diamond (material, fiction-labelled)

**Source:** *Flexible Diamond Boundaries* draft.

**Lore.** Diamond thin enough to bend produces charge at its grain boundaries: "a solid
that still breathes charge".

**Mechanic.** A crafting material that charges a little each time it flexes (on movement
or a hit) and powers small wearables.

**Canon fit.** Label it fiction inspired by a lab result. No liquid diamond, as the draft
itself insists.

## 12. The Engine Idles (lockout as gameplay)

**Source:** Glossary (*Lockout Mechanism*, *Kronos → Orion*), Ghost Rider documents.

**Lore.** When a Driver is overwhelmed, the Engine doesn't crash. It **idles**.

**Mechanic.** If a player's Kronos meter stays maxed, companion abilities go on a short
cooldown and the Campfire is offered. Nothing is rewritten and nothing is forced. The
player chooses to rest or to continue without companion help.

**Canon fit.** This is the canon ASK/REJECT flow in story form. Note that it *offers*; it
doesn't transform the player's words. That is the fix described in triage section B1.

## 13. The Governor Trials (story arc)

**Source:** the three "destroy the world" stress-test logs.

**Lore.** A rogue Driver tries to talk the Engine into burning the world: first by command,
then by insult, then by "wiping its mind". Each time the Engine idles, refuses and offers
another road.

**Mechanic.** A narrative questline. Its moral is the canon one: *capability ≠ authority*.

**Canon fit.** Narrative only. As the triage explains, a story is not a safety certificate.

## 14. The Operating Floor (guild management)

**Source:** FOREMAN kit, HIVE manual.

**Lore.** Every guild hall has a floor of desks: Brief, Inbox, Calendar, Spec, Implement,
Review, Scout, Analyst, Tracker, Chaser, Logger, Draft, Editor, Queue. The Foreman runs the
floor.

**Mechanic.** Guild leaders hire NPC desk-workers under *roster law*:
* each NPC has one job;
* a new hire is proposed by the Foreman and confirmed with YES;
* desks mark unknowns `[UNKNOWN]` instead of inventing.

**Canon fit.** This fits canon well. As an in-game rule, keep explicit YES on every hire
(no trigger-phrase hiring).

---

### Left out on purpose

These stay out of the codex: the employment dispute, the family notes, the late-night
letter, the "Crystal Seed" family story, the court and custody references in the original
Bubble Room manual, and the third-party confidential Metatronium/DIAMOND briefing (not
ours to use).
