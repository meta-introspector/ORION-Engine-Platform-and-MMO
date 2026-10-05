module

public import Mathlib
public import RequestProject.Zoo.Arena

/-!
# Dragons: 64 gold locks, the sun, species and looks

Exact statements of the designer's answers about unlocking and shaping a dragon.

* "Level" here means one of the 64 character nodes being unlocked or gold-locked. Gold-locking
  depends on play (a sharp shooter can gold-lock all 64 straight away), not on skill levels.
* Gold-locking all 64 nodes gives the dragon seed. To hatch it, the player has to take the seed
  to a sun, which needs the skills to escape the planetary skybox.
* The player's skill in the biological line decides which looks they can give the dragon. A
  low-skill dragon looks plain but can do everything any dragon of its species can do.
* The underlying species build is chosen at hatching from the Proofs Arena animals (or the
  generic dragon) and can never change. Every other aspect (colour, structure, …) can.

*Update:* the designer's later answers refine this file; see `Curation.lean`. Species, body
aspects and archetype upgrades all affect abilities, and only the skin doesn't
(`RoundThreeCuration.skin_never_matters`). The species list is the actual animals plus the
generic dragon and the phoenix; `HIVE`, `PULSE` and `SHEPHERD` become archetype upgrades
(`RoundThreeCuration.roster_split`). Reaching a sun means getting through the skybox gate with
the quest-line escape feature or a key (`RoundThreeCuration.canHatch`). Menus only ever show
options within reach (`RoundThreeCuration.menu_within_reach`).
-/

@[expose] public section
namespace RoundThreeDragon

/-! ## Gold locks need play, not skill; hatching needs the sun -/

/-- What matters about a player here: how many of the 64 character nodes are gold-locked, their
skill for escaping the planetary skybox, and their biological-line skill. -/
structure Player where
  goldLocks : ℕ
  escapeSkill : ℕ
  bioSkill : ℕ

/-- A player new to the game. -/
def fresh : Player := ⟨0, 0, 0⟩

/-- Gold-lock one more node (for example by sharp shooting). No skill level is required, and
skills do not change. At most 64 nodes can be gold-locked. -/
def lockNode (p : Player) : Player := { p with goldLocks := min 64 (p.goldLocks + 1) }

theorem lockNode_iterate (k : ℕ) (hk : k ≤ 64) :
    (lockNode^[k] fresh) = ⟨k, 0, 0⟩ := by
  induction k with
  | zero => rfl
  | succ k ih =>
    rw [Function.iterate_succ_apply', ih (by omega)]
    simp only [lockNode, Player.mk.injEq, and_true]
    omega

/-- **A sharp shooter can gold-lock all 64 at once.** A fresh player can gold-lock all 64
nodes with every skill still at zero. -/
theorem sharpshooter_all_64 : lockNode^[64] fresh = ⟨64, 0, 0⟩ :=
  lockNode_iterate 64 le_rfl

/-- The player can plant the dragon seed in a sun: all 64 nodes gold-locked, and escape skill
at least `E`, what it takes to leave the planetary skybox and reach a sun.

*Superseded* by `RoundThreeCuration.canHatch`: passing the skybox gate takes the quest-line
escape feature or a key, not a skill threshold. -/
def canPlantSeed (E : ℕ) (p : Player) : Prop := p.goldLocks = 64 ∧ E ≤ p.escapeSkill

instance (E : ℕ) (p : Player) : Decidable (canPlantSeed E p) := by
  unfold canPlantSeed; infer_instance

/-- **No sun, no dragon.** Gold-locking all 64 nodes is not enough: a fresh sharp shooter with
no escape skill cannot hatch a dragon. -/
theorem sharpshooter_cannot_hatch (E : ℕ) (hE : 0 < E) :
    ¬ canPlantSeed E (lockNode^[64] fresh) := by
  rw [sharpshooter_all_64]
  simp [canPlantSeed]
  omega

/-- Hatching needs all 64 gold locks and the escape skill; nothing else. In particular the
biological-line skill does not matter for hatching. -/
theorem canPlantSeed_iff (E : ℕ) (p : Player) :
    canPlantSeed E p ↔ p.goldLocks = 64 ∧ E ≤ p.escapeSkill := Iff.rfl

/-! ## Species: chosen once from the Proofs Arena roster -/

/-- The species a dragon can be built on: any Core animal of the Proofs Arena roster. Its
entry `"DRAGON"` is the generic dragon.

*Superseded* by `RoundThreeCuration.speciesChoices`: the three non-animal systems are archetype
upgrades, not species. -/
def speciesChoices : List String := EFMWZoo.coreRoster

/-- The roster offers 46 builds, including the whale and the generic dragon. -/
theorem speciesChoices_spec :
    speciesChoices.length = 46 ∧ "WHALE" ∈ speciesChoices ∧ "DRAGON" ∈ speciesChoices := by
  decide

/-- A dragon: its species build and its look. `L` is the type of looks (colour, structure and
every other changeable aspect). -/
structure Dragon (L : Type) where
  species : String
  look : L

variable {L : Type}

/-- Hatch a dragon of a chosen species, with the plain starting look `plain`. Refused unless
the player can plant the seed and the species is on the roster. -/
def hatch (E : ℕ) (p : Player) (s : String) (plain : L) : Option (Dragon L) :=
  if canPlantSeed E p ∧ s ∈ speciesChoices then some ⟨s, plain⟩ else none

theorem hatch_spec (E : ℕ) (p : Player) (s : String) (plain : L) (d : Dragon L)
    (h : hatch E p s plain = some d) :
    canPlantSeed E p ∧ d.species = s ∧ s ∈ speciesChoices := by
  unfold hatch at h
  split_ifs at h with hc
  cases h
  exact ⟨hc.1, rfl, hc.2⟩

/-! ## Looks: unlocked by biological-line skill; species never changes -/

/-- Change the dragon's look to `l`. `tier l` is the biological-line skill a look needs.
Refused if the player's skill is too low. Only the look changes. -/
def customize (tier : L → ℕ) (bio : ℕ) (d : Dragon L) (l : L) : Option (Dragon L) :=
  if tier l ≤ bio then some { d with look := l } else none

/-- Apply a sequence of look changes (each with the player's skill at that time), skipping any
that are refused. -/
def customizeAll (tier : L → ℕ) (d : Dragon L) : List (ℕ × L) → Dragon L
  | [] => d
  | (bio, l) :: rest => customizeAll tier ((customize tier bio d l).getD d) rest

/-- **A whale dragon is always a whale dragon.** No sequence of look changes, at any skill
levels, changes the species build. -/
theorem species_forever (tier : L → ℕ) (d : Dragon L) (cs : List (ℕ × L)) :
    (customizeAll tier d cs).species = d.species := by
  induction cs generalizing d with
  | nil => rfl
  | cons c rest ih =>
    obtain ⟨bio, l⟩ := c
    simp only [customizeAll]
    rw [ih]
    unfold customize
    split_ifs <;> rfl

/-- **Everything else can change.** With enough skill, any look at all can be given to the
dragon. -/
theorem any_look_reachable (tier : L → ℕ) (d : Dragon L) (l : L) :
    customize tier (tier l) d l = some { d with look := l } := by
  simp [customize]

/-- **Skill only adds options.** A look available at some skill stays available at any higher
skill. -/
theorem looks_monotone (tier : L → ℕ) (d : Dragon L) (l : L) (bio bio' : ℕ) (hb : bio ≤ bio')
    (h : (customize tier bio d l).isSome) : (customize tier bio' d l).isSome := by
  unfold customize at *
  split_ifs at h with h1
  · rw [if_pos (le_trans h1 hb)]; rfl
  · simp at h

/-- A low-skill player is held to plain looks: a look whose tier is above their skill is
refused. -/
theorem low_skill_refused (tier : L → ℕ) (d : Dragon L) (l : L) (bio : ℕ) (h : bio < tier l) :
    customize tier bio d l = none := by
  simp [customize]
  omega

/-- **Plain but fully capable.** Whatever a dragon can do is decided by its species build
(`cap`), never by its look, so a plain low-skill dragon can do everything a fully curated dragon
of the same species can.

*Superseded* by `RoundThreeCuration.skin_never_matters`: curated body aspects and archetype
upgrades also affect abilities; only the skin never does. -/
theorem looks_do_not_matter {C : Type} (cap : String → C) (d : Dragon L) (l : L) :
    cap ({ d with look := l } : Dragon L).species = cap d.species ∧
      ∀ cs (tier : L → ℕ), cap (customizeAll tier d cs).species = cap d.species :=
  ⟨rfl, fun cs tier => by rw [species_forever]⟩

end RoundThreeDragon
