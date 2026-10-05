module

public import Mathlib
public import RequestProject.RoundFive.RulingsFive
public import RequestProject.Zoo.Arena

/-!
# Round Six rulings: three strikes for the council, a 2% arena tax on anonymous
# contributions, and the 50 / 47 / 43 Monolithic Zoo taxonomy

The designer's answers written into the *ORION R6* page, under the copy of the previous reply,
plus Matthew's Zoo input on the same page, stated as rules with their consequences proved.

* **Council: three strikes and you're out, with a 7-day retry timer.** A *strike* is a
  reassessment round in which a seat that voted yes in the first round now votes no. Under the
  Round 5 rule such a round forces another reassessment. Now the third strike ends the motion:
  it is struck out (`deliberate6`). The council therefore always decides within three
  reassessments (`decides_within_three`). Only the first three reassessments matter
  (`only_three_rounds_matter`), three spreading rounds strike the motion out
  (`three_strikes_out`), and before the third strike the Round 5 rule is unchanged
  (`agrees_with_round_five`, `pass_has_four_fifths6`). A struck-out motion can be brought back
  exactly from seven days after the strike (`retry_allowed_iff`).
* **Royalties: a 2% arena tax instead of removing the share.** Records of a hard-reset user are
  anonymous contributions. Instead of sending the whole royalty share to the developer arenas
  (Round 5), the arenas take a tax rate `τ` of it, and the rest still goes to the
  contributor's (anonymous) account (`arenaTake`, `holderTake`). After a hard reset the arenas
  gain exactly `τ` times the user's share (`taxReset_arena_gain`), the user keeps `1 - τ` of it
  (`taxReset_user_keeps`), other users are unchanged (`taxReset_other_user`), and nothing is
  created or lost (`tax_split_conserves`). At `τ = 1` this is the Round 5 rule
  (`full_tax_is_round_five`). At `τ = 2%` the arenas take 2 and the contributor keeps 98 of every
  100 (`two_percent_example`).
* **Monolithic Zoo: 50 = 47 animal names + 3 conceptual animals; 47 = 43 core + 4.** PULSE, HIVE
  and SHEPHARD are Zoo "animals" but not animal names. CHIMERA, WOODPECKER, NIGHTENGALE and
  HUMMINGBIRD form the 47–50 extension band. Taking the 46-animal Core list from the earlier
  design compilation and removing PULSE, HIVE and SHEPHERD leaves exactly 43 distinct animal
  names (`coreAnimalNames_spec`). With the extension band they make 47 distinct names
  (`animalNames_spec`), and with the three conceptual animals 50 distinct Zoo entries
  (`monolithicZoo_spec`).
-/

@[expose] public section

namespace RoundSixRulings

open RoundFourRulings RoundFourRulingsTwo RoundFourRulingsThree RoundFourRulingsFour
open RoundFiveRulings

/-! ## Council: three strikes and you're out -/

/-- What happens to a motion. -/
inductive Outcome where
  /-- Passed with 4/5 approval in the round of record. -/
  | passed
  /-- Settled below 4/5. -/
  | rejected
  /-- Third strike: the motion is out and can be retried after the timer. -/
  | struckOut
  /-- Still being reassessed. -/
  | pending
  deriving DecidableEq, Repr

/-- The number of strikes after which a motion is out. -/
def strikeLimit : ℕ := 3

/-- Run the reassessment rounds in order, counting strikes. A round with a new no is a strike.
The third strike ends the motion. A round with only original noes settles it by the 4/5 rule. -/
def deliberate6 {n : ℕ} (first : Fin n → Bool) : ℕ → List (Fin n → Bool) → Outcome
  | _, [] => .pending
  | k, r :: rest =>
    if hasNewNay first r then
      if k + 1 = strikeLimit then .struckOut else deliberate6 first (k + 1) rest
    else if council (List.ofFn r) then .passed else .rejected

/-- The council's decision under the three-strikes rule: a unanimous first round passes at
once; otherwise the reassessment rounds decide, starting with no strikes. -/
def decide6 {n : ℕ} (first : Fin n → Bool) (rounds : List (Fin n → Bool)) : Outcome :=
  if ∀ i, first i = true then .passed else deliberate6 first 0 rounds

/-- **A unanimous first round passes.** -/
theorem unanimous_passes6 {n : ℕ} (first : Fin n → Bool) (rounds : List (Fin n → Bool))
    (h : ∀ i, first i = true) : decide6 first rounds = .passed := by
  simp [decide6, h]

/-- **Three spreading rounds strike the motion out**, whatever would have come after. -/
theorem three_strikes_out {n : ℕ} (first r₁ r₂ r₃ : Fin n → Bool) (rest : List (Fin n → Bool))
    (h₁ : hasNewNay first r₁ = true) (h₂ : hasNewNay first r₂ = true)
    (h₃ : hasNewNay first r₃ = true) :
    deliberate6 first 0 (r₁ :: r₂ :: r₃ :: rest) = .struckOut := by
  simp [deliberate6, h₁, h₂, h₃, strikeLimit]

theorem deliberate6_take {n : ℕ} (first : Fin n → Bool) :
    ∀ (k : ℕ) (rounds : List (Fin n → Bool)), k < strikeLimit →
      deliberate6 first k rounds = deliberate6 first k (rounds.take (strikeLimit - k))
  | _, [], _ => by simp
  | k, r :: rest, hk => by
    have hpos : strikeLimit - k = (strikeLimit - (k + 1)) + 1 := by omega
    rw [hpos, List.take_succ_cons]
    simp only [deliberate6]
    split_ifs with h1 h2
    · rfl
    · exact deliberate6_take first (k + 1) rest (by omega)
    · rfl
    · rfl

/-- **Only the first three reassessments matter.** -/
theorem only_three_rounds_matter {n : ℕ} (first : Fin n → Bool) (rounds : List (Fin n → Bool)) :
    deliberate6 first 0 rounds = deliberate6 first 0 (rounds.take 3) :=
  deliberate6_take first 0 rounds (by decide)

theorem deliberate6_decides {n : ℕ} (first : Fin n → Bool) :
    ∀ (k : ℕ) (rounds : List (Fin n → Bool)), k < strikeLimit →
      strikeLimit - k ≤ rounds.length → deliberate6 first k rounds ≠ .pending
  | k, [], hk, hl => by simp at hl; omega
  | k, r :: rest, hk, hl => by
    simp only [deliberate6]
    split_ifs with h1 h2
    · simp
    · exact deliberate6_decides first (k + 1) rest (by omega) (by simp at hl; omega)
    · simp
    · simp

/-- **The council always decides within three reassessments**: after three reassessment
rounds the motion has passed, been rejected, or been struck out. Compare
`RoundFiveRulings.endless_without_cap`, which shows the Round 5 rule alone could go on forever. -/
theorem decides_within_three {n : ℕ} (first : Fin n → Bool) (rounds : List (Fin n → Bool))
    (h : 3 ≤ rounds.length) : decide6 first rounds ≠ .pending := by
  unfold decide6
  split_ifs
  · simp
  · exact deliberate6_decides first 0 rounds (by decide) (by simpa [strikeLimit] using h)

/-- Read a Round 5 decision as an outcome. -/
def ofRoundFive : Option Bool → Outcome
  | some true => .passed
  | some false => .rejected
  | none => .pending

theorem deliberate6_agrees {n : ℕ} (first : Fin n → Bool) :
    ∀ (k : ℕ) (rounds : List (Fin n → Bool)), deliberate6 first k rounds ≠ .struckOut →
      deliberate6 first k rounds = ofRoundFive (deliberate first rounds)
  | _, [], _ => by simp [deliberate6, deliberate, ofRoundFive]
  | k, r :: rest, h => by
    by_cases h1 : hasNewNay first r = true
    · by_cases h2 : k + 1 = strikeLimit
      · simp [deliberate6, h1, h2] at h
      · have h' : deliberate6 first (k + 1) rest ≠ .struckOut := by
          simpa [deliberate6, h1, h2] using h
        rw [new_nay_forces_another_round first r rest h1]
        simpa [deliberate6, h1, h2] using deliberate6_agrees first (k + 1) rest h'
    · have h1' : hasNewNay first r = false := by simpa using h1
      rw [settles_on_original_nays first r rest h1']
      cases hc : council (List.ofFn r) <;> simp [deliberate6, h1', hc, ofRoundFive]

/-- **Before the third strike nothing changes**: whenever the motion is not struck out, the
three-strikes rule gives exactly the Round 5 result. -/
theorem agrees_with_round_five {n : ℕ} (first : Fin n → Bool) (rounds : List (Fin n → Bool))
    (h : decide6 first rounds ≠ .struckOut) :
    decide6 first rounds = ofRoundFive (decide5 first rounds) := by
  unfold decide6 decide5 at *
  split_ifs at * with hu
  · rfl
  · exact deliberate6_agrees first 0 rounds h

/-- **Passing still means 4/5 approval in the round of record.** -/
theorem pass_has_four_fifths6 {n : ℕ} (first : Fin n → Bool) (rounds : List (Fin n → Bool))
    (h : decide6 first rounds = .passed) :
    (∀ i, first i = true) ∨
      ∃ r ∈ rounds, hasNewNay first r = false ∧ 5 * (List.ofFn r).count false ≤ n := by
  have hne : decide6 first rounds ≠ .struckOut := by rw [h]; decide
  have h5 := agrees_with_round_five first rounds hne
  rw [h] at h5
  apply pass_has_four_fifths5
  cases hd : decide5 first rounds with
  | none => simp [hd, ofRoundFive] at h5
  | some b =>
    cases b
    · rw [hd] at h5; exact absurd h5 (by decide)
    · rfl

/-- Days a struck-out motion must wait before it can be brought back. -/
def retryWait : ℕ := 7

/-- A motion struck out on day `struckOn` may be brought back on day `today`. -/
def mayRetry (struckOn today : ℕ) : Bool := decide (struckOn + retryWait ≤ today)

/-- **The 7-day timer**: a struck-out motion can be brought back exactly from seven days after
the strike. -/
theorem retry_allowed_iff (struckOn today : ℕ) :
    mayRetry struckOn today = true ↔ struckOn + 7 ≤ today := by
  simp [mayRetry, retryWait]

/-- Example (five seats): seat 0 votes no; each of the next three reassessments brings a new no
from a different seat, so the third strike puts the motion out. -/
theorem three_strikes_example :
    decide6 (n := 5) ![false, true, true, true, true]
      [![true, false, true, true, true], ![true, true, false, true, true],
       ![true, true, true, false, true]] = .struckOut := by
  decide

/-- Example (five seats): two strikes, then a round with only the original no: the motion
passes. -/
theorem two_strikes_then_pass_example :
    decide6 (n := 5) ![false, true, true, true, true]
      [![true, false, true, true, true], ![true, true, false, true, true],
       ![false, true, true, true, true]] = .passed := by
  decide

/-! ## Royalties: a 2% arena tax on anonymous contributions -/

/-- What the developer arenas receive over `recs` when they take rate `τ` of every
hard-reset (anonymous) record's royalties. -/
noncomputable def arenaTake {ι U : Type} [DecidableEq U] (w : World ι U) (τ : ℚ)
    (amt : ι → ℚ) (recs : Finset ι) : ℚ :=
  ∑ i ∈ recs, if (w.records i).creator ∈ w.reset then τ * amt i else 0

/-- What user `u`'s account receives over `recs`: the full royalty on records of a user who has
not hard-reset, and the remaining `1 - τ` on anonymous records. -/
noncomputable def holderTake {ι U : Type} [DecidableEq U] (w : World ι U) (τ : ℚ)
    (amt : ι → ℚ) (recs : Finset ι) (u : U) : ℚ :=
  ∑ i ∈ recs.filter (fun i => (w.records i).creator = u),
    if (w.records i).creator ∈ w.reset then (1 - τ) * amt i else amt i

/-- User `u`'s full royalty share over `recs`. -/
noncomputable def share {ι U : Type} [DecidableEq U] (w : World ι U) (amt : ι → ℚ) (recs : Finset ι)
    (u : U) : ℚ :=
  ∑ i ∈ recs.filter (fun i => (w.records i).creator = u), amt i

/-- **Nothing is created or lost**: on every record the arenas' tax and the account's part add up
to the record's royalty. -/
theorem tax_split_conserves {ι U : Type} [DecidableEq U] (w : World ι U) (τ : ℚ)
    (amt : ι → ℚ) (i : ι) :
    (if (w.records i).creator ∈ w.reset then τ * amt i else 0) +
      (if (w.records i).creator ∈ w.reset then (1 - τ) * amt i else amt i) = amt i := by
  split_ifs <;> ring

/-- **A hard reset moves exactly `τ` of that user's share into the arenas.** -/
theorem taxReset_arena_gain {ι U : Type} [DecidableEq U] (w : World ι U) (τ : ℚ)
    (amt : ι → ℚ) (recs : Finset ι) (u : U) (hu : u ∉ w.reset) :
    arenaTake (hardReset w u) τ amt recs = arenaTake w τ amt recs + τ * share w amt recs u := by
  classical
  unfold arenaTake share
  rw [Finset.mul_sum, Finset.sum_filter, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i _
  simp only [hardReset, Finset.mem_insert]
  by_cases hc : (w.records i).creator = u
  · simp [hc, hu]
  · simp [hc]

/-- **The user keeps `1 - τ` of their share after a hard reset.** -/
theorem taxReset_user_keeps {ι U : Type} [DecidableEq U] (w : World ι U) (τ : ℚ)
    (amt : ι → ℚ) (recs : Finset ι) (u : U) :
    holderTake (hardReset w u) τ amt recs u = (1 - τ) * share w amt recs u := by
  unfold holderTake share
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i hi
  simp only [Finset.mem_filter, hardReset] at hi
  simp [hardReset, hi.2]

/-- **Other users are unchanged.** -/
theorem taxReset_other_user {ι U : Type} [DecidableEq U] (w : World ι U) (τ : ℚ)
    (amt : ι → ℚ) (recs : Finset ι) (u v : U) (hv : v ≠ u) :
    holderTake (hardReset w u) τ amt recs v = holderTake w τ amt recs v := by
  unfold holderTake
  apply Finset.sum_congr rfl
  intro i hi
  simp only [Finset.mem_filter] at hi
  have : (w.records i).creator ≠ u := hi.2 ▸ hv
  simp [hardReset, this]

/-- **A 100% tax is the Round 5 rule**: the arenas gain the user's whole share, and the user
keeps nothing. -/
theorem full_tax_is_round_five {ι U : Type} [DecidableEq U] (w : World ι U)
    (amt : ι → ℚ) (recs : Finset ι) (u : U) (hu : u ∉ w.reset) :
    arenaTake (hardReset w u) 1 amt recs = arenaTake w 1 amt recs + share w amt recs u ∧
      holderTake (hardReset w u) 1 amt recs u = 0 := by
  constructor
  · rw [taxReset_arena_gain w 1 amt recs u hu, one_mul]
  · rw [taxReset_user_keeps]; ring

/-- **At 2%**: for a hard-reset user whose share is 100, the arenas gain 2 and the user keeps 98. -/
theorem two_percent_example {ι U : Type} [DecidableEq U] (w : World ι U)
    (amt : ι → ℚ) (recs : Finset ι) (u : U) (hu : u ∉ w.reset)
    (h100 : share w amt recs u = 100) :
    arenaTake (hardReset w u) (2 / 100) amt recs = arenaTake w (2 / 100) amt recs + 2 ∧
      holderTake (hardReset w u) (2 / 100) amt recs u = 98 := by
  constructor
  · rw [taxReset_arena_gain w _ amt recs u hu, h100]; norm_num
  · rw [taxReset_user_keeps, h100]; norm_num

/-! ## Monolithic Zoo: 50 / 47 / 43 -/

/-- The three conceptual Zoo "animals" that are not animal names (Matthew's spelling). -/
def conceptualAnimals : List String := ["PULSE", "HIVE", "SHEPHARD"]

/-- The 47–50 extension band (membership as given by Matthew; positions not yet assigned). -/
def extensionBand : List String := ["CHIMERA", "WOODPECKER", "NIGHTENGALE", "HUMMINGBIRD"]

/-- The 43 core animal names: the 46-animal Core list of the design compilation without PULSE,
HIVE and SHEPHERD (spelled SHEPHERD in that list). -/
def coreAnimalNames : List String :=
  EFMWZoo.coreRoster.filter (fun s => s ∉ ["PULSE", "HIVE", "SHEPHERD"])

/-- All 47 animal names in use. -/
def animalNames : List String := coreAnimalNames ++ extensionBand

/-- All 50 Monolithic Zoo entries. -/
def monolithicZoo : List String := animalNames ++ conceptualAnimals

/-- **43 core animal names**, all distinct, and the Core list loses exactly PULSE, HIVE and
SHEPHERD. -/
theorem coreAnimalNames_spec :
    coreAnimalNames.length = 43 ∧ coreAnimalNames.Nodup ∧
      EFMWZoo.coreRoster.length = coreAnimalNames.length + 3 := by
  decide

/-- **47 animal names**, all distinct: none of the extension band is already a core name. -/
theorem animalNames_spec : animalNames.length = 47 ∧ animalNames.Nodup := by
  decide

/-- **50 Zoo entries**, all distinct. -/
theorem monolithicZoo_spec : monolithicZoo.length = 50 ∧ monolithicZoo.Nodup := by
  decide

end RoundSixRulings
