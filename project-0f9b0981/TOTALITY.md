# Totality: what exists, what this round adds, and what the platform still needs

## 1. What the project has accomplished so far (plain language)

The earlier rounds read the TGS:ATE / ORION documents and did two kinds of work:

* **Checked the claims that can be checked.** The numbers, formulas and worked examples were
  proved correct or shown to be wrong in Lean, a proof checker. Examples: the `W(e)` evidence
  formula, the 144/36 arithmetic, the Civ One 17-turn minimum, the bott Clifford matrices, the
  3-6-9 digital roots, and the DASL address examples (which do not decode as the document says).
  `NOTES.md` and `ARISTOTLE_SUMMARY.md` list them.
* **Designed the rules that decide what the platform trusts and rewards, and proved they do what
  they promise.** Claim scores stay between 0 and 1. Repeating evidence can't inflate a score.
  Resubmitting work earns no XP. Levels 1–13 can't be skipped. Cross-discipline "bridges" always
  show a shared reason. The Zoo gate never lets hypotheses count as evidence. See `HUB_DESIGN.md`
  (`RequestProject/Hub/`), `COMPARISON.md` and `ORION_TOOLS.md`.

In short, what exists is a **verified rulebook and design documents**, not running software.

## 2. Can the platform, education hub and MMO be built here?

In part. This project can deliver:

* precise, machine-checked **specifications**: the definitions and guarantees a real
  implementation has to meet;
* **reference implementations** of the rules in Lean. These can be run with `#eval`, so
  production code can be tested against them;
* design documents, reviews of submitted material, and checks of claims.

This project cannot deliver servers, a web front end, a 3D client, networking, accounts,
moderation, hosting, or a live community. Those need a software team, for example with a
Rust, TypeScript or C# game runtime. Matthew's plan already assumes this split: a modular runtime,
plus "a second formal layer in Lean for invariants and theorem-level claims rather than
trying to implement the real-time simulator itself in Lean". **This round builds that second
layer for the "one room" milestone.**

## 3. This round: the Lean invariant layer for Minimum Viable Totality

Files:

* `RequestProject/Totality/Core.lean`: the generic layer. It works for any state type and any
  intervention type, so one room, a house, a village, a city or the world all get the same
  guarantees.
* `RequestProject/Totality/Room.lean`: rooms with two agents and a player channel, plus a
  concrete test room.

Everything builds with no `sorry` and uses only Lean's standard axioms. The concrete room's facts
are checked by Lean's kernel (`decide +kernel`), not by compiled code.

### Module-by-module (Matthew's layout → what is proved)

| Runtime module | Lean definition | Guarantee proved |
|---|---|---|
| `/world`, `/archimedes` | `Engine`: a pure `step seed state intervention` | Same inputs always give the same outputs. `run_append`: running two command lists back to back is the same as running them joined |
| `/provenance` eventgraph, replay | `Event`, `record`, `CoherentFrom` | `eq_record_of_coherent`: **exact replay**. Re-running the recorded seeds and interventions rebuilds the whole log, field by field. `replay_final`: the last recorded state is the replayed state |
| "Why did this happen?" | `event_explained`, `causal_link`, `Room.why` | Each event's result is exactly the physics applied to its parent state, seed, both agents' decisions and the player's input. Each parent is the previous event's child, so the chain leads back to the start |
| `/zoo` audits | `audit`, `zooPass` | `audit_iff`: the replay audit accepts **exactly** the coherent logs. `audit_rejects_tamper`: any edited log is rejected. `zooPass_cons`: adding an auditor never turns a fail into a pass |
| `/efmw` coherence, residuals | `residuals` | Logs the engine writes have no residuals. In the demo, the monitor names exactly the edited event |
| `/janus` counterfactuals | `janus_agree_before`, `janus_branch_point` | A counterfactual that changes the history at time *t* matches the actual history at every time up to *t*. The future cannot rewrite the past |
| `/cuby` branching, `/borges` histories | `branches` | `branches_length`: exactly *k*ⁿ histories are stored. `branches_sound`: every stored branch replays to its stored state. `branches_complete`: no possible history is missing |
| `/thor` constraints | `Preserves`, `thorWarnings` | A constraint kept by every step holds in every history, branch and replay, and the monitor never warns |
| `/dragon` attractors, regimes | `dragon_eventually_periodic`, `dragon_stays_in_cycle` | With finitely many states, every free-running regime eventually cycles. The lead-in plus the period is at most the number of states, and once in the cycle it never leaves |
| `/agents` perception, memory, executive | `Room`, `decision₁/₂` | `decision_blind`: an agent reacts only to what it observes and remembers. `memory_suffix`, `memory_length`: memory is append-only and grows by one observation per step |

### The test room and the 10 success criteria

Three balls on a ring of 6 cells, each with a position and a velocity. A "push" moves one unit of
velocity from a ball to the next ball. Agent 1 sees only where balls 0 and 1 are. Agent 2 sees
only where ball 2 is. Neither sees velocities. The player can push any ball, and the seed adds a
deterministic "noise" push on some steps.

| # | Criterion | Result in Lean |
|---|---|---|
| 1 | deterministic, reproducible evolution | `demo_audit`: a 10-event log passes the replay audit |
| 2 | agents with incomplete observations | `agent1_view_incomplete`: two worlds agent 1 can't tell apart get the same decision, yet evolve differently |
| 3 | persistent agent memory | `demo_memory`: after 10 steps, 10 observations are remembered and the first one is still there |
| 4 | Cuby branching | `demo_branch_count`: 4 player options, 4 steps deep, gives 256 branches |
| 5 | Janus counterfactuals | `demo_janus_prefix` (same past), `demo_janus_diverges` (different future) |
| 6 | Dragon regime detection | `demo_dragon_cycle`: the free-running room cycles with least period 6 |
| 7 | Borges branch storage | `demo_branches_conserve`: every stored branch replays exactly and conserves momentum |
| 8 | EFMW coherence monitoring | `demo_tamper_residual`: the monitor flags exactly event 2 in the tampered log |
| 9 | Zoo auditing | `demo_tamper_rejected` |
| 10 | exact replay from provenance | `demo_replay` (from the general `eq_record_of_coherent`) |
| Thor | physical constraint | `momentum_preserved`: total momentum is conserved for every seed, decision and intervention |

`demo_agent1_acts` shows the agents aren't idle: agent 1 pushes ball 0 at step 6. Agent 2 never
acts in this particular run.

### Provenance fields (item 14) and how they are covered

* **Stored in each event:** `event_id`, `parent_state`, `child_state`, `random_seed`,
  `interventions` and `engine_version`. `timestamp` is the step index (= `event_id`).
* **Recomputed exactly from stored fields:** `observations` and `agent_decisions`. They are
  functions of the parent state (`Room.why`). A runtime may still cache them. The audit then
  checks the cache against the recomputed values.
* **Fixed by `engine_version`:** `equations_used` and `parameters`. In the formal model the
  engine *is* the equations. A real runtime should hash the equation registry into the version.
* **Monitor outputs, not inputs:** `warnings`, `Zoo results` and `confidence`. These are computed
  from the log (`thorWarnings`, `residuals`, `audit`), so they can always be recomputed and
  checked.

## 4. How to use this in the real engine

1. Write the runtime in whatever language the team prefers, with Matthew's module layout.
2. Make every step a pure function of `(seed, state, intervention)` and log the event fields above.
   This is the one design rule the replay theorems depend on.
3. **Differential testing.** Export small scenarios from the runtime and replay them in the
   Lean reference with `#eval`/`decide`, as `demo_audit` does. Any disagreement is a bug in one
   of the two.
4. When the room works, scale up. The generic theorems don't change for a house, village, city or
   world. Only the concrete `physics`, observations and policies change, plus new domain
   constraints for Thor to prove.

## 5. What is not covered

* Real-time performance, networking, rendering, continuous (floating-point) physics and
  concurrency. The formal model is a discrete, single-threaded step function. Floating-point
  runtimes need care to stay bit-for-bit reproducible, for example with fixed-point arithmetic or
  a deterministic math library.
* Dragon's theorem is an existence result for finite state spaces. The demo finds its cycle by
  direct checking. A runtime detector, such as Floyd's or Brent's cycle detection, would still need
  implementing and testing.
* The room is a deliberately tiny test room. The proofs don't show that Totality will be fun, or
  that any EFMW physical claim is true. They show that the proposed architecture meets the
  engineering criterion: it is **reproducible, inspectable and auditable**.
