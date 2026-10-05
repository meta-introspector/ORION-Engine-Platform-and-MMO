module

public import Mathlib

/-!
# Checking the numerical claims in the source texts

The source texts make several exact arithmetic claims (cipher values, polyhedron
counts, gematria, "primes vs. octaves").  This file checks each one in Lean.
In two places the check also shows *how much* a claim can support:

* `tesla_cipher_digital_root` holds for **every** positive integer multiplied by
  any positive multiple of 3, so the "×6 cipher reduces every letter to 3, 6 or 9"
  observation says nothing about English (or any particular alphabet).
* `framework_constants_cover_alphabet_sizes` shows that every integer from 20
  to 36 is a sum of at most two of the constants used in the corpus, so a
  post-hoc match between an alphabet size and a geometric count carries no
  evidential weight unless the rule was fixed in advance (the corpus's own
  "Blind Mapping Test").
-/

@[expose] public section

namespace Friction

/-! ## Digit sums and the "×6 / Tesla cipher" -/

/-- Base-10 digit sum. -/
def digitSum (n : ℕ) : ℕ := (Nat.digits 10 n).sum

/-- One step of "reduce a number by summing its digits". -/
def ReducesTo (a b : ℕ) : Prop := b = digitSum a

lemma digitSum_modEq (n : ℕ) : digitSum n ≡ n [MOD 9] :=
  (Nat.modEq_nine_digits_sum n).symm

lemma digitSum_pos {n : ℕ} (hn : 0 < n) : 0 < digitSum n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    unfold digitSum
    rw [Nat.digits_def' (by norm_num) hn, List.sum_cons]
    by_cases h : n % 10 = 0
    · have h1 : 0 < n / 10 := by omega
      have := ih (n / 10) (by omega) h1
      unfold digitSum at this
      omega
    · omega

/-- Repeated digit sums preserve the residue mod 9 and positivity. -/
lemma reduces_invariant {a b : ℕ} (h : Relation.ReflTransGen ReducesTo a b) :
    b ≡ a [MOD 9] ∧ (0 < a → 0 < b) := by
  induction h with
  | refl => exact ⟨Nat.ModEq.refl _, id⟩
  | tail _ hbc ih =>
    rw [hbc]
    exact ⟨(digitSum_modEq _).trans ih.1, fun ha => digitSum_pos (ih.2 ha)⟩

/-- **The "×6 cipher" claim, in full generality.**  For *any* positive multiplier `m`
divisible by 3 and *any* positive integer `n` (not just the 26 letter positions),
every single-digit number reached from `m * n` by repeatedly summing digits is
3, 6 or 9.  So the property comes from the multiplier, not from the English
alphabet. -/
theorem tesla_cipher_digital_root (m n r : ℕ) (hm : 3 ∣ m) (hmpos : 0 < m) (hn : 0 < n)
    (hr : Relation.ReflTransGen ReducesTo (m * n) r) (hr10 : r < 10) :
    r = 3 ∨ r = 6 ∨ r = 9 := by
  obtain ⟨hmod, hpos⟩ := reduces_invariant hr
  have hp : 0 < r := hpos (Nat.mul_pos hmpos hn)
  have h3 : 3 ∣ m * n := Dvd.dvd.mul_right hm n
  unfold Nat.ModEq at hmod
  omega

/-- The "Gaia factor": G is the 7th letter and 7 × 6 = 42. -/
theorem gaia_factor : 7 * 6 = 42 := by norm_num

/-! ## Character-set and dodecahedron counts -/

/-- 26 uppercase + 26 lowercase + 10 digits = 62 = 12 faces + 20 vertices + 30 edges. -/
theorem latin62_eq_dodecahedron : 26 + 26 + 10 = 62 ∧ 12 + 20 + 30 = 62 := by norm_num

/-- Twelve pentagons have 60 corners; three meet at each vertex, giving 20 vertices;
the counts satisfy Euler's formula `V - E + F = 2`; and 12 × 12 = 144. -/
theorem dodecahedron_counts :
    12 * 5 = 60 ∧ 60 / 3 = 20 ∧ (20 : ℤ) - 30 + 12 = 2 ∧ 12 * 12 = 144 := by norm_num

/-! ## Gematria of אדם (Adam) -/

/-- Standard Hebrew letter value of Aleph. -/
def aleph : ℕ := 1
/-- Standard Hebrew letter value of Dalet. -/
def dalet : ℕ := 4
/-- Standard Hebrew letter value of Mem. -/
def mem : ℕ := 40

/-- Aleph (1) + Dam (דם = 4 + 40 = 44) = Adam (45). -/
theorem adam_gematria : dalet + mem = 44 ∧ aleph + (dalet + mem) = 45 := by
  decide

/-! ## "Octaves" (powers of two) versus "Primes" -/

/-- The 5:2 container is built from primes. -/
theorem five_two_prime : Nat.Prime 5 ∧ Nat.Prime 2 := by norm_num

/-- An octave `2^k` is prime exactly when `k = 1`: the "fluid doubling" series and
the "rigid prime" series share exactly one member, the number 2 — which is itself
one of the two numbers in the 5:2 container. -/
theorem octave_prime_iff (k : ℕ) : Nat.Prime (2 ^ k) ↔ k = 1 := by
  constructor
  · intro h
    exact ((Nat.Prime.pow_eq_iff h).1 rfl).2
  · rintro rfl
    norm_num

/-! ## The look-elsewhere check for alphabet/geometry matches -/

/-- Constants that the corpus itself uses: 1 (spark/Aleph), 2 (poles), 3 (triad),
4 (tetrahedron vertices/faces), 5 (5:2), 6 (×6 cipher), 8 (Dingir star), 12 (faces),
20 (vertices / icosahedron faces), 24 (cube rotations), 30 (edges), 60 (base 60), 144. -/
def frameworkConstants : List ℕ := [1, 2, 3, 4, 5, 6, 8, 12, 20, 24, 30, 60, 144]

/-- Every integer from 20 to 36 (covering Hebrew 22, Greek 24, Latin 26, Arabic 28,
Russian 33, …) is a framework constant or the sum of two of them.  Hence a match
between an alphabet size and "a geometric count" is expected by chance. -/
theorem framework_constants_cover_alphabet_sizes :
    ∀ n ∈ List.range' 20 17, n ∈ frameworkConstants ∨
      ∃ a ∈ frameworkConstants, ∃ b ∈ frameworkConstants, a + b = n := by
  decide

end Friction
