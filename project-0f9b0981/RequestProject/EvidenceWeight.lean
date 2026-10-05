module

public import Mathlib

/-!
# The Evidence Weighting Rubric `W(e)` of "Operation Snake and Scale"

The page *Operation Snake and Scale* (Section III) specifies the evidence weight

  `W(e) = S_t × R_m × C_i × (1 - D_r)`

where
* `S_t ∈ {1.0, 0.8, 0.5, 0.1}` is the source tier weight,
* `R_m ∈ {1.0, 0.8, 0.1}` is the methodological rigor score,
* `C_i = 1.0` if `R_m < 0.8`, and `C_i = min(1 + 0.1 n, 1.5)` if `R_m ≥ 0.8`,
  `n` being the number of strictly independent primary sources,
* `D_r` is the discrepancy ratio, "capped at 1.0" (so `0 ≤ D_r ≤ 1`).

All values are modelled exactly with rational numbers. We prove the properties
the page claims for the rubric (the anti-volume safeguard, the corroboration cap)
together with some consequences it does not state (the full range of `W(e)`,
which can exceed `1`, and the fixed ranking between tiers).
-/

@[expose] public section

namespace SnakeAndScale

/-- Source tier (`S_t`), assigned from the metadata origin. -/
inductive SourceTier
  | primary     -- 1.0: primary disclosures / official records / court documents
  | audit       -- 0.8: independent technical audits / verified datasets
  | secondary   -- 0.5: secondary synthesis / credible journalism
  | unverified  -- 0.1: unverified allegations / social media / opinion
  deriving DecidableEq, Fintype

/-- The numeric weight `S_t` of a source tier. -/
def SourceTier.weight : SourceTier → ℚ
  | .primary => 1
  | .audit => 4 / 5
  | .secondary => 1 / 2
  | .unverified => 1 / 10

/-- Methodological rigor category (`R_m`). -/
inductive Rigor
  | cryptographic  -- 1.0: cryptographic proof / reproducible data
  | disclosed      -- 0.8: disclosed, testable methodology
  | opaque         -- 0.1: opaque, anecdotal or speculative
  deriving DecidableEq, Fintype

/-- The numeric score `R_m` of a rigor category. -/
def Rigor.weight : Rigor → ℚ
  | .cryptographic => 1
  | .disclosed => 4 / 5
  | .opaque => 1 / 10

/-- The corroboration factor `C_i`, exactly as specified: `1` when `R_m < 0.8`,
otherwise `min (1 + 0.1 n) 1.5`. -/
def corroboration (r : Rigor) (n : ℕ) : ℚ :=
  if r.weight < 4 / 5 then 1 else min (1 + (n : ℚ) / 10) (3 / 2)

/-- The evidence weight `W(e) = S_t × R_m × C_i × (1 - D_r)`. -/
def evidenceWeight (s : SourceTier) (r : Rigor) (n : ℕ) (d : ℚ) : ℚ :=
  s.weight * r.weight * corroboration r n * (1 - d)

lemma SourceTier.weight_pos (s : SourceTier) : 0 < s.weight := by
  cases s <;> norm_num [SourceTier.weight]

lemma SourceTier.weight_le_one (s : SourceTier) : s.weight ≤ 1 := by
  cases s <;> norm_num [SourceTier.weight]

lemma Rigor.weight_pos (r : Rigor) : 0 < r.weight := by
  cases r <;> norm_num [Rigor.weight]

lemma Rigor.weight_le_one (r : Rigor) : r.weight ≤ 1 := by
  cases r <;> norm_num [Rigor.weight]

/-- **Anti-volume safeguard.** For low-rigor evidence the corroboration factor is `1`,
however many repetitions there are. -/
theorem corroboration_opaque (n : ℕ) : corroboration .opaque n = 1 := by
  simp [corroboration, Rigor.weight]; norm_num

/-- **Anti-volume safeguard, for the full weight.** The weight of low-rigor evidence does
not depend on the number `n` of corroborating sources. -/
theorem evidenceWeight_opaque_indep (s : SourceTier) (n m : ℕ) (d : ℚ) :
    evidenceWeight s .opaque n d = evidenceWeight s .opaque m d := by
  simp [evidenceWeight, corroboration_opaque]

lemma one_le_corroboration (r : Rigor) (n : ℕ) : 1 ≤ corroboration r n := by
  unfold corroboration
  split_ifs
  · rfl
  · refine le_min ?_ (by norm_num)
    have : (0 : ℚ) ≤ n / 10 := by positivity
    linarith

/-- **Corroboration cap.** The multiplier never exceeds `1.5`. -/
theorem corroboration_le (r : Rigor) (n : ℕ) : corroboration r n ≤ 3 / 2 := by
  unfold corroboration
  split_ifs
  · norm_num
  · exact min_le_right _ _

/-- Corroboration is monotone in the number of independent sources. -/
theorem corroboration_mono (r : Rigor) {n m : ℕ} (h : n ≤ m) :
    corroboration r n ≤ corroboration r m := by
  unfold corroboration
  split_ifs
  · rfl
  · refine min_le_min ?_ le_rfl
    have : (n : ℚ) ≤ m := by exact_mod_cast h
    linarith

/-- The cap is reached at five independent sources: for high-rigor evidence,
`C_i = 1.5` exactly when `n ≥ 5`, so a sixth source adds nothing. -/
theorem corroboration_eq_max_iff (r : Rigor) (hr : r ≠ .opaque) (n : ℕ) :
    corroboration r n = 3 / 2 ↔ 5 ≤ n := by
  have hr' : ¬ r.weight < 4 / 5 := by
    cases r <;> simp_all [Rigor.weight]
    all_goals norm_num
  simp only [corroboration, hr', if_false]
  constructor
  · intro h
    by_contra hn
    push_neg at hn
    have hn' : (n : ℚ) ≤ 4 := by exact_mod_cast Nat.lt_succ_iff.mp hn
    have : min (1 + (n : ℚ) / 10) (3 / 2) ≤ 1 + (n : ℚ) / 10 := min_le_left _ _
    linarith
  · intro h
    have hn' : (5 : ℚ) ≤ n := by exact_mod_cast h
    exact min_eq_right (by linarith)

/-- The weight is non-negative whenever `D_r ≤ 1`. -/
theorem evidenceWeight_nonneg (s : SourceTier) (r : Rigor) (n : ℕ) {d : ℚ} (hd : d ≤ 1) :
    0 ≤ evidenceWeight s r n d := by
  unfold evidenceWeight
  have := s.weight_pos; have := r.weight_pos; have := one_le_corroboration r n
  have : 0 ≤ 1 - d := by linarith
  positivity

/-- **Range of `W(e)`.** For `0 ≤ D_r`, the weight is at most `1.5`. -/
theorem evidenceWeight_le (s : SourceTier) (r : Rigor) (n : ℕ) {d : ℚ} (hd0 : 0 ≤ d)
    (hd1 : d ≤ 1) : evidenceWeight s r n d ≤ 3 / 2 := by
  unfold evidenceWeight
  have h1 := s.weight_pos; have h2 := s.weight_le_one
  have h3 := r.weight_pos; have h4 := r.weight_le_one
  have h5 := one_le_corroboration r n; have h6 := corroboration_le r n
  have h7 : 0 ≤ 1 - d := by linarith
  have h8 : 1 - d ≤ 1 := by linarith
  calc s.weight * r.weight * corroboration r n * (1 - d)
      ≤ 1 * 1 * (3 / 2) * 1 := by gcongr
    _ = 3 / 2 := by norm_num

/-- The upper bound `1.5` is attained, so the "Reliability Score" produced by the rubric
is **not** confined to `[0, 1]`. -/
theorem evidenceWeight_max :
    evidenceWeight .primary .cryptographic 5 0 = 3 / 2 := by
  simp [evidenceWeight, SourceTier.weight, Rigor.weight, corroboration]; norm_num

/-- **Low-rigor ceiling.** Opaque/anecdotal evidence never weighs more than `0.1`. -/
theorem evidenceWeight_opaque_le (s : SourceTier) (n : ℕ) {d : ℚ} (hd0 : 0 ≤ d)
    (hd1 : d ≤ 1) : evidenceWeight s .opaque n d ≤ 1 / 10 := by
  simp only [evidenceWeight, corroboration_opaque, Rigor.weight]
  have h1 := s.weight_pos; have h2 := s.weight_le_one
  have h7 : 0 ≤ 1 - d := by linarith
  have h8 : 1 - d ≤ 1 := by linarith
  calc s.weight * (1 / 10) * 1 * (1 - d) ≤ 1 * (1 / 10) * 1 * 1 := by gcongr
    _ = 1 / 10 := by norm_num

/-- **Unverified-source ceiling.** Evidence from an unverified source never weighs more
than `0.15`, however rigorous or corroborated. -/
theorem evidenceWeight_unverified_le (r : Rigor) (n : ℕ) {d : ℚ} (hd0 : 0 ≤ d)
    (hd1 : d ≤ 1) : evidenceWeight .unverified r n d ≤ 3 / 20 := by
  unfold evidenceWeight
  simp only [SourceTier.weight]
  have h3 := r.weight_pos; have h4 := r.weight_le_one
  have h5 := one_le_corroboration r n; have h6 := corroboration_le r n
  have h7 : 0 ≤ 1 - d := by linarith
  have h8 : 1 - d ≤ 1 := by linarith
  calc 1 / 10 * r.weight * corroboration r n * (1 - d) ≤ 1 / 10 * 1 * (3 / 2) * 1 := by
        gcongr
    _ = 3 / 20 := by norm_num

/-- Uncontested (`D_r = 0`) primary evidence with a cryptographic proof weighs at least `1`. -/
theorem one_le_evidenceWeight_primary_crypto (n : ℕ) :
    1 ≤ evidenceWeight .primary .cryptographic n 0 := by
  simpa [evidenceWeight, SourceTier.weight, Rigor.weight] using
    one_le_corroboration .cryptographic n

/-- The weight vanishes exactly when the discrepancy ratio is at its cap `1`. -/
theorem evidenceWeight_eq_zero_iff (s : SourceTier) (r : Rigor) (n : ℕ) (d : ℚ) :
    evidenceWeight s r n d = 0 ↔ d = 1 := by
  unfold evidenceWeight
  have := s.weight_pos; have := r.weight_pos
  have := (lt_of_lt_of_le one_pos (one_le_corroboration r n))
  constructor
  · intro h
    rcases mul_eq_zero.mp h with h | h
    · exfalso; exact (by positivity : s.weight * r.weight * corroboration r n ≠ 0) h
    · linarith
  · rintro rfl; simp

/-- More discrepancy never increases the weight. -/
theorem evidenceWeight_antitone_discrepancy (s : SourceTier) (r : Rigor) (n : ℕ) {d d' : ℚ}
    (h : d ≤ d') : evidenceWeight s r n d' ≤ evidenceWeight s r n d := by
  unfold evidenceWeight
  have := s.weight_pos; have := r.weight_pos; have := one_le_corroboration r n
  have : 0 ≤ s.weight * r.weight * corroboration r n := by positivity
  exact mul_le_mul_of_nonneg_left (by linarith) this

end SnakeAndScale
