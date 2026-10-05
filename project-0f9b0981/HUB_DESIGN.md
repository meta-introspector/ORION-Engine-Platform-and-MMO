# A global knowledge hub on the ORION framework: design and verified core

This document sketches a platform where people learn, discuss and play together around
shared knowledge (a community hub, an education layer and a game/MMO layer), with AI
assistants that help spot patterns across disciplines. It builds on the ORION Engine
Architecture and the linked TGS:ATE documents reviewed earlier (see `NOTES.md`).

Most of a platform like this is product, community and engineering work, and a proof
cannot settle it. The parts that *can* be settled are the scoring and matching rules that
decide what the platform trusts, recommends and rewards. Those are exactly the rules people
will try to game, so they are defined precisely and proved in Lean
(`RequestProject/Hub/`). The build has no `sorry` and uses only the standard axioms.

---

## 1. Architecture at a glance

| Layer | What users do | ORION source idea | Verified core |
|---|---|---|---|
| **Knowledge graph** | Post claims, attach evidence, challenge claims | Operation Snake and Scale evidence rubric `W(e)` | `Hub/Reliability.lean` |
| **Pattern bridges** | Browse AI-suggested links between fields | Open Research Intelligence Optimization Network (cross-disciplinary synthesis) | `Hub/CrossDiscipline.lean` |
| **Learning path / MMO progression** | Level up by contributing verified knowledge | The 13 Levels of Geometric Integration | `Hub/Progression.lean` |
| **Safety and governance** | Humans review and confirm what the AI proposes | A Human-Centered Approach to AI Safety | design rules (§5) |
| **Shared spaces** | Meet in themed rooms, study halls and game worlds | The 4th Space, Tri-Sphere Architecture | design only |

### Data model (minimal)
* **Concept**: a node with a discipline label and a set of *pattern tags*
  (`feedback-loop`, `phase-transition`, `network-effect`, `symmetry`, …).
* **Claim**: a statement about one or more concepts.
* **Evidence**: source tier `S_t`, rigor `R_m`, number of independent sources `n`
  (the fields of `W(e)`), attached to a claim as *supporting* or *conflicting*.
* **Contribution**: a claim, with its supporting and conflicting evidence, submitted by a user.
* **Learner**: holds a set of contributions, from which XP and level are computed.

---

## 2. Claim reliability (`RequestProject/Hub/Reliability.lean`)

The earlier review found that the page's `D_r` is circular (it divides values of `W`, and
`W` already contains `D_r`) and undefined when nothing supports the claim. The hub fixes
both:

* the ratio uses **base weights** (`W(e)` with `D_r = 0`), so nothing is circular;
* each side is weighed by its **strongest** item, not the sum, so volume alone cannot win;
* no support means `D_r = 1`;
* claim score = `best_support × (1 − D_r) / 1.5`, a normalised score.

**Proved:**
* `claimScore_eq`: the score equals `max(0, best_support − best_conflict) / 1.5`.
* `claimScore_mem_Icc`: every score lies in `[0, 1]`. `claimScore_max`: the value 1 is
  reached (uncontested primary, cryptographic, 5 sources). `claimScore_nil`: a claim with no
  support scores 0. `discrepancy_mem_Icc`: `0 ≤ D_r ≤ 1`.
* **Anti-volume:** `claimScore_dup_support` and `claimScore_dup_conflict` say that repeating
  evidence already on file changes nothing. `claimScore_weak_support` says that piling on
  support weaker than the best item changes nothing.
* **Monotonicity:** more support never lowers a score (`claimScore_cons_support_ge`). More
  conflict never raises it (`claimScore_cons_conflict_le`).
* `claimScore_pos_iff`: a claim scores above 0 exactly when its strongest support outweighs
  its strongest challenge.

*Design choice to review:* using the maximum instead of a sum means that many independent,
strong corroborations help only through `n` inside `W(e)`, which caps at 5 sources, and not by
being added together. That is the anti-volume intent. If you want summing, the anti-volume
theorems would need a different mechanism, such as deduplicating by source identity.

---

## 3. Cross-discipline pattern matching (`RequestProject/Hub/CrossDiscipline.lean`)

AI assistants propose pattern tags for each concept, and human curators confirm them. The
hub compares two concepts by the **Jaccard similarity** of their tags, and suggests a
**bridge** when the concepts come from *different* disciplines and the similarity is at
least a threshold `θ`. Example: "predator–prey cycles" (ecology) and "boom–bust cycles"
(economics) share `feedback-loop` and `oscillation`.

**Proved:**
* `jaccard_comm`, `jaccard_nonneg`, `jaccard_le_one`: similarity is symmetric and in `[0, 1]`.
* `jaccard_eq_one_iff`: similarity is 1 exactly for identical nonempty tag sets.
  `jaccard_eq_zero_iff`: it is 0 exactly when the concepts share no tag.
* `mem_bridges`: the suggestion list contains **exactly** the cross-discipline pairs at or
  above the threshold (sound and complete). `bridges_symm`: suggestions are symmetric.
  `bridges_cross`: a suggestion never stays within one discipline.
* `bridges_shared_tag` (**explainability**): for any `θ > 0`, every suggestion has at least
  one concrete shared tag, which the interface can show as "linked because both involve …".
* `bridges_antitone`: raising `θ` only removes suggestions.

The AI's role is therefore bounded. It proposes tags, humans confirm them, and the
suggestion rule is a fixed, checkable function of the confirmed tags. It is not an opaque
ranking.

---

## 4. Progression: the 13-level path (`RequestProject/Hub/Progression.lean`)

The learning path and the game layer share one progression. XP is the total claim score of a
learner's **distinct** verified contributions, and
`level = min(13, 1 + ⌊XP / k⌋)` with `k` XP per level.

**Proved:**
* `one_le_levelOf`, `levelOf_le_13`: levels run from 1 to 13. `levelOf_twelve_mul`: Level 13
  is reached at `12k` XP. `levelOf_mono`: level never drops as XP grows.
* `experience_cons_of_mem` (**anti-farming**): resubmitting a contribution already on file
  earns no XP.
* `levelOf_experience_cons` (**no skipping**): with `k ≥ 1`, one more contribution raises a
  level by at most one, so all 13 levels are passed in order.
  `levelOf_experience_cons_ge`: a new contribution never lowers a level.

Ideas for the game layer, not formalized: levels unlock areas of a shared world (study halls,
field-specific "realms", and bridge quests that ask players to explain or test a suggested
cross-discipline link). Guilds form around disciplines, and cross-guild quests reward bridges.

---

## 5. Safety and governance rules (design, following the human-centred AI-safety page)

1. **Humans decide.** AI proposes tags, summaries and candidate bridges. Only confirmed
   tags feed into matching, and only reviewed evidence feeds into scores.
2. **Every number can be explained.** Scores use the published formula (§2). Bridges show
   their shared tags (§3). Levels follow the published formula (§4).
3. **Volume cannot win.** Anti-volume and anti-farming are *proved properties*, not
   intentions.
4. **Contest, don't delete.** Disagreement is recorded as conflicting evidence, which lowers
   a score in a predictable way.
5. **Privacy and moderation** follow standard practice: minimal data, transparent
   moderation logs, appeal routes. These are outside the formal model.

---

## 6. Roadmap

1. **Pilot knowledge graph:** a few hundred concepts in 5–6 disciplines, with the
   scoring and bridge rules implemented to match the Lean definitions.
2. **Education layer:** courses organised as paths through concepts, with bridge
   quests as capstone exercises.
3. **Community layer:** discussion threads attached to claims, curator roles, guilds.
4. **Game/MMO layer:** a shared world where areas map to disciplines and portals map
   to verified bridges.
5. **Keep the implementation tied to the proofs:** keep the Lean definitions as the reference
   specification. Test the production code against them, for example with generated test
   cases evaluated in Lean with `#eval`.

## What is not covered
The proofs cover only the scoring, matching and progression rules as defined here. They do
not show that the tier values are the right ones, that AI-proposed tags are accurate, or
that the platform will be engaging or safe in practice. Those are empirical and design
questions.

---

## Update: the *Orion Chronicles* build document

A comparison with Star Wars Galaxies, Fallout, and current community, education and
citizen-science platforms is in `COMPARISON.md`. That round also added two Lean files:
* `RequestProject/Hub/Meters.lean`: the Kronos/Orion meters as a running average. Proved
  properties: the meter moves gradually, spikes fade, a sustained pattern wins, Kronos gives
  volume and Orion gives grade, and the best balance depends on the role, so 50/50 is not forced.
* `RequestProject/Hub/CubyNumerics.lean`: every checkable number in the CUBY 4.1 update. All
  of them hold except month 3's "2:1", which is 66/34.
