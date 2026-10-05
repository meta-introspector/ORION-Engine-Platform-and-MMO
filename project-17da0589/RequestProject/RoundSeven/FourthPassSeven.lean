module

public import Mathlib
public import RequestProject.RoundFour.RulingsFour
public import RequestProject.RoundSeven.FollowUpSeven

/-!
# Round Seven, fourth pass: the ToC X-Summary page, quests that never run out, skins, and a
# story gate for Elder's Garden

Material read on the page now titled *ORION R7 💎*, and on the *ToC X-Summary* page and the two
shared chats linked from it.

* **Skins are cosmetic (ToC X-Summary).** An ability rule ignores skin exactly when it can be
  written using only species, body, archetype and acquired traits (`skinBlind_iff_factors`). So
  "swap the skin, nothing changes" is a complete test for a dev's ability formula.
* **"No one is ever truly stuck" (ToC X-Summary).** If infinitely many quests in the catalogue are
  fair for a beginner (skill 0), then at every skill level, however many quests a player has
  already finished, there is still an unfinished quest they can complete
  (`never_stuck`). With only finitely many beginner-fair quests, a player who has done them all
  at skill 0 is stuck (`stuck_if_finite`), so the claim needs the catalogue to keep growing.
* **Elder's Garden story gate (proposal, from the second shared chat).** Each story declares a
  genre, real or lore. A story is published only if it is consistent with the stories already
  published in the same genre, using Ryan's Loom contract check. Then each genre's published
  record is always consistent (`run_canon_satisfiable`), a refused story changes nothing
  (`publish_refused`), and publishing a lore story never changes the real record
  (`lore_leaves_real`). The check is about consistency only: a story that is false in the real
  world can still pass (`gate_cannot_certify_truth`).
-/

@[expose] public section

namespace RoundSevenFourthPass

/-! ## Skins are cosmetic -/

/-- A character, as described on the ToC X-Summary page. -/
structure Character (Sp Bd Ar Sk Tr : Type) where
  species : Sp
  body : Bd
  archetype : Ar
  skin : Sk
  traits : List Tr

variable {Sp Bd Ar Sk Tr α : Type}

/-- An ability rule is skin-blind when changing a character's skin never changes its result. -/
def SkinBlind (ability : Character Sp Bd Ar Sk Tr → α) : Prop :=
  ∀ c (s : Sk), ability { c with skin := s } = ability c

/-- **Skin is cosmetic, exactly.** An ability rule is skin-blind if and only if it is computed
from species, body, archetype and acquired traits alone. -/
theorem skinBlind_iff_factors [Nonempty Sk] (ability : Character Sp Bd Ar Sk Tr → α) :
    SkinBlind ability ↔
      ∃ f : Sp → Bd → Ar → List Tr → α,
        ∀ c, ability c = f c.species c.body c.archetype c.traits := by
  constructor
  · intro h
    obtain ⟨s₀⟩ := ‹Nonempty Sk›
    exact ⟨fun sp bd ar tr => ability ⟨sp, bd, ar, s₀, tr⟩, fun c => (h c s₀).symm⟩
  · rintro ⟨f, hf⟩ c s
    rw [hf, hf]

/-- **Acquired traits never replace species.** Adding a trait leaves species unchanged. -/
theorem trait_keeps_species (c : Character Sp Bd Ar Sk Tr) (t : Tr) :
    ({ c with traits := t :: c.traits } : Character Sp Bd Ar Sk Tr).species = c.species := rfl

/-! ## Nobody is ever stuck, provided the catalogue keeps growing -/

open RoundFourRulingsFour

/-- **Nobody is ever stuck.** Suppose infinitely many quests in the catalogue are completable from
skill 0. Then for every skill level `s` and every finite set of finished quests, some unfinished
quest is completable at skill `s`. -/
theorem never_stuck (catalogue : ℕ → List Stage)
    (hinf : {i | completable 0 (catalogue i) = true}.Infinite)
    (s : ℕ) (done : Finset ℕ) :
    ∃ i, i ∉ done ∧ completable s (catalogue i) = true := by
  obtain ⟨i, hi, hnot⟩ := hinf.exists_notMem_finset done
  exact ⟨i, hnot, completable_mono 0 s (Nat.zero_le s) _ hi⟩

/-- **With finitely many beginner quests, a beginner can get stuck.** If only finitely many
quests are completable from skill 0, a skill-0 player who has finished all of them has nothing
left that they can complete. -/
theorem stuck_if_finite (catalogue : ℕ → List Stage)
    (hfin : {i | completable 0 (catalogue i) = true}.Finite) :
    ∃ done : Finset ℕ, ∀ i, i ∉ done → completable 0 (catalogue i) = false := by
  refine ⟨hfin.toFinset, fun i hi => ?_⟩
  simpa [Set.Finite.mem_toFinset] using hi

/-! ## Elder's Garden story gate (proposal) -/

open RoundSevenFollowUp

/-- The genre a writer must choose before publishing. -/
inductive Genre where
  | real
  | lore
  deriving DecidableEq

/-- A story: its declared genre and the facts it asserts, written as Loom constraints. -/
structure Story (Key : Type) where
  genre : Genre
  claims : List (Constraint Key)

/-- Everything already published in one genre, as one list of constraints. -/
def canon {Key : Type} (published : List (Story Key)) (g : Genre) : List (Constraint Key) :=
  ((published.filter (fun st => st.genre = g)).map Story.claims).flatten

/-- A story may be published when the Loom check accepts it together with everything already
published in its genre. -/
def Admissible {Key : Type} [DecidableEq Key] (published : List (Story Key)) (st : Story Key) :
    Prop :=
  contractCheck (canon published st.genre ++ st.claims)

open Classical in
/-- Try to publish a story: it is added only if admissible. -/
noncomputable def publish {Key : Type} [DecidableEq Key] (published : List (Story Key))
    (st : Story Key) : List (Story Key) :=
  if Admissible published st then published ++ [st] else published

/-- **A refused story changes nothing.** -/
theorem publish_refused {Key : Type} [DecidableEq Key] (published : List (Story Key))
    (st : Story Key) (h : ¬ Admissible published st) : publish published st = published := by
  simp [publish, h]

theorem canon_append_single {Key : Type} (published : List (Story Key)) (st : Story Key)
    (g : Genre) :
    canon (published ++ [st]) g =
      canon published g ++ (if st.genre = g then st.claims else []) := by
  unfold canon
  by_cases h : st.genre = g <;> simp [List.filter_append, h]

/-- **Publishing a lore story never changes the real record** (and the same with the genres
swapped). -/
theorem publish_other_genre {Key : Type} [DecidableEq Key] (published : List (Story Key))
    (st : Story Key) (g : Genre) (hg : st.genre ≠ g) :
    canon (publish published st) g = canon published g := by
  unfold publish
  split_ifs
  · rw [canon_append_single]; simp [hg]
  · rfl

theorem lore_leaves_real {Key : Type} [DecidableEq Key] (published : List (Story Key))
    (st : Story Key) (h : st.genre = .lore) :
    canon (publish published st) .real = canon published .real :=
  publish_other_genre published st .real (by rw [h]; decide)

theorem satisfiable_nil {Key : Type} : Satisfiable ([] : List (Constraint Key)) :=
  ⟨fun _ => .int 0, by simp⟩

/-- One publication attempt keeps every genre's record consistent. -/
theorem publish_canon_satisfiable {Key : Type} [DecidableEq Key] (published : List (Story Key))
    (st : Story Key) (h : ∀ g, Satisfiable (canon published g)) (g : Genre) :
    Satisfiable (canon (publish published st) g) := by
  by_cases hg : st.genre = g
  · unfold publish
    split_ifs with hadm
    · rw [canon_append_single, if_pos hg]
      have := (contractCheck_iff_satisfiable _).1 hadm
      rwa [hg] at this
    · exact h g
  · rw [publish_other_genre published st g hg]; exact h g

/-- Publish a list of stories one after another, starting from nothing. -/
noncomputable def runPublish {Key : Type} [DecidableEq Key] (attempts : List (Story Key)) :
    List (Story Key) :=
  attempts.foldl publish []

/-- **Each genre's published record is always consistent**, whatever stories are submitted and
in whatever order. -/
theorem run_canon_satisfiable {Key : Type} [DecidableEq Key] (attempts : List (Story Key))
    (g : Genre) : Satisfiable (canon (runPublish attempts) g) := by
  suffices ∀ (start : List (Story Key)), (∀ g, Satisfiable (canon start g)) →
      ∀ g, Satisfiable (canon (attempts.foldl publish start) g) by
    exact this [] (fun g => by simpa [canon] using satisfiable_nil) g
  induction attempts with
  | nil => intro start h; simpa using h
  | cons st rest ih =>
    intro start h
    exact ih _ (publish_canon_satisfiable start st h)

/-- **Consistency is not truth.** For any real world and any key, there is a "real" story that
passes the gate on an empty profile but is false in that world. -/
theorem gate_cannot_certify_truth {Key : Type} [DecidableEq Key] (world : Key → Scalar)
    (k : Key) :
    ∃ st : Story Key, st.genre = .real ∧ Admissible [] st ∧
      ¬ ∀ c ∈ st.claims, Holds c (world c.key) := by
  let v : Scalar := if world k = .int 0 then .int 1 else .int 0
  refine ⟨⟨.real, [⟨k, .equals, v⟩]⟩, rfl, ?_, ?_⟩
  · unfold Admissible
    rw [contractCheck_iff_satisfiable]
    exact ⟨fun _ => v, by simp [canon, Holds]⟩
  · intro h
    have := h _ (List.mem_singleton_self _)
    simp only [Holds] at this
    by_cases h0 : world k = .int 0
    · simp [v, h0] at this
    · simp [v, h0] at this

end RoundSevenFourthPass

end
