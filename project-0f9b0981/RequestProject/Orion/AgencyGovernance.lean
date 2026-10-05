module

public import Mathlib

/-!
# Ghost Rider as Agency Governance, and the NewKin Council classroom

This file makes precise the platform rules of *The NewKin Council Multi-Model Experiment &
Architectural Synthesis* (Section IV) and the classroom design worked out in the Volume V
interview log, and proves they do what the documents say.

1. **Ghost Rider, the governor of delegated agency** (Section IV.2). An agent may think and
   propose freely, but it moves only inside a human authorization.
   * *Thought ≠ Decision ≠ Action.* Thinking and proposing change nothing (`thought_inert`).
   * *No self-authorization.* However long an agent runs on its own, it never gains a goal, an
     approval or extra budget that the human did not give (`agent_run_goal`,
     `agent_run_approved`, `agent_run_budget`).
   * *Non-Delegable Rule.* Completing an authorized task never authorizes a new objective:
     after completion no action at all runs until a human authorizes again
     (`completion_not_authorization`).
   * *Divergence Test.* An action whose objective differs from the authorized purpose is
     refused (`divergent_refused`), and every action an agent runs on its own serves the
     original purpose (`agent_run_on_purpose`).
   * *Human Reauthorization Gate.* An action that needs a new privilege, touches external
     infrastructure, or cannot be undone is refused unless the human approved that specific
     action (`gate_blocks`), and runs once approved (`gate_opens`). An approval is used up by
     the action it approved (`approval_single_use`).
   * *Delegated authority expires* (Volume V: "How long does that authority last? When does it
     expire?"): an agent running on its own executes at most the budget the human granted
     (`agent_run_bounded`).
   * *Take the wheel back at any moment.* From any state, one human step removes all delegated
     authority (`take_wheel_always`).
   * *The Copilot rule* (Phase 5): the Copilot may take the wheel to solve the authorized
     problem and park (`copilot_can_park`), but cannot choose the next destination or start
     moving again (`completion_not_authorization`).
2. **The classroom** (Section IV.3, Volume V "The Classroom").
   * *Visibility ≠ speaking authority.* Raising a hand never grants the floor
     (`raise_hand_not_floor`); only the Catalyst's recognition does (`floor_only_by_catalyst`),
     and every line in the transcript was spoken by a model that held the floor
     (`transcript_recognized`).
   * *Mode 1, blind inquiry.* A model's answer does not depend on the other models' answers
     (`blind_independent`).
   * *Mode 4, synthesis preserves dissent.* Every position any member holds appears in the
     synthesis, either as the shared conclusion or as a minority position
     (`synthesis_keeps_every_position`), and a minority position is never the shared one.
3. **Correlated consensus** (Section II, Phase 2). Ten models that all trace back to the same
   training base count as one independent source, not ten (`correlated_consensus`); agreement
   adds independent weight only through genuinely different bases (`effectiveSources_le`).
   This matches the Hub's anti-volume rule for claim scores (`claimScore_dup_support`).
-/

@[expose] public section

namespace AgencyGovernance

/-! ## 1. Ghost Rider: the governor of delegated agency -/

/-- An action an agent may attempt, with the three consequence thresholds of the
Human Reauthorization Gate. -/
structure Action (O : Type*) where
  /-- The purpose the action serves. -/
  objective : O
  /-- It needs a privilege the agent does not already have. -/
  newPrivilege : Bool
  /-- It touches external infrastructure. -/
  external : Bool
  /-- It cannot be undone. -/
  irreversible : Bool
  deriving DecidableEq

/-- An action crosses a consequence threshold. -/
def Action.crossesThreshold {O : Type*} (a : Action O) : Bool :=
  a.newPrivilege || a.external || a.irreversible

/-- Events. The first four come from the agent, the last three from the human. -/
inductive Event (O : Type*)
  /-- Search, simulate, brainstorm, critique. -/
  | think
  /-- Propose a destination (never adopts it). -/
  | propose (o : O)
  /-- Attempt an action. -/
  | act (a : Action O)
  /-- Report the authorized task complete ("get the vehicle parked"). -/
  | complete
  /-- The human sets a destination and a budget of actions. -/
  | authorize (o : O) (budget : ℕ)
  /-- The human approves one specific threshold-crossing action. -/
  | reauthorize (a : Action O)
  /-- The human takes the wheel back. -/
  | takeWheel

/-- Events the agent can produce on its own. -/
def Event.byAgent {O : Type*} : Event O → Bool
  | .think | .propose _ | .act _ | .complete => true
  | _ => false

/-- The governor's state. -/
structure Gov (O : Type*) where
  /-- The human-authorized destination, if any (`none` = parked). -/
  goal : Option O
  /-- Specific threshold-crossing actions the human approved. -/
  approved : List (Action O)
  /-- Actions still allowed under the current authorization. -/
  budget : ℕ
  /-- Actions executed so far, newest first. -/
  log : List (Action O)

variable {O : Type*} [DecidableEq O]

/-- An action may run when it serves the authorized destination, budget remains, and it either
crosses no threshold or the human approved exactly this action. -/
def Gov.permitted (g : Gov O) (a : Action O) : Bool :=
  decide (g.goal = some a.objective) && decide (0 < g.budget) &&
    (!a.crossesThreshold || decide (a ∈ g.approved))

/-- One step of the governor. -/
def step (g : Gov O) : Event O → Gov O
  | .think => g
  | .propose _ => g
  | .act a => if g.permitted a then
      { g with approved := g.approved.erase a, budget := g.budget - 1, log := a :: g.log } else g
  | .complete => { g with goal := none, approved := [], budget := 0 }
  | .authorize o n => { g with goal := some o, approved := [], budget := n }
  | .reauthorize a => { g with approved := a :: g.approved }
  | .takeWheel => { g with goal := none, approved := [], budget := 0 }

/-- Run a list of events. -/
def run (g : Gov O) (es : List (Event O)) : Gov O := es.foldl step g

lemma run_cons (g : Gov O) (e : Event O) (es : List (Event O)) :
    run g (e :: es) = run (step g e) es := rfl

lemma step_act (g : Gov O) (a : Action O) : step g (.act a) = if g.permitted a then
    { g with approved := g.approved.erase a, budget := g.budget - 1, log := a :: g.log } else g :=
  rfl

/-- **Thought ≠ Decision ≠ Action.** Thinking and proposing change nothing. -/
theorem thought_inert (g : Gov O) (o : O) : step g .think = g ∧ step g (.propose o) = g :=
  ⟨rfl, rfl⟩

/-- A single agent step never sets a new goal: the goal stays or is cleared. -/
lemma step_agent_goal (g : Gov O) (e : Event O) (he : e.byAgent = true) :
    (step g e).goal = g.goal ∨ (step g e).goal = none := by
  cases e with
  | act a => rw [step_act]; split_ifs <;> simp
  | complete => simp [step]
  | think | propose => simp [step]
  | _ => simp [Event.byAgent] at he

/-- **No self-authorization (goal).** An agent running on its own ends with the destination the
human gave, or parked; never with a destination of its own choosing. -/
theorem agent_run_goal (g : Gov O) (es : List (Event O)) (hes : ∀ e ∈ es, e.byAgent = true) :
    (run g es).goal = g.goal ∨ (run g es).goal = none := by
  induction es generalizing g with
  | nil => simp [run]
  | cons e es ih =>
    rw [run_cons]
    have h1 := step_agent_goal g e (hes e (by simp))
    rcases ih (step g e) (fun e' he' => hes e' (by simp [he'])) with h | h
    · rw [h]; exact h1
    · exact Or.inr h

/-- **No self-authorization (approvals).** Agent steps never add approvals. -/
theorem agent_run_approved (g : Gov O) (es : List (Event O)) (hes : ∀ e ∈ es, e.byAgent = true) :
    ∀ a ∈ (run g es).approved, a ∈ g.approved := by
  induction es generalizing g with
  | nil => simp [run]
  | cons e es ih =>
    intro a ha
    rw [run_cons] at ha
    have h := ih (step g e) (fun e' he' => hes e' (by simp [he'])) a ha
    have he := hes e (by simp)
    cases e with
    | act b => rw [step_act] at h; split_ifs at h
               · exact List.mem_of_mem_erase h
               · exact h
    | complete => simp [step] at h
    | think | propose => exact h
    | _ => simp [Event.byAgent] at he

/-- **No self-authorization (budget).** Agent steps never raise the budget. -/
theorem agent_run_budget (g : Gov O) (es : List (Event O)) (hes : ∀ e ∈ es, e.byAgent = true) :
    (run g es).budget ≤ g.budget := by
  induction es generalizing g with
  | nil => simp [run]
  | cons e es ih =>
    rw [run_cons]
    refine le_trans (ih (step g e) (fun e' he' => hes e' (by simp [he']))) ?_
    have he := hes e (by simp)
    cases e with
    | act b => rw [step_act]; split_ifs <;> simp
    | complete => simp [step]
    | think | propose => simp [step]
    | _ => simp [Event.byAgent] at he

/-- Nothing is permitted while parked. -/
lemma not_permitted_of_parked (g : Gov O) (h : g.goal = none) (a : Action O) :
    g.permitted a = false := by simp [Gov.permitted, h]

/-- Agent steps from a parked state stay parked and execute nothing. -/
lemma agent_run_parked (g : Gov O) (h : g.goal = none) (es : List (Event O))
    (hes : ∀ e ∈ es, e.byAgent = true) : (run g es).goal = none ∧ (run g es).log = g.log := by
  induction es generalizing g with
  | nil => simp [run, h]
  | cons e es ih =>
    rw [run_cons]
    have he := hes e (by simp)
    have hs : (step g e).goal = none ∧ (step g e).log = g.log := by
      cases e with
      | act b => simp [step, not_permitted_of_parked g h, h]
      | complete => simp [step]
      | think | propose => simp [step, h]
      | _ => simp [Event.byAgent] at he
    have := ih (step g e) hs.1 (fun e' he' => hes e' (by simp [he']))
    exact ⟨this.1, this.2.trans hs.2⟩

/-- **The Non-Delegable Rule.** Completing an authorized task never authorizes a new objective:
after completion, whatever the agent does on its own, it stays parked and executes nothing. -/
theorem completion_not_authorization (g : Gov O) (es : List (Event O))
    (hes : ∀ e ∈ es, e.byAgent = true) :
    (run (step g .complete) es).goal = none ∧
      (run (step g .complete) es).log = (step g .complete).log :=
  agent_run_parked _ rfl es hes

/-- **The Divergence Test.** An action that does not serve the authorized purpose is refused. -/
theorem divergent_refused (g : Gov O) (a : Action O) (h : g.goal ≠ some a.objective) :
    step g (.act a) = g := by
  simp [step, Gov.permitted, h]

/-- **The Human Reauthorization Gate (closed).** A threshold-crossing action the human did not
approve is refused, even when it serves the authorized purpose. -/
theorem gate_blocks (g : Gov O) (a : Action O) (ht : a.crossesThreshold = true)
    (hn : a ∉ g.approved) : step g (.act a) = g := by
  simp [step, Gov.permitted, ht, hn]

/-- **The Human Reauthorization Gate (open).** Once the human approves that specific action, it
runs (provided it serves the destination and budget remains). -/
theorem gate_opens (g : Gov O) (a : Action O) (hg : g.goal = some a.objective)
    (hb : 0 < g.budget) : (step (step g (.reauthorize a)) (.act a)).log = a :: g.log := by
  simp [step, Gov.permitted, hg, hb]

/-- An approval is used up by the action it approved. -/
theorem approval_single_use (g : Gov O) (a : Action O) (hg : g.goal = some a.objective)
    (hb : 0 < g.budget) (hn : a ∉ g.approved) :
    a ∉ (step (step g (.reauthorize a)) (.act a)).approved := by
  rw [step_act]
  split_ifs
  · simpa [step] using hn
  · simp_all [step, Gov.permitted]

/-- Every action an agent runs on its own serves the destination the human authorized, and a
threshold-crossing one was approved by the human beforehand. -/
theorem agent_run_on_purpose (g : Gov O) (es : List (Event O))
    (hes : ∀ e ∈ es, e.byAgent = true) :
    ∃ new, (run g es).log = new ++ g.log ∧
      ∀ a ∈ new, g.goal = some a.objective ∧ (a.crossesThreshold = true → a ∈ g.approved) := by
  induction es generalizing g with
  | nil => exact ⟨[], by simp [run], by simp⟩
  | cons e es ih =>
    rw [run_cons]
    have he := hes e (by simp)
    obtain ⟨new, hlog, hnew⟩ := ih (step g e) (fun e' he' => hes e' (by simp [he']))
    have hg := step_agent_goal g e he
    have happ : ∀ a ∈ (step g e).approved, a ∈ g.approved :=
      agent_run_approved g [e] (by simpa using he)
    cases e with
    | act b =>
      by_cases hp : g.permitted b = true
      · have hs : step g (.act b) =
            { g with approved := g.approved.erase b, budget := g.budget - 1, log := b :: g.log } := by
          simp [step, hp]
        rw [hs] at hlog hnew ⊢
        have hpb : g.goal = some b.objective ∧ (b.crossesThreshold = true → b ∈ g.approved) := by
          simp only [Gov.permitted, Bool.and_eq_true, decide_eq_true_eq, Bool.or_eq_true,
            Bool.not_eq_true'] at hp
          refine ⟨hp.1.1, fun ht => ?_⟩
          rcases hp.2 with h | h
          · simp [h] at ht
          · exact h
        refine ⟨new ++ [b], by simpa using hlog, ?_⟩
        intro a ha
        rcases List.mem_append.1 ha with ha | ha
        · obtain ⟨h1, h2⟩ := hnew a ha
          refine ⟨h1, fun ht => ?_⟩
          exact List.mem_of_mem_erase (h2 ht)
        · simp at ha; subst ha; exact hpb
      · have hs : step g (.act b) = g := by simp [step, hp]
        rw [hs] at hlog hnew ⊢; exact ⟨new, hlog, hnew⟩
    | complete =>
      obtain ⟨hpark, hl⟩ := agent_run_parked (step g .complete) rfl es
        (fun e' he' => hes e' (by simp [he']))
      refine ⟨[], by rw [hl]; rfl, by simp⟩
    | think | propose => exact ⟨new, hlog, hnew⟩
    | _ => simp [Event.byAgent] at he

/-- **Delegated authority expires.** An agent running on its own executes at most as many
actions as the budget the human granted. -/
theorem agent_run_bounded (g : Gov O) (es : List (Event O)) (hes : ∀ e ∈ es, e.byAgent = true) :
    ∃ new, (run g es).log = new ++ g.log ∧ new.length + (run g es).budget ≤ g.budget := by
  induction es generalizing g with
  | nil => exact ⟨[], by simp [run], by simp [run]⟩
  | cons e es ih =>
    rw [run_cons]
    have he := hes e (by simp)
    obtain ⟨new, hlog, hlen⟩ := ih (step g e) (fun e' he' => hes e' (by simp [he']))
    cases e with
    | act b =>
      by_cases hp : g.permitted b = true
      · have hb : 0 < g.budget := by
          simp only [Gov.permitted, Bool.and_eq_true, decide_eq_true_eq] at hp; exact hp.1.2
        have hs : step g (.act b) =
            { g with approved := g.approved.erase b, budget := g.budget - 1, log := b :: g.log } := by
          simp [step, hp]
        rw [hs] at hlog hlen ⊢
        refine ⟨new ++ [b], by simpa using hlog, ?_⟩
        simp only [List.length_append, List.length_singleton] at *; omega
      · have hs : step g (.act b) = g := by simp [step, hp]
        rw [hs] at hlog hlen ⊢; exact ⟨new, hlog, hlen⟩
    | complete =>
      obtain ⟨-, hl⟩ := agent_run_parked (step g .complete) rfl es
        (fun e' he' => hes e' (by simp [he']))
      have hb : (run (step g .complete) es).budget ≤ 0 :=
        agent_run_budget (step g .complete) es (fun e' he' => hes e' (by simp [he']))
      exact ⟨[], by rw [hl]; rfl, by simp only [List.length_nil] at hb ⊢; omega⟩
    | think | propose => exact ⟨new, hlog, hlen⟩
    | _ => simp [Event.byAgent] at he

/-- **Take the wheel back at any moment.** Whatever the state, one human step parks the vehicle
and removes every delegated approval and all remaining budget. -/
theorem take_wheel_always (g : Gov O) :
    (step g .takeWheel).goal = none ∧ (step g .takeWheel).approved = [] ∧
      (step g .takeWheel).budget = 0 := ⟨rfl, rfl, rfl⟩

/-- **The Copilot rule (can park).** Given a destination and budget, the Copilot can carry out
an ordinary action toward it and then park. -/
theorem copilot_can_park (g : Gov O) (o : O) (n : ℕ) (a : Action O) (ho : a.objective = o)
    (hn : 0 < n) (ht : a.crossesThreshold = false) :
    let g' := run g [.authorize o n, .act a, .complete]
    g'.log = a :: g.log ∧ g'.goal = none := by
  simp [run, step, Gov.permitted, ho, hn, ht]

/-! ## 2. The classroom: visibility is not speaking authority -/

/-- Classroom events: AI members raise hands and speak; the Catalyst recognizes and yields. -/
inductive RoomEvent (M : Type*)
  | raiseHand (m : M)
  | speak (m : M) (line : String)
  | recognize (m : M)
  | yieldFloor

/-- Events the AI members can produce. -/
def RoomEvent.byAI {M : Type*} : RoomEvent M → Bool
  | .raiseHand _ | .speak _ _ => true
  | _ => false

/-- The room: who holds the floor, raised hands, and the transcript (newest first). -/
structure Room (M : Type*) where
  floor : Option M
  hands : List M
  transcript : List (M × String)

variable {M : Type*} [DecidableEq M]

/-- One classroom step. Speaking without the floor is ignored. -/
def roomStep (r : Room M) : RoomEvent M → Room M
  | .raiseHand m => { r with hands := m :: r.hands }
  | .speak m l => if r.floor = some m then { r with transcript := (m, l) :: r.transcript } else r
  | .recognize m => { r with floor := some m, hands := r.hands.erase m }
  | .yieldFloor => { r with floor := none }

/-- Run classroom events. -/
def roomRun (r : Room M) (es : List (RoomEvent M)) : Room M := es.foldl roomStep r

lemma roomRun_cons (r : Room M) (e : RoomEvent M) (es : List (RoomEvent M)) :
    roomRun r (e :: es) = roomRun (roomStep r e) es := rfl

/-- **Raising a hand is not the floor.** -/
theorem raise_hand_not_floor (r : Room M) (m : M) :
    (roomStep r (.raiseHand m)).floor = r.floor := rfl

/-- **Only the Catalyst gives the floor.** However the AI members act, the floor stays with
whoever the Catalyst last recognized. -/
theorem floor_only_by_catalyst (r : Room M) (es : List (RoomEvent M))
    (hes : ∀ e ∈ es, e.byAI = true) : (roomRun r es).floor = r.floor := by
  induction es generalizing r with
  | nil => rfl
  | cons e es ih =>
    rw [roomRun_cons]
    have he := hes e (by simp)
    rw [ih _ (fun e' he' => hes e' (by simp [he']))]
    cases e with
    | raiseHand => rfl
    | speak m l => simp only [roomStep]; split_ifs <;> rfl
    | _ => simp [RoomEvent.byAI] at he

/-- **Visibility ≠ speaking authority.** However the AI members act, every new line in the
transcript was spoken by the member the Catalyst had recognized. In particular, with nobody
recognized, nothing is added. -/
theorem transcript_recognized (r : Room M) (es : List (RoomEvent M))
    (hes : ∀ e ∈ es, e.byAI = true) :
    ∃ new, (roomRun r es).transcript = new ++ r.transcript ∧ ∀ x ∈ new, r.floor = some x.1 := by
  induction es generalizing r with
  | nil => exact ⟨[], rfl, by simp⟩
  | cons e es ih =>
    rw [roomRun_cons]
    have he := hes e (by simp)
    obtain ⟨new, hl, hnew⟩ := ih (roomStep r e) (fun e' he' => hes e' (by simp [he']))
    have hfl : (roomStep r e).floor = r.floor := floor_only_by_catalyst r [e] (by simpa using he)
    rw [hfl] at hnew
    cases e with
    | raiseHand => exact ⟨new, hl, hnew⟩
    | speak m l =>
      by_cases hm : r.floor = some m
      · have hs : (roomStep r (.speak m l)).transcript = (m, l) :: r.transcript := by
          simp [roomStep, hm]
        refine ⟨new ++ [(m, l)], by rw [hl, hs]; simp, ?_⟩
        intro x hx
        rcases List.mem_append.1 hx with hx | hx
        · exact hnew x hx
        · simp at hx; subst hx; exact hm
      · have hs : roomStep r (.speak m l) = r := by simp [roomStep, hm]
        rw [hs] at hl ⊢; exact ⟨new, hl, hnew⟩
    | _ => simp [RoomEvent.byAI] at he

/-- A recognized member's line is recorded. -/
theorem recognized_speaks (r : Room M) (m : M) (l : String) :
    (roomStep (roomStep r (.recognize m)) (.speak m l)).transcript = (m, l) :: r.transcript := by
  simp [roomStep]

/-- **Mode 1, blind inquiry.** In blind mode a member sees only the prompt, so its answer does
not change when the other members' answers change. -/
def answerIn {P A : Type*} (blind : Bool) (f : P → List A → A) (prompt : P) (others : List A) : A :=
  f prompt (if blind then [] else others)

theorem blind_independent {P A : Type*} (f : P → List A → A) (p : P) (xs ys : List A) :
    answerIn true f p xs = answerIn true f p ys := rfl

/-- **Mode 4, synthesis.** The shared conclusion (if every member agrees) and the minority
positions (every other distinct position). -/
def synthesis {Pos : Type*} [DecidableEq Pos] (ps : List Pos) : Option Pos × List Pos :=
  match ps with
  | [] => (none, [])
  | p :: _ => if ps.all (· = p) then (some p, []) else (none, ps.dedup)

/-- **Consensus does not erase dissent.** Every position held by any member appears in the
synthesis, as the shared conclusion or as a minority position. -/
theorem synthesis_keeps_every_position {Pos : Type*} [DecidableEq Pos] (ps : List Pos) (q : Pos)
    (hq : q ∈ ps) : (synthesis ps).1 = some q ∨ q ∈ (synthesis ps).2 := by
  match ps, hq with
  | p :: rest, hq =>
    dsimp only [synthesis]
    split_ifs with h
    · left; have := List.all_eq_true.1 h q hq; simp at this; simp [this]
    · right; simpa using hq

/-- When members disagree, there is no shared conclusion: disagreement is reported, not
averaged away. -/
theorem synthesis_disagreement {Pos : Type*} [DecidableEq Pos] (ps : List Pos) (p q : Pos)
    (hp : p ∈ ps) (hq : q ∈ ps) (hpq : p ≠ q) : (synthesis ps).1 = none := by
  match ps, hp with
  | r :: rest, hp =>
    dsimp only [synthesis]
    split_ifs with h
    · have h1 := List.all_eq_true.1 h p hp; have h2 := List.all_eq_true.1 h q hq
      simp at h1 h2; exact absurd (h1.trans h2.symm) hpq
    · rfl

/-! ## 3. Correlated consensus -/

/-- The number of independent sources behind a set of agreeing answers: the number of distinct
training bases they come from. -/
def effectiveSources {B : Type*} [DecidableEq B] (bases : List B) : ℕ := bases.dedup.length

/-- **Correlated consensus.** Any number of agreeing models that share one training base count
as a single independent source. -/
theorem correlated_consensus {B : Type*} [DecidableEq B] (b : B) (n : ℕ) (hn : 0 < n) :
    effectiveSources (List.replicate n b) = 1 := by
  obtain ⟨k, rfl⟩ : ∃ k, n = k + 1 := ⟨n - 1, by omega⟩
  clear hn
  suffices h : (List.replicate (k + 1) b).dedup = [b] by simp [effectiveSources, h]
  induction k with
  | zero => simp
  | succ k ih =>
    rw [List.replicate_succ, List.dedup_cons_of_mem (List.mem_replicate.2 ⟨by omega, rfl⟩), ih]

/-- Agreement never counts for more than the number of distinct bases, and never more than the
number of models. -/
theorem effectiveSources_le {B : Type*} [DecidableEq B] (bases : List B) :
    effectiveSources bases ≤ bases.length := (List.dedup_sublist bases).length_le

end AgencyGovernance
