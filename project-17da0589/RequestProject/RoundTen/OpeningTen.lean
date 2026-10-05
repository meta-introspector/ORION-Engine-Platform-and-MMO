module

public import Mathlib

/-!
# Round Ten: a separate, skill-gated language display

This is a proposed *model*, not a claim about the existing Python engine. The canonical
message is always stored separately from its player-facing display. Safety instructions are
not sent through the garbling path. Ordinary words have proficiency thresholds; greater skill
can reveal more original words, but cannot make a previously revealed word garbled.
-/

@[expose] public section

namespace RoundTenOpening

/-- Distinguish authoritative safety messages from ordinary role-play language. -/
inductive MessageKind where
  | safety
  | ordinary
  deriving DecidableEq, Repr

/-- A word in the language dictionary and the skill at which it becomes clear. -/
structure Word where
  original : String
  garbled : String
  threshold : ℕ
  deriving DecidableEq, Repr

/-- Render ordinary words at a player's skill, leaving safety messages unchanged. -/
def displayWord (kind : MessageKind) (skill : ℕ) (w : Word) : String :=
  if kind = .safety ∨ w.threshold ≤ skill then w.original else w.garbled

/-- A message retains its canonical words even if its display is garbled. -/
structure LanguageMessage where
  kind : MessageKind
  words : List Word
  deriving Repr

/-- The player-facing display; this is never substituted for `canonical`. -/
def display (skill : ℕ) (m : LanguageMessage) : List String :=
  m.words.map (displayWord m.kind skill)

/-- The canonical words are independently available for review and audit. -/
def canonical (m : LanguageMessage) : List String :=
  m.words.map Word.original

/-- Store the authoritative original alongside the skill-specific rendering. -/
def render (skill : ℕ) (m : LanguageMessage) : List String × List String :=
  (canonical m, display skill m)

/-- All safety messages retain their words, regardless of language skill. -/
theorem safety_display_is_canonical (skill : ℕ) (words : List Word) :
    display skill ⟨.safety, words⟩ = canonical ⟨.safety, words⟩ := by
  simp [display, canonical, displayWord]

/-- At or above every word's threshold the ordinary display is clear. -/
theorem sufficiently_skilled_sees_canonical (skill : ℕ) (words : List Word)
    (h : ∀ w ∈ words, w.threshold ≤ skill) :
    display skill ⟨.ordinary, words⟩ = canonical ⟨.ordinary, words⟩ := by
  simp only [display, canonical, List.map_inj_left]
  intro w hw
  simp [displayWord, h w hw]

/-- Increasing skill never re-garbles a previously clear ordinary word. -/
theorem clarity_monotone (low high : ℕ) (w : Word)
    (hskill : low ≤ high) (hclear : w.threshold ≤ low) :
    displayWord .ordinary high w = w.original := by
  simp [displayWord, le_trans hclear hskill]

/-- The canonical text does not depend on the reader's proficiency. -/
theorem render_retains_canonical (skill : ℕ) (m : LanguageMessage) :
    (render skill m).1 = canonical m := by
  rfl

end RoundTenOpening
