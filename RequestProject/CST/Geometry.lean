module

public import Mathlib

/-!
# Cosmic Sandbox Theory, Volumes I–IV: geometry and physics-style formulas

Checks of the definite geometric and formula claims in the Volume I–IV pages (Mechanics of
Dimensional Transit, Cosmic Fluid Dynamics, Fractal Toroidal Bubble Theory, The Escher Cosmos,
The Plasma Substrate, The 5:2 Geometry Upgrade, The Biometric and Quantum Framework for Modeling
the Soul). See `CST_COMPILED_EDITION.md` for the plain-language write-up.

1. **Conscious Transit Equation** `T_v = J·Γ / (D + τ_net/Λ)`. For fixed positive inputs `T_v`
   strictly decreases as `D` grows (`transit_strictAnti`), and the formula is continuous at
   `D = Λ` (`transit_continuous_at_threshold`): the formula itself has no threshold there, so the
   "container pops when `D < Λ`" rule has to be stated as a separate rule.
2. **Which dodecahedron tiles space.** The rhombic dodecahedron's 120° dihedral angle fits exactly
   three times around an edge (`rhombic_fits_three`). The regular (pentagonal) dodecahedron, whose
   dihedral angle `θ` has `cos θ = −1/√5`, fits around an edge no whole number of times
   (`regular_dodecahedron_no_edge_tiling`), so regular dodecahedra cannot tile space.
3. **The (0,0,0) centre.** Inside either dodecahedron, the only point at equal distance from all
   twelve face planes is the centre (`rhombic_equidistant_iff`, `regular_equidistant_iff`).
4. **The displaced observer.** Moving inside a fixed twelve-faced boundary, the rates at which the
   observer approaches the twelve faces always sum to zero (`rhombic_net_recession_zero`), so the
   faces can never all recede at once (`rhombic_not_all_recede`): a displaced observer cannot mimic
   uniform cosmic expansion. The apparent size of the far face shrinks ever more slowly
   (`far_face_shrink_decelerates`), not at accelerating speed.
5. **Inverse-square dilution.** If `F(r)·4πr² = C` then doubling the distance quarters the force
   (`inverse_square_double`).
6. **1:5:1 Conical Diamond.** A pentagonal bipyramid has 7 vertices, 15 edges and 10 faces and
   satisfies Euler's formula (`bipyramid_euler`).
7. **Probability current.** As printed, `ψ∇ψ − ψ∇ψ` is identically zero (`printed_current_zero`).
   With the complex conjugate restored, `ψ̄∇ψ − ψ∇ψ̄ = 2i·Im(ψ̄∇ψ)`, so the current is real
   (`conj_current_formula`).
-/

@[expose] public section

namespace CSTGeometry

open Real

/-! ## 1. The Conscious Transit Equation -/

/-- `T_v = J·Γ / (D + τ_net/Λ)`. -/
noncomputable def transit (J Γ D τ Λ : ℝ) : ℝ := J * Γ / (D + τ / Λ)

/-- With `J, Γ, Λ > 0` and `τ ≥ 0`, the transit vector strictly decreases as the distance from
the centre grows (on `D > 0`). -/
theorem transit_strictAnti {J Γ τ Λ : ℝ} (hJ : 0 < J) (hΓ : 0 < Γ) (hτ : 0 ≤ τ) (hΛ : 0 < Λ) :
    StrictAntiOn (fun D => transit J Γ D τ Λ) (Set.Ioi 0) := by
  intro a ha b hb hab
  simp only [Set.mem_Ioi] at ha hb
  have hq : 0 ≤ τ / Λ := div_nonneg hτ hΛ.le
  unfold transit
  exact div_lt_div_of_pos_left (mul_pos hJ hΓ) (by linarith) (by linarith)

/-- The formula is continuous at `D = Λ`: nothing special happens at the "surface tension
threshold". -/
theorem transit_continuous_at_threshold {J Γ τ Λ : ℝ} (hτ : 0 ≤ τ) (hΛ : 0 < Λ) :
    ContinuousAt (fun D => transit J Γ D τ Λ) Λ := by
  unfold transit
  have : Λ + τ / Λ ≠ 0 := by have := div_nonneg hτ hΛ.le; linarith
  exact continuousAt_const.div (continuousAt_id.add continuousAt_const) this

/-! ## 2. Which dodecahedron tiles space? -/

/-- Three rhombic-dodecahedron dihedral angles (120°) fill the full turn around an edge. -/
theorem rhombic_fits_three : 3 * (2 * π / 3) = 2 * π := by ring

/-- The regular dodecahedron's dihedral angle lies strictly between 90° and 120°. -/
theorem regular_dihedral_bounds {θ : ℝ} (h0 : 0 ≤ θ) (hπ : θ ≤ π) (hc : cos θ = -1 / √5) :
    π / 2 < θ ∧ θ < 2 * π / 3 := by
  have h5 : (2 : ℝ) < √5 := by
    rw [show (2 : ℝ) = √4 by rw [show (4 : ℝ) = 2 ^ 2 by norm_num, sqrt_sq (by norm_num)]]
    exact sqrt_lt_sqrt (by norm_num) (by norm_num)
  have hs : 0 < √5 := by linarith
  have hneg : -1 / √5 < 0 := by apply div_neg_of_neg_of_pos <;> linarith
  have hgt : -(1 / 2 : ℝ) < -1 / √5 := by
    rw [neg_div, neg_lt_neg_iff, div_lt_div_iff₀ hs (by norm_num)]; linarith
  constructor
  · by_contra h
    push_neg at h
    have : cos (π / 2) ≤ cos θ :=
      Real.cos_le_cos_of_nonneg_of_le_pi h0 (by linarith [pi_pos]) h
    rw [cos_pi_div_two] at this; linarith
  · by_contra h
    push_neg at h
    have : cos θ ≤ cos (2 * π / 3) :=
      Real.cos_le_cos_of_nonneg_of_le_pi (by positivity) hπ h
    have h23 : cos (2 * π / 3) = -(1 / 2) := by
      rw [show 2 * π / 3 = π - π / 3 by ring, cos_pi_sub, cos_pi_div_three]
    linarith

/-- **Regular dodecahedra cannot tile space**: no whole number of copies of the dihedral angle
closes up around an edge. -/
theorem regular_dodecahedron_no_edge_tiling {θ : ℝ} (h0 : 0 ≤ θ) (hπ : θ ≤ π)
    (hc : cos θ = -1 / √5) (k : ℕ) : (k : ℝ) * θ ≠ 2 * π := by
  obtain ⟨h1, h2⟩ := regular_dihedral_bounds h0 hπ hc
  intro hk
  have hp := pi_pos
  rcases Nat.lt_or_ge k 4 with hk4 | hk4
  · have : (k : ℝ) ≤ 3 := by exact_mod_cast Nat.lt_succ_iff.mp hk4
    nlinarith
  · have : (4 : ℝ) ≤ k := by exact_mod_cast hk4
    nlinarith

/-! ## 3. The centre is the only equidistant point -/

/-- Signed gap from a point `x` to the face plane `n · x = 1`. Within each dodecahedron all twelve
normals have the same length, so equal gaps mean equal distances. -/
def gap (n x : ℝ × ℝ × ℝ) : ℝ := 1 - (n.1 * x.1 + n.2.1 * x.2.1 + n.2.2 * x.2.2)

/-- The twelve face normals of the rhombic dodecahedron. -/
def rhombicNormals : List (ℝ × ℝ × ℝ) :=
  [(1, 1, 0), (1, -1, 0), (-1, 1, 0), (-1, -1, 0), (1, 0, 1), (1, 0, -1), (-1, 0, 1),
    (-1, 0, -1), (0, 1, 1), (0, 1, -1), (0, -1, 1), (0, -1, -1)]

/-- A point is equidistant from all twelve faces of the rhombic dodecahedron exactly when it is
the centre `(0,0,0)`. -/
theorem rhombic_equidistant_iff (x : ℝ × ℝ × ℝ) :
    (∃ c, ∀ n ∈ rhombicNormals, gap n x = c) ↔ x = 0 := by
  constructor
  · rintro ⟨c, hc⟩
    obtain ⟨a, b, d⟩ := x
    simp only [rhombicNormals, List.mem_cons, List.not_mem_nil, or_false, forall_eq_or_imp,
      forall_eq, gap] at hc
    obtain ⟨h1, h2, h3, h4, h5, -, -, h8, h9, -, -, h12⟩ := hc
    have ha : a = 0 := by linarith
    have hb : b = 0 := by linarith
    have hd : d = 0 := by linarith
    simp [ha, hb, hd]
  · rintro rfl
    exact ⟨1, fun n _ => by simp [gap]⟩

/-- The twelve face normals of the regular dodecahedron, `(0, ±1, ±φ)` and cyclic shifts. -/
noncomputable def regularNormals : List (ℝ × ℝ × ℝ) :=
  [(0, 1, goldenRatio), (0, 1, -goldenRatio), (0, -1, goldenRatio), (0, -1, -goldenRatio),
    (1, goldenRatio, 0), (1, -goldenRatio, 0), (-1, goldenRatio, 0), (-1, -goldenRatio, 0),
    (goldenRatio, 0, 1), (-goldenRatio, 0, 1), (goldenRatio, 0, -1), (-goldenRatio, 0, -1)]

/-- The same holds for the regular dodecahedron (all normals have length `√(1 + φ²)`). -/
theorem regular_equidistant_iff (x : ℝ × ℝ × ℝ) :
    (∃ c, ∀ n ∈ regularNormals, gap n x = c) ↔ x = 0 := by
  constructor
  · rintro ⟨c, hc⟩
    obtain ⟨a, b, d⟩ := x
    simp only [regularNormals, List.mem_cons, List.not_mem_nil, or_false, forall_eq_or_imp,
      forall_eq, gap] at hc
    obtain ⟨h1, h2, h3, h4, h5, h6, h7, h8, -, -, -, -⟩ := hc
    have hb : b = 0 := by linarith
    have hd : goldenRatio * d = 0 := by linarith
    have hd' : d = 0 := by
      rcases mul_eq_zero.1 hd with h | h
      · exact absurd h goldenRatio_pos.ne'
      · exact h
    have ha : a = 0 := by subst hb hd'; linarith
    simp [ha, hb, hd']
  · rintro rfl
    exact ⟨1, fun n _ => by simp [gap]⟩

/-! ## 4. The displaced observer -/

/-- Rate at which an observer moving with velocity `v` approaches the face with normal `n`. -/
def approachRate (n v : ℝ × ℝ × ℝ) : ℝ := n.1 * v.1 + n.2.1 * v.2.1 + n.2.2 * v.2.2

/-- **Zero net recession.** Whatever the observer's velocity, the approach rates to the twelve
faces sum to zero: whatever one side gains, the opposite side loses. -/
theorem rhombic_net_recession_zero (v : ℝ × ℝ × ℝ) :
    (rhombicNormals.map (fun n => approachRate n v)).sum = 0 := by
  simp [rhombicNormals, approachRate]; ring

/-- So the twelve faces can never all be receding at once: a moving observer inside a static
boundary cannot reproduce uniform expansion. -/
theorem rhombic_not_all_recede (v : ℝ × ℝ × ℝ) :
    ¬ ∀ n ∈ rhombicNormals, approachRate n v < 0 := by
  intro h
  have hs := rhombic_net_recession_zero v
  simp only [rhombicNormals, List.mem_cons, List.not_mem_nil, or_false, forall_eq_or_imp,
    forall_eq] at h
  simp only [rhombicNormals, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil] at hs
  linarith [h.1, h.2.1, h.2.2.1, h.2.2.2.1, h.2.2.2.2.1, h.2.2.2.2.2.1, h.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.2.2.2]

/-- Apparent size of a face at distance `d + s` falls like `1/(d+s)`. Over equal steps, the loss
of apparent size gets smaller the further away the face already is: the far side shrinks ever
more slowly, not at accelerating speed. -/
theorem far_face_shrink_decelerates {d s t h : ℝ} (hd : 0 < d) (hs : 0 ≤ s) (hst : s < t)
    (hh : 0 < h) :
    1 / (d + t) - 1 / (d + t + h) < 1 / (d + s) - 1 / (d + s + h) := by
  have ht : 0 < d + t := by linarith
  have hs' : 0 < d + s := by linarith
  have e1 : 1 / (d + t) - 1 / (d + t + h) = h / ((d + t) * (d + t + h)) := by
    field_simp; ring
  have e2 : 1 / (d + s) - 1 / (d + s + h) = h / ((d + s) * (d + s + h)) := by
    field_simp; ring
  rw [e1, e2]
  apply div_lt_div_of_pos_left hh (by positivity)
  nlinarith

/-! ## 5. Inverse-square dilution -/

/-- If `F(r)·4πr² = C` at every radius, doubling the distance quarters the force. -/
theorem inverse_square_double {F : ℝ → ℝ} {C r : ℝ} (hr : 0 < r)
    (hF : ∀ ρ, 0 < ρ → F ρ * (4 * π * ρ ^ 2) = C) : F (2 * r) = F r / 4 := by
  have h1 := hF r hr
  have h2 := hF (2 * r) (by linarith)
  have hp : 0 < 4 * π * r ^ 2 := by positivity
  have key : (F (2 * r) * 4 - F r) * (4 * π * r ^ 2) = 0 := by
    have : F (2 * r) * (4 * π * (2 * r) ^ 2) = F r * (4 * π * r ^ 2) := by rw [h1, h2]
    linear_combination this
  rcases mul_eq_zero.1 key with h | h
  · linarith
  · exact absurd h hp.ne'

/-! ## 6. The 1:5:1 Conical Diamond -/

/-- A pentagonal bipyramid (1 apex, 5 equatorial vertices, 1 base) has 7 vertices, 15 edges and
10 triangular faces, and satisfies Euler's formula. Both 1:5:1 and 3:1:3 sum to 7. -/
theorem bipyramid_euler :
    1 + 5 + 1 = 7 ∧ 5 + 5 + 5 = 15 ∧ 5 + 5 = 10 ∧ (7 : ℤ) - 15 + 10 = 2 ∧ 3 + 1 + 3 = 7 := by
  norm_num

/-! ## 7. The probability current -/

/-- As printed (`ψ∇ψ − ψ∇ψ`, without complex conjugates) the "current" is identically zero. -/
theorem printed_current_zero (ψ dψ : ℂ) : ψ * dψ - ψ * dψ = 0 := sub_self _

/-- With the conjugate restored, `ψ̄·ψ' − ψ·ψ̄' = 2i·Im(ψ̄·ψ')`, so
`j = (ħ/2mi)(ψ̄∇ψ − ψ∇ψ̄) = (ħ/m)·Im(ψ̄∇ψ)` is real. -/
theorem conj_current_formula (ψ dψ : ℂ) :
    (starRingEnd ℂ) ψ * dψ - ψ * (starRingEnd ℂ) dψ =
      2 * Complex.I * (((starRingEnd ℂ) ψ * dψ).im : ℂ) := by
  apply Complex.ext <;> simp; ring

end CSTGeometry
