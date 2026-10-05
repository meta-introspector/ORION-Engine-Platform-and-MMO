module

public import Mathlib

/-!
# Linguistic friction as a coding-theory trade-off

The corpus appeals to Shannon's information theory for two claims:
"high-bandwidth intent forced through a low-bandwidth language loses data", and
"over-explaining is an error-correction mechanism".  In their simplest exact
forms both are theorems:

* `encoding_must_merge`: if there are more distinct intents than available
  expressions, every encoding merges two different intents (pigeonhole).
* `majority_corrects_one`: saying a bit three times and reading the majority
  recovers it whenever at most one copy is corrupted — redundancy is friction
  that pays for itself.
* `majority_fails_two`: the same scheme fails with two corruptions, and it costs
  three symbols per bit, so redundancy has limits and a price.
-/

@[expose] public section

namespace Friction

/-- **Compression loses information.**  Any encoding of `M` distinct intents into a
vocabulary of `N < M` expressions sends two different intents to the same
expression. -/
theorem encoding_must_merge {M N : ℕ} (h : N < M) (f : Fin M → Fin N) :
    ∃ i j, i ≠ j ∧ f i = f j := by
  obtain ⟨i, j, hij, h⟩ := Fintype.exists_ne_map_eq_of_card_lt f (by simpa using h)
  exact ⟨i, j, hij, h⟩

/-- Majority vote of three bits. -/
def majority (x y z : Bool) : Bool := (x && y) || (y && z) || (x && z)

/-- Number of corrupted copies in an error pattern. -/
def errCount (e₁ e₂ e₃ : Bool) : ℕ := e₁.toNat + e₂.toNat + e₃.toNat

/-- **Redundancy corrects errors.**  Sending a bit three times and decoding by majority
recovers it whenever at most one of the three copies is flipped. -/
theorem majority_corrects_one (b e₁ e₂ e₃ : Bool) (he : errCount e₁ e₂ e₃ ≤ 1) :
    majority (b ^^ e₁) (b ^^ e₂) (b ^^ e₃) = b := by
  revert he
  cases b <;> cases e₁ <;> cases e₂ <;> cases e₃ <;> decide

/-- **Redundancy has limits.**  With two flipped copies, majority decoding returns the
wrong bit. -/
theorem majority_fails_two (b : Bool) : majority (b ^^ true) (b ^^ true) (b ^^ false) = !b := by
  cases b <;> decide

end Friction
