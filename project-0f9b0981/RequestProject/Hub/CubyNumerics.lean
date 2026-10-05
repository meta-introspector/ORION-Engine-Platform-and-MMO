module

public import Mathlib

/-!
# The numbers in the *Orion Chronicles* build document (CUBY 4.1 update)

The build document (Proposal v0.2 plus the CUBY 4 → 4.1 update) lists identities and
approximations as "verified". This file checks each one that has a definite arithmetic
meaning.

* Exact identities: all correct (`39³ = 59319`, `59319 = 13 × 4563`, `39² = 1521`,
  `93³ = 804357 = 93 × 93²`, `9³ = 729`, `9999 = 9 × 1111`, `13 × 28 = 364`, and the
  Erdős–Straus decomposition `4/39 = 1/11 + 1/88 + 1/3432`).
* Digital roots: `144`, `59319`, `804357`, `9999` and `729` all have digital root `9`, and
  `93` has digital root `3`, as stated.
* φ approximations: `144/φ ≈ 89.0`, `13φ ≈ 21.03`, `93/φ ≈ 57.48`, `364/φ ≈ 224.96` all hold
  to the stated precision.
* Month table: every month's `η⁺/η⁻` split sums to `100`, the table mirrors (month `i` and
  month `14 − i` swap their two numbers), and the year's `η⁺` total equals its `η⁻` total
  (`650` each), so the claimed "whole year = equilibrium" is correct.
  One small mismatch: month 3's quest is "hold a 2:1 ratio", but month 3's split `66/34` is
  not exactly `2:1` (`66 ≠ 2 × 34`).
-/

@[expose] public section

namespace CubyNumerics

/-! ## Exact identities -/

theorem cube_39 : 39 ^ 3 = 59319 := by norm_num
theorem grid_per_month : 59319 = 13 * 4563 := by norm_num
theorem months_fill_grid : 13 * 4563 = 39 ^ 3 := by norm_num
theorem face_39 : 39 ^ 2 = 1521 := by norm_num
theorem cube_93 : 93 ^ 3 = 804357 := by norm_num
theorem cube_93_div : 804357 / 93 = 8649 ∧ 8649 = 93 ^ 2 := by norm_num
theorem cube_9 : 9 ^ 3 = 729 := by norm_num
theorem n9999 : 9999 / 9 = 1111 ∧ 9999 % 9 = 0 := by norm_num
theorem year_days : 13 * 28 = 364 ∧ 13 * 28 + 1 = 365 := by norm_num
theorem three_thirteen : 39 = 3 * 13 := by norm_num

/-- The Erdős–Straus decomposition quoted in the document is correct. -/
theorem erdos_straus_4_39 : (4 : ℚ) / 39 = 1 / 11 + 1 / 88 + 1 / 3432 := by norm_num

/-! ## Digital roots -/

/-- Digital root of a positive integer (repeated digit sum), via the standard formula. -/
def digitalRoot (n : ℕ) : ℕ := if n = 0 then 0 else 1 + (n - 1) % 9

/-- The standard formula agrees with repeated digit sums on the document's numbers. -/
theorem digitalRoot_eq_digit_sums :
    (Nat.digits 10 144).sum = 9 ∧ (Nat.digits 10 59319).sum = 27 ∧
      (Nat.digits 10 804357).sum = 27 ∧ (Nat.digits 10 9999).sum = 36 ∧
      (Nat.digits 10 729).sum = 18 ∧ (Nat.digits 10 93).sum = 12 := by
  norm_num

theorem digitalRoot_nine :
    digitalRoot 144 = 9 ∧ digitalRoot 59319 = 9 ∧ digitalRoot 804357 = 9 ∧
      digitalRoot 9999 = 9 ∧ digitalRoot 729 = 9 := by decide

theorem digitalRoot_93 : digitalRoot 93 = 3 := by decide

/-! ## Golden-ratio approximations -/

open Real

lemma sqrt5_bounds : (2.23606 : ℝ) < √5 ∧ √5 < 2.23607 := by
  constructor
  · rw [Real.lt_sqrt (by norm_num)]; norm_num
  · rw [Real.sqrt_lt' (by norm_num)]; norm_num

lemma inv_goldenRatio_eq : goldenRatio⁻¹ = (√5 - 1) / 2 := by
  have h5 : (√5) ^ 2 = 5 := Real.sq_sqrt (by norm_num)
  have hpos : (0 : ℝ) < 1 + √5 := by positivity
  rw [goldenRatio, inv_div, div_eq_div_iff hpos.ne' (by norm_num)]
  nlinarith

/-- `144 / φ ≈ 89.0` (it lies between `88.99` and `89`). -/
theorem rind_over_phi : (88.99 : ℝ) < 144 / goldenRatio ∧ 144 / goldenRatio < 89 := by
  rw [div_eq_mul_inv, inv_goldenRatio_eq]
  obtain ⟨h1, h2⟩ := sqrt5_bounds
  constructor <;> linarith

/-- `13 φ ≈ 21.03`, close to the Fibonacci number `F₈ = 21`. -/
theorem thirteen_phi : (21.025 : ℝ) < 13 * goldenRatio ∧ 13 * goldenRatio < 21.035 := by
  rw [goldenRatio]
  obtain ⟨h1, h2⟩ := sqrt5_bounds
  constructor <;> linarith

/-- `93 / φ ≈ 57.48`. -/
theorem ninetythree_over_phi :
    (57.475 : ℝ) < 93 / goldenRatio ∧ 93 / goldenRatio < 57.485 := by
  rw [div_eq_mul_inv, inv_goldenRatio_eq]
  obtain ⟨h1, h2⟩ := sqrt5_bounds
  constructor <;> linarith

/-- `364 / φ ≈ 224.96`. -/
theorem year_over_phi :
    (224.955 : ℝ) < 364 / goldenRatio ∧ 364 / goldenRatio < 224.965 := by
  rw [div_eq_mul_inv, inv_goldenRatio_eq]
  obtain ⟨h1, h2⟩ := sqrt5_bounds
  constructor <;> linarith

/-! ## The 13-month `η⁺ / η⁻` table -/

/-- `η⁺` (gold) share of month `i` (months `1` to `13`), as in the document's table. -/
def etaPlus : ℕ → ℕ
  | 1 => 78 | 2 => 72 | 3 => 66 | 4 => 62 | 5 => 58 | 6 => 54 | 7 => 50
  | 8 => 46 | 9 => 42 | 10 => 38 | 11 => 34 | 12 => 28 | 13 => 22 | _ => 0

/-- `η⁻` (violet) share of month `i`, as in the document's table. -/
def etaMinus : ℕ → ℕ
  | 1 => 22 | 2 => 28 | 3 => 34 | 4 => 38 | 5 => 42 | 6 => 46 | 7 => 50
  | 8 => 54 | 9 => 58 | 10 => 62 | 11 => 66 | 12 => 72 | 13 => 78 | _ => 0

/-- Each month's split is a percentage split: `η⁺ + η⁻ = 100`. -/
theorem month_sum_100 : ∀ i ∈ Finset.Icc 1 13, etaPlus i + etaMinus i = 100 := by decide

/-- The table mirrors: month `i` and month `14 − i` swap their two numbers. -/
theorem month_mirror : ∀ i ∈ Finset.Icc 1 13, etaPlus i = etaMinus (14 - i) := by decide

/-- **"The whole year = equilibrium."** Over the 13 months the `η⁺` total equals the `η⁻`
total, `650` each. -/
theorem year_equilibrium :
    ∑ i ∈ Finset.Icc 1 13, etaPlus i = 650 ∧ ∑ i ∈ Finset.Icc 1 13, etaMinus i = 650 := by
  decide

/-- Month 7 is the exact 50/50 node. -/
theorem month_seven_balanced : etaPlus 7 = etaMinus 7 := by decide

/-- `η⁺` never increases from one month to the next. -/
theorem etaPlus_antitone : ∀ i ∈ Finset.Icc 1 12, etaPlus (i + 1) ≤ etaPlus i := by decide

/-- Month 3's split `66/34` is **not** exactly the `2:1` ratio its quest names. -/
theorem month_three_not_two_to_one : etaPlus 3 ≠ 2 * etaMinus 3 := by decide

end CubyNumerics
