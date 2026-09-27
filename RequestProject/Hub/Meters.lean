module

public import Mathlib

/-!
# The Kronos / Orion meters

The build document (§3) asks for meters that
* track a *running average* of weighted behavioural events and never forbid an action,
* **move gradually**, so short-term spikes are possible but long-term identity is the running
  average, and a sustained pattern outweighs one-off spikes;
* modulate outcomes: Kronos-leaning play gives **more volume and lower grade**, Orion-leaning
  play gives **less volume and higher grade**;
* reward "the balance that serves the character's actual purpose and role", without requiring
  a perfect 50/50.

The model here is standard: the meter `m ∈ [0, 1]` is the character's Orion share (the Kronos
share is `1 − m`). Each behavioural event carries an Orion share `s ∈ [0, 1]`, and the meter is
updated as an exponential moving average with rate `α ∈ [0, 1]`:

  `m' = (1 − α) m + α s`.

Outputs use `volume = 1 + a (1 − m)` and `grade = 1 + b m`, where the role weights
`a, b > 0` say how much a role values raw throughput and refinement.

Note that the update takes only behavioural events. There is no input through which a payment
could move the meter, which is how "no pay-to-shift" is enforced in this model.
-/

@[expose] public section

namespace OrionMeters

/-- One meter update from a behavioural event with Orion share `s`. -/
def step (α m s : ℚ) : ℚ := (1 - α) * m + α * s

/-- The meter after a history of events (oldest first). -/
def run (α m : ℚ) (events : List ℚ) : ℚ := events.foldl (step α) m

/-- The meter stays in `[0, 1]`. -/
theorem step_mem_Icc {α m s : ℚ} (hα0 : 0 ≤ α) (hα1 : α ≤ 1) (hm0 : 0 ≤ m) (hm1 : m ≤ 1)
    (hs0 : 0 ≤ s) (hs1 : s ≤ 1) : 0 ≤ step α m s ∧ step α m s ≤ 1 := by
  unfold step
  constructor <;> nlinarith

theorem run_mem_Icc {α : ℚ} (hα0 : 0 ≤ α) (hα1 : α ≤ 1) (events : List ℚ)
    (hev : ∀ s ∈ events, 0 ≤ s ∧ s ≤ 1) {m : ℚ} (hm0 : 0 ≤ m) (hm1 : m ≤ 1) :
    0 ≤ run α m events ∧ run α m events ≤ 1 := by
  induction events generalizing m with
  | nil => exact ⟨hm0, hm1⟩
  | cons s l ih =>
    have hs := hev s (by simp)
    obtain ⟨h0, h1⟩ := step_mem_Icc hα0 hα1 hm0 hm1 hs.1 hs.2
    exact ih (fun t ht => hev t (by simp [ht])) h0 h1

/-- **Meters move gradually.** One event moves the meter by at most `α`. -/
theorem abs_step_sub_le {α m s : ℚ} (hα0 : 0 ≤ α) (hm0 : 0 ≤ m) (hm1 : m ≤ 1)
    (hs0 : 0 ≤ s) (hs1 : s ≤ 1) : |step α m s - m| ≤ α := by
  have h : step α m s - m = α * (s - m) := by unfold step; ring
  rw [h, abs_mul, abs_of_nonneg hα0]
  have : |s - m| ≤ 1 := abs_le.2 ⟨by linarith, by linarith⟩
  nlinarith [abs_nonneg (s - m)]

/-- Two meters that see the same events move closer together by a factor of `1 − α` per
event. -/
theorem run_sub (α m₁ m₂ : ℚ) (events : List ℚ) :
    run α m₁ events - run α m₂ events = (1 - α) ^ events.length * (m₁ - m₂) := by
  induction events generalizing m₁ m₂ with
  | nil => simp [run]
  | cons s l ih =>
    simp only [run, List.foldl_cons] at ih ⊢
    rw [ih, List.length_cons, pow_succ]
    unfold step; ring

/-- **One-off spikes fade.** Changing one past event from `s` to `s'` changes the current meter
by exactly `α (1 − α)^k |s − s'|`, where `k` is the number of events since. So the effect
shrinks geometrically as play continues. -/
theorem spike_effect {α : ℚ} (hα : 0 ≤ α) (m s s' : ℚ) (later : List ℚ) :
    |run α m (s :: later) - run α m (s' :: later)| =
      α * |1 - α| ^ later.length * |s - s'| := by
  have h : run α m (s :: later) - run α m (s' :: later) =
      (1 - α) ^ later.length * (α * (s - s')) := by
    have := run_sub α (step α m s) (step α m s') later
    simp only [run, List.foldl_cons] at this ⊢
    rw [this]; unfold step; ring
  rw [h, abs_mul, abs_mul, abs_pow, abs_of_nonneg hα]; ring

/-- **A sustained pattern wins.** After `n` events that all have Orion share `s`, the meter's
distance to `s` has shrunk by the factor `(1 − α)^n`. So with `0 < α ≤ 1`, repeating one style
of play pulls the meter to that style, whatever the starting point. -/
theorem run_replicate (α m s : ℚ) (n : ℕ) :
    run α m (List.replicate n s) - s = (1 - α) ^ n * (m - s) := by
  have hfix : run α s (List.replicate n s) = s := by
    induction n with
    | zero => simp [run]
    | succ n ih =>
      simp only [run, List.replicate_succ, List.foldl_cons] at ih ⊢
      have : step α s s = s := by unfold step; ring
      rw [this, ih]
  have := run_sub α m s (List.replicate n s)
  rw [hfix, List.length_replicate] at this
  exact this

/-! ## Outcome modulation -/

/-- Resource volume at Orion share `m`, for a role with throughput weight `a`. -/
def volume (a m : ℚ) : ℚ := 1 + a * (1 - m)

/-- Resource grade at Orion share `m`, for a role with refinement weight `b`. -/
def grade (b m : ℚ) : ℚ := 1 + b * m

/-- Total value produced: volume × grade. -/
def yield (a b m : ℚ) : ℚ := volume a m * grade b m

/-- **Kronos gives volume, Orion gives grade.** Moving towards Orion (larger `m`) lowers volume
and raises grade. -/
theorem volume_grade_tradeoff {a b m m' : ℚ} (ha : 0 ≤ a) (hb : 0 ≤ b) (h : m ≤ m') :
    volume a m' ≤ volume a m ∧ grade b m ≤ grade b m' := by
  unfold volume grade
  constructor <;> nlinarith

/-- The best balance for a role with weights `a, b`. -/
def bestBalance (a b : ℚ) : ℚ := (b + a * b - a) / (2 * a * b)

/-- **The balance that serves the role is rewarded.** For role weights `a, b > 0`, the value
produced is largest at `bestBalance a b`, and strictly smaller at every other balance. -/
theorem yield_le_best {a b : ℚ} (ha : 0 < a) (hb : 0 < b) (m : ℚ) :
    yield a b m ≤ yield a b (bestBalance a b) ∧
      (yield a b m = yield a b (bestBalance a b) ↔ m = bestBalance a b) := by
  have key : ∀ x, yield a b x =
      (1 + a + a * b * bestBalance a b ^ 2) - a * b * (x - bestBalance a b) ^ 2 := by
    intro x
    unfold yield volume grade bestBalance
    field_simp
    ring
  have hab : 0 < a * b := mul_pos ha hb
  rw [key m, key (bestBalance a b)]
  refine ⟨by nlinarith [sq_nonneg (m - bestBalance a b)], ?_⟩
  constructor
  · intro h
    have : a * b * (m - bestBalance a b) ^ 2 = 0 := by linarith
    rcases mul_eq_zero.1 this with h1 | h1
    · exact absurd h1 hab.ne'
    · exact sub_eq_zero.1 (pow_eq_zero_iff (n := 2) (by norm_num) |>.1 h1)
  · intro h; rw [h]

/-- With equal weights the best balance is exactly 50/50. -/
theorem bestBalance_symm {k : ℚ} (hk : 0 < k) : bestBalance k k = 1 / 2 := by
  unfold bestBalance
  field_simp
  ring

/-- **No forced 50/50.** Every positive target balance `t` (in particular every `t ∈ (0, 1]`) is
the best balance for some role
(throughput weight `1/(2t)`, refinement weight `1`). -/
theorem bestBalance_surj {t : ℚ} (ht : 0 < t) : bestBalance (1 / (2 * t)) 1 = t := by
  unfold bestBalance
  field_simp
  ring

end OrionMeters
