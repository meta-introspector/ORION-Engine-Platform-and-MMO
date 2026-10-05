# The Orion Chronicles: how the ORION Engine documents become the game

**The target.** The platform we are building towards is **The Orion Chronicles**, the video game
proposal. Everything else in this repository serves it. This file uses two sets of sources:

* **The ORION Engine Architecture** and the three pages inside it: *Open Research Intelligence
  Optimization Network*, *A Human-Centered Approach to AI Safety* and *Operation Snake and Scale*.
  The foundational protocols it names are also included: the Watermelon Equation and the Ghost
  Rider Protocol.
* **The Orion Chronicles proposal.** This is Proposal v0.2 plus the CUBY 4 → 4.1 update, as
  summarised in `COMPARISON.md` and `HUB_DESIGN.md`.

> **Note on the Google Doc link.** The Google Doc link in the first request
> (`docs.google.com/document/d/1AmcVE16…`) now opens a document titled **"The Tri-Sphere
> Architecture"**, not the Orion Chronicles proposal. It may have been replaced or re-pointed.
> This file therefore works from the proposal material in earlier rounds. §2.4 notes where the
> Tri-Sphere document fits. If a newer proposal exists, sending its text or a working link will
> let the mapping below be updated.

---

## 1. The one-paragraph picture

The ORION Engine overview describes one pipeline:

1. A user enters through the **Ghost Rider Protocol**.
2. Their raw intent is **transmuted** by the Watermelon Equation into a "Seed".
3. The Seed is **cross-examined** by the NewKin Council agents in Operation Snake and Scale,
   inside the ORION loop.
4. The **Human-Centered Safety layer** watches the whole trajectory.
5. The **human Catalyst decides**.

The Orion Chronicles makes that pipeline playable:

* the player is the **Catalyst** (the Driver);
* the council agents are **companions**;
* the ORION loop is the **structure of quests**, above all in the Global Crucible;
* the evidence rubric sets the **grade** of knowledge;
* the Kronos/Orion states become the **meters**.

The rules that decide what the game trusts, rewards and stops are defined in Lean. They are
proved to do what the documents promise.

---

## 2. Component-by-component mapping

### 2.1 Foundational layer: Watermelon Equation + Ghost Rider Protocol

| ORION source idea | Orion Chronicles system | Verified rule |
|---|---|---|
| Human = Driver, AI = Engine | The player always holds the wheel. AI companions advise and never act on the player's behalf without the player's say-so | Authority Stop: `authority_stop`, `canResume_iff` |
| Kronos (deconstruct, listen) / Orion (reconstruct, reframe) | Kronos/Orion meters: Kronos gives volume, Orion gives grade | `RequestProject/Hub/Meters.lean` (`volume_grade_tradeoff`, `spike_effect`, `run_mem_Icc`) |
| Rind → Fruit (friction to coherent "Seed") | Transmutation / meditation centres; a quest's final output is a "Seed" item that records what was learned | Seeds are records in the append-only ledger (`Ledger.prefix_run`) |

### 2.2 Infrastructure: the ORION eleven-phase loop

The loop **Define → Retrieve → Evaluate → Connect → Generate → Attack → Refine → Human Review →
Test → Record → Reuse** fits naturally as the arc of a research quest:

| Phase | Quest stage in the game |
|---|---|
| Define | Accept or write the problem (Crucible board, guild request) |
| Retrieve | Explore: gather lore, resources and sources in the world |
| Evaluate | Grade what was found (the evidence rubric sets item/lore grade) |
| Connect | Find cross-discipline bridges between realms (bridge quests) |
| Generate | Craft a proposal: a recipe, design or hypothesis |
| Attack | Trial: rival players, the Blade companion or public events try to break it |
| Refine | Rebuild from what survived |
| Human Review | Guild / mentor / expert review |
| Test | Field trial, simulation or pilot in a seasonal test world |
| Record | Enters the Vault (the living archive), failures included |
| Reuse | Becomes a resource for later quests and players |

**Proved** (`RequestProject/Orion/Engine.lean`, §1). A run may advance one phase at a time or
bounce back to any earlier phase. With that rule:

* no phase is ever skipped (`Run.visits_all_below`);
* nothing is tested, recorded or reused before a Human Review (`Run.humanReview_before`);
* nothing reaches Human Review without first surviving an Attack (`Run.attack_before_review`);
* reaching Record means every phase from Define to Test was visited first
  (`Run.record_after_all`).

A concrete run with a bounce is checked (`exampleRun`).

**Living archive / failure metadata → the Vault.** Failed attempts stay in the Vault with their
parameters and failure modes, so a later player can see what was tried. The Vault is
append-only (`Ledger.prefix_run` in `Hub/ZooGate.lean`, and `guard_run` in `Orion/Engine.lean`).

**Relationship tiers (Observed / Proposed / Unresolved) → the map.** One natural reading:
*observed* links are solid roads, *proposed* links are dotted trails, and *unresolved* links are
fog. Only observed or replicated records move a claim's score (`ledgerScore_non_evidence_*`).
This is a suggestion, not formalised further.

### 2.3 Application: Operation Snake and Scale → investigation quests and the companion party

| Council agent | Companion role in the game |
|---|---|
| **Prism** | Scout / archivist: gathers and organises what the party finds (Snake phase) |
| **Blade** | Challenger: attacks weak links and brings counter-evidence (Snake phase) |
| **Compass** | Navigator: keeps the investigation in scope (Scale phase) |
| **Auditor** | Assayer: computes evidence weight `W(e)` with the published formula (Scale phase) |
| **Matriarch** | Keeper of consequences: attaches the human impact to every finding (Scale phase) |
| **Catalyst** | The player |

**Proved** (`Orion/Engine.lean`, §4):
* **The debate ("bounce") loop always ends within its recursion limit.** It either converges
  at the first converging round (`debate_converged`) or escalates to the player
  (`debate_escalate_iff`). No companion argument can run forever.
* **No companion can silence another.** The decision ledger accepts only extensions
  (`guard_append`, `guard_preserves`). Any edit or deletion of an existing decision triggers a
  hard stop (`guard_rejects_edit`). Every earlier ledger survives in every later one
  (`guard_run`).
* **Nothing reaches the player unaudited.** A findings package reaches the Catalyst exactly when
  the Auditor passed it and none of the four hard stops fired: intrusion, doxxing, unilateral
  override, recursion limit (`reachesCatalyst_iff`).
* The evidence formula, anti-volume cap and claim score were already proved
  (`EvidenceWeight.lean`, `Hub/Reliability.lean`).

### 2.4 Governance: A Human-Centered Approach to AI Safety → AI companions and moderation

In the game, every AI-driven companion, tutor or NPC that talks with players goes through the
Human Intent Safety Layer.

**Independent Stop Mechanism** (`Orion/Engine.lean`, §2):
* work proceeds exactly when none of the Evidence, Safety or Authority stops holds
  (`mayProceed_iff`);
* each stop halts work on its own (`evidence_stop`, `safety_stop`, `authority_stop`);
* every reported stop reason is a real failed condition (`mem_stopReasons`), so the interface
  can always say *why* it stopped;
* an ordinary user can never resume a halted process (`user_cannot_resume`);
* not even an authorized operator can resume while a stop condition still holds
  (`no_resume_while_stopped`).

**Intervention ladder** (`Orion/Engine.lean`, §3). The rungs follow the page's order:
assist → clarify → name the harm → refuse operational help → offer alternatives → de-escalate →
harm-reduction information → escalate → end the interaction. The rung is
`min(8, ⌊total risk / step⌋)`. Proved:
* **ordinary players get ordinary help:** below one step of total risk, there is no
  intervention (`rung_benign`);
* **no fragmentation loophole:** splitting one request into many small pieces never lowers the
  response (`rung_fragmentation`);
* **proportional:** one turn of risk at most `step` moves the ladder by at most one rung
  (`rung_step_le`);
* **no reset mid-interaction:** later turns never lower the rung (`rung_append_mono`);
* a sustained campaign reaches "end interaction" (`rung_top`).

**Where the Tri-Sphere document fits.** Its Driver / Engine / Vehicle / Copilot vocabulary is
the same as the Ghost Rider layer. "The Copilot expands perspective without seizing the wheel"
is exactly what the Authority Stop and `user_cannot_resume` / `canResume_iff` enforce for AI
companions. The document marks its geometry and filter states as Layer D (framework-specific).
In the game they fit as **lore and visual language**, for example skyboxes and the five filter
states as meditation-centre stances. They are not physics the engine relies on. Its numeric
claims were checked in earlier rounds (`NOTES.md`, `NumericClaims.lean`).

---

## 3. Developer hand-off

* **Rules:** `RequestProject/Orion/Engine.lean` (new this round) plus the existing
  `RequestProject/Hub/*.lean`, `EvidenceWeight.lean` and `Totality/*.lean`.
* **Golden test vectors:**
  * `conformance/golden_vectors.json`: 30 cases (evidence, score, level, meter, Zoo gate);
  * `conformance/engine_vectors.json`, **new**: 25 cases (loop moves, stops, resume rights,
    ladder, debate loop, ledger guard). Lean checks all of them, plus two checks of rung
    names, in `RequestProject/Conformance/EngineVectors.lean`.
* **Reference port:** `python3 conformance/reference.py` now checks both files. All cases pass.
  This port is tested only on those cases, not proved.

## 4. Suggested build order towards the game

1. **Vertical slice (as the proposal already plans):** the dual-perception demo, built on the
   one-room Totality engine (`TOTALITY.md`) with replayable logs.
2. **First quest arc:** one Crucible quest that walks through the eleven phases, with the five
   companions and the Vault. Server logs are checked against the loop, ledger and stop rules
   using the golden vectors.
3. **AI companion safety:** the stop mechanism and ladder in front of every AI companion, with
   published parameters.
4. **Progression and meters:** the 13-level path and the Kronos/Orion meters, already proved.
5. **Community and world:** guilds, bubbles, cities and the Crucible at scale.

## 5. Decisions for the team (the proofs hold for any choice)

* **Ladder parameters:** the risk points per rung (`step`) and the per-turn risk scale, for
  example severity × confidence.
* **Ladder memory:** the ladder sums risk over the *whole interaction* and never drops within
  it. That closes the fragmentation loophole, but a long harmless session slowly accumulates
  small risks. Options:
  * reset per interaction (the proved model);
  * let risk decay over time. This would need re-proving the fragmentation property for the
    decaying version.
* **Debate recursion limit:** the number of rounds before the question goes to the player.
* **Minors:** trajectory evaluation of under-18 players needs legal and child-safety review
  before any build, as `COMPARISON.md` §7 already says.

## 6. What is not covered

The proofs show that the rules as defined do what the documents promise. They do not show:
* that the parameters are well chosen;
* that risk estimates or AI outputs are accurate;
* that the page's falsifiability tests will pass (for example, trajectory evaluation beating
  keyword filters, or uncorrelated multi-agent review);
* that the game is fun;
* that any physical or metaphysical claim in the source documents is true.
