module

public import Mathlib
public import RequestProject.RoundFour.RulingsFour

/-!
# Round Five rulings: repeated council reassessment, phoenix strength, quest kinds,
# royalty overflow to the developer arenas, and safe-zone lock-in for every skill

The designer's answers written into the *ORION R5 – Ryan's Links* page (under the copy of the
previous reply), stated as rules with their consequences proved.

* **Council: a new no forces another reassessment.** After a split first round, the council
  reassesses. If a seat that voted *yes* in the first round now votes *no*, the dissent has
  spread and the council reassesses again (`new_nay_forces_another_round`). If the only noes
  left are the same noes from the same seats as in the first round, the council settles that
  round by the 4/5 rule (`settles_on_original_nays`). Passing always means 4/5 approval in the
  round of record (`pass_has_four_fifths5`). A settling round never has more noes than the
  first round (`settled_nays_le_first`), so a motion that already had 4/5 in the first round
  passes as soon as it settles (`first_four_fifths_passes_on_settling`). Without a cap the
  deliberation can go on indefinitely (`endless_without_cap`).
* **Phoenix strength.** The phoenix's abilities must be at least 10% above every non-phoenix
  dragon and every elemental player (`PhoenixAbove`). With non-phoenix dragons between 2× and
  2.2× a non-dragon player, a phoenix at 2.42× or more satisfies the rule
  (`phoenix_threshold_suffices`), and 2.42× is the least that works if some dragon sits at the
  2.2× top (`phoenix_threshold_needed`).
* **Quest kinds.** Every quest has an exact entry skill (`entrySkill`): a player can complete it
  exactly when their starting skill reaches that value (`completable_iff_entry`). Leveled and
  sub-leveled quests are completable now (`leveled_or_sub_completable`). Epic training quests
  sit above the player's level: their end goal cannot be reached yet, and becomes reachable
  exactly once the player reaches the entry skill (`epic_locked_until_entry`).
* **Royalty overflow.** Royalties that would have gone to a hard-reset user flow into the public
  developer team arenas instead (`payee`, `hardReset_to_arena`). A hard reset moves exactly that
  user's share into the arenas (`hardReset_arena_gain`), takes the user's share to zero
  (`hardReset_user_zero`), and leaves other users' shares unchanged (`hardReset_other_user`).
* **No auto-levelling.** Skill progress can be built up anywhere (`train`), but it only becomes
  part of the build ("gold-locked") through meditation in a safe zone, out of combat. So locked
  skill never changes in any run without such a meditation (`locked_only_by_meditation`),
  meditating elsewhere does nothing (`meditate_needs_safe_zone`), and progress is never lost
  (`total_progress`).
-/

@[expose] public section

namespace RoundFiveRulings

open RoundFourRulings RoundFourRulingsTwo RoundFourRulingsThree RoundFourRulingsFour

/-! ## Council: reassess again whenever a new no appears -/

/-- A seat that voted yes in the first round votes no in round `r`: the dissent has spread. -/
def hasNewNay {n : ℕ} (first r : Fin n → Bool) : Bool :=
  decide (∃ i, r i = false ∧ first i = true)

/-- Run the reassessment rounds in order. A round with a new no triggers another round. A round
whose noes all come from seats that already voted no in the first round settles the motion by
the 4/5 rule. `none` means the council is still deliberating. -/
def deliberate {n : ℕ} (first : Fin n → Bool) : List (Fin n → Bool) → Option Bool
  | [] => none
  | r :: rest => if hasNewNay first r then deliberate first rest else some (council (List.ofFn r))

/-- The council's decision: a unanimous first round passes at once; otherwise it is decided by
the reassessment rounds. -/
def decide5 {n : ℕ} (first : Fin n → Bool) (rounds : List (Fin n → Bool)) : Option Bool :=
  if ∀ i, first i = true then some true else deliberate first rounds

/-- **A unanimous first round passes.** -/
theorem unanimous_passes5 {n : ℕ} (first : Fin n → Bool) (rounds : List (Fin n → Bool))
    (h : ∀ i, first i = true) : decide5 first rounds = some true := by
  simp [decide5, h]

/-- **A new no forces another reassessment.** -/
theorem new_nay_forces_another_round {n : ℕ} (first r : Fin n → Bool)
    (rest : List (Fin n → Bool)) (h : hasNewNay first r = true) :
    deliberate first (r :: rest) = deliberate first rest := by
  simp [deliberate, h]

/-- **Only the original noes left: the round settles by the 4/5 rule.** -/
theorem settles_on_original_nays {n : ℕ} (first r : Fin n → Bool)
    (rest : List (Fin n → Bool)) (h : hasNewNay first r = false) :
    deliberate first (r :: rest) = some (council (List.ofFn r)) := by
  simp [deliberate, h]

theorem deliberate_pass {n : ℕ} (first : Fin n → Bool) :
    ∀ rounds : List (Fin n → Bool), deliberate first rounds = some true →
      ∃ r ∈ rounds, hasNewNay first r = false ∧ 5 * (List.ofFn r).count false ≤ n
  | [], h => by simp [deliberate] at h
  | r :: rest, h => by
    by_cases hr : hasNewNay first r = true
    · rw [new_nay_forces_another_round first r rest hr] at h
      obtain ⟨r', hr', h'⟩ := deliberate_pass first rest h
      exact ⟨r', List.mem_cons_of_mem _ hr', h'⟩
    · have hr' : hasNewNay first r = false := by simpa using hr
      rw [settles_on_original_nays first r rest hr'] at h
      have := (council_iff_rejections _).1 (Option.some.inj h)
      exact ⟨r, List.mem_cons_self, hr', by simpa using this⟩

/-- **Passing always means 4/5 approval in the round of record**: either the first round was
unanimous, or some reassessment round with only original noes reached 4/5. -/
theorem pass_has_four_fifths5 {n : ℕ} (first : Fin n → Bool) (rounds : List (Fin n → Bool))
    (h : decide5 first rounds = some true) :
    (∀ i, first i = true) ∨
      ∃ r ∈ rounds, hasNewNay first r = false ∧ 5 * (List.ofFn r).count false ≤ n := by
  by_cases hu : ∀ i, first i = true
  · exact Or.inl hu
  · right
    simp only [decide5, hu, if_false] at h
    exact deliberate_pass first rounds h

theorem count_false_mono : ∀ {n : ℕ} (r f : Fin n → Bool), (∀ i, r i = false → f i = false) →
    (List.ofFn r).count false ≤ (List.ofFn f).count false
  | 0, _, _, _ => by simp
  | n + 1, r, f, h => by
    rw [List.ofFn_succ, List.ofFn_succ, List.count_cons, List.count_cons]
    have ih := count_false_mono (fun i => r i.succ) (fun i => f i.succ) (fun i hi => h _ hi)
    have h0 := h 0
    cases hr : r 0 <;> cases hf : f 0 <;> simp_all
    omega

/-- **A settling round never has more noes than the first round**: its noes all come from
first-round dissenters. -/
theorem settled_nays_le_first {n : ℕ} (first r : Fin n → Bool) (h : hasNewNay first r = false) :
    (List.ofFn r).count false ≤ (List.ofFn first).count false := by
  apply count_false_mono
  intro i hi
  by_contra hf
  have : hasNewNay first r = true := by
    simp only [hasNewNay, decide_eq_true_eq]
    exact ⟨i, hi, by simpa using hf⟩
  simp_all

/-- **A motion with 4/5 in the first round passes as soon as it settles.** -/
theorem first_four_fifths_passes_on_settling {n : ℕ} (first r : Fin n → Bool)
    (rest : List (Fin n → Bool)) (hfirst : 5 * (List.ofFn first).count false ≤ n)
    (h : hasNewNay first r = false) : deliberate first (r :: rest) = some true := by
  rw [settles_on_original_nays first r rest h]
  have := settled_nays_le_first first r h
  congr 1
  rw [council_iff_rejections]
  simp only [List.length_ofFn]
  omega

/-- **Without a cap, deliberation can go on indefinitely**: if every reassessment round keeps
producing a new no, the council never decides. -/
theorem endless_without_cap {n : ℕ} (first r : Fin n → Bool) (h : hasNewNay first r = true)
    (k : ℕ) : deliberate first (List.replicate k r) = none := by
  induction k with
  | zero => rfl
  | succ k ih => rw [List.replicate_succ, new_nay_forces_another_round first r _ h, ih]

/-- Example (five seats): seat 0 votes no; in the reassessment seat 1 newly votes no, so the
council reassesses again; the second reassessment has only seat 0's original no and passes. -/
theorem spread_then_settle_example :
    decide5 (n := 5) ![false, true, true, true, true]
      [![true, false, true, true, true], ![false, true, true, true, true]] = some true := by
  decide

/-- Example (five seats): one original no plus a new no in the only reassessment so far: the
council is still deliberating. -/
theorem spread_still_open_example :
    decide5 (n := 5) ![false, true, true, true, true] [![false, false, true, true, true]] =
      none := by
  decide

/-! ## Phoenix: at least 10% above every other elemental ability -/

/-- The phoenix strength `p` is at least 10% above each strength in `others` (non-phoenix
dragons and elemental players). -/
def PhoenixAbove (p : ℚ) (others : List ℚ) : Prop := ∀ x ∈ others, 11 / 10 * x ≤ p

/-- **2.42× is enough.** If non-phoenix dragons are at most 2.2× a non-dragon player's skill `b`
and elemental players at most `b`, a phoenix at 2.42× `b` or more satisfies the rule. -/
theorem phoenix_threshold_suffices (b p : ℚ) (hb : 0 ≤ b) (dragons players : List ℚ)
    (hd : ∀ x ∈ dragons, x ≤ 11 / 5 * b) (hpl : ∀ x ∈ players, x ≤ b)
    (hp : 121 / 50 * b ≤ p) : PhoenixAbove p (dragons ++ players) := by
  intro x hx
  rcases List.mem_append.1 hx with h | h
  · have := hd x h; linarith
  · have := hpl x h; linarith

/-- **…and 2.42× is the least that works** when some non-phoenix dragon sits at the 2.2× top. -/
theorem phoenix_threshold_needed (b p : ℚ) (others : List ℚ) (htop : 11 / 5 * b ∈ others)
    (h : PhoenixAbove p others) : 121 / 50 * b ≤ p := by
  have := h _ htop; linarith

/-! ## Quest kinds: leveled, sub-leveled and epic training quests -/

/-- The exact starting skill a quest needs. -/
def entrySkill : List Stage → ℕ
  | [] => 0
  | st :: rest => max st.req (entrySkill rest - st.teaches)

/-- **Every quest has an exact entry skill**: it is completable exactly from that skill up. -/
theorem completable_iff_entry (s : ℕ) (q : List Stage) :
    completable s q = true ↔ entrySkill q ≤ s := by
  induction q generalizing s with
  | nil => simp [completable, entrySkill]
  | cons st rest ih =>
    simp only [completable, Bool.and_eq_true, decide_eq_true_eq, ih, entrySkill]
    omega

/-- **Leveled and sub-leveled quests can be completed now**: their entry skill is at or below
the player's skill. -/
theorem leveled_or_sub_completable (s : ℕ) (q : List Stage) (h : entrySkill q ≤ s) :
    completable s q = true :=
  (completable_iff_entry s q).2 h

/-- **Epic training quests stay locked until the player is ready**: above the player's level the
end goal can't be reached, and it becomes reachable exactly once the player's skill reaches the
quest's entry skill. -/
theorem epic_locked_until_entry (s : ℕ) (q : List Stage) (h : s < entrySkill q) :
    completable s q = false ∧ ∀ t, entrySkill q ≤ t → completable t q = true := by
  refine ⟨?_, fun t ht => (completable_iff_entry t q).2 ht⟩
  cases hc : completable s q
  · rfl
  · have := (completable_iff_entry s q).1 hc; omega

/-- A final gate of skill `g` at the end of a quest: the end goal requires `g`. -/
def withGate (q : List Stage) (g : ℕ) : List Stage := q ++ [⟨g, 0⟩]

/-- Example: a one-stage training quest teaching 3, gated at skill 10, needs starting skill 7. -/
theorem gate_example : entrySkill (withGate [⟨0, 3⟩] 10) = 7 := by decide

/-! ## Royalties: a hard-reset user's share flows into the developer arenas -/

/-- Who receives a record's royalties. -/
inductive Payee (U : Type) where
  /-- The record's author. -/
  | user (u : U)
  /-- The public developer team arenas. -/
  | arena
  deriving DecidableEq

/-- Royalties go to the author, or to the developer arenas once the author has hard-reset. -/
def payee {ι U : Type} [DecidableEq U] (w : World ι U) (i : ι) : Payee U :=
  if (w.records i).creator ∈ w.reset then .arena else .user (w.records i).creator

/-- The arenas take exactly the royalties that no user receives under the fourth ruling. -/
theorem payee_user_iff {ι U : Type} [DecidableEq U] (w : World ι U) (i : ι) (u : U) :
    payee w i = .user u ↔ royaltyTo w i = some u := by
  unfold payee royaltyTo; split_ifs <;> simp

/-- **A hard-reset user's royalties go to the developer arenas.** -/
theorem hardReset_to_arena {ι U : Type} [DecidableEq U] (w : World ι U) (u : U) (i : ι)
    (hi : (w.records i).creator = u) : payee (hardReset w u) i = .arena := by
  simp [payee, hardReset, hi]

/-- Total royalties received by `p` over the records `recs`, with amounts `amt`. -/
def received {ι U : Type} [DecidableEq U] (w : World ι U) (amt : ι → ℕ) (recs : Finset ι)
    (p : Payee U) : ℕ :=
  ∑ i ∈ recs.filter (fun i => payee w i = p), amt i

/-- **A hard reset moves exactly that user's share into the arenas.** -/
theorem hardReset_arena_gain {ι U : Type} [DecidableEq U] (w : World ι U) (amt : ι → ℕ)
    (recs : Finset ι) (u : U) :
    received (hardReset w u) amt recs .arena =
      received w amt recs .arena + received w amt recs (.user u) := by
  classical
  unfold received
  rw [← Finset.sum_union]
  · apply Finset.sum_congr _ (fun _ _ => rfl)
    ext i
    simp only [Finset.mem_filter, Finset.mem_union, payee, hardReset, Finset.mem_insert]
    by_cases hc : (w.records i).creator = u
    · simp only [hc]; by_cases hr : u ∈ w.reset <;> simp [hr]
    · by_cases hr : (w.records i).creator ∈ w.reset <;> simp [hc, hr]
  · rw [Finset.disjoint_filter]
    intro i _ h1 h2; rw [h1] at h2; cases h2

/-- **After a hard reset the user receives nothing.** -/
theorem hardReset_user_zero {ι U : Type} [DecidableEq U] (w : World ι U) (amt : ι → ℕ)
    (recs : Finset ι) (u : U) : received (hardReset w u) amt recs (.user u) = 0 := by
  unfold received
  apply Finset.sum_eq_zero
  intro i hi
  simp only [Finset.mem_filter, payee, hardReset, Finset.mem_insert] at hi
  obtain ⟨_, hi⟩ := hi
  split_ifs at hi with h
  simp_all

/-- **Other users' shares are unchanged.** -/
theorem hardReset_other_user {ι U : Type} [DecidableEq U] (w : World ι U) (amt : ι → ℕ)
    (recs : Finset ι) (u v : U) (hv : v ≠ u) :
    received (hardReset w u) amt recs (.user v) = received w amt recs (.user v) := by
  unfold received
  apply Finset.sum_congr _ (fun _ _ => rfl)
  ext i
  simp only [Finset.mem_filter, payee, hardReset, Finset.mem_insert]
  by_cases hc : (w.records i).creator = v
  · have : (w.records i).creator ≠ u := hc ▸ hv
    simp [this]
  · constructor <;> rintro ⟨h1, h2⟩ <;> refine ⟨h1, ?_⟩ <;> split_ifs at h2 ⊢ <;>
      simp_all [Payee.user.injEq]

/-! ## No auto-levelling: every skill change is locked in by safe-zone meditation -/

/-- A player's skills: the gold-locked level of each skill, and progress built up since. -/
structure Skills (S : Type) where
  locked : S → ℕ
  banked : S → ℕ

/-- One step: build progress in a skill (anywhere, even in combat), or meditate to lock in a
skill's progress. -/
inductive SkillStep (S : Type) where
  | train (s : S) (k : ℕ)
  | meditate (s : S)

/-- Apply one step in a situation. Meditation works only in a safe zone, out of combat. -/
def sstep {S : Type} [DecidableEq S] (sit : Situation) (st : Skills S) : SkillStep S → Skills S
  | .train s k => { st with banked := Function.update st.banked s (st.banked s + k) }
  | .meditate s =>
      if canMeditate sit = true then
        ⟨Function.update st.locked s (st.locked s + st.banked s), Function.update st.banked s 0⟩
      else st

/-- Play a sequence of steps, each in its own situation. -/
def srun {S : Type} [DecidableEq S] (st : Skills S) (l : List (Situation × SkillStep S)) :
    Skills S :=
  l.foldl (fun st p => sstep p.1 st p.2) st

/-- Whether a step is a meditation in a safe zone, out of combat. -/
def isSafeMeditation {S : Type} : Situation × SkillStep S → Bool
  | (sit, .meditate _) => canMeditate sit
  | _ => false

/-- **Meditation outside a safe zone, or in combat, does nothing.** -/
theorem meditate_needs_safe_zone {S : Type} [DecidableEq S] (sit : Situation) (st : Skills S)
    (s : S) (h : canMeditate sit = false) : sstep sit st (.meditate s) = st := by
  simp [sstep, h]

/-- **Meditation in a safe zone locks in that skill's progress.** -/
theorem meditate_locks_in {S : Type} [DecidableEq S] (st : Skills S) (s : S) :
    (sstep ⟨false, true⟩ st (.meditate s)).locked s = st.locked s + st.banked s ∧
      (sstep ⟨false, true⟩ st (.meditate s)).banked s = 0 := by
  simp [sstep, canMeditate]

/-- **No auto-levelling.** In any run without a safe-zone meditation, no locked skill changes. -/
theorem locked_only_by_meditation {S : Type} [DecidableEq S] (st : Skills S)
    (l : List (Situation × SkillStep S)) (h : ∀ p ∈ l, isSafeMeditation p = false) :
    (srun st l).locked = st.locked := by
  induction l generalizing st with
  | nil => rfl
  | cons p l ih =>
    simp only [srun, List.foldl_cons] at ih ⊢
    rw [ih _ (fun q hq => h q (List.mem_cons_of_mem _ hq))]
    obtain ⟨sit, step⟩ := p
    have hp := h (sit, step) List.mem_cons_self
    cases step with
    | train s k => rfl
    | meditate s =>
      simp only [isSafeMeditation] at hp
      simp [sstep, hp]

/-- Progress a step adds to skill `s`. -/
def SkillStep.gain {S : Type} [DecidableEq S] (s : S) : SkillStep S → ℕ
  | .train s' k => if s' = s then k else 0
  | .meditate _ => 0

/-- **Progress is never lost.** Each step changes locked-plus-banked progress in a skill by
exactly what that step trains. -/
theorem total_progress {S : Type} [DecidableEq S] (sit : Situation) (st : Skills S)
    (step : SkillStep S) (s : S) :
    (sstep sit st step).locked s + (sstep sit st step).banked s =
      st.locked s + st.banked s + step.gain s := by
  cases step with
  | train s' k =>
    simp only [sstep, SkillStep.gain]
    by_cases h : s' = s
    · subst h; simp; omega
    · simp [Function.update_of_ne (Ne.symm h), h]
  | meditate s' =>
    simp only [sstep, SkillStep.gain]
    split_ifs
    · by_cases h : s' = s
      · subst h; simp
      · simp [Function.update_of_ne (Ne.symm h)]
    · simp

end RoundFiveRulings
