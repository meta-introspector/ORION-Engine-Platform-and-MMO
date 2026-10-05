module

public import Mathlib

/-!
# The Atlas representation grid

The web app's Atlas shows each knowledge element in `7` forms (card, graph, animation, speech,
numbers, quiz, linked data) through `7` lenses (plain words, framework, evidence, try it, make
it, where it comes from, open question). At knowledge level `n` it shows the first `n` forms
through the first `n` lenses. This file checks the three facts the app relies on:

* level `n` has exactly `n²` representations (`card_level`), from `1` at level 1 to `49` at
  level 7;
* levels are nested: everything shown at level `n` is still shown at level `n + 1`
  (`level_mono`);
* going up one level adds exactly `2n + 1` new representations (`card_level_succ_sdiff`).

The JavaScript copy in `webapp/index.html` (`OrionAtlas.grid`) is tested against the same three
facts in `webapp/test_atlas.mjs`.
-/

@[expose] public section

namespace RepresentationGrid

/-- The number of forms and of lenses. -/
def size : ℕ := 7

/-- The cells shown at level `n`: pairs (form index, lens index) with both indices below `n`. -/
def level (n : ℕ) : Finset (ℕ × ℕ) := Finset.range n ×ˢ Finset.range n

/-- Level `n` shows `n²` representations. -/
theorem card_level (n : ℕ) : (level n).card = n ^ 2 := by
  simp [level, Finset.card_product, sq]

/-- The full grid at level 7 has 49 cells. -/
theorem card_top : (level size).card = 49 := by rw [card_level]; rfl

/-- Levels are nested. -/
theorem level_mono {m n : ℕ} (h : m ≤ n) : level m ⊆ level n :=
  Finset.product_subset_product (Finset.range_subset_range.2 h) (Finset.range_subset_range.2 h)

/-- Moving from level `n` to level `n + 1` adds exactly `2n + 1` representations. -/
theorem card_level_succ_sdiff (n : ℕ) : (level (n + 1) \ level n).card = 2 * n + 1 := by
  rw [Finset.card_sdiff_of_subset (level_mono (Nat.le_succ n)), card_level, card_level]
  have : n ^ 2 ≤ (n + 1) ^ 2 := Nat.pow_le_pow_left (Nat.le_succ n) 2
  zify [this]; ring

end RepresentationGrid
