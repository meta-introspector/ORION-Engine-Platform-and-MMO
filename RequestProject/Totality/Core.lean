module

public import Mathlib

/-!
# Totality: the formal invariant layer

This file is the "second formal layer in Lean" proposed for the Totality engine: it does not
run the real-time simulator, it states and proves the invariants that any faithful
implementation must satisfy. Everything is generic in the state type `S` and the intervention
type `I`, so the same theorems apply to one room, a house, a village or a world.

* **Engine / determinism** (`/world`, `/archimedes`): an engine is a pure step function
  `step seed state intervention`. Same seed, same state, same intervention, same result.
* **Provenance** (`/provenance`): every step is logged as an `Event` (id, parent state, seed,
  intervention, child state, engine version). A log is *coherent* when it chains correctly.
  Exact replay from the recorded seeds and interventions reconstructs the whole log
  (`eq_record_of_coherent`), and "why did this happen?" has an exact answer
  (`event_explained`, `causal_link`).
* **Zoo audit** (`/zoo`): a decidable replay audit that accepts exactly the coherent logs
  (`audit_iff`) and rejects any tampered log (`audit_rejects_tamper`). Adding more audits never
  turns a failure into a pass (`zooPass_cons`).
* **Janus** (`/janus`): a counterfactual that changes the intervention at time `t` agrees with
  the actual history on everything before `t` (`janus_agree_before`).
* **Cuby / Borges** (`/cuby`, `/borges`): branching over a finite menu of interventions; the
  stored branch set has exactly `k ^ n` histories, every stored branch replays to its stored
  state, and every possible history is stored (`branches_*`).
* **Thor** (`/thor`): a constraint preserved by every step holds along every history, every
  branch and every replay (`thor_*`), so the monitor never raises a warning (`thorWarnings_nil`).
* **EFMW coherence** (`/efmw`): the residual monitor lists exactly the events whose child state
  does not match the engine; it is empty for every recorded log (`residuals_record`).
* **Dragon** (`/dragon`): in a finite state space every autonomous regime is eventually
  periodic, with transient and period at most the number of states (`dragon_eventually_periodic`).
-/

@[expose] public section

namespace Totality

/-! ## Engine and determinism -/

/-- A deterministic engine: a pure step function of a random seed, a state and an
intervention, together with an engine version stamp. -/
structure Engine (S I : Type*) where
  version : ℕ
  step : ℕ → S → I → S

variable {S I : Type*} (E : Engine S I)

/-- Run a list of commands (seed, intervention) from a state. -/
def Engine.run (s : S) : List (ℕ × I) → S
  | [] => s
  | c :: cs => Engine.run (E.step c.1 s c.2) cs

/-- The full list of states visited, starting with the initial state. -/
def Engine.trace (s : S) : List (ℕ × I) → List S
  | [] => [s]
  | c :: cs => s :: Engine.trace (E.step c.1 s c.2) cs

@[simp] lemma Engine.run_nil (s : S) : E.run s [] = s := rfl
@[simp] lemma Engine.run_cons (s : S) (c : ℕ × I) (cs : List (ℕ × I)) :
    E.run s (c :: cs) = E.run (E.step c.1 s c.2) cs := rfl
@[simp] lemma Engine.trace_nil (s : S) : E.trace s [] = [s] := rfl
@[simp] lemma Engine.trace_cons (s : S) (c : ℕ × I) (cs : List (ℕ × I)) :
    E.trace s (c :: cs) = s :: E.trace (E.step c.1 s c.2) cs := rfl

/-- Running the concatenation of two command lists is running one after the other. -/
theorem Engine.run_append (s : S) (xs ys : List (ℕ × I)) :
    E.run s (xs ++ ys) = E.run (E.run s xs) ys := by
  induction xs generalizing s with
  | nil => rfl
  | cons c cs ih => exact ih _

@[simp] lemma Engine.length_trace (s : S) (cs : List (ℕ × I)) :
    (E.trace s cs).length = cs.length + 1 := by
  induction cs generalizing s with
  | nil => rfl
  | cons c cs ih => simp [ih]

/-- The last state of the trace is the result of the run. -/
theorem Engine.getLast_trace (s : S) (cs : List (ℕ × I)) :
    (E.trace s cs).getLast (by cases cs <;> simp) = E.run s cs := by
  induction cs generalizing s with
  | nil => rfl
  | cons c cs ih =>
    simp only [Engine.trace_cons, Engine.run_cons]
    rw [List.getLast_cons (by cases cs <;> simp)]
    exact ih _

/-! ## Provenance -/

/-- A provenance record for one step. The timestamp is the event id (the step index). -/
structure Event (S I : Type*) where
  eventId : ℕ
  parent : S
  seed : ℕ
  input : I
  child : S
  engineVersion : ℕ
  deriving DecidableEq

/-- The commands (seed, intervention) recorded in a log. -/
def inputs (log : List (Event S I)) : List (ℕ × I) :=
  log.map fun e => (e.seed, e.input)

/-- The log the engine writes when it runs `cs` from `s`, numbering events from `n`. -/
def Engine.recordFrom : ℕ → S → List (ℕ × I) → List (Event S I)
  | _, _, [] => []
  | n, s, c :: cs =>
    ⟨n, s, c.1, c.2, E.step c.1 s c.2, E.version⟩ :: Engine.recordFrom (n + 1) (E.step c.1 s c.2) cs

/-- The log the engine writes when it runs `cs` from `s`. -/
def Engine.record (s : S) (cs : List (ℕ × I)) : List (Event S I) := E.recordFrom 0 s cs

/-- A log is coherent (from event id `n` and state `s`) when ids count up, each event's parent
is the previous child (or `s`), its engine version is the current one, and its child is exactly
what the engine computes from its parent, seed and intervention. -/
def Engine.CoherentFrom : ℕ → S → List (Event S I) → Prop
  | _, _, [] => True
  | n, s, e :: es =>
    e.eventId = n ∧ e.parent = s ∧ e.engineVersion = E.version ∧
      e.child = E.step e.seed s e.input ∧ Engine.CoherentFrom (n + 1) e.child es

@[simp] lemma inputs_recordFrom (n : ℕ) (s : S) (cs : List (ℕ × I)) :
    inputs (E.recordFrom n s cs) = cs := by
  induction cs generalizing n s with
  | nil => rfl
  | cons c cs ih => simp [Engine.recordFrom, inputs] at ih ⊢; exact ih _ _

/-- Every log written by the engine is coherent. -/
theorem Engine.coherent_recordFrom (n : ℕ) (s : S) (cs : List (ℕ × I)) :
    E.CoherentFrom n s (E.recordFrom n s cs) := by
  induction cs generalizing n s with
  | nil => trivial
  | cons c cs ih => exact ⟨rfl, rfl, rfl, rfl, ih _ _⟩

/-- **Exact replay.** A coherent log is reconstructed, field by field, by re-running the engine
on the seeds and interventions it records. -/
theorem Engine.eq_record_of_coherent (n : ℕ) (s : S) (log : List (Event S I))
    (h : E.CoherentFrom n s log) : log = E.recordFrom n s (inputs log) := by
  induction log generalizing n s with
  | nil => rfl
  | cons e es ih =>
    obtain ⟨h1, h2, h3, h4, h5⟩ := h
    have := ih _ _ h5
    obtain ⟨id, par, sd, inp, ch, ver⟩ := e
    simp only at h1 h2 h3 h4 h5 this
    subst h1 h2 h3 h4
    exact congrArg _ this

/-- A log is coherent exactly when it equals the replay of its own recorded inputs. -/
theorem Engine.coherent_iff_eq_record (n : ℕ) (s : S) (log : List (Event S I)) :
    E.CoherentFrom n s log ↔ log = E.recordFrom n s (inputs log) := by
  refine ⟨E.eq_record_of_coherent n s log, fun h => ?_⟩
  rw [h]; exact E.coherent_recordFrom _ _ _

/-- The recorded child states are exactly the states visited after the start. -/
theorem Engine.map_child_recordFrom (n : ℕ) (s : S) (cs : List (ℕ × I)) :
    (E.recordFrom n s cs).map Event.child = (E.trace s cs).tail := by
  induction cs generalizing n s with
  | nil => rfl
  | cons c cs ih =>
    simp only [Engine.recordFrom, List.map_cons, Engine.trace_cons, List.tail_cons, ih]
    cases cs <;> rfl

/-- **Replay of the final state.** In a coherent log starting at `s`, the last recorded state is
the result of re-running the recorded inputs from `s`. -/
theorem Engine.replay_final (n : ℕ) (s : S) (log : List (Event S I))
    (h : E.CoherentFrom n s log) :
    (s :: log.map Event.child).getLast (by simp) = E.run s (inputs log) := by
  have hl : log.map Event.child = (E.trace s (inputs log)).tail := by
    conv_lhs => rw [E.eq_record_of_coherent n s log h]
    exact E.map_child_recordFrom _ _ _
  have ht : s :: (E.trace s (inputs log)).tail = E.trace s (inputs log) := by
    cases inputs log <;> rfl
  simp only [hl, ht]
  exact E.getLast_trace s (inputs log)

/-- **"Why did this happen?"** Every event in a coherent log is explained exactly: its child
state is the engine's step applied to its recorded parent, seed and intervention. -/
theorem Engine.event_explained (n : ℕ) (s : S) (log : List (Event S I))
    (h : E.CoherentFrom n s log) (e : Event S I) (he : e ∈ log) :
    e.child = E.step e.seed e.parent e.input ∧ e.engineVersion = E.version := by
  induction log generalizing n s with
  | nil => simp at he
  | cons e' es ih =>
    obtain ⟨_, h2, h3, h4, h5⟩ := h
    rcases List.mem_cons.1 he with rfl | he
    · exact ⟨h2 ▸ h4, h3⟩
    · exact ih _ _ h5 he

/-- **Causal chain.** In a coherent log each event's parent is the previous event's child, so
the explanation of any event can be followed back to the initial state. -/
theorem Engine.causal_link (n : ℕ) (s : S) (log : List (Event S I))
    (h : E.CoherentFrom n s log) (i : ℕ) (hi : i + 1 < log.length) :
    log[i + 1].parent = log[i].child := by
  induction log generalizing n s i with
  | nil => simp at hi
  | cons e es ih =>
    obtain ⟨_, _, _, _, h5⟩ := h
    cases i with
    | zero =>
      cases es with
      | nil => simp at hi
      | cons e2 es2 => exact h5.2.1
    | succ i => exact ih _ _ h5 i (by simpa using hi)

/-! ## Zoo audit -/

section Audit
variable [DecidableEq S] [DecidableEq I]

/-- The replay audit: re-run the engine on the recorded inputs and compare with the log. -/
def Engine.audit (n : ℕ) (s : S) (log : List (Event S I)) : Bool :=
  decide (log = E.recordFrom n s (inputs log))

/-- The replay audit accepts exactly the coherent logs. -/
theorem Engine.audit_iff (n : ℕ) (s : S) (log : List (Event S I)) :
    E.audit n s log = true ↔ E.CoherentFrom n s log := by
  simp [Engine.audit, E.coherent_iff_eq_record]

/-- Every log written by the engine passes the replay audit. -/
theorem Engine.audit_record (s : S) (cs : List (ℕ × I)) : E.audit 0 s (E.record s cs) = true :=
  (E.audit_iff _ _ _).2 (E.coherent_recordFrom _ _ _)

/-- **Tamper detection.** If a log is altered in any field while keeping the same recorded
seeds and interventions, the audit rejects the altered log. -/
theorem Engine.audit_rejects_tamper (n : ℕ) (s : S) (log log' : List (Event S I))
    (h : E.CoherentFrom n s log) (hne : log' ≠ log) (hin : inputs log' = inputs log) :
    E.audit n s log' = false := by
  by_contra hc
  have h' := (E.audit_iff n s log').1 (by simpa using hc)
  exact hne (by rw [E.eq_record_of_coherent n s _ h', E.eq_record_of_coherent n s _ h, hin])

/-- A Zoo is a list of audits; a log passes when every audit passes. -/
def zooPass (zoo : List (List (Event S I) → Bool)) (log : List (Event S I)) : Bool :=
  zoo.all fun t => t log

omit [DecidableEq S] [DecidableEq I] in
/-- Adding an auditor never turns a failure into a pass. -/
theorem zooPass_cons (t : List (Event S I) → Bool) (zoo : List (List (Event S I) → Bool))
    (log : List (Event S I)) (h : zooPass zoo log = false) : zooPass (t :: zoo) log = false := by
  simp only [zooPass, List.all_cons, Bool.and_eq_false_iff] at h ⊢
  exact Or.inr h

/-- A Zoo containing the replay audit rejects every tampered log. -/
theorem zooPass_rejects_tamper (zoo : List (List (Event S I) → Bool)) (n : ℕ) (s : S)
    (log log' : List (Event S I)) (h : E.CoherentFrom n s log) (hne : log' ≠ log)
    (hin : inputs log' = inputs log) : zooPass (E.audit n s :: zoo) log' = false := by
  simp [zooPass, E.audit_rejects_tamper n s log log' h hne hin]

/-! ## EFMW coherence monitor -/

/-- The residual monitor: ids of events whose child does not match the engine's step. -/
def Engine.residuals (log : List (Event S I)) : List ℕ :=
  (log.filter fun e => decide (e.child ≠ E.step e.seed e.parent e.input)).map Event.eventId

omit [DecidableEq I] in
/-- A coherent log has no residuals. -/
theorem Engine.residuals_of_coherent (n : ℕ) (s : S) (log : List (Event S I))
    (h : E.CoherentFrom n s log) : E.residuals log = [] := by
  simp only [Engine.residuals, List.map_eq_nil_iff, List.filter_eq_nil_iff, decide_eq_true_eq,
    not_not]
  exact fun e he => (E.event_explained n s log h e he).1

omit [DecidableEq I] in
/-- Every log written by the engine has no residuals. -/
theorem Engine.residuals_record (s : S) (cs : List (ℕ × I)) : E.residuals (E.record s cs) = [] :=
  E.residuals_of_coherent 0 s _ (E.coherent_recordFrom _ _ _)

end Audit

/-! ## Janus: counterfactuals -/

/-- Prefix agreement: the trace of `xs ++ ys` starts with the trace of `xs`. -/
theorem Engine.trace_append_take (s : S) (xs ys : List (ℕ × I)) :
    (E.trace s (xs ++ ys)).take (xs.length + 1) = E.trace s xs := by
  induction xs generalizing s with
  | nil => cases ys <;> rfl
  | cons c cs ih => simp [ih]

/-- **Janus.** A counterfactual that changes the history from time `t = xs.length` on (any
intervention `a` versus `b`, any continuations) agrees with the actual history on every state up
to and including time `t`: the future cannot change the past. -/
theorem Engine.janus_agree_before (s : S) (xs ys zs : List (ℕ × I)) (a b : ℕ × I) :
    (E.trace s (xs ++ a :: ys)).take (xs.length + 1) =
      (E.trace s (xs ++ b :: zs)).take (xs.length + 1) := by
  rw [E.trace_append_take, E.trace_append_take]

/-- The logs agree too: the counterfactual log and the actual log share their first `t` events. -/
theorem Engine.recordFrom_append_take (n : ℕ) (s : S) (xs ys : List (ℕ × I)) :
    (E.recordFrom n s (xs ++ ys)).take xs.length = E.recordFrom n s xs := by
  induction xs generalizing n s with
  | nil => simp [Engine.recordFrom]
  | cons c cs ih => simp [Engine.recordFrom, ih]

/-- The counterfactual state is obtained by applying the alternative intervention at the branch
point and replaying the continuation from there. -/
theorem Engine.janus_branch_point (s : S) (xs ys : List (ℕ × I)) (c : ℕ × I) :
    E.run s (xs ++ c :: ys) = E.run (E.step c.1 (E.run s xs) c.2) ys := by
  rw [E.run_append]; rfl

/-! ## Cuby branching and Borges storage -/

/-- All histories of length `n` over a finite menu `opts` of commands, stored with their final
states. -/
def Engine.branches (opts : List (ℕ × I)) : ℕ → S → List (List (ℕ × I) × S)
  | 0, s => [([], s)]
  | n + 1, s => opts.flatMap fun c =>
      (Engine.branches opts n (E.step c.1 s c.2)).map fun p => (c :: p.1, p.2)

/-- The Borges store holds exactly `k ^ n` histories, `k` the menu size. -/
theorem Engine.branches_length (opts : List (ℕ × I)) (n : ℕ) (s : S) :
    (E.branches opts n s).length = opts.length ^ n := by
  induction n generalizing s with
  | zero => rfl
  | succ n ih =>
    simp only [Engine.branches, List.length_flatMap, List.length_map, ih]
    rw [List.map_const', List.sum_replicate, smul_eq_mul, pow_succ, mul_comm]

/-- Every stored branch is sound: its history has length `n`, uses only menu commands, and its
stored state is exactly the replay of its history. -/
theorem Engine.branches_sound (opts : List (ℕ × I)) (n : ℕ) (s : S)
    (p : List (ℕ × I) × S) (hp : p ∈ E.branches opts n s) :
    p.2 = E.run s p.1 ∧ p.1.length = n ∧ ∀ c ∈ p.1, c ∈ opts := by
  induction n generalizing s p with
  | zero => simp [Engine.branches] at hp; subst hp; simp
  | succ n ih =>
    simp only [Engine.branches, List.mem_flatMap, List.mem_map] at hp
    obtain ⟨c, hc, q, hq, rfl⟩ := hp
    obtain ⟨h1, h2, h3⟩ := ih _ q hq
    refine ⟨h1, by simp [h2], ?_⟩
    intro d hd
    rcases List.mem_cons.1 hd with rfl | hd
    · exact hc
    · exact h3 d hd

/-- Every possible history over the menu is stored (no unrealized possibility is lost). -/
theorem Engine.branches_complete (opts : List (ℕ × I)) (s : S) (h : List (ℕ × I))
    (hopts : ∀ c ∈ h, c ∈ opts) : (h, E.run s h) ∈ E.branches opts h.length s := by
  induction h generalizing s with
  | nil => simp [Engine.branches]
  | cons c cs ih =>
    simp only [Engine.branches, List.length_cons, List.mem_flatMap, List.mem_map]
    exact ⟨c, hopts c (by simp), (cs, E.run (E.step c.1 s c.2) cs),
      ih _ (fun d hd => hopts d (by simp [hd])), rfl⟩

/-! ## Thor: constraints -/

/-- A constraint preserved by every step, for every seed and intervention. -/
def Engine.Preserves (C : S → Prop) : Prop := ∀ seed s i, C s → C (E.step seed s i)

theorem Engine.thor_run {C : S → Prop} (hC : E.Preserves C) (s : S) (hs : C s)
    (cs : List (ℕ × I)) : C (E.run s cs) := by
  induction cs generalizing s with
  | nil => exact hs
  | cons c cs ih => exact ih _ (hC _ _ _ hs)

/-- **Thor.** A preserved constraint holds at every state of every history. -/
theorem Engine.thor_trace {C : S → Prop} (hC : E.Preserves C) (s : S) (hs : C s)
    (cs : List (ℕ × I)) : ∀ t ∈ E.trace s cs, C t := by
  induction cs generalizing s with
  | nil => simpa using hs
  | cons c cs ih =>
    intro t ht
    rcases List.mem_cons.1 ht with rfl | ht
    · exact hs
    · exact ih _ (hC _ _ _ hs) t ht

/-- A preserved constraint holds in every stored branch. -/
theorem Engine.thor_branches {C : S → Prop} (hC : E.Preserves C) (s : S) (hs : C s)
    (opts : List (ℕ × I)) (n : ℕ) (p : List (ℕ × I) × S) (hp : p ∈ E.branches opts n s) :
    C p.2 := by
  rw [(E.branches_sound opts n s p hp).1]; exact E.thor_run hC s hs _

/-- The Thor monitor: ids of logged events whose child violates the constraint. -/
def thorWarnings (C : S → Prop) [DecidablePred C] (log : List (Event S I)) : List ℕ :=
  (log.filter fun e => !decide (C e.child)).map Event.eventId

/-- A preserved constraint never raises a warning in a log the engine wrote. -/
theorem Engine.thorWarnings_nil {C : S → Prop} [DecidablePred C] (hC : E.Preserves C) (n : ℕ)
    (s : S) (hs : C s) (cs : List (ℕ × I)) : thorWarnings C (E.recordFrom n s cs) = [] := by
  have key : ∀ e ∈ E.recordFrom n s cs, C e.child := by
    intro e he
    have hmem : e.child ∈ (E.recordFrom n s cs).map Event.child := List.mem_map_of_mem he
    rw [E.map_child_recordFrom] at hmem
    exact E.thor_trace hC s hs cs _ (List.mem_of_mem_tail hmem)
  simp only [thorWarnings, List.map_eq_nil_iff, List.filter_eq_nil_iff]
  intro e he
  simpa using key e he

/-! ## Dragon: attractors and regimes -/

/-- **Dragon.** In a finite state space, any autonomous regime `f` (for example the engine with
a fixed seed and no intervention) is eventually periodic: after a transient of length `μ` the
trajectory repeats with period `p`, and together they are at most the number of states. -/
theorem dragon_eventually_periodic [Fintype S] (f : S → S) (s : S) :
    ∃ μ p, 0 < p ∧ μ + p ≤ Fintype.card S ∧ ∀ n, μ ≤ n → f^[n + p] s = f^[n] s := by
  obtain ⟨i, j, hne, hij⟩ := Fintype.exists_ne_map_eq_of_card_lt
    (fun k : Fin (Fintype.card S + 1) => f^[k] s) (by simp)
  have key : ∀ a b : Fin (Fintype.card S + 1), a < b → f^[a] s = f^[b] s →
      ∃ μ p, 0 < p ∧ μ + p ≤ Fintype.card S ∧ ∀ n, μ ≤ n → f^[n + p] s = f^[n] s := by
    intro a b hab he
    have hab' : (a : ℕ) < b := hab
    have hb := b.isLt
    refine ⟨a, b - a, by omega, by omega, fun n hn => ?_⟩
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hn
    rw [show (a : ℕ) + k + (b - a) = k + b by omega, show (a : ℕ) + k = k + a by omega,
      Function.iterate_add_apply, Function.iterate_add_apply, ← he]
  rcases lt_or_gt_of_ne hne with h | h
  · exact key i j h hij
  · exact key j i h hij.symm

/-- The attractor reached is invariant: from time `μ` on, the trajectory stays inside the cycle
`{f^[μ] s, …, f^[μ + p - 1] s}`. -/
theorem dragon_stays_in_cycle (f : S → S) (s : S) (μ p : ℕ) (hp : 0 < p)
    (h : ∀ n, μ ≤ n → f^[n + p] s = f^[n] s) (n : ℕ) (hn : μ ≤ n) :
    ∃ k < p, f^[n] s = f^[μ + k] s := by
  induction n, hn using Nat.le_induction with
  | base => exact ⟨0, hp, rfl⟩
  | succ n hn ih =>
    obtain ⟨k, hk, he⟩ := ih
    by_cases hk1 : k + 1 < p
    · refine ⟨k + 1, hk1, ?_⟩
      rw [Function.iterate_succ_apply', he, ← Function.iterate_succ_apply' f]
      rfl
    · refine ⟨0, hp, ?_⟩
      have hkp : k + 1 = p := by omega
      rw [Function.iterate_succ_apply', he, ← Function.iterate_succ_apply' f,
        show (μ + k).succ = μ + p by omega, h μ le_rfl, add_zero]

end Totality
