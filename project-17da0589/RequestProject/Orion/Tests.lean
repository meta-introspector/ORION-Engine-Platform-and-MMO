module

public import Mathlib

/-!
# Held-out cousin cases and the metaphor gate

Used for the "held-out cousin case" and "semantic poisoning" questions in
`ROUND_THREE_RESPONSES.md`.

**Cousin cases as metamorphic transforms.**  A claim is a predicate `G` on a domain `Dom`.
A *cousin transform* `T` maps the domain to itself and preserves the claim
(`G (T x) ↔ G x`).  The cousins of the seen cases `S` are `T '' S`.

* `cousins_in_domain` — cousins never leave the claim's domain (no out-of-domain variables);
* `genuine_passes_cousins` — an answer that encodes the claim's logic (is `T`-invariant) and
  is right on `S` is right on every cousin;
* `cousin_failure_exposes` — an answer right on `S` but wrong on a cousin is not encoding
  the claim's logic: it is not `T`-invariant (it memorised or pattern-matched).

**Metaphor gate.**  A dictionary entry pairs a player's term with a checkable mathematical
claim.  For "Seashell Spirals = Fibonacci":

* `seashell_recurrence` — the Fibonacci recurrence holds for every `n`;
* `seashell_ratio_tendsto` — consecutive ratios tend to the golden ratio (Mathlib's
  `tendsto_fib_succ_div_fib_atTop`);
* `troll_powers_of_two_rejected` — the substitute claim "Seashell Spirals are the powers of
  two" fails the recurrence check at `n = 0`.
-/

@[expose] public section

namespace Orion.Tests

open Filter Topology

variable {X : Type*}

/-- Cousins stay inside the domain. -/
theorem cousins_in_domain (Dom S : Set X) (T : X → X) (hT : Set.MapsTo T Dom Dom)
    (hS : S ⊆ Dom) : T '' S ⊆ Dom := by
  rintro _ ⟨x, hx, rfl⟩
  exact hT (hS hx)

/-- An answer that is right on the seen cases and `T`-invariant is right on every cousin. -/
theorem genuine_passes_cousins (G P : X → Prop) (S : Set X) (T : X → X)
    (hG : ∀ x, G (T x) ↔ G x) (hP : ∀ x, P (T x) ↔ P x) (hS : ∀ x ∈ S, P x ↔ G x) :
    ∀ y ∈ T '' S, P y ↔ G y := by
  rintro _ ⟨x, hx, rfl⟩
  rw [hP, hG]
  exact hS x hx

/-- Failing a cousin while passing the seen cases exposes a non-invariant answer. -/
theorem cousin_failure_exposes (G P : X → Prop) (S : Set X) (T : X → X)
    (hG : ∀ x, G (T x) ↔ G x) (hS : ∀ x ∈ S, P x ↔ G x)
    (hfail : ∃ y ∈ T '' S, ¬ (P y ↔ G y)) : ¬ ∀ x, P (T x) ↔ P x :=
  fun hP => by
    obtain ⟨y, hy, hn⟩ := hfail
    exact hn (genuine_passes_cousins G P S T hG hP hS y hy)

/-- The recurrence check a sequence claim must pass. -/
def FibLike (s : ℕ → ℕ) : Prop := s 0 = 0 ∧ s 1 = 1 ∧ ∀ n, s (n + 2) = s (n + 1) + s n

/-- "Seashell Spirals" resolved to the Fibonacci numbers passes the check. -/
theorem seashell_recurrence : FibLike Nat.fib :=
  ⟨Nat.fib_zero, Nat.fib_one, fun n => by rw [Nat.fib_add_two, add_comm]⟩

/-- Its consecutive ratios tend to the golden ratio. -/
theorem seashell_ratio_tendsto :
    Tendsto (fun n => (Nat.fib (n + 1) : ℝ) / Nat.fib n) atTop (𝓝 Real.goldenRatio) :=
  tendsto_fib_succ_div_fib_atTop

/-- A troll substitution (powers of two) is rejected. -/
theorem troll_powers_of_two_rejected : ¬ FibLike (fun n => 2 ^ n) := by
  rintro ⟨h0, -, -⟩
  simp at h0

end Orion.Tests
