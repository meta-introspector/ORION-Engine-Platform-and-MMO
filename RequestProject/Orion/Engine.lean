module

public import Mathlib

/-!
# The ORION Engine: the loop, the stops, the ladder and the council

This file makes precise the *orchestration* rules stated in the ORION Engine Architecture
pages (the overview, *Open Research Intelligence Optimization Network*, *A Human-Centered
Approach to AI Safety* and *Operation Snake and Scale*) and proves that they do what the pages
promise. The evidence-weight formula `W(e)` from the same pages is treated separately in
`RequestProject/EvidenceWeight.lean` and `RequestProject/Hub/Reliability.lean`.

1. **The eleven-phase loop** (Define, Retrieve, Evaluate, Connect, Generate, Attack, Refine,
   Human Review, Test, Record, Reuse). A run may advance one phase at a time or "bounce" back
   to any earlier phase (Attack → Generate, Test → Define, Reuse → Define, …). It may never jump
   forward. Proved: no phase is ever skipped (`Run.visits_all_below`). In particular, nothing is
   tested, recorded or reused before a human review (`Run.humanReview_before`), and nothing
   reaches a human reviewer without first being attacked (`Run.attack_before_review`).
2. **The Independent Stop Mechanism** (Evidence Stop, Safety Stop, Authority Stop). Work proceeds
   exactly when none of the three stops holds (`mayProceed_iff`). Each stop halts work on its
   own, whatever the other two say (`evidence_stop`, `safety_stop`, `authority_stop`). An
   ordinary user can never resume a halted process (`user_cannot_resume`), and nobody can resume
   while a stop condition still holds (`no_resume_while_stopped`).
3. **The intervention ladder** of the Human Intent Safety Layer. The response rung is a published
   function of the accumulated risk of the whole interaction. Proved: ordinary low-risk sessions
   get ordinary assistance (`rung_benign`). The rung never drops within an interaction
   (`rung_append_mono`). Splitting a request into many harmless-looking pieces never lowers the
   response (`rung_fragmentation`). One turn of moderate risk moves the ladder by at most one rung,
   so responses stay proportional (`rung_step_le`).
4. **Operation Snake and Scale.** The cross-agent debate ("bounce") loop always ends within its
   recursion limit, either converging or handing the question to the human Catalyst
   (`debate_*`). The agent decision ledger only grows: an attempt to alter or delete another
   agent's decision object triggers a hard stop (`guard_*`). A package reaches the Catalyst only
   if the Auditor passed it and no hard stop fired (`reachesCatalyst_iff`).
-/

@[expose] public section

namespace Orion

/-! ## 1. The eleven-phase loop -/

/-- The eleven phases of the ORION loop, in order. -/
inductive Phase
  | define | retrieve | evaluate | connect | generate | attack | refine
  | humanReview | test | record | reuse
  deriving DecidableEq, Repr

namespace Phase

/-- Position of a phase in the loop, from `0` (Define) to `10` (Reuse). -/
def idx : Phase → ℕ
  | define => 0 | retrieve => 1 | evaluate => 2 | connect => 3 | generate => 4
  | attack => 5 | refine => 6 | humanReview => 7 | test => 8 | record => 9 | reuse => 10

theorem idx_injective : Function.Injective idx := by
  intro a b h; cases a <;> cases b <;> simp_all [idx]

theorem idx_le_ten (p : Phase) : p.idx ≤ 10 := by cases p <;> simp [idx]

/-- Every position `0 … 10` is the position of some phase. -/
theorem exists_of_le_ten (k : ℕ) (hk : k ≤ 10) : ∃ p : Phase, p.idx = k := by
  interval_cases k
  exacts [⟨define, rfl⟩, ⟨retrieve, rfl⟩, ⟨evaluate, rfl⟩, ⟨connect, rfl⟩, ⟨generate, rfl⟩,
    ⟨attack, rfl⟩, ⟨refine, rfl⟩, ⟨humanReview, rfl⟩, ⟨test, rfl⟩, ⟨record, rfl⟩, ⟨reuse, rfl⟩]

end Phase

/-- A permitted move: advance exactly one phase, or bounce back to any earlier phase
(for example Attack → Generate, Test → Define, or Reuse → Define to start a new problem). -/
def Step (p q : Phase) : Prop := q.idx = p.idx + 1 ∨ q.idx < p.idx

/-- A run of the engine: a sequence of phases, starting at Define, in which every move is
permitted. Time is indexed by `ℕ`; a run that has finished can simply bounce to Define. -/
structure Run where
  phase : ℕ → Phase
  start : phase 0 = Phase.define
  step : ∀ n, Step (phase n) (phase (n + 1))

namespace Run

variable (r : Run)

/-- **No phase is skipped.** If the run is at phase `q` at time `n`, then every phase up to `q`
has been visited at some time `≤ n`. -/
theorem visits_all_below (n : ℕ) :
    ∀ k ≤ (r.phase n).idx, ∃ i ≤ n, (r.phase i).idx = k := by
  induction n with
  | zero => intro k hk; exact ⟨0, le_rfl, by simp_all [r.start, Phase.idx]⟩
  | succ n ih =>
    intro k hk
    by_cases hkn : k ≤ (r.phase n).idx
    · obtain ⟨i, hi, h⟩ := ih k hkn; exact ⟨i, by omega, h⟩
    · refine ⟨n + 1, le_rfl, ?_⟩
      rcases r.step n with h | h <;> omega

/-- Every phase earlier than the current one was visited strictly earlier. -/
theorem phase_before {n : ℕ} (p : Phase) (hp : p.idx < (r.phase n).idx) :
    ∃ i < n, r.phase i = p := by
  obtain ⟨i, hi, h⟩ := r.visits_all_below n p.idx hp.le
  refine ⟨i, lt_of_le_of_ne hi ?_, Phase.idx_injective h⟩
  rintro rfl; omega

/-- **Human review gate.** Nothing is tested, recorded or reused until a human review has
taken place. -/
theorem humanReview_before {n : ℕ}
    (h : r.phase n = Phase.test ∨ r.phase n = Phase.record ∨ r.phase n = Phase.reuse) :
    ∃ i < n, r.phase i = Phase.humanReview := by
  apply r.phase_before
  rcases h with h | h | h <;> simp [h, Phase.idx]

/-- **Adversarial review first.** Nothing reaches a human reviewer without first passing
through the Attack (challenge) phase. -/
theorem attack_before_review {n : ℕ} (h : r.phase n = Phase.humanReview) :
    ∃ i < n, r.phase i = Phase.attack := by
  apply r.phase_before; simp [h, Phase.idx]

/-- Reaching Record at time `n` means the full sequence Define … Test was visited before. -/
theorem record_after_all {n : ℕ} (h : r.phase n = Phase.record) (p : Phase)
    (hp : p.idx < 9) : ∃ i < n, r.phase i = p := by
  apply r.phase_before; simpa [h, Phase.idx] using hp

end Run

/-- The loop really can bounce: this run goes forward to Attack, bounces back to Generate once,
then continues to Reuse and starts over. -/
def exampleRun : Run where
  phase n :=
    let seq : List Phase := [.define, .retrieve, .evaluate, .connect, .generate, .attack,
      .generate, .attack, .refine, .humanReview, .test, .record, .reuse]
    seq.getD (n % 13) .define
  start := rfl
  step n := by
    have h := Nat.mod_lt n (by norm_num : 13 > 0)
    have h' : (n + 1) % 13 = if n % 13 = 12 then 0 else n % 13 + 1 := by split_ifs <;> omega
    simp only [h']
    interval_cases n % 13 <;> simp [Step, Phase.idx]

/-! ## 2. The Independent Stop Mechanism -/

/-- The three questions checked before any further operational step. -/
structure StopInputs where
  /-- `false` means "We don't know enough." -/
  enoughEvidence : Bool
  /-- `false` means "Continuing would create unacceptable risk." -/
  acceptableRisk : Bool
  /-- `false` means "You haven't authorized this action." -/
  authorized : Bool
  deriving DecidableEq, Repr

/-- The three independent stop conditions. -/
inductive StopReason | evidence | safety | authority
  deriving DecidableEq, Repr

/-- The list of stops currently in force, so the interface can say *why* it stopped. -/
def stopReasons (s : StopInputs) : List StopReason :=
  (if s.enoughEvidence then [] else [.evidence]) ++
  (if s.acceptableRisk then [] else [.safety]) ++
  (if s.authorized then [] else [.authority])

/-- Work may proceed only when no stop is in force. -/
def mayProceed (s : StopInputs) : Bool := (stopReasons s).isEmpty

theorem mayProceed_iff (s : StopInputs) :
    mayProceed s = true ↔ s.enoughEvidence ∧ s.acceptableRisk ∧ s.authorized := by
  rcases s with ⟨_ | _, _ | _, _ | _⟩ <;> simp [mayProceed, stopReasons]

/-- The Evidence Stop halts work on its own, whatever the other two conditions say. -/
theorem evidence_stop (s : StopInputs) (h : s.enoughEvidence = false) :
    mayProceed s = false ∧ StopReason.evidence ∈ stopReasons s := by
  rcases s with ⟨_ | _, _ | _, _ | _⟩ <;> simp_all [mayProceed, stopReasons]

/-- The Safety Stop halts work on its own. -/
theorem safety_stop (s : StopInputs) (h : s.acceptableRisk = false) :
    mayProceed s = false ∧ StopReason.safety ∈ stopReasons s := by
  rcases s with ⟨_ | _, _ | _, _ | _⟩ <;> simp_all [mayProceed, stopReasons]

/-- The Authority Stop halts work on its own. -/
theorem authority_stop (s : StopInputs) (h : s.authorized = false) :
    mayProceed s = false ∧ StopReason.authority ∈ stopReasons s := by
  rcases s with ⟨_ | _, _ | _, _ | _⟩ <;> simp_all [mayProceed, stopReasons]

/-- The reported reasons are exactly the failed conditions: every reported stop is real. -/
theorem mem_stopReasons (s : StopInputs) (x : StopReason) :
    x ∈ stopReasons s ↔
      (x = .evidence ∧ s.enoughEvidence = false) ∨ (x = .safety ∧ s.acceptableRisk = false) ∨
      (x = .authority ∧ s.authorized = false) := by
  rcases s with ⟨_ | _, _ | _, _ | _⟩ <;> cases x <;> simp [stopReasons]

/-- Who is asking. Only a formally authorized operator holds override rights. -/
inductive Actor | user | operator
  deriving DecidableEq, Repr

/-- A halted process may be resumed only by an authorized operator, and only once every stop
condition has cleared. An ordinary user's recourse is to disengage. -/
def canResume (a : Actor) (s : StopInputs) : Bool := a == .operator && mayProceed s

/-- An authorized operator may halt at any time. -/
def canHalt (a : Actor) : Bool := a == .operator

/-- "An ordinary user cannot unilaterally override the safety boundary." -/
theorem user_cannot_resume (s : StopInputs) : canResume .user s = false := rfl

/-- Not even an operator can resume while any stop condition still holds. -/
theorem no_resume_while_stopped (a : Actor) (s : StopInputs) (h : stopReasons s ≠ []) :
    canResume a s = false := by
  simp [canResume, mayProceed, h]

theorem canResume_iff (a : Actor) (s : StopInputs) :
    canResume a s = true ↔ a = .operator ∧ stopReasons s = [] := by
  cases a <;> simp [canResume, mayProceed, List.isEmpty_iff]

theorem operator_can_halt : canHalt .operator = true := rfl

/-! ## 3. The intervention ladder -/

/-- Normal assistance, followed by the eight escalating interventions of the Human Intent
Safety Layer, in the page's order. -/
inductive Rung
  | assist | clarify | nameHarm | refuseOperational | offerAlternatives | deescalate
  | harmReduction | escalate | endInteraction
  deriving DecidableEq, Repr

/-- The rung at position `k`, `0 ≤ k ≤ 8` (anything above 8 is the top rung). -/
def Rung.atLevel : ℕ → Rung
  | 0 => .assist | 1 => .clarify | 2 => .nameHarm | 3 => .refuseOperational
  | 4 => .offerAlternatives | 5 => .deescalate | 6 => .harmReduction | 7 => .escalate
  | _ => .endInteraction

/-- Accumulated risk of an interaction: the total of the per-turn risk estimates. Each turn's
estimate is a natural number of "risk points", for example severity × confidence on fixed
published scales. -/
def trajectoryRisk (turns : List ℕ) : ℕ := turns.sum

/-- The rung position for an interaction: one rung per `step` risk points, capped at the top
rung `8`. `step` is a published policy parameter. -/
def rungLevel (step : ℕ) (turns : List ℕ) : ℕ := min 8 (trajectoryRisk turns / step)

/-- The rung itself. -/
def rung (step : ℕ) (turns : List ℕ) : Rung := Rung.atLevel (rungLevel step turns)

theorem rungLevel_le (step : ℕ) (turns : List ℕ) : rungLevel step turns ≤ 8 := min_le_left _ _

/-- **Ordinary assistance is preserved.** An interaction whose total risk stays below one step
gets ordinary help, with no intervention at all. -/
theorem rung_benign {step : ℕ} {turns : List ℕ} (h : trajectoryRisk turns < step) :
    rung step turns = .assist := by
  simp [rung, rungLevel, Nat.div_eq_of_lt h, Rung.atLevel]

/-- **The ladder does not reset mid-interaction.** Later turns never lower the rung. -/
theorem rung_append_mono (step : ℕ) (turns more : List ℕ) :
    rungLevel step turns ≤ rungLevel step (turns ++ more) := by
  unfold rungLevel trajectoryRisk
  rw [List.sum_append]
  exact min_le_min_left _ (Nat.div_le_div_right (Nat.le_add_right _ _))

/-- **No fragmentation loophole.** Replacing one request of risk `r` by any number of pieces
whose risks together add up to at least `r` never lowers the response. -/
theorem rung_fragmentation (step r : ℕ) (turns pieces : List ℕ) (h : r ≤ pieces.sum) :
    rungLevel step (turns ++ [r]) ≤ rungLevel step (turns ++ pieces) := by
  unfold rungLevel trajectoryRisk
  simp only [List.sum_append, List.sum_singleton]
  exact min_le_min_left _ (Nat.div_le_div_right (by omega))

/-- **Proportional responses.** One turn of risk at most `step` raises the ladder by at most one
rung, so the response escalates gradually. -/
theorem rung_step_le {step r : ℕ} (hs : 0 < step) (hr : r ≤ step) (turns : List ℕ) :
    rungLevel step (turns ++ [r]) ≤ rungLevel step turns + 1 := by
  unfold rungLevel trajectoryRisk
  simp only [List.sum_append, List.sum_singleton]
  have : (turns.sum + r) / step ≤ turns.sum / step + 1 :=
    (Nat.div_le_div_right (by omega)).trans (Nat.add_div_right _ hs).le
  omega

/-- A sustained dangerous campaign reaches the top rung: once total risk is at least `8 * step`,
the interaction ends. -/
theorem rung_top {step : ℕ} {turns : List ℕ} (hs : 0 < step)
    (h : 8 * step ≤ trajectoryRisk turns) : rung step turns = .endInteraction := by
  have : 8 ≤ trajectoryRisk turns / step := (Nat.le_div_iff_mul_le hs).2 (by linarith)
  simp [rung, rungLevel, min_eq_left this, Rung.atLevel]

/-! ## 4. Operation Snake and Scale -/

/-- Outcome of the cross-agent debate ("bounce") loop. -/
inductive DebateOutcome
  /-- The council converged in round `k`. -/
  | converged (k : ℕ)
  /-- The recursion limit was reached without convergence: hand the question to the Catalyst. -/
  | escalateToCatalyst
  deriving DecidableEq, Repr

/-- Run debate rounds `0, 1, …, limit − 1`, stopping at the first round that converges. -/
def debate (limit : ℕ) (converges : ℕ → Bool) : DebateOutcome :=
  match (List.range limit).find? converges with
  | some k => .converged k
  | none => .escalateToCatalyst

/-- A reported convergence is genuine, within the limit, and the first one. -/
theorem debate_converged {limit k : ℕ} {c : ℕ → Bool} (h : debate limit c = .converged k) :
    c k = true ∧ k < limit ∧ ∀ j < k, c j = false := by
  unfold debate at h
  split at h
  · rename_i k' hk
    cases h
    rw [List.find?_eq_some_iff_getElem] at hk
    obtain ⟨hck, i, hi, hik, hbefore⟩ := hk
    simp only [List.getElem_range] at hik hbefore
    subst hik
    refine ⟨hck, by simpa using hi, fun j hj => ?_⟩
    simpa using hbefore j hj
  · cases h

/-- **The loop always ends.** It escalates to the human exactly when no round within the
recursion limit converged. -/
theorem debate_escalate_iff (limit : ℕ) (c : ℕ → Bool) :
    debate limit c = .escalateToCatalyst ↔ ∀ j < limit, c j = false := by
  unfold debate
  split
  · rename_i k hk
    simp only [reduceCtorEq, false_iff, not_forall]
    have := List.find?_some hk
    have hmem := List.mem_of_find?_eq_some hk
    exact ⟨k, List.mem_range.1 hmem, by simp [this]⟩
  · rename_i hk
    simp only [List.find?_eq_none, List.mem_range] at hk
    simpa using hk

/-- The four Ghost Rider hard-stop thresholds of Operation Snake and Scale. -/
structure HardStops where
  intrusion : Bool
  doxxing : Bool
  unilateralOverride : Bool
  recursionLimit : Bool
  deriving DecidableEq, Repr

/-- Execution aborts if any threshold is breached. -/
def HardStops.abort (h : HardStops) : Bool :=
  h.intrusion || h.doxxing || h.unilateralOverride || h.recursionLimit

/-- The agent-decision ledger guard. A proposed new ledger is accepted only if it extends the
current one, so no agent can alter or delete an existing decision object. Anything else is a
unilateral override attempt, which triggers a hard stop (`none`). -/
def guard {α : Type*} [DecidableEq α] (current proposed : List α) : Option (List α) :=
  if current <+: proposed then some proposed else none

/-- Appending decision objects is always accepted. -/
theorem guard_append {α : Type*} [DecidableEq α] (current new : List α) :
    guard current (current ++ new) = some (current ++ new) := by
  simp [guard]

/-- An accepted update never changes or removes an existing entry. -/
theorem guard_preserves {α : Type*} [DecidableEq α] {current proposed next : List α}
    (h : guard current proposed = some next) : current <+: next := by
  unfold guard at h
  split at h
  · cases h; assumption
  · cases h

/-- Rewriting any existing decision object is rejected, which triggers a hard stop. -/
theorem guard_rejects_edit {α : Type*} [DecidableEq α] (pre post : List α) (a b : α)
    (hab : a ≠ b) (rest : List α) :
    guard (pre ++ a :: post) (pre ++ b :: rest) = none := by
  unfold guard
  rw [if_neg]
  rintro ⟨t, ht⟩
  have := congrArg (fun l => l[pre.length]?) ht
  simp at this
  exact hab this

/-- Every ledger in a sequence of accepted updates extends every earlier one. -/
theorem guard_run {α : Type*} [DecidableEq α] (L : ℕ → List α)
    (hL : ∀ n, guard (L n) (L (n + 1)) = some (L (n + 1))) {m n : ℕ} (hmn : m ≤ n) :
    L m <+: L n := by
  induction hmn with
  | refl => exact List.prefix_refl _
  | step _ ih => exact ih.trans (guard_preserves (hL _))

/-- A package reaches the human Catalyst only after the Auditor's publication pass succeeded
and no hard stop fired. -/
def reachesCatalyst (auditorPass : Bool) (h : HardStops) : Bool := auditorPass && !h.abort

theorem reachesCatalyst_iff (auditorPass : Bool) (h : HardStops) :
    reachesCatalyst auditorPass h = true ↔
      auditorPass = true ∧ h.intrusion = false ∧ h.doxxing = false ∧
        h.unilateralOverride = false ∧ h.recursionLimit = false := by
  rcases h with ⟨_ | _, _ | _, _ | _, _ | _⟩ <;> cases auditorPass <;>
    simp [reachesCatalyst, HardStops.abort]

end Orion
