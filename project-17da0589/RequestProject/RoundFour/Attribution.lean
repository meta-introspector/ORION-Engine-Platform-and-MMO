module

public import Mathlib

/-!
# Royalty and attribution splits

Checks the attribution rules that reached the project this round (see
`ROUND_FOUR_TRIAGE.md`, section B2):

* the platform proposal in *Current ORION Engine Platform 100126*: a "1/(n+1) Progenitor
  Royalty" plus a 60 % / 40 % split each time a blueprint is mutated;
* the golden-ratio split in a third-party attribution briefing (61.8 % / 23.6 % / 14.6 %,
  with each deeper layer receiving `1/φ` of the layer above).

What is proved:

* `chain_split_sum` — a mutation chain where the newest team keeps a fraction `1 - r` and
  passes `r` up the chain always pays out exactly 100 %, for any `r`.  The 60/40 rule is
  the case `r = 3/5` (`sixty_forty_sum`).
* `progenitor_three_overpays`, `progenitor_unbounded` — if "1/(n+1)" is read as "the
  ancestor `n` generations back receives `1/(n+1)` of the revenue", three ancestors already
  receive more than 100 %, and the total grows without bound with the chain length.  (Read
  instead as "`n` contributors each receive `1/(n+1)`", the total is `n/(n+1) < 1`:
  `equal_shares_sum`.)  The rule text must say which is meant.
* `golden_split_sum` — `1/φ + 1/φ³ + 1/φ⁴ = 1`, so the 61.8 / 23.6 / 14.6 split adds up
  exactly.
* `golden_two_layers_exhaust` — a pool `P` paid out with first layer `P/φ` and ratio `1/φ`
  is used up by the first two layers (`P/φ + P/φ² = P`); every further layer overspends.
* `sixty_forty_near_golden` — the 60/40 rule is the golden split rounded: `|3/5 - 1/φ| < 1/50`.
-/

@[expose] public section

namespace RoundFour.Attribution

open Finset

/-- Payout to the team `k` steps above the newest one in a chain of `N` mutations
(`k < N`), when each team keeps `1 - r` of what reaches it and passes `r` upward. -/
def chainShare (r : ℝ) (k : ℕ) : ℝ := (1 - r) * r ^ k

/-- The founder at the top of an `N`-step chain receives what is left, `r ^ N`. -/
def founderShare (r : ℝ) (N : ℕ) : ℝ := r ^ N

/-- A keep-`(1 - r)`, pass-`r` chain always distributes exactly 100 %. -/
theorem chain_split_sum (r : ℝ) (N : ℕ) :
    ∑ k ∈ range N, chainShare r k + founderShare r N = 1 := by
  unfold chainShare founderShare
  rw [← Finset.mul_sum]
  have h := geom_sum_mul r N
  linarith [h]

/-- The 60/40 mutation rule (`r = 3/5`) pays out exactly 100 % for every chain length. -/
theorem sixty_forty_sum (N : ℕ) :
    ∑ k ∈ range N, chainShare (3 / 5) k + founderShare (3 / 5) N = 1 :=
  chain_split_sum _ N

/-- Depth reading of "1/(n+1)": the ancestor `k + 1` generations back receives
`1/(k+2)`.  Total paid to `N` ancestors. -/
noncomputable def progenitorTotal (N : ℕ) : ℝ := ∑ k ∈ range N, 1 / ((k : ℝ) + 2)

/-- Under the depth reading, three ancestors already receive `13/12 > 100 %`. -/
theorem progenitor_three_overpays : progenitorTotal 3 = 13 / 12 := by
  unfold progenitorTotal
  simp [Finset.sum_range_succ]
  norm_num

/-- Under the depth reading, the total payout grows without bound. -/
theorem progenitor_unbounded (M : ℝ) : ∃ N, M < progenitorTotal N := by
  have h := Real.tendsto_sum_range_one_div_nat_succ_atTop
  obtain ⟨N, hN⟩ := (Filter.tendsto_atTop.mp h (M + 2)).exists
  refine ⟨N, ?_⟩
  have key : ∀ n : ℕ, ∑ k ∈ range (n + 1), 1 / ((k : ℝ) + 1) = 1 + progenitorTotal n := by
    intro n
    unfold progenitorTotal
    rw [Finset.sum_range_succ']
    simp only [Nat.cast_zero, zero_add, div_one, Nat.cast_succ]
    rw [add_comm]
    congr 1
    refine Finset.sum_congr rfl fun k _ => ?_
    ring_nf
  have hmono : ∑ k ∈ range N, 1 / ((k : ℝ) + 1) ≤ ∑ k ∈ range (N + 1), 1 / ((k : ℝ) + 1) := by
    rw [Finset.sum_range_succ]
    have : (0 : ℝ) ≤ 1 / ((N : ℝ) + 1) := by positivity
    linarith
  have := key N
  linarith

/-- Contributor reading of "1/(n+1)": `n` contributors each receive `1/(n+1)`; the total is
`n/(n+1)`, below 100 %. -/
theorem equal_shares_sum (n : ℕ) :
    ∑ _k ∈ range n, (1 : ℝ) / (n + 1) = n / (n + 1) := by
  simp [div_eq_mul_inv]

open Real in
/-- The 61.8 % / 23.6 % / 14.6 % golden split adds up exactly: `1/φ + 1/φ³ + 1/φ⁴ = 1`. -/
theorem golden_split_sum : 1 / goldenRatio + 1 / goldenRatio ^ 3 + 1 / goldenRatio ^ 4 = 1 := by
  have key : ∀ g : ℝ, 0 < g → g ^ 2 = g + 1 → 1 / g + 1 / g ^ 3 + 1 / g ^ 4 = 1 := by
    intro g hg h
    field_simp
    nlinarith [h]
  exact key _ goldenRatio_pos goldenRatio_sq

open Real in
/-- With first layer `P/φ` and ratio `1/φ`, the first two layers already use the whole
pool: `P/φ + P/φ² = P`.  Any third layer overspends. -/
theorem golden_two_layers_exhaust (P : ℝ) :
    P / goldenRatio + P / goldenRatio ^ 2 = P := by
  have key : ∀ g : ℝ, 0 < g → g ^ 2 = g + 1 → P / g + P / g ^ 2 = P := by
    intro g hg h
    field_simp
    rw [h]
  exact key _ goldenRatio_pos goldenRatio_sq

open Real in
/-- The 60/40 rule is the golden split, rounded: `|3/5 - 1/φ| < 1/50`. -/
theorem sixty_forty_near_golden : |(3 / 5 : ℝ) - 1 / goldenRatio| < 1 / 50 := by
  rw [one_div, inv_goldenRatio, goldenConj]
  have h5 : Real.sqrt 5 < 2.237 := by
    rw [Real.sqrt_lt' (by norm_num)]; norm_num
  have h5' : 2.236 < Real.sqrt 5 := by
    rw [Real.lt_sqrt (by norm_num)]; norm_num
  rw [abs_lt]
  constructor <;> nlinarith

end RoundFour.Attribution
