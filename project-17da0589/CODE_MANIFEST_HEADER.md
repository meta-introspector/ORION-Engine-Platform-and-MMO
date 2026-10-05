# Code manifest and comparison notes

This file is the "CODE export" asked for in the comparison against the OEPPF / Round Three build. It lists every
file in this project (Appendix A) and every theorem in the Lean files (Appendix B), so the comparison can be done
file by file and line by line, not only from the Properties panel.

To regenerate it after any change: `python3 review/make_code_manifest.py`. The hand-written part is
`CODE_MANIFEST_HEADER.md`; the appendices are generated.

## How to check it yourself

- `lake build` builds every Lean file. It finishes with no errors and no `sorry`.
- Every theorem in the project uses only Lean's standard axioms (`propext`, `Classical.choice`, `Quot.sound`, plus
  the compiler-trust axioms `Lean.ofReduceBool` / `Lean.trustCompiler` that `native_decide` uses). No theorem
  depends on `sorry`.
- The four Python files each run on their own and print their self-test result:
  `python3 orion/gate_reference.py`, `python3 review/ghost_rider_v3_check.py`,
  `python3 review/anti_babel_await_check.py`, `python3 review/h4_penrose_fixed.py`.
  They are executable sketches and checks, not proofs.

## Panel count versus code count

The Properties panel shows the headline results picked out for review. The Lean code holds
**739** named theorems and lemmas (Appendix B); the rest are companion facts, earlier versions and supporting steps.
"Proved" in either place means proved about the rules **as written down in the Lean definitions**. There is no game
or platform code in this project, so nothing here is a proof about a running system.

## Corrections to the comparison

### 1. The safety kernel *is* in this project

The comparison says the Gate / Roles / Consensus / Record / Shares files "may still be in the repo". They are, and
they build with everything else:

| File | What it covers |
| --- | --- |
| `RequestProject/Orion/Gate.lean` | Execution gate (Ryan's Round Three contribution): an unmapped lever never executes however strong the plight; the emergency path stays inside a pre-delegated envelope (listed levers and deeds, blast/residue caps, expiry, use count); total exposure over a run is bounded; a sub-envelope never permits more than its parent; jurisdiction over every deed touched; the decision never commits an unmapped lever but always offers halt/reverse under a real plight; break-glass needs two distinct humans and a cooling-off delay; the audit verdict doesn't depend on the outcome. |
| `RequestProject/Orion/Roles.lean` | Separation of roles: fewer principals than roles can't separate them; a copilot alone can't separate them and holds at most one role; an offline assignment that does separate them exists. |
| `RequestProject/Orion/Consensus.lean` | Correlated reviewers: effective number of independent reviewers, between 1 and n, falls as correlation rises. |
| `RequestProject/Orion/Record.lean` | Append-only record: pushing keeps history, the root entry is preserved, the digest is injective, tiering is lossless. |
| `RequestProject/Orion/Shares.lean` | Credit allocation: floor allocation never over-allocates, the final allocation sums exactly and each share is within one unit; responsibility shares sum to one, out-of-scope parties get zero. |
| `RequestProject/Orion/Tests.lean` | Held-out "cousin" cases: an answer that encodes the claim passes every cousin, one that fails a cousin was pattern-matching. Metaphor gate: "Seashell Spirals = Fibonacci" passes its check, a troll substitute (powers of two) fails it. |
| `orion/gate_reference.py` | Runnable Python sketch of the same gate, with self-tests. |
| `review/ghost_rider_v3_check.py`, `review/anti_babel_await_check.py` | Checks on the Ghost Rider and anti-Babel code that was shared earlier. |

So the platform-safety layer (no self-authorisation, envelopes, dual break-glass) is formalized here too. It's just
not what the Round Three curation entries on the panel are about.

### 2. 43 versus 46 is not a mismatch

The Core roster in `RequestProject/Zoo/Arena.lean` has **46** entries. `EFMWZoo.coreRoster_spec` proves it has 46
distinct names and that its first 23 are exactly the v1 inventory.

The **43** is the number of dragon **species**. Following the curation answers, `HIVE`, `PULSE` and `SHEPHERD` are
archetype upgrades, not animals. `RoundThreeCuration.roster_split` proves:

\[ 46 \text{ Core entries} = 43 \text{ species (including } \texttt{DRAGON} \text{ and } \texttt{PHOENIX}) + 3 \text{ archetypes.} \]

The species list is computed from the 46-entry roster by removing the three archetypes, so the two numbers can't
drift apart. The canonical number for the Proofs Arena roster is 46. The canonical number for "species a dragon
can be built on" is 43. The older `RoundThreeDragon.speciesChoices` (all 46 as builds) is kept in the code, marked
*Superseded*.

### 3. What is genuinely not here

- **Ryan's Formal Kernel v0.3 / ProtoASI package** (authority state machine, "learning does not grant
  authority"). Those ZIPs were never shared with this project, so nothing here formalizes or checks them. The
  Round Three gate above is based on his Round Three contribution summary and transcript only.
- **Kronos / Orion meters and dual perception.** Only the aggro side is modelled: Kronos-aligned (kinetic)
  skills reset aggro, ORION-aligned debuffs and heals don't (`RoundThreeClarifications`, `RoundThreeCuration`).
  The meters themselves aren't formalized.
- **Education / Global / Social hubs.** Not formalized.

## The four answers still needed

Until these are answered, the proofs assume the reading shown. Each is a one-word answer.

| # | Question | What the proofs assume now | Where |
| --- | --- | --- | --- |
| 1 | Rounding: do costs round **up** and payouts round **down**? | Both halvings are defined; `rounding_spec` proves they differ by at most 1 and only on odd amounts. Which one applies to costs and which to payouts isn't fixed yet. | `RoundThreeCuration.rounding_spec`, `ROUND_THREE_CLARIFICATIONS.md` §8.5 |
| 2 | Keep the lock names "Gold Lock" (64 character nodes) and "Black Hole lock" (144 dragon nodes)? | These names. Renaming doesn't change any proof. | `ROUND_THREE_CLARIFICATIONS.md` §8.6 |
| 3 | In a group, does casting a Kronos (kinetic) skill while a teammate is aggroed aggro **only the caster**, for the full 10 minutes? | Yes (`join_fight`). Members who cast nothing kinetic are never aggroed by the group (`stays_inactive`, proved regardless of this answer). | `RoundThreeCuration.join_fight`, §8.8 |
| 4 | Can **any** species take the `HIVE` / `PULSE` / `SHEPHERD` archetype, or only the generic `DRAGON`? | Any species: the model puts no species restriction on archetype upgrades. | `RoundThreeCuration.archetypes_valid`, `ROUND_THREE_CLARIFICATIONS.md` "Still open" |

## Older entries that were replaced

These stay in the code so the history is visible. Each is marked *Superseded* in its docstring and points at its
replacement:

- `RoundThreeDragon.speciesChoices` (46 builds) → `RoundThreeCuration.speciesChoices` (43 species + 3 archetypes).
- `RoundThreeDragon.canPlantSeed` → `RoundThreeCuration.canHatch` (the skybox gate needs the quest-line escape or a key).
- `RoundThreeDragon.looks_do_not_matter` → `RoundThreeCuration.skin_never_matters` (body and archetype affect abilities; only skin never does).
- The mid-encounter PvP refusal in `RoundThreeRulings` → the toggle in `RoundThreeClarifications` that records the request and applies it when the encounter ends.
- An earlier reading of the gift rules in `RoundThreeFollowups` → the gift rules in `RoundThreeRulings` (numbered queue slots 1–20, sender's warning, schematic-based points).
