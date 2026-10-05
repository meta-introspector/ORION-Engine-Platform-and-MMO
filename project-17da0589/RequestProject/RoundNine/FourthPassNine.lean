module

public import Mathlib

/-!
# Round Nine, fourth pass: the new spaghetti and uploads on *ORION R9 Live*

**Round Ten correction:** the assumed scoring below is not the user's Greedy game. Its proofs are
valid only for the expressly defined *example* `greedyScore` and `greedyBust`; they make no claim
about the user's actual game. Its rulebook has not been provided.

* **Greedy (dice) in the gambling arenas.** Scoring assumed to be the common "Greed" rules:
  a single 1 scores 100, a single 5 scores 50, three of a kind score 100 × the face (three 1s score
  1000). A roll that scores nothing is a bust and loses the points built up this turn, but never
  points already banked.
  Proved: a roll scores nothing exactly when it has no 1, no 5 and no face three or more times
  (`greedy_bust_iff_score_zero`); of the 46,656 ways six dice can land, exactly 1,440 are busts
  (`greedy_six_dice_busts`), about 1 in 32; and over any sequence of rolls, busts and stops, banked
  points never go down (`greedy_bank_monotone`).
* **Betting pools with the locked 3% tax.** Winners share what is left after the tax, in proportion
  to their stakes, rounded down. Proved: the pool never pays out more than came in
  (`pool_payout_le_net`, `pool_tax_plus_payout_le_pool`), and a bigger winning stake never gets a
  smaller payout (`pool_payout_monotone`).
* **Rat Slap (Egyptian Ratscrew).** Cards only move between hands and the pile.
  Proved: the number of cards in play never changes (`ratSlap_run_total`).
* **The Newkin Council / 13-Level Gauntlet mockup.** With 13 seats and a 66% supermajority, a vote
  needs at least 9 yes votes (`gauntlet_min_yes`), so a 9–4 vote passes (`gauntlet_nine_four_passes`)
  and 9/13 shows as 69% (`gauntlet_nine_of_thirteen_pct`). But with only 7 active members, no vote
  can reach 9 yes (`gauntlet_seven_active_cannot_pass`), so the mockup's "Active council 7/13" and
  "Quorum 9/13 reached" can't both be true. The 64% Orion consensus shown is below the 66%
  threshold (`gauntlet_64_below_threshold`).
* **Engine v5.4 text filters (from `orion1.zip`).** The "Ghost Rider" filter replaces letter
  sequences anywhere, not whole words, so `skill` becomes `srenew`, `harmony` becomes `healony` and
  `whatever` becomes `wunderstandver` (`ghostRider_skill`, `ghostRider_harmony`,
  `ghostRider_whatever`). The "rind to fruit" step turns `cannot` into `can`, so a rule and its
  opposite come out as the same text (`rind_merges_opposites`), and then no later step can tell
  which one was meant (`no_recovery_of_merged`).
* **Ghostwriter-Mirror safety level.** Any score of 140 or more is reset to 0, so the safety level
  is not monotone: a more positive text can score lower (`safetyLevel_not_monotone`).
-/

@[expose] public section

namespace RoundNineFourth

/-! ## 1. Greedy (dice) -/

/-- How many of the dice in a roll show face `f` (faces are `1 … 6`). -/
def faceCount (roll : List ℕ) (f : ℕ) : ℕ := roll.count f

/-- Points for one face showing `c` times: triples first, then single 1s and 5s. -/
def faceScore (f c : ℕ) : ℕ :=
  (if f = 1 then 1000 else 100 * f) * (c / 3) +
  (if f = 1 then 100 else if f = 5 then 50 else 0) * (c % 3)

/-- Points for a whole roll (assumed common "Greed" scoring). -/
def greedyScore (roll : List ℕ) : ℕ :=
  ((List.range 6).map fun i => faceScore (i + 1) (faceCount roll (i + 1))).sum

/-- A bust: no 1, no 5, and no face three or more times. -/
def greedyBust (roll : List ℕ) : Prop :=
  faceCount roll 1 = 0 ∧ faceCount roll 5 = 0 ∧ ∀ f ∈ [2, 3, 4, 6], faceCount roll f < 3

instance (roll : List ℕ) : Decidable (greedyBust roll) := by
  unfold greedyBust; infer_instance

/-- All the ways `n` dice can land, as lists of faces. -/
def allRolls : ℕ → List (List ℕ)
  | 0 => [[]]
  | n + 1 => (allRolls n).flatMap fun r => (List.range 6).map fun i => (i + 1) :: r

theorem allRolls_length : (allRolls 6).length = 46656 := by native_decide

/-- A roll of six dice scores nothing exactly when it is a bust. -/
theorem greedy_bust_iff_score_zero :
    ∀ r ∈ allRolls 6, greedyBust r ↔ greedyScore r = 0 := by
  native_decide

/-- Of the 46,656 ways six dice can land, exactly 1,440 are busts. -/
theorem greedy_six_dice_busts : (allRolls 6).countP (fun r => decide (greedyBust r)) = 1440 := by
  native_decide

/-- The state of a Greedy turn: points already banked, and points at risk this turn. -/
structure GreedyState where
  bank : ℕ
  pot : ℕ

/-- What can happen in a turn: a roll scoring `s` points (a bust when `s = 0`), or stopping. -/
inductive GreedyMove
  | roll (s : ℕ)
  | stop

/-- One move. A bust wipes the points at risk; stopping banks them. -/
def greedyStep (st : GreedyState) : GreedyMove → GreedyState
  | .roll 0 => ⟨st.bank, 0⟩
  | .roll (s + 1) => ⟨st.bank, st.pot + (s + 1)⟩
  | .stop => ⟨st.bank + st.pot, 0⟩

/-- Banked points never go down, over any sequence of rolls, busts and stops. -/
theorem greedy_bank_monotone (moves : List GreedyMove) (st : GreedyState) :
    st.bank ≤ (moves.foldl greedyStep st).bank := by
  induction moves generalizing st with
  | nil => exact le_rfl
  | cons m ms ih =>
    refine le_trans ?_ (ih (greedyStep st m))
    cases m with
    | roll s => cases s <;> simp [greedyStep]
    | stop => simp [greedyStep]

/-! ## 2. Betting pools with the 3% tax -/

/-- The locked 3% tax on a pool (rounded down). -/
def poolTax (pool : ℕ) : ℕ := pool * 3 / 100

/-- What the winners share. -/
def poolNet (pool : ℕ) : ℕ := pool - poolTax pool

/-- A winner's payout: their share of the net, in proportion to their stake, rounded down. -/
def payout (net winTotal stake : ℕ) : ℕ := stake * net / winTotal

theorem sum_div_le (l : List ℕ) (w : ℕ) : (l.map fun a => a / w).sum ≤ l.sum / w := by
  induction l with
  | nil => simp
  | cons a l ih =>
    simp only [List.map_cons, List.sum_cons]
    exact le_trans (Nat.add_le_add_left ih _) (Nat.add_div_le_add_div _ _ _)

/-- The winners together never receive more than the net pool. -/
theorem pool_payout_le_net (pool : ℕ) (winners : List ℕ) :
    (winners.map (payout (poolNet pool) winners.sum)).sum ≤ poolNet pool := by
  rcases Nat.eq_zero_or_pos winners.sum with h | h
  · have hz : ∀ x, payout (poolNet pool) winners.sum x = 0 := fun x => by
      rw [payout, h, Nat.div_zero]
    rw [show payout (poolNet pool) winners.sum = fun _ => 0 from funext hz]
    simp
  · have hs := sum_div_le (winners.map (· * poolNet pool)) winners.sum
    have e : (winners.map (· * poolNet pool)).sum = winners.sum * poolNet pool := by
      simp [List.sum_map_mul_right]
    rw [e, Nat.mul_div_cancel_left _ h, List.map_map] at hs
    exact hs

/-- Tax plus payouts never exceed what was staked. -/
theorem pool_tax_plus_payout_le_pool (pool : ℕ) (winners : List ℕ) :
    poolTax pool + (winners.map (payout (poolNet pool) winners.sum)).sum ≤ pool := by
  have h1 := pool_payout_le_net pool winners
  have h2 : poolTax pool ≤ pool := by
    show pool * 3 / 100 ≤ pool
    omega
  have h3 : poolNet pool = pool - poolTax pool := rfl
  omega

/-- A bigger winning stake never gets a smaller payout. -/
theorem pool_payout_monotone (net winTotal : ℕ) {a b : ℕ} (h : a ≤ b) :
    payout net winTotal a ≤ payout net winTotal b :=
  Nat.div_le_div_right (Nat.mul_le_mul_right _ h)

/-! ## 3. Rat Slap -/

/-- Cards in each player's hand, and in the pile. -/
structure RatSlap (n : ℕ) where
  hand : Fin n → ℕ
  pile : ℕ

/-- Moves: player `i` plays a card onto the pile, or player `i` slaps and takes the pile. -/
inductive RatMove (n : ℕ)
  | play (i : Fin n)
  | slap (i : Fin n)

def ratStep {n : ℕ} (g : RatSlap n) : RatMove n → RatSlap n
  | .play i =>
    if g.hand i = 0 then g else ⟨Function.update g.hand i (g.hand i - 1), g.pile + 1⟩
  | .slap i => ⟨Function.update g.hand i (g.hand i + g.pile), 0⟩

/-- Cards in play. -/
def ratTotal {n : ℕ} (g : RatSlap n) : ℕ := (∑ i, g.hand i) + g.pile

theorem ratStep_total {n : ℕ} (g : RatSlap n) (m : RatMove n) :
    ratTotal (ratStep g m) = ratTotal g := by
  cases m with
  | play i =>
    simp only [ratStep]
    split_ifs with h
    · rfl
    · simp only [ratTotal]
      rw [Finset.sum_update_of_mem (Finset.mem_univ i), Finset.sdiff_singleton_eq_erase]
      have := Finset.add_sum_erase Finset.univ g.hand (Finset.mem_univ i)
      omega
  | slap i =>
    simp only [ratStep, ratTotal]
    rw [Finset.sum_update_of_mem (Finset.mem_univ i), Finset.sdiff_singleton_eq_erase]
    have := Finset.add_sum_erase Finset.univ g.hand (Finset.mem_univ i)
    omega

/-- The number of cards in play never changes, over any sequence of plays and slaps. -/
theorem ratSlap_run_total {n : ℕ} (moves : List (RatMove n)) (g : RatSlap n) :
    ratTotal (moves.foldl ratStep g) = ratTotal g := by
  induction moves generalizing g with
  | nil => rfl
  | cons m ms ih => simp only [List.foldl_cons]; rw [ih, ratStep_total]

/-! ## 4. The 13-Level Gauntlet mockup -/

/-- `yes` out of `seats` meets a `pct`% threshold. -/
def meets (yes seats pct : ℕ) : Prop := pct * seats ≤ 100 * yes

instance (yes seats pct : ℕ) : Decidable (meets yes seats pct) := by
  unfold meets; infer_instance

/-- With 13 seats and a 66% supermajority, 9 yes votes is the minimum. -/
theorem gauntlet_min_yes : meets 9 13 66 ∧ ∀ k < 9, ¬ meets k 13 66 := by decide

theorem gauntlet_nine_four_passes : meets 9 13 66 := gauntlet_min_yes.1

/-- 9 of 13 is 69% (rounded down, and also to the nearest percent). -/
theorem gauntlet_nine_of_thirteen_pct : 9 * 100 / 13 = 69 ∧ (9 * 100 * 2 + 13) / (2 * 13) = 69 := by
  decide

/-- With only 7 members active, no vote can reach the 66% supermajority of 13 seats. -/
theorem gauntlet_seven_active_cannot_pass : ∀ yes ≤ 7, ¬ meets yes 13 66 := by decide

theorem gauntlet_64_below_threshold : (64 : ℕ) < 66 := by decide

/-! ## 5. Engine v5.4 and Ghostwriter-Mirror text filters -/

/-- Replace every occurrence of `pat` by `rep`, left to right, anywhere in the text
(as the engine's `re.sub(re.escape(pattern), …)` does; `fuel` bounds the recursion). -/
def replaceAux (pat rep : List Char) : ℕ → List Char → List Char
  | 0, s => s
  | _ + 1, [] => []
  | n + 1, c :: cs =>
    if pat ≠ [] ∧ pat.isPrefixOf (c :: cs) then
      rep ++ replaceAux pat rep n ((c :: cs).drop pat.length)
    else c :: replaceAux pat rep n cs

def replaceAll (pat rep s : List Char) : List Char := replaceAux pat rep s.length s

theorem ghostRider_skill :
    replaceAll "kill".toList "renew".toList "skill orb".toList = "srenew orb".toList := by decide

theorem ghostRider_harmony :
    replaceAll "harm".toList "heal".toList "harmony".toList = "healony".toList := by decide

theorem ghostRider_whatever :
    replaceAll "hate".toList "understand".toList "whatever".toList = "wunderstandver".toList := by
  decide

/-- The "rind to fruit" word swap for negations, one word at a time: `cannot`/`can't` → `can`,
`won't` → `will` (the engine also does this for `will not` and `shouldn't`). -/
def rindWord (w : String) : String :=
  if w = "cannot" ∨ w = "can't" then "can" else if w = "won't" then "will" else w

def rind (s : List String) : List String := s.map rindWord

/-- A safety rule and its opposite come out of the "rind to fruit" step as the same text. -/
theorem rind_merges_opposites :
    rind ["minors", "cannot", "be", "contacted"] = rind ["minors", "can", "be", "contacted"] ∧
    (["minors", "cannot", "be", "contacted"] : List String) ≠ ["minors", "can", "be", "contacted"] := by
  decide

/-- Once two different texts are merged, no later step can recover which one was meant. -/
theorem no_recovery_of_merged {α β : Type*} (f : α → β) {a b : α} (hab : a ≠ b) (h : f a = f b) :
    ¬ ∃ g : β → α, ∀ x, g (f x) = x := by
  rintro ⟨g, hg⟩
  exact hab (by rw [← hg a, h, hg b])

theorem rind_not_recoverable : ¬ ∃ g : List String → List String, ∀ x, g (rind x) = x :=
  no_recovery_of_merged rind rind_merges_opposites.2 rind_merges_opposites.1

/-- Ghostwriter-Mirror's safety level from the whole-number raw score: clamp to `0 … 144`,
then reset anything `≥ 140` to `0`. -/
def safetyLevel (raw : ℤ) : ℤ :=
  let s := max 0 (min 144 raw)
  if 140 ≤ s then 0 else s

theorem safetyLevel_cliff : safetyLevel 139 = 139 ∧ safetyLevel 140 = 0 := by
  decide

/-- A more positive text can get a lower safety level. -/
theorem safetyLevel_not_monotone : ¬ Monotone safetyLevel := by
  intro h
  have := h (show (139 : ℤ) ≤ 140 by norm_num)
  rw [safetyLevel_cliff.1, safetyLevel_cliff.2] at this
  norm_num at this

end RoundNineFourth
