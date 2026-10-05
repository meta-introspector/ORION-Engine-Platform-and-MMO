module

public import Mathlib

/-!
# Successive agreement does not imply stability

An exact mathematical illustration for the linked discussion of measurement anchoring.
This says nothing about whether any particular physical constant has changed, nor does
it establish a statistical claim about any data set.
-/

@[expose] public section
namespace RoundThreeLinks

/-- A sequence whose successive published readings differ by exactly `step`. -/
noncomputable def anchoredReadings (step : ℝ) (n : ℕ) : ℝ := n * step

/-- Any positive allowed step supports readings which always agree with their
predecessor to within that step but eventually drift past any given threshold. -/
theorem local_agreement_allows_unbounded_drift (step : ℝ) (hs : 0 < step)
    (bound : ℝ) :
    (∀ n : ℕ, anchoredReadings step (n + 1) - anchoredReadings step n = step) ∧
    ∃ n : ℕ, bound < anchoredReadings step n - anchoredReadings step 0 := by
  constructor
  · intro n
    simp [anchoredReadings, Nat.cast_add, Nat.cast_one, add_mul]
  · obtain ⟨n, hn⟩ := exists_nat_gt (bound / step)
    refine ⟨n, ?_⟩
    simp only [anchoredReadings, Nat.cast_zero, zero_mul, sub_zero]
    have h := (div_lt_iff₀ hs).mp hn
    nlinarith

end RoundThreeLinks
