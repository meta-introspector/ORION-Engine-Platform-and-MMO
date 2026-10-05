module

public import Mathlib
public import RequestProject.RoundFive.RulingsFive

/-!
# Round Seven rulings: capped skills with 64 node levels, the 2% sale tax, arena and
# admin pools, the RD pool bonus, and the locked platform names

The designer's answers written into the *ORION R7 Live* page, under the copy of the Round 6
reply, stated as rules with their consequences proved.

* **Leveling.** Every skill is capped at 100 (`train_le_cap`, `train_saturates`, `le_train`),
  and a player's level is the number of the 64 character nodes unlocked. (The page first read
  "notes"; the designer corrected this to "nodes", which is the Round 3 meaning of "level".)
  Levels run from 0 to 64 (`playerLevel_le`, `playerLevel_eq_max_iff`). With skills capped at
  100, the Round 6 strength question has a concrete answer for elemental abilities (the only
  place the phoenix differs; see `FollowUpSeven`): a non-phoenix dragon at 2×–2.2× sits
  between 200 and 220 at full skill (`dragon_at_full_skill`), a phoenix at 2.42× or more sits at
  242 or more (`phoenix_at_full_skill`), and at equal skill the phoenix is at least 10% above
  every non-phoenix dragon and every normal player (`phoenix_above_at_equal_skill`). Across
  different skills this fails (`phoenix_low_skill_example`).
* **Sale tax.** When a created item or schematic is bought, 2% of the price is the creator's
  royalty and the seller keeps 98% (`sale_conserves`, `sale_seller`). If the creator hard-reset
  (anonymous flag), that 2% goes to the admin arena pool instead (`sale_anonymous`,
  `sale_tagged`).
* **Arena payouts: 2% off the total, not per contribution.** In exact arithmetic the two are the
  same (`skim_total_eq_sum`). In whole coins, rounding per contribution never takes more than
  rounding once on the total (`skimEach_le_skimTotal`) and can take less
  (`skim_rounding_example`).
* **Monthly admin pools: split evenly.** In whole coins every admin gets the same amount and
  fewer coins than there are admins are left over (`evenSplit_conserves`,
  `evenSplit_remainder_lt`, `evenSplit_example`).
* **RD pool: 2% for each original creator, 10× (20%) for a player who worked with the DEV
  team.** The payouts fit in the pool exactly when `2a + 20b ≤ 100`
  (`rdPayout_fits_iff`). Six DEV collaborators on one pool already exceed it
  (`six_collaborators_overflow`).
* **Platform names are locked.** The five hard names are recorded (`hardName`). A name changes
  only through an approval of a routed proposal: any sequence of events with no approval leaves
  every name unchanged, whoever proposed it (`names_unchanged_without_approval`), and an
  approval of something never proposed changes nothing (`approve_unproposed_noop`).
-/

@[expose] public section

namespace RoundSevenRulings

/-! ## Leveling: skills capped at 100, player level = character nodes unlocked (of 64) -/

/-- The maximum of every skill. -/
def skillCap : ℕ := 100

/-- The number of character nodes; unlocking all of them makes a level-64 player. -/
def nodeCount : ℕ := 64

/-- Training adds progress to a skill, stopping at the cap. -/
def train (s gain : ℕ) : ℕ := min skillCap (s + gain)

/-- No skill goes above 100. -/
theorem train_le_cap (s gain : ℕ) : train s gain ≤ skillCap := min_le_left _ _

/-- Training never lowers a skill that is within the cap. -/
theorem le_train (s gain : ℕ) (hs : s ≤ skillCap) : s ≤ train s gain :=
  le_min hs (Nat.le_add_right _ _)

/-- Enough training reaches exactly 100. -/
theorem train_saturates (s gain : ℕ) (h : skillCap ≤ s + gain) : train s gain = skillCap :=
  min_eq_left h

/-- A player's level: how many of the 64 character nodes they have unlocked. -/
def playerLevel (unlocked : Finset (Fin nodeCount)) : ℕ := unlocked.card

/-- Levels run from 0 to 64. -/
theorem playerLevel_le (unlocked : Finset (Fin nodeCount)) : playerLevel unlocked ≤ nodeCount := by
  simpa [playerLevel] using Finset.card_le_univ unlocked

/-- Level 64 means every character node is unlocked. -/
theorem playerLevel_eq_max_iff (unlocked : Finset (Fin nodeCount)) :
    playerLevel unlocked = nodeCount ↔ unlocked = Finset.univ := by
  unfold playerLevel
  constructor
  · intro h; exact Finset.eq_univ_of_card unlocked (by simpa using h)
  · rintro rfl; simp

/-- Ability strength: the build's multiplier times the skill. A normal player has
multiplier 1. -/
def strength (mult : ℚ) (skill : ℚ) : ℚ := mult * skill

/-- **The strength question with the cap.** A non-phoenix dragon (2× to 2.2×) at full skill 100
sits between 200 and 220. -/
theorem dragon_at_full_skill (m : ℚ) (h1 : 2 ≤ m) (h2 : m ≤ 11 / 5) :
    200 ≤ strength m 100 ∧ strength m 100 ≤ 220 := by
  unfold strength; constructor <;> linarith

/-- A phoenix at 2.42× or more sits at 242 or more at full skill. -/
theorem phoenix_at_full_skill (p : ℚ) (hp : 121 / 50 ≤ p) : 242 ≤ strength p 100 := by
  unfold strength; linarith

/-- **At equal skill the phoenix is 10% above everyone.** With the same skill `s`, a phoenix at
2.42× or more is at least 10% above every non-phoenix dragon (2.2× or less) and every normal
player (1×), using the Round 5 rule `PhoenixAbove`. -/
theorem phoenix_above_at_equal_skill (s p : ℚ) (hs : 0 ≤ s) (hp : 121 / 50 ≤ p)
    (dragonMults : List ℚ) (hd : ∀ m ∈ dragonMults, m ≤ 11 / 5) :
    RoundFiveRulings.PhoenixAbove (strength p s)
      (dragonMults.map (fun m => strength m s) ++ [strength 1 s]) :=
  RoundFiveRulings.phoenix_threshold_suffices s _ hs _ [strength 1 s]
    (by
      intro x hx
      obtain ⟨m, hm, rfl⟩ := List.mem_map.1 hx
      unfold strength; nlinarith [hd m hm])
    (by intro x hx; simp at hx; subst hx; unfold strength; linarith)
    (by unfold strength; nlinarith)

/-- Across different skills the 10% rule does not hold: a phoenix at skill 50 (121) is below a
2× dragon at skill 100 (200). -/
theorem phoenix_low_skill_example : strength (121 / 50) 50 < strength 2 100 := by
  norm_num [strength]

/-! ## Sale tax: 2% of the price to the creator, or to the admin arena pool if anonymous -/

/-- The tax rate on sales of created items and schematics. -/
def saleRate : ℚ := 2 / 100

/-- Where the money from one sale goes. -/
structure SaleSplit where
  /-- The seller. -/
  seller : ℚ
  /-- The creator named by the item's character/user tag. -/
  creator : ℚ
  /-- The admin arena pool. -/
  adminPool : ℚ

/-- Splitting a sale at `price`; `anonymous` is the hard-reset flag on the item. -/
def sale (price : ℚ) (anonymous : Bool) : SaleSplit :=
  { seller := (1 - saleRate) * price
    creator := if anonymous then 0 else saleRate * price
    adminPool := if anonymous then saleRate * price else 0 }

/-- Nothing is created or lost in a sale. -/
theorem sale_conserves (price : ℚ) (anonymous : Bool) :
    (sale price anonymous).seller + (sale price anonymous).creator
      + (sale price anonymous).adminPool = price := by
  cases anonymous <;> simp [sale] <;> ring

/-- The seller always keeps 98%. -/
theorem sale_seller (price : ℚ) (anonymous : Bool) :
    (sale price anonymous).seller = 98 / 100 * price := by
  simp only [sale, saleRate]; ring

/-- A tagged item pays its creator 2% and the admin pool nothing. -/
theorem sale_tagged (price : ℚ) :
    (sale price false).creator = 2 / 100 * price ∧ (sale price false).adminPool = 0 := by
  simp [sale, saleRate]

/-- An anonymous (hard-reset) item pays 2% to the admin arena pool and nothing to a creator. -/
theorem sale_anonymous (price : ℚ) :
    (sale price true).creator = 0 ∧ (sale price true).adminPool = 2 / 100 * price := by
  simp [sale, saleRate]

/-! ## Arena payouts: 2% off the total before allocation -/

/-- In exact arithmetic, 2% of the total equals the sum of 2% of each contribution. -/
theorem skim_total_eq_sum (cs : List ℚ) :
    saleRate * cs.sum = (cs.map (fun c => saleRate * c)).sum := by
  induction cs with
  | nil => simp
  | cons c cs ih => simp [List.sum_cons, mul_add, ih]

/-- 2% of the total, rounded down once, in whole coins. -/
def skimTotal (cs : List ℕ) : ℕ := cs.sum * 2 / 100

/-- 2% of each contribution, each rounded down, in whole coins. -/
def skimEach (cs : List ℕ) : ℕ := (cs.map (fun c => c * 2 / 100)).sum

/-- Rounding per contribution never takes more than rounding once on the total. -/
theorem skimEach_le_skimTotal (cs : List ℕ) : skimEach cs ≤ skimTotal cs := by
  induction cs with
  | nil => simp [skimEach, skimTotal]
  | cons c cs ih =>
    simp only [skimEach, skimTotal, List.map_cons, List.sum_cons] at ih ⊢
    calc c * 2 / 100 + (cs.map (fun c => c * 2 / 100)).sum
        ≤ c * 2 / 100 + cs.sum * 2 / 100 := Nat.add_le_add_left ih _
      _ ≤ (c * 2 + cs.sum * 2) / 100 := Nat.add_div_le_add_div _ _ _
      _ = (c + cs.sum) * 2 / 100 := by rw [add_mul]

/-- Two contributions of 49 coins: per contribution the skim is 0, on the total it is 1. -/
theorem skim_rounding_example : skimEach [49, 49] = 0 ∧ skimTotal [49, 49] = 1 := by decide

/-! ## Monthly admin pools: split evenly among admins -/

/-- Each admin's share of a pool of `pool` coins among `admins` admins. -/
def evenShare (pool admins : ℕ) : ℕ := pool / admins

/-- The even shares plus the leftover make up the pool. -/
theorem evenSplit_conserves (pool admins : ℕ) :
    admins * evenShare pool admins + pool % admins = pool := Nat.div_add_mod _ _

/-- Fewer coins than there are admins are left over. -/
theorem evenSplit_remainder_lt (pool admins : ℕ) (h : 0 < admins) : pool % admins < admins :=
  Nat.mod_lt _ h

/-- 100 coins among 3 admins: 33 each, 1 left over. -/
theorem evenSplit_example : evenShare 100 3 = 33 ∧ 100 % 3 = 1 := by decide

/-! ## RD pool: 2% per original creator, 10× for players who worked with the DEV team -/

/-- Total percentage of an RD pool paid out to `a` original creators at 2% each and `b` DEV
collaborators at 10 × 2% = 20% each. -/
def rdPercent (a b : ℕ) : ℕ := 2 * a + 10 * 2 * b

/-- The payouts fit in the pool exactly when the percentages add to at most 100. -/
theorem rdPayout_fits_iff (a b : ℕ) (R : ℚ) (hR : 0 < R) :
    (rdPercent a b : ℚ) / 100 * R ≤ R ↔ 2 * a + 20 * b ≤ 100 := by
  have key : (rdPercent a b : ℚ) / 100 * R ≤ R ↔ (rdPercent a b : ℚ) ≤ 100 := by
    constructor
    · intro h
      by_contra hc
      push_neg at hc
      have : R < (rdPercent a b : ℚ) / 100 * R := by
        have : (1 : ℚ) < (rdPercent a b : ℚ) / 100 := by
          rw [lt_div_iff₀ (by norm_num)]; linarith
        nlinarith
      linarith
    · intro h
      have : (rdPercent a b : ℚ) / 100 ≤ 1 := by
        rw [div_le_iff₀ (by norm_num)]; linarith
      nlinarith
  rw [key, rdPercent]
  constructor
  · intro h; exact_mod_cast (show ((2 * a + 20 * b : ℕ) : ℚ) ≤ 100 by push_cast at h ⊢; linarith)
  · intro h; exact_mod_cast (show 2 * a + 10 * 2 * b ≤ 100 by omega)

/-- Six DEV collaborators on one RD pool would be owed 120% of it. -/
theorem six_collaborators_overflow : rdPercent 0 6 = 120 ∧ 100 < rdPercent 0 6 := by decide

/-! ## Platform names: locked; changes only through an approved, routed proposal -/

/-- The five platforms named on the R7 page. -/
inductive Platform where
  | engine | gate | playground | chronicles | ascent
  deriving DecidableEq, Repr

/-- The hard names, locked until specifically changed. -/
def hardName : Platform → String
  | .engine => "The ORION Engine"
  | .gate => "ORION's Gate"
  | .playground => "The Playground"
  | .chronicles => "The Orion Chronicles"
  | .ascent => "The Ascent"

/-- What can happen to a name. Anyone, including the project owner, can only *propose*. -/
inductive NameEvent (Person : Type) where
  | propose (who : Person) (p : Platform) (name : String)
  | approve (p : Platform) (name : String)

/-- The current names and the proposals waiting for approval. -/
structure NameState where
  names : Platform → String
  pending : List (Platform × String)

/-- One event. A proposal is only queued; an approval applies a queued proposal. -/
def NameEvent.apply {Person : Type} (st : NameState) : NameEvent Person → NameState
  | .propose _ p name => { st with pending := (p, name) :: st.pending }
  | .approve p name =>
    if (p, name) ∈ st.pending then
      { names := Function.update st.names p name
        pending := st.pending.erase (p, name) }
    else st

/-- Run a list of events. -/
def runNames {Person : Type} (st : NameState) (evs : List (NameEvent Person)) : NameState :=
  evs.foldl NameEvent.apply st

/-- Whether an event is an approval. -/
def NameEvent.isApproval {Person : Type} : NameEvent Person → Bool
  | .propose .. => false
  | .approve .. => true

/-- **No exceptions.** Without an approval, no name ever changes, whoever proposes. -/
theorem names_unchanged_without_approval {Person : Type} (st : NameState)
    (evs : List (NameEvent Person)) (h : ∀ e ∈ evs, e.isApproval = false) :
    (runNames st evs).names = st.names := by
  induction evs generalizing st with
  | nil => rfl
  | cons e evs ih =>
    simp only [runNames, List.foldl_cons] at ih ⊢
    rw [ih _ (fun e' he' => h e' (List.mem_cons_of_mem _ he'))]
    cases e with
    | propose => rfl
    | approve => simp [NameEvent.isApproval] at h

/-- Approving something that was never proposed changes nothing. -/
theorem approve_unproposed_noop {Person : Type} (st : NameState) (p : Platform) (name : String)
    (h : (p, name) ∉ st.pending) :
    (NameEvent.approve (Person := Person) p name).apply st = st := by
  simp [NameEvent.apply, h]

/-- An approved proposal sets exactly that platform's name. -/
theorem approve_sets_name {Person : Type} (st : NameState) (p : Platform) (name : String)
    (h : (p, name) ∈ st.pending) :
    ((NameEvent.approve (Person := Person) p name).apply st).names p = name ∧
      ∀ q, q ≠ p →
        ((NameEvent.approve (Person := Person) p name).apply st).names q = st.names q := by
  simp only [NameEvent.apply, h, if_true]
  exact ⟨by simp, fun q hq => by simp [Function.update_of_ne hq]⟩

end RoundSevenRulings
