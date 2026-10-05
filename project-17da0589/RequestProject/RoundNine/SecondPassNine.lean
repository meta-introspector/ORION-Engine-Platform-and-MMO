module

public import Mathlib
public import RequestProject.RoundNine.OpeningNine

/-!
# Round Nine, second pass: the notes written under the R9 reply on *ORION R9 Live*

* **Who controls what (💎, replaces the R9 "mutated schematic → DEV team" reading).** Three kinds
  of change to a player's design:
  - a *direct edit* to the original design: an active creator has the final say, otherwise the
    whole DEV team ("the doves") must agree; then the Galactic council and a human;
  - a *DEV adoption* of the design into the game's permanent structure (galactic property, the
    starting worlds, anything added later): an active creator must say yes, otherwise the whole
    DEV team; then the council and a human. Saying no leaves the design on the open market;
  - a *mutated schematic* made from it: the creator has no control, and the original is untouched.
  Proved: an active creator's no blocks a direct edit or an adoption (`creator_no_blocks_official`);
  a mutation needs nobody's permission (`mutation_free`) and never changes the original
  (`mutation_keeps_original`); official changes still need the council and a human
  (`official_needs_council_and_human`); over any sequence of requests, a design whose active creator
  never said yes is never edited or adopted (`work_protected_v2`).
* **Skill orbs, version 4.** Any orb can sit in a node slot; only a gold-locked (level 100) orb can
  go into the 64-grid matrix; an orb gains levels only while active in a node slot. An extreme
  marksman's one-shot can earn a free gold-locked orb. Proved: training an orb that isn't in a node
  does nothing (`train_needs_node`); the matrix only ever holds gold orbs (`matrix_always_gold`);
  levels come only from training and marksman rewards (`levels_from_training_or_marksman`); a full
  64-orb matrix needs at least `6400 − 100 × (marksman rewards)` training steps
  (`full_matrix_cost`), so exactly 6,400 when there are no rewards (`full_matrix_cost_no_rewards`).
* **KRION bonus, per slot.** The 25% bonus applies to the orb in that slot only
  (`krion_other_slot_unchanged`), and the total gain is a quarter of the KRION-slotted orbs'
  values (`krion_total`).
* **Ordinary dragons: one primary element, chosen by the player.** Stacked elements run at
  1.75/3 of the primary (`ratio_table`). Whatever the stacking rule, as long as no element of an
  ordinary dragon goes above its one-element strength, a phoenix running the same number of
  elements is at least as strong in every one (`phoenix_ge_any_capped`); the 3 : 1.75 rule is one
  such rule (`ratio_capped`, `phoenix_beats_ratio`).
* **Skybox access, version 3.** Private no longer means owner-only: the owner can give guests
  access tiers. Proved: the owner can do everything (`owner_full_access_v3`); a guest at tier `t`
  can do everything that needs tier `t` or less (`guest_tier_mono`); someone not on the guest list
  can't enter a private skybox (`stranger_kept_out`); a private skybox with no guests is
  owner-only (`private_no_guests`); only the owner or a DEV can change the guest list
  (`setAccess_unauthorized`).
-/

@[expose] public section

namespace RoundNineSecond

open Classical

/-! ## 1. Who controls what: direct edits, DEV adoption, mutated schematics -/

/-- The three kinds of request that can touch a player's design. -/
inductive ChangeKind
  /-- Change the original design itself (including code it contributed to the build). -/
  | directEdit
  /-- The DEV team uses the design as part of the game's permanent structure. -/
  | adoption
  /-- Someone makes a mutated schematic from it (a new design; the original stays as it is). -/
  | mutation
  deriving DecidableEq

/-- Official changes are the ones that touch the original design or the permanent game. -/
def ChangeKind.official : ChangeKind → Prop
  | .mutation => False
  | _ => True

/-- The votes on a request. -/
structure Votes (Dev : Type) where
  creatorYes : Bool
  devYes : Dev → Bool
  councilYes : Bool
  humanYes : Bool

/-- The decision. A mutation needs nobody's permission. An official request needs the first gate
(an active creator's yes, otherwise every DEV on the team), then the council and a human. -/
def Decide {Dev : Type} (team : Finset Dev) (creatorActive : Bool) (kind : ChangeKind)
    (v : Votes Dev) : Prop :=
  match kind with
  | .mutation => True
  | _ => (if creatorActive then v.creatorYes = true else ∀ d ∈ team, v.devYes d = true) ∧
      v.councilYes = true ∧ v.humanYes = true

/-- **An active creator's "no" blocks a direct edit or an adoption.** -/
theorem creator_no_blocks_official {Dev : Type} (team : Finset Dev) (kind : ChangeKind)
    (hk : kind.official) (v : Votes Dev) (hno : v.creatorYes = false) :
    ¬ Decide team true kind v := by
  cases kind <;> simp_all [Decide, ChangeKind.official]

/-- **Official changes need the Galactic council and a human.** -/
theorem official_needs_council_and_human {Dev : Type} (team : Finset Dev) (active : Bool)
    (kind : ChangeKind) (hk : kind.official) (v : Votes Dev) (h : Decide team active kind v) :
    v.councilYes = true ∧ v.humanYes = true := by
  cases kind <;> simp_all [Decide, ChangeKind.official]

/-- **If the creator is inactive, an official change needs every DEV on the team.** -/
theorem inactive_needs_all_devs {Dev : Type} (team : Finset Dev) (kind : ChangeKind)
    (hk : kind.official) (v : Votes Dev) (h : Decide team false kind v) :
    ∀ d ∈ team, v.devYes d = true := by
  cases kind <;> simp_all [Decide, ChangeKind.official]

/-- **A mutated schematic needs nobody's permission**: the creator has no control over it. -/
theorem mutation_free {Dev : Type} (team : Finset Dev) (active : Bool) (v : Votes Dev) :
    Decide team active .mutation v := trivial

/-- A design's state: its content and whether it is part of the permanent game. -/
structure DesignState (V : Type) where
  content : V
  inGame : Bool

/-- A request: its kind, the creator's status, the votes and (for edits) the new content. -/
structure Request (Dev V : Type) where
  kind : ChangeKind
  creatorActive : Bool
  votes : Votes Dev
  newContent : V

/-- Apply a request to the original design. A mutation produces a separate design and leaves the
original exactly as it is. -/
noncomputable def applyRequest {Dev V : Type} (team : Finset Dev) (s : DesignState V)
    (r : Request Dev V) : DesignState V :=
  if Decide team r.creatorActive r.kind r.votes then
    match r.kind with
    | .directEdit => ⟨r.newContent, s.inGame⟩
    | .adoption => ⟨s.content, true⟩
    | .mutation => s
  else s

/-- **A mutation never changes the original design.** -/
theorem mutation_keeps_original {Dev V : Type} (team : Finset Dev) (s : DesignState V)
    (r : Request Dev V) (hk : r.kind = .mutation) : applyRequest team s r = s := by
  unfold applyRequest; rw [hk]; split_ifs <;> rfl

/-- **Everybody's work is protected, version 2.** Over any sequence of requests in which the creator
stays active and never says yes to an official request, the design is never edited and never taken
into the permanent game; mutations made from it don't touch it. -/
theorem work_protected_v2 {Dev V : Type} (team : Finset Dev) (rs : List (Request Dev V))
    (s : DesignState V)
    (hno : ∀ r ∈ rs, r.kind.official → r.creatorActive = true ∧ r.votes.creatorYes = false) :
    rs.foldl (applyRequest team) s = s := by
  induction rs generalizing s with
  | nil => rfl
  | cons r rs ih =>
    simp only [List.foldl_cons]
    have hr : applyRequest team s r = s := by
      unfold applyRequest
      split_ifs with h
      · cases hk : r.kind
        · obtain ⟨ha, hn⟩ := hno r (by simp) (by simp [hk, ChangeKind.official])
          exact absurd h (by rw [ha, hk]; exact creator_no_blocks_official team .directEdit trivial _ hn)
        · obtain ⟨ha, hn⟩ := hno r (by simp) (by simp [hk, ChangeKind.official])
          exact absurd h (by rw [ha, hk]; exact creator_no_blocks_official team .adoption trivial _ hn)
        · rfl
      · rfl
    rw [hr]
    exact ih s (fun r' hr' => hno r' (by simp [hr']))

/-! ## 2. Skill orbs, version 4: node slots, the 64-grid matrix, marksman rewards -/

/-- Where an orb sits. -/
inductive Place
  | loose
  | node
  | matrix
  deriving DecidableEq

/-- An orb: its level (0–100) and where it sits. -/
structure Orb where
  level : ℕ
  place : Place
  deriving DecidableEq

/-- The gold-lock level. -/
def gold : ℕ := 100

/-- What can happen to orbs. -/
inductive OrbAct
  /-- Train this orb one level (works only while it is active in a node slot). -/
  | train (o : Orb)
  /-- Put this orb into a node slot (any orb can go in). -/
  | toNode (o : Orb)
  /-- Put this orb into the 64-grid matrix (only if gold-locked). -/
  | toMatrix (o : Orb)
  /-- Take this orb out of its slot. -/
  | unslot (o : Orb)
  /-- Craft a new empty orb. -/
  | craft
  /-- Deconstruct this orb. -/
  | deconstruct (o : Orb)
  /-- Trade, sell or gift an orb: it changes hands, not level or place. -/
  | trade
  /-- An extreme marksman's one-shot earns a free gold-locked orb. -/
  | marksman

/-- One step. -/
def orbStep (w : List Orb) : OrbAct → List Orb
  | .train o => if o ∈ w ∧ o.place = .node then ⟨min (o.level + 1) gold, .node⟩ :: w.erase o else w
  | .toNode o => if o ∈ w then ⟨o.level, .node⟩ :: w.erase o else w
  | .toMatrix o => if o ∈ w ∧ o.level = gold then ⟨o.level, .matrix⟩ :: w.erase o else w
  | .unslot o => if o ∈ w then ⟨o.level, .loose⟩ :: w.erase o else w
  | .craft => ⟨0, .loose⟩ :: w
  | .deconstruct o => w.erase o
  | .trade => w
  | .marksman => ⟨gold, .loose⟩ :: w

/-- Run a sequence of steps. -/
def orbRun (w : List Orb) (acts : List OrbAct) : List Orb := acts.foldl orbStep w

/-- Number of `train` actions (an upper bound on the training that actually happens, since training
an orb outside a node slot does nothing). -/
def trains : List OrbAct → ℕ
  | [] => 0
  | .train _ :: as => trains as + 1
  | _ :: as => trains as

/-- Number of marksman rewards. -/
def rewards : List OrbAct → ℕ
  | [] => 0
  | .marksman :: as => rewards as + 1
  | _ :: as => rewards as

/-- Total of all orb levels in the world. -/
def levelSum (w : List Orb) : ℕ := (w.map Orb.level).sum

/-- The orbs in the matrix. -/
def inMatrix (w : List Orb) : List Orb := w.filter (fun o => o.place = .matrix)

/-- **Training an orb that isn't active in a node slot does nothing.** -/
theorem train_needs_node (w : List Orb) (o : Orb) (h : o.place ≠ .node) :
    orbStep w (.train o) = w := by
  simp [orbStep, h]

/-- **A non-gold orb can't go into the matrix.** -/
theorem toMatrix_needs_gold (w : List Orb) (o : Orb) (h : o.level ≠ gold) :
    orbStep w (.toMatrix o) = w := by
  simp [orbStep, h]

/-- The matrix invariant: every orb in the matrix is gold-locked. -/
def MatrixGold (w : List Orb) : Prop := ∀ o ∈ w, o.place = .matrix → o.level = gold

theorem matrixGold_erase {w : List Orb} (h : MatrixGold w) (o : Orb) : MatrixGold (w.erase o) :=
  fun x hx => h x (List.mem_of_mem_erase hx)

theorem orbStep_matrixGold (w : List Orb) (a : OrbAct) (h : MatrixGold w) :
    MatrixGold (orbStep w a) := by
  have he := fun o => matrixGold_erase h o
  cases a with
  | train o =>
    simp only [orbStep]; split_ifs
    · intro x hx; simp only [List.mem_cons] at hx
      rcases hx with rfl | hx
      · simp
      · exact he o x hx
    · exact h
  | toNode o =>
    simp only [orbStep]; split_ifs
    · intro x hx; simp only [List.mem_cons] at hx
      rcases hx with rfl | hx
      · simp
      · exact he o x hx
    · exact h
  | toMatrix o =>
    simp only [orbStep]; split_ifs with hc
    · intro x hx; simp only [List.mem_cons] at hx
      rcases hx with rfl | hx
      · intro; exact hc.2
      · exact he o x hx
    · exact h
  | unslot o =>
    simp only [orbStep]; split_ifs
    · intro x hx; simp only [List.mem_cons] at hx
      rcases hx with rfl | hx
      · simp
      · exact he o x hx
    · exact h
  | craft =>
    intro x hx; simp only [orbStep, List.mem_cons] at hx
    rcases hx with rfl | hx
    · simp
    · exact h x hx
  | deconstruct o => exact he o
  | trade => exact h
  | marksman =>
    intro x hx; simp only [orbStep, List.mem_cons] at hx
    rcases hx with rfl | hx
    · intro; rfl
    · exact h x hx

/-- **The matrix only ever holds gold-locked orbs**, whatever happens. -/
theorem matrix_always_gold (w : List Orb) (acts : List OrbAct) (h : MatrixGold w) :
    MatrixGold (orbRun w acts) := by
  induction acts generalizing w with
  | nil => exact h
  | cons a as ih => exact ih _ (orbStep_matrixGold w a h)

theorem levelSum_erase {w : List Orb} {o : Orb} (h : o ∈ w) :
    levelSum (w.erase o) + o.level = levelSum w := by
  unfold levelSum
  induction w with
  | nil => simp at h
  | cons x w ih =>
    by_cases hx : x = o
    · subst hx; simp [add_comm]
    · rw [List.erase_cons_tail (by simpa using hx)]
      have : o ∈ w := by
        rcases List.mem_cons.mp h with h | h
        · exact absurd h.symm hx
        · exact h
      simp only [List.map_cons, List.sum_cons]
      have := ih this
      omega

theorem orbStep_levelSum (w : List Orb) (a : OrbAct) :
    levelSum (orbStep w a) ≤ levelSum w + trains [a] + gold * rewards [a] := by
  cases a with
  | train o =>
    simp only [orbStep, trains, rewards]; split_ifs with hc
    · have := levelSum_erase hc.1
      have : min (o.level + 1) gold ≤ o.level + 1 := min_le_left _ _
      simp only [levelSum, List.map_cons, List.sum_cons] at *
      omega
    · omega
  | toNode o =>
    simp only [orbStep, trains, rewards]; split_ifs with hc
    · have := levelSum_erase hc
      simp only [levelSum, List.map_cons, List.sum_cons] at *
      omega
    · omega
  | toMatrix o =>
    simp only [orbStep, trains, rewards]; split_ifs with hc
    · have := levelSum_erase hc.1
      simp only [levelSum, List.map_cons, List.sum_cons] at *
      omega
    · omega
  | unslot o =>
    simp only [orbStep, trains, rewards]; split_ifs with hc
    · have := levelSum_erase hc
      simp only [levelSum, List.map_cons, List.sum_cons] at *
      omega
    · omega
  | craft => simp [orbStep, trains, rewards, levelSum]
  | deconstruct o =>
    simp only [orbStep, trains, rewards]
    by_cases hc : o ∈ w
    · have := levelSum_erase hc; omega
    · rw [List.erase_of_not_mem hc]; omega
  | trade => simp [orbStep, trains, rewards]
  | marksman => simp [orbStep, trains, rewards, levelSum, add_comm]

/-- **Levels come only from training and marksman rewards.** Crafting, deconstructing, slotting
and trading never add levels: the world's total grows by at most one per training step and 100 per
marksman reward. -/
theorem levels_from_training_or_marksman (w : List Orb) (acts : List OrbAct) :
    levelSum (orbRun w acts) ≤ levelSum w + trains acts + gold * rewards acts := by
  induction acts generalizing w with
  | nil => simp [orbRun, trains, rewards]
  | cons a as ih =>
    simp only [orbRun, List.foldl_cons] at ih ⊢
    have h1 := ih (orbStep w a)
    have h2 := orbStep_levelSum w a
    have ht : trains (a :: as) = trains [a] + trains as := by
      cases a <;> simp [trains, add_comm]
    have hr : rewards (a :: as) = rewards [a] + rewards as := by
      cases a <;> simp [rewards, add_comm]
    rw [ht, hr, mul_add]
    omega

theorem matrix_count_le (w : List Orb) (h : MatrixGold w) :
    (inMatrix w).length * gold ≤ levelSum w := by
  induction w with
  | nil => simp [inMatrix]
  | cons x w ih =>
    have hw : MatrixGold w := fun o ho => h o (List.mem_cons_of_mem _ ho)
    have := ih hw
    simp only [inMatrix, List.filter_cons, levelSum, List.map_cons, List.sum_cons] at this ⊢
    split_ifs with hx
    · have hg := h x (by simp) (by simpa using hx)
      simp only [List.length_cons, add_mul, one_mul, hg]
      omega
    · omega

/-- **A full 64-orb matrix needs at least 6,400 − 100 × (marksman rewards) training steps**,
starting from a world of empty orbs with an empty matrix. -/
theorem full_matrix_cost (w : List Orb) (acts : List OrbAct) (h0 : levelSum w = 0)
    (hm : MatrixGold w) (h64 : 64 ≤ (inMatrix (orbRun w acts)).length) :
    6400 ≤ trains acts + 100 * rewards acts := by
  have h1 := levels_from_training_or_marksman w acts
  have h2 := matrix_count_le _ (matrix_always_gold w acts hm)
  have h3 : 64 * gold ≤ (inMatrix (orbRun w acts)).length * gold := Nat.mul_le_mul_right _ h64
  simp only [gold] at *
  omega

/-- **With no marksman rewards, a full matrix costs at least 6,400 training steps.** -/
theorem full_matrix_cost_no_rewards (w : List Orb) (acts : List OrbAct) (h0 : levelSum w = 0)
    (hm : MatrixGold w) (hr : rewards acts = 0)
    (h64 : 64 ≤ (inMatrix (orbRun w acts)).length) : 6400 ≤ trains acts := by
  have := full_matrix_cost w acts h0 hm h64
  omega

/-- **If marksman rewards are capped at two (levels one and two), a full matrix still costs at least
6,200 training steps.** -/
theorem full_matrix_cost_two_rewards (w : List Orb) (acts : List OrbAct) (h0 : levelSum w = 0)
    (hm : MatrixGold w) (hr : rewards acts ≤ 2)
    (h64 : 64 ≤ (inMatrix (orbRun w acts)).length) : 6200 ≤ trains acts := by
  have := full_matrix_cost w acts h0 hm h64
  omega

/-! ## 3. KRION bonus: per slot, on that slot's orb only -/

/-- The value of slot `i`: its orb's value, plus 25% if the slot is a KRION slot. -/
def krionValue {ι : Type} (base : ι → ℚ) (krion : ι → Bool) (i : ι) : ℚ :=
  if krion i then base i * 5 / 4 else base i

/-- **The bonus on one slot doesn't touch any other slot.** Turning slot `j` into a KRION slot
leaves every other slot's value as it was. -/
theorem krion_other_slot_unchanged {ι : Type} [DecidableEq ι] (base : ι → ℚ) (krion : ι → Bool)
    (j i : ι) (hij : i ≠ j) :
    krionValue base (Function.update krion j true) i = krionValue base krion i := by
  simp [krionValue, Function.update_of_ne hij]

/-- **The total gain is a quarter of the values of the orbs in KRION slots.** -/
theorem krion_total {ι : Type} (s : Finset ι) (base : ι → ℚ) (krion : ι → Bool) :
    ∑ i ∈ s, krionValue base krion i =
      ∑ i ∈ s, base i + (∑ i ∈ s.filter (fun i => krion i = true), base i) / 4 := by
  rw [Finset.sum_filter, Finset.sum_div, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun i _ => ?_
  unfold krionValue; split_ifs <;> ring

/-! ## 4. Ordinary dragons: one primary element, stacked elements at 3 : 1.75 -/

/-- Strength of each element (one-element ordinary dragon = 1): the primary runs at 1, each
stacked element at 1.75/3 of it. -/
def ratioStrength (isPrimary : Bool) : ℚ := if isPrimary then 1 else 7 / 4 / 3

/-- **Worked numbers (ordinary one-element dragon = 100):** primary 100, each stacked element
about 58.33 (exactly 175/3). -/
theorem ratio_table : (100 * ratioStrength true, 100 * ratioStrength false) = (100, 175 / 3) := by
  norm_num [ratioStrength]

/-- **The phoenix stays at least as strong under any capped stacking rule.** If no element of an
ordinary dragon running `k ≤ 5` elements is ever stronger than a one-element ordinary dragon, a
phoenix running `k` elements is at least as strong in every one. -/
theorem phoenix_ge_any_capped {k : ℕ} (hk : k ≤ 5) (s : ℚ) (hs : s ≤ 1) :
    s ≤ RoundEightOpening.phoenixMult k :=
  le_trans hs (RoundEightOpening.one_le_phoenixMult hk)

/-- **The 3 : 1.75 rule is capped**: no element goes above a one-element dragon. -/
theorem ratio_capped (p : Bool) : ratioStrength p ≤ 1 := by
  cases p <;> norm_num [ratioStrength]

/-- **So the phoenix stays ahead of the 3 : 1.75 rule**, element by element, at every count. -/
theorem phoenix_beats_ratio {k : ℕ} (hk : k ≤ 5) (p : Bool) :
    ratioStrength p ≤ RoundEightOpening.phoenixMult k :=
  phoenix_ge_any_capped hk _ (ratio_capped p)

/-! ## 5. Skybox access, version 3: private with guest tiers -/

/-- Access settings. `privateGuests` lists guests with their access tier (higher = more). Every
other setting admits at tier 0 (entry only); the owner always has every tier. -/
inductive Access3 (P A B : Type)
  | publicAccess
  | privateGuests (guests : List (P × ℕ))
  | minLevel (n : ℕ)
  | archetypes (allowed : List A)
  | builds (allowed : List B)
  | allOf (x y : Access3 P A B)
  | anyOf (x y : Access3 P A B)

open RoundNineOpening (Visitor)

/-- Whether a non-owner visitor gets tier `t` under an access setting. -/
def Access3.grants {P A B : Type} : Access3 P A B → Visitor P A B → ℕ → Prop
  | .publicAccess, _, t => t = 0
  | .privateGuests g, v, t => ∃ u, (v.id, u) ∈ g ∧ t ≤ u
  | .minLevel n, v, t => n ≤ v.level ∧ t = 0
  | .archetypes l, v, t => v.archetype ∈ l ∧ t = 0
  | .builds l, v, t => v.build ∈ l ∧ t = 0
  | .allOf x y, v, t => x.grants v t ∧ y.grants v t
  | .anyOf x y, v, t => x.grants v t ∨ y.grants v t

/-- A skybox, version 3. -/
structure Skybox3 (P A B : Type) where
  owner : P
  access : Access3 P A B

/-- Visitor `v` may do something that needs tier `t` (entering needs tier 0). -/
def Skybox3.allows {P A B : Type} (s : Skybox3 P A B) (v : Visitor P A B) (t : ℕ) : Prop :=
  v.id = s.owner ∨ s.access.grants v t

/-- **The owner can do everything in their own skybox.** -/
theorem owner_full_access_v3 {P A B : Type} (s : Skybox3 P A B) (v : Visitor P A B)
    (h : v.id = s.owner) (t : ℕ) : s.allows v t := Or.inl h

theorem grants_mono {P A B : Type} (a : Access3 P A B) (v : Visitor P A B) {t t' : ℕ}
    (h : t' ≤ t) (ht : a.grants v t) : a.grants v t' := by
  induction a with
  | publicAccess => simp only [Access3.grants] at *; omega
  | privateGuests g => obtain ⟨u, hu, htu⟩ := ht; exact ⟨u, hu, le_trans h htu⟩
  | minLevel n => exact ⟨ht.1, by have := ht.2; omega⟩
  | archetypes l => exact ⟨ht.1, by have := ht.2; omega⟩
  | builds l => exact ⟨ht.1, by have := ht.2; omega⟩
  | allOf x y ihx ihy => exact ⟨ihx ht.1, ihy ht.2⟩
  | anyOf x y ihx ihy => exact ht.elim (fun h1 => Or.inl (ihx h1)) (fun h2 => Or.inr (ihy h2))

/-- **A guest with tier `t` can do everything that needs tier `t` or less.** -/
theorem guest_tier_mono {P A B : Type} (s : Skybox3 P A B) (v : Visitor P A B) {t t' : ℕ}
    (h : t' ≤ t) (ht : s.allows v t) : s.allows v t' :=
  ht.imp id (grants_mono _ _ h)

/-- **A guest given tier `u` in a private skybox gets exactly the tiers up to `u`** (when they
appear once on the list). -/
theorem private_guest_gets {P A B : Type} (owner : P) (v : Visitor P A B) (u t : ℕ)
    (hne : v.id ≠ owner) :
    (Skybox3.mk owner (Access3.privateGuests [(v.id, u)] : Access3 P A B)).allows v t ↔ t ≤ u := by
  simp [Skybox3.allows, Access3.grants, hne]

/-- **Someone not on the guest list can't enter a private skybox.** -/
theorem stranger_kept_out {P A B : Type} (owner : P) (g : List (P × ℕ)) (v : Visitor P A B)
    (hne : v.id ≠ owner) (hg : ∀ u, (v.id, u) ∉ g) (t : ℕ) :
    ¬ (Skybox3.mk owner (Access3.privateGuests g : Access3 P A B)).allows v t := by
  rintro (h | ⟨u, hu, -⟩)
  · exact hne h
  · exact hg u hu

/-- **A private skybox with no guests is owner-only.** -/
theorem private_no_guests {P A B : Type} (owner : P) (v : Visitor P A B) (t : ℕ) :
    (Skybox3.mk owner (Access3.privateGuests [] : Access3 P A B)).allows v t ↔ v.id = owner := by
  simp [Skybox3.allows, Access3.grants]

/-- Change the setting (including the guest list): only the owner or a DEV can. -/
def setAccess {P A B : Type} [DecidableEq P] (isDev : P → Prop) [DecidablePred isDev]
    (s : Skybox3 P A B) (who : P) (new : Access3 P A B) : Skybox3 P A B :=
  if who = s.owner ∨ isDev who then ⟨s.owner, new⟩ else s

/-- **Only the owner or a DEV can change a skybox's access or guest list.** -/
theorem setAccess_unauthorized {P A B : Type} [DecidableEq P] (isDev : P → Prop)
    [DecidablePred isDev] (s : Skybox3 P A B) (who : P) (new : Access3 P A B)
    (h1 : who ≠ s.owner) (h2 : ¬ isDev who) : setAccess isDev s who new = s := by
  unfold setAccess; rw [if_neg (by tauto)]

end RoundNineSecond

end
