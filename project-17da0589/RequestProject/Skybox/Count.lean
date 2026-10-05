module

public import RequestProject.RoundFour.H4
import all RequestProject.RoundFour.H4

/-!
# 12 × 12 = 144 and 120 × 120 = 14 400: the symmetries of the 120-point skybox

The 120 unit icosians (`RoundFour.H4.icosians`, the vertices of the 600-cell, the
"120-node skybox") are viewed as quaternions `w + x i + y j + z k`.

What is proved here:

* `icosians_mul_mem`, `icosians_conj_mem`, `one_mem_icosians` — the 120 points are closed
  under quaternion multiplication and conjugation and contain `1`: they form a group with
  120 elements.
* `rotation_preserves`, `mirror_preserves` — for every *pair* `(l, r)` of the 120 points
  (there are `120 × 120 = 14 400` pairs), the map `x ↦ l·x·r̄` and its mirror image
  `x ↦ l·x̄·r̄` send the 120 points to themselves.
* `rotation_count` — the maps `x ↦ l·x·r̄` give exactly 7 200 different matrices
  (the pairs `(l, r)` and `(-l, -r)` give the same map).
* `skybox_symmetry_count` — together with the mirror images they give 14 400 different
  matrices, i.e. at least 14 400 different symmetries of the 120-point skybox.
  (That these are *all* of its symmetries — the classical fact that the symmetry group
  `H₄` has order 14 400 — is not proved here.)

Here the "matrix" of a map is the list of images of the four basis quaternions `1, i, j, k`;
maps with different matrices are different maps.
-/

@[expose] public section

namespace Skybox

open RoundFour.H4 RoundFour.H4.Q5

/-- Quaternion product of `(w, x, y, z) = w + x i + y j + z k`. -/
def qmul (p q : V4) : V4 :=
  let (a1, b1, c1, d1) := p
  let (a2, b2, c2, d2) := q
  (a1 * a2 - b1 * b2 - c1 * c2 - d1 * d2,
   a1 * b2 + b1 * a2 + c1 * d2 - d1 * c2,
   a1 * c2 - b1 * d2 + c1 * a2 + d1 * b2,
   a1 * d2 + b1 * c2 - c1 * b2 + d1 * a2)

/-- Quaternion conjugate `w - x i - y j - z k`. -/
def qconj (p : V4) : V4 := (p.1, -p.2.1, -p.2.2.1, -p.2.2.2)

/-- The rotation `x ↦ l · x · r̄`. -/
def rotate (l r x : V4) : V4 := qmul (qmul l x) (qconj r)

/-- The mirror map `x ↦ l · x̄ · r̄`. -/
def mirror (l r x : V4) : V4 := qmul (qmul l (qconj x)) (qconj r)

/-- The basis quaternions `1, i, j, k`. -/
def basis : List V4 := [(1, 0, 0, 0), (0, 1, 0, 0), (0, 0, 1, 0), (0, 0, 0, 1)]

/-- The matrix (images of `1, i, j, k`) of a map. -/
def matrixOf (f : V4 → V4) : List V4 := basis.map f

/-- All 14 400 rotation matrices, one for each pair `(l, r)`. -/
def rotationMatrices : List (List V4) :=
  icosians.flatMap fun l => icosians.map fun r => matrixOf (rotate l r)

/-- All 14 400 mirror matrices, one for each pair `(l, r)`. -/
def mirrorMatrices : List (List V4) :=
  icosians.flatMap fun l => icosians.map fun r => matrixOf (mirror l r)

/-! ### The 120 points form a group -/

theorem one_mem_icosians : ((1, 0, 0, 0) : V4) ∈ icosians := by native_decide

theorem icosians_conj_mem : ∀ p ∈ icosians, qconj p ∈ icosians := by native_decide

theorem icosians_mul_mem : ∀ p ∈ icosians, ∀ q ∈ icosians, qmul p q ∈ icosians := by
  native_decide

/-! ### Every pair gives a symmetry -/

theorem rotation_preserves (l r x : V4) (hl : l ∈ icosians) (hr : r ∈ icosians)
    (hx : x ∈ icosians) : rotate l r x ∈ icosians :=
  icosians_mul_mem _ (icosians_mul_mem l hl x hx) _ (icosians_conj_mem r hr)

theorem mirror_preserves (l r x : V4) (hl : l ∈ icosians) (hr : r ∈ icosians)
    (hx : x ∈ icosians) : mirror l r x ∈ icosians :=
  icosians_mul_mem _ (icosians_mul_mem l hl _ (icosians_conj_mem x hx)) _
    (icosians_conj_mem r hr)

/-! ### Counting -/

theorem icosians_card : icosians.toFinset.card = 120 := by
  rw [List.toFinset_card_of_nodup icosians_nodup, icosians_length]

theorem pairs_count : (icosians ×ˢ icosians).length = 14400 := by
  rw [List.length_product, icosians_length]

theorem rotation_count : rotationMatrices.toFinset.card = 7200 := by
  rw [List.card_toFinset]; native_decide

/-- Flip the signs of the images of `i, j, k`: composing with `x ↦ x̄`. -/
def flipTail (m : List V4) : List V4 :=
  m.mapIdx fun k v => if k = 0 then v else (-v.1, -v.2.1, -v.2.2.1, -v.2.2.2)

theorem Q5_neg_neg (x : Q5) : -(-x) = x := by
  cases x
  show Q5.mk (-(-_)) (-(-_)) = _
  simp

theorem flipTail_flipTail (m : List V4) : flipTail (flipTail m) = m := by
  unfold flipTail
  apply List.ext_getElem (by simp)
  intro n h1 h2
  by_cases hk : n = 0 <;> simp [hk, Q5_neg_neg]

theorem flipTail_injective : Function.Injective flipTail := fun a b h => by
  rw [← flipTail_flipTail a, ← flipTail_flipTail b, h]

theorem mirrorMatrices_eq : mirrorMatrices = rotationMatrices.map flipTail := by
  native_decide

/-- A 3 × 3 determinant. -/
def det3 (a b c d e f g h i : Q5) : Q5 :=
  a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g)

/-- A 4 × 4 determinant (cofactor expansion along the first column list entry). -/
def det4 (m : List V4) : Q5 :=
  let c0 := m.getD 0 (0, 0, 0, 0)
  let c1 := m.getD 1 (0, 0, 0, 0)
  let c2 := m.getD 2 (0, 0, 0, 0)
  let c3 := m.getD 3 (0, 0, 0, 0)
  c0.1 * det3 c1.2.1 c2.2.1 c3.2.1 c1.2.2.1 c2.2.2.1 c3.2.2.1 c1.2.2.2 c2.2.2.2 c3.2.2.2
  - c0.2.1 * det3 c1.1 c2.1 c3.1 c1.2.2.1 c2.2.2.1 c3.2.2.1 c1.2.2.2 c2.2.2.2 c3.2.2.2
  + c0.2.2.1 * det3 c1.1 c2.1 c3.1 c1.2.1 c2.2.1 c3.2.1 c1.2.2.2 c2.2.2.2 c3.2.2.2
  - c0.2.2.2 * det3 c1.1 c2.1 c3.1 c1.2.1 c2.2.1 c3.2.1 c1.2.2.1 c2.2.2.1 c3.2.2.1

theorem det_rotations : ∀ m ∈ rotationMatrices, det4 m = 1 := by native_decide

theorem det_mirrors : ∀ m ∈ mirrorMatrices, det4 m = -1 := by native_decide

theorem rotation_mirror_disjoint :
    Disjoint rotationMatrices.toFinset mirrorMatrices.toFinset := by
  rw [Finset.disjoint_left]
  intro m h1 h2
  rw [List.mem_toFinset] at h1 h2
  have := (det_rotations m h1).symm.trans (det_mirrors m h2)
  exact absurd this (by native_decide)

theorem mirror_count : mirrorMatrices.toFinset.card = 7200 := by
  have h : (rotationMatrices.map flipTail).toFinset = rotationMatrices.toFinset.image flipTail := by
    ext; simp
  rw [mirrorMatrices_eq, h, Finset.card_image_of_injective _ flipTail_injective, rotation_count]

/-- The rotations `x ↦ l·x·r̄` and mirror maps `x ↦ l·x̄·r̄`, over all `120 × 120` pairs of
skybox points, give 14 400 different matrices: at least 14 400 different symmetries of the
120-point skybox. -/
theorem skybox_symmetry_count :
    (rotationMatrices ++ mirrorMatrices).toFinset.card = 14400 := by
  rw [List.toFinset_append, Finset.card_union_of_disjoint rotation_mirror_disjoint,
    rotation_count, mirror_count]

/-- The plain arithmetic in the message. -/
theorem skybox_arithmetic :
    12 * 12 = 144 ∧ 144 * 100 = 14400 ∧ 120 * 120 = 14400 ∧ 2 * 7200 = 14400 := by
  norm_num

end Skybox
