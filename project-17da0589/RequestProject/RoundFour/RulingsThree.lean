module

public import Mathlib
public import RequestProject.RoundFour.RulingsTwo
public import RequestProject.RoundThree.Curation

/-!
# Round Four rulings, third pass: element switching, council sizes, hard reset, lessons

The designer's notes written into the reply that sits between the fourth and fifth photo
dividers on the *ORION Round 4* page, stated as rules with their consequences proved.

* **Element switching (note on phoenix elements).** A dragon that isn't a phoenix may switch
  between its gained elements anywhere, as long as it is not actively in combat. It does not
  need to be in a safe zone. In combat, switching does nothing (`combat_freezes_switch`); out of
  combat, anywhere, switching works exactly as before (`switch_out_of_combat`). Gaining an
  element is not restricted. The one-active-element rule for non-phoenix dragons still holds
  after any play, in or out of combat (`runC_valid`, `other_at_most_one_activeC`). The note
  speaks of "other players", so a phoenix is left free to switch in combat; this is a reading,
  flagged as a question.
* **Council sizes (note on Q1).** A personal council has at least five seats and a public
  council at least ten. With 4/5 consensus, every allowed council absorbs at least one rejection
  (`no_single_veto`), and a public council at least two (`public_absorbs_two`). The small-council
  veto found in the previous pass cannot occur (`small_council_not_allowed`).
* **Hard reset (note on public record).** A hard reset turns every public record of that user
  into an anonymous contribution. The content stays public (`hardReset_keeps_visibility`); the
  public view shows "anonymous" (`hardReset_public_anonymous`); the development team and
  administrators still see the real user (`hardReset_admin_sees_user`); nobody else's records
  change (`hardReset_others_unchanged`).
* **Lessons (D3, from the earlier note on extended opportunities).** Lessons are a separate
  list beside the menu: options just past the player's reach, offered as a guided track. The
  menu rule is untouched. A lesson is never on the menu (`lesson_not_on_menu`); every lesson
  is within `stretch` levels of the player's skill (`lesson_near_level`); and once the player
  levels up to it, the lesson's option appears on the menu (`lesson_then_menu`).
* **Archetype pairing (Q5).** The pairing HIVE ↦ Kronos, PULSE ↦ Orion, SHEPHERD ↦ KRION is now
  confirmed (`confirmedPairing`, `confirmedPairing_bijective`).
-/

@[expose] public section

namespace RoundFourRulingsThree

open RoundFourRulings RoundFourRulingsTwo

/-! ## Element switching is blocked only in active combat -/

/-- Where a dragon is and what it is doing. Only `inCombat` matters for switching; `inSafeZone`
is recorded to show that it doesn't. -/
structure Situation where
  inCombat : Bool
  inSafeZone : Bool

/-- Whether a step is a switch (turning an element on or off, or choosing the active set), as
opposed to gaining a new element. -/
def _root_.RoundFourRulingsTwo.ElemStep'.isSwitch : ElemStep' → Bool
  | .gain _ _ => false
  | _ => true

/-- A switch is allowed for a phoenix at any time, and for any other dragon whenever it is not
actively in combat. -/
def switchAllowed (d : Elemental) (sit : Situation) : Bool :=
  d.phoenix || !sit.inCombat

/-- One step of play in a given situation. A switch that isn't allowed changes nothing. -/
def stepC (d : Elemental) (sit : Situation) (s : ElemStep') : Elemental :=
  if s.isSwitch && !switchAllowed d sit then d else d.step' s

/-- Play a sequence of steps, each in its own situation. -/
def runC (d : Elemental) (l : List (Situation × ElemStep')) : Elemental :=
  l.foldl (fun d p => stepC d p.1 p.2) d

/-- **No switching in combat.** A dragon that isn't a phoenix and is actively in combat keeps
its active elements, whatever switch it tries. -/
theorem combat_freezes_switch (d : Elemental) (hp : d.phoenix = false) (sit : Situation)
    (hc : sit.inCombat = true) (s : ElemStep') (hs : s.isSwitch = true) :
    (stepC d sit s).active = d.active := by
  simp [stepC, switchAllowed, hp, hc, hs]

/-- **Switching anywhere out of combat.** Out of combat, whether or not in a safe zone, a switch
works exactly as it did before the restriction. -/
theorem switch_out_of_combat (d : Elemental) (sit : Situation) (hc : sit.inCombat = false)
    (s : ElemStep') : stepC d sit s = d.step' s := by
  simp [stepC, switchAllowed, hc]

/-- **No safe zone needed.** For a dragon out of combat, being outside a safe zone gives the
same result as being inside one. -/
theorem safe_zone_irrelevant (d : Elemental) (s : ElemStep') (c : Bool) :
    stepC d ⟨c, false⟩ s = stepC d ⟨c, true⟩ s := rfl

/-- **Gaining is never blocked**, even in combat.

*Refined* in `RoundFour/RulingsFour.lean`: levelling an orb in combat only makes an element
pending; it is locked in by meditating in a safe zone out of combat. -/
theorem gain_in_combat (d : Elemental) (sit : Situation) (e : Element) (base : ℕ) :
    stepC d sit (.gain e base) = d.gain' e base := by
  simp [stepC, ElemStep'.isSwitch, Elemental.step']

theorem stepC_valid (d : Elemental) (sit : Situation) (s : ElemStep') (h : d.Valid') :
    (stepC d sit s).Valid' := by
  unfold stepC; split_ifs
  · exact h
  · exact step'_valid d s h

theorem stepC_phoenix (d : Elemental) (sit : Situation) (s : ElemStep') :
    (stepC d sit s).phoenix = d.phoenix := by
  unfold stepC; split_ifs
  · rfl
  · exact step'_phoenix d s

/-- **The element rule still always holds.** Any sequence of steps, each in or out of combat,
keeps a valid dragon valid. -/
theorem runC_valid (d : Elemental) (l : List (Situation × ElemStep')) (h : d.Valid') :
    (runC d l).Valid' := by
  induction l generalizing d with
  | nil => exact h
  | cons p l ih => exact ih _ (stepC_valid d p.1 p.2 h)

theorem runC_phoenix (d : Elemental) (l : List (Situation × ElemStep')) :
    (runC d l).phoenix = d.phoenix := by
  induction l generalizing d with
  | nil => rfl
  | cons p l ih => simp only [runC, List.foldl_cons] at ih ⊢; rw [ih, stepC_phoenix]

/-- **Non-phoenix dragons keep at most one active element**, in or out of combat. -/
theorem other_at_most_one_activeC (l : List (Situation × ElemStep')) :
    (runC (hatch' false) l).active.card ≤ 1 :=
  (runC_valid _ l (hatch'_valid false)).2 (by rw [runC_phoenix]; rfl)

/-! ## Council sizes: five seats personal, ten public -/

/-- The two levels of council. -/
inductive CouncilLevel
  | personalCouncil
  | publicCouncil
  deriving DecidableEq, Repr

/-- The minimum number of seats: five for a personal council, ten for a public one. -/
def minSeats : CouncilLevel → ℕ
  | .personalCouncil => 5
  | .publicCouncil => 10

/-- A vote is allowed only when at least the minimum number of votes is cast. -/
def Allowed (level : CouncilLevel) (votes : List Bool) : Prop := minSeats level ≤ votes.length

/-- **No single veto.** In any allowed council, one rejection never blocks consensus: if
every vote but one is an approval, the council reaches 4/5 consensus. -/
theorem no_single_veto (level : CouncilLevel) (votes : List Bool) (h : Allowed level votes)
    (h1 : votes.count false ≤ 1) : council votes = true := by
  rw [council_iff_rejections]
  have : 5 ≤ minSeats level := by cases level <;> decide
  unfold Allowed at h; omega

/-- **A public council absorbs two rejections.** -/
theorem public_absorbs_two (votes : List Bool) (h : Allowed .publicCouncil votes)
    (h2 : votes.count false ≤ 2) : council votes = true := by
  rw [council_iff_rejections]; simp only [Allowed, minSeats] at h; omega

/-- **The small-council veto can't happen.** No allowed council has four or fewer votes. -/
theorem small_council_not_allowed (level : CouncilLevel) (votes : List Bool)
    (h : votes.length ≤ 4) : ¬ Allowed level votes := by
  unfold Allowed; cases level <;> simp [minSeats] <;> omega

/-- In a council of exactly ten, two rejections pass and three don't. -/
theorem ten_two_three :
    council (List.replicate 2 false ++ List.replicate 8 true) = true ∧
    council (List.replicate 3 false ++ List.replicate 7 true) = false := by decide

/-! ## Hard reset: public records become anonymous contributions -/

/-- How a record's author is shown. -/
inductive Shown (U : Type)
  | named (u : U)
  | anonymous
  deriving DecidableEq, Repr

/-- A record: who made it and whether it is public. -/
structure Record (U : Type) where
  creator : U
  vis : Visibility

/-- The project state: the records, and the set of users who have done a hard reset. -/
structure World (ι U : Type) where
  records : ι → Record U
  reset : Finset U

/-- A hard reset by user `u`. -/
def hardReset {ι U : Type} [DecidableEq U] (w : World ι U) (u : U) : World ι U :=
  { w with reset := insert u w.reset }

/-- The author shown to the public: anonymous for anyone who has done a hard reset. -/
def publicAuthor {ι U : Type} [DecidableEq U] (w : World ι U) (i : ι) : Shown U :=
  if (w.records i).creator ∈ w.reset then .anonymous else .named (w.records i).creator

/-- The author shown to the development team and administrators: always the real user. -/
def adminAuthor {ι U : Type} (w : World ι U) (i : ι) : U := (w.records i).creator

/-- **Public records of a reset user are shown as anonymous.** -/
theorem hardReset_public_anonymous {ι U : Type} [DecidableEq U] (w : World ι U) (u : U) (i : ι)
    (hi : (w.records i).creator = u) : publicAuthor (hardReset w u) i = .anonymous := by
  simp [publicAuthor, hardReset, hi]

/-- **The content stays public.** A hard reset changes no record's visibility. -/
theorem hardReset_keeps_visibility {ι U : Type} [DecidableEq U] (w : World ι U) (u : U) (i : ι) :
    ((hardReset w u).records i).vis = (w.records i).vis := rfl

/-- **The development team and administrators still see the real user.** -/
theorem hardReset_admin_sees_user {ι U : Type} [DecidableEq U] (w : World ι U) (u : U) (i : ι) :
    adminAuthor (hardReset w u) i = adminAuthor w i := rfl

/-- **Nobody else's records change.** -/
theorem hardReset_others_unchanged {ι U : Type} [DecidableEq U] (w : World ι U) (u : U) (i : ι)
    (hi : (w.records i).creator ≠ u) : publicAuthor (hardReset w u) i = publicAuthor w i := by
  simp [publicAuthor, hardReset, hi]

/-! ## Lessons: a separate track beside the menu -/

open RoundThreeCuration

variable {A : Type}

/-- *Superseded* by `RoundFourRulingsFour.lessonsAt` (lessons are offered at the player's own
level). Kept for reference.

The lessons offered: options that are not within reach yet, at most `stretch` levels above
the player's own skill. -/
def lessons [DecidableEq A] (tier : A → ℕ) (m : Means A) (stretch : ℕ) (all : List A) : List A :=
  all.filter (fun a => !withinReach tier m a && decide (tier a ≤ m.skill + stretch))

/-- **A lesson is never on the menu**, so the menu rule ("only what you can do now") is
untouched. -/
theorem lesson_not_on_menu [DecidableEq A] (tier : A → ℕ) (m : Means A) (stretch : ℕ)
    (all : List A) (a : A) (h : a ∈ lessons tier m stretch all) : a ∉ menu tier m all := by
  simp only [lessons, menu, List.mem_filter, Bool.and_eq_true, Bool.not_eq_true'] at h ⊢
  intro h'; simp [h.2.1] at h'

/-- **Lessons start at the player's level.** Every lesson is within `stretch` levels of the
player's skill, and above it. -/
theorem lesson_near_level [DecidableEq A] (tier : A → ℕ) (m : Means A) (stretch : ℕ)
    (all : List A) (a : A) (h : a ∈ lessons tier m stretch all) :
    m.skill < tier a ∧ tier a ≤ m.skill + stretch := by
  simp only [lessons, List.mem_filter, Bool.and_eq_true, Bool.not_eq_true',
    decide_eq_true_eq] at h
  refine ⟨?_, h.2.2⟩
  by_contra hc
  have := h.2.1
  simp [withinReach, show tier a ≤ m.skill by omega] at this

/-- **Finishing the lesson opens the menu entry.** Once the player's skill reaches the lesson's
level, its option is on the menu. -/
theorem lesson_then_menu [DecidableEq A] (tier : A → ℕ) (m : Means A) (stretch : ℕ)
    (all : List A) (a : A) (h : a ∈ lessons tier m stretch all) (m' : Means A)
    (hs : tier a ≤ m'.skill) : a ∈ menu tier m' all :=
  menu_complete tier m' all a (List.mem_filter.mp h).1 (Or.inl hs)

/-! ## Q5: the archetype pairing is confirmed -/

/-- The confirmed pairing: HIVE ↦ Kronos, PULSE ↦ Orion, SHEPHERD ↦ KRION. -/
def confirmedPairing : Upgrade → Build := pairing

/-- **The confirmed pairing is one-to-one and covers all three builds.** -/
theorem confirmedPairing_bijective : Function.Bijective confirmedPairing := pairing_bijective

end RoundFourRulingsThree
