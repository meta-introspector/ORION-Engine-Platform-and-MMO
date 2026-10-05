module

public import Mathlib

/-!
# Integer share allocation and the accountability ledger

Used for the "pop-out equity" and "delegated standing" questions in
`ROUND_THREE_RESPONSES.md`.  These are *platform-internal accounting rules*; they say
nothing about how any legal system assigns ownership or liability.

**Share allocation.**  `N` indivisible units (shares, tokens) are split among `m` holders
with natural-number weights `w i` (contribution points from labour logs, progenitor weight,
…) of positive total `W`.

* `floor_alloc_sum_le`, `floor_deficit_lt` — rounding each exact entitlement `N·wᵢ/W` down
  leaves fewer than `m` units unallocated;
* `final_alloc_sum` — handing one leftover unit to each of the first `r` holders allocates
  exactly `N`;
* `final_alloc_lower`, `final_alloc_upper` — every holder ends within one unit of their exact
  entitlement.

**Accountability ledger.**  An act is attributed either to the whole authorisation chain
(if it was inside the delegated scope) or to the actor alone (if not).

* `share_sum_one` — the shares of the responsible set sum to one;
* `out_of_scope_share_zero` — for an out-of-scope act, every delegator's share is zero;
* `in_scope_share` — in scope, a chain of a progenitor plus `n` others gives each `1/(n+1)`.
-/

@[expose] public section

namespace Orion.Shares

open Finset

variable {m : ℕ}

/-- Total weight. -/
def total (w : Fin m → ℕ) : ℕ := ∑ i, w i

/-- Rounded-down allocation. -/
def floorAlloc (N : ℕ) (w : Fin m → ℕ) (i : Fin m) : ℕ := N * w i / total w

lemma floorAlloc_mul_le (N : ℕ) (w : Fin m → ℕ) (i : Fin m) :
    floorAlloc N w i * total w ≤ N * w i := Nat.div_mul_le_self _ _

lemma lt_floorAlloc_succ_mul (N : ℕ) (w : Fin m → ℕ) (hW : 0 < total w) (i : Fin m) :
    N * w i < (floorAlloc N w i + 1) * total w := by
  unfold floorAlloc
  rw [Nat.add_one_mul]
  have := Nat.lt_div_mul_add (a := N * w i) hW
  linarith

/-- Rounding down never over-allocates. -/
theorem floor_alloc_sum_le (N : ℕ) (w : Fin m → ℕ) (hW : 0 < total w) :
    ∑ i, floorAlloc N w i ≤ N := by
  have h : (∑ i, floorAlloc N w i) * total w ≤ N * total w := by
    rw [Finset.sum_mul, total, Finset.mul_sum]
    exact Finset.sum_le_sum (fun i _ => floorAlloc_mul_le N w i)
  exact Nat.le_of_mul_le_mul_right h hW

/-- Rounding down leaves fewer than `m` units over. -/
theorem floor_deficit_lt (N : ℕ) (w : Fin m → ℕ) (hW : 0 < total w) :
    N < ∑ i, floorAlloc N w i + m := by
  have h : N * total w < (∑ i, floorAlloc N w i + m) * total w := by
    have hm : 0 < m := by
      rcases Nat.eq_zero_or_pos m with rfl | h
      · simp [total] at hW
      · exact h
    have hlt : ∑ i, N * w i < ∑ i, (floorAlloc N w i + 1) * total w :=
      Finset.sum_lt_sum_of_nonempty (Finset.univ_nonempty_iff.2 ⟨⟨0, hm⟩⟩)
        (fun i _ => lt_floorAlloc_succ_mul N w hW i)
    rw [← Finset.mul_sum, ← total, ← Finset.sum_mul] at hlt
    simpa [Finset.sum_add_distrib] using hlt
  exact Nat.lt_of_mul_lt_mul_right h

/-- Number of leftover units. -/
def leftover (N : ℕ) (w : Fin m → ℕ) : ℕ := N - ∑ i, floorAlloc N w i

/-- Final allocation: the first `leftover` holders get one extra unit. -/
def finalAlloc (N : ℕ) (w : Fin m → ℕ) (i : Fin m) : ℕ :=
  floorAlloc N w i + if i.val < leftover N w then 1 else 0

lemma sum_indicator (r : ℕ) (hr : r ≤ m) :
    ∑ i : Fin m, (if i.val < r then 1 else 0) = r := by
  rw [Fin.sum_univ_eq_sum_range (fun j => if j < r then 1 else 0), Finset.sum_boole]
  have : (Finset.range m).filter (· < r) = Finset.range r := by
    ext j; simp only [Finset.mem_filter, Finset.mem_range]; omega
  simp [this]

/-- Exactly `N` units are allocated. -/
theorem final_alloc_sum (N : ℕ) (w : Fin m → ℕ) (hW : 0 < total w) :
    ∑ i, finalAlloc N w i = N := by
  have h1 := floor_alloc_sum_le N w hW
  have h2 := floor_deficit_lt N w hW
  unfold finalAlloc
  rw [Finset.sum_add_distrib, sum_indicator _ (by unfold leftover; omega)]
  unfold leftover
  omega

/-- Nobody gets less than their exact entitlement rounded down. -/
theorem final_alloc_lower (N : ℕ) (w : Fin m → ℕ) (i : Fin m) :
    finalAlloc N w i * total w ≤ N * w i + total w := by
  have := floorAlloc_mul_le N w i
  unfold finalAlloc
  split_ifs <;> nlinarith

/-- Nobody gets more than one unit above their exact entitlement. -/
theorem final_alloc_upper (N : ℕ) (w : Fin m → ℕ) (hW : 0 < total w) (i : Fin m) :
    N * w i < (finalAlloc N w i + 1) * total w := by
  have := lt_floorAlloc_succ_mul N w hW i
  unfold finalAlloc
  split_ifs <;> nlinarith

/-! ### Accountability ledger -/

variable {P : Type*} [DecidableEq P]

/-- Who answers for an act: the whole authorisation chain if in scope, else the actor. -/
def responsible (chain : Finset P) (actor : P) (inScope : Prop) [Decidable inScope] :
    Finset P :=
  if inScope then chain else {actor}

/-- Each responsible principal's share. -/
noncomputable def share (chain : Finset P) (actor : P) (inScope : Prop) [Decidable inScope]
    (p : P) : ℝ :=
  if p ∈ responsible chain actor inScope then 1 / (responsible chain actor inScope).card
  else 0

/-- The shares sum to one (given a non-empty chain). -/
theorem share_sum_one (chain : Finset P) (actor : P) (inScope : Prop) [Decidable inScope]
    (hne : chain.Nonempty) :
    ∑ p ∈ responsible chain actor inScope, share chain actor inScope p = 1 := by
  have hpos : 0 < (responsible chain actor inScope).card := by
    unfold responsible; split_ifs
    · exact hne.card_pos
    · simp
  rw [Finset.sum_congr rfl (fun p hp => by rw [share, if_pos hp]), Finset.sum_const,
    nsmul_eq_mul]
  field_simp

/-- An act outside the delegated scope puts no share on anyone but the actor. -/
theorem out_of_scope_share_zero (chain : Finset P) (actor p : P) (inScope : Prop)
    [Decidable inScope] (h : ¬ inScope) (hp : p ≠ actor) :
    share chain actor inScope p = 0 := by
  simp [share, responsible, h, hp]

/-- In scope, a chain of a progenitor plus `n` others gives each member `1/(n+1)`. -/
theorem in_scope_share (chain : Finset P) (actor p : P) (inScope : Prop) [Decidable inScope]
    (n : ℕ) (hcard : chain.card = n + 1) (h : inScope) (hp : p ∈ chain) :
    share chain actor inScope p = 1 / (n + 1) := by
  simp [share, responsible, h, hp, hcard]

end Orion.Shares
