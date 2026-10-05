module

public import Mathlib

/-!
# The spoken tour's cursor

`site/js/tour.js` moves a cursor through a script of `L` steps; some steps name a place to
show (a target), others only speak.  This file specifies the cursor and the stage:

* `clamp_lt`, `next_lt`, `prev_lt`: the cursor never leaves the script;
* `next_last`, `prev_zero`: it stops at the ends instead of wrapping;
* `targetAt_of_some`: a step with its own target shows that target;
* `targetAt_of_none`: a step without a target keeps showing the previous step's target,
  so the stage is never blank.

The JavaScript is checked against these statements by `site/test/run.mjs`.
-/

@[expose] public section

namespace Friction.Site

/-- Clamp a cursor into a script of length `L`. -/
def clamp (L i : ℕ) : ℕ := min i (L - 1)

/-- Advance the cursor by one step. -/
def next (L i : ℕ) : ℕ := clamp L (clamp L i + 1)

/-- Move the cursor back by one step. -/
def prev (L i : ℕ) : ℕ := clamp L (clamp L i - 1)

theorem clamp_lt {L : ℕ} (hL : 0 < L) (i : ℕ) : clamp L i < L := by
  unfold clamp; omega

theorem next_lt {L : ℕ} (hL : 0 < L) (i : ℕ) : next L i < L := clamp_lt hL _

theorem prev_lt {L : ℕ} (hL : 0 < L) (i : ℕ) : prev L i < L := clamp_lt hL _

/-- At the last step, `next` stays put. -/
theorem next_last (L : ℕ) : next L (L - 1) = L - 1 := by
  unfold next clamp; omega

/-- At the first step, `prev` stays put. -/
theorem prev_zero (L : ℕ) : prev L 0 = 0 := by
  unfold prev clamp; omega

variable {α : Type*}

/-- What is on stage at step `i`: the most recent target at or before `i`, or `d`. -/
def targetAt (steps : List (Option α)) (d : α) (i : ℕ) : α :=
  ((steps.take (i + 1)).filterMap id).getLast?.getD d

private lemma take_succ_eq (steps : List (Option α)) (i : ℕ) (x : Option α)
    (h : steps[i]? = some x) : steps.take (i + 1) = steps.take i ++ [x] := by
  rw [List.take_add_one, h]
  rfl

/-- A step with its own target shows it. -/
theorem targetAt_of_some (steps : List (Option α)) (d : α) (i : ℕ) (t : α)
    (h : steps[i]? = some (some t)) : targetAt steps d i = t := by
  unfold targetAt
  rw [take_succ_eq steps i _ h, List.filterMap_append]
  simp

/-- A step without a target keeps the previous stage: the stage is never blank. -/
theorem targetAt_of_none (steps : List (Option α)) (d : α) (i : ℕ)
    (h : steps[i + 1]? = some none) : targetAt steps d (i + 1) = targetAt steps d i := by
  unfold targetAt
  rw [take_succ_eq steps (i + 1) _ h, List.filterMap_append]
  simp

end Friction.Site
