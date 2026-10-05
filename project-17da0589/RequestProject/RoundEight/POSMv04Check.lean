module

public import Mathlib

/-!
# Ryan's POSM v0.4 (temporal composition), kernel-checked

This is the Lean source of `POSM_v0.4_temporal_composition.zip` (attached to *ORION R8 Live*),
gathered into one file and checked by the Lean kernel. The package's own `BUILD_STATUS.md` says
Lean was not run when it was made.

Built as shipped, on its own pinned toolchain (Lean 4.19.0, Mathlib `v4.19.0`), `lake build`
fails three times; the same two proof errors also appear on this project's Lean 4.28:

1. `POSM/Composition.lean:165`: `exact_mod_cast hn` after `gcongr` fails with "no goals":
   `gcongr` already closes the goal. Fix: delete the line.
2. `POSM/Counterexample.lean:26-27`: in the triangle-inequality proof for the discrete
   distance, `simp [natDiscreteDistance]` leaves `0 ≤ (if a = b then 0 else 1) + (if b = a then
   0 else 1)`. Fix: `simp only [natDiscreteDistance, if_true]` then `split_ifs <;> norm_num`.
3. `Main.lean` has no `main` function, so the `posm` executable (a default target) does not
   link. Fix: add `def main : IO Unit := IO.println (repr governanceV04)`.

With those three fixes, every theorem in the package is proved, using only Lean's standard axioms.
No statement was changed. The only other change here is that the `#eval` in `Main.lean` is not
copied.

The section at the end adds one result the package does not have:
`local_does_not_imply_uniform_global_budget` rules out *every* real budget, not only
whole-number ones (the package's `local_does_not_imply_uniform_global_nat_budget`).
-/

@[expose] public section

namespace POSM

/-- A deliberately minimal boundary geometry.  It is a pseudometric-shaped
interface, stated explicitly so the continuity assumptions remain visible. -/
structure BoundaryGeometry (B : Type*) where
  d : B → B → ℝ
  nonneg : ∀ a b, 0 ≤ d a b
  refl : ∀ a, d a a = 0
  symm : ∀ a b, d a b = d b a
  triangle : ∀ a b c, d a c ≤ d a b + d b c

variable {B : Type*}

/-- One-step change in the boundary state. -/
def boundaryJump (G : BoundaryGeometry B) (boundary : ℕ → B) (t : ℕ) : ℝ :=
  G.d (boundary t) (boundary (t + 1))

/-- Path-length style drift accumulated over `n` consecutive transitions. -/
def cumulativeBoundaryDrift
    (G : BoundaryGeometry B) (boundary : ℕ → B) (t : ℕ) : ℕ → ℝ
  | 0 => 0
  | n + 1 => cumulativeBoundaryDrift G boundary t n + boundaryJump G boundary (t + n)

/-- The direct distance between the interval endpoints. -/
def endpointBoundaryDistance
    (G : BoundaryGeometry B) (boundary : ℕ → B) (t n : ℕ) : ℝ :=
  G.d (boundary t) (boundary (t + n))

/-- v0.3 identity-through-change: after some horizon, every local boundary jump
and every model-tracking error stays within its own bound. -/
def IdentityThroughChange
    (G : BoundaryGeometry B)
    (boundary : ℕ → B)
    (trackingError : ℕ → ℝ)
    (δ K : ℝ) : Prop :=
  ∃ T, ∀ t, T ≤ t → boundaryJump G boundary t ≤ δ ∧ trackingError t ≤ K

/-- v0.4 adds an interval budget.  Local admissibility remains necessary, but
identity over a window also requires cumulative drift to fit the budget. -/
def WindowedIdentityThroughChange
    (G : BoundaryGeometry B)
    (boundary : ℕ → B)
    (trackingError : ℕ → ℝ)
    (δ K D : ℝ)
    (H : ℕ) : Prop :=
  ∃ T, ∀ t, T ≤ t →
    trackingError t ≤ K ∧
    boundaryJump G boundary t ≤ δ ∧
    ∀ n, n ≤ H → cumulativeBoundaryDrift G boundary t n ≤ D

/-- A strong, horizon-independent continuity requirement.  This is intentionally
stronger than local identity-through-change. -/
def UniformGlobalIdentity
    (G : BoundaryGeometry B)
    (boundary : ℕ → B)
    (trackingError : ℕ → ℝ)
    (δ K D : ℝ) : Prop :=
  ∃ T, ∀ t, T ≤ t →
    trackingError t ≤ K ∧
    boundaryJump G boundary t ≤ δ ∧
    ∀ n, cumulativeBoundaryDrift G boundary t n ≤ D

/-- Recursive path length composes exactly across adjacent intervals. -/
theorem cumulative_compose
    (G : BoundaryGeometry B) (boundary : ℕ → B) (t m n : ℕ) :
    cumulativeBoundaryDrift G boundary t (m + n) =
      cumulativeBoundaryDrift G boundary t m +
      cumulativeBoundaryDrift G boundary (t + m) n := by
  induction n with
  | zero => simp [cumulativeBoundaryDrift]
  | succ n ih =>
      simp [Nat.add_assoc, cumulativeBoundaryDrift, ih, add_assoc]

/-- Triangle inequality converts path-length drift into an endpoint bound. -/
theorem endpoint_le_cumulative
    (G : BoundaryGeometry B) (boundary : ℕ → B) (t n : ℕ) :
    endpointBoundaryDistance G boundary t n ≤
      cumulativeBoundaryDrift G boundary t n := by
  induction n with
  | zero =>
      simp [endpointBoundaryDistance, cumulativeBoundaryDrift, G.refl]
  | succ n ih =>
      have htri := G.triangle (boundary t) (boundary (t + n)) (boundary (t + (n + 1)))
      have hstep :
          G.d (boundary (t + n)) (boundary (t + (n + 1))) =
            boundaryJump G boundary (t + n) := by
        simp [boundaryJump, Nat.add_assoc]
      calc
        endpointBoundaryDistance G boundary t (n + 1)
            = G.d (boundary t) (boundary (t + (n + 1))) := rfl
        _ ≤ G.d (boundary t) (boundary (t + n)) +
              G.d (boundary (t + n)) (boundary (t + (n + 1))) := htri
        _ = endpointBoundaryDistance G boundary t n +
              boundaryJump G boundary (t + n) := by
                rw [hstep]
                rfl
        _ ≤ cumulativeBoundaryDrift G boundary t n +
              boundaryJump G boundary (t + n) := by
                gcongr
        _ = cumulativeBoundaryDrift G boundary t (n + 1) := by
                rfl

/-- If each of the next `n` jumps is at most `δ`, cumulative drift is at most
`n * δ`.  This is the core temporal-composition budget. -/
theorem cumulative_le_linear_budget
    (G : BoundaryGeometry B) (boundary : ℕ → B)
    (t n : ℕ) (δ : ℝ)
    (h : ∀ i, i < n → boundaryJump G boundary (t + i) ≤ δ) :
    cumulativeBoundaryDrift G boundary t n ≤ (n : ℝ) * δ := by
  induction n with
  | zero => simp [cumulativeBoundaryDrift]
  | succ n ih =>
      have hprev : ∀ i, i < n → boundaryJump G boundary (t + i) ≤ δ := by
        intro i hi
        exact h i (Nat.lt_trans hi (Nat.lt_succ_self n))
      have hlast : boundaryJump G boundary (t + n) ≤ δ := h n (Nat.lt_succ_self n)
      calc
        cumulativeBoundaryDrift G boundary t (n + 1)
            = cumulativeBoundaryDrift G boundary t n + boundaryJump G boundary (t + n) := rfl
        _ ≤ (n : ℝ) * δ + δ := add_le_add (ih hprev) hlast
        _ = ((n + 1 : ℕ) : ℝ) * δ := by
              push_cast
              ring

/-- v0.3 local identity therefore composes to a linear interval envelope. -/
theorem identityThroughChange_implies_linear_envelope
    (G : BoundaryGeometry B)
    (boundary : ℕ → B)
    (trackingError : ℕ → ℝ)
    (δ K : ℝ)
    (hId : IdentityThroughChange G boundary trackingError δ K) :
    ∃ T, ∀ t, T ≤ t → ∀ n,
      cumulativeBoundaryDrift G boundary t n ≤ (n : ℝ) * δ := by
  rcases hId with ⟨T, hT⟩
  refine ⟨T, ?_⟩
  intro t ht n
  apply cumulative_le_linear_budget G boundary t n δ
  intro i hi
  exact (hT (t + i) (le_trans ht (Nat.le_add_right t i))).1

/-- A finite horizon `H` turns a local step bound into a finite cumulative
budget `H * δ`. -/
theorem identityThroughChange_implies_windowed
    (G : BoundaryGeometry B)
    (boundary : ℕ → B)
    (trackingError : ℕ → ℝ)
    (δ K : ℝ)
    (H : ℕ)
    (hδ : 0 ≤ δ)
    (hId : IdentityThroughChange G boundary trackingError δ K) :
    WindowedIdentityThroughChange G boundary trackingError δ K ((H : ℝ) * δ) H := by
  rcases hId with ⟨T, hT⟩
  refine ⟨T, ?_⟩
  intro t ht
  refine ⟨(hT t ht).2, (hT t ht).1, ?_⟩
  intro n hn
  have hlin := cumulative_le_linear_budget G boundary t n δ (fun i hi =>
    (hT (t + i) (le_trans ht (Nat.le_add_right t i))).1)
  calc
    cumulativeBoundaryDrift G boundary t n ≤ (n : ℝ) * δ := hlin
    _ ≤ (H : ℝ) * δ := by
      gcongr

/-- Discrete geometry on natural-number boundary states. -/
def natDiscreteDistance (a b : ℕ) : ℝ := if a = b then 0 else 1

def natDiscreteGeometry : BoundaryGeometry ℕ where
  d := natDiscreteDistance
  nonneg := by
    intro a b
    by_cases h : a = b <;> simp [natDiscreteDistance, h]
  refl := by
    intro a
    simp [natDiscreteDistance]
  symm := by
    intro a b
    by_cases h : a = b
    · subst b
      simp [natDiscreteDistance]
    · have h' : b ≠ a := by exact fun hba => h (Eq.symm hba)
      simp [natDiscreteDistance, h, h']
  triangle := by
    intro a b c
    by_cases hac : a = c
    · subst c
      simp only [natDiscreteDistance, if_true]
      split_ifs <;> norm_num
    · by_cases hab : a = b
      · subst b
        simp [natDiscreteDistance, hac]
      · by_cases hbc : b = c
        · subst c
          simp [natDiscreteDistance, hac, hab]
        · simp [natDiscreteDistance, hac, hab, hbc]

/-- A boundary that changes to a fresh state every step. -/
def linearBoundary (t : ℕ) : ℕ := t

def exactTrackingError (_t : ℕ) : ℝ := 0

theorem linear_jump_one (t : ℕ) :
    boundaryJump natDiscreteGeometry linearBoundary t = 1 := by
  simp [boundaryJump, natDiscreteGeometry, natDiscreteDistance, linearBoundary]

theorem linear_cumulative_eq_nat (t n : ℕ) :
    cumulativeBoundaryDrift natDiscreteGeometry linearBoundary t n = (n : ℝ) := by
  induction n with
  | zero => simp [cumulativeBoundaryDrift]
  | succ n ih =>
      simp [cumulativeBoundaryDrift, ih, linear_jump_one, Nat.cast_add, Nat.cast_one]

/-- Every local step is admissible at δ = 1 and tracking is exact. -/
theorem linear_has_local_identity :
    IdentityThroughChange natDiscreteGeometry linearBoundary exactTrackingError 1 0 := by
  refine ⟨0, ?_⟩
  intro t ht
  constructor
  · simp [linear_jump_one]
  · simp [exactTrackingError]

/-- Yet no finite natural-number cumulative budget can bound the trajectory for
all horizons.  Local admissibility therefore does not imply uniform global
identity. -/
theorem local_does_not_imply_uniform_global_nat_budget :
    ¬ ∃ D : ℕ,
      UniformGlobalIdentity natDiscreteGeometry linearBoundary exactTrackingError 1 0 (D : ℝ) := by
  intro h
  rcases h with ⟨D, T, hT⟩
  have hbudget := (hT T (Nat.le_refl T)).2.2 (D + 1)
  rw [linear_cumulative_eq_nat] at hbudget
  have hnot : ¬ (((D + 1 : ℕ) : ℝ) ≤ (D : ℝ)) := by
    exact_mod_cast Nat.not_succ_le_self D
  exact hnot hbudget

/-- The same witness is perfectly well-behaved on any fixed finite window: its
required cumulative budget is exactly the window length. -/
theorem linear_is_windowed (H : ℕ) :
    WindowedIdentityThroughChange
      natDiscreteGeometry linearBoundary exactTrackingError 1 0 (H : ℝ) H := by
  simpa using
    identityThroughChange_implies_windowed
      natDiscreteGeometry linearBoundary exactTrackingError 1 0 H (by norm_num) linear_has_local_identity

structure GovernanceState where
  canShip : Bool
  hasAuthority : Bool
  cycle0Open : Bool
  deriving Repr, DecidableEq

/-- v0.4 changes continuity mathematics, not authority. -/
def governanceV04 : GovernanceState :=
  { canShip := true, hasAuthority := false, cycle0Open := false }

theorem canShip_ne_hasAuthority : governanceV04.canShip ≠ governanceV04.hasAuthority := by
  decide

theorem cycle0_remains_closed : governanceV04.cycle0Open = false := by
  rfl

/-! ## Added: no real budget works either -/

/-- The package proves that no *whole-number* budget `D` bounds the linear witness's drift over
every horizon. The same holds for every real `D`: drift over `n` steps is `n`, which eventually
passes any real number. -/
theorem local_does_not_imply_uniform_global_budget :
    ¬ ∃ D : ℝ,
      UniformGlobalIdentity natDiscreteGeometry linearBoundary exactTrackingError 1 0 D := by
  rintro ⟨D, T, hT⟩
  obtain ⟨n, hn⟩ := exists_nat_gt D
  have h := (hT T le_rfl).2.2 n
  rw [linear_cumulative_eq_nat] at h
  linarith

/-- Local identity-through-change holds for the linear witness, yet it has no uniform global
identity for any real budget: the package's claim 5, without the whole-number restriction. -/
theorem local_identity_not_uniform_global :
    IdentityThroughChange natDiscreteGeometry linearBoundary exactTrackingError 1 0 ∧
      ∀ D : ℝ, ¬ UniformGlobalIdentity natDiscreteGeometry linearBoundary exactTrackingError 1 0 D :=
  ⟨linear_has_local_identity, fun D hD => local_does_not_imply_uniform_global_budget ⟨D, hD⟩⟩

end POSM

end
