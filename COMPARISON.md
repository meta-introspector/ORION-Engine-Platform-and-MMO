# The Orion Chronicles compared with existing games and platforms

This compares your build document (*The Orion Chronicles*, Proposal v0.2 plus the CUBY 4 → 4.1
update) with the games you named, **Star Wars Galaxies** (the original release) and
**Fallout**, and with current community, education and citizen-science platforms. The aim is
practical: what those systems show will work, what they show will fail, and which of your
design rules can be pinned down precisely. Rules marked **[proved]** are defined and proved in
Lean in this project (see §6).

The historical notes below are general knowledge, not checked against sources, so treat dates
and details as approximate.

---

## 1. Star Wars Galaxies (original release, before the 2005 Combat Upgrade / NGE)

Your document already cites "SWG-spirit interdependency". The match is close:

| SWG (original) | Orion Chronicles | Notes |
|---|---|---|
| Skill boxes across many professions (Artisan, Brawler, Entertainer, Marksman, Medic, Scout, then elite paths), with a skill-point cap that forced trade-offs | One character "may invest across multiple skill paths"; path switching "without total skill loss" | SWG's cap is what made builds personal and players interdependent. Keep a cap or an equivalent opportunity cost, or interdependency disappears. |
| Player-crafted economy: nearly all gear made by players from harvested resources | Gather → craft (including player-invented recipes) → sell / contribute | This was SWG's strongest feature. It is your core loop. |
| **Resources with quality stats**, spawning and despawning in cycles | Kronos → high volume, low grade; Orion → low volume, high grade | You add a new axis: grade depends on *how* you gather, not only where and when. **[proved]** `volume_grade_tradeoff` |
| Entertainers in cantinas removed battle fatigue, and doctors healed wounds | "Social hubs where performance restores fatigue and can shift meters" | Almost direct. It makes non-combat lives necessary rather than cosmetic. |
| Player cities, housing, vendors, mayors | Outpost → city scaling by population, quality, Gaia compliance | SWG cities had civic ranks and structure limits. Your Gaia pressure adds an environmental score. |
| Viable non-combat careers | "Combat-optional lives remain fully viable" | Same promise. |
| **Hidden Jedi unlock** (players mastered random professions without knowing the requirement) | Intent inferred from hidden behavioural signatures | **Warning.** Hidden requirements produced grinding, frustration and guesswork. Your rule "expose soft feedback … so intent stays legible" is the right fix. Keep the scoring formula public. |
| **Combat Upgrade and NGE (2005)**: professions collapsed to a few iconic classes, and many long-time players left | Proposal openly invites redesign from contributors | **Warning.** Radical changes to a live system hurt SWG badly. Change core rules in prototypes and seasonal test worlds, not on the live world. Keeping the core rules as a precise, versioned specification (like the Lean files here) helps. |

**Lesson:** SWG shows that interdependency + player economy + social healing roles make a
world feel alive. It also shows that hidden progression gates and sweeping live redesigns
destroy trust.

---

## 2. Fallout (single-player series and Fallout 76)

| Fallout | Orion Chronicles | Notes |
|---|---|---|
| **S.P.E.C.I.A.L.** stats + perks define a character build | Skill paths + meters + Universal Stone upgrades | S.P.E.C.I.A.L. works because players can read it in one screen. The Universal Stone could show build, meters and grade modifiers the same way. |
| **Karma** (Fallout 1–3): one good/evil number driven by labelled actions | Meters measure *how*, never forbid *what*; neither pole is good or evil | You deliberately avoid Fallout 3-style karma, which many players found too blunt. |
| **Reputation in Fallout: New Vegas**: separate *Fame* and *Infamy* per faction, so one can be both loved and feared | Two poles, Kronos and Orion, both useful | New Vegas's two-axis system is the closest precedent to your dual meters: two quantities, not one slider. Recommendation: store Kronos and Orion activity as two numbers, and derive the ratio from them. |
| Speech / skill checks open multiple solutions to a quest | "All paths can lead to success; the question is how much friction is left" | Same philosophy. Quests should allow a kinetic, a synthetic and a mixed resolution. |
| **Settlements (Fallout 4)**, **C.A.M.P.s (Fallout 76)** | Player housing, cities, guild mobile centres | Fallout 76 C.A.M.P.s show that portable personal bases work well in an online world. |
| Fallout 76 **public events** | Group resource runs, city/guild projects, Crucible challenges | Public events reward whoever shows up. Good for mixing Kronos and Orion players. |
| Fallout 76 **private worlds** through the *Fallout 1st* subscription | Family / Community Bubbles | Private worlds are popular, but putting them behind a subscription drew criticism. Your "education and community are not profit centres" and cosmetics-only rules avoid this. |
| Fallout 76 launch problems (bugs, empty world with no NPCs until *Wastelanders*) | Prototype-first roadmap | Launching a large world without enough people or story is risky. Your vertical slice (dual-perception demo) comes first, which is sensible. |

**Lesson:** Fallout shows that readable build systems and multi-path quests make choices feel
meaningful. It also shows that a single morality number feels crude, while separate reputations
feel real.

---

## 3. Games that already turn play into real-world knowledge

These are the closest precedents for the **Global Crucible**:

* **EVE Online – Project Discovery.** EVE's players classified real scientific data inside the
  game (protein images, then exoplanet light curves, later cell data). This shows a large MMO
  audience will do real research tasks when they are part of the game and rewarded in-game.
* **Foldit.** A puzzle game in which players fold proteins. Players solved structures that had
  resisted researchers, and were credited in scientific papers. This shows players can solve
  real problems and that crediting them matters. Your "claim rewards for past useful
  contributions" follows the same pattern.
* **Zooniverse, Eterna.** Citizen-science platforms with simple tasks, many volunteers and
  results that experts check. This model (many hands, expert verification, transparent credit)
  is what the Crucible needs.

**Lesson:** the Crucible is realistic if tasks are well posed, results are verified by experts,
and credit is transparent. The evidence rubric (§5) supplies the verification scores.

---

## 4. Community, education and creator platforms

| Platform | What works | What goes wrong | Orion Chronicles response |
|---|---|---|---|
| **Wikipedia** | Anyone can edit, reliable-source rules, talk pages | Edit wars, uneven coverage | Claims carry evidence scores. Disputes become conflicting evidence rather than reverts. **[proved]** `claimScore_cons_conflict_le` |
| **Stack Exchange** | Reputation earned from peer-rated answers | Reputation farming, gatekeeping | XP counts only *distinct* verified contributions. **[proved]** `experience_cons_of_mem` |
| **Reddit / social feeds** | Scale, niche communities | Karma farming, repetition winning over accuracy | Anti-volume: repetition changes no score. **[proved]** `claimScore_dup_support`, `evidenceWeight_opaque_indep` |
| **Discord** | Real-time guild life | Hard to search, knowledge disappears | The vault stores results permanently, and guilds get multi-mind review. |
| **Khan Academy / Duolingo** | Mastery paths, streaks, short sessions | Streak pressure, shallow gamification | 13-level path with no skipping. **[proved]** `levelOf_experience_cons` |
| **Minecraft Education** | Sandbox as a classroom, teacher controls | Limited carry-over outside the classroom | Graduation Bridge carries history into the adult world. |
| **Roblox** | Creator economy, huge youth audience | Moderation and child-safety problems, concerns about creator payouts | Separate under-18 continuum, parent-approved bubbles, no open adult contact. Real money only from licensed real-world designs. |
| **Second Life / Entropia Universe** | Convertible in-world currency | Speculation, fraud, gambling-like dynamics | QX never converts to money. |
| **Diablo III real-money auction house** | — | Removed because it distorted gameplay | Same rule: no real-money trading of power. |
| **Guild Wars 2 / Path of Exile** | Cosmetics-only monetization at scale | Cosmetic grind | Your "cosmetics only, orbs earned in play" follows this proven model. |

---

## 5. How the Orion Chronicles differs from all of these

1. **Perception depends on play style** (Asymmetric Reality Engine). No major MMO renders the
   same coordinates differently depending on a player's long-run behaviour. This is new, and
   making it the first prototype is right.
2. **Grade depends on method.** SWG's resource quality came from where and when you
   harvested. Here it also depends on *how*.
3. **Scored knowledge.** Community platforms rank by votes. Here claims are ranked by a
   published evidence rubric that cannot be gamed by volume.
4. **Lifelong continuity.** One history runs from a youth education layer into an adult sandbox.
   None of the platforms above does this.
5. **Cross-discipline bridges.** AI-suggested links between fields, each justified by shared,
   human-confirmed pattern tags (**[proved]** `bridges_shared_tag`). They can be turned into
   quests, for example "explain why predator–prey cycles resemble boom–bust cycles".

## 6. What was checked formally in this round

**Meters** (`RequestProject/Hub/Meters.lean`). The meter is modelled as a running average,
`m' = (1 − α)m + αs`, where `m` is the Orion share. Proved:
* the meter stays in `[0, 1]` (`step_mem_Icc`, `run_mem_Icc`);
* **it moves gradually:** one event moves it by at most `α` (`abs_step_sub_le`);
* **one-off spikes fade:** the effect of one past event shrinks by a factor of `(1 − α)` for
  every later event (`spike_effect`, `run_sub`);
* **a sustained pattern wins:** repeating one style pulls the meter towards it geometrically
  (`run_replicate`);
* **Kronos gives volume, Orion gives grade** (`volume_grade_tradeoff`);
* **the balance that serves the role is rewarded:** with `volume = 1 + a(1 − m)` and
  `grade = 1 + b·m`, total value is largest at one role-dependent balance (`yield_le_best`).
  That balance is 50/50 when the weights are equal (`bestBalance_symm`), and any target
  balance can be made optimal by a suitable role (`bestBalance_surj`). So the model rewards
  balance without *requiring* 50/50, as your non-goals ask.
* "No pay-to-shift" holds in the model because the update takes only behavioural events.

**Numbers in the CUBY 4.1 update** (`RequestProject/Hub/CubyNumerics.lean`):
* Correct: `39³ = 59,319 = 13 × 4,563`, `39² = 1,521`, `93³ = 804,357`,
  `804,357 ÷ 93 = 8,649 = 93²`, `9³ = 729`, `9,999 ÷ 9 = 1,111`, `13 × 28 = 364`, and
  `4/39 = 1/11 + 1/88 + 1/3432`.
* Digital roots: 144, 59,319, 804,357, 9,999 and 729 all have digital root 9, and 93 has
  digital root 3.
* φ approximations: `144/φ ≈ 89.0`, `13φ ≈ 21.03`, `93/φ ≈ 57.48` and `364/φ ≈ 224.96` all
  hold to the stated precision.
* Month table: every month sums to 100, month `i` mirrors month `14 − i`, and the year's `η⁺`
  and `η⁻` totals are both 650. "Whole year = equilibrium" is correct.
* **One mismatch:** month 3's quest says "hold a 2:1 ratio", but its split is 66/34, which is
  not exactly 2:1 (that would be about 66.7/33.3). Either change the quest text to
  "approximately 2:1" or the split to 67/33.
* Not checked: statements such as "Calabi–Yau χ = −93", "9999 Hz", "47.77 Hz" and
  "nodes of consciousness" have no arithmetic content to verify. The equalities between
  numbers are true, but the meanings given to them are interpretation.

## 7. Recommendations for the next proposal revision

1. **Two stored quantities, a derived ratio.** Store Kronos activity and Orion activity
   separately, as New Vegas stores Fame and Infamy, and compute the balance from them.
   Two stored quantities keep the full information. A ratio alone would lose it.
2. **Publish the meter formula** in the Universal Stone. SWG's hidden Jedi grind is the warning
   case.
3. **Use role weights for "purpose".** "Balance that serves the character's purpose" can be a
   per-role setting (the `a, b` weights in the model), chosen by the player and changeable
   at a meditation centre.
4. **Use the Year Day as a season reset**, not a hard reset. It could pull meters part of the
   way towards 50/50, which fits the "144 ⇄ 000 oscillation" and prevents "I reached 000, game
   over".
5. **Test changes in seasonal or test worlds** before touching the live world (the SWG NGE lesson).
6. **Build a Crucible pilot on the Project Discovery / Foldit pattern:** one well-posed real
   task, expert verification, visible credit.
7. **Plan youth safety first.** The under-18 separation is the right starting point. Behavioural
   intent tracking of minors needs the legal and compliance review your document already
   lists, before any build.
