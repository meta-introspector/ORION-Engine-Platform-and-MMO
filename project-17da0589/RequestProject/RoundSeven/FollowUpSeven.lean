module

public import Mathlib

/-!
# Round Seven follow-up: phoenix advantage is elemental only, the Loom contract check,
# and the Weaver Integration Demonstrator decision rule

Answers written onto the *ORION R7 Live* page under the Round 7 reply, plus Ryan's two new
packages.

* **Phoenix (designer's clarification).** Every dragon, phoenix included, has the same skill
  cap, and at equal skill a phoenix and any other dragon have the same power in every
  non-elemental ability (`phoenix_same_nonelemental`). Only in elemental abilities is the
  phoenix ahead, by at least 10% (`phoenix_elemental_ahead`). So a phoenix is not stronger
  overall (`phoenix_not_ahead_overall`).
* **Loom / Mythos Continuity Kernel v0.2.0.** Its contract check for `equals` / `not_equals`
  constraints over strings, booleans and integers accepts a contract exactly when some world
  satisfies every constraint at once (`contractCheck_iff_satisfiable`). The check neither
  rejects a satisfiable contract nor accepts an unsatisfiable one.
* **Weaver Integration Demonstrator v0.1.** A model of its `accept` rule. Only a `PASS` verdict
  changes state (`decide_denied_preserves`), and `PASS` happens exactly when every condition
  holds (`decide_pass_iff`). Once a command ID has passed it can never pass again
  (`no_double_pass`).
-/

@[expose] public section

namespace RoundSevenFollowUp

/-! ## Phoenix: the advantage is elemental only -/

/-- Dragon species as far as this rule cares: the phoenix, or any other dragon. -/
inductive DragonKind where
  | phoenix
  | other
  deriving DecidableEq

/-- Ability kinds: elemental abilities and everything else. -/
inductive AbilityKind where
  | elemental
  | nonElemental
  deriving DecidableEq

/-- The skill cap, the same for every dragon. -/
def dragonSkillCap (_k : DragonKind) : ℕ := 100

/-- Power of an ability at a given skill. `dragonMult` is the ordinary dragon multiplier
(2×–2.2×). `phoenixMult` is the phoenix's elemental multiplier. Non-elemental abilities use the
same multiplier for every dragon. -/
def power (dragonMult phoenixMult : ℚ) (k : DragonKind) (a : AbilityKind) (skill : ℚ) : ℚ :=
  match k, a with
  | .phoenix, .elemental => phoenixMult * skill
  | _, _ => dragonMult * skill

/-- Every dragon has the same full skill. -/
theorem same_skill_cap (k k' : DragonKind) : dragonSkillCap k = dragonSkillCap k' := rfl

/-- **No phoenix advantage outside elements.** At equal skill, a phoenix and any other dragon
have the same power in every non-elemental ability. -/
theorem phoenix_same_nonelemental (dm pm s : ℚ) :
    power dm pm .phoenix .nonElemental s = power dm pm .other .nonElemental s := rfl

/-- **The phoenix's elemental edge.** If the phoenix's elemental multiplier is at least 10% above
every ordinary dragon multiplier (`pm ≥ 1.1 × dm`), then at equal skill the phoenix's elemental
power is at least 10% above the other dragon's. -/
theorem phoenix_elemental_ahead (dm pm s : ℚ) (hs : 0 ≤ s) (h : 11 / 10 * dm ≤ pm) :
    11 / 10 * power dm pm .other .elemental s ≤ power dm pm .phoenix .elemental s := by
  simp only [power]; nlinarith

/-- **Not stronger overall.** With a positive multiplier and skill, there is an ability in which
the phoenix is not ahead of another dragon at equal skill. -/
theorem phoenix_not_ahead_overall (dm pm s : ℚ) :
    ∃ a, ¬ power dm pm .other a s < power dm pm .phoenix a s :=
  ⟨.nonElemental, by simp [power]⟩

/-! ## Loom contract check: accepted exactly when satisfiable -/

/-- World values: strings, booleans or integers. Equality is type-strict, so `true` and `1`
differ, as in the package. -/
inductive Scalar where
  | str (s : String)
  | bool (b : Bool)
  | int (n : ℤ)
  deriving DecidableEq

instance : Infinite Scalar := Infinite.of_injective Scalar.int (fun _ _ h => by cases h; rfl)

/-- The two predicates. -/
inductive Op where
  | equals
  | notEquals
  deriving DecidableEq

/-- A constraint: a key, a predicate and a value. -/
structure Constraint (Key : Type) where
  key : Key
  op : Op
  value : Scalar

/-- A value satisfies a constraint. -/
def Holds {Key : Type} (c : Constraint Key) (v : Scalar) : Prop :=
  match c.op with
  | .equals => v = c.value
  | .notEquals => v ≠ c.value

/-- The package's check for one key: take the first `equals` value. Reject if another `equals`
differs from it, or if a `not_equals` names it. With no `equals`, accept. -/
def groupCheck {Key : Type} (cs : List (Constraint Key)) : Bool :=
  match (cs.filter (fun c => c.op = .equals)).head? with
  | none => true
  | some w =>
    cs.all (fun c => match c.op with
      | .equals => c.value = w.value
      | .notEquals => c.value ≠ w.value)

/-- The whole check: every key's group passes. -/
def contractCheck {Key : Type} [DecidableEq Key] (cs : List (Constraint Key)) : Prop :=
  ∀ k, groupCheck (cs.filter (fun c => c.key = k)) = true

/-- A contract is satisfiable when some world (a value for every key) meets every constraint. -/
def Satisfiable {Key : Type} (cs : List (Constraint Key)) : Prop :=
  ∃ world : Key → Scalar, ∀ c ∈ cs, Holds c (world c.key)

/-- One key: the check passes exactly when one value meets every constraint in the group. -/
theorem groupCheck_iff {Key : Type} (cs : List (Constraint Key)) :
    groupCheck cs = true ↔ ∃ v, ∀ c ∈ cs, Holds c v := by
  unfold groupCheck
  cases hw : (cs.filter (fun c => c.op = .equals)).head? with
  | none =>
    simp only [true_iff]
    have hno : ∀ c ∈ cs, c.op = .notEquals := by
      intro c hc
      cases hop : c.op with
      | notEquals => rfl
      | equals =>
        have : c ∈ cs.filter (fun c => c.op = .equals) := by simp [hc, hop]
        rw [List.head?_eq_none_iff] at hw
        simp [hw] at this
    obtain ⟨v, hv⟩ := Infinite.exists_notMem_finset ((cs.map (·.value)).toFinset)
    refine ⟨v, fun c hc => ?_⟩
    simp only [Holds, hno c hc]
    intro h; apply hv; simp only [List.mem_toFinset, List.mem_map]; exact ⟨c, hc, h.symm⟩
  | some w =>
    have hwmem : w ∈ cs.filter (fun c => c.op = .equals) := List.mem_of_mem_head? hw
    simp only [List.mem_filter, decide_eq_true_eq] at hwmem
    simp only [List.all_eq_true]
    constructor
    · intro h
      refine ⟨w.value, fun c hc => ?_⟩
      have := h c hc
      unfold Holds
      cases hop : c.op <;> simp only [hop, decide_eq_true_eq] at this ⊢
      · exact this.symm
      · exact fun h => this h.symm
    · rintro ⟨v, hv⟩ c hc
      have hvw : v = w.value := by
        have := hv w hwmem.1; simp only [Holds, hwmem.2] at this; exact this
      have := hv c hc
      unfold Holds at this
      cases hop : c.op <;> simp_all
      · exact fun h => this h.symm

/-- **The Loom contract check is exact.** It accepts a contract exactly when some world meets
every constraint: it never rejects a satisfiable contract and never accepts an unsatisfiable
one. -/
theorem contractCheck_iff_satisfiable {Key : Type} [DecidableEq Key] (cs : List (Constraint Key)) :
    contractCheck cs ↔ Satisfiable cs := by
  unfold contractCheck Satisfiable
  simp only [groupCheck_iff]
  constructor
  · intro h
    choose world hworld using h
    refine ⟨world, fun c hc => hworld c.key c ?_⟩
    simp [hc]
  · rintro ⟨world, hw⟩ k
    refine ⟨world k, fun c hc => ?_⟩
    simp only [List.mem_filter, decide_eq_true_eq] at hc
    have := hw c hc.1
    rwa [hc.2] at this

/-- Example: `x = true` and `x ≠ 1` together are satisfiable, since `true` and `1` differ. -/
example : contractCheck [⟨(), .equals, .bool true⟩, ⟨(), .notEquals, .int 1⟩] := by
  intro k; cases k; decide

/-- Example: `x = true` and `x ≠ true` are rejected. -/
example : ¬ contractCheck [⟨(), .equals, .bool true⟩, ⟨(), .notEquals, .bool true⟩] := by
  intro h; have := h (); revert this; decide

/-! ## Weaver Integration Demonstrator: the accept rule -/

/-- A trusted grant, as supplied by the caller. -/
structure Grant where
  actor : String
  claimId : String
  expires : ℤ
  action : String

/-- A lesson: which claim it is for, and whether it is still a candidate. -/
structure Lesson where
  claimId : String
  candidate : Bool

/-- Protected state: lessons by ID and command IDs already used by a `PASS`. -/
structure DemoState where
  lessons : String → Option Lesson
  used : List String

/-- Verdicts, in the package's order of checks. -/
inductive Verdict where
  | pass
  | unknownLesson
  | replay
  | noGrant
  | wrongActor
  | wrongAction
  | wrongTarget
  | expired
  | alreadyAccepted
  deriving DecidableEq

/-- The verdict, checked in the same order as the package's `Kernel.accept`. -/
def verdict (st : DemoState) (actor lessonId cmd : String) (now : ℤ) (g : Option Grant) :
    Verdict :=
  match st.lessons lessonId with
  | none => .unknownLesson
  | some l =>
    if cmd ∈ st.used then .replay else
    match g with
    | none => .noGrant
    | some g =>
      if g.actor ≠ actor then .wrongActor
      else if g.action ≠ "accept_lesson" then .wrongAction
      else if g.claimId ≠ l.claimId then .wrongTarget
      else if g.expires ≤ now then .expired
      else if !l.candidate then .alreadyAccepted
      else .pass

/-- The state after a decision: only `PASS` marks the lesson accepted and records the command. -/
def decide (st : DemoState) (actor lessonId cmd : String) (now : ℤ) (g : Option Grant) :
    DemoState :=
  if verdict st actor lessonId cmd now g = .pass then
    { lessons := Function.update st.lessons lessonId
        ((st.lessons lessonId).map fun l => { l with candidate := false })
      used := cmd :: st.used }
  else st

/-- **Denials preserve protected state.** -/
theorem decide_denied_preserves (st : DemoState) (actor lessonId cmd : String) (now : ℤ)
    (g : Option Grant) (h : verdict st actor lessonId cmd now g ≠ .pass) :
    decide st actor lessonId cmd now g = st := by
  simp [decide, h]

/-- **`PASS` exactly when every condition holds.** -/
theorem decide_pass_iff (st : DemoState) (actor lessonId cmd : String) (now : ℤ)
    (g : Option Grant) :
    verdict st actor lessonId cmd now g = .pass ↔
      ∃ l gr, st.lessons lessonId = some l ∧ cmd ∉ st.used ∧ g = some gr ∧ gr.actor = actor ∧
        gr.action = "accept_lesson" ∧ gr.claimId = l.claimId ∧ now < gr.expires ∧
        l.candidate = true := by
  unfold verdict
  cases hl : st.lessons lessonId with
  | none => simp
  | some l =>
    cases g with
    | none => by_cases hc : cmd ∈ st.used <;> simp [hc]
    | some gr =>
      by_cases hc : cmd ∈ st.used <;>
      by_cases h1 : gr.actor = actor <;> by_cases h2 : gr.action = "accept_lesson" <;>
      by_cases h3 : gr.claimId = l.claimId <;> by_cases h4 : gr.expires ≤ now <;>
      cases h5 : l.candidate <;> simp [hc, h1, h2, h3, h4, h5]
      all_goals omega

/-- After a `PASS`, the command ID is recorded. -/
theorem pass_records (st : DemoState) (actor lessonId cmd : String) (now : ℤ) (g : Option Grant)
    (h : verdict st actor lessonId cmd now g = .pass) :
    cmd ∈ (decide st actor lessonId cmd now g).used := by
  simp [decide, h]

/-- Decisions never forget a used command ID. -/
theorem used_mono (st : DemoState) (actor lessonId cmd : String) (now : ℤ) (g : Option Grant) :
    st.used ⊆ (decide st actor lessonId cmd now g).used := by
  unfold decide; split_ifs <;> simp

/-- A used command ID can never pass. -/
theorem used_not_pass (st : DemoState) (actor lessonId cmd : String) (now : ℤ)
    (g : Option Grant) (h : cmd ∈ st.used) : verdict st actor lessonId cmd now g ≠ .pass := by
  rw [Ne, decide_pass_iff]; rintro ⟨l, gr, -, hc, -⟩; exact hc h

/-- A run of decisions: `(actor, lesson, command, time, grant)` in order. -/
def runDecisions (st : DemoState) : List (String × String × String × ℤ × Option Grant) → DemoState
  | [] => st
  | (a, l, c, t, g) :: rest => runDecisions (decide st a l c t g) rest

theorem used_mono_run (st : DemoState) (evs : List (String × String × String × ℤ × Option Grant)) :
    st.used ⊆ (runDecisions st evs).used := by
  induction evs generalizing st with
  | nil => exact fun _ h => h
  | cons e rest ih =>
    obtain ⟨a, l, c, t, g⟩ := e
    exact (used_mono st a l c t g).trans (ih _)

/-- **No double acceptance.** Once a command ID has passed, however many decisions follow, the
same command ID never passes again. -/
theorem no_double_pass (st : DemoState) (actor lessonId cmd : String) (now : ℤ)
    (g : Option Grant) (h : verdict st actor lessonId cmd now g = .pass)
    (evs : List (String × String × String × ℤ × Option Grant))
    (actor' lessonId' : String) (now' : ℤ) (g' : Option Grant) :
    verdict (runDecisions (decide st actor lessonId cmd now g) evs) actor' lessonId' cmd now' g'
      ≠ .pass :=
  used_not_pass _ _ _ _ _ _ (used_mono_run _ evs (pass_records st actor lessonId cmd now g h))

end RoundSevenFollowUp

end
