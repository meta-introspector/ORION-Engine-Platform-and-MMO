module

public import Mathlib
public import RequestProject.RoundThree.Clarifications
public import RequestProject.Zoo.Arena

/-!
# Curation menus, dragon builds, the skybox gate, the monthly reset and group aggro

Exact statements of the designer's answers given after `Dragon.lean`.

* **Menus never show what a player can't do.** Every curating or crafting menu lists only
  options within reach. An option is within reach through the player's own skill, a blueprint
  schematic they own, or a tradesman they engage who has the skill.
* **Dragon builds.** Species (chosen once from the actual Proofs Arena animals, the generic
  dragon, or the phoenix) affects abilities. So do the curated body aspects and the archetype
  upgrades `HIVE`, `PULSE` and `SHEPHERD`. Only the skin never affects abilities. A phoenix
  dragon can catch fire, but it isn't on fire all the time.
* **The skybox gate.** Passing the invisible gate at the edge of the atmosphere, through the
  dodecahedron skybox lattice and into the solar level, needs the skybox escape feature (earned
  only through the predetermined quest line) or a key. Building a rocket isn't enough.
* **Halving odd costs.** Both rounding rules are stated so the team can pick one.
* **Monthly reset.** At the 24-hour shutdown, every unclaimed developer-hosted prize pool resets
  and its energy goes to reconstruction. Player-hosted pools are untouched and nothing is lost.
* **Forced demolition pays more** than a scheduled one.
* **Group aggro.** Aggro belongs to one player. Leaving the skybox clears it. One member's
  actions never change another member's timer, so nobody can draw aggro onto the group.
-/

@[expose] public section
namespace RoundThreeCuration

/-! ## Menus: only what is within reach is ever offered -/

variable {A : Type}

/-- How a player can get an alteration (or a crafted item) done: their own skill in the relevant
skill line, the blueprint schematics they own, and the skills of tradesmen they can engage. -/
structure Means (A : Type) where
  skill : ℕ
  blueprints : List A
  tradesmen : List ℕ

/-- An option of difficulty `tier a` is within reach if the player has the skill, owns the
blueprint, or can engage a tradesman with the skill. -/
def withinReach [DecidableEq A] (tier : A → ℕ) (m : Means A) (a : A) : Bool :=
  decide (tier a ≤ m.skill) || decide (a ∈ m.blueprints) || m.tradesmen.any (fun t => decide (tier a ≤ t))

/-- The menu shown to the player: the options in `all` that are within reach, and nothing
else. -/
def menu [DecidableEq A] (tier : A → ℕ) (m : Means A) (all : List A) : List A :=
  all.filter (withinReach tier m)

/-- **Nothing out of reach is shown.** Everything on the menu can be done through the player's
own skill, a blueprint they own, or a tradesman they can engage. -/
theorem menu_within_reach [DecidableEq A] (tier : A → ℕ) (m : Means A) (all : List A) (a : A)
    (h : a ∈ menu tier m all) :
    tier a ≤ m.skill ∨ a ∈ m.blueprints ∨ ∃ t ∈ m.tradesmen, tier a ≤ t := by
  simp only [menu, List.mem_filter, withinReach, Bool.or_eq_true, decide_eq_true_eq,
    List.any_eq_true] at h
  tauto

/-- **Everything within reach is shown.** -/
theorem menu_complete [DecidableEq A] (tier : A → ℕ) (m : Means A) (all : List A) (a : A)
    (ha : a ∈ all)
    (h : tier a ≤ m.skill ∨ a ∈ m.blueprints ∨ ∃ t ∈ m.tradesmen, tier a ≤ t) :
    a ∈ menu tier m all := by
  simp only [menu, List.mem_filter, withinReach, Bool.or_eq_true, decide_eq_true_eq,
    List.any_eq_true]
  tauto

/-- A player with no blueprints and no tradesman only ever sees options at or below their own
skill. -/
theorem solo_menu_le_skill [DecidableEq A] (tier : A → ℕ) (s : ℕ) (all : List A) (a : A)
    (h : a ∈ menu tier ⟨s, [], []⟩ all) : tier a ≤ s := by
  rcases menu_within_reach tier _ all a h with h | h | ⟨t, ht, _⟩
  · exact h
  · simp at h
  · simp at ht

/-- **The menu only grows.** More skill, another blueprint or another tradesman never removes
an option. -/
theorem menu_mono [DecidableEq A] (tier : A → ℕ) (m m' : Means A) (all : List A) (a : A)
    (hs : m.skill ≤ m'.skill) (hb : m.blueprints ⊆ m'.blueprints)
    (ht : m.tradesmen ⊆ m'.tradesmen) (h : a ∈ menu tier m all) : a ∈ menu tier m' all := by
  have ha : a ∈ all := (List.mem_filter.mp h).1
  apply menu_complete tier m' all a ha
  rcases menu_within_reach tier m all a h with h | h | ⟨t, htm, hle⟩
  · exact Or.inl (le_trans h hs)
  · exact Or.inr (Or.inl (hb h))
  · exact Or.inr (Or.inr ⟨t, ht htm, hle⟩)

/-! ## Dragon builds: species, archetypes, body and skin -/

/-- The three Proofs Arena systems that are not animals. They are the archetype upgrades of
the generic dragon build. -/
def archetypes : List String := ["HIVE", "PULSE", "SHEPHERD"]

/-- The species a dragon can be built on: the actual animals of the Proofs Arena Core roster,
together with the generic `DRAGON` build and the `PHOENIX`. -/
def speciesChoices : List String := EFMWZoo.coreRoster.filter (fun s => s ∉ archetypes)

/-- 43 species to choose from, including the generic dragon and the phoenix, and none of the
three archetypes. The archetypes come from the same roster, and the roster is exactly the
species plus the archetypes. -/
theorem roster_split :
    speciesChoices.length = 43 ∧ "DRAGON" ∈ speciesChoices ∧ "PHOENIX" ∈ speciesChoices ∧
      "WHALE" ∈ speciesChoices ∧ (∀ a ∈ archetypes, a ∉ speciesChoices) ∧
      (∀ a ∈ archetypes, a ∈ EFMWZoo.coreRoster) ∧
      EFMWZoo.coreRoster.length = speciesChoices.length + archetypes.length := by
  decide

/-- A dragon. `B` is the type of body aspects (structure, scales or fur, and so on) and `S` the
type of skins. `onFire` records whether it is burning right now. -/
structure Dragon (B S : Type) where
  species : String
  archetypes : List String
  body : B
  skin : S
  onFire : Bool

variable {B S C : Type}

/-- What a dragon can do. It may depend on the species, the archetype upgrades and the body,
but **not on the skin** and not on whether it is burning at this moment. -/
def abilities (ab : String → List String → B → C) (d : Dragon B S) : C :=
  ab d.species d.archetypes d.body

/-- A curation step. -/
inductive Curation (B S : Type)
  | body (b : B)
  | skin (s : S)
  | archetype (a : String)

/-- Apply a curation step. An archetype upgrade must be one of the three archetypes and is not
added twice. -/
def curate (d : Dragon B S) : Curation B S → Dragon B S
  | .body b => { d with body := b }
  | .skin s => { d with skin := s }
  | .archetype a =>
      if a ∈ archetypes ∧ a ∉ d.archetypes then { d with archetypes := d.archetypes ++ [a] }
      else d

/-- **A whale dragon is always a whale dragon.** No sequence of curation steps (body, skin or
archetype) changes the species. -/
theorem species_forever (d : Dragon B S) (cs : List (Curation B S)) :
    (cs.foldl curate d).species = d.species := by
  induction cs generalizing d with
  | nil => rfl
  | cons c cs ih =>
    simp only [List.foldl_cons]
    rw [ih]
    cases c with
    | body b => rfl
    | skin s => rfl
    | archetype a => simp only [curate]; split_ifs <;> rfl

/-- **The skin never matters.** Changing the skin, as often as you like, never changes what the
dragon can do. -/
theorem skin_never_matters (ab : String → List String → B → C) (d : Dragon B S) (s : S) :
    abilities ab (curate d (.skin s)) = abilities ab d := rfl

/-- Every archetype upgrade a dragon carries is one of the three archetypes. -/
theorem archetypes_valid (d : Dragon B S) (cs : List (Curation B S))
    (h : ∀ a ∈ d.archetypes, a ∈ archetypes) :
    ∀ a ∈ (cs.foldl curate d).archetypes, a ∈ archetypes := by
  induction cs generalizing d with
  | nil => exact h
  | cons c cs ih =>
    apply ih
    cases c with
    | body b => exact h
    | skin s => exact h
    | archetype a =>
      simp only [curate]
      split_ifs with hc
      · intro x hx
        rcases List.mem_append.mp hx with hx | hx
        · exact h x hx
        · rw [List.mem_singleton.mp hx]; exact hc.1
      · exact h

/-- A freshly hatched dragon of species `s`: no archetypes yet, not on fire. -/
def hatchling (s : String) (b : B) (sk : S) : Dragon B S := ⟨s, [], b, sk, false⟩

/-- Catch fire. Only a phoenix dragon can. -/
def ignite (d : Dragon B S) : Dragon B S :=
  if d.species = "PHOENIX" then { d with onFire := true } else d

/-- Put the fire out. -/
def douse (d : Dragon B S) : Dragon B S := { d with onFire := false }

/-- **A phoenix dragon isn't always burning.** It hatches not on fire, it can catch fire, and
the fire can go out again. Burning doesn't change what it can do.

*Superseded* by `RoundFourRulings.phoenix_hatches_with_fire`: the designer has ruled (Round Four,
D4) that a phoenix hatches with fire active. -/
theorem phoenix_fire (b : B) (sk : S) (ab : String → List String → B → C) :
    (hatchling "PHOENIX" b sk).onFire = false ∧
      (ignite (hatchling "PHOENIX" b sk)).onFire = true ∧
      (douse (ignite (hatchling "PHOENIX" b sk))).onFire = false ∧
      abilities ab (ignite (hatchling "PHOENIX" b sk)) = abilities ab (hatchling "PHOENIX" b sk) := by
  simp [hatchling, ignite, douse, abilities]

/-- Only a phoenix dragon catches fire.

*Superseded* by `RoundFourRulings.fire_open_to_all`: the designer has ruled (Round Four, D4) that
any dragon can learn fire, with the phoenix build keeping its advantages. -/
theorem ignite_other (d : Dragon B S) (h : d.species ≠ "PHOENIX") : ignite d = d := by
  simp [ignite, h]

/-! ## The skybox gate -/

/-- What matters for leaving the planet: steps completed on the predetermined quest line that
grants the skybox escape feature, whether the player holds a key, and how many items (rockets
and so on) they have crafted. -/
structure Traveller where
  questSteps : ℕ
  hasKey : Bool
  crafted : ℕ

/-- A fresh player. -/
def Traveller.fresh : Traveller := ⟨0, false, 0⟩

/-- Something a player does. -/
inductive Deed
  | craft
  | questStep
  | getKey

/-- Do something. -/
def Traveller.act (t : Traveller) : Deed → Traveller
  | .craft => { t with crafted := t.crafted + 1 }
  | .questStep => { t with questSteps := t.questSteps + 1 }
  | .getKey => { t with hasKey := true }

/-- The player has the skybox escape feature once they have finished the quest line, which has
`Q` steps. -/
def Traveller.hasEscape (Q : ℕ) (t : Traveller) : Prop := Q ≤ t.questSteps

/-- The invisible gate lets the player through into the solar level exactly when they have the
skybox escape feature or a key. -/
def passesGate (Q : ℕ) (t : Traveller) : Prop := t.hasEscape Q ∨ t.hasKey = true

instance (Q : ℕ) (t : Traveller) : Decidable (passesGate Q t) := by
  unfold passesGate Traveller.hasEscape; infer_instance

/-- **A rocket isn't enough.** A player who only crafts (rockets that reach the lattice, or
anything else) never gets through the gate, however much they build. -/
theorem crafting_alone_blocked (Q : ℕ) (hQ : 0 < Q) (n : ℕ) :
    ¬ passesGate Q ((fun t => t.act .craft)^[n] Traveller.fresh) := by
  have : ∀ n, (fun t : Traveller => t.act .craft)^[n] Traveller.fresh = ⟨0, false, n⟩ := by
    intro n
    induction n with
    | zero => rfl
    | succ n ih => rw [Function.iterate_succ_apply', ih]; rfl
  rw [this]
  simp only [passesGate, Traveller.hasEscape, not_or]
  exact ⟨by omega, by simp⟩

/-- **The quest line or a key.** Finishing the quest line gets a player through, and so does a
key. -/
theorem quest_or_key (Q : ℕ) (t : Traveller) :
    passesGate Q ((fun t => t.act .questStep)^[Q] t) ∧ passesGate Q (t.act .getKey) := by
  constructor
  · left
    have : ∀ k, ((fun t : Traveller => t.act .questStep)^[k] t).questSteps = t.questSteps + k := by
      intro k
      induction k with
      | zero => rfl
      | succ k ih =>
        rw [Function.iterate_succ_apply']
        change ((fun t : Traveller => t.act .questStep)^[k] t).questSteps + 1 = _
        omega
    simp only [Traveller.hasEscape, this]
    omega
  · right; rfl

/-- To hatch a dragon the player needs all 64 gold locks and must get through the gate to
reach a sun. -/
def canHatch (Q : ℕ) (goldLocks : ℕ) (t : Traveller) : Prop := goldLocks = 64 ∧ passesGate Q t

/-- **No sun, no dragon.** A sharp shooter with all 64 gold locks who has only been crafting
can't hatch a dragon. -/
theorem sharpshooter_rocket_cannot_hatch (Q : ℕ) (hQ : 0 < Q) (n : ℕ) :
    ¬ canHatch Q 64 ((fun t => t.act .craft)^[n] Traveller.fresh) :=
  fun h => crafting_alone_blocked Q hQ n h.2

/-! ## Halving an odd cost -/

/-- Half, rounded down: 7 becomes 3. -/
def halfDown (c : ℕ) : ℕ := c / 2

/-- Half, rounded up: 7 becomes 4. -/
def halfUp (c : ℕ) : ℕ := (c + 1) / 2

/-- **The two rules differ by at most 1, and only on odd costs.** Rounding up never charges less
than an exact half; rounding down never charges more. -/
theorem rounding_spec (c : ℕ) :
    halfDown c ≤ halfUp c ∧ halfUp c ≤ halfDown c + 1 ∧
      (c % 2 = 0 → halfDown c = halfUp c) ∧ 2 * halfDown c ≤ c ∧ c ≤ 2 * halfUp c := by
  simp only [halfDown, halfUp]
  omega

/-- Over `n` discounted orbs of base cost `c`, rounding down saves the player at most `n` in
total compared with rounding up. -/
theorem rounding_total (c n : ℕ) : n * halfUp c ≤ n * halfDown c + n := by
  have := (rounding_spec c).2.1
  nlinarith

example : halfDown 7 = 3 ∧ halfUp 7 = 4 := by decide

/-! ## The monthly reset -/

/-- A prize pool: whether the development team hosts it (Poly Pog, the public arenas and
championships) and how much unclaimed energy it holds. -/
structure Pool where
  devHosted : Bool
  energy : ℕ

/-- At the 24-hour shutdown at the start of the month, every developer-hosted pool resets to
zero. Player-hosted pools are left alone. -/
def resetPool (p : Pool) : Pool := if p.devHosted then { p with energy := 0 } else p

/-- The unclaimed energy from developer-hosted pools, which goes to the reconstruction. -/
def reclaimed (ps : List Pool) : ℕ := (ps.filter (·.devHosted)).map (·.energy) |>.sum

/-- The shutdown: pools reset, and the reconstruction fund receives the reclaimed energy. -/
def monthlyReset (ps : List Pool) (fund : ℕ) : List Pool × ℕ :=
  (ps.map resetPool, fund + reclaimed ps)

/-- Total energy: in the pools plus in the reconstruction fund. -/
def totalEnergy (ps : List Pool) (fund : ℕ) : ℕ := (ps.map (·.energy)).sum + fund

/-- **The reset.** After the shutdown every developer-hosted pool is empty, every player-hosted
pool is unchanged, the fund grows by exactly the unclaimed developer pool energy, and **no
energy is created or lost.** -/
theorem monthlyReset_spec (ps : List Pool) (fund : ℕ) :
    (∀ p ∈ (monthlyReset ps fund).1, p.devHosted = true → p.energy = 0) ∧
      (∀ p ∈ ps, p.devHosted = false → p ∈ (monthlyReset ps fund).1) ∧
      (monthlyReset ps fund).2 = fund + reclaimed ps ∧
      totalEnergy (monthlyReset ps fund).1 (monthlyReset ps fund).2 = totalEnergy ps fund := by
  refine ⟨?_, ?_, rfl, ?_⟩
  · intro p hp hd
    simp only [monthlyReset, List.mem_map] at hp
    obtain ⟨q, _, rfl⟩ := hp
    unfold resetPool at *
    split_ifs at * with h
    · rfl
    · simp_all
  · intro p hp hd
    simp only [monthlyReset, List.mem_map]
    exact ⟨p, hp, by simp [resetPool, hd]⟩
  · simp only [monthlyReset, totalEnergy, reclaimed]
    induction ps with
    | nil => simp
    | cons p ps ih =>
      by_cases hd : p.devHosted = true
      · simp [resetPool, hd] at ih ⊢
        omega
      · simp [resetPool, hd] at ih ⊢
        omega

/-! ## Forced demolition pays more -/

/-- What a demolition pays in resources. A forced (unscheduled) demolition pays the normal
yield plus a bonus for the inconvenience; a scheduled one pays the normal yield; practice pays
nothing. -/
def demolitionResources (yield bonus : ℕ) : RoundThreeRulings.DemolitionMode → ℕ
  | .practice => 0
  | .sanctioned => yield
  | .forced => yield + bonus

/-- **Forcing pays more.** With any positive bonus, a forced demolition pays strictly more than
a scheduled one, which pays more than practice (when the yield is positive). -/
theorem forced_pays_more (yield bonus : ℕ) (hb : 0 < bonus) (hy : 0 < yield) :
    demolitionResources yield bonus .practice < demolitionResources yield bonus .sanctioned ∧
      demolitionResources yield bonus .sanctioned < demolitionResources yield bonus .forced := by
  simp only [demolitionResources]
  omega

/-! ## Group aggro: per player, no griefing -/

open RoundThreeClarifications in
/-- What a group member does in one second: an ordinary action (`Action`), or leaving the
skybox. -/
inductive GroupDeed
  | act (a : Action)
  | leave

open RoundThreeClarifications

open Classical

variable {ι : Type}

/-- One second for the group: member `i` does `d`; every other member's timer is untouched
(their own countdown is handled when they act). A kinetic action by a member who isn't aggroed,
while a group mate is, means joining the fight, and aggroes **that member only**. Leaving the
skybox clears the member's aggro. -/
noncomputable def groupStep (timers : ι → ℕ) (i : ι) : GroupDeed → ι → ℕ
  | .leave => Function.update timers i 0
  | .act a =>
      if timers i = 0 ∧ a.isKinetic ∧ ∃ j, timers j ≠ 0 then
        Function.update timers i aggroWindow
      else Function.update timers i (stepAggro (timers i) a)

/-- **No griefing.** Whatever member `i` does, every other member's timer is unchanged. -/
theorem no_grief (timers : ι → ℕ) (i j : ι) (hij : j ≠ i) (d : GroupDeed) :
    groupStep timers i d j = timers j := by
  cases d with
  | leave => simp [groupStep, Function.update_of_ne hij]
  | act a => simp only [groupStep]; split_ifs <;> simp [Function.update_of_ne hij]

/-- Run a sequence of (member, deed) pairs. -/
noncomputable def groupRun (timers : ι → ℕ) : List (ι × GroupDeed) → ι → ℕ
  | [] => timers
  | (i, d) :: rest => groupRun (groupStep timers i d) rest

/-- **Inactive members stay inactive.** A member who isn't aggroed, and who casts no kinetic
(Kronos-aligned) skill themselves, stays un-aggroed whatever the rest of the group does. -/
theorem stays_inactive (timers : ι → ℕ) (j : ι) (h0 : timers j = 0) (ds : List (ι × GroupDeed))
    (hj : ∀ a, (j, GroupDeed.act a) ∈ ds → a.isKinetic = false) :
    groupRun timers ds j = 0 := by
  induction ds generalizing timers with
  | nil => exact h0
  | cons x ds ih =>
    obtain ⟨i, d⟩ := x
    simp only [groupRun]
    apply ih
    · by_cases hij : j = i
      · subst hij
        cases d with
        | leave => simp [groupStep]
        | act a =>
          have ha := hj a (by simp)
          simp only [groupStep, ha, h0]
          split_ifs <;> simp_all [stepAggro]
      · rw [no_grief timers i j hij d, h0]
    · intro a ha; exact hj a (by simp [ha])

/-- **Leaving the skybox clears your aggro.** -/
theorem leave_clears (timers : ι → ℕ) (i : ι) : groupStep timers i .leave i = 0 := by
  simp [groupStep]

/-- **Joining the fight.** A member who isn't aggroed and casts a kinetic skill while a group
mate is aggroed becomes aggroed for the full 10 minutes, and nobody else is affected. -/
theorem join_fight (timers : ι → ℕ) (i j : ι) (hi : timers i = 0) (hj : timers j ≠ 0) :
    groupStep timers i (.act .kinetic) i = aggroWindow ∧
      ∀ k, k ≠ i → groupStep timers i (.act .kinetic) k = timers k := by
  refine ⟨?_, fun k hk => no_grief timers i k hk _⟩
  have : timers i = 0 ∧ Action.kinetic.isKinetic = true ∧ ∃ j, timers j ≠ 0 :=
    ⟨hi, rfl, j, hj⟩
  simp only [groupStep, if_pos this, Function.update_self]

end RoundThreeCuration
