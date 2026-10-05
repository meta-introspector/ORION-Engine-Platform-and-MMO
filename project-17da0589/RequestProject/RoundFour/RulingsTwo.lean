module

public import Mathlib
public import RequestProject.RoundFour.Rulings

/-!
# Round Four rulings, second pass: hatching, chosen elements, 4/5 consensus, public record

The designer's notes written into the "UPDATED ARI" report on the *ORION Round 4* page
(the block between the third and fourth photo dividers) are stated here as rules, with their
consequences proved. Three results in `RoundFour/Rulings.lean` are superseded by this file
(`phoenix_hatches_with_fire`, `phoenix_all_active`, `five_element_phoenix`); they are kept there
unchanged and marked.

* **Hatching (D8 note).** A phoenix hatches *unlit* but with the fire ability already gained.
  The hatching animation shows it catching fire, but it does not stay aflame unless the player
  activates the flame ability (`phoenix_hatches_unlit_with_fire`).
* **Chosen elements (D4 note).** A phoenix's elements don't all switch on at once. A phoenix
  build chooses which, and how many, of its gained elements are active
  (`phoenix_select`, `phoenix_any_selection`). Any other dragon still has at most one active
  (`other_at_most_one_active'`). A phoenix can still run all five by choice
  (`five_element_phoenix_by_choice`).
* **Consensus is 4/5 (Q1).** The council publishes when at least four fifths of the votes cast
  are approvals (`council`). Exactly `n / 5` rejections can be absorbed in a council of `n`
  (`council_iff_rejections`). In particular a council of four or fewer needs every vote, so one
  rejection blocks there (`small_council_needs_all`).
* **Monster aggro timer (Q3b).** Monsters use the same 10-minute timer as players
  (`monster_window_same`).
* **Public record (D6 note).** Private conversations are allowed, but anything a player
  attaches to a project submitted to the council becomes public record
  (`submit_publishes_attachments`, `council_build_all_public`). Items not attached stay as they
  were (`submit_keeps_unattached`).
* **Archetype pairing (Q5, proposal).** The designer's reading HIVE ↦ Kronos, PULSE ↦ Orion,
  SHEPHERD ↦ KRION is a one-to-one pairing (`pairing_bijective`). This records the proposal; it
  is not yet confirmed.
-/

@[expose] public section

namespace RoundFourRulingsTwo

open RoundFourRulings

/-! ## Hatching and chosen elements -/

/-- A new hatchling, second ruling. A phoenix hatches with fire *gained* but not active (it is
unlit until the player activates the flame ability), at no cost. Any other dragon hatches with
no element. -/
def hatch' (phoenix : Bool) : Elemental :=
  if phoenix then ⟨true, {.fire}, ∅, 0⟩ else ⟨false, ∅, ∅, 0⟩

/-- Gain element `e` at standard price `base`. Gaining never switches an element on, for any
dragon. A phoenix pays the half rate (`RoundFourRulings.gainCost`). -/
def _root_.RoundFourRulings.Elemental.gain' (d : Elemental) (e : Element) (base : ℕ) : Elemental :=
  { d with acquired := insert e d.acquired, spent := d.spent + gainCost d.phoenix base }

/-- Switch element `e` on. A phoenix adds it to its active set; any other dragon makes it its
single active element. Elements not yet gained can't be switched on. -/
def _root_.RoundFourRulings.Elemental.activate (d : Elemental) (e : Element) : Elemental :=
  if e ∈ d.acquired then
    if d.phoenix then { d with active := insert e d.active } else { d with active := {e} }
  else d

/-- Switch element `e` off. -/
def _root_.RoundFourRulings.Elemental.deactivate (d : Elemental) (e : Element) : Elemental :=
  { d with active := d.active.erase e }

/-- Choose the whole active set at once. A phoenix gets exactly the chosen elements it has
gained. Any other dragon may choose at most one element; a larger choice changes nothing. -/
def _root_.RoundFourRulings.Elemental.select (d : Elemental) (s : Finset Element) : Elemental :=
  if d.phoenix then { d with active := s ∩ d.acquired }
  else if s.card ≤ 1 then { d with active := s ∩ d.acquired } else d

/-- One step of elemental play under the second ruling. -/
inductive ElemStep'
  | gain (e : Element) (base : ℕ)
  | activate (e : Element)
  | deactivate (e : Element)
  | select (s : Finset Element)

/-- Apply one step. -/
def _root_.RoundFourRulings.Elemental.step' (d : Elemental) : ElemStep' → Elemental
  | .gain e base => d.gain' e base
  | .activate e => d.activate e
  | .deactivate e => d.deactivate e
  | .select s => d.select s

/-- Apply a sequence of steps. -/
def _root_.RoundFourRulings.Elemental.run' (d : Elemental) (l : List ElemStep') : Elemental :=
  l.foldl Elemental.step' d

/-- The second rule: only gained elements can be active, and a dragon that isn't a phoenix has
at most one active. A phoenix may have any number active, by choice. -/
def _root_.RoundFourRulings.Elemental.Valid' (d : Elemental) : Prop :=
  d.active ⊆ d.acquired ∧ (d.phoenix = false → d.active.card ≤ 1)

theorem hatch'_valid (p : Bool) : (hatch' p).Valid' := by
  cases p <;> simp [hatch', Elemental.Valid']

theorem step'_phoenix (d : Elemental) (s : ElemStep') : (d.step' s).phoenix = d.phoenix := by
  cases s <;> simp only [Elemental.step', Elemental.gain', Elemental.activate,
    Elemental.deactivate, Elemental.select] <;> split_ifs <;> rfl

theorem run'_phoenix (d : Elemental) (l : List ElemStep') : (d.run' l).phoenix = d.phoenix := by
  induction l generalizing d with
  | nil => rfl
  | cons s l ih => simp only [Elemental.run', List.foldl_cons] at ih ⊢; rw [ih, step'_phoenix]

theorem step'_valid (d : Elemental) (s : ElemStep') (h : d.Valid') : (d.step' s).Valid' := by
  obtain ⟨hs, hc⟩ := h
  cases s with
  | gain e base =>
    exact ⟨hs.trans (Finset.subset_insert _ _), hc⟩
  | activate e =>
    simp only [Elemental.step', Elemental.activate]
    split_ifs with he hp
    · exact ⟨Finset.insert_subset he hs, fun h => by simp [hp] at h⟩
    · exact ⟨Finset.singleton_subset_iff.2 he, fun _ => by simp⟩
    · exact ⟨hs, hc⟩
  | deactivate e =>
    exact ⟨(Finset.erase_subset _ _).trans hs,
      fun h => (Finset.card_le_card (Finset.erase_subset _ _)).trans (hc h)⟩
  | select t =>
    simp only [Elemental.step', Elemental.select]
    split_ifs with hp ht
    · exact ⟨Finset.inter_subset_right, fun h => by simp [hp] at h⟩
    · exact ⟨Finset.inter_subset_right,
        fun _ => (Finset.card_le_card Finset.inter_subset_left).trans ht⟩
    · exact ⟨hs, hc⟩

/-- **The second rule always holds.** Starting from any valid state, every sequence of gains,
activations, deactivations and selections keeps it. -/
theorem run'_valid (d : Elemental) (l : List ElemStep') (h : d.Valid') : (d.run' l).Valid' := by
  induction l generalizing d with
  | nil => exact h
  | cons s l ih => exact ih _ (step'_valid d s h)

/-- **A phoenix hatches unlit, with the fire ability.** It has fire gained, nothing active, and
it paid nothing for it. -/
theorem phoenix_hatches_unlit_with_fire :
    Element.fire ∈ (hatch' true).acquired ∧ (hatch' true).active = ∅ ∧ (hatch' true).spent = 0 := by
  simp [hatch']

/-- **The flame is one action away.** A newly hatched phoenix that activates fire is aflame. -/
theorem phoenix_lights_up : Element.fire ∈ ((hatch' true).activate .fire).active := by
  simp [hatch', Elemental.activate]

/-- **Fire is open to every dragon.** A non-phoenix dragon that gains fire and activates it has
fire active. -/
theorem fire_open_to_all' (base : ℕ) :
    Element.fire ∈ (((hatch' false).gain' .fire base).activate .fire).active := by
  simp [hatch', Elemental.gain', Elemental.activate]

/-- **A phoenix picks its active elements.** Selecting a set gives exactly the selected
elements it has gained. -/
theorem phoenix_select (d : Elemental) (hp : d.phoenix = true) (s : Finset Element) :
    (d.select s).active = s ∩ d.acquired ∧ (d.select s).acquired = d.acquired := by
  simp [Elemental.select, hp]

/-- **Any choice is reachable.** For a phoenix, every set of gained elements, of any size
(including none), is the active set after one selection. -/
theorem phoenix_any_selection (d : Elemental) (hp : d.phoenix = true) (s : Finset Element)
    (hs : s ⊆ d.acquired) : (d.run' [.select s]).active = s := by
  simp [Elemental.run', Elemental.step', Elemental.select, hp, Finset.inter_eq_left.2 hs]

/-- **Switching an element off works.** -/
theorem deactivate_off (d : Elemental) (e : Element) : e ∉ (d.deactivate e).active := by
  simp [Elemental.deactivate]

/-- **Other dragons still have at most one element active**, however they play. -/
theorem other_at_most_one_active' (l : List ElemStep') :
    ((hatch' false).run' l).active.card ≤ 1 := by
  have hv := run'_valid _ l (hatch'_valid false)
  exact hv.2 (by rw [run'_phoenix]; rfl)

/-- **A five-element phoenix, by choice.** A phoenix that gains water, earth, air and ether and
then selects all five has all five active. -/
theorem five_element_phoenix_by_choice (a b c d : ℕ) :
    let p := (((((hatch' true).gain' .water a).gain' .earth b).gain' .air c).gain' .ether d)
    (p.select Finset.univ).active = Finset.univ := by
  simp only [hatch', Elemental.gain', Elemental.select, if_true]
  decide

/-- **A phoenix need not run everything.** The same five-element phoenix can select only water
and air, leaving the others off. -/
theorem phoenix_partial_choice (a b c d : ℕ) :
    let p := (((((hatch' true).gain' .water a).gain' .earth b).gain' .air c).gain' .ether d)
    (p.select {.water, .air}).active = {.water, .air} := by
  simp only [hatch', Elemental.gain', Elemental.select, if_true]
  decide

/-! ## Q1: consensus means four fifths -/

/-- The council reaches consensus when at least 4/5 of the votes cast are approvals. -/
def council (votes : List Bool) : Bool := consensus 4 5 votes

/-- **How many rejections a council absorbs.** A council reaches 4/5 consensus exactly when
five times the number of rejections is at most the number of votes, i.e. at most `n / 5`
rejections in a council of `n`. -/
theorem council_iff_rejections (votes : List Bool) :
    council votes = true ↔ 5 * votes.count false ≤ votes.length := by
  have h := List.count_add_count_not votes true
  simp only [Bool.not_true] at h
  simp only [council, consensus, decide_eq_true_eq]
  omega

/-- The same count, written with division: at most `n / 5` rejections. -/
theorem council_iff_rejections_div (votes : List Bool) :
    council votes = true ↔ votes.count false ≤ votes.length / 5 := by
  rw [council_iff_rejections]; omega

/-- **Small councils need every vote.** With four or fewer votes cast, one rejection blocks
consensus: the old single veto returns for councils that small. -/
theorem small_council_needs_all (votes : List Bool) (hn : votes.length ≤ 4)
    (h : false ∈ votes) : council votes = false := by
  have hpos : 0 < votes.count false := List.count_pos_iff.2 h
  cases hc : council votes
  · rfl
  · have := (council_iff_rejections votes).1 hc; omega

/-- **Five votes absorb one rejection.** -/
theorem five_one_rejection : council [false, true, true, true, true] = true := by decide

/-- **Five votes don't absorb two.** -/
theorem five_two_rejections : council [false, false, true, true, true] = false := by decide

/-- **Four votes don't absorb one.** Three of four (75 %) is short of 4/5. -/
theorem four_one_rejection : council [false, true, true, true] = false := by decide

/-! ## Q3b: monsters use the same aggro timer -/

/-- The aggro window used by monsters: the same 10-minute window as players. -/
def monsterAggroWindow : ℕ := RoundThreeClarifications.aggroWindow

theorem monster_window_same :
    monsterAggroWindow = RoundThreeClarifications.aggroWindow ∧ monsterAggroWindow = 600 :=
  ⟨rfl, rfl⟩

/-! ## D6 note: what is attached to a council submission becomes public record -/

/-- Visibility of an item (a message, note, file or blueprint). -/
inductive Visibility
  | privateItem
  | publicRecord
  deriving DecidableEq, Repr

/-- Submitting a project to the council: every item attached to the project becomes public
record. Items not attached keep their visibility. -/
def submit {ι : Type} (vis : ι → Visibility) (attached : ι → Prop) [DecidablePred attached] :
    ι → Visibility :=
  fun i => if attached i then .publicRecord else vis i

/-- **Attachments become public record.** -/
theorem submit_publishes_attachments {ι : Type} (vis : ι → Visibility) (attached : ι → Prop)
    [DecidablePred attached] (i : ι) (hi : attached i) :
    submit vis attached i = .publicRecord := by
  simp [submit, hi]

/-- **Private conversations that aren't attached stay as they were.** -/
theorem submit_keeps_unattached {ι : Type} (vis : ι → Visibility) (attached : ι → Prop)
    [DecidablePred attached] (i : ι) (hi : ¬ attached i) : submit vis attached i = vis i := by
  simp [submit, hi]

/-- **Nothing private goes forward with the council.** After submission, every item in the
build is public record. -/
theorem council_build_all_public {ι : Type} (vis : ι → Visibility) (attached : ι → Prop)
    [DecidablePred attached] :
    ∀ i, attached i → submit vis attached i = .publicRecord :=
  fun i hi => submit_publishes_attachments vis attached i hi

/-! ## Q5 proposal: pairing the dragon upgrades with the three builds -/

/-- The three dragon archetype upgrades. -/
inductive Upgrade
  | hive
  | pulse
  | shepherd
  deriving DecidableEq, Fintype, Repr

/-- The three alignment builds. -/
inductive Build
  | kronos
  | orion
  | krion
  deriving DecidableEq, Fintype, Repr

/-- The designer's proposed pairing: HIVE ↦ Kronos, PULSE ↦ Orion, SHEPHERD ↦ KRION. -/
def pairing : Upgrade → Build
  | .hive => .kronos
  | .pulse => .orion
  | .shepherd => .krion

/-- **The proposed pairing is one-to-one and covers all three builds.** -/
theorem pairing_bijective : Function.Bijective pairing := by
  constructor
  · intro a b h; cases a <;> cases b <;> first | rfl | cases h
  · intro b; cases b
    · exact ⟨.hive, rfl⟩
    · exact ⟨.pulse, rfl⟩
    · exact ⟨.shepherd, rfl⟩

end RoundFourRulingsTwo
