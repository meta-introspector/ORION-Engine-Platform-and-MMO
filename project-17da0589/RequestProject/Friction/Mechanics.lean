module

public import Mathlib

/-!
# Friction as a necessary and as a problematic quantity

Standard textbook mechanics, stated and proved in Lean, that makes the corpus's
qualitative thesis ("a frictionless Avatar is unsustainable, an over-calcified
one suffocates") precise in the one setting where friction is actually a
physical quantity.

* Kinetic (Coulomb) friction: with coefficient `μ > 0` a sliding body stops after
  a finite distance `v₀² / (2 μ g)`; with `μ = 0` it never stops.
* Traction: the horizontal acceleration a body can get from the ground is at most
  `μ g`, so with `μ = 0` it cannot start, stop or steer.
* Resonance: a frictionless oscillator driven at its natural frequency has an
  unbounded response (a runaway, the analogue of "Octave inflation"); with
  damping `c > 0` the steady response has amplitude exactly `1 / c`.
* Dissipation: damping never increases the oscillator's energy.
* The "Goldilocks" band: the steady amplitude lies in a target band `[a, b]`
  exactly when the damping lies in `[1/b, 1/a]` — too little friction gives
  runaway, too much gives a response that dies out.
* Impedance matching: a zero-resistance load receives no power; the power
  delivered is largest at the matched load `R = Rs`.
-/

@[expose] public section

namespace Friction

open Real

/-! ## Kinetic (Coulomb) friction -/

/-- Speed of a body sliding under kinetic friction `μ g`, before it stops. -/
noncomputable def slideSpeed (v₀ μ g t : ℝ) : ℝ := v₀ - μ * g * t

/-- Distance travelled while sliding under kinetic friction, before it stops. -/
noncomputable def slideDist (v₀ μ g t : ℝ) : ℝ := v₀ * t - μ * g * t ^ 2 / 2

/-- With positive kinetic friction the body stops at time `v₀/(μ g)` after travelling
`v₀² / (2 μ g)`. -/
theorem kinetic_friction_stops (v₀ μ g : ℝ) (hμ : 0 < μ) (hg : 0 < g) :
    slideSpeed v₀ μ g (v₀ / (μ * g)) = 0 ∧
      slideDist v₀ μ g (v₀ / (μ * g)) = v₀ ^ 2 / (2 * μ * g) := by
  have h : μ * g ≠ 0 := by positivity
  unfold slideSpeed slideDist
  constructor
  · field_simp; ring
  · field_simp; ring

/-- With zero friction a moving body never stops, and it travels arbitrarily far. -/
theorem frictionless_never_stops (v₀ g : ℝ) (hv : 0 < v₀) :
    (∀ t, slideSpeed v₀ 0 g t = v₀) ∧ ∀ D : ℝ, ∃ t, D < slideDist v₀ 0 g t := by
  refine ⟨fun t => by simp [slideSpeed], fun D => ⟨(|D| + 1) / v₀, ?_⟩⟩
  simp only [slideDist, zero_mul, zero_div, sub_zero]
  rw [mul_div_cancel₀ _ hv.ne']
  linarith [le_abs_self D]

/-- **Traction bound.**  If the ground can supply at most `μ m g` of horizontal force,
the body's acceleration is at most `μ g`; with `μ = 0` it cannot accelerate at all. -/
theorem traction_bound (m μ g a : ℝ) (hm : 0 < m) (hF : |m * a| ≤ μ * m * g) :
    |a| ≤ μ * g ∧ (μ = 0 → a = 0) := by
  have h1 : |a| ≤ μ * g := by
    rw [abs_mul, abs_of_pos hm] at hF
    nlinarith
  refine ⟨h1, fun h0 => ?_⟩
  rw [h0, zero_mul] at h1
  exact abs_nonpos_iff.mp h1

/-! ## The driven oscillator `x'' + c x' + x = cos t` -/

/-- Resonant response of the frictionless oscillator. -/
noncomputable def undampedResponse (t : ℝ) : ℝ := t * sin t / 2

/-- `t sin t / 2` solves `x'' + x = cos t` (zero friction, resonant forcing). -/
theorem undampedResponse_solves (t : ℝ) :
    HasDerivAt undampedResponse ((sin t + t * cos t) / 2) t ∧
      HasDerivAt (fun s => (sin s + s * cos s) / 2) ((2 * cos t - t * sin t) / 2) t ∧
      (2 * cos t - t * sin t) / 2 + undampedResponse t = cos t := by
  refine ⟨?_, ?_, ?_⟩
  · have := ((hasDerivAt_id t).mul (hasDerivAt_sin t)).div_const 2
    convert this using 1
    simp
  · have := ((hasDerivAt_sin t).add ((hasDerivAt_id t).mul (hasDerivAt_cos t))).div_const 2
    convert this using 1
    simp; ring
  · unfold undampedResponse; ring

/-- **No friction ⇒ runaway.**  The resonant response of the frictionless oscillator
exceeds every bound. -/
theorem undampedResponse_unbounded (M : ℝ) : ∃ t, M < undampedResponse t := by
  obtain ⟨k, hk⟩ := exists_nat_gt (|M|)
  refine ⟨π / 2 + 2 * π * k, ?_⟩
  have hs : sin (π / 2 + 2 * π * k) = 1 := by
    rw [show π / 2 + 2 * π * k = π / 2 + (k : ℕ) * (2 * π) by ring, sin_add_nat_mul_two_pi,
      sin_pi_div_two]
  unfold undampedResponse
  rw [hs]
  have : (1 : ℝ) ≤ 2 * π := by linarith [pi_gt_three]
  have hk0 : (0 : ℝ) ≤ k := Nat.cast_nonneg k
  nlinarith [le_abs_self M, pi_pos, mul_nonneg (by linarith [pi_gt_three] : (0:ℝ) ≤ π - 1) hk0]

/-- Steady response of the damped oscillator with damping `c`. -/
noncomputable def dampedResponse (c t : ℝ) : ℝ := sin t / c

/-- `sin t / c` solves `x'' + c x' + x = cos t` for every nonzero damping `c`. -/
theorem dampedResponse_solves (c t : ℝ) (hc : c ≠ 0) :
    HasDerivAt (dampedResponse c) (cos t / c) t ∧
      HasDerivAt (fun s => cos s / c) (-sin t / c) t ∧
      -sin t / c + c * (cos t / c) + dampedResponse c t = cos t := by
  refine ⟨(hasDerivAt_sin t).div_const c, ?_, ?_⟩
  · simpa using (hasDerivAt_cos t).div_const c
  · unfold dampedResponse; field_simp; ring

/-- **Friction ⇒ bounded.**  With damping `c > 0` the response never exceeds `1 / c`,
and it reaches `1 / c`. -/
theorem dampedResponse_amplitude (c : ℝ) (hc : 0 < c) :
    (∀ t, |dampedResponse c t| ≤ 1 / c) ∧ dampedResponse c (π / 2) = 1 / c := by
  refine ⟨fun t => ?_, by simp [dampedResponse]⟩
  unfold dampedResponse
  rw [abs_div, abs_of_pos hc]
  exact div_le_div_of_nonneg_right (abs_sin_le_one t) hc.le

/-- **Dissipation.**  For any solution of the free oscillator `x' = v`, `v' = -c v - x`
with `c ≥ 0`, the energy `(v² + x²)/2` never increases; with `c = 0` it is constant. -/
theorem energy_antitone (c : ℝ) (hc : 0 ≤ c) (x v : ℝ → ℝ)
    (hx : ∀ t, HasDerivAt x (v t) t) (hv : ∀ t, HasDerivAt v (-c * v t - x t) t) :
    Antitone (fun t => (v t ^ 2 + x t ^ 2) / 2) := by
  have hE : ∀ t, HasDerivAt (fun t => (v t ^ 2 + x t ^ 2) / 2) (-c * v t ^ 2) t := by
    intro t
    have := (((hv t).pow 2).add ((hx t).pow 2)).div_const 2
    convert this using 1
    simp; ring
  refine antitone_of_hasDerivAt_nonpos hE fun t => ?_
  have := sq_nonneg (v t)
  show -c * v t ^ 2 ≤ 0
  nlinarith

/-- Without friction the energy is conserved. -/
theorem energy_conserved (x v : ℝ → ℝ)
    (hx : ∀ t, HasDerivAt x (v t) t) (hv : ∀ t, HasDerivAt v (-x t) t) (s t : ℝ) :
    (v s ^ 2 + x s ^ 2) / 2 = (v t ^ 2 + x t ^ 2) / 2 := by
  have hE : ∀ t, HasDerivAt (fun t => (v t ^ 2 + x t ^ 2) / 2) 0 t := by
    intro t
    have := (((hv t).pow 2).add ((hx t).pow 2)).div_const 2
    convert this using 1
    simp; ring
  exact is_const_of_deriv_eq_zero
    (fun t => (hE t).differentiableAt) (fun t => (hE t).deriv) s t

/-- **The Goldilocks band.**  For a target band with `0 < a` and `0 < b`, the steady amplitude `1/c`
of the damped oscillator lies in `[a, b]` exactly when the damping lies in `[1/b, 1/a]`:
friction below `1/b` lets the response exceed `b` (and at `c → 0` it runs away), friction
above `1/a` suppresses the response below `a`. -/
theorem goldilocks_band (a b c : ℝ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    (a ≤ 1 / c ∧ 1 / c ≤ b) ↔ (1 / b ≤ c ∧ c ≤ 1 / a) := by
  constructor
  · rintro ⟨h1, h2⟩
    constructor
    · rw [div_le_iff₀ hb]; rw [div_le_iff₀ hc] at h2; linarith
    · rw [le_div_iff₀ ha]; rw [le_div_iff₀ hc] at h1; linarith
  · rintro ⟨h1, h2⟩
    constructor
    · rw [le_div_iff₀ hc]; rw [le_div_iff₀ ha] at h2; linarith
    · rw [div_le_iff₀ hc]; rw [div_le_iff₀ hb] at h1; linarith

/-! ## Impedance matching (maximum power transfer) -/

/-- Power delivered to a load of resistance `R` by a source of voltage `V` and internal
resistance `Rs`. -/
noncomputable def loadPower (V Rs R : ℝ) : ℝ := V ^ 2 * R / (Rs + R) ^ 2

/-- **Maximum power transfer.**  A load with zero resistance receives no power, and
among all loads `R ≥ 0` the power is largest at the matched load `R = Rs`, where it
equals `V² / (4 Rs)`.  "Open channel" in the sense of *no reflection* means matched
resistance, not zero resistance. -/
theorem max_power_transfer (V Rs R : ℝ) (hs : 0 < Rs) (hR : 0 ≤ R) :
    loadPower V Rs 0 = 0 ∧ loadPower V Rs Rs = V ^ 2 / (4 * Rs) ∧
      loadPower V Rs R ≤ loadPower V Rs Rs := by
  have hRs : Rs + Rs ≠ 0 := by positivity
  have hpos : 0 < (Rs + R) ^ 2 := by positivity
  refine ⟨by simp [loadPower], ?_, ?_⟩
  · unfold loadPower; field_simp; ring
  · unfold loadPower
    rw [div_le_div_iff₀ hpos (by positivity)]
    have h1 : 0 ≤ V ^ 2 * Rs * (Rs - R) ^ 2 :=
      mul_nonneg (mul_nonneg (sq_nonneg V) hs.le) (sq_nonneg _)
    nlinarith [h1]

end Friction
