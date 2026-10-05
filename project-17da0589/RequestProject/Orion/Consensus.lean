module

public import Mathlib

/-!
# Consensus texture: the effective number of independent agents

`n` agents whose errors have equal pairwise correlation `ρ ∈ [0, 1]` carry the information
of `n_eff = n / (1 + (n - 1) ρ)` independent agents.  This is the quantity behind the
`ConsensusTexture` alert proposed in `ROUND_THREE_RESPONSES.md`.

* `sum_corr_matrix`, `variance_of_mean` — the derivation: the variance of the mean of `n`
  unit-variance signals with pairwise correlation `ρ` is `(1 + (n-1)ρ)/n = 1 / n_eff`;
* `neff_full_corr` — fully correlated agents (`ρ = 1`) are worth exactly one agent, however
  many agree (`ModelAgreement ≠ IndependentEvidence`);
* `neff_indep` — independent agents (`ρ = 0`) are worth `n`;
* `one_le_neff`, `neff_le` — always `1 ≤ n_eff ≤ n`;
* `neff_antitone` — more correlation, less evidence;
* `texture_iff` — the alert `n_eff < 2` fires exactly when `ρ > (n-2)/(2(n-1))`.
-/

@[expose] public section

namespace Orion.Consensus

open Finset

/-- Effective number of independent agents. -/
noncomputable def neff (n : ℕ) (ρ : ℝ) : ℝ := n / (1 + (n - 1) * ρ)

/-- Sum of the entries of the equicorrelation matrix. -/
theorem sum_corr_matrix (n : ℕ) (ρ : ℝ) :
    ∑ i : Fin n, ∑ j : Fin n, (if i = j then (1 : ℝ) else ρ) = n + n * (n - 1) * ρ := by
  have h : ∀ i : Fin n, ∑ j : Fin n, (if i = j then (1 : ℝ) else ρ) = 1 + (n - 1) * ρ := by
    intro i
    rw [← Finset.sum_erase_add _ _ (Finset.mem_univ i), if_pos rfl,
      Finset.sum_congr rfl (fun j hj => if_neg (Finset.ne_of_mem_erase hj).symm),
      Finset.sum_const, Finset.card_erase_of_mem (Finset.mem_univ i), Finset.card_univ,
      Fintype.card_fin, nsmul_eq_mul]
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · exact absurd i.2 (by simp)
    · rw [Nat.cast_sub hn]; push_cast; ring
  rw [Finset.sum_congr rfl (fun i _ => h i), Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul]
  ring

/-- The variance of the mean of `n` unit-variance signals with pairwise correlation `ρ`
equals `1 / n_eff`. -/
theorem variance_of_mean {n : ℕ} (hn : 0 < n) (ρ : ℝ) :
    (1 / (n : ℝ) ^ 2) * ∑ i : Fin n, ∑ j : Fin n, (if i = j then (1 : ℝ) else ρ) =
      1 / neff n ρ := by
  rw [sum_corr_matrix, neff, one_div_div]
  have hn' : (0 : ℝ) < n := by exact_mod_cast hn
  field_simp

/-- `ρ = 1`: any number of perfectly correlated agents is worth one. -/
theorem neff_full_corr {n : ℕ} (hn : 0 < n) : neff n 1 = 1 := by
  have hn' : (0 : ℝ) < n := by exact_mod_cast hn
  unfold neff
  rw [mul_one, add_sub_cancel, div_self hn'.ne']

/-- `ρ = 0`: independent agents are worth `n`. -/
theorem neff_indep (n : ℕ) : neff n 0 = n := by simp [neff]

lemma denom_pos {n : ℕ} (hn : 0 < n) {ρ : ℝ} (hρ : 0 ≤ ρ) : 0 < 1 + ((n : ℝ) - 1) * ρ := by
  have : (1 : ℝ) ≤ n := by exact_mod_cast hn
  nlinarith

/-- `n_eff ≤ n`. -/
theorem neff_le {n : ℕ} (hn : 0 < n) {ρ : ℝ} (hρ : 0 ≤ ρ) : neff n ρ ≤ n := by
  have h1 : (1 : ℝ) ≤ n := by exact_mod_cast hn
  unfold neff
  rw [div_le_iff₀ (denom_pos hn hρ)]
  nlinarith [mul_nonneg (mul_nonneg (by linarith : (0 : ℝ) ≤ n) (sub_nonneg.2 h1)) hρ]

/-- `1 ≤ n_eff`. -/
theorem one_le_neff {n : ℕ} (hn : 0 < n) {ρ : ℝ} (hρ0 : 0 ≤ ρ) (hρ1 : ρ ≤ 1) :
    1 ≤ neff n ρ := by
  have h1 : (1 : ℝ) ≤ n := by exact_mod_cast hn
  unfold neff
  rw [le_div_iff₀ (denom_pos hn hρ0)]
  nlinarith

/-- More correlation means fewer effective agents. -/
theorem neff_antitone {n : ℕ} (hn : 0 < n) {ρ σ : ℝ} (hρ : 0 ≤ ρ) (hρσ : ρ ≤ σ) :
    neff n σ ≤ neff n ρ := by
  have h1 : (0 : ℝ) ≤ n - 1 := by
    have : (1 : ℝ) ≤ n := by exact_mod_cast hn
    linarith
  unfold neff
  apply div_le_div_of_nonneg_left (by positivity) (denom_pos hn hρ)
  nlinarith

/-- The `ConsensusTexture` alert: fewer than two effective independent agents. -/
def Texture (n : ℕ) (ρ : ℝ) : Prop := neff n ρ < 2

/-- For `n ≥ 2` agents, the alert fires exactly when `ρ > (n - 2) / (2 (n - 1))`. -/
theorem texture_iff {n : ℕ} (hn : 2 ≤ n) {ρ : ℝ} (hρ : 0 ≤ ρ) :
    Texture n ρ ↔ ((n : ℝ) - 2) / (2 * ((n : ℝ) - 1)) < ρ := by
  have h2 : (2 : ℝ) ≤ n := by exact_mod_cast hn
  have hd : (0 : ℝ) < 2 * ((n : ℝ) - 1) := by linarith
  unfold Texture neff
  rw [div_lt_iff₀ (denom_pos (by omega) hρ), div_lt_iff₀ hd]
  constructor <;> intro h <;> nlinarith

end Orion.Consensus
