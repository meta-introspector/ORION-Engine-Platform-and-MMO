module

public import Mathlib

/-!
# The 600-cell / H₄ engine: what is right, what is broken, and the fix

This file checks the geometry behind the `H4 / PENROSE GEOMETRIC ENGINE` scripts in the
Round Four zip archive (see `ROUND_FOUR_TRIAGE.md`, section C1).

All arithmetic is exact, in the field `ℚ(√5)`, modelled as pairs `a + b√5` with rational
`a, b`.  `Q5.toReal_mul` shows the model multiplies exactly like the real numbers
`a + b·√5`, so every identity checked here also holds over `ℝ`.

What is proved:

* `icosians_length`, `icosians_nodup`, `icosians_unit` — the 120 unit icosians the scripts
  build (16 + 8 + 96 points) really are 120 distinct points on the unit 3-sphere (the
  vertices of the 600-cell).  `icosians_unit_real` restates the norm identity over `ℝ`.
* `orig_not_equal_length` — the scripts' "simple roots" for H₄ do not all have the same
  length, so they cannot be a simple system for H₄ (all H₄ roots have one length).  This is
  why the scripts' reflection orbits never close (they stop at the 20 000-point cap).
* `orig_first_pair_angle` — the first two of those roots meet at 120° (Coxeter label 3),
  but the scripts' diagram `•--5--•---•---•` puts the label 5 on that pair.
* `fixedSimple_gram` — the corrected roots have exactly the H₄ Coxeter Gram matrix:
  unit length, `⟨α₁,α₂⟩ = -φ/2 = -cos 36°`, `⟨α₂,α₃⟩ = ⟨α₃,α₄⟩ = -1/2 = -cos 60°`, and the
  other pairs orthogonal.
* `fixed_reflections_preserve_icosians` and `orbit_stays_in_icosians` — each corrected
  reflection maps the 120 points to themselves, so any reflection orbit of a root stays
  inside the 600-cell and closes (at 120 points).
-/

@[expose] public section

namespace RoundFour.H4

/-- An element `a + b√5` of the field `ℚ(√5)`. -/
structure Q5 where
  a : ℚ
  b : ℚ
deriving DecidableEq, Repr

namespace Q5

instance : Zero Q5 := ⟨⟨0, 0⟩⟩
instance : One Q5 := ⟨⟨1, 0⟩⟩
instance : Add Q5 := ⟨fun x y => ⟨x.a + y.a, x.b + y.b⟩⟩
instance : Neg Q5 := ⟨fun x => ⟨-x.a, -x.b⟩⟩
instance : Sub Q5 := ⟨fun x y => ⟨x.a - y.a, x.b - y.b⟩⟩
instance : Mul Q5 := ⟨fun x y => ⟨x.a * y.a + 5 * x.b * y.b, x.a * y.b + x.b * y.a⟩⟩

/-- A rational number viewed in `ℚ(√5)`. -/
def ofRat (q : ℚ) : Q5 := ⟨q, 0⟩

/-- `1/2`. -/
def half : Q5 := ⟨1 / 2, 0⟩
/-- The golden ratio `φ = (1 + √5)/2`. -/
def phi : Q5 := ⟨1 / 2, 1 / 2⟩
/-- `1/φ = φ - 1 = (√5 - 1)/2`. -/
def iphi : Q5 := ⟨-1 / 2, 1 / 2⟩

/-- The real number `a + b√5`. -/
noncomputable def toReal (x : Q5) : ℝ := (x.a : ℝ) + (x.b : ℝ) * Real.sqrt 5

theorem toReal_add (x y : Q5) : toReal (x + y) = toReal x + toReal y := by
  show ((x.a + y.a : ℚ) : ℝ) + ((x.b + y.b : ℚ) : ℝ) * Real.sqrt 5 = _
  unfold toReal; push_cast; ring

/-- The model multiplies like the reals `a + b√5`. -/
theorem toReal_mul (x y : Q5) : toReal (x * y) = toReal x * toReal y := by
  show ((x.a * y.a + 5 * x.b * y.b : ℚ) : ℝ) + ((x.a * y.b + x.b * y.a : ℚ) : ℝ) * Real.sqrt 5 = _
  unfold toReal
  have h5 : Real.sqrt 5 * Real.sqrt 5 = 5 := Real.mul_self_sqrt (by norm_num)
  push_cast
  linear_combination (-(x.b : ℝ) * (y.b : ℝ)) * h5

theorem toReal_one : toReal 1 = 1 := by
  show ((1 : ℚ) : ℝ) + ((0 : ℚ) : ℝ) * Real.sqrt 5 = 1
  simp

theorem phi_mul_iphi : phi * iphi = 1 := by native_decide

end Q5

open Q5

/-- A vector in `ℚ(√5)⁴`. -/
abbrev V4 := Q5 × Q5 × Q5 × Q5

/-- The Euclidean inner product on `ℚ(√5)⁴`. -/
def dot (u v : V4) : Q5 :=
  u.1 * v.1 + u.2.1 * v.2.1 + u.2.2.1 * v.2.2.1 + u.2.2.2 * v.2.2.2

/-- Scalar multiple. -/
def smul (c : Q5) (u : V4) : V4 := (c * u.1, c * u.2.1, c * u.2.2.1, c * u.2.2.2)

/-- Vector difference. -/
def vsub (u v : V4) : V4 := (u.1 - v.1, u.2.1 - v.2.1, u.2.2.1 - v.2.2.1, u.2.2.2 - v.2.2.2)

/-- Reflection in the hyperplane orthogonal to a *unit* vector `n`: `v ↦ v - 2⟨v,n⟩ n`. -/
def reflectUnit (v n : V4) : V4 := vsub v (smul (ofRat 2 * dot v n) n)

/-- Build a vector from a list of four coordinates (missing entries are `0`). -/
def ofList (l : List Q5) : V4 :=
  (l.getD 0 0, l.getD 1 0, l.getD 2 0, l.getD 3 0)

/-- The 16 points `(±1/2, ±1/2, ±1/2, ±1/2)`. -/
def halfPoints : List V4 :=
  (List.range 16).map fun s =>
    ofList ((List.range 4).map fun k => if s.testBit k then half else -half)

/-- The 8 points `±eᵢ`. -/
def axisPoints : List V4 :=
  (List.range 4).flatMap fun i =>
    [ofList ((List.range 4).map fun k => if k = i then 1 else 0),
     ofList ((List.range 4).map fun k => if k = i then -1 else 0)]

/-- The 12 even permutations of four positions. -/
def evenPerms : List (List ℕ) :=
  [[0, 1, 2, 3], [0, 2, 3, 1], [0, 3, 1, 2], [1, 0, 3, 2], [1, 2, 0, 3], [1, 3, 2, 0],
   [2, 0, 1, 3], [2, 1, 3, 0], [2, 3, 0, 1], [3, 0, 2, 1], [3, 1, 0, 2], [3, 2, 1, 0]]

/-- The 96 points: even permutations of `(±φ, ±1, ±1/φ, 0)/2`. -/
def goldenPoints : List V4 :=
  (List.range 8).flatMap fun s =>
    let base : List Q5 :=
      [if s.testBit 0 then half * phi else -(half * phi),
       if s.testBit 1 then half else -half,
       if s.testBit 2 then half * iphi else -(half * iphi),
       0]
    evenPerms.map fun p => ofList (p.map fun i => base.getD i 0)

/-- The 120 unit icosians = the vertices of the 600-cell = the H₄ root system. -/
def icosians : List V4 := halfPoints ++ axisPoints ++ goldenPoints

theorem icosians_length : icosians.length = 120 := by native_decide

theorem icosians_nodup : icosians.Nodup := by native_decide

theorem icosians_unit : ∀ p ∈ icosians, dot p p = 1 := by native_decide

/-- The unit-norm identity, over the real numbers. -/
theorem icosians_unit_real (p : V4) (hp : p ∈ icosians) :
    toReal p.1 ^ 2 + toReal p.2.1 ^ 2 + toReal p.2.2.1 ^ 2 + toReal p.2.2.2 ^ 2 = 1 := by
  have h := congrArg toReal (icosians_unit p hp)
  simp only [dot, toReal_add, toReal_mul, toReal_one] at h
  nlinarith [h]

/-! ### The scripts' simple roots -/

/-- The first three "simple roots" used by the scripts: `e₁ - e₂`, `e₂ - e₃`, `e₃ - e₄`. -/
def origα1 : V4 := (1, -1, 0, 0)
def origα2 : V4 := (0, 1, -1, 0)
def origα3 : V4 := (0, 0, 1, -1)
/-- The fourth root of the exact `ℚ(√5)` script: `(-√5/4, 1/2, 1/2, √5/4)`. -/
def origα4exact : V4 := (⟨0, -1 / 4⟩, half, half, ⟨0, 1 / 4⟩)
/-- The fourth root of the floating-point scripts: `(-φ/2, 1/2, 1/2, (φ-1)/2)`. -/
def origα4float : V4 := (-(half * phi), half, half, half * iphi)

/-- The scripts' roots do not have a common length (`|α₁|² = 2`, but `|α₄|² = 9/8` in the
exact script and `5/4` in the floating-point ones), so they are not an H₄ simple system. -/
theorem orig_not_equal_length :
    dot origα1 origα1 = ofRat 2 ∧ dot origα4exact origα4exact = ofRat (9 / 8) ∧
      dot origα4float origα4float = ofRat (5 / 4) := by
  native_decide

/-- The first pair meets at 120°: the Cartan entry `2⟨α₁,α₂⟩/⟨α₂,α₂⟩` is `-1` (Coxeter
label 3), although the scripts' diagram puts the label 5 there. -/
theorem orig_first_pair_angle :
    dot origα1 origα2 = ofRat (-1) ∧ dot origα2 origα2 = ofRat 2 := by
  native_decide

/-! ### The corrected simple roots -/

/-- `α₁ = -e₁`. -/
def fixα1 : V4 := (-1, 0, 0, 0)
/-- `α₂ = (φ/2, -1/2, 1/(2φ), 0)`. -/
def fixα2 : V4 := (half * phi, -half, half * iphi, 0)
/-- `α₃ = (0, φ/2, -1/(2φ), -1/2)`. -/
def fixα3 : V4 := (0, half * phi, -(half * iphi), -half)
/-- `α₄ = e₄`. -/
def fixα4 : V4 := (0, 0, 0, 1)

/-- The corrected simple system. -/
def fixedSimple : List V4 := [fixα1, fixα2, fixα3, fixα4]

/-- The corrected roots are themselves among the 120 icosians. -/
theorem fixedSimple_mem : ∀ n ∈ fixedSimple, n ∈ icosians := by native_decide

/-- The corrected roots have the H₄ Coxeter Gram matrix
`⟨αᵢ,αⱼ⟩ = -cos(π/mᵢⱼ)` with `m₁₂ = 5`, `m₂₃ = m₃₄ = 3` and all other pairs `2`. -/
theorem fixedSimple_gram :
    dot fixα1 fixα1 = 1 ∧ dot fixα2 fixα2 = 1 ∧ dot fixα3 fixα3 = 1 ∧ dot fixα4 fixα4 = 1 ∧
      dot fixα1 fixα2 = -(half * phi) ∧ dot fixα2 fixα3 = -half ∧
      dot fixα3 fixα4 = -half ∧ dot fixα1 fixα3 = 0 ∧ dot fixα1 fixα4 = 0 ∧
      dot fixα2 fixα4 = 0 := by
  native_decide

/-- `cos 36° = φ/2`, so `-(half * phi)` really is `-cos(π/5)`. -/
theorem cos_pi_div_five_eq : Real.cos (Real.pi / 5) = toReal (half * phi) := by
  rw [Real.cos_pi_div_five, toReal_mul]
  simp only [toReal, half, phi]
  push_cast
  ring

/-- Each corrected reflection maps the 600-cell's vertex set to itself. -/
theorem fixed_reflections_preserve_icosians :
    ∀ n ∈ fixedSimple, ∀ p ∈ icosians, reflectUnit p n ∈ icosians := by
  native_decide

/-- The `i`-th corrected simple root. -/
def gen : Fin 4 → V4
  | 0 => fixα1
  | 1 => fixα2
  | 2 => fixα3
  | 3 => fixα4

theorem gen_mem (i : Fin 4) : gen i ∈ fixedSimple := by
  fin_cases i <;> simp [gen, fixedSimple]

/-- Apply the corrected reflections named by a word of generator indices. -/
def applyWord (w : List (Fin 4)) (v : V4) : V4 :=
  w.foldl (fun x i => reflectUnit x (gen i)) v

/-- Every reflection orbit of a root stays inside the 120 vertices of the 600-cell, so the
orbit search in the corrected engine terminates (it cannot pass 120 points). -/
theorem orbit_stays_in_icosians (w : List (Fin 4)) (p : V4) (hp : p ∈ icosians) :
    applyWord w p ∈ icosians := by
  unfold applyWord
  induction w generalizing p with
  | nil => simpa using hp
  | cons i w ih =>
    exact ih _ (fixed_reflections_preserve_icosians _ (gen_mem i) p hp)

end RoundFour.H4
