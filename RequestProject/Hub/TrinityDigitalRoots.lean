module

public import RequestProject.Hub.CubyNumerics

/-!
# "3, 6, 9 Is All You Need" — the core digital-root claims

Source: Mike DuPont's paper `tesla369` ("3, 6, 9 Is All You Need"). These are the claims
that tie directly to the TGS:ATE "digital root 9" and 144 statements, re-proved here from the
same `digitalRoot` used in `CubyNumerics` (`digitalRoot n = 1 + (n - 1) % 9` for `n > 0`).

* `trinity_iff_three_dvd` — for `n > 0`, the digital root lies in `{3, 6, 9}` exactly when
  `3 ∣ n`.
* `trinity_add`, `trinity_mul` — the trinity is closed under addition and absorbs
  multiplication by any positive number.
* `doubling_orbit`, `doubling_misses_trinity` — the digital roots of `2^k` cycle through
  `1, 2, 4, 8, 7, 5` with period 6 and never hit `{3, 6, 9}`.
* `prime_mod_six` — every prime above 3 is `1` or `5` mod 6.
* `fib_digitalRoot_period`, `fib_trinity_iff` — the digital roots of the Fibonacci numbers
  repeat with period 24, and (for `n > 0`) land in `{3, 6, 9}` exactly when `4 ∣ n`.
* `archimedes_bounds` — `223/71 < π < 22/7`.

The paper's material on Hecke operators, the discriminant `Δ` and the Monster group is not
re-checked here.
-/

@[expose] public section

namespace TrinityDigitalRoots

open CubyNumerics

/-- The "trinity" of digital roots. -/
def Trinity (d : ℕ) : Prop := d = 3 ∨ d = 6 ∨ d = 9

instance : DecidablePred Trinity := fun d => by unfold Trinity; infer_instance

lemma digitalRoot_pos {n : ℕ} (hn : 0 < n) : digitalRoot n = 1 + (n - 1) % 9 := by
  simp [digitalRoot, hn.ne']

/-- For positive `n`, the digital root is in `{3, 6, 9}` exactly when `3 ∣ n`. -/
theorem trinity_iff_three_dvd {n : ℕ} (hn : 0 < n) : Trinity (digitalRoot n) ↔ 3 ∣ n := by
  rw [digitalRoot_pos hn, Trinity]
  omega

/-- The digital roots of the positive multiples of 3 are exactly 3, 6 and 9. -/
theorem trinity_range :
    {d | ∃ n, 0 < n ∧ 3 ∣ n ∧ digitalRoot n = d} = {3, 6, 9} := by
  ext d
  simp only [Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff]
  constructor
  · rintro ⟨n, hn, h3, rfl⟩
    exact (trinity_iff_three_dvd hn).2 h3
  · rintro (rfl | rfl | rfl)
    · exact ⟨3, by decide, by decide, by decide⟩
    · exact ⟨6, by decide, by decide, by decide⟩
    · exact ⟨9, by decide, by decide, by decide⟩

/-- Adding two numbers whose digital roots are in the trinity stays in the trinity. -/
theorem trinity_add {a b : ℕ} (ha : 0 < a) (hb : 0 < b)
    (hA : Trinity (digitalRoot a)) (hB : Trinity (digitalRoot b)) :
    Trinity (digitalRoot (a + b)) := by
  rw [trinity_iff_three_dvd ha] at hA
  rw [trinity_iff_three_dvd hb] at hB
  exact (trinity_iff_three_dvd (by omega)).2 (dvd_add hA hB)

/-- Multiplying a number in the trinity by any positive number stays in the trinity. -/
theorem trinity_mul {a b : ℕ} (ha : 0 < a) (hb : 0 < b) (hA : Trinity (digitalRoot a)) :
    Trinity (digitalRoot (a * b)) := by
  rw [trinity_iff_three_dvd ha] at hA
  exact (trinity_iff_three_dvd (Nat.mul_pos ha hb)).2 (dvd_mul_of_dvd_left hA b)

/-- The doubling orbit of digital roots. -/
def doublingCycle : List ℕ := [1, 2, 4, 8, 7, 5]

/-- The digital root of `2^k` is the `k mod 6`-th entry of `1, 2, 4, 8, 7, 5`. -/
theorem doubling_orbit (k : ℕ) : digitalRoot (2 ^ k) = doublingCycle[k % 6]! := by
  have hpos : 0 < 2 ^ k := by positivity
  rw [digitalRoot_pos hpos]
  have hm : 2 ^ k % 9 = 2 ^ (k % 6) % 9 := by
    conv_lhs => rw [← Nat.div_add_mod k 6, pow_add, pow_mul]
    rw [Nat.mul_mod, Nat.pow_mod]
    norm_num
  have hk : k % 6 < 6 := Nat.mod_lt _ (by norm_num)
  generalize k % 6 = r at hm hk ⊢
  generalize 2 ^ k = c at *
  interval_cases r <;> simp [doublingCycle] at hm ⊢ <;> omega

/-- The doubling orbit never reaches 3, 6 or 9. -/
theorem doubling_misses_trinity (k : ℕ) : ¬ Trinity (digitalRoot (2 ^ k)) := by
  rw [trinity_iff_three_dvd (by positivity)]
  intro h
  have := (Nat.Prime.dvd_of_dvd_pow Nat.prime_three h)
  omega

/-- Every prime above 3 is `1` or `5` mod 6. -/
theorem prime_mod_six {p : ℕ} (hp : p.Prime) (h3 : 3 < p) : p % 6 = 1 ∨ p % 6 = 5 := by
  have h2 : ¬ 2 ∣ p := fun h => by
    have := (Nat.prime_dvd_prime_iff_eq Nat.prime_two hp).1 h; omega
  have h3' : ¬ 3 ∣ p := fun h => by
    have := (Nat.prime_dvd_prime_iff_eq Nat.prime_three hp).1 h; omega
  omega

/-- Fibonacci numbers are periodic mod 9 with period 24. -/
lemma fib_mod_nine_period (n : ℕ) : Nat.fib (n + 24) % 9 = Nat.fib n % 9 := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    rcases Nat.lt_or_ge n 2 with hn | hn
    · interval_cases n <;> decide
    · obtain ⟨m, rfl⟩ : ∃ m, n = m + 2 := ⟨n - 2, by omega⟩
      have h1 := ih m (by omega)
      have h2 := ih (m + 1) (by omega)
      have e1 : Nat.fib (m + 2 + 24) = Nat.fib (m + 24) + Nat.fib (m + 1 + 24) := by
        rw [show m + 2 + 24 = (m + 24) + 2 by omega, Nat.fib_add_two,
          show m + 24 + 1 = m + 1 + 24 by omega]
      have e2 := Nat.fib_add_two (n := m)
      omega

lemma fib_mod_nine (n : ℕ) : Nat.fib n % 9 = Nat.fib (n % 24) % 9 := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    rcases Nat.lt_or_ge n 24 with hn | hn
    · rw [Nat.mod_eq_of_lt hn]
    · have := ih (n - 24) (by omega)
      rw [show n = (n - 24) + 24 by omega, fib_mod_nine_period, this]
      congr 2
      omega

/-- The digital roots of the Fibonacci numbers repeat with period 24. -/
theorem fib_digitalRoot_period (n : ℕ) (hn : 0 < n) :
    digitalRoot (Nat.fib (n + 24)) = digitalRoot (Nat.fib n) := by
  have hf : 0 < Nat.fib n := Nat.fib_pos.2 hn
  have hf' : 0 < Nat.fib (n + 24) := Nat.fib_pos.2 (by omega)
  rw [digitalRoot_pos hf, digitalRoot_pos hf']
  have := fib_mod_nine_period n
  omega

/-- For `n > 0`, the digital root of `fib n` is 3, 6 or 9 exactly when `4 ∣ n`. -/
theorem fib_trinity_iff (n : ℕ) (hn : 0 < n) : Trinity (digitalRoot (Nat.fib n)) ↔ 4 ∣ n := by
  rw [trinity_iff_three_dvd (Nat.fib_pos.2 hn)]
  have h := fib_mod_nine n
  have h3 : 3 ∣ Nat.fib n ↔ 3 ∣ Nat.fib (n % 24) % 9 := by omega
  rw [h3, show (4 ∣ n) ↔ 4 ∣ n % 24 by omega]
  have : n % 24 < 24 := Nat.mod_lt _ (by norm_num)
  interval_cases n % 24 <;> decide

/-- Archimedes' bounds: `223/71 < π < 22/7`. -/
theorem archimedes_bounds : (223 / 71 : ℝ) < Real.pi ∧ Real.pi < 22 / 7 := by
  constructor
  · linarith [Real.pi_gt_d4]
  · linarith [Real.pi_lt_d4]

end TrinityDigitalRoots
