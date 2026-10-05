module

public import Mathlib

/-!
# Round Seven, third pass: skill orbs, a split-focus phoenix, and the arena tax at 3% and 5%

Answers written onto the *ORION R7 Live* page under the second Round 7 reply.

* **Skill orbs (designer's clarification).** Each of the 64 character nodes holds a skill orb. An
  orb is levelled one step at a time up to 100. At 100 it is gold-locked, and only a gold-locked
  orb can be ported to the dragon matrix (`portable_iff_goldLocked`). From 0 this takes exactly
  100 level-ups (`levelUps_to_goldLock`). Every orb on the dragon matrix is gold-locked
  (`ported_all_goldLocked`). Once the dragon matrix is in play, a new orb takes the dragon's skill
  level directly instead of being levelled again (`slotOnDragon`).
* **Phoenix (proposal: replaces the Round 5 "at least 10% above" rule if approved).** Every extra
  active element costs focus: with `k` active elements, each element works at
  `1 - d × (k - 1)` of full strength. A phoenix with all five elements active is then weaker in
  each element than any one-element dragon at equal skill, as long as `d > 1/44`
  (`phoenix_below_every_dragon`), and `1/44` is the exact boundary (`focus_boundary_needed`). It
  stays at or above an ordinary player as long as `d ≤ 1/8` (`phoenix_at_least_player`).
* **Arena tax at any whole-number rate (2%, 3%, 5%).** Rounding once on the total never collects
  less than rounding each contribution (`skimEachAt_le_skimTotalAt`), and the gap is smaller than
  the number of contributions (`skimTotalAt_lt_skimEachAt_add`). Amounts below `⌈100 / rate⌉`
  pay no tax (`taxAt_eq_zero_iff`): below 50 coins at 2%, 34 at 3%, 20 at 5%.
-/

@[expose] public section

namespace RoundSevenThirdPass

/-! ## Skill orbs: level to 100, gold-lock, then port to the dragon matrix -/

/-- The level at which an orb gold-locks. -/
def orbCap : ℕ := 100

/-- Number of character nodes (one orb each). -/
def humanNodes : ℕ := 64

/-- Number of nodes on the dragon matrix. -/
def dragonNodes : ℕ := 144

/-- One level-up: one step, never past 100. -/
def levelUp (l : ℕ) : ℕ := min orbCap (l + 1)

/-- An orb is gold-locked when it has reached 100. -/
def GoldLocked (l : ℕ) : Prop := l = orbCap

/-- Only a gold-locked orb may be ported to the dragon matrix. -/
def Portable (l : ℕ) : Prop := GoldLocked l

theorem portable_iff_goldLocked (l : ℕ) : Portable l ↔ l = 100 := Iff.rfl

/-- A level-up never passes 100. -/
theorem levelUp_le_cap (l : ℕ) : levelUp l ≤ orbCap := min_le_left _ _

/-- After `n` level-ups from 0, the orb is at level `min 100 n`. -/
theorem iterate_levelUp (n : ℕ) : levelUp^[n] 0 = min orbCap n := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Function.iterate_succ_apply', ih]
    simp only [levelUp, orbCap]
    omega

/-- **Exactly 100 level-ups.** From level 0, the orb is gold-locked after `n` level-ups exactly
when `n ≥ 100`. -/
theorem levelUps_to_goldLock (n : ℕ) : GoldLocked (levelUp^[n] 0) ↔ 100 ≤ n := by
  rw [iterate_levelUp]; simp only [GoldLocked, orbCap]; omega

/-- A player's level: the number of gold-locked orbs among the 64 nodes. -/
def playerLevel (orbs : Fin humanNodes → ℕ) : ℕ :=
  (Finset.univ.filter (fun i => orbs i = orbCap)).card

theorem playerLevel_le (orbs : Fin humanNodes → ℕ) : playerLevel orbs ≤ 64 := by
  unfold playerLevel
  exact (Finset.card_filter_le _ _).trans (by simp [humanNodes])

/-- **Level 64** means every one of the 64 orbs is gold-locked. -/
theorem playerLevel_eq_64_iff (orbs : Fin humanNodes → ℕ) :
    playerLevel orbs = 64 ↔ ∀ i, GoldLocked (orbs i) := by
  unfold playerLevel GoldLocked
  have : (Finset.univ : Finset (Fin humanNodes)).card = 64 := by simp [humanNodes]
  constructor
  · intro h i
    rw [← this, Finset.card_filter_eq_iff] at h
    exact h i (Finset.mem_univ i)
  · intro h
    rw [Finset.filter_true_of_mem (fun i _ => h i), this]

/-- The dragon matrix: each of the 144 nodes is empty or holds an orb at some level. -/
abbrev DragonMatrix := Fin dragonNodes → Option ℕ

/-- Port an orb into a node; refused (matrix unchanged) unless the orb is gold-locked. -/
def port (m : DragonMatrix) (node : Fin dragonNodes) (l : ℕ) : DragonMatrix :=
  if l = orbCap then Function.update m node (some l) else m

/-- Slot a new orb on the dragon: it takes the dragon's skill level for that skill directly. -/
def slotOnDragon (m : DragonMatrix) (node : Fin dragonNodes) (dragonSkill : ℕ) : DragonMatrix :=
  Function.update m node (some dragonSkill)

/-- Every occupied node holds a gold-locked orb. -/
def AllGoldLocked (m : DragonMatrix) : Prop := ∀ i l, m i = some l → GoldLocked l

/-- A port refused for an orb below 100 leaves the matrix unchanged. -/
theorem port_refused (m : DragonMatrix) (node : Fin dragonNodes) (l : ℕ) (h : l ≠ orbCap) :
    port m node l = m := by simp [port, h]

/-- **Only gold-locked orbs reach the dragon.** Starting from an empty matrix, any sequence of
port attempts leaves every occupied node gold-locked. -/
theorem ported_all_goldLocked (moves : List (Fin dragonNodes × ℕ)) :
    AllGoldLocked (moves.foldl (fun m mv => port m mv.1 mv.2) (fun _ => none)) := by
  suffices ∀ m, AllGoldLocked m →
      AllGoldLocked (moves.foldl (fun m mv => port m mv.1 mv.2) m) from
    this _ (fun _ _ h => by simp at h)
  induction moves with
  | nil => intro m h; exact h
  | cons mv moves ih =>
    intro m hm
    apply ih
    intro i l hi
    dsimp only at hi
    unfold port at hi
    split_ifs at hi with hc
    · rcases eq_or_ne i mv.1 with rfl | hne
      · simp at hi; subst hi; exact hc
      · rw [Function.update_of_ne hne] at hi; exact hm i l hi
    · exact hm i l hi

/-- Slotting on the dragon sets the orb to the dragon's skill level at once. -/
theorem slotOnDragon_level (m : DragonMatrix) (node : Fin dragonNodes) (s : ℕ) :
    slotOnDragon m node s node = some s := by simp [slotOnDragon]

/-- The dragon matrix is the 64 character nodes plus 80 dragon nodes. -/
theorem dragonNodes_split : dragonNodes = humanNodes + 80 := rfl

/-! ## Phoenix (proposal): every extra active element costs focus -/

/-- Focus with `k` active elements: each element works at `1 - d (k - 1)` of full strength. -/
def focus (d : ℚ) (k : ℕ) : ℚ := 1 - d * ((k : ℚ) - 1)

/-- Per-element power: dragon multiplier × focus × skill. -/
def elemPower (mult d : ℚ) (k : ℕ) (skill : ℚ) : ℚ := mult * focus d k * skill

/-- One active element means full focus. -/
theorem focus_one (d : ℚ) : focus d 1 = 1 := by simp [focus]

/-- More active elements never raise per-element strength (for `d ≥ 0`). -/
theorem focus_antitone (d : ℚ) (hd : 0 ≤ d) {j k : ℕ} (hjk : j ≤ k) : focus d k ≤ focus d j := by
  unfold focus
  have : (j : ℚ) ≤ k := by exact_mod_cast hjk
  nlinarith

/-- **A five-element phoenix is weaker per element than any one-element dragon.** Dragons sit
between 2× and 2.2× (the phoenix too). If `d > 1/44`, then at equal positive skill, every
element of a phoenix with all five active is strictly weaker than the same element of any
one-element dragon. -/
theorem phoenix_below_every_dragon (d pm dm s : ℚ) (hd : 1 / 44 < d) (hs : 0 < s)
    (hpm : pm ≤ 11 / 5) (hpm0 : 0 ≤ pm) (hdm : 2 ≤ dm) :
    elemPower pm d 5 s < elemPower dm d 1 s := by
  unfold elemPower
  rw [focus_one]
  unfold focus
  push_cast
  have h1 : pm * (1 - d * (5 - 1)) < 2 := by
    rcases le_or_gt 0 (1 - d * (5 - 1)) with hx | hx
    · calc pm * (1 - d * (5 - 1)) ≤ 11 / 5 * (1 - d * (5 - 1)) :=
            mul_le_mul_of_nonneg_right hpm hx
        _ < 2 := by linarith
    · nlinarith
  have h2 : pm * (1 - d * (5 - 1)) < dm := by linarith
  nlinarith

/-- **`1/44` is the exact boundary.** At `d = 1/44`, a 2.2× phoenix with all five elements ties a
2× dragon, so the strict guarantee needs `d > 1/44`. -/
theorem focus_boundary_needed (s : ℚ) : elemPower (11 / 5) (1 / 44) 5 s = elemPower 2 (1 / 44) 1 s := by
  simp only [elemPower, focus]; push_cast; ring

/-- **Still above an ordinary player.** If `d ≤ 1/8`, a phoenix (at least 2×) with all five
elements active is still at least as strong per element as a non-dragon player (1×). -/
theorem phoenix_at_least_player (d pm s : ℚ) (hd : d ≤ 1 / 8) (hs : 0 ≤ s) (hpm : 2 ≤ pm) :
    1 * s ≤ elemPower pm d 5 s := by
  unfold elemPower focus
  push_cast
  have : 1 ≤ pm * (1 - d * (5 - 1)) := by nlinarith
  nlinarith

/-- Example with `d = 5%`: a five-element phoenix works at 80% per element, so 1.6× to 1.76× of a
player, below every one-element dragon (2× to 2.2×). -/
theorem focus_example : focus (5 / 100) 5 = 4 / 5 ∧ 2 * focus (5 / 100) 5 = 8 / 5 ∧
    11 / 5 * focus (5 / 100) 5 = 44 / 25 := by
  simp only [focus]; norm_num

/-! ## Arena and sale tax at any whole-number rate -/

/-- Tax at `rate`% of an amount, in whole coins, rounded in the player's favour. -/
def taxAt (rate x : ℕ) : ℕ := x * rate / 100

/-- Taking `rate`% of the total, rounded once. -/
def skimTotalAt (rate : ℕ) (cs : List ℕ) : ℕ := taxAt rate cs.sum

/-- Taking `rate`% of each contribution, each rounded. -/
def skimEachAt (rate : ℕ) (cs : List ℕ) : ℕ := (cs.map (taxAt rate)).sum

/-- **Rounding per contribution never takes more**, at any rate. -/
theorem skimEachAt_le_skimTotalAt (rate : ℕ) (cs : List ℕ) :
    skimEachAt rate cs ≤ skimTotalAt rate cs := by
  induction cs with
  | nil => simp [skimEachAt, skimTotalAt, taxAt]
  | cons c cs ih =>
    simp only [skimEachAt, skimTotalAt, taxAt, List.map_cons, List.sum_cons] at ih ⊢
    calc c * rate / 100 + (cs.map (fun x => x * rate / 100)).sum
        ≤ c * rate / 100 + cs.sum * rate / 100 := Nat.add_le_add_left ih _
      _ ≤ (c * rate + cs.sum * rate) / 100 := Nat.add_div_le_add_div _ _ _
      _ = (c + cs.sum) * rate / 100 := by rw [add_mul]

/-- **The gap is less than one coin per contribution**, at any rate. -/
theorem skimTotalAt_lt_skimEachAt_add (rate : ℕ) (cs : List ℕ) :
    skimTotalAt rate cs < skimEachAt rate cs + cs.length + 1 := by
  induction cs with
  | nil => simp [skimEachAt, skimTotalAt, taxAt]
  | cons c cs ih =>
    simp only [skimEachAt, skimTotalAt, taxAt, List.map_cons, List.sum_cons,
      List.length_cons] at ih ⊢
    have h := Nat.add_div_le_add_div (c * rate) (cs.sum * rate) 100
    have key : (c * rate + cs.sum * rate) / 100 ≤ c * rate / 100 + cs.sum * rate / 100 + 1 := by
      omega
    rw [add_mul]
    omega

/-- **Small amounts pay nothing.** The tax on `x` is 0 exactly when `x × rate < 100`. -/
theorem taxAt_eq_zero_iff (rate x : ℕ) : taxAt rate x = 0 ↔ x * rate < 100 := by
  unfold taxAt; constructor
  · intro h; by_contra h'; push_neg at h'
    have := Nat.div_pos h' (by norm_num : 0 < 100); omega
  · intro h; exact Nat.div_eq_of_lt h

/-- The tax-free thresholds: under 50 coins at 2%, under 34 at 3%, under 20 at 5%. -/
theorem thresholds :
    (taxAt 2 49 = 0 ∧ taxAt 2 50 = 1) ∧ (taxAt 3 33 = 0 ∧ taxAt 3 34 = 1) ∧
    (taxAt 5 19 = 0 ∧ taxAt 5 20 = 1) := by decide

/-- The 49 + 49 example at 2%, 3% and 5%. Per contribution: 0, 2, 4. From the total: 1, 2, 4. -/
theorem example_49_49 :
    (skimEachAt 2 [49, 49], skimTotalAt 2 [49, 49]) = (0, 1) ∧
    (skimEachAt 3 [49, 49], skimTotalAt 3 [49, 49]) = (2, 2) ∧
    (skimEachAt 5 [49, 49], skimTotalAt 5 [49, 49]) = (4, 4) := by decide

/-- Ten contributions of 19 coins (pool 190): per contribution 0 at every rate; from the total
3, 5 and 9 coins. -/
theorem example_ten_19 :
    (skimEachAt 2 (List.replicate 10 19), skimTotalAt 2 (List.replicate 10 19)) = (0, 3) ∧
    (skimEachAt 3 (List.replicate 10 19), skimTotalAt 3 (List.replicate 10 19)) = (0, 5) ∧
    (skimEachAt 5 (List.replicate 10 19), skimTotalAt 5 (List.replicate 10 19)) = (0, 9) := by
  decide

/-- A 1,000-coin sale pays 20, 30 and 50 coins at 2%, 3% and 5%. -/
theorem example_1000 : taxAt 2 1000 = 20 ∧ taxAt 3 1000 = 30 ∧ taxAt 5 1000 = 50 := by decide

/-- Sale split at `rate`%: seller keeps the rest; nothing is created or lost. -/
theorem sale_split_conserves (rate price : ℕ) (h : rate ≤ 100) :
    (price - taxAt rate price) + taxAt rate price = price := by
  have : taxAt rate price ≤ price := by
    unfold taxAt
    calc price * rate / 100 ≤ price * 100 / 100 := Nat.div_le_div_right (Nat.mul_le_mul_left _ h)
      _ = price := by simp
  omega

end RoundSevenThirdPass
