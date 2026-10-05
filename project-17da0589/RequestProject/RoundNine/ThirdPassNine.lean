module

public import Mathlib

/-!
# Round Nine, third pass: the new spaghetti on *ORION R9 Live*

* **Stars are dragons' homes (solar boxes).** Every place in the game sits inside at most one
  enclosing place (`parent`), and nesting has finite depth. A star is a dragon's solar box; the
  dragon's domain is everything inside it, including nested skyboxes and bubbles.
  Proved: for anything inside at least one star there is exactly one *nearest* enclosing star
  (`nearestStar_exists`, `nearestStar_unique`); when no star sits inside another star's universe,
  the nearest star is simply the star you are inside (`nearestStar_of_no_nested`), so two dragons'
  domains never overlap (`domains_disjoint`).
* **Pre-launch idea pipeline (construction council).** Players submit ideas; an idea goes to the
  DEVs only if it isn't already in the searchable wiki, and the first person to submit it gets the
  credit. Proved: an idea is forwarded exactly when it is new (`submit_forwards_iff`); no idea ever
  reaches the DEVs twice (`run_inbox_nodup`); every submitted idea ends up in the wiki
  (`run_submitted_known`); and once credited, the credit never moves to someone else
  (`run_credit_kept`).
* **Advertisement bubbles and honorable mentions.** A downloadable app mentioned during the build
  gets exactly one advertisement bubble, however often it is mentioned (`mem_adBubbles`,
  `adBubbles_repeat`); the same rule gives every song on the build playlist an honorable mention.
-/

@[expose] public section

namespace RoundNineThird

open Relation

/-! ## 1. Stars, solar boxes and dragon domains -/

/-- The map of places: each place has at most one enclosing place, and nesting has finite depth
(the enclosing place is always one level shallower). -/
structure World (S : Type) where
  parent : S → Option S
  depth : S → ℕ
  depth_lt : ∀ s t, parent s = some t → depth t < depth s

variable {S : Type} (w : World S)

/-- One step outward: `t` directly encloses `s`. -/
def World.Up (s t : S) : Prop := w.parent s = some t

/-- `s` is inside `t` (or is `t`). -/
def World.Inside (s t : S) : Prop := ReflTransGen w.Up s t

theorem up_rightUnique : Relator.RightUnique w.Up := by
  intro a b c hb hc
  simp only [World.Up] at hb hc
  rw [hb] at hc
  exact Option.some.inj hc

theorem inside_depth {s t : S} (h : w.Inside s t) : w.depth t ≤ w.depth s := by
  induction h with
  | refl => exact le_rfl
  | tail _ hup ih => exact (w.depth_lt _ _ hup).le.trans ih

theorem inside_eq_of_depth {s t : S} (h : w.Inside s t) (hd : w.depth s ≤ w.depth t) : s = t := by
  rcases ReflTransGen.cases_head h with rfl | ⟨u, hsu, hut⟩
  · rfl
  · have h1 := w.depth_lt _ _ hsu
    have h2 := inside_depth w hut
    omega

theorem inside_antisymm {s t : S} (h1 : w.Inside s t) (h2 : w.Inside t s) : s = t :=
  inside_eq_of_depth w h1 (inside_depth w h2)

/-- `a` is the nearest star enclosing `s`: it encloses `s`, and every star enclosing `s` also
encloses `a`. -/
def World.NearestStar (isStar : S → Prop) (s a : S) : Prop :=
  w.Inside s a ∧ isStar a ∧ ∀ b, isStar b → w.Inside s b → w.Inside a b

/-- There is at most one nearest star. -/
theorem nearestStar_unique (isStar : S → Prop) {s a b : S}
    (ha : w.NearestStar isStar s a) (hb : w.NearestStar isStar s b) : a = b :=
  inside_antisymm w (ha.2.2 b hb.2.1 hb.1) (hb.2.2 a ha.2.1 ha.1)

/-- Anything inside at least one star has a nearest star. -/
theorem nearestStar_exists (isStar : S → Prop) {s a : S} (hs : w.Inside s a) (ha : isStar a) :
    ∃ c, w.NearestStar isStar s c := by
  classical
  suffices key : ∀ n s, w.depth s < n → ∀ a, w.Inside s a → isStar a →
      ∃ c, w.NearestStar isStar s c from key _ s (Nat.lt_succ_self _) a hs ha
  intro n
  induction n with
  | zero => intro s h; omega
  | succ n ih =>
    intro s hn a hs ha
    by_cases hstar : isStar s
    · exact ⟨s, ReflTransGen.refl, hstar, fun b _ hb => hb⟩
    · rcases ReflTransGen.cases_head hs with rfl | ⟨t, hst, hta⟩
      · exact absurd ha hstar
      · have hdt : w.depth t < n := by have := w.depth_lt _ _ hst; omega
        obtain ⟨c, hc1, hc2, hc3⟩ := ih t hdt a hta ha
        refine ⟨c, ReflTransGen.head hst hc1, hc2, fun b hb hsb => ?_⟩
        rcases ReflTransGen.cases_head hsb with rfl | ⟨t', hst', ht'b⟩
        · exact absurd hb hstar
        · have : t' = t := up_rightUnique w hst' hst
          subst this
          exact hc3 b hb ht'b

/-- If no star sits inside another star's universe, the nearest star of anything inside a star is
that star: everything inside a solar box belongs to its dragon. -/
theorem nearestStar_of_no_nested (isStar : S → Prop)
    (noNest : ∀ a b, isStar a → isStar b → w.Inside a b → a = b)
    {s a : S} (hs : w.Inside s a) (ha : isStar a) : w.NearestStar isStar s a := by
  refine ⟨hs, ha, fun b hb hsb => ?_⟩
  rcases ReflTransGen.total_of_right_unique (up_rightUnique w) hs hsb with h | h
  · exact h
  · rw [noNest b a hb ha h]
    exact ReflTransGen.refl

/-- With no nested stars, two dragons' domains never overlap. -/
theorem domains_disjoint (isStar : S → Prop)
    (noNest : ∀ a b, isStar a → isStar b → w.Inside a b → a = b)
    {s a b : S} (ha : isStar a) (hb : isStar b) (hsa : w.Inside s a) (hsb : w.Inside s b) :
    a = b :=
  nearestStar_unique w isStar (nearestStar_of_no_nested w isStar noNest hsa ha)
    (nearestStar_of_no_nested w isStar noNest hsb hb)

/-! ## 2. Pre-launch idea pipeline -/

/-- The searchable wiki: the ideas already known, who gets credit for each, and the DEV inbox. -/
structure Wiki (I P : Type) where
  known : Finset I
  credit : I → Option P
  inbox : List I

variable {I P : Type} [DecidableEq I]

/-- Player `p` submits idea `i`. A known idea changes nothing; a new idea is added to the wiki,
credited to `p`, and sent to the DEVs. -/
def submit (w : Wiki I P) (p : P) (i : I) : Wiki I P :=
  if i ∈ w.known then w
  else { known := insert i w.known, credit := Function.update w.credit i (some p),
         inbox := w.inbox ++ [i] }

/-- A whole sequence of submissions. -/
def run (w : Wiki I P) : List (P × I) → Wiki I P
  | [] => w
  | (p, i) :: rest => run (submit w p i) rest

/-- An idea is forwarded to the DEVs exactly when it isn't already in the wiki. -/
theorem submit_forwards_iff (w : Wiki I P) (p : P) (i : I) :
    (submit w p i).inbox = w.inbox ++ [i] ↔ i ∉ w.known := by
  unfold submit
  split_ifs with h
  · simp [h]
  · simp [h]

/-- A well-formed wiki: no idea is in the inbox twice, and every forwarded idea is known. -/
def Wiki.Good (w : Wiki I P) : Prop := w.inbox.Nodup ∧ ∀ i ∈ w.inbox, i ∈ w.known

theorem submit_good {w : Wiki I P} (h : w.Good) (p : P) (i : I) : (submit w p i).Good := by
  unfold submit
  split_ifs with hi
  · exact h
  · refine ⟨?_, ?_⟩
    · refine List.nodup_append.2 ⟨h.1, List.nodup_singleton i, ?_⟩
      intro a ha b hb
      rw [List.mem_singleton] at hb
      subst hb
      rintro rfl
      exact hi (h.2 a ha)
    · intro j hj
      rcases List.mem_append.1 hj with hj | hj
      · exact Finset.mem_insert_of_mem (h.2 j hj)
      · rw [List.mem_singleton.1 hj]
        exact Finset.mem_insert_self _ _

theorem run_good {w : Wiki I P} (h : w.Good) (subs : List (P × I)) : (run w subs).Good := by
  induction subs generalizing w with
  | nil => exact h
  | cons x rest ih => exact ih (submit_good h x.1 x.2)

/-- Starting from an empty inbox, no idea ever reaches the DEVs twice. -/
theorem run_inbox_nodup (known : Finset I) (credit : I → Option P) (subs : List (P × I)) :
    (run ⟨known, credit, []⟩ subs).inbox.Nodup :=
  (run_good ⟨List.nodup_nil, by simp⟩ subs).1

theorem known_subset_submit (w : Wiki I P) (p : P) (i : I) : w.known ⊆ (submit w p i).known := by
  unfold submit
  split_ifs
  · exact subset_rfl
  · exact Finset.subset_insert _ _

theorem known_subset_run (w : Wiki I P) (subs : List (P × I)) : w.known ⊆ (run w subs).known := by
  induction subs generalizing w with
  | nil => exact subset_rfl
  | cons x rest ih => exact (known_subset_submit w x.1 x.2).trans (ih _)

theorem mem_known_submit (w : Wiki I P) (p : P) (i : I) : i ∈ (submit w p i).known := by
  unfold submit
  split_ifs with h
  · exact h
  · exact Finset.mem_insert_self _ _

/-- Every submitted idea ends up in the wiki. -/
theorem run_submitted_known (w : Wiki I P) (subs : List (P × I)) :
    ∀ x ∈ subs, x.2 ∈ (run w subs).known := by
  induction subs generalizing w with
  | nil => simp
  | cons x rest ih =>
    intro y hy
    rcases List.mem_cons.1 hy with rfl | hy
    · exact known_subset_run _ rest (mem_known_submit w y.1 y.2)
    · exact ih _ y hy

theorem submit_credit_of_known {w : Wiki I P} {i : I} (hi : i ∈ w.known) (p : P) (j : I) :
    (submit w p j).credit i = w.credit i := by
  unfold submit
  split_ifs with hj
  · rfl
  · have : i ≠ j := by rintro rfl; exact hj hi
    simp [Function.update_of_ne this]

/-- Once an idea is in the wiki, its credit never changes, whatever is submitted later. -/
theorem run_credit_kept {w : Wiki I P} {i : I} (hi : i ∈ w.known) (subs : List (P × I)) :
    (run w subs).credit i = w.credit i := by
  induction subs generalizing w with
  | nil => rfl
  | cons x rest ih =>
    simp only [run]
    rw [ih (known_subset_submit w x.1 x.2 hi), submit_credit_of_known hi]

/-- The first person to submit a new idea is credited with it. -/
theorem submit_credit_new {w : Wiki I P} {i : I} (hi : i ∉ w.known) (p : P) :
    (submit w p i).credit i = some p := by
  simp [submit, hi]

/-! ## 3. Advertisement bubbles and honorable mentions -/

/-- The advertisement bubbles on the construction site: one per downloadable app mentioned during
the build (the same rule, with "on the build playlist", gives the honorable mentions). -/
def adBubbles {A : Type} [DecidableEq A] (downloadable : A → Prop) [DecidablePred downloadable]
    (mentions : List A) : Finset A :=
  (mentions.filter (fun a => downloadable a)).toFinset

/-- An app has a bubble exactly when it was mentioned and can be downloaded. -/
theorem mem_adBubbles {A : Type} [DecidableEq A] (downloadable : A → Prop)
    [DecidablePred downloadable] (mentions : List A) (a : A) :
    a ∈ adBubbles downloadable mentions ↔ a ∈ mentions ∧ downloadable a := by
  simp [adBubbles]

/-- Mentioning an app again gives it no second bubble. -/
theorem adBubbles_repeat {A : Type} [DecidableEq A] (downloadable : A → Prop)
    [DecidablePred downloadable] (mentions : List A) {a : A} (ha : a ∈ mentions) :
    adBubbles downloadable (mentions ++ [a]) = adBubbles downloadable mentions := by
  ext b
  simp only [mem_adBubbles, List.mem_append, List.mem_singleton]
  constructor
  · rintro ⟨hb | rfl, hd⟩
    · exact ⟨hb, hd⟩
    · exact ⟨ha, hd⟩
  · rintro ⟨hb, hd⟩
    exact ⟨Or.inl hb, hd⟩

end RoundNineThird
