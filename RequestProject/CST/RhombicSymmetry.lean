module

public import Mathlib

/-!
# The space-filling dodecahedron is a cube–octahedron object

Context: the *Blade node* comparison of Logvinovich's IT³ "Macroscopic Atom" model with
TGS:ATE lists "Different privileged polyhedra": cube / octahedron / `O_h` symmetry for IT³,
dodecahedral foam for TGS:ATE.

`RequestProject/CST/Geometry.lean` already showed that regular (pentagonal) dodecahedra cannot
fill space and that the rhombic dodecahedron can. This file checks, with integer coordinates,
that the rhombic dodecahedron is built from exactly the cube and the octahedron, and has their
full symmetry:

* its 14 vertices are the 8 cube vertices `(±1, ±1, ±1)` and the 6 octahedron vertices
  `(±2, 0, 0), (0, ±2, 0), (0, 0, ±2)` (`vertices_card`, `vertices_split`);
* each of its 12 faces (outward normal `n`, plane `n · x = 2`) contains exactly 4 vertices
  (2 cube and 2 octahedron vertices, a rhombus), and every vertex lies on the inner side of every
  face plane (`face_vertices_card`, `face_rhombus`, `vertices_inside`);
* Euler's formula `14 − 24 + 12 = 2` holds, with 24 = 12 · 4 / 2 edges (`euler`);
* the 12 face normals are the 12 vectors with two entries `±1` and one `0`, and the set is
  preserved by swapping two coordinates, cycling the coordinates and changing one sign
  (`normals_swap`, `normals_cycle`, `normals_neg`). These three moves generate all 48 signed
  permutations, i.e. the full octahedral group `O_h`.

So once TGS:ATE uses the dodecahedron that actually fills space, its cell has the same `O_h`
symmetry, and the same cube and octahedron, that IT³ privileges. The golden-ratio dodecahedron
has icosahedral symmetry instead, and does not fill space.
-/

@[expose] public section

namespace RhombicSymmetry

/-- Integer points of `ℤ³`. -/
abbrev P := ℤ × ℤ × ℤ

/-- Dot product. -/
def dot (a b : P) : ℤ := a.1 * b.1 + a.2.1 * b.2.1 + a.2.2 * b.2.2

/-- The 12 face normals (as in `CSTGeometry.rhombicNormals`). -/
def normals : Finset P :=
  {(1, 1, 0), (1, -1, 0), (-1, 1, 0), (-1, -1, 0), (1, 0, 1), (1, 0, -1), (-1, 0, 1),
    (-1, 0, -1), (0, 1, 1), (0, 1, -1), (0, -1, 1), (0, -1, -1)}

/-- The 8 cube vertices. -/
def cube : Finset P :=
  {(1, 1, 1), (1, 1, -1), (1, -1, 1), (1, -1, -1), (-1, 1, 1), (-1, 1, -1), (-1, -1, 1),
    (-1, -1, -1)}

/-- The 6 octahedron vertices. -/
def octa : Finset P := {(2, 0, 0), (-2, 0, 0), (0, 2, 0), (0, -2, 0), (0, 0, 2), (0, 0, -2)}

/-- The vertices of the rhombic dodecahedron. -/
def vertices : Finset P := cube ∪ octa

/-- The vertices on the face with normal `n`. -/
def faceVertices (n : P) : Finset P := vertices.filter (fun v => dot n v = 2)

theorem vertices_card : cube.card = 8 ∧ octa.card = 6 ∧ vertices.card = 14 := by decide

theorem vertices_split : Disjoint cube octa := by decide

theorem normals_card : normals.card = 12 := by decide

/-- Every vertex is on the inner side of every face plane. -/
theorem vertices_inside : ∀ n ∈ normals, ∀ v ∈ vertices, dot n v ≤ 2 := by decide

/-- Each face holds exactly four vertices. -/
theorem face_vertices_card : ∀ n ∈ normals, (faceVertices n).card = 4 := by decide

/-- Each face is a rhombus: two cube vertices and two octahedron vertices. -/
theorem face_rhombus :
    ∀ n ∈ normals, ((faceVertices n).filter (· ∈ cube)).card = 2 ∧
      ((faceVertices n).filter (· ∈ octa)).card = 2 := by decide

/-- Every vertex lies on some face. -/
theorem every_vertex_on_a_face : ∀ v ∈ vertices, ∃ n ∈ normals, dot n v = 2 := by decide

/-- Euler's formula: 14 vertices, 12 · 4 / 2 = 24 edges, 12 faces. -/
theorem euler : (14 : ℤ) - 12 * 4 / 2 + 12 = 2 := by norm_num

/-- The normals are exactly the vectors in `{−1, 0, 1}³` with exactly one zero entry. -/
theorem normals_eq : normals = ((Finset.Icc (-1 : ℤ) 1) ×ˢ (Finset.Icc (-1 : ℤ) 1) ×ˢ
    (Finset.Icc (-1 : ℤ) 1)).filter
      (fun v => ([v.1, v.2.1, v.2.2].filter (· = 0)).length = 1) := by decide

/-- Swapping the first two coordinates preserves the normals. -/
theorem normals_swap : ∀ v ∈ normals, (v.2.1, v.1, v.2.2) ∈ normals := by decide

/-- Cycling the coordinates preserves the normals. -/
theorem normals_cycle : ∀ v ∈ normals, (v.2.1, v.2.2, v.1) ∈ normals := by decide

/-- Changing the sign of the first coordinate preserves the normals. -/
theorem normals_neg : ∀ v ∈ normals, (-v.1, v.2.1, v.2.2) ∈ normals := by decide

/-- The same three moves preserve the vertex set (so they are symmetries of the solid). -/
theorem vertices_symm : ∀ v ∈ vertices, (v.2.1, v.1, v.2.2) ∈ vertices ∧
    (v.2.1, v.2.2, v.1) ∈ vertices ∧ (-v.1, v.2.1, v.2.2) ∈ vertices := by decide

end RhombicSymmetry
