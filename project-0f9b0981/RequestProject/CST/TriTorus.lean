module

public import Mathlib
public import RequestProject.Hub.CubyNumerics

/-!
# The Nested Tri-Torus, the RPTF Architecture and the 13 Levels

Checks of the numerical claims in three *A Journey Into Universal Geometry* pages. See
`CST_COMPILED_EDITION.md` §3.11 for the plain-language write-up.

1. **Nested Tri-Torus digit sums.** `111 → 3`, `313 → 7`, `144 → 9` and `120 → 3` are correct
   (`trinity_digit_roots`). But the page's step function "3 (Time) + 3 (Space) = 6, then 6 + 3 = 9"
   uses 3 for Space, whereas its own reduction of 313 is 7; with the stated reductions
   Time + Space reduces to 1, not 6 (`space_step_mismatch`).
2. **The 44.8% parameterization.** `1 − V + (2/7)V = 0.68` has the unique solution `V = 0.448`,
   and then the equatorial part is `0.32` and the outer void `0.552` (`rptf_fit`). The same
   construction fits **any** dark-energy share between 2/7 (about 28.6%) and 100%
   (`rptf_fit_iff`), so the fit does not constrain the budget.
3. **The "Infinite Breath" equations.** `33 + 66 + 1 = 100`, and `33.333… + 66.666… = 100`
   exactly. Also `99.999… = 100` (`repeating_nines`), so the two lines do not differ.
4. **The fractal 2/3 ratio.** Taking the Planck 2018 value `Ω_Λ = 0.6847 ± 0.0073` as input,
   2/3 lies more than 2.4 standard errors below it (`two_thirds_vs_planck`).
5. **30/60/90 re-orientation grid.** After tilting the pole by an angle `θ ∈ [0, π]`, the old
   pole lies on the new equator exactly when `θ = 90°` (`old_pole_on_new_equator_iff`); after a
   60° shift it sits 30° from the new equator (`sixty_degree_shift`), so a 60° shift does not
   swap the frozen and hot zones completely.
6. **Conservation of Material State.** Filtering Phase into Refracted Light never changes their
   total (`conservation_of_material_state`).
-/

@[expose] public section

namespace CSTTriTorus

open CubyNumerics Real

/-! ## 1. Digit sums -/

theorem trinity_digit_roots :
    digitalRoot 111 = 3 ∧ digitalRoot 313 = 7 ∧ digitalRoot 144 = 9 ∧ digitalRoot 120 = 3 ∧
      60 * 2 = 120 ∧ 6 + 1 = 5 + 2 := by
  decide

/-- With the page's own reductions (Time 3, Space 7), Time + Space reduces to 1, not 6; and the
three domains together reduce to 1, not 9. -/
theorem space_step_mismatch :
    digitalRoot (3 + 7) = 1 ∧ digitalRoot (3 + 7 + 9) = 1 ∧ digitalRoot (111 + 313 + 144) = 1 ∧
      3 + 3 = 6 := by
  decide

/-! ## 2. The 44.8% parameterization -/

/-- Dark-energy share predicted from the Tri-Torus volume `V`: outer void plus 2/7 of the torus. -/
def darkEnergyShare (V : ℚ) : ℚ := 1 - V + 2 / 7 * V

theorem rptf_fit :
    darkEnergyShare (448 / 1000) = 68 / 100 ∧ 5 / 7 * (448 / 1000 : ℚ) = 32 / 100 ∧
      1 - (448 / 1000 : ℚ) = 552 / 1000 ∧
      ∀ V, darkEnergyShare V = 68 / 100 → V = 448 / 1000 := by
  refine ⟨by norm_num [darkEnergyShare], by norm_num, by norm_num, fun V h => ?_⟩
  unfold darkEnergyShare at h; linarith

/-- A torus volume between 0 and the whole dodecahedron reproduces a dark-energy share `f`
exactly when `2/7 ≤ f ≤ 1`. -/
theorem rptf_fit_iff (f : ℚ) :
    (∃ V, 0 ≤ V ∧ V ≤ 1 ∧ darkEnergyShare V = f) ↔ 2 / 7 ≤ f ∧ f ≤ 1 := by
  constructor
  · rintro ⟨V, h0, h1, rfl⟩; unfold darkEnergyShare; constructor <;> linarith
  · rintro ⟨h0, h1⟩
    refine ⟨7 / 5 * (1 - f), by linarith, by linarith, ?_⟩
    unfold darkEnergyShare; ring

/-! ## 3. The Infinite Breath equations -/

theorem breath_sums : (33 + 66 + 1 : ℕ) = 100 ∧ (100 / 3 + 200 / 3 : ℚ) = 100 := by norm_num

/-- `99.999… = 100`: the repeating decimal `0.999…` equals 1. -/
theorem repeating_nines : 99 + ∑' k : ℕ, (9 : ℝ) / 10 ^ (k + 1) = 100 := by
  have h : ∑' k : ℕ, (9 : ℝ) / 10 ^ (k + 1) = 1 := by
    have hg := tsum_geometric_of_lt_one (r := (1 / 10 : ℝ)) (by norm_num) (by norm_num)
    have : (fun k : ℕ => (9 : ℝ) / 10 ^ (k + 1)) = fun k => (9 / 10) * (1 / 10) ^ k := by
      funext k; rw [pow_succ, one_div_pow]; field_simp
    rw [this, tsum_mul_left, hg]; norm_num
  rw [h]; norm_num

/-! ## 4. The fractal 2/3 ratio against Planck 2018 -/

/-- With `Ω_Λ = 0.6847 ± 0.0073` (Planck 2018, taken as input), 2/3 is more than 2.4 standard
errors away. -/
theorem two_thirds_vs_planck : (24 / 10 : ℚ) * (73 / 10000) < 6847 / 10000 - 2 / 3 := by
  norm_num

/-! ## 5. The 30/60/90 re-orientation grid -/

/-- After tilting the processing pole by `θ ∈ [0, π]`, the old pole is at angle `θ` from the new
pole, so it lies on the new equator (90° from the new pole) exactly when `θ = π/2`. -/
theorem old_pole_on_new_equator_iff {θ : ℝ} (h0 : 0 ≤ θ) (hπ : θ ≤ π) :
    cos θ = 0 ↔ θ = π / 2 := by
  constructor
  · intro h
    have := Real.injOn_cos ⟨h0, hπ⟩ ⟨by linarith [pi_pos], by linarith [pi_pos]⟩
      (h.trans cos_pi_div_two.symm)
    exact this
  · rintro rfl; exact cos_pi_div_two

/-- After a 60° shift the old pole sits at latitude 30° in the new frame, not on the equator. -/
theorem sixty_degree_shift : cos (π / 3) = 1 / 2 ∧ π / 2 - π / 3 = π / 6 := by
  refine ⟨cos_pi_div_three, by ring⟩

/-! ## 6. Conservation of Material State -/

/-- Filtering an amount `a` of Phase into Refracted Light. -/
def filterStep (a : ℚ) (s : ℚ × ℚ) : ℚ × ℚ := (s.1 - a, s.2 + a)

/-- The total of Phase and Refracted Light is unchanged by any sequence of filtering steps
(including steps with negative `a`, i.e. Phase being released back). -/
theorem conservation_of_material_state (steps : List ℚ) (s : ℚ × ℚ) :
    let t := steps.foldl (fun s a => filterStep a s) s
    t.1 + t.2 = s.1 + s.2 := by
  induction steps generalizing s with
  | nil => rfl
  | cons a as ih =>
    simp only [List.foldl_cons]
    rw [ih]; simp [filterStep]

end CSTTriTorus
