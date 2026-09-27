module

public import Mathlib

/-!
# The explicit numerical claims in the TGS:ATE documents

This file checks every explicit piece of arithmetic or geometry in the supplied documents
that has a definite mathematical meaning. It says nothing about the physical,
spiritual or interpretive claims those numbers are meant to support.
-/

@[expose] public section

namespace TGSNumerics

open Real

/-! ## The Watermelon Equation V2.0 -/

/-- "1 + 4 + 4 = 9": the digit sum of `144` is `9`. -/
theorem digitSum_144 : (Nat.digits 10 144).sum = 9 := by norm_num

/-- Appendix step 2: `S = A / 4` with `A = 144` gives `S = 36`. -/
theorem entropy_step : (144 : ℚ) / 4 = 36 := by norm_num

/-- Appendix step 3: `36 = 12 J` has the unique solution `J = 3`. -/
theorem solve_J (J : ℚ) : 36 = 12 * J ↔ J = 3 := by constructor <;> intro h <;> linarith

/-- "Output (3 + 6 = 9)": the digit sum of `36` is also `9`. -/
theorem digitSum_36 : (Nat.digits 10 36).sum = 9 := by norm_num

/-- "The sum is 1.5 + 1.5 = 3." -/
theorem one_half_sum : (3 / 2 : ℚ) + 3 / 2 = 3 := by norm_num

/-- Bekenstein–Hawking `S = k A / (4 l_P²)` in units with `k = l_P = 1` and `A = 144`
gives `36`, the value the appendix uses. -/
theorem bekenstein_hawking_units (k lP A : ℝ) (hk : k = 1) (hl : lP = 1) (hA : A = 144) :
    k * A / (4 * lP ^ 2) = 36 := by subst hk hl hA; norm_num

/-- Read as numbers, `144 = 000` is false: `000` is the number `0`. -/
theorem literal_144_ne_000 : (144 : ℕ) ≠ 000 := by decide

/-- The five filter-state symbols of *The Tri-Sphere Architecture*, taken literally as
comparisons of natural numbers: only `<>` (not equal) and `>` hold. The documents use these
symbols as labels, not as numerical statements. -/
theorem literal_filter_states :
    (144 : ℕ) ≠ 000 ∧ ¬ (144 : ℕ) < 000 ∧ (144 : ℕ) > 000 ∧ ¬ (144 : ℕ) = 000 := by decide

/-! ## Geometry: the dodecahedron, `12 × 12 = 144`, and "the 144° angle" -/

/-- "The multiplication of the 12 outer encoding faces ... by the 12 inner projecting faces
yields the 144." -/
theorem twelve_mul_twelve : 12 * 12 = 144 := by norm_num

/-- Regular dodecahedron: 12 pentagonal faces give `12·5/2 = 30` edges, and with 20 vertices
Euler's formula `V - E + F = 2` holds. -/
theorem dodecahedron_counts : 12 * 5 / 2 = 30 ∧ (20 : ℤ) - 30 + 12 = 2 := by norm_num

/-- Interior angle of a regular `n`-gon, in degrees. -/
def interiorAngle (n : ℕ) : ℚ := ((n : ℚ) - 2) * 180 / n

/-- 144° is the interior angle of the regular **decagon** ... -/
theorem interiorAngle_decagon : interiorAngle 10 = 144 := by norm_num [interiorAngle]

/-- ... whereas the faces of the dodecahedron are regular pentagons, with angle 108°. -/
theorem interiorAngle_pentagon : interiorAngle 5 = 108 := by norm_num [interiorAngle]

/-- 144° is not the dihedral angle of the regular dodecahedron either: that angle has cosine
`-1/√5` (a standard fact, used here only as the value being compared), while
`cos 144° = cos (4π/5) = -(1 + √5)/4`. -/
theorem cos_144_ne_dodecahedral_dihedral : Real.cos (4 * π / 5) ≠ -1 / √5 := by
  have h : Real.cos (4 * π / 5) = -((1 + √5) / 4) := by
    rw [show 4 * π / 5 = π - π / 5 by ring, Real.cos_pi_sub, Real.cos_pi_div_five]
  rw [h]
  intro heq
  have h5 : (0 : ℝ) < √5 := by positivity
  have hsq : √5 * √5 = 5 := Real.mul_self_sqrt (by norm_num)
  field_simp at heq
  nlinarith

/-! ## The 13 Levels of Geometric Integration

The document presents the levels as a linear state machine `L1 → L2 → ⋯ → L13`. -/

/-- The transition function of the 13-level chain (`none` means no further level). -/
def nextLevel (k : Fin 13) : Option (Fin 13) :=
  if h : k.val + 1 < 13 then some ⟨k.val + 1, h⟩ else none

/-- Level 13 (index 12) is terminal and every other level has a successor, so the chain from
Level 1 visits all 13 levels in order and ends at Level 13 after 12 transitions. -/
theorem nextLevel_terminal_iff (k : Fin 13) : nextLevel k = none ↔ k = 12 := by
  revert k; decide

/-- Level 4 ("4 internal, 4 horizontal and 4 vertical vectors") uses 12 vectors, as many as
the dodecahedron has faces; Level 5 pairs 5 aspects with 12 faces (60 pairs); Level 9 combines
3 tori, 3 axes and 3 fluctuation states (27 combinations). -/
theorem level_counts : 4 + 4 + 4 = 12 ∧ 5 * 12 = 60 ∧ 3 * 3 * 3 = 27 := by norm_num

end TGSNumerics
