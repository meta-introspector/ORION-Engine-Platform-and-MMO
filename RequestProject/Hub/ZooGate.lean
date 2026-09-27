module

public import RequestProject.Hub.Reliability

/-!
# The Zoo gate: Devs 2.0 / EFMW epistemics inside the knowledge hub

Matthew Chenoweth Wright's white paper *Devs 2.0: EFMW* describes a pipeline in which models
propose, the **Monolithic Zoo** attacks, evidence arrives from outside, and **humans decide what
enters the canonical record**. It asks that every assertion carry one of the statuses
*proposed, derived, simulated, observed, replicated, contradicted, superseded, unknown*, and it
states several hard rules. This file gives each rule a precise meaning in the hub and proves it.

1. **"A generated hypothesis is not evidence. Neither is a simulation. Neither is an elegant
   derivation."** Only *observed* and *replicated* records feed the hub's claim score, so adding
   a proposed, derived or simulated record never changes a score (`ledgerScore_non_evidence_*`).
2. **"Humans determine what enters the canonical record"**, and the Zoo exists to attack. A
   record is admitted only with human approval, preregistration (frozen before the outcome), and
   no veto from any Zoo auditor. One veto blocks admission, and adding more auditors can never
   turn a rejection into an admission (`admit_*`).
3. **"It should not rewrite its historical predictions after observing outcomes."** The
   prediction ledger is append-only: every earlier ledger is a prefix of every later one
   (`Ledger.prefix_run`).
4. **CollapseΩ, "reality progressively removes alternatives."** Observations only narrow the set
   of live possibilities. The result does not depend on the order in which observations arrive,
   and the actual world is never eliminated by true observations (`collapse_*`).
-/

@[expose] public section

namespace OrionHub

/-! ## 1. Epistemic status: hypotheses are not evidence -/

/-- The eight epistemic statuses listed in *Devs 2.0: EFMW*, §5. -/
inductive Status
  | proposed | derived | simulated | observed | replicated | contradicted | superseded | unknown
  deriving DecidableEq

/-- Only observations and replications count as evidence. -/
def Status.isEvidence : Status → Bool
  | .observed | .replicated => true
  | _ => false

/-- A record in the corpus: a piece of evidence together with its epistemic status. -/
structure Record where
  status : Status
  evidence : Evidence

/-- The evidence that actually counts: records whose status is observed or replicated. -/
def evidenceOf (l : List Record) : List Evidence :=
  (l.filter fun r => r.status.isEvidence).map Record.evidence

/-- Claim score computed from status-tagged records. -/
def ledgerScore (support conflict : List Record) : ℚ :=
  claimScore (evidenceOf support) (evidenceOf conflict)

lemma evidenceOf_cons_of_not {r : Record} (h : r.status.isEvidence = false) (l : List Record) :
    evidenceOf (r :: l) = evidenceOf l := by
  simp [evidenceOf, h]

/-- **A hypothesis, derivation or simulation is not evidence (support side).** Adding a
supporting record that is not observed or replicated never changes the score. -/
theorem ledgerScore_non_evidence_support {r : Record} (h : r.status.isEvidence = false)
    (support conflict : List Record) :
    ledgerScore (r :: support) conflict = ledgerScore support conflict := by
  simp [ledgerScore, evidenceOf_cons_of_not h]

/-- **A hypothesis, derivation or simulation is not evidence (conflict side).** An
unobserved objection does not lower a score either. -/
theorem ledgerScore_non_evidence_conflict {r : Record} (h : r.status.isEvidence = false)
    (support conflict : List Record) :
    ledgerScore support (r :: conflict) = ledgerScore support conflict := by
  simp [ledgerScore, evidenceOf_cons_of_not h]

/-- A claim backed only by proposals, derivations and simulations scores `0`. -/
theorem ledgerScore_no_observations {support : List Record}
    (h : ∀ r ∈ support, r.status.isEvidence = false) (conflict : List Record) :
    ledgerScore support conflict = 0 := by
  have : evidenceOf support = [] := by
    simp only [evidenceOf, List.map_eq_nil_iff, List.filter_eq_nil_iff]
    intro r hr
    simp [h r hr]
  rw [ledgerScore, this, claimScore_nil]

/-- The listed non-evidence statuses. -/
theorem generated_not_evidence :
    Status.proposed.isEvidence = false ∧ Status.derived.isEvidence = false ∧
      Status.simulated.isEvidence = false := ⟨rfl, rfl, rfl⟩

/-! ## 2. The admission gate: humans decide, the Zoo can veto -/

/-- What is known about a candidate record when it is considered for the canonical record. -/
structure Review where
  /-- A human reviewer approved it. -/
  humanApproved : Bool
  /-- The prediction or protocol was frozen (preregistered) before the outcome was seen. -/
  frozenBeforeOutcome : Bool
  /-- One verdict per Zoo auditor that examined it: `true` means that auditor vetoes. -/
  zooVetoes : List Bool

/-- Admission rule for the canonical record. -/
def admit (r : Review) : Bool :=
  r.humanApproved && r.frozenBeforeOutcome && !(r.zooVetoes.any id)

/-- **Humans decide.** Nothing is admitted without human approval, however many automated
checks it passes. -/
theorem admit_requires_human {r : Review} (h : admit r = true) : r.humanApproved = true := by
  simp_all [admit]

/-- Nothing is admitted unless it was frozen before the outcome was observed. -/
theorem admit_requires_frozen {r : Review} (h : admit r = true) :
    r.frozenBeforeOutcome = true := by
  simp_all [admit]

/-- **One veto is enough.** If any Zoo auditor vetoes, the record is not admitted. -/
theorem admit_false_of_veto {r : Review} (h : true ∈ r.zooVetoes) : admit r = false := by
  simp only [admit, Bool.and_eq_false_iff, Bool.not_eq_false']
  right
  exact List.any_eq_true.2 ⟨true, h, rfl⟩

/-- **More criticism cannot launder a rejection.** Consulting additional Zoo auditors can turn an
admission into a rejection, but never a rejection into an admission. -/
theorem admit_of_admit_more_auditors {r : Review} (more : List Bool)
    (h : admit { r with zooVetoes := r.zooVetoes ++ more } = true) : admit r = true := by
  simp only [admit, Bool.and_eq_true, Bool.not_eq_true', List.any_append,
    Bool.or_eq_false_iff] at h ⊢
  exact ⟨h.1, h.2.1⟩

/-- The gate is exactly the conjunction of its three conditions. -/
theorem admit_iff (r : Review) :
    admit r = true ↔
      r.humanApproved = true ∧ r.frozenBeforeOutcome = true ∧ ∀ v ∈ r.zooVetoes, v = false := by
  simp [admit, and_assoc]

/-! ## 3. The append-only prediction ledger -/

/-- A ledger of predictions (or any records), oldest first. -/
structure Ledger (α : Type*) where
  entries : List α

namespace Ledger

variable {α : Type*}

/-- The only write operation: append a new entry at the end. -/
def record (L : Ledger α) (a : α) : Ledger α := ⟨L.entries ++ [a]⟩

/-- Apply a sequence of writes. -/
def run (L : Ledger α) (ops : List α) : Ledger α := ops.foldl record L

theorem run_entries (L : Ledger α) (ops : List α) : (L.run ops).entries = L.entries ++ ops := by
  induction ops generalizing L with
  | nil => simp [run]
  | cons a ops ih =>
    simp only [run, List.foldl_cons] at ih ⊢
    rw [ih]; simp [record]

/-- **History is never rewritten.** Whatever is written later, the earlier ledger survives
unchanged as a prefix. -/
theorem prefix_run (L : Ledger α) (ops : List α) : L.entries <+: (L.run ops).entries := by
  rw [run_entries]; exact List.prefix_append _ _

/-- Every past entry keeps its position and content. -/
theorem get_run (L : Ledger α) (ops : List α) {i : ℕ} (hi : i < L.entries.length) :
    (L.run ops).entries[i]? = L.entries[i]? := by
  rw [run_entries, List.getElem?_append_left hi]

end Ledger

/-! ## 4. CollapseΩ: observations narrow the possibility space -/

/-- The possibilities in `S` that are compatible with every observation in `obs`. -/
def collapse {W : Type*} (S : Set W) (obs : List (W → Prop)) : Set W :=
  {w | w ∈ S ∧ ∀ o ∈ obs, o w}

variable {W : Type*}

/-- Observations never add possibilities. -/
theorem collapse_subset (S : Set W) (obs : List (W → Prop)) : collapse S obs ⊆ S :=
  fun _ hw => hw.1

/-- Observing more never widens the possibility space. -/
theorem collapse_antitone (S : Set W) (obs more : List (W → Prop)) :
    collapse S (obs ++ more) ⊆ collapse S obs :=
  fun _ hw => ⟨hw.1, fun o ho => hw.2 o (List.mem_append_left _ ho)⟩

/-- Updating step by step equals updating on all observations at once. -/
theorem collapse_append (S : Set W) (obs more : List (W → Prop)) :
    collapse (collapse S obs) more = collapse S (obs ++ more) := by
  ext w
  simp only [collapse, Set.mem_setOf_eq, List.mem_append]
  constructor
  · rintro ⟨⟨hS, h1⟩, h2⟩
    exact ⟨hS, fun o ho => ho.elim (h1 o) (h2 o)⟩
  · rintro ⟨hS, h⟩
    exact ⟨⟨hS, fun o ho => h o (Or.inl ho)⟩, fun o ho => h o (Or.inr ho)⟩

/-- **Order does not matter.** The same observations in any order give the same result. -/
theorem collapse_perm (S : Set W) {obs obs' : List (W → Prop)} (h : obs.Perm obs') :
    collapse S obs = collapse S obs' := by
  ext w
  simp only [collapse, Set.mem_setOf_eq]
  constructor
  · rintro ⟨hS, hw⟩; exact ⟨hS, fun o ho => hw o (h.mem_iff.2 ho)⟩
  · rintro ⟨hS, hw⟩; exact ⟨hS, fun o ho => hw o (h.mem_iff.1 ho)⟩

/-- **Reality is never ruled out.** If the actual world was considered possible and every
observation is true of it, it survives the update. -/
theorem actual_survives {S : Set W} {obs : List (W → Prop)} {w : W} (hS : w ∈ S)
    (htrue : ∀ o ∈ obs, o w) : w ∈ collapse S obs :=
  ⟨hS, htrue⟩

end OrionHub
