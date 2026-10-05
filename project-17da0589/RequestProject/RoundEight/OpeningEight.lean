module

public import Mathlib
public import RequestProject.RoundThree.Curation
public import RequestProject.RoundFour.RulingsFour
public import RequestProject.RoundSeven.ThirdPassSeven
public import RequestProject.RoundSeven.FourthPassSeven

/-!
# Round Eight, opening pass: the answers written on *ORION R8 Live*

* **Skill orbs, corrected.** There is no limit on how many gold-locked (level-100) orbs a player
  owns (`gold_unbounded`). Gold-locking more orbs never takes a player past level 64 on its own
  (`orbs_alone_level`); level 65 (dragon rider) comes only from meditating in a safe zone with the
  64-orb grid complete (`meditate_rider_iff`, `rider_needs_grid`). Surplus orbs can be kept or
  exchanged at 50%, rounded in the player's favour (`exchange_energy_bounds`), and an exchange
  never breaks the 64-orb grid (`rider_needs_grid`).
* **Phoenix taper.** With `k` active elements a phoenix works at `1 + (5 - k)/40` times an
  ordinary dragon of the same skill: 1.1× with one element (the Round 5 rule), never below 1×, and
  exactly 1× with all five (`phoenixMult_one`, `one_le_phoenixMult`, `phoenixMult_five`,
  `phoenixMult_antitone`). This is the earlier focus-cost model with `d = 1/44`
  (`phoenixMult_eq_focus`).
* **Ordinary dragons stack elements in a fixed order** as their skill grows: the unlocked
  elements are always the first few of the order and only grow with skill (`unlocked_prefix`,
  `unlocked_mono`). If stacking costs an ordinary dragon any power, a phoenix running the same
  number of elements is stronger in each one (`phoenix_beats_stacked_dragon`).
* **Tax locked at 3%** (`tax3_free_iff`, `tax3_examples`).
* **Three kinds of skybox access**: open access, level-specific, and the Round 3 quest/key gate.
  Crafting still never opens a quest-gated skybox (`crafting_never_opens_gated`).
* **Never stuck, with a quest generator and a search.** The search returns exactly the unfinished
  quests of the chosen category the player can complete (`mem_search_iff`); a generator that
  pitches a fresh quest at the player's level always exists (`generator_fresh`,
  `generator_completable`); and interacting with the world alone eventually unlocks any skill
  requirement (`interaction_unlocks`).
* **Story gate, version 2.** Any genre label; genres that need sources (real stories) can only be
  published with at least one cited source (`run_sourced`); every genre's record stays consistent
  (`run_canon2_satisfiable`); a reworked story is taken down and must pass the gate again
  (`rework_requires_gate`).
* **RD pool overflow, one option worked out.** Scaling every claim down by the same factor never
  pays out more than the pool (`rdScaled_total_le`, `rdScaled_example`).
* **The toroidal loop.** Engine → socials → MMO → education → projects → ancestral tree → back to
  the engine: six steps return every layer to itself (`next_six`), and every layer reaches every
  other within five steps (`reach_all`).
* **Crafted special skins.** The look of a skin is still cosmetic; a bioengineered skin's
  enhancement is a separate input (`lookBlind_iff_factors`).
-/

@[expose] public section

namespace RoundEightOpening

/-! ## 1. Skill orbs: no cap on gold-locked orbs; level 65 by meditation -/

/-- The 64-orb grid a player builds before becoming a dragon rider. -/
def gridSize : ℕ := 64

/-- A player's orb progression: how many gold-locked orbs they own (no maximum), whether they have
completed the dragon-rider meditation, and the energy earned by exchanging surplus orbs. -/
structure Progress where
  gold : ℕ
  rider : Bool
  energy : ℕ

/-- A new player. -/
def Progress.fresh : Progress := ⟨0, false, 0⟩

/-- Player level, as far as it has been ruled: one level per gold-locked orb up to the 64-orb
grid, and level 65 after the dragon-rider meditation. -/
def level (p : Progress) : ℕ := if p.rider then 65 else min p.gold gridSize

/-- What a player can do with orbs. `exchange v` trades one surplus orb worth `v` for energy. -/
inductive OrbAct
  | goldLock
  | meditate (safeZone : Bool)
  | exchange (v : ℕ)

/-- Energy from exchanging an orb worth `v` at 50%, rounded up (payouts round in the player's
favour, Round 4 ruling D1). -/
def exchangeEnergy (v : ℕ) : ℕ := (v + 1) / 2

/-- One action. Meditation makes the player a dragon rider only in a safe zone with the 64-orb
grid complete. Only orbs beyond the grid can be exchanged. -/
def step (p : Progress) : OrbAct → Progress
  | .goldLock => { p with gold := p.gold + 1 }
  | .meditate safe => if safe = true ∧ gridSize ≤ p.gold then { p with rider := true } else p
  | .exchange v =>
      if gridSize < p.gold then { p with gold := p.gold - 1, energy := p.energy + exchangeEnergy v }
      else p

/-- Run a list of actions from a starting state. -/
def run (p : Progress) (acts : List OrbAct) : Progress := acts.foldl step p

theorem run_goldLocks (p : Progress) (n : ℕ) :
    run p (List.replicate n .goldLock) = { p with gold := p.gold + n } := by
  induction n generalizing p with
  | zero => rfl
  | succ n ih =>
    rw [List.replicate_succ, run, List.foldl_cons, ← run, ih]
    simp only [step]
    congr 1
    omega

/-- **No maximum on gold-locked orbs.** Any number of orbs can be gold-locked. -/
theorem gold_unbounded (N : ℕ) : ∃ acts, N < (run Progress.fresh acts).gold :=
  ⟨List.replicate (N + 1) .goldLock, by rw [run_goldLocks]; simp [Progress.fresh]⟩

/-- **Orbs alone stop at level 64.** A new player who only gold-locks orbs is at level
`min n 64` after `n` orbs, and is never a dragon rider. -/
theorem orbs_alone_level (n : ℕ) :
    level (run Progress.fresh (List.replicate n .goldLock)) = min n 64 ∧
      (run Progress.fresh (List.replicate n .goldLock)).rider = false := by
  rw [run_goldLocks]
  simp [level, Progress.fresh, gridSize]

/-- **Level 65 is reached by meditation.** Meditating makes a player a dragon rider exactly when
they already are one, or they are in a safe zone with at least 64 gold-locked orbs. -/
theorem meditate_rider_iff (p : Progress) (safe : Bool) :
    (step p (.meditate safe)).rider = true ↔ p.rider = true ∨ (safe = true ∧ 64 ≤ p.gold) := by
  simp only [step, gridSize]
  split_ifs with h
  · simp [h]
  · constructor
    · exact Or.inl
    · rintro (h' | h')
      · exact h'
      · exact absurd h' h

/-- Player level never exceeds 65 under the rules ruled so far. -/
theorem level_le (p : Progress) : level p ≤ 65 := by
  unfold level gridSize; split_ifs <;> omega

/-- **Dragon riders always keep their 64-orb grid.** Starting from a new player, after any
actions, a dragon rider owns at least 64 gold-locked orbs: meditation needs the full grid, and
exchanging only ever trades surplus orbs. -/
theorem rider_needs_grid (acts : List OrbAct) :
    (run Progress.fresh acts).rider = true → 64 ≤ (run Progress.fresh acts).gold := by
  suffices ∀ p : Progress, (p.rider = true → 64 ≤ p.gold) →
      ((run p acts).rider = true → 64 ≤ (run p acts).gold) from
    this _ (by simp [Progress.fresh])
  induction acts with
  | nil => intro p h; exact h
  | cons a rest ih =>
    intro p h
    apply ih
    cases a with
    | goldLock => intro hr; simp only [step] at hr ⊢; have := h hr; omega
    | meditate safe =>
      simp only [step, gridSize]
      split_ifs with hs
      · intro _; exact hs.2
      · exact h
    | exchange v =>
      simp only [step, gridSize]
      split_ifs with hs
      · intro _; simp only; omega
      · exact h

/-- **The 50% exchange.** Exchanging an orb worth `v` gives at least half of `v`, and at most half
a unit more. -/
theorem exchange_energy_bounds (v : ℕ) :
    v ≤ 2 * exchangeEnergy v ∧ 2 * exchangeEnergy v ≤ v + 1 := by
  unfold exchangeEnergy; omega

/-! ## 2. Phoenix taper and ordinary dragons stacking elements -/

/-- A phoenix's strength in each active element, relative to an ordinary single-element dragon
of the same skill, when it runs `k` elements (1 to 5). -/
def phoenixMult (k : ℕ) : ℚ := 1 + (5 - (k : ℚ)) / 40

/-- **Fire alone keeps the Round 5 rule:** 10% above any ordinary dragon. -/
theorem phoenixMult_one : phoenixMult 1 = 11 / 10 := by norm_num [phoenixMult]

/-- **All five elements at full dragon power.** -/
theorem phoenixMult_five : phoenixMult 5 = 1 := by norm_num [phoenixMult]

/-- **The floor.** With at most five elements the phoenix never drops below an ordinary dragon. -/
theorem one_le_phoenixMult {k : ℕ} (hk : k ≤ 5) : 1 ≤ phoenixMult k := by
  unfold phoenixMult
  have : (k : ℚ) ≤ 5 := by exact_mod_cast hk
  linarith

/-- **Adding elements narrows the lead.** -/
theorem phoenixMult_antitone {j k : ℕ} (h : j ≤ k) : phoenixMult k ≤ phoenixMult j := by
  unfold phoenixMult
  have : (j : ℚ) ≤ k := by exact_mod_cast h
  linarith

/-- The taper is the Round 7 focus-cost model with `d = 1/44`, applied to the 1.1× phoenix. -/
theorem phoenixMult_eq_focus (k : ℕ) :
    phoenixMult k = 11 / 10 * RoundSevenThirdPass.focus (1 / 44) k := by
  unfold phoenixMult RoundSevenThirdPass.focus; ring

/-- The elements an ordinary dragon has unlocked: the first `unlockCount skill` of a fixed order. -/
def unlocked {E : Type} (order : List E) (unlockCount : ℕ → ℕ) (skill : ℕ) : List E :=
  order.take (unlockCount skill)

/-- **Always in the same order.** The unlocked elements are a prefix of the fixed order. -/
theorem unlocked_prefix {E : Type} (order : List E) (unlockCount : ℕ → ℕ) (skill : ℕ) :
    unlocked order unlockCount skill <+: order :=
  List.take_prefix _ _

/-- **More skill never loses an element.** -/
theorem unlocked_mono {E : Type} (order : List E) (unlockCount : ℕ → ℕ) (hmono : Monotone unlockCount)
    {s t : ℕ} (hst : s ≤ t) : unlocked order unlockCount s <+: unlocked order unlockCount t := by
  unfold unlocked
  have h := hmono hst
  rw [show unlockCount t = unlockCount s + (unlockCount t - unlockCount s) by omega,
    List.take_add]
  exact List.prefix_append _ _

/-- **The phoenix is the only one at full power in several elements.** If an ordinary dragon
running `k ≥ 2` elements works at a factor `c k < 1` in each, a phoenix of the same skill running
the same `k ≤ 5` elements is stronger in each one. -/
theorem phoenix_beats_stacked_dragon (c : ℕ → ℚ) (hc : ∀ k, 2 ≤ k → c k < 1) {k : ℕ}
    (hk2 : 2 ≤ k) (hk5 : k ≤ 5) {s : ℚ} (hs : 0 < s) : c k * s < phoenixMult k * s := by
  have h1 := hc k hk2
  have h2 := one_le_phoenixMult hk5
  nlinarith

/-! ## 3. Tax locked at 3% -/

open RoundSevenThirdPass in
/-- **At 3%, an amount pays no tax exactly when it is below 34 coins.** -/
theorem tax3_free_iff (x : ℕ) : taxAt 3 x = 0 ↔ x < 34 := by
  rw [taxAt_eq_zero_iff]; omega

open RoundSevenThirdPass in
/-- The 3% column of the worked-example table. -/
theorem tax3_examples :
    skimTotalAt 3 [49, 49] = 2 ∧ skimEachAt 3 [49, 49] = 2 ∧
      skimTotalAt 3 (List.replicate 10 19) = 5 ∧ skimEachAt 3 (List.replicate 10 19) = 0 ∧
      taxAt 3 1000 = 30 := by decide

/-! ## 4. Kinds of skybox -/

open RoundThreeCuration

/-- A skybox is open to everyone, open from a given level, or behind the Round 3 gate (the escape
earned through a quest line of `Q` steps, or a key). -/
inductive Skybox
  | openAccess
  | levelGated (minLevel : ℕ)
  | questGated (Q : ℕ)

/-- Whether a player at level `lvl` with progress `t` can enter. -/
def canEnter (lvl : ℕ) (t : Traveller) : Skybox → Prop
  | .openAccess => True
  | .levelGated L => L ≤ lvl
  | .questGated Q => passesGate Q t

theorem canEnter_open (lvl : ℕ) (t : Traveller) : canEnter lvl t .openAccess := trivial

theorem canEnter_level_iff (lvl L : ℕ) (t : Traveller) :
    canEnter lvl t (.levelGated L) ↔ L ≤ lvl := Iff.rfl

/-- **Crafting still never opens a quest-gated skybox.** -/
theorem crafting_never_opens_gated (lvl Q : ℕ) (hQ : 0 < Q) (n : ℕ) :
    ¬ canEnter lvl ((fun t => t.act .craft)^[n] Traveller.fresh) (.questGated Q) :=
  crafting_alone_blocked Q hQ n

/-! ## 5. Never stuck: search, quest generator, and interaction -/

open RoundFourRulingsFour

/-- A quest in the quest book: an identifier, a category, and its stages. -/
structure Quest (Cat : Type) where
  id : ℕ
  cat : Cat
  stages : List Stage

/-- The search feature: unfinished quests in the chosen category that a player at skill `s` can
complete. -/
def search {Cat : Type} [DecidableEq Cat] (catalogue : List (Quest Cat)) (done : Finset ℕ)
    (category : Cat) (s : ℕ) : List (Quest Cat) :=
  catalogue.filter (fun q => decide (q.cat = category) && decide (q.id ∉ done) &&
    completable s q.stages)

/-- **The search is exact.** A quest is returned exactly when it is in the catalogue, in the chosen
category, unfinished, and completable at the player's skill. -/
theorem mem_search_iff {Cat : Type} [DecidableEq Cat] (catalogue : List (Quest Cat))
    (done : Finset ℕ) (category : Cat) (s : ℕ) (q : Quest Cat) :
    q ∈ search catalogue done category s ↔
      q ∈ catalogue ∧ q.cat = category ∧ q.id ∉ done ∧ completable s q.stages = true := by
  simp [search, and_assoc]

/-- The generator: a fresh quest in the chosen category, pitched at the player's own skill. -/
def generate {Cat : Type} (done : Finset ℕ) (category : Cat) (s : ℕ) : Quest Cat :=
  ⟨done.sup id + 1, category, [⟨s, 1⟩]⟩

/-- **A generated quest is new.** -/
theorem generator_fresh {Cat : Type} (done : Finset ℕ) (category : Cat) (s : ℕ) :
    (generate done category s).id ∉ done := by
  intro h
  have h1 : done.sup id + 1 ≤ done.sup id := Finset.le_sup (f := id) h
  omega

/-- **A generated quest can be completed.** -/
theorem generator_completable {Cat : Type} (done : Finset ℕ) (category : Cat) (s : ℕ) :
    completable s (generate done category s).stages = true := by
  simp [generate, completable]

/-- **Interaction alone unlocks everything.** If every interaction with the world (raids, guilds,
the environment) raises skill by at least 1, then after `R` interactions a player who started at
skill 0 meets any skill requirement `R`. -/
theorem interaction_unlocks (gain : ℕ → ℕ) (hg : ∀ s, 1 ≤ gain s) (R : ℕ) :
    R ≤ (fun s => s + gain s)^[R] 0 := by
  suffices ∀ n s, s + n ≤ (fun s => s + gain s)^[n] s by simpa using this R 0
  intro n
  induction n with
  | zero => intro s; simp
  | succ n ih =>
    intro s
    rw [Function.iterate_succ_apply]
    have := ih (s + gain s)
    have := hg s
    omega

/-! ## 6. Story gate, version 2 -/

open RoundSevenFollowUp RoundSevenFourthPass

/-- A story with any genre label, the facts it asserts, and the sources attached to it. -/
structure Story2 (G Key : Type) where
  genre : G
  claims : List (Constraint Key)
  sources : List String

/-- Everything already published in one genre. -/
def canon2 {G Key : Type} [DecidableEq G] (published : List (Story2 G Key)) (g : G) :
    List (Constraint Key) :=
  ((published.filter (fun st => st.genre = g)).map Story2.claims).flatten

/-- A story is admissible when it is consistent with its genre's record and, if its genre needs
sources (real stories), it cites at least one. -/
def Admissible2 {G Key : Type} [DecidableEq G] [DecidableEq Key] (needsSource : G → Prop)
    (published : List (Story2 G Key)) (st : Story2 G Key) : Prop :=
  contractCheck (canon2 published st.genre ++ st.claims) ∧ (needsSource st.genre → st.sources ≠ [])

open Classical in
/-- Try to publish a story. -/
noncomputable def publish2 {G Key : Type} [DecidableEq G] [DecidableEq Key] (needsSource : G → Prop)
    (published : List (Story2 G Key)) (st : Story2 G Key) : List (Story2 G Key) :=
  if Admissible2 needsSource published st then published ++ [st] else published

/-- Rework the `i`-th published story: it is taken down, and the new version goes through the
gate again against everything else. -/
noncomputable def rework {G Key : Type} [DecidableEq G] [DecidableEq Key] (needsSource : G → Prop)
    (published : List (Story2 G Key)) (i : ℕ) (st : Story2 G Key) : List (Story2 G Key) :=
  publish2 needsSource (published.eraseIdx i) st

/-- **A reworked story goes back through the gate.** If the new version is in the record after a
rework, it was admissible against everything else that was published. -/
theorem rework_requires_gate {G Key : Type} [DecidableEq G] [DecidableEq Key]
    (needsSource : G → Prop) (published : List (Story2 G Key)) (i : ℕ) (st : Story2 G Key) :
    rework needsSource published i st = published.eraseIdx i ++ [st] →
      Admissible2 needsSource (published.eraseIdx i) st := by
  unfold rework publish2
  split_ifs with h
  · intro _; exact h
  · intro heq
    have := congrArg List.length heq
    simp at this

theorem canon2_append_single {G Key : Type} [DecidableEq G] (published : List (Story2 G Key))
    (st : Story2 G Key) (g : G) :
    canon2 (published ++ [st]) g = canon2 published g ++ (if st.genre = g then st.claims else []) := by
  unfold canon2
  by_cases h : st.genre = g <;> simp [List.filter_append, h]

/-- Publishing keeps every genre consistent. -/
theorem publish2_canon_satisfiable {G Key : Type} [DecidableEq G] [DecidableEq Key]
    (needsSource : G → Prop) (published : List (Story2 G Key)) (st : Story2 G Key)
    (h : ∀ g, Satisfiable (canon2 published g)) (g : G) :
    Satisfiable (canon2 (publish2 needsSource published st) g) := by
  unfold publish2
  split_ifs with hadm
  · rw [canon2_append_single]
    by_cases hg : st.genre = g
    · rw [if_pos hg]
      have := (contractCheck_iff_satisfiable _).1 hadm.1
      rwa [hg] at this
    · rw [if_neg hg, List.append_nil]; exact h g
  · exact h g

/-- Taking a story down keeps every genre consistent. -/
theorem eraseIdx_canon2_satisfiable {G Key : Type} [DecidableEq G] (published : List (Story2 G Key))
    (i : ℕ) (h : ∀ g, Satisfiable (canon2 published g)) (g : G) :
    Satisfiable (canon2 (published.eraseIdx i) g) := by
  obtain ⟨w, hw⟩ := h g
  refine ⟨w, fun c hc => hw c ?_⟩
  unfold canon2 at hc ⊢
  simp only [List.mem_flatten, List.mem_map, List.mem_filter] at hc ⊢
  obtain ⟨l, ⟨st, ⟨hst, hg⟩, rfl⟩, hcl⟩ := hc
  exact ⟨st.claims, ⟨st, ⟨(List.eraseIdx_sublist _ _).subset hst, hg⟩, rfl⟩, hcl⟩

/-- Every published story whose genre needs sources has at least one. -/
def AllSourced {G Key : Type} (needsSource : G → Prop) (published : List (Story2 G Key)) : Prop :=
  ∀ st ∈ published, needsSource st.genre → st.sources ≠ []

theorem publish2_sourced {G Key : Type} [DecidableEq G] [DecidableEq Key] (needsSource : G → Prop)
    (published : List (Story2 G Key)) (st : Story2 G Key) (h : AllSourced needsSource published) :
    AllSourced needsSource (publish2 needsSource published st) := by
  unfold publish2
  split_ifs with hadm
  · intro x hx
    rcases List.mem_append.1 hx with hx | hx
    · exact h x hx
    · rw [List.mem_singleton.1 hx]; exact hadm.2
  · exact h

/-- One editorial action: submit a new story, or rework the `i`-th published one. -/
inductive Edit (G Key : Type)
  | submit (st : Story2 G Key)
  | rework (i : ℕ) (st : Story2 G Key)

/-- Apply one editorial action. -/
noncomputable def applyEdit {G Key : Type} [DecidableEq G] [DecidableEq Key] (needsSource : G → Prop)
    (published : List (Story2 G Key)) : Edit G Key → List (Story2 G Key)
  | .submit st => publish2 needsSource published st
  | .rework i st => rework needsSource published i st

/-- Run editorial actions from an empty record. -/
noncomputable def runEdits {G Key : Type} [DecidableEq G] [DecidableEq Key] (needsSource : G → Prop)
    (edits : List (Edit G Key)) : List (Story2 G Key) :=
  edits.foldl (applyEdit needsSource) []

theorem runEdits_invariant {G Key : Type} [DecidableEq G] [DecidableEq Key] (needsSource : G → Prop)
    (edits : List (Edit G Key)) :
    (∀ g, Satisfiable (canon2 (runEdits needsSource edits) g)) ∧
      AllSourced needsSource (runEdits needsSource edits) := by
  suffices ∀ start : List (Story2 G Key),
      ((∀ g, Satisfiable (canon2 start g)) ∧ AllSourced needsSource start) →
      (∀ g, Satisfiable (canon2 (edits.foldl (applyEdit needsSource) start) g)) ∧
        AllSourced needsSource (edits.foldl (applyEdit needsSource) start) from
    this [] ⟨fun g => by simpa [canon2] using satisfiable_nil, by simp [AllSourced]⟩
  induction edits with
  | nil => intro start h; exact h
  | cons e rest ih =>
    intro start ⟨hs, ha⟩
    apply ih
    cases e with
    | submit st => exact ⟨publish2_canon_satisfiable _ _ _ hs, publish2_sourced _ _ _ ha⟩
    | rework i st =>
      refine ⟨publish2_canon_satisfiable _ _ _ (eraseIdx_canon2_satisfiable _ i hs),
        publish2_sourced _ _ _ ?_⟩
      intro x hx
      exact ha x ((List.eraseIdx_sublist _ _).subset hx)

/-- **Every genre's record is always consistent**, whatever is submitted or reworked. -/
theorem run_canon2_satisfiable {G Key : Type} [DecidableEq G] [DecidableEq Key]
    (needsSource : G → Prop) (edits : List (Edit G Key)) (g : G) :
    Satisfiable (canon2 (runEdits needsSource edits) g) :=
  (runEdits_invariant needsSource edits).1 g

/-- **Every published real story cites a source**, whatever is submitted or reworked. -/
theorem run_sourced {G Key : Type} [DecidableEq G] [DecidableEq Key] (needsSource : G → Prop)
    (edits : List (Edit G Key)) : AllSourced needsSource (runEdits needsSource edits) :=
  (runEdits_invariant needsSource edits).2

/-! ## 7. RD pool overflow: the "scale everyone down" option (for the explanation in the reply) -/

/-- Shares claimed from a pool of size `P` (in percent, or in coins). If the claims fit they are
paid as claimed; otherwise every claim is scaled down by the same factor `P / total`. -/
noncomputable def rdScaled (claims : List ℚ) (P : ℚ) : List ℚ :=
  if claims.sum ≤ P then claims else claims.map (fun w => w * (P / claims.sum))

/-- **Scaling never pays out more than the pool.** -/
theorem rdScaled_total_le (claims : List ℚ) {P : ℚ} (hP : 0 ≤ P) :
    (rdScaled claims P).sum ≤ P := by
  unfold rdScaled
  split_ifs with h
  · exact h
  · have hpos : claims.sum ≠ 0 := by intro h0; rw [h0] at h; exact h hP
    rw [List.sum_map_mul_right, List.map_id']
    field_simp
    exact le_refl _

/-- Worked example: a creator's 2% plus six DEV collaborators at 20% each claim 122% of the pool.
Scaled down, the creator gets 100/61 % (about 1.64%) and each collaborator 1000/61 % (about
16.39%), using exactly 100%. -/
theorem rdScaled_example :
    rdScaled (2 :: List.replicate 6 20) 100 =
      100 / 61 :: List.replicate 6 (1000 / 61) := by
  norm_num [rdScaled, List.replicate]

/-! ## 8. The toroidal loop -/

/-- The layers in the order ruled on R8 Live. -/
inductive Layer
  | engine
  | socials
  | mmo
  | education
  | projects
  | ancestralTree
  deriving DecidableEq, Fintype, Repr

/-- The next layer; the ancestral tree feeds back into the engine. -/
def Layer.next : Layer → Layer
  | .engine => .socials
  | .socials => .mmo
  | .mmo => .education
  | .education => .projects
  | .projects => .ancestralTree
  | .ancestralTree => .engine

/-- The default path, starting from the engine. -/
theorem default_path :
    (List.range 6).map (fun n => Layer.next^[n] .engine) =
      [.engine, .socials, .mmo, .education, .projects, .ancestralTree] := by decide

/-- **It is a loop.** Six steps bring every layer back to itself. -/
theorem next_six (l : Layer) : Layer.next^[6] l = l := by cases l <;> rfl

/-- **Enter anywhere, reach everything.** From any layer, every layer is at most five steps
along. -/
theorem reach_all : ∀ a b : Layer, ∃ n < 6, Layer.next^[n] a = b := by decide

/-! ## 9. Crafted special skins -/

/-- A character whose skin has a look (cosmetic) and, for a crafted bioengineered skin, an
enhancement. -/
structure Character2 (Sp Bd Ar Lk En Tr : Type) where
  species : Sp
  body : Bd
  archetype : Ar
  look : Lk
  skinEnhancement : Option En
  traits : List Tr

variable {Sp Bd Ar Lk En Tr α : Type}

/-- An ability rule ignores the look of the skin. -/
def LookBlind (ability : Character2 Sp Bd Ar Lk En Tr → α) : Prop :=
  ∀ c (l : Lk), ability { c with look := l } = ability c

/-- **A skin's look stays cosmetic.** An ability rule ignores the look exactly when it is computed
from species, body, archetype, the skin's enhancement (if any) and traits. -/
theorem lookBlind_iff_factors [Nonempty Lk] (ability : Character2 Sp Bd Ar Lk En Tr → α) :
    LookBlind ability ↔
      ∃ f : Sp → Bd → Ar → Option En → List Tr → α,
        ∀ c, ability c = f c.species c.body c.archetype c.skinEnhancement c.traits := by
  constructor
  · intro h
    obtain ⟨l₀⟩ := ‹Nonempty Lk›
    exact ⟨fun sp bd ar en tr => ability ⟨sp, bd, ar, l₀, en, tr⟩, fun c => (h c l₀).symm⟩
  · rintro ⟨f, hf⟩ c l
    rw [hf, hf]

end RoundEightOpening

end
