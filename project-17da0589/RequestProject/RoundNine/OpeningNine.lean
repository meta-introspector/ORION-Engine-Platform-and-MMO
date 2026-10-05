module

public import Mathlib
public import RequestProject.RoundEight.OpeningEight

/-!
# Round Nine, opening pass: *ORION R9 Live* and the answers written under the R8 reply

* **Protecting everybody's work (the DEV / Galactic council rule).** A change that would
  supersede a design goes through a first gate, then the Galactic council, then a human. At the
  first gate an active creator of an original (non-mutated) design has the final say; otherwise
  (creator inactive or unavailable, or a mutated schematic) the whole DEV team must agree. The rule
  cascades: a change touching several designs needs every one of their gates.
  Proved: an active creator's "no" blocks the change (`creator_veto`); nothing passes without the
  council and a human (`approved_needs_council_and_human`); an inactive creator's design changes
  only with the whole DEV team's agreement (`inactive_needs_dev_consensus`, `one_dev_blocks`);
  when every affected creator is active, DEV agreement is not needed (`approved_iff_all_active`);
  and over any sequence of changes, a design whose active creator never said yes is never changed
  (`work_protected`).
* **Diamond lock.** A 💎 entry in the official archive changes only through an edit signed by its
  owner (`diamond_locked`); an unsigned edit never changes it (`unsigned_edit_diamond`). A copy
  whose 💎 values differ from the official record fails the official check (`altered_copy_fails`).
* **Skill orbs, version 3.** Orbs level up to 100; only a level-100 (gold-locked) orb can be slotted
  into the 64-node matrix (`slot_iff_gold`). Crafting makes empty (level 0) orbs, deconstructing
  turns an orb back into raw materials, and trading only moves orbs, so across the whole world,
  every skill level that exists was trained by someone (`levels_only_from_training`). In a world
  that starts with empty orbs, any 64 gold orbs took at least 6,400 training steps in total
  (`gold_needs_training`, `sixtyfour_gold_cost`). Everyone's 64 starter orbs exactly fill the
  matrix (`starter_fills_matrix`).
* **Ordinary dragons choose their elemental path** and progress one element at a time. Mastered
  elements are never repeated (`mastered_nodup`), never lost (`mastered_prefix`), and any order the
  player picks can be followed (`any_path_achievable`).
* **Skybox access, version 2.** Owners (and DEVs) set public, private, invite-only, by-request,
  minimum-level, archetype or build access, or combinations of these. Only the owner or a DEV can
  change the setting (`setPolicy_unauthorized`); the owner can always enter
  (`owner_can_enter`); a private skybox admits only its owner (`private_only_owner`).
* **RD pool at 3%: three ways to make it fit.** (A) shared pots: never more than 33% of a pool
  (`optionA_total_le`); (B) per person with a cap: fits exactly when `3·creators + 30·collaborators
  ≤ 100`, so at most three collaborators beside one creator (`optionB_fits_iff`, `optionB_cap`);
  (C) per person, scaled down when over 100%: always fits (`optionC_total_le`) and keeps every
  collaborator at exactly ten times a creator (`optionC_ratio`).
* **Phoenix vs stacked ordinary dragons, worked numbers** for possible stacking costs
  (`stack_table_5`, `stack_table_10`, `phoenix_ge_stacked`).
-/

@[expose] public section

namespace RoundNineOpening

open Classical

/-! ## 1. Protecting everybody's work: creator, DEV team, Galactic council, human -/

/-- The state of one existing design at the time a change is voted on. -/
structure Design where
  /-- The creator is still playing and available to answer. -/
  creatorActive : Bool
  /-- The design is a mutated schematic (derived from someone else's work). -/
  mutated : Bool

/-- A design whose creator has the final say: an original design with an active creator. -/
def CreatorDecides (d : Design) : Prop := d.creatorActive = true ∧ d.mutated = false

/-- The votes on one proposed change. -/
structure Ballot (ι Dev : Type) where
  /-- Each affected design's creator approves. -/
  creatorYes : ι → Bool
  /-- Each DEV team member agrees. -/
  devYes : Dev → Bool
  /-- The Galactic council finalises. -/
  council : Bool
  /-- A human gives the last pass. -/
  human : Bool

variable {ι Dev : Type}

/-- The first gate for one affected design: its creator if they decide, otherwise the whole DEV
team. -/
def GatePasses (team : Finset Dev) (status : ι → Design) (b : Ballot ι Dev) (i : ι) : Prop :=
  if CreatorDecides (status i) then b.creatorYes i = true else ∀ m ∈ team, b.devYes m = true

/-- A change touching the designs in `affected` goes through when every affected design passes
its first gate, the Galactic council finalises it and a human passes it. -/
def Approved (team : Finset Dev) (status : ι → Design) (affected : Finset ι) (b : Ballot ι Dev) :
    Prop :=
  (∀ i ∈ affected, GatePasses team status b i) ∧ b.council = true ∧ b.human = true

/-- **An active creator's "no" blocks the change.** -/
theorem creator_veto (team : Finset Dev) (status : ι → Design) (affected : Finset ι)
    (b : Ballot ι Dev) {i : ι} (hi : i ∈ affected) (hc : CreatorDecides (status i))
    (hno : b.creatorYes i = false) : ¬ Approved team status affected b := by
  rintro ⟨h, -, -⟩
  have := h i hi
  rw [GatePasses, if_pos hc, hno] at this
  exact Bool.false_ne_true this

/-- **Nothing goes through without the Galactic council and a human.** -/
theorem approved_needs_council_and_human (team : Finset Dev) (status : ι → Design)
    (affected : Finset ι) (b : Ballot ι Dev) (h : Approved team status affected b) :
    b.council = true ∧ b.human = true := h.2

/-- **When the creator can't decide (inactive, unavailable, or a mutated schematic), the whole DEV
team must agree.** -/
theorem inactive_needs_dev_consensus (team : Finset Dev) (status : ι → Design)
    (affected : Finset ι) (b : Ballot ι Dev) {i : ι} (hi : i ∈ affected)
    (hc : ¬ CreatorDecides (status i)) (h : Approved team status affected b) :
    ∀ m ∈ team, b.devYes m = true := by
  have := h.1 i hi
  rwa [GatePasses, if_neg hc] at this

/-- **One DEV member's "no" blocks a change to a design whose creator can't decide.** -/
theorem one_dev_blocks (team : Finset Dev) (status : ι → Design) (affected : Finset ι)
    (b : Ballot ι Dev) {i : ι} (hi : i ∈ affected) (hc : ¬ CreatorDecides (status i))
    {m : Dev} (hm : m ∈ team) (hno : b.devYes m = false) :
    ¬ Approved team status affected b := by
  intro h
  have := inactive_needs_dev_consensus team status affected b hi hc h m hm
  rw [hno] at this
  exact Bool.false_ne_true this

/-- **When every affected creator is active (and no design is mutated), the creators, the council
and a human decide; the DEV team's agreement isn't needed.** -/
theorem approved_iff_all_active (team : Finset Dev) (status : ι → Design) (affected : Finset ι)
    (b : Ballot ι Dev) (hall : ∀ i ∈ affected, CreatorDecides (status i)) :
    Approved team status affected b ↔
      (∀ i ∈ affected, b.creatorYes i = true) ∧ b.council = true ∧ b.human = true := by
  unfold Approved
  constructor
  · rintro ⟨h, hc, hh⟩
    refine ⟨fun i hi => ?_, hc, hh⟩
    have := h i hi
    rwa [GatePasses, if_pos (hall i hi)] at this
  · rintro ⟨h, hc, hh⟩
    refine ⟨fun i hi => ?_, hc, hh⟩
    rw [GatePasses, if_pos (hall i hi)]
    exact h i hi

/-- A proposed change: which designs it touches, their new versions, the status of each design at
the time of the vote, and the votes. -/
structure Proposal (ι Dev V : Type) where
  affected : Finset ι
  newVersion : ι → V
  status : ι → Design
  ballot : Ballot ι Dev

/-- Apply a proposal: if approved, every affected design takes its new version. -/
noncomputable def applyProposal {V : Type} (team : Finset Dev) (w : ι → V)
    (p : Proposal ι Dev V) : ι → V :=
  if Approved team p.status p.affected p.ballot then
    fun i => if i ∈ p.affected then p.newVersion i else w i
  else w

/-- Apply a sequence of proposals in order. -/
noncomputable def runProposals {V : Type} (team : Finset Dev) (w : ι → V)
    (ps : List (Proposal ι Dev V)) : ι → V :=
  ps.foldl (applyProposal team) w

/-- **Everybody's work is protected.** Over any sequence of proposals, if every proposal that
touches design `i` found its creator active and deciding, and that creator said no, design `i` is
exactly as it was. -/
theorem work_protected {V : Type} (team : Finset Dev) (ps : List (Proposal ι Dev V)) (i : ι)
    (h : ∀ p ∈ ps, i ∈ p.affected →
      CreatorDecides (p.status i) ∧ p.ballot.creatorYes i = false) (w : ι → V) :
    runProposals team w ps i = w i := by
  induction ps generalizing w with
  | nil => rfl
  | cons p ps ih =>
    simp only [runProposals, List.foldl_cons] at ih ⊢
    rw [ih (fun q hq => h q (List.mem_cons_of_mem _ hq))]
    unfold applyProposal
    by_cases hA : Approved team p.status p.affected p.ballot
    · rw [if_pos hA]
      by_cases hi : i ∈ p.affected
      · obtain ⟨hc, hno⟩ := h p List.mem_cons_self hi
        exact absurd hA (creator_veto team p.status p.affected p.ballot hi hc hno)
      · simp [hi]
    · rw [if_neg hA]

/-! ## 2. Diamond lock -/

/-- An edit to the official archive: a key, a new value, and whether the owner signed it. -/
structure ArchiveEdit (K V : Type) where
  key : K
  value : V
  ownerSigned : Bool

/-- Apply an edit. A 💎 key changes only with the owner's signature. -/
def applyEdit {K V : Type} [DecidableEq K] (diamond : K → Prop) [DecidablePred diamond]
    (a : K → V) (e : ArchiveEdit K V) : K → V :=
  if diamond e.key ∧ e.ownerSigned = false then a
  else fun k => if k = e.key then e.value else a k

/-- **An unsigned edit never changes a 💎 entry.** -/
theorem unsigned_edit_diamond {K V : Type} [DecidableEq K] (diamond : K → Prop)
    [DecidablePred diamond] (a : K → V) (e : ArchiveEdit K V) {k : K} (hk : diamond k)
    (hs : e.ownerSigned = false) : applyEdit diamond a e k = a k := by
  unfold applyEdit
  by_cases h : diamond e.key ∧ e.ownerSigned = false
  · rw [if_pos h]
  · rw [if_neg h]
    by_cases h' : k = e.key
    · subst h'; exact absurd ⟨hk, hs⟩ h
    · simp [h']

/-- **Diamond lock.** Over any sequence of edits, a 💎 entry that no owner-signed edit targets keeps
its value. -/
theorem diamond_locked {K V : Type} [DecidableEq K] (diamond : K → Prop) [DecidablePred diamond]
    (es : List (ArchiveEdit K V)) {k : K} (hk : diamond k)
    (h : ∀ e ∈ es, e.key = k → e.ownerSigned = false) (a : K → V) :
    es.foldl (applyEdit diamond) a k = a k := by
  induction es generalizing a with
  | nil => rfl
  | cons e es ih =>
    rw [List.foldl_cons, ih (fun e' he' => h e' (List.mem_cons_of_mem _ he'))]
    by_cases hek : e.key = k
    · exact unsigned_edit_diamond diamond a e hk (h e List.mem_cons_self hek)
    · unfold applyEdit
      by_cases h1 : diamond e.key ∧ e.ownerSigned = false
      · rw [if_pos h1]
      · rw [if_neg h1]; simp [Ne.symm hek]

/-- A copy passes the official check when every 💎 entry matches the official record. -/
def OfficialCopy {K V : Type} (diamond : K → Prop) (official copy : K → V) : Prop :=
  ∀ k, diamond k → copy k = official k

/-- **A copy with any altered 💎 value fails the official check.** -/
theorem altered_copy_fails {K V : Type} (diamond : K → Prop) (official copy : K → V) {k : K}
    (hk : diamond k) (hne : copy k ≠ official k) : ¬ OfficialCopy diamond official copy :=
  fun h => hne (h k hk)

/-! ## 3. Skill orbs, version 3 -/

/-- The highest orb level; a level-100 orb is gold-locked. -/
def maxOrbLevel : ℕ := 100

/-- The number of nodes in a player's matrix. -/
def matrixNodes : ℕ := 64

/-- Orbs everyone starts with. -/
def starterOrbs : ℕ := 64

/-- A matrix node accepts an orb exactly when it is gold-locked (level 100). -/
def canSlot (orbLevel : ℕ) : Prop := orbLevel = maxOrbLevel

/-- **Only gold-locked orbs can be slotted.** -/
theorem slot_iff_gold (l : ℕ) (hl : l ≤ maxOrbLevel) : canSlot l ↔ maxOrbLevel ≤ l := by
  unfold canSlot; omega

/-- **The 64 starter orbs exactly fill the matrix.** -/
theorem starter_fills_matrix : starterOrbs = matrixNodes := rfl

/-- Everything in the world, as far as orbs are concerned: the level of every orb in existence
(whoever holds it) and the raw materials. -/
structure OrbWorld where
  orbs : List ℕ
  raw : ℕ

/-- What can happen to orbs. -/
inductive OrbOp
  /-- Train an orb at level `l` by one level (capped at 100). -/
  | train (l : ℕ)
  /-- Deconstruct an orb at level `l` into raw materials. -/
  | deconstruct (l : ℕ)
  /-- Craft a new empty orb from raw materials. -/
  | craftEmpty
  /-- Trade, sell, transmute or gift an orb: it changes hands, not level. -/
  | trade

/-- One step, with `yield` raw materials from a deconstructed orb and `cost` per crafted orb. -/
def orbStep (yield cost : ℕ) (w : OrbWorld) : OrbOp → OrbWorld
  | .train l => if l ∈ w.orbs then ⟨min (l + 1) maxOrbLevel :: w.orbs.erase l, w.raw⟩ else w
  | .deconstruct l => if l ∈ w.orbs then ⟨w.orbs.erase l, w.raw + yield⟩ else w
  | .craftEmpty => if cost ≤ w.raw then ⟨0 :: w.orbs, w.raw - cost⟩ else w
  | .trade => w

/-- Run a sequence of steps. -/
def orbRun (yield cost : ℕ) (w : OrbWorld) (ops : List OrbOp) : OrbWorld :=
  ops.foldl (orbStep yield cost) w

/-- Number of training steps in a sequence. -/
def trainCount : List OrbOp → ℕ
  | [] => 0
  | .train _ :: ops => trainCount ops + 1
  | _ :: ops => trainCount ops

theorem orbStep_sum_le (yield cost : ℕ) (w : OrbWorld) (op : OrbOp) :
    (orbStep yield cost w op).orbs.sum ≤ w.orbs.sum + trainCount [op] := by
  cases op with
  | train l =>
    simp only [orbStep, trainCount]
    split_ifs with h
    · have := List.sum_erase h
      simp only [List.sum_cons]
      have : min (l + 1) maxOrbLevel ≤ l + 1 := min_le_left _ _
      omega
    · omega
  | deconstruct l =>
    simp only [orbStep, trainCount]
    split_ifs with h
    · have := List.sum_erase h
      dsimp only; omega
    · omega
  | craftEmpty =>
    simp only [orbStep, trainCount]
    split_ifs <;> simp
  | trade => simp [orbStep, trainCount]

/-- **Every skill level in the world was trained by someone.** Crafting, deconstructing and trading
never add levels: the total of all orb levels grows by at most one per training step. -/
theorem levels_only_from_training (yield cost : ℕ) (ops : List OrbOp) (w : OrbWorld) :
    (orbRun yield cost w ops).orbs.sum ≤ w.orbs.sum + trainCount ops := by
  induction ops generalizing w with
  | nil => simp [orbRun, trainCount]
  | cons op ops ih =>
    simp only [orbRun, List.foldl_cons] at ih ⊢
    have h1 := ih (orbStep yield cost w op)
    have h2 := orbStep_sum_le yield cost w op
    have : trainCount (op :: ops) = trainCount [op] + trainCount ops := by
      cases op <;> simp [trainCount, add_comm]
    omega

theorem count_mul_le_sum (a : ℕ) (l : List ℕ) : l.count a * a ≤ l.sum := by
  induction l with
  | nil => simp
  | cons x l ih =>
    rw [List.count_cons, List.sum_cons]
    split_ifs with h
    · simp only [beq_iff_eq] at h; subst h; rw [add_mul, one_mul]; omega
    · simp only [add_zero]; omega

/-- **Gold orbs take training.** In a world whose orbs all start empty, after any sequence of
steps, (number of gold-locked orbs) × 100 ≤ (number of training steps). -/
theorem gold_needs_training (yield cost : ℕ) (ops : List OrbOp) (w : OrbWorld)
    (h0 : w.orbs.sum = 0) :
    (orbRun yield cost w ops).orbs.count maxOrbLevel * maxOrbLevel ≤ trainCount ops := by
  have := levels_only_from_training yield cost ops w
  have := count_mul_le_sum maxOrbLevel (orbRun yield cost w ops).orbs
  omega

/-- **A full 64-node gold matrix costs at least 6,400 training steps** across the world, starting
from empty orbs; crafting, deconstructing and trading can't shortcut it. -/
theorem sixtyfour_gold_cost (yield cost : ℕ) (ops : List OrbOp) (w : OrbWorld)
    (h0 : w.orbs.sum = 0)
    (h64 : matrixNodes ≤ (orbRun yield cost w ops).orbs.count maxOrbLevel) :
    6400 ≤ trainCount ops := by
  have := gold_needs_training yield cost ops w h0
  have : matrixNodes * maxOrbLevel ≤
      (orbRun yield cost w ops).orbs.count maxOrbLevel * maxOrbLevel :=
    Nat.mul_le_mul_right _ h64
  simp only [matrixNodes, maxOrbLevel] at *
  omega

/-! ## 4. Ordinary dragons choose their elemental path, one element at a time -/

/-- An ordinary dragon's elemental progress: the elements mastered so far, in order, and the one
element (if any) currently in progress with its progress count. -/
structure ElemProgress (E : Type) where
  mastered : List E
  current : Option E
  progress : ℕ

/-- What a player can do: pick the next element (only when nothing is in progress and it isn't
mastered), or train the element in progress. -/
inductive ElemAct (E : Type)
  | choose (e : E)
  | train

/-- One step; an element is mastered after `need` training steps. -/
def elemStep {E : Type} [DecidableEq E] (need : ℕ) (s : ElemProgress E) :
    ElemAct E → ElemProgress E
  | .choose e => if s.current = none ∧ e ∉ s.mastered then ⟨s.mastered, some e, 0⟩ else s
  | .train => match s.current with
    | none => s
    | some e => if need ≤ s.progress + 1 then ⟨s.mastered ++ [e], none, 0⟩
                else ⟨s.mastered, some e, s.progress + 1⟩

/-- Run a sequence of actions. -/
def elemRun {E : Type} [DecidableEq E] (need : ℕ) (s : ElemProgress E) (acts : List (ElemAct E)) :
    ElemProgress E :=
  acts.foldl (elemStep need) s

/-- The invariant: mastered elements are distinct and the one in progress isn't among them. -/
def ElemOK {E : Type} (s : ElemProgress E) : Prop :=
  s.mastered.Nodup ∧ ∀ e, s.current = some e → e ∉ s.mastered

theorem elemStep_ok {E : Type} [DecidableEq E] (need : ℕ) (s : ElemProgress E) (a : ElemAct E)
    (h : ElemOK s) : ElemOK (elemStep need s a) := by
  obtain ⟨hn, hc⟩ := h
  cases a with
  | choose e =>
    simp only [elemStep]
    split_ifs with h1
    · refine ⟨hn, fun e' he' => ?_⟩
      simp only [Option.some.injEq] at he'
      subst he'; exact h1.2
    · exact ⟨hn, hc⟩
  | train =>
    simp only [elemStep]
    cases hcur : s.current with
    | none => exact ⟨hn, hc⟩
    | some e =>
      simp only
      split_ifs
      · refine ⟨?_, fun e' he' => by simp at he'⟩
        rw [List.nodup_append]
        refine ⟨hn, List.nodup_singleton e, ?_⟩
        intro a ha b hb hab
        simp only [List.mem_singleton] at hb
        subst hb hab
        exact hc a hcur ha
      · refine ⟨hn, fun e' he' => ?_⟩
        simp only [Option.some.injEq] at he'
        subst he'; exact hc e hcur

theorem elemRun_ok {E : Type} [DecidableEq E] (need : ℕ) (acts : List (ElemAct E)) :
    ∀ s : ElemProgress E, ElemOK s → ElemOK (elemRun need s acts) := by
  induction acts with
  | nil => intro s h; exact h
  | cons a acts ih => intro s h; exact ih _ (elemStep_ok need s a h)

/-- **No element is ever mastered twice.** -/
theorem mastered_nodup {E : Type} [DecidableEq E] (need : ℕ) (acts : List (ElemAct E)) :
    (elemRun need ⟨[], none, 0⟩ acts).mastered.Nodup :=
  (elemRun_ok need acts _ ⟨List.nodup_nil, fun _ _ h => by simp at h⟩).1

theorem elemStep_prefix {E : Type} [DecidableEq E] (need : ℕ) (s : ElemProgress E)
    (a : ElemAct E) : s.mastered <+: (elemStep need s a).mastered := by
  cases a with
  | choose e => simp only [elemStep]; split_ifs <;> exact List.prefix_refl _
  | train =>
    simp only [elemStep]
    cases s.current with
    | none => exact List.prefix_refl _
    | some e =>
      simp only
      split_ifs
      · exact List.prefix_append _ _
      · exact List.prefix_refl _

/-- **Mastered elements are never lost**: the mastered list only grows at the end. -/
theorem mastered_prefix {E : Type} [DecidableEq E] (need : ℕ) (acts : List (ElemAct E)) :
    ∀ s : ElemProgress E, s.mastered <+: (elemRun need s acts).mastered := by
  induction acts with
  | nil => intro s; exact List.prefix_refl _
  | cons a acts ih =>
    intro s
    exact (elemStep_prefix need s a).trans (ih _)

/-- Training an element that is `k + 1` steps from mastery, `k + 1` times, masters it. -/
theorem train_masters {E : Type} [DecidableEq E] (need : ℕ) (m : List E)
    (e : E) : ∀ k, k < need →
      elemRun need ⟨m, some e, need - 1 - k⟩ (List.replicate (k + 1) .train) =
        ⟨m ++ [e], none, 0⟩ := by
  intro k
  induction k with
  | zero =>
    intro _
    simp only [elemRun, List.replicate, List.foldl_cons, List.foldl_nil, elemStep]
    rw [if_pos (by omega)]
  | succ k ih =>
    intro hk
    rw [List.replicate_succ, elemRun, List.foldl_cons]
    have : elemStep need ⟨m, some e, need - 1 - (k + 1)⟩ ElemAct.train =
        ⟨m, some e, need - 1 - k⟩ := by
      simp only [elemStep]
      rw [if_neg (by omega)]
      congr 1; omega
    rw [this]
    exact ih (by omega)

/-- **Any order the player chooses can be followed.** For any list of distinct elements, there is a
sequence of choices and training that masters exactly those elements in exactly that order. -/
theorem any_path_achievable {E : Type} [DecidableEq E] (need : ℕ) (hneed : 0 < need)
    (path : List E) (hp : path.Nodup) :
    ∃ acts, (elemRun need ⟨[], none, 0⟩ acts).mastered = path := by
  suffices h : ∀ (pre path : List E), (pre ++ path).Nodup →
      ∃ acts, elemRun need ⟨pre, none, 0⟩ acts = ⟨pre ++ path, none, 0⟩ by
    obtain ⟨acts, h⟩ := h [] path (by simpa using hp)
    exact ⟨acts, by rw [h]; rfl⟩
  intro pre path
  induction path generalizing pre with
  | nil => intro _; exact ⟨[], by simp [elemRun]⟩
  | cons e rest ih =>
    intro hnd
    have he : e ∉ pre := by
      intro hm
      rw [List.nodup_append] at hnd
      exact hnd.2.2 e hm e List.mem_cons_self rfl
    obtain ⟨acts, hacts⟩ := ih (pre ++ [e]) (by simpa using hnd)
    refine ⟨.choose e :: List.replicate need .train ++ acts, ?_⟩
    rw [List.cons_append, elemRun, List.foldl_cons, List.foldl_append]
    have h1 : elemStep need ⟨pre, none, 0⟩ (.choose e) = ⟨pre, some e, 0⟩ := by
      simp [elemStep, he]
    rw [h1]
    have h2 := train_masters need pre e (need - 1) (by omega)
    rw [show need - 1 + 1 = need by omega, show need - 1 - (need - 1) = 0 by omega] at h2
    unfold elemRun at h2 hacts
    rw [h2, hacts]
    simp

/-! ## 5. Skybox access, version 2 -/

/-- Who is asking to enter. -/
structure Visitor (P A B : Type) where
  id : P
  level : ℕ
  archetype : A
  build : B

/-- The access settings an owner (or a DEV) can choose, including combinations. -/
inductive Access (P A B : Type)
  | publicAccess
  | privateAccess
  | inviteOnly (invited : List P)
  | byRequest (approved : List P)
  | minLevel (n : ℕ)
  | archetypes (allowed : List A)
  | builds (allowed : List B)
  | allOf (x y : Access P A B)
  | anyOf (x y : Access P A B)

/-- Whether a non-owner visitor meets an access setting. -/
def Access.admits {P A B : Type} : Access P A B → Visitor P A B → Prop
  | .publicAccess, _ => True
  | .privateAccess, _ => False
  | .inviteOnly l, v => v.id ∈ l
  | .byRequest l, v => v.id ∈ l
  | .minLevel n, v => n ≤ v.level
  | .archetypes l, v => v.archetype ∈ l
  | .builds l, v => v.build ∈ l
  | .allOf x y, v => x.admits v ∧ y.admits v
  | .anyOf x y, v => x.admits v ∨ y.admits v

/-- A skybox: its owner and its current access setting. -/
structure Skybox (P A B : Type) where
  owner : P
  access : Access P A B

/-- Entry: the owner always, anyone else by the access setting. -/
def Skybox.canEnter {P A B : Type} (s : Skybox P A B) (v : Visitor P A B) : Prop :=
  v.id = s.owner ∨ s.access.admits v

/-- Change the setting: only the owner or a DEV can. -/
def setPolicy {P A B : Type} [DecidableEq P] (isDev : P → Prop) [DecidablePred isDev]
    (s : Skybox P A B) (who : P) (new : Access P A B) : Skybox P A B :=
  if who = s.owner ∨ isDev who then ⟨s.owner, new⟩ else s

/-- **Only the owner or a DEV can change a skybox's access.** -/
theorem setPolicy_unauthorized {P A B : Type} [DecidableEq P] (isDev : P → Prop)
    [DecidablePred isDev] (s : Skybox P A B) (who : P) (new : Access P A B)
    (h1 : who ≠ s.owner) (h2 : ¬ isDev who) : setPolicy isDev s who new = s := by
  unfold setPolicy; rw [if_neg (by tauto)]

/-- **The owner (or a DEV) gets exactly the setting they chose.** -/
theorem setPolicy_authorized {P A B : Type} [DecidableEq P] (isDev : P → Prop)
    [DecidablePred isDev] (s : Skybox P A B) (who : P) (new : Access P A B)
    (h : who = s.owner ∨ isDev who) : (setPolicy isDev s who new).access = new := by
  unfold setPolicy; rw [if_pos h]

/-- **The owner can always enter their own skybox.** -/
theorem owner_can_enter {P A B : Type} (s : Skybox P A B) (v : Visitor P A B)
    (h : v.id = s.owner) : s.canEnter v := Or.inl h

/-- **A private skybox admits only its owner.** -/
theorem private_only_owner {P A B : Type} (owner : P) (v : Visitor P A B) :
    (Skybox.mk owner (Access.privateAccess : Access P A B)).canEnter v ↔ v.id = owner := by
  simp [Skybox.canEnter, Access.admits]

/-! ## 6. RD pool at 3%: three options -/

/-- **Option A, shared pots.** All original creators split one 3% pot and all DEV collaborators
split one 30% pot (ten times the creator pot). With `c` creators and `k` collaborators, the
creator pot is paid only if `c > 0` and the collaborator pot only if `k > 0`. -/
def optionATotal (c k : ℕ) : ℚ := (if 0 < c then 3 else 0) + (if 0 < k then 30 else 0)

/-- **Option A never uses more than 33% of a pool.** -/
theorem optionA_total_le (c k : ℕ) : optionATotal c k ≤ 33 := by
  unfold optionATotal; split_ifs <;> norm_num

/-- **Option B, per person with a cap.** Each creator gets 3% and each collaborator 30%. -/
def optionBTotal (c k : ℕ) : ℕ := 3 * c + 30 * k

/-- **Option B fits exactly when `3·creators + 30·collaborators ≤ 100`.** -/
theorem optionB_fits_iff (c k : ℕ) : optionBTotal c k ≤ 100 ↔ 3 * c + 30 * k ≤ 100 := Iff.rfl

/-- **With one creator, option B allows at most three collaborators** (3 + 90 = 93%; four would be
123%). -/
theorem optionB_cap (k : ℕ) : optionBTotal 1 k ≤ 100 ↔ k ≤ 3 := by
  unfold optionBTotal; omega

/-- **Option C, per person, scaled down when over 100%.** -/
noncomputable def optionC (c k : ℕ) : List ℚ :=
  RoundEightOpening.rdScaled (List.replicate c 3 ++ List.replicate k 30) 100

/-- **Option C always fits in the pool.** -/
theorem optionC_total_le (c k : ℕ) : (optionC c k).sum ≤ 100 :=
  RoundEightOpening.rdScaled_total_le _ (by norm_num)

/-- **Option C keeps every collaborator at exactly ten times a creator**, whether or not it had to
scale down. -/
theorem optionC_ratio (c k : ℕ) :
    ∃ f : ℚ, 0 < f ∧ optionC c k = List.replicate c (3 * f) ++ List.replicate k (30 * f) := by
  unfold optionC RoundEightOpening.rdScaled
  split_ifs with h
  · exact ⟨1, one_pos, by simp⟩
  · push_neg at h
    refine ⟨100 / (List.replicate c (3 : ℚ) ++ List.replicate k 30).sum,
      div_pos (by norm_num) (by linarith), ?_⟩
    simp only [List.map_append, List.map_replicate]

/-- Worked example for option C: one creator and six collaborators claim 183%. Scaled down, the
creator gets 100/61 % (about 1.64%) and each collaborator 1000/61 % (about 16.39%). -/
theorem optionC_example :
    optionC 1 6 = 100 / 61 :: List.replicate 6 (1000 / 61) := by
  norm_num [optionC, RoundEightOpening.rdScaled, List.replicate]

/-! ## 7. Phoenix vs stacked ordinary dragons: worked numbers -/

/-- An ordinary dragon running `k` elements loses `d` per extra element. -/
def stackMult (d : ℚ) (k : ℕ) : ℚ := 1 - d * ((k : ℚ) - 1)

/-- Table for a 5% stacking cost: 100%, 95%, 90%, 85%, 80%. -/
theorem stack_table_5 :
    (List.range 5).map (fun j => stackMult (1/20) (j + 1)) = [1, 19/20, 9/10, 17/20, 4/5] := by
  norm_num [stackMult, List.range_succ]

/-- Table for a 10% stacking cost: 100%, 90%, 80%, 70%, 60%. -/
theorem stack_table_10 :
    (List.range 5).map (fun j => stackMult (1/10) (j + 1)) = [1, 9/10, 4/5, 7/10, 3/5] := by
  norm_num [stackMult, List.range_succ]

/-- **For any stacking cost `d ≥ 0`, a phoenix running `k ≤ 5` elements is at least as strong in
each as an ordinary dragon running the same number**, and strictly stronger whenever `k < 5` or
`d > 0`. -/
theorem phoenix_ge_stacked (d : ℚ) (hd : 0 ≤ d) {k : ℕ} (hk1 : 1 ≤ k) (hk5 : k ≤ 5) :
    stackMult d k ≤ RoundEightOpening.phoenixMult k ∧
      (k < 5 ∨ 0 < d → stackMult d k < RoundEightOpening.phoenixMult k) := by
  unfold stackMult RoundEightOpening.phoenixMult
  have hk1' : (1 : ℚ) ≤ k := by exact_mod_cast hk1
  have hk5' : (k : ℚ) ≤ 5 := by exact_mod_cast hk5
  refine ⟨by nlinarith, ?_⟩
  rintro (h | h)
  · have : (k : ℚ) < 5 := by exact_mod_cast h
    nlinarith
  · rcases eq_or_lt_of_le hk1' with h1 | h1
    · rw [← h1]; norm_num
    · nlinarith

end RoundNineOpening

end
