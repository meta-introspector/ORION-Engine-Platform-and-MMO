module

public import Mathlib

/-!
# The append-only reasoning record (`R₂` must not erase `R₀`) and its storage

Used for the "database bloat vs. zero information loss" question in
`ROUND_THREE_RESPONSES.md`.  A record is a list of entries, newest first; the only write
operation is `push` (cons).

* `push_keeps_history`, `r0_preserved` — every later state still contains the whole earlier
  history as a suffix, and the first entry `R₀` is still the oldest entry;
* `digest_injective` — a hash chain `digest (x :: c) = step (digest c) x` identifies the
  entire history, *under the idealisation* that `step` is injective and never returns the
  genesis value (collision resistance); so a client that keeps only the 32-byte head digest
  can detect any erasure or rewrite;
* `tiering_lossless`, `tiered_cost_le` — splitting the record into a hot window of the `W`
  newest entries and a compressed cold tier loses nothing, and the hot cost is bounded by
  `W · b` however long the history grows;
* `dedup_le` — content-addressed storage never stores more blobs than entries.
-/

@[expose] public section

namespace Orion.Record

variable {α H : Type*}

/-- Append a new entry (newest first). -/
def push (c : List α) (x : α) : List α := x :: c

/-- Pushing never removes history: the old record is a suffix of the new one. -/
theorem push_keeps_history (c : List α) (xs : List α) : c <:+ xs.reverse ++ c :=
  List.suffix_append _ _

/-- The oldest entry `R₀` survives every later revision. -/
theorem r0_preserved (c xs : List α) (r₀ : α) (h : c.getLast? = some r₀) :
    (xs ++ c).getLast? = some r₀ := by
  rw [List.getLast?_append, h]
  rfl

/-- The hash chain over a newest-first record. -/
def digest (h₀ : H) (step : H → α → H) : List α → H
  | [] => h₀
  | x :: c => step (digest h₀ step c) x

/-- Under collision resistance (an injective `step` that never returns `h₀`), the head
digest determines the entire history. -/
theorem digest_injective (h₀ : H) (step : H → α → H)
    (hinj : ∀ a b x y, step a x = step b y → a = b ∧ x = y)
    (hgen : ∀ a x, step a x ≠ h₀) :
    Function.Injective (digest h₀ step) := by
  intro c₁
  induction c₁ with
  | nil =>
    intro c₂ h
    cases c₂ with
    | nil => rfl
    | cons y c₂ => exact absurd h.symm (hgen _ _)
  | cons x c₁ ih =>
    intro c₂ h
    cases c₂ with
    | nil => exact absurd h (hgen _ _)
    | cons y c₂ =>
      obtain ⟨h1, h2⟩ := hinj _ _ _ _ h
      rw [ih h1, h2]

/-- Hot window (newest `W` entries) and cold tier (the rest) together are the record. -/
theorem tiering_lossless (c : List α) (W : ℕ) : c.take W ++ c.drop W = c :=
  List.take_append_drop W c

/-- Cost with hot entries at `b` each and cold (compressed) entries at `k` each. -/
def tieredCost (c : List α) (W b k : ℕ) : ℕ := (c.take W).length * b + (c.drop W).length * k

/-- The hot cost is bounded by `W · b` regardless of history length. -/
theorem tiered_cost_le (c : List α) (W b k : ℕ) :
    tieredCost c W b k ≤ W * b + c.length * k := by
  unfold tieredCost
  have h1 : (c.take W).length ≤ W := List.length_take_le W c
  have h2 : (c.drop W).length ≤ c.length := by simp
  exact Nat.add_le_add (Nat.mul_le_mul_right _ h1) (Nat.mul_le_mul_right _ h2)

/-- Content-addressed storage stores each distinct blob once. -/
theorem dedup_le [DecidableEq α] (c : List α) : c.toFinset.card ≤ c.length :=
  List.toFinset_card_le c

end Orion.Record
