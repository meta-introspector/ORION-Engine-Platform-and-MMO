module

public import RequestProject.EvidenceWeight

/-!
# Claim reliability for the knowledge hub

The ORION evidence rubric `W(e)` (see `RequestProject/EvidenceWeight.lean`) scores a
single piece of evidence. A knowledge hub needs a score for a whole *claim*, backed by
some pieces of supporting evidence and challenged by some pieces of conflicting evidence.

The original page defines the discrepancy ratio as
"conflicting evidence weight / supporting evidence weight". The earlier review found two
problems with that: it is circular (the weights already contain `D_r`) and it is undefined
when there is no supporting evidence. This file fixes both, as a design choice:

* weights inside the ratio are the *base* weights `W(e)` with `D_r = 0`, so nothing is circular;
* the weight of a side is its *strongest* item (a maximum, not a sum), so repeating the same
  or weaker evidence cannot move the score — the anti-volume principle, applied at claim level;
* with no supporting evidence, `D_r = 1`.

The claim score is then `best_support × (1 − D_r) / 1.5`, normalised into `[0, 1]`.
-/

@[expose] public section

namespace OrionHub

open SnakeAndScale

/-- One piece of evidence submitted to the hub. -/
structure Evidence where
  tier : SourceTier
  rigor : Rigor
  sources : ℕ
  deriving DecidableEq

/-- Base weight of a piece of evidence: `W(e)` with no discrepancy. -/
def Evidence.baseWeight (e : Evidence) : ℚ :=
  evidenceWeight e.tier e.rigor e.sources 0

/-- Weight of one side of a debate: its strongest item (`0` if empty). -/
def best (l : List Evidence) : ℚ :=
  l.foldr (fun e m => max e.baseWeight m) 0

/-- Discrepancy ratio, made well defined: `min 1 (best conflict / best support)`, and `1`
when there is no support. -/
def discrepancy (support conflict : List Evidence) : ℚ :=
  if best support = 0 then 1 else min 1 (best conflict / best support)

/-- Normalised reliability score of a claim, in `[0, 1]`. -/
def claimScore (support conflict : List Evidence) : ℚ :=
  best support * (1 - discrepancy support conflict) / (3 / 2)

lemma Evidence.baseWeight_nonneg (e : Evidence) : 0 ≤ e.baseWeight :=
  evidenceWeight_nonneg _ _ _ (by norm_num)

lemma Evidence.baseWeight_le (e : Evidence) : e.baseWeight ≤ 3 / 2 :=
  evidenceWeight_le _ _ _ le_rfl (by norm_num)

lemma best_nonneg (l : List Evidence) : 0 ≤ best l := by
  induction l with
  | nil => simp [best]
  | cons e l ih => exact le_max_of_le_right ih

lemma best_le (l : List Evidence) : best l ≤ 3 / 2 := by
  induction l with
  | nil => simp [best]; norm_num
  | cons e l ih => exact max_le e.baseWeight_le ih

lemma best_cons (e : Evidence) (l : List Evidence) : best (e :: l) = max e.baseWeight (best l) :=
  rfl

lemma le_best {e : Evidence} {l : List Evidence} (h : e ∈ l) : e.baseWeight ≤ best l := by
  induction l with
  | nil => simp at h
  | cons a l ih =>
    rw [best_cons]
    rcases List.mem_cons.1 h with rfl | h
    · exact le_max_left _ _
    · exact le_max_of_le_right (ih h)

/-- **Closed form.** The claim score is `max 0 (best support − best conflict) / 1.5`. -/
theorem claimScore_eq (support conflict : List Evidence) :
    claimScore support conflict = max 0 (best support - best conflict) / (3 / 2) := by
  unfold claimScore discrepancy
  have hs := best_nonneg support
  have hc := best_nonneg conflict
  split_ifs with h
  · rw [h, zero_sub, max_eq_left (by linarith : -best conflict ≤ 0)]; simp
  · have hpos : 0 < best support := lt_of_le_of_ne hs (Ne.symm h)
    congr 1
    rcases le_total (best conflict / best support) 1 with h1 | h1
    · rw [min_eq_right h1, mul_sub, mul_div_cancel₀ _ h, mul_one]
      rw [div_le_one hpos] at h1
      rw [max_eq_right (by linarith)]
    · rw [min_eq_left h1]
      rw [one_le_div hpos] at h1
      rw [max_eq_left (by linarith)]; ring

/-- The discrepancy ratio always lies in `[0, 1]`. -/
theorem discrepancy_mem_Icc (support conflict : List Evidence) :
    0 ≤ discrepancy support conflict ∧ discrepancy support conflict ≤ 1 := by
  unfold discrepancy
  split_ifs
  · norm_num
  · exact ⟨le_min zero_le_one (div_nonneg (best_nonneg _) (best_nonneg _)), min_le_left _ _⟩

/-- **Normalisation.** Every claim score lies in `[0, 1]`. -/
theorem claimScore_mem_Icc (support conflict : List Evidence) :
    0 ≤ claimScore support conflict ∧ claimScore support conflict ≤ 1 := by
  rw [claimScore_eq]
  have := best_le support
  have := best_nonneg conflict
  constructor
  · positivity
  · rw [div_le_one (by norm_num)]
    exact max_le (by norm_num) (by linarith)

/-- A claim with no supporting evidence scores `0`. -/
theorem claimScore_nil (conflict : List Evidence) : claimScore [] conflict = 0 := by
  rw [claimScore_eq]
  have := best_nonneg conflict
  have h0 : best [] = 0 := rfl
  rw [h0, zero_sub, max_eq_left (by linarith : -best conflict ≤ 0)]; simp

/-- The score `1` is reached: uncontested primary evidence with cryptographic proof and
five independent sources. -/
theorem claimScore_max :
    claimScore [⟨.primary, .cryptographic, 5⟩] [] = 1 := by
  rw [claimScore_eq]
  simp [best, Evidence.baseWeight, evidenceWeight, corroboration, SourceTier.weight,
    Rigor.weight]
  norm_num

/-- **Anti-volume, for supporting evidence.** Resubmitting evidence already on file does not
change the score, however often it is repeated. -/
theorem claimScore_dup_support {e : Evidence} {support : List Evidence} (h : e ∈ support)
    (conflict : List Evidence) :
    claimScore (e :: support) conflict = claimScore support conflict := by
  rw [claimScore_eq, claimScore_eq, best_cons, max_eq_right (le_best h)]

/-- **Anti-volume, for conflicting evidence.** Repeating a challenge already on file does not
lower the score either. -/
theorem claimScore_dup_conflict (support : List Evidence) {e : Evidence}
    {conflict : List Evidence} (h : e ∈ conflict) :
    claimScore support (e :: conflict) = claimScore support conflict := by
  rw [claimScore_eq, claimScore_eq, best_cons, max_eq_right (le_best h)]

/-- **Anti-volume, weak evidence.** Adding supporting evidence that is no stronger than the
strongest item already on file does not change the score. -/
theorem claimScore_weak_support {e : Evidence} {support conflict : List Evidence}
    (h : e.baseWeight ≤ best support) :
    claimScore (e :: support) conflict = claimScore support conflict := by
  rw [claimScore_eq, claimScore_eq, best_cons, max_eq_right h]

/-- Adding supporting evidence never lowers a claim's score. -/
theorem claimScore_cons_support_ge (e : Evidence) (support conflict : List Evidence) :
    claimScore support conflict ≤ claimScore (e :: support) conflict := by
  rw [claimScore_eq, claimScore_eq, best_cons]
  gcongr
  exact le_max_right _ _

/-- Adding conflicting evidence never raises a claim's score. -/
theorem claimScore_cons_conflict_le (support : List Evidence) (e : Evidence)
    (conflict : List Evidence) :
    claimScore support (e :: conflict) ≤ claimScore support conflict := by
  rw [claimScore_eq, claimScore_eq, best_cons]
  gcongr
  exact le_max_right _ _

/-- A claim scores strictly above `0` exactly when its strongest support outweighs its
strongest challenge. -/
theorem claimScore_pos_iff (support conflict : List Evidence) :
    0 < claimScore support conflict ↔ best conflict < best support := by
  rw [claimScore_eq]
  constructor
  · intro h
    by_contra hc
    push_neg at hc
    rw [max_eq_left (by linarith)] at h
    simp at h
  · intro h
    rw [max_eq_right (by linarith)]
    have : 0 < best support - best conflict := by linarith
    positivity

end OrionHub
