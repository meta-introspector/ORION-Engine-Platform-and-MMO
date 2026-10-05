module

public import Mathlib
public import RequestProject.RoundFour.RulingsThree

/-!
# Round Four rulings, fourth pass: phoenix in combat, locking in elements, council
# reassessment, royalties, quest-fair lessons, element strength

The designer's notes written into the reply that sits between the fifth and sixth photo
dividers on the *ORION Round 4* page, stated as rules with their consequences proved.

* **Phoenix in combat.** A phoenix may have all its learned elements active at once and may
  switch them even mid-battle (`phoenix_switch_in_combat`, `phoenix_all_learned_active`).
* **New elements are locked in by meditation.** Levelling an element orb (even in combat) only
  makes the element *pending*. It becomes usable only after the dragon meditates in a safe zone,
  out of combat. So a pending element can never be active (`pending_not_active`), combat never
  adds a usable element (`combat_no_new_element`), meditating outside a safe zone or in combat
  does nothing (`lockIn_needs_safe_zone`), and meditating in a safe zone works
  (`lockIn_in_safe_zone`). The element rules hold after any play (`runL_valid`).
  This refines `RoundFourRulingsThree.gain_in_combat`, whose single "gain" step is now split in
  two.
* **Council reassessment.** Every AI seat must vote yes or no (no abstentions: a vote is a
  function from seats to yes/no). A unanimous first round passes (`unanimous_passes`). Any no
  vote triggers one full reassessment, and the motion passes only if the reassessment round
  still has 4/5 approval (`nay_needs_reassessment`). So passing always means a round of record
  with 4/5 approval (`pass_has_four_fifths`); an example shows one first-round no can still end
  in failure after reassessment (`reassessment_can_fail`).
* **Royalties.** Royalties for a record go to its author, but after a hard reset they go to
  nobody (`hardReset_no_royalty`); other users' royalties are unchanged
  (`hardReset_others_royalty`).
* **Lessons at the player's level; quests are fair.** Lessons are offered at the player's level
  (`lessonsAt`, `lessonAt_usable`). A quest is a list of stages, each with a requirement and the
  skill its lessons teach. A quest is offered only if it never asks for more than the player
  can have learnt by that stage (`Fair`). Fair quests are exactly the completable ones
  (`fair_iff_completable`), stronger players can do whatever weaker ones can
  (`completable_mono`), and no stage asks for more than starting skill plus everything the quest
  teaches (`fair_stage_le_total`).
* **Element strength (designer's intuition).** A dragon's elemental skill is twice a non-dragon
  player's (`dragonPower`). "10% differentiation between non-phoenix dragons" has two readings:
  every non-phoenix dragon within 10% of the 2× baseline (`InBand`), or the strongest at most
  10% above the weakest (`InSpread`). They differ: the band allows a 22% gap
  (`band_allows_wider_gap`). Anchoring the weakest at exactly 2× and the strongest at 2.2×
  satisfies both (`anchored_satisfies_both`).
-/

@[expose] public section

namespace RoundFourRulingsFour

open RoundFourRulings RoundFourRulingsTwo RoundFourRulingsThree

/-! ## Phoenix: every learned element at once, switching even in combat -/

/-- **A phoenix may switch mid-battle.** For a phoenix, combat changes nothing. -/
theorem phoenix_switch_in_combat (d : Elemental) (hp : d.phoenix = true) (sit : Situation)
    (s : ElemStep') : stepC d sit s = d.step' s := by
  simp [stepC, switchAllowed, hp]

/-- **A phoenix can have all its learned elements active at once**, in combat or not. -/
theorem phoenix_all_learned_active (d : Elemental) (hp : d.phoenix = true) (sit : Situation) :
    (stepC d sit (.select d.acquired)).active = d.acquired := by
  rw [phoenix_switch_in_combat d hp]
  simp [Elemental.step', Elemental.select, hp]

/-! ## Locking in a new element by meditation -/

/-- A dragon together with the elements whose orbs have levelled up but that are not yet
locked in. -/
structure Dragon where
  core : Elemental
  pending : Finset Element

/-- One step of play under the fourth ruling. -/
inductive Step
  /-- An element orb levels up (allowed anywhere, even in combat). -/
  | levelOrb (e : Element)
  /-- Meditate to lock in a pending element, at standard price `base`. -/
  | lockIn (e : Element) (base : ℕ)
  /-- Switch elements on or off (governed by the combat rule of the third pass). -/
  | switch (s : ElemStep')

/-- Meditation works only in a safe zone and out of combat. -/
def canMeditate (sit : Situation) : Bool := sit.inSafeZone && !sit.inCombat

/-- Apply one step in a given situation. A `switch` step that tries to gain is ignored: new
elements come only through `lockIn`. -/
def stepL (d : Dragon) (sit : Situation) : Step → Dragon
  | .levelOrb e => if e ∈ d.core.acquired then d else { d with pending := insert e d.pending }
  | .lockIn e base =>
      if e ∈ d.pending ∧ canMeditate sit = true then
        ⟨d.core.gain' e base, d.pending.erase e⟩
      else d
  | .switch s => if s.isSwitch then { d with core := stepC d.core sit s } else d

/-- Play a sequence of steps, each in its own situation. -/
def runL (d : Dragon) (l : List (Situation × Step)) : Dragon :=
  l.foldl (fun d p => stepL d p.1 p.2) d

/-- The rules: the elemental rules hold, and pending elements are not yet learned. -/
def Dragon.Valid (d : Dragon) : Prop :=
  d.core.Valid' ∧ Disjoint d.pending d.core.acquired

theorem stepL_valid (d : Dragon) (sit : Situation) (s : Step) (h : d.Valid) :
    (stepL d sit s).Valid := by
  obtain ⟨hv, hd⟩ := h
  cases s with
  | levelOrb e =>
    simp only [stepL]; split_ifs with he
    · exact ⟨hv, hd⟩
    · exact ⟨hv, Finset.disjoint_insert_left.2 ⟨he, hd⟩⟩
  | lockIn e base =>
    simp only [stepL]; split_ifs with he
    · refine ⟨step'_valid d.core (.gain e base) hv, ?_⟩
      simp only [Elemental.gain']
      rw [Finset.disjoint_insert_right]
      exact ⟨by simp, Finset.disjoint_of_subset_left (Finset.erase_subset _ _) hd⟩
    · exact ⟨hv, hd⟩
  | switch s =>
    simp only [stepL]; split_ifs with hs
    · refine ⟨stepC_valid d.core sit s hv, ?_⟩
      have : (stepC d.core sit s).acquired = d.core.acquired := by
        unfold stepC; split_ifs
        · rfl
        · cases s <;> simp_all [ElemStep'.isSwitch, Elemental.step', Elemental.activate,
            Elemental.deactivate, Elemental.select] <;> split_ifs <;> rfl
      simpa [this] using hd
    · exact ⟨hv, hd⟩

/-- **The rules always hold.** -/
theorem runL_valid (d : Dragon) (l : List (Situation × Step)) (h : d.Valid) :
    (runL d l).Valid := by
  induction l generalizing d with
  | nil => exact h
  | cons p l ih => exact ih _ (stepL_valid d p.1 p.2 h)

/-- **A pending element can't be used.** In a valid state, an element whose orb has levelled
up but that hasn't been locked in is never active. -/
theorem pending_not_active (d : Dragon) (h : d.Valid) (e : Element) (he : e ∈ d.pending) :
    e ∉ d.core.active := fun ha =>
  Finset.disjoint_left.1 h.2 he (h.1.1 ha)

/-- **Combat never adds a usable element.** Whatever happens in one step of combat, the set of
learned elements is unchanged. -/
theorem combat_no_new_element (d : Dragon) (sit : Situation) (hc : sit.inCombat = true)
    (s : Step) : (stepL d sit s).core.acquired = d.core.acquired := by
  cases s with
  | levelOrb e => simp only [stepL]; split_ifs <;> rfl
  | lockIn e base => simp [stepL, canMeditate, hc]
  | switch s =>
    simp only [stepL]; split_ifs with hs
    · unfold stepC; split_ifs
      · rfl
      · cases s <;> simp_all [ElemStep'.isSwitch, Elemental.step', Elemental.activate,
          Elemental.deactivate, Elemental.select] <;> split_ifs <;> rfl
    · rfl

/-- **Meditation needs a safe zone, out of combat.** Elsewhere it does nothing. -/
theorem lockIn_needs_safe_zone (d : Dragon) (sit : Situation) (hs : canMeditate sit = false)
    (e : Element) (base : ℕ) : stepL d sit (.lockIn e base) = d := by
  simp [stepL, hs]

/-- **Meditation in a safe zone locks the element in.** -/
theorem lockIn_in_safe_zone (d : Dragon) (e : Element) (he : e ∈ d.pending) (base : ℕ) :
    e ∈ (stepL d ⟨false, true⟩ (.lockIn e base)).core.acquired ∧
    e ∉ (stepL d ⟨false, true⟩ (.lockIn e base)).pending := by
  simp [stepL, canMeditate, he, Elemental.gain']

/-- **Orb levelling works even in combat**, but only makes the element pending. -/
theorem levelOrb_in_combat (d : Dragon) (sit : Situation) (e : Element)
    (he : e ∉ d.core.acquired) : e ∈ (stepL d sit (.levelOrb e)).pending := by
  simp [stepL, he]

/-! ## Council: every seat votes, any no triggers one reassessment -/

/-- The council's decision. Every one of the `n` AI seats votes yes or no in the first round.
If all say yes, the motion passes. Otherwise the whole council reassesses and the motion passes
only if the reassessment round still has 4/5 approval. -/
def decide4 {n : ℕ} (first second : Fin n → Bool) : Bool :=
  if ∀ i, first i = true then true else council (List.ofFn second)

/-- **Unanimous first round passes.** -/
theorem unanimous_passes {n : ℕ} (first second : Fin n → Bool) (h : ∀ i, first i = true) :
    decide4 first second = true := by
  simp [decide4, h]

/-- **Any no vote sends the motion to reassessment**, and the outcome is decided there. -/
theorem nay_needs_reassessment {n : ℕ} (first second : Fin n → Bool) (h : ∃ i, first i = false) :
    decide4 first second = council (List.ofFn second) := by
  obtain ⟨i, hi⟩ := h
  have : ¬ ∀ j, first j = true := fun hall => by simp [hall i] at hi
  simp [decide4, this]

/-- **Passing always means 4/5 approval in the round of record**: either the first round was
unanimous, or the reassessment round reached 4/5. -/
theorem pass_has_four_fifths {n : ℕ} (first second : Fin n → Bool)
    (h : decide4 first second = true) :
    (∀ i, first i = true) ∨ 5 * (List.ofFn second).count false ≤ n := by
  by_cases hu : ∀ i, first i = true
  · exact Or.inl hu
  · right
    simp only [decide4, hu, if_false] at h
    simpa using (council_iff_rejections _).1 h

/-- **One first-round no can still end in failure.** In a five-seat council, a single no in the
first round followed by two noes after reassessment fails. -/
theorem reassessment_can_fail :
    decide4 (n := 5) ![false, true, true, true, true] ![false, false, true, true, true] = false := by
  decide

/-- **…and it can pass.** If the reassessment keeps one no, a five-seat council passes. -/
theorem reassessment_can_pass :
    decide4 (n := 5) ![false, true, true, true, true] ![false, true, true, true, true] = true := by
  decide

/-! ## Royalties stop after a hard reset -/

/-- Who receives the royalties for a record: its author, or nobody once the author has done a
hard reset. -/
def royaltyTo {ι U : Type} [DecidableEq U] (w : World ι U) (i : ι) : Option U :=
  if (w.records i).creator ∈ w.reset then none else some (w.records i).creator

/-- **No royalties after a hard reset.** -/
theorem hardReset_no_royalty {ι U : Type} [DecidableEq U] (w : World ι U) (u : U) (i : ι) :
    royaltyTo (hardReset w u) i ≠ some u := by
  unfold royaltyTo hardReset
  split_ifs with h
  · simp
  · intro he; simp only [Option.some.injEq] at he; simp [he] at h

/-- **Other users' royalties are unchanged.** -/
theorem hardReset_others_royalty {ι U : Type} [DecidableEq U] (w : World ι U) (u : U) (i : ι)
    (hi : (w.records i).creator ≠ u) : royaltyTo (hardReset w u) i = royaltyTo w i := by
  simp [royaltyTo, hardReset, hi]

/-! ## Lessons at the player's level, and fair quests -/

/-- The lessons offered to a player: options at or below the player's own skill level that the
player has not learnt yet. -/
def lessonsAt {A : Type} (tier : A → ℕ) (skill : ℕ) (learnt : A → Bool) (all : List A) :
    List A :=
  all.filter (fun a => decide (tier a ≤ skill) && !learnt a)

/-- **Every lesson offered is usable at the player's level.** -/
theorem lessonAt_usable {A : Type} (tier : A → ℕ) (skill : ℕ) (learnt : A → Bool) (all : List A)
    (a : A) (h : a ∈ lessonsAt tier skill learnt all) : tier a ≤ skill := by
  simp only [lessonsAt, List.mem_filter, Bool.and_eq_true, decide_eq_true_eq] at h
  exact h.2.1

/-- A quest stage: the skill it requires and the skill its lessons teach. -/
structure Stage where
  req : ℕ
  teaches : ℕ

/-- Whether a player starting at skill `s` can complete the stages in order, taking every
lesson along the way. -/
def completable : ℕ → List Stage → Bool
  | _, [] => true
  | s, st :: rest => decide (st.req ≤ s) && completable (s + st.teaches) rest

/-- Total skill taught by a list of stages. -/
def taught (l : List Stage) : ℕ := (l.map Stage.teaches).sum

/-- A quest is **fair** for skill `s` if no stage asks for more than the player can have learnt
by then: starting skill plus what the earlier stages taught. -/
def Fair (s : ℕ) (q : List Stage) : Prop :=
  ∀ k (hk : k < q.length), q[k].req ≤ s + taught (q.take k)

/-- **Fair quests are exactly the completable ones.** -/
theorem fair_iff_completable (s : ℕ) (q : List Stage) : Fair s q ↔ completable s q = true := by
  induction q generalizing s with
  | nil => simp [Fair, completable]
  | cons st rest ih =>
    simp only [completable, Bool.and_eq_true, decide_eq_true_eq, ← ih]
    constructor
    · intro h
      refine ⟨by simpa [taught] using h 0 (by simp), fun k hk => ?_⟩
      have := h (k + 1) (by simpa using hk)
      simpa [taught, Nat.add_assoc] using this
    · rintro ⟨h0, h⟩ k hk
      cases k with
      | zero => simpa [taught] using h0
      | succ k =>
        have := h k (by simpa using hk)
        simpa [taught, Nat.add_assoc] using this

/-- **A stronger player can do whatever a weaker one can.** -/
theorem completable_mono (s t : ℕ) (hst : s ≤ t) (q : List Stage)
    (h : completable s q = true) : completable t q = true := by
  rw [← fair_iff_completable] at h ⊢
  intro k hk; have := h k hk; omega

/-- **No stage asks for more than the player can obtain before the quest ends**: starting skill
plus everything the quest teaches. -/
theorem fair_stage_le_total (s : ℕ) (q : List Stage) (h : Fair s q) (k : ℕ) (hk : k < q.length) :
    q[k].req ≤ s + taught q := by
  have h1 := h k hk
  have : taught (q.take k) ≤ taught q := by
    have e := congrArg List.sum (List.take_append_drop k (q.map Stage.teaches))
    rw [List.sum_append] at e
    simp only [taught, List.map_take]; omega
  omega

/-! ## Element strength -/

/-- A dragon's elemental skill: twice that of a non-dragon player (base `b`). -/
def dragonPower (b : ℚ) : ℚ := 2 * b

/-- Reading A: a non-phoenix dragon's strength `x` is within 10% of the 2× baseline. -/
def InBand (b x : ℚ) : Prop := |x - dragonPower b| ≤ dragonPower b / 10

/-- Reading B: the strongest of two non-phoenix dragons is at most 10% above the weaker. -/
def InSpread (x y : ℚ) : Prop := max x y ≤ 11 / 10 * min x y

/-- **The two readings differ.** With base 100, strengths 180 and 220 are both within 10% of
the 2× baseline, but 220 is about 22% above 180. -/
theorem band_allows_wider_gap :
    InBand 100 180 ∧ InBand 100 220 ∧ ¬ InSpread 180 220 := by
  refine ⟨?_, ?_, ?_⟩ <;> norm_num [InBand, InSpread, dragonPower, abs_le]

/-- **Anchoring satisfies both readings.** If every non-phoenix dragon sits between exactly 2×
and 2.2× a non-dragon player's skill, each is in the band and any two are within 10%. -/
theorem anchored_satisfies_both (b x y : ℚ)
    (hx : 2 * b ≤ x ∧ x ≤ 11 / 5 * b) (hy : 2 * b ≤ y ∧ y ≤ 11 / 5 * b) :
    InBand b x ∧ InBand b y ∧ InSpread x y := by
  refine ⟨?_, ?_, ?_⟩
  · unfold InBand dragonPower; rw [abs_le]; constructor <;> linarith
  · unfold InBand dragonPower; rw [abs_le]; constructor <;> linarith
  · unfold InSpread
    rcases le_total x y with h | h
    · rw [max_eq_right h, min_eq_left h]; linarith
    · rw [max_eq_left h, min_eq_right h]; linarith

/-- **A dragon is always at least 1.8× a non-dragon player** under reading A. -/
theorem band_at_least (b x : ℚ) (h : InBand b x) : 9 / 5 * b ≤ x := by
  unfold InBand dragonPower at h; rw [abs_le] at h; linarith [h.1]

end RoundFourRulingsFour
