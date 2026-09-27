module

public import RequestProject.Totality.Core

/-!
# Minimum viable Totality: one room

This file instantiates the invariant layer of `Totality/Core.lean` for the proposed first
milestone: **one room** with several physical objects, **two autonomous agents** with
incomplete observations and persistent memory, and **one player intervention channel**.

## Generic rooms (`/agents`)

A `Room` bundles two agents (each with its own partial observation of the world and a policy
that reads its memory and current observation) with a physics step that takes a seed, both
agents' decisions and the player's intervention. Every room is an `Engine`, so every theorem in
`Core.lean` applies to it. In addition:

* `Room.memory_suffix`, `Room.memory_length`: agent memory is persistent (append-only).
* `Room.decision_blind`: an agent's decision depends on the world only through its own
  observation and memory (incomplete information is enforced, not just intended).
* `Room.why`: for every event in a coherent log, the new world is exactly the physics applied to
  the recorded seed, the two agents' decisions (recomputed from the recorded parent state) and the
  player's intervention: an exact causal answer to "why did this happen?".

## The concrete room

Three balls on a ring of 6 cells, each with a position and a velocity (both mod 6). A push
transfers one unit of velocity from a ball to the next one, so pushes never create momentum.
Agent 1 sees only the positions of balls 0 and 1; agent 2 sees only the position of ball 2;
neither sees velocities. The player may push any ball, and the seed adds a deterministic
"noise" push on some steps. Proved or checked:

1. deterministic, reproducible evolution and exact replay of a 10-event log (`demo_audit`,
   `demo_replay`);
2. agents with incomplete observations (`agent1_view_incomplete`);
3. persistent memory (`demo_memory`);
4. Cuby branching and 7. Borges storage (`demo_branch_count`, `demo_branches_conserve`);
5. Janus counterfactuals (`demo_janus_prefix`, `demo_janus_diverges`);
6. Dragon regime detection (`demo_dragon_cycle`);
8. EFMW coherence monitoring and 9. Zoo auditing: the tampered log is rejected and the residual
   monitor names exactly the altered event (`demo_tamper_rejected`, `demo_tamper_residual`);
10. Thor: total momentum is conserved by every step for every seed and intervention
   (`momentum_preserved`), hence along every history, branch and replay.
-/

@[expose] public section

namespace Totality

/-! ## Generic rooms with two agents -/

/-- A room: two agents with partial observations and policies, and a physics step. -/
structure Room (W O A P : Type*) where
  version : ℕ
  obs₁ : W → O
  obs₂ : W → O
  pol₁ : List O → O → A
  pol₂ : List O → O → A
  physics : ℕ → W → A → A → P → W

/-- The state of a room: the world and each agent's memory of past observations
(most recent first). -/
structure RoomState (W O : Type*) where
  world : W
  mem₁ : List O
  mem₂ : List O
  deriving DecidableEq

variable {W O A P : Type*} (R : Room W O A P)

/-- Agent 1's decision: its policy applied to its memory and its current observation. -/
def Room.decision₁ (st : RoomState W O) : A := R.pol₁ st.mem₁ (R.obs₁ st.world)

/-- Agent 2's decision. -/
def Room.decision₂ (st : RoomState W O) : A := R.pol₂ st.mem₂ (R.obs₂ st.world)

/-- Every room is an engine whose intervention is the player's input. -/
def Room.engine : Engine (RoomState W O) P where
  version := R.version
  step seed st p :=
    { world := R.physics seed st.world (R.decision₁ st) (R.decision₂ st) p
      mem₁ := R.obs₁ st.world :: st.mem₁
      mem₂ := R.obs₂ st.world :: st.mem₂ }

/-- **Persistent memory.** Agent 1 never forgets: its old memory is a suffix of its memory after
any run. -/
theorem Room.memory_suffix (st : RoomState W O) (cs : List (ℕ × P)) :
    st.mem₁ <:+ (R.engine.run st cs).mem₁ ∧ st.mem₂ <:+ (R.engine.run st cs).mem₂ := by
  induction cs generalizing st with
  | nil => exact ⟨List.suffix_refl _, List.suffix_refl _⟩
  | cons c cs ih =>
    obtain ⟨h1, h2⟩ := ih (R.engine.step c.1 st c.2)
    exact ⟨(List.suffix_cons _ _).trans h1, (List.suffix_cons _ _).trans h2⟩

/-- Each step adds exactly one observation to each agent's memory. -/
theorem Room.memory_length (st : RoomState W O) (cs : List (ℕ × P)) :
    (R.engine.run st cs).mem₁.length = st.mem₁.length + cs.length ∧
      (R.engine.run st cs).mem₂.length = st.mem₂.length + cs.length := by
  induction cs generalizing st with
  | nil => simp
  | cons c cs ih =>
    obtain ⟨h1, h2⟩ := ih (R.engine.step c.1 st c.2)
    simp only [Engine.run_cons, h1, h2, List.length_cons]
    exact ⟨by simp [Room.engine]; omega, by simp [Room.engine]; omega⟩

/-- **Incomplete observation is enforced.** Two room states that agent 1 cannot tell apart
(same memory, same current observation) get the same decision from agent 1, however much the
hidden parts of the world differ. -/
theorem Room.decision_blind (st st' : RoomState W O) (hm : st.mem₁ = st'.mem₁)
    (ho : R.obs₁ st.world = R.obs₁ st'.world) : R.decision₁ st = R.decision₁ st' := by
  simp [Room.decision₁, hm, ho]

/-- **"Why did this happen?"** In a coherent provenance log, each event's new world is exactly
the physics applied to the recorded seed, the decisions both agents make on the recorded parent
state, and the recorded player intervention; and each agent's memory grew by exactly its
observation of the parent world. -/
theorem Room.why (n : ℕ) (st : RoomState W O) (log : List (Event (RoomState W O) P))
    (h : R.engine.CoherentFrom n st log) (e : Event (RoomState W O) P) (he : e ∈ log) :
    e.child.world = R.physics e.seed e.parent.world (R.decision₁ e.parent)
        (R.decision₂ e.parent) e.input ∧
      e.child.mem₁ = R.obs₁ e.parent.world :: e.parent.mem₁ ∧
      e.child.mem₂ = R.obs₂ e.parent.world :: e.parent.mem₂ := by
  have := (R.engine.event_explained n st log h e he).1
  rw [this]
  exact ⟨rfl, rfl, rfl⟩

/-! ## The concrete room: three balls on a ring of six cells -/

namespace BallRoom

/-- Three balls, each with a position and a velocity mod 6. -/
structure World where
  p0 : ZMod 6
  p1 : ZMod 6
  p2 : ZMod 6
  v0 : ZMod 6
  v1 : ZMod 6
  v2 : ZMod 6
  deriving DecidableEq, Repr

/-- A push on ball `i`: one unit of velocity moves from ball `i` to ball `i + 1` (cyclically). -/
def push : Fin 3 → World → World
  | 0, w => { w with v0 := w.v0 - 1, v1 := w.v1 + 1 }
  | 1, w => { w with v1 := w.v1 - 1, v2 := w.v2 + 1 }
  | 2, w => { w with v2 := w.v2 - 1, v0 := w.v0 + 1 }

/-- An optional push (agents and the player may also do nothing). -/
def pushOpt : Option (Fin 3) → World → World
  | none, w => w
  | some i, w => push i w

/-- Seed-driven noise: on seeds divisible by 4, a push on ball `(seed / 4) mod 3`. -/
def noise (seed : ℕ) (w : World) : World :=
  if seed % 4 = 0 then push ⟨seed / 4 % 3, Nat.mod_lt _ (by norm_num)⟩ w else w

/-- Free motion: every ball advances by its velocity. -/
def drift (w : World) : World :=
  { w with p0 := w.p0 + w.v0, p1 := w.p1 + w.v1, p2 := w.p2 + w.v2 }

/-- The physics: agent 1's push, agent 2's push, the player's push, seed noise, then motion. -/
def physics (seed : ℕ) (w : World) (a₁ a₂ : Option (Fin 3)) (p : Option (Fin 3)) : World :=
  drift (noise seed (pushOpt p (pushOpt a₂ (pushOpt a₁ w))))

/-- The room: agent 1 sees balls 0 and 1, agent 2 sees ball 2, neither sees velocities.
Agent 1 pushes ball 0 when what it sees has not changed since its last observation.
Agent 2 pushes ball 2 when ball 2 is at cell 0. -/
def room : Room World (List (ZMod 6)) (Option (Fin 3)) (Option (Fin 3)) where
  version := 1
  obs₁ w := [w.p0, w.p1]
  obs₂ w := [w.p2]
  pol₁ mem o := if mem.head? = some o then some 0 else none
  pol₂ _ o := if o = [0] then some 2 else none
  physics := physics

/-- Total momentum of the room. -/
def momentum (w : World) : ZMod 6 := w.v0 + w.v1 + w.v2

lemma momentum_push (i : Fin 3) (w : World) : momentum (push i w) = momentum w := by
  fin_cases i <;> simp [push, momentum] <;> ring

lemma momentum_pushOpt (o : Option (Fin 3)) (w : World) :
    momentum (pushOpt o w) = momentum w := by
  cases o <;> simp [pushOpt, momentum_push]

lemma momentum_drift (w : World) : momentum (drift w) = momentum w := rfl

lemma momentum_physics (seed : ℕ) (w : World) (a₁ a₂ p : Option (Fin 3)) :
    momentum (physics seed w a₁ a₂ p) = momentum w := by
  rw [physics, momentum_drift, noise]
  split_ifs <;> simp only [momentum_push, momentum_pushOpt]

/-- **Thor.** Total momentum is conserved by every step of the room, for every seed, every agent
decision and every player intervention. -/
theorem momentum_preserved (m : ZMod 6) :
    room.engine.Preserves fun st => momentum st.world = m := by
  intro seed st p h
  simpa [Room.engine, room] using (momentum_physics _ _ _ _ _).trans h

/-- The starting room: balls at cells 0, 2, 4 with velocities 1, 0, 5; empty memories. -/
def init : RoomState World (List (ZMod 6)) :=
  ⟨⟨0, 2, 4, 1, 0, 5⟩, [], []⟩

/-- Ten steps: seeds and player interventions. -/
def demoCmds : List (ℕ × Option (Fin 3)) :=
  [(1, none), (4, some 1), (7, none), (8, none), (2, some 0),
   (12, none), (3, some 2), (5, none), (16, some 1), (9, none)]

/-- The provenance log written by the engine for the demo run. -/
def demoLog : List (Event (RoomState World (List (ZMod 6))) (Option (Fin 3))) :=
  room.engine.record init demoCmds

/-- 1 and 10. The demo log passes the replay audit (checked by the kernel). -/
theorem demo_audit : room.engine.audit 0 init demoLog = true := by decide +kernel

/-- Exact replay: re-running the recorded seeds and interventions reproduces the whole log. -/
theorem demo_replay : demoLog = room.engine.recordFrom 0 init (inputs demoLog) :=
  room.engine.eq_record_of_coherent 0 init demoLog (room.engine.coherent_recordFrom _ _ _)

/-- A tampered log: the child state of event 2 is edited (ball 0 moved to cell 5). -/
def tamperedLog : List (Event (RoomState World (List (ZMod 6))) (Option (Fin 3))) :=
  demoLog.modify 2 fun e => { e with child := { e.child with world := { e.child.world with p0 := 5 } } }

/-- 9. The Zoo's replay audit rejects the tampered log (checked by the kernel). -/
theorem demo_tamper_rejected : room.engine.audit 0 init tamperedLog = false := by decide +kernel

/-- 8. The EFMW residual monitor names exactly the altered event. -/
theorem demo_tamper_residual : room.engine.residuals tamperedLog = [2] := by decide +kernel

/-- 2. Agent 1's view is incomplete: two worlds that differ in hidden velocities look the same
to agent 1 and get the same decision, although their next states differ. -/
theorem agent1_view_incomplete :
    let s : RoomState World (List (ZMod 6)) := ⟨⟨0, 2, 4, 1, 0, 5⟩, [], []⟩
    let s' : RoomState World (List (ZMod 6)) := ⟨⟨0, 2, 4, 3, 3, 0⟩, [], []⟩
    room.obs₁ s.world = room.obs₁ s'.world ∧ room.decision₁ s = room.decision₁ s' ∧
      room.engine.step 0 s none ≠ room.engine.step 0 s' none := by
  decide +kernel

/-- The agents are not inert: in the demo run, agent 1 decides to push ball 0 at step 6 (what it
sees did not change between steps 5 and 6), and does nothing at the other steps. -/
theorem demo_agent1_acts :
    (room.engine.trace init demoCmds).dropLast.map room.decision₁ =
      [none, none, none, none, none, none, some 0, none, none, none] := by
  decide +kernel

/-- 3. After the ten demo steps each agent remembers exactly ten observations, and its first
observation is still there. -/
theorem demo_memory :
    (room.engine.run init demoCmds).mem₁.length = 10 ∧
      (room.engine.run init demoCmds).mem₁.getLast? = some [0, 2] := by
  decide +kernel

/-- The last three steps of the demo, replaced by a counterfactual: at step 7 the player pushes
ball 0 instead of doing nothing. -/
def janusCmds : List (ℕ × Option (Fin 3)) :=
  demoCmds.take 7 ++ [(5, some 0), (16, some 1), (9, none)]

/-- 5. Janus: the counterfactual agrees with the actual run on the first eight states (times
0 to 7) -/
theorem demo_janus_prefix :
    (room.engine.trace init janusCmds).take 8 = (room.engine.trace init demoCmds).take 8 := by
  exact room.engine.janus_agree_before init (demoCmds.take 7) [(16, some 1), (9, none)]
    [(16, some 1), (9, none)] (5, some 0) (5, none)

/-- … and it genuinely diverges afterwards (checked by the kernel). -/
theorem demo_janus_diverges : room.engine.run init janusCmds ≠ room.engine.run init demoCmds := by
  decide +kernel

/-- The Cuby menu: fixed seed 1, and the player may do nothing or push any of the three balls. -/
def menu : List (ℕ × Option (Fin 3)) := [(1, none), (1, some 0), (1, some 1), (1, some 2)]

/-- 4 and 7. Cuby branching four steps deep stores exactly `4 ^ 4 = 256` histories in Borges. -/
theorem demo_branch_count : (room.engine.branches menu 4 init).length = 256 := by
  rw [Engine.branches_length]; rfl

/-- Every stored branch conserves momentum (Thor), and replays to its stored state. -/
theorem demo_branches_conserve (b : List (ℕ × Option (Fin 3)) × RoomState World (List (ZMod 6)))
    (hb : b ∈ room.engine.branches menu 4 init) :
    momentum b.2.world = momentum init.world ∧ b.2 = room.engine.run init b.1 :=
  ⟨room.engine.thor_branches (momentum_preserved _) init rfl menu 4 b hb,
    (room.engine.branches_sound menu 4 init b hb).1⟩

/-- The free-running regime of the world alone: seed 1, no agents, no player. -/
def freeRun (w : World) : World := physics 1 w none none none

/-- 6. Dragon: the free-running regime from the initial world enters a cycle of period 6
immediately (transient 0), and 6 is the least period. -/
theorem demo_dragon_cycle :
    freeRun^[6] init.world = init.world ∧ ∀ k ∈ Finset.Ioo 0 6, freeRun^[k] init.world ≠ init.world := by
  decide +kernel

end BallRoom

end Totality
