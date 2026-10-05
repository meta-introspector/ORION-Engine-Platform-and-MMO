module

public import Mathlib

/-!
# Checkable claims from Dr. Logvinovich's IT³ preprints and from their published critiques

This file accompanies `TEAM_ROSTER_AND_X_REVIEW.md` (§2). It checks only claims that are pure
arithmetic or pure mathematics. Nothing here says anything about whether the IT³ framework
describes physical reality.

* **IT³ "Level A" arithmetic (Zenodo 23018681), all confirmed:**
  the seven quadratic subfields of `ℚ(√2, √3, √5)` have discriminants multiplying to
  `2^16 · 3^4 · 5^4` (`it3_seven_discriminants`); its square root is `57600 = 240^2 = 0xE100`
  (`it3_covolume`); `172 = 43 << 2` (`it3_closure_shift`); `86 + 87 = 173 = 0xAD`, the
  hexadecimal sum has no carry between digits and its low hex digit is `13`
  (`it3_central_edge_hex`); `43` is the first Heegner prime that is not one of Ogg's
  supersingular primes (`it3_first_ogg_breaking_heegner`).
  One caveat: in *binary* the sum `86 + 87` does carry (`it3_central_edge_binary_carries`), so
  "carry-free" is only true digit-by-digit in hexadecimal.
* **Nader's critique (Zenodo 22071951), point (2), confirmed:** a quarter turn about the
  `z`-axis flips the sign of the `m = 6` azimuthal factor (`c4_flips_m6`), so its average over
  the four quarter turns is zero (`c4_average_m6_vanishes`), while the `m = 12` factor is
  unchanged (`c4_fixes_m12`). This is exactly the mechanism the critique gives for why the
  `Y₆,₆` term carries no `O_h`-invariant part.
* **Watts's audit (Zenodo 22160908), the "operator closure" point, confirmed:** if a state is
  defined with a floor, then every object of every catalogue lands on an integer state
  (`floor_states_always_integral`). So "100 % integer agreement" is the same for real data and
  for any made-up data, and is not evidence of quantization.
-/

@[expose] public section

namespace TeamReview.IT3

/-! ## IT³ arithmetic -/

/-- The discriminant of the real quadratic field `ℚ(√d)` for squarefree `d > 1`:
`d` if `d ≡ 1 (mod 4)`, and `4d` otherwise. -/
def quadDisc (d : ℕ) : ℕ := if d % 4 = 1 then d else 4 * d

/-- The squarefree radicands of the seven quadratic subfields of `ℚ(√2, √3, √5)`. -/
def subfieldRadicands : List ℕ := [2, 3, 5, 6, 10, 15, 30]

/-- **IT³ claim, confirmed.** The seven quadratic discriminants multiply to `2^16 · 3^4 · 5^4`. -/
theorem it3_seven_discriminants :
    (subfieldRadicands.map quadDisc).prod = 2 ^ 16 * 3 ^ 4 * 5 ^ 4 := by
  decide

/-- **IT³ claim, confirmed.** `√(2^16 · 3^4 · 5^4) = 57600 = 240^2 = 0xE100`. -/
theorem it3_covolume :
    57600 * 57600 = 2 ^ 16 * 3 ^ 4 * 5 ^ 4 ∧ 57600 = 240 ^ 2 ∧ (57600 : ℕ) = 0xE100 := by
  decide

/-- **IT³ claim, confirmed.** `172 = 43 << 2`. -/
theorem it3_closure_shift : (43 : ℕ) <<< 2 = 172 := by decide

/-- **IT³ claim, confirmed (hexadecimal reading).** `86 = 0x56`, `87 = 0x57`, their sum is
`173 = 0xAD`, neither hex digit position produces a carry, and the low hex digit is `13`. -/
theorem it3_central_edge_hex :
    (86 : ℕ) = 0x56 ∧ (87 : ℕ) = 0x57 ∧ 86 + 87 = 0xAD ∧
      86 % 16 + 87 % 16 < 16 ∧ 86 / 16 + 87 / 16 < 16 ∧ (86 + 87) % 16 = 13 := by
  decide

/-- **Caveat.** In binary, `86` and `87` share set bits, so adding them does carry. -/
theorem it3_central_edge_binary_carries : (86 : ℕ) &&& 87 ≠ 0 := by decide

/-- The nine Heegner numbers. -/
def heegner : List ℕ := [1, 2, 3, 7, 11, 19, 43, 67, 163]

/-- Ogg's fifteen supersingular primes (the primes dividing the order of the Monster group). -/
def oggPrimes : List ℕ := [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 59, 71]

/-- **IT³ claim, confirmed.** `43` is a prime Heegner number that is not an Ogg prime, and every
smaller prime Heegner number is an Ogg prime. -/
theorem it3_first_ogg_breaking_heegner :
    43 ∈ heegner ∧ Nat.Prime 43 ∧ 43 ∉ oggPrimes ∧
      ∀ p ∈ heegner, p.Prime → p < 43 → p ∈ oggPrimes := by
  refine ⟨by decide, by norm_num, by decide, ?_⟩
  intro p hp hprime hlt
  simp only [heegner, List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
    first | omega | decide | (exfalso; norm_num at hprime)

/-! ## Nader's critique: the quarter turn and the `m = 6` and `m = 12` factors -/

open Complex in
/-- The azimuthal factor `e^{i m φ}` of the spherical harmonic `Y_{m,m}`. -/
noncomputable def azimuthal (m : ℤ) (φ : ℝ) : ℂ := exp (m * φ * I)

open Complex in
lemma azimuthal_quarter_turn (m : ℤ) (φ : ℝ) :
    azimuthal m (φ + Real.pi / 2) = azimuthal m φ * exp (m * (Real.pi / 2 : ℝ) * I) := by
  unfold azimuthal
  rw [← Complex.exp_add]
  congr 1
  push_cast
  ring

/-- **Nader (2), confirmed.** A quarter turn about the `z`-axis flips the sign of the `m = 6`
factor. -/
theorem c4_flips_m6 (φ : ℝ) : azimuthal 6 (φ + Real.pi / 2) = - azimuthal 6 φ := by
  rw [azimuthal_quarter_turn]
  have h : Complex.exp ((6 : ℤ) * (Real.pi / 2 : ℝ) * Complex.I) = -1 := by
    have : ((6 : ℤ) : ℂ) * ((Real.pi / 2 : ℝ) : ℂ) * Complex.I =
        Real.pi * Complex.I + 2 * Real.pi * Complex.I := by
      push_cast; ring
    rw [this, Complex.exp_add, Complex.exp_pi_mul_I, Complex.exp_two_pi_mul_I]
    ring
  rw [h]; ring

/-- **Nader (2), confirmed.** A quarter turn leaves the `m = 12` factor unchanged. -/
theorem c4_fixes_m12 (φ : ℝ) : azimuthal 12 (φ + Real.pi / 2) = azimuthal 12 φ := by
  rw [azimuthal_quarter_turn]
  have h : Complex.exp ((12 : ℤ) * (Real.pi / 2 : ℝ) * Complex.I) = 1 := by
    have : ((12 : ℤ) : ℂ) * ((Real.pi / 2 : ℝ) : ℂ) * Complex.I =
        (3 : ℕ) * (2 * Real.pi * Complex.I) := by
      push_cast; ring
    rw [this, Complex.exp_nat_mul, Complex.exp_two_pi_mul_I, one_pow]
  rw [h, mul_one]

/-- **Nader (2), confirmed.** Averaging the `m = 6` factor over the four quarter turns gives
zero, so that term has no part that is invariant under the quarter turn (and hence none that is
invariant under the octahedral group, which contains it). -/
theorem c4_average_m6_vanishes (φ : ℝ) :
    azimuthal 6 φ + azimuthal 6 (φ + Real.pi / 2) + azimuthal 6 (φ + Real.pi / 2 + Real.pi / 2)
      + azimuthal 6 (φ + Real.pi / 2 + Real.pi / 2 + Real.pi / 2) = 0 := by
  rw [c4_flips_m6 (φ + Real.pi / 2 + Real.pi / 2), c4_flips_m6 (φ + Real.pi / 2), c4_flips_m6 φ]
  ring

/-! ## Watts's audit: floor-defined states are always integers -/

/-- A value "matches the lattice" when it is an integer. -/
def OnLattice (v : ℝ) : Prop := ∃ n : ℤ, v = n

/-- **Watts, confirmed.** Whatever the catalogue and whatever the descent map `g`, a state
defined as `⌊g x⌋` is on the lattice for every object. The "match rate" is therefore 100 % for
any input at all, real or random, and so it cannot be evidence for physical quantization. -/
theorem floor_states_always_integral {α : Type*} (catalogue : List α) (g : α → ℝ) :
    ∀ x ∈ catalogue, OnLattice (⌊g x⌋ : ℝ) :=
  fun x _ => ⟨⌊g x⌋, rfl⟩

end TeamReview.IT3

end
