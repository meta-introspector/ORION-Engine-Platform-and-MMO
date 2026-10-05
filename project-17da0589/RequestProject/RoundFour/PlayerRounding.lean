module

public import Mathlib
public import RequestProject.RoundThree.Curation

/-!
# Rounding in the player's favour (designer's ruling, Round Four)

The designer answered the rounding question with "we definitely want the rounding to work in
favour of the player". For anything the player **pays** that means rounding **down**; for
anything the player **receives** it means rounding **up**. This file states that rule and one
consequence the team needs to see before coding it.

* `playerCost_le_exact`, `exact_le_playerPayout`: a player never pays more than the exact
  fraction of a cost and never receives less than the exact fraction of a payout.
* `half_cost_eq_halfDown`, `half_payout_eq_halfUp`: for halving, this is `halfDown` on costs and
  `halfUp` on payouts (from `RoundThreeCuration`). So an orb costing 7 at half price costs 3.
* **Consequence for the 2 % conversion tax.** If the tax is a cost rounded in the player's
  favour, every conversion of 49 or less is tax-free (`small_conversion_untaxed`), any amount
  can be split into such pieces (`exists_untaxed_split`), and splitting never costs more than
  converting in one go (`split_never_costs_more`). So, as stated, the tax can be avoided
  entirely by converting in small pieces. Charging the tax on a running total
  (`runningTax`) closes this: the total charged then doesn't depend on how the amount was
  split (`runningTax_split_invariant`).
* `playerKeep_never_gains`: even with player-favourable rounding, no chain of conversions
  creates currency.
-/

@[expose] public section

namespace RoundFourRounding

open RoundThreeCuration

/-- The player's share of a cost `c` scaled by `num / den`, rounded **down** (in the player's
favour). -/
def playerCost (c num den : ℕ) : ℕ := c * num / den

/-- A payout `p` scaled by `num / den`, rounded **up** (in the player's favour). -/
def playerPayout (p num den : ℕ) : ℕ := (p * num + den - 1) / den

/-- **Never pays more than the exact amount.** -/
theorem playerCost_le_exact (c num den : ℕ) :
    (playerCost c num den : ℚ) ≤ (c * num : ℚ) / den := by
  unfold playerCost
  have := Nat.cast_div_le (α := ℚ) (m := c * num) (n := den)
  simpa using this

/-- **Never receives less than the exact amount.** -/
theorem exact_le_playerPayout (p num den : ℕ) (hd : 0 < den) :
    (p * num : ℚ) / den ≤ (playerPayout p num den : ℚ) := by
  unfold playerPayout
  rw [div_le_iff₀ (by exact_mod_cast hd)]
  have h := Nat.lt_div_mul_add (a := p * num + den - 1) hd
  have h2 : p * num ≤ (p * num + den - 1) / den * den := by omega
  exact_mod_cast h2

/-- The two directions differ by at most one unit. -/
theorem playerCost_le_playerPayout (c num den : ℕ) (hd : 0 < den) :
    playerCost c num den ≤ playerPayout c num den ∧
      playerPayout c num den ≤ playerCost c num den + 1 := by
  unfold playerCost playerPayout
  constructor
  · exact Nat.div_le_div_right (by omega)
  · rw [Nat.div_le_iff_le_mul_add_pred hd]
    have h1 := Nat.div_add_mod (c * num) den
    have h2 := Nat.mod_lt (c * num) hd
    rw [Nat.mul_add, Nat.mul_one]
    generalize den * (c * num / den) = m at *
    generalize c * num = a at *
    omega

/-- Halving a cost in the player's favour is `halfDown`. -/
theorem half_cost_eq_halfDown (c : ℕ) : playerCost c 1 2 = halfDown c := by
  simp [playerCost, halfDown]

/-- Halving a payout in the player's favour is `halfUp`. -/
theorem half_payout_eq_halfUp (p : ℕ) : playerPayout p 1 2 = halfUp p := by
  simp [playerPayout, halfUp]

example : playerCost 7 1 2 = 3 ∧ playerPayout 7 1 2 = 4 := by decide

/-! ## The 2 % conversion tax under player-favourable rounding -/

/-- 2 % tax on a conversion of `x`, rounded down (in the player's favour). -/
def playerTax (x : ℕ) : ℕ := playerCost x 2 100

/-- **Small conversions are tax-free.** Any conversion of 49 or less pays no tax. -/
theorem small_conversion_untaxed (x : ℕ) (hx : x ≤ 49) : playerTax x = 0 := by
  unfold playerTax playerCost; omega

/-- From 50 upwards a single conversion does pay tax. -/
theorem large_conversion_taxed (x : ℕ) (hx : 50 ≤ x) : 0 < playerTax x := by
  unfold playerTax playerCost; omega

/-- **Splitting never costs more** than converting the whole amount at once. -/
theorem split_never_costs_more (l : List ℕ) : (l.map playerTax).sum ≤ playerTax l.sum := by
  induction l with
  | nil => simp [playerTax, playerCost]
  | cons x l ih =>
    simp only [List.map_cons, List.sum_cons]
    unfold playerTax playerCost at *
    calc x * 2 / 100 + (List.map (fun x => x * 2 / 100) l).sum
        ≤ x * 2 / 100 + l.sum * 2 / 100 := by omega
      _ ≤ (x * 2 + l.sum * 2) / 100 := Nat.add_div_le_add_div _ _ _
      _ = (x + l.sum) * 2 / 100 := by ring_nf

/-- **Every amount can be split into tax-free pieces** of at most 49. -/
theorem exists_untaxed_split (T : ℕ) :
    ∃ l : List ℕ, l.sum = T ∧ (∀ x ∈ l, x ≤ 49) ∧ (l.map playerTax).sum = 0 := by
  refine ⟨List.replicate (T / 49) 49 ++ [T % 49], ?_, ?_, ?_⟩
  · simp [List.sum_replicate]; omega
  · intro x hx
    simp only [List.mem_append, List.mem_replicate, List.mem_singleton] at hx
    rcases hx with ⟨-, rfl⟩ | rfl
    · exact le_rfl
    · have := Nat.mod_lt T (show 0 < 49 by norm_num); omega
  · have h1 : ∀ x ∈ List.replicate (T / 49) 49 ++ [T % 49], playerTax x = 0 := by
      intro x hx
      simp only [List.mem_append, List.mem_replicate, List.mem_singleton] at hx
      rcases hx with ⟨-, rfl⟩ | rfl
      · exact small_conversion_untaxed _ le_rfl
      · exact small_conversion_untaxed _ (by have := Nat.mod_lt T (show 0 < 49 by norm_num); omega)
    rw [List.sum_eq_zero]
    intro y hy
    obtain ⟨x, hx, rfl⟩ := List.mem_map.mp hy
    exact h1 x hx

/-- **The fix: tax the running total.** The tax due on a conversion is the tax on everything
converted so far minus what has already been charged. -/
def runningTax (l : List ℕ) : ℕ := playerTax l.sum

/-- With a running total the tax charged depends only on the total converted, never on how it
was split. -/
theorem runningTax_split_invariant (l l' : List ℕ) (h : l.sum = l'.sum) :
    runningTax l = runningTax l' := by
  simp [runningTax, h]

/-- What the player keeps from one conversion. -/
def playerKeep (x : ℕ) : ℕ := x - playerTax x

/-- **No currency from nothing.** However many conversions are chained, the player never ends
with more than they started with. -/
theorem playerKeep_never_gains (k x : ℕ) : playerKeep^[k] x ≤ x := by
  induction k generalizing x with
  | zero => simp
  | succ k ih =>
    rw [Function.iterate_succ_apply]
    exact (ih _).trans (Nat.sub_le _ _)

end RoundFourRounding
