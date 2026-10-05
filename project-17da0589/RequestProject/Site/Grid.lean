module

public import Mathlib

/-!
# The n × n representation grid of the friction atlas

At knowledge level `n` the atlas (`site/js/grid.js`) shows the first `n` forms × the first
`n` depths of a knowledge element.  This file specifies that grid and proves its counting
facts:

* `card_cells`: level `n` has exactly `n²` cells;
* `cells_mono`: the level-`m` grid sits inside the level-`n` grid for `m ≤ n`, so raising
  the level never removes a representation;
* `card_new_cells`: going from level `n` to `n + 1` adds exactly `2n + 1` cells;
* `cellIndex_lt`, `cellIndex_injOn`, `cellAt_cellIndex`: row-major numbering `r·n + c`
  is a bijection between the grid and `{0, …, n² − 1}`.

The JavaScript is checked against these statements by `site/test/run.mjs`; this file is a
specification of that arithmetic, not a proof about the JavaScript itself.
-/

@[expose] public section

namespace Friction.Site

/-- The cells (depth row, form column) visible at knowledge level `n`. -/
def cells (n : ℕ) : Finset (ℕ × ℕ) := Finset.range n ×ˢ Finset.range n

/-- Level `n` shows exactly `n²` representations. -/
theorem card_cells (n : ℕ) : (cells n).card = n ^ 2 := by
  simp [cells, Finset.card_product, sq]

/-- Raising the level never removes a representation. -/
theorem cells_mono {m n : ℕ} (h : m ≤ n) : cells m ⊆ cells n := by
  intro p hp
  simp only [cells, Finset.mem_product, Finset.mem_range] at hp ⊢
  omega

/-- Going from level `n` to level `n + 1` adds exactly `2n + 1` new representations. -/
theorem card_new_cells (n : ℕ) : (cells (n + 1) \ cells n).card = 2 * n + 1 := by
  rw [Finset.card_sdiff_of_subset (cells_mono (Nat.le_add_right n 1)), card_cells, card_cells]
  have : (n + 1) ^ 2 = n ^ 2 + (2 * n + 1) := by ring
  omega

/-- Row-major number of a cell at level `n`. -/
def cellIndex (n : ℕ) (p : ℕ × ℕ) : ℕ := p.1 * n + p.2

/-- Row-major numbers of level-`n` cells lie in `{0, …, n² − 1}`. -/
theorem cellIndex_lt {n : ℕ} {p : ℕ × ℕ} (hp : p ∈ cells n) : cellIndex n p < n ^ 2 := by
  simp only [cells, Finset.mem_product, Finset.mem_range] at hp
  unfold cellIndex
  nlinarith

/-- Decoding a row-major number gives the cell back. -/
theorem cellAt_cellIndex {n : ℕ} {p : ℕ × ℕ} (hp : p ∈ cells n) :
    (cellIndex n p / n, cellIndex n p % n) = p := by
  simp only [cells, Finset.mem_product, Finset.mem_range] at hp
  have hn : 0 < n := by omega
  unfold cellIndex
  ext
  · simp only
    rw [Nat.add_comm, Nat.add_mul_div_right _ _ hn, Nat.div_eq_of_lt hp.2, zero_add]
  · simp only
    rw [Nat.add_comm, Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt hp.2]

/-- Distinct cells get distinct numbers. -/
theorem cellIndex_injOn (n : ℕ) : Set.InjOn (cellIndex n) (cells n) := by
  intro p hp q hq h
  rw [← cellAt_cellIndex hp, ← cellAt_cellIndex hq, h]

end Friction.Site
