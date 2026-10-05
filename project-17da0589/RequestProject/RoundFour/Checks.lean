module

public import Mathlib

/-!
# Small exact checks on Round Four material

Each block answers one concrete question raised by a Round Four document (section numbers
refer to `ROUND_FOUR_TRIAGE.md`).

* **Clock numbers (A3).**  `clock_palindromes` — of the 720 readings on a 12-hour clock,
  exactly 57 read the same backwards (`7:27`, `12:21`, …), about 7.9 %.  Someone who glances
  at clocks a dozen times a day should expect to catch about one such reading a day by
  chance alone.
* **Penrose pentagrid (C1).**  `pentagrid_pairs`, `pentagrid_thin_pairs`, `pentagrid_raw_tiles`
  — the script's 810 raw rhombi = 10 line-family pairs × 9 × 9, and exactly 5 of the 10 pairs
  give thin rhombi (so the reported 405 / 405 split is forced by the counting, not a
  property of the tiling).  `script_corner_order_not_cycle` — the order in which the script
  lists each rhombus' corners jumps across a diagonal, so its "curvature walk" traces a
  bow-tie instead of the rhombus; `fixed_corner_order_cycle` — the corrected order walks
  the four edges.
* **Watermelon puzzle (D, GaiaNet).**  `dried_mass` — a 100 kg melon that is 99 % water,
  dried until it is 98 % water, weighs 50 kg.
* **Self-lifting device (B5).**  `closed_system_net_force` — for any closed device the
  internal forces cancel, so the net force is just its weight; `closed_system_cannot_rise`
  — the net vertical force on it is strictly downward.  Lift needs an external push or
  ejected mass.
* **Dragon Soul "second apple" (C2).**  `apple_unbounded` — the script's rule
  `weight ← weight²` has no limit on repeat use, so any weight above 1 can be pumped past
  every bound; `apple_once_bounded` — with the one-shot flag actually cleared after use,
  the weight never exceeds `w²`.
* **Modular Altar (D).**  `altar_center_mode` — with the four trays laid side by side (half
  the table width) and centred, a quarter of the table is exposed at each end, which is
  half of each zone; `altar_stacked_footprint` — if the trays are literally stacked they
  cover only a quarter of the sand zone, so "stacked" in the spec must mean "laid in a row".
* **Sanctuary Defense (D, Bubble Room manual).**  `sanctuary_balance` — with the proposed
  difficulty `6 + 2·threat` and tier bonuses +6/+4/+2/+0, the d20 game is an even contest:
  53 % overall, ranging from 95 % down to 15 %.
-/

@[expose] public section

namespace RoundFour.Checks

/-! ### Clock palindromes -/

/-- How a 12-hour clock displays `h:mm`, without the colon (`7:05` ↦ `"705"`). -/
def clockString (h m : ℕ) : String :=
  toString h ++ (if m < 10 then "0" else "") ++ toString m

/-- The display reads the same backwards. -/
def isPalindromic (s : String) : Bool := s.toList == s.toList.reverse

/-- All 720 readings `h:mm` with `h ∈ 1..12`, `m ∈ 0..59`. -/
def clockReadings : List (ℕ × ℕ) :=
  (List.range 12).flatMap fun i => (List.range 60).map fun m => (i + 1, m)

theorem clock_readings_count : clockReadings.length = 720 := by native_decide

/-- Exactly 57 of the 720 readings are palindromes. -/
theorem clock_palindromes :
    (clockReadings.filter fun p => isPalindromic (clockString p.1 p.2)).length = 57 := by
  native_decide

/-! ### Penrose pentagrid counting -/

/-- Unordered pairs `k < m` of the five line families. -/
def familyPairs : List (ℕ × ℕ) :=
  (List.range 5).flatMap fun k => ((List.range 5).filter (k < ·)).map fun m => (k, m)

/-- Pairs whose directions differ by `±2` steps (mod 5) give thin (36°) rhombi. -/
def isThinPair (p : ℕ × ℕ) : Bool :=
  let d := p.2 - p.1
  min d (5 - d) == 2

theorem pentagrid_pairs : familyPairs.length = 10 := by decide

theorem pentagrid_thin_pairs :
    (familyPairs.filter isThinPair).length = 5 ∧
      (familyPairs.filter fun p => !isThinPair p).length = 5 := by
  decide

/-- With line indices `-L..L` there are `10 (2L+1)²` raw intersections; `L = 4` gives 810. -/
theorem pentagrid_raw_tiles : familyPairs.length * (2 * 4 + 1) ^ 2 = 810 := by decide

/-- A rhombus corner as the change to the index vector `n ∈ ℤ⁵`: which of the two crossing
families `k`, `m` have been stepped back by one. -/
def corner (k m : Fin 5) (dk dm : ℤ) : Fin 5 → ℤ :=
  fun i => (if i = k then -dk else 0) + (if i = m then -dm else 0)

/-- Two corners are joined by a tile edge iff their index vectors differ in exactly one
coordinate, by exactly one. -/
def isEdge (u v : Fin 5 → ℤ) : Bool :=
  ((List.finRange 5).filter fun i => u i != v i).length == 1 &&
    (List.finRange 5).all fun i => (u i - v i).natAbs ≤ 1

/-- The script lists corners as `n, n - e_k, n - e_m, n - e_k - e_m`.  Its second step
(`n - e_k → n - e_m`) is a diagonal, not an edge, for every pair of families. -/
theorem script_corner_order_not_cycle :
    ∀ k m : Fin 5, k ≠ m → isEdge (corner k m 1 0) (corner k m 0 1) = false := by
  decide

/-- The corrected order `n, n - e_k, n - e_k - e_m, n - e_m` walks four edges. -/
theorem fixed_corner_order_cycle :
    ∀ k m : Fin 5, k ≠ m →
      isEdge (corner k m 0 0) (corner k m 1 0) ∧ isEdge (corner k m 1 0) (corner k m 1 1) ∧
        isEdge (corner k m 1 1) (corner k m 0 1) ∧ isEdge (corner k m 0 1) (corner k m 0 0) := by
  decide

/-! ### The watermelon puzzle -/

/-- Drying only removes water, so the dry mass `M (1 - p)` is conserved; at water fraction
`q` the total mass is `M (1 - p) / (1 - q)`. -/
theorem dried_mass_general (M p q M' : ℝ) (hq : q < 1)
    (hdry : M' * (1 - q) = M * (1 - p)) : M' = M * (1 - p) / (1 - q) := by
  have : (1 - q) ≠ 0 := by linarith
  field_simp
  linarith

/-- 100 kg at 99 % water, dried to 98 % water, weighs 50 kg. -/
theorem dried_mass (M' : ℝ) (hdry : M' * (1 - 98 / 100) = 100 * (1 - 99 / 100)) :
    M' = 50 := by
  linarith

/-! ### A closed device cannot lift itself -/

/-- Internal forces obey Newton's third law, `F i j = -F j i`, so they cancel in total and
the net (vertical) force on a closed device is just its weight `-(Σ mᵢ) g`. -/
theorem closed_system_net_force {ι : Type*} [Fintype ι] (F : ι → ι → ℝ)
    (hF : ∀ i j, F i j = -F j i) (mass : ι → ℝ) (g : ℝ) :
    ∑ i, (∑ j, F i j - mass i * g) = -(∑ i, mass i) * g := by
  have hcancel : ∑ i, ∑ j, F i j = 0 := by
    have h1 : ∑ i, ∑ j, F i j = ∑ i, ∑ j, F j i := Finset.sum_comm
    have h2 : ∑ i, ∑ j, F j i = -∑ i, ∑ j, F i j := by
      rw [← Finset.sum_neg_distrib]
      refine Finset.sum_congr rfl fun i _ => ?_
      rw [← Finset.sum_neg_distrib]
      exact Finset.sum_congr rfl fun j _ => by rw [hF i j, neg_neg]
    linarith
  rw [Finset.sum_sub_distrib, hcancel, ← Finset.sum_mul]
  ring

/-- With positive mass and gravity, the net vertical force on a closed device is downward:
spinning, pumping or pulsing parts inside cannot make it rise. -/
theorem closed_system_cannot_rise {ι : Type*} [Fintype ι] [Nonempty ι] (F : ι → ι → ℝ)
    (hF : ∀ i j, F i j = -F j i) (mass : ι → ℝ) (hm : ∀ i, 0 < mass i) (g : ℝ) (hg : 0 < g) :
    ∑ i, (∑ j, F i j - mass i * g) < 0 := by
  rw [closed_system_net_force F hF mass g]
  have : 0 < ∑ i, mass i := Finset.sum_pos (fun i _ => hm i) Finset.univ_nonempty
  nlinarith

/-! ### Dragon Soul: the second apple -/

/-- The script's rule: each "second apple" squares the weight. -/
def apple (w : ℝ) : ℝ := w * w

/-- Nothing stops repeated use, and any weight above 1 is pumped past every bound. -/
theorem apple_unbounded (w : ℝ) (hw : 1 < w) (B : ℝ) : ∃ n, B < apple^[n] w := by
  have hiter : ∀ n, apple^[n] w = w ^ (2 ^ n) := by
    intro n
    induction n with
    | zero => simp
    | succ n ih =>
      rw [Function.iterate_succ_apply', ih, apple, pow_succ, pow_mul]
      ring
  obtain ⟨n, hn⟩ := pow_unbounded_of_one_lt B hw
  refine ⟨n, ?_⟩
  rw [hiter]
  have : n ≤ 2 ^ n := (Nat.lt_two_pow_self).le
  calc B < w ^ n := hn
    _ ≤ w ^ (2 ^ n) := pow_le_pow_right₀ hw.le this

/-- The intended rule: the apple works once, then the flag is cleared. -/
def appleOnce : ℝ × Bool → ℝ × Bool
  | (w, true) => (w * w, false)
  | (w, false) => (w, false)

/-- With the flag cleared after use, any number of apples leaves the weight at `w` or `w²`. -/
theorem apple_once_bounded (w : ℝ) (n : ℕ) :
    (appleOnce^[n] (w, true)).1 = w ∨ (appleOnce^[n] (w, true)).1 = w * w := by
  have hfalse : ∀ k (x : ℝ), appleOnce^[k] (x, false) = (x, false) := by
    intro k x
    induction k with
    | zero => rfl
    | succ k ih => rw [Function.iterate_succ_apply, show appleOnce (x, false) = (x, false) from rfl, ih]
  cases n with
  | zero => left; rfl
  | succ n =>
    right
    rw [Function.iterate_succ_apply, show appleOnce (w, true) = (w * w, false) from rfl, hfalse]

/-! ### Modular Altar layout -/

/-- Width of the table exposed at each end when trays of total width `t` are centred on a
table of width 1. -/
def exposedEach (t : ℚ) : ℚ := (1 - t) / 2

/-- Centre mode: trays covering half the width leave a quarter of the table exposed at each
end, i.e. half of the sand zone and half of the tool zone (each zone is half the table). -/
theorem altar_center_mode : exposedEach (1 / 2) = 1 / 4 ∧ exposedEach (1 / 2) / (1 / 2) = 1 / 2 := by
  norm_num [exposedEach]

/-- Four trays that together cover half the table each have footprint `1/8`; stacked, they
cover `1/8` of the table, a quarter of the half-table sand zone.  Laid in a row they cover
it exactly. -/
theorem altar_stacked_footprint : (1 / 2 / 4 : ℚ) / (1 / 2) = 1 / 4 ∧ (4 * (1 / 2 / 4) : ℚ) = 1 / 2 := by
  norm_num

/-! ### Sanctuary Defense (de-personalised Bubble Room tabletop rules) -/

/-- Proposed difficulty for a threat of rank `t ∈ 1..6`: `6 + 2t` (8 … 18). -/
def threatDC (t : ℕ) : ℕ := 6 + 2 * t

/-- A d20 roll `r` with tier bonus `b` beats threat `t`: a natural 20 always wins (the
dragon), a natural 1 always fails, otherwise `r + b ≥ DC`. -/
def beats (b t r : ℕ) : Bool := r == 20 || (r != 1 && threatDC t ≤ r + b)

/-- Chance that tier bonus `b` beats threat `t` on one d20. -/
def winChance (b t : ℕ) : ℚ := ((List.range 20).filter fun i => beats b t (i + 1)).length / 20

/-- Tier table from the manual: (number of d20 faces selecting the tier, tier bonus).
Big Dogs 18–20 (+6), Avatars 13–17 (+4), Infantry 6–12 (+2), Gnomes 1–5 (+0). -/
def tiers : List (ℕ × ℕ) := [(3, 6), (5, 4), (7, 2), (5, 0)]

/-- Overall win chance when the tier is rolled first and the threat rank is a fair d6. -/
def overallWinChance : ℚ :=
  (tiers.map fun p => (p.1 : ℚ) / 20 * (((List.range 6).map fun t => winChance p.2 (t + 1)).sum / 6)).sum

/-- The proposed numbers give an even game: 53 % overall, from 95 % (Big Dog against a rank-1
threat) down to 15 % (Gnome against a rank-6 threat). -/
theorem sanctuary_balance :
    overallWinChance = 53 / 100 ∧ winChance 6 1 = 19 / 20 ∧ winChance 0 6 = 3 / 20 := by
  native_decide

end RoundFour.Checks
