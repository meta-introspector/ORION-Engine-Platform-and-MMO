module

public import Mathlib

/-!
# Re-checking the Cl(8,0) generators on bott.cicada71.net (Mike DuPont)

The page builds eight 16×16 signed-permutation matrices as four-fold Kronecker products of
`I`, `X`, `Z` and `J = XZ`, using the index table `STR8` and the tables `qperm`, `qsign`
published in its source, with `bit(r, k) = (r >> (3 - k)) & 1`. It claims they generate the
Clifford algebra Cl(8,0): each squares to the identity and distinct generators anticommute.

This file transcribes those tables and checks the claim on the actual integer matrices:
`gen_sq` (every `eᵢ² = 1`) and `gen_anticomm` (`eᵢ eⱼ = - eⱼ eᵢ` for `i ≠ j`).
-/

@[expose] public section

namespace BottCliffordCheck

/-- `STR8` from the page: which of `I, X, Z, J` (0, 1, 2, 3) sits in each tensor slot. -/
def STR8 : List (List ℕ) :=
  [[0,0,0,1],[0,0,0,2],[0,0,3,3],[0,3,1,3],[1,3,2,3],[2,3,2,3],[3,0,2,3],[3,1,1,3]]

/-- `qperm[g][b]`: the column hit by row `b` of the 2×2 factor `g`. -/
def qperm : List (List ℕ) := [[0,1],[1,0],[0,1],[1,0]]

/-- `qsign[g][b]`: the sign of that entry. -/
def qsign : List (List ℤ) := [[1,1],[1,1],[1,-1],[-1,1]]

def bit (r k : ℕ) : ℕ := (r >>> (3 - k)) &&& 1

/-- Column hit by row `r` in generator `i`. -/
def col (i r : ℕ) : ℕ :=
  (List.range 4).foldl (fun c k => 2 * c + (qperm[(STR8[i]!)[k]!]!)[bit r k]!) 0

/-- Sign of that entry. -/
def sgn (i r : ℕ) : ℤ :=
  (List.range 4).foldl (fun s k => s * (qsign[(STR8[i]!)[k]!]!)[bit r k]!) 1

/-- The `i`-th generator as a 16×16 integer matrix. -/
def gen (i : Fin 8) : Matrix (Fin 16) (Fin 16) ℤ :=
  Matrix.of fun r c => if col i r = c.val then sgn i r else 0

/-- Every generator squares to the identity. -/
theorem gen_sq : ∀ i : Fin 8, gen i * gen i = 1 := by
  native_decide

/-- Distinct generators anticommute. -/
theorem gen_anticomm : ∀ i j : Fin 8, i ≠ j → gen i * gen j = - (gen j * gen i) := by
  native_decide

/-- Together: the eight matrices satisfy the Cl(8,0) relations `eᵢeⱼ + eⱼeᵢ = 2δᵢⱼ`. -/
theorem clifford_relations (i j : Fin 8) :
    gen i * gen j + gen j * gen i = if i = j then 2 else 0 := by
  split_ifs with h
  · subst h; rw [gen_sq]; norm_num [two_smul, one_add_one_eq_two]
  · rw [gen_anticomm i j h]; abel

end BottCliffordCheck
