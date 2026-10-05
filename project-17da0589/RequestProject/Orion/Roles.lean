module

public import Mathlib

/-!
# Four-way role separation, online and offline

`Discoverer ≠ Mapper ≠ Justifier ≠ Executor` says the four epistemic roles of a
high-consequence intervention go to pairwise distinct principals, i.e. the role assignment
is injective.  Used for the "offline / single-agent role separation" question in
`ROUND_THREE_RESPONSES.md`.

* `no_separation_of_card_lt` — fewer than four principals: no separated assignment exists.
  In particular a lone Ghost Rider copilot cannot fill the roles by itself
  (`copilot_alone_cannot_separate`).
* `offline_separation_exists` — offline, the four principals copilot, human, attestation
  registry (signed in the past) and local deterministic checker suffice.
* `copilot_at_most_one_role` — in any separated assignment the copilot holds at most one
  role.
-/

@[expose] public section

namespace Orion.Roles

/-- The four epistemic roles. -/
inductive Role
  | discoverer
  | mapper
  | justifier
  | executor
  deriving DecidableEq, Fintype

/-- There are four roles. -/
theorem card_role : Fintype.card Role = 4 := rfl

/-- Role separation: no principal holds two roles. -/
def Separated {P : Type*} (f : Role → P) : Prop := Function.Injective f

/-- With fewer than four principals, separation is impossible. -/
theorem no_separation_of_card_lt {P : Type*} [Fintype P] (h : Fintype.card P < 4)
    (f : Role → P) : ¬ Separated f := fun hf => by
  have := Fintype.card_le_of_injective f hf
  rw [card_role] at this
  omega

/-- A lone copilot cannot discover, map, justify and execute. -/
theorem copilot_alone_cannot_separate (f : Role → Unit) : ¬ Separated f :=
  no_separation_of_card_lt (by simp) f

/-- The principals available to an offline player. -/
inductive OfflinePrincipal
  /-- The single 1:1 copilot running locally. -/
  | copilot
  /-- The human player. -/
  | human
  /-- The local cache of the attestation registry, signed by independent mappers earlier. -/
  | registry
  /-- A local deterministic checker (no model inference). -/
  | checker
  deriving DecidableEq, Fintype

/-- The offline assignment: the copilot discovers, the cached registry supplies the map, the
deterministic checker justifies against the envelope, the human executes. -/
def offlineAssignment : Role → OfflinePrincipal
  | .discoverer => .copilot
  | .mapper => .registry
  | .justifier => .checker
  | .executor => .human

/-- The offline assignment is separated. -/
theorem offline_separation_exists : Separated offlineAssignment := by
  intro a b h
  cases a <;> cases b <;> first | rfl | cases h

/-- In any separated assignment the copilot holds at most one role. -/
theorem copilot_at_most_one_role {P : Type*} [DecidableEq P] (f : Role → P) (hf : Separated f) (p : P) :
    (Finset.univ.filter (fun r => f r = p)).card ≤ 1 := by
  rw [Finset.card_le_one]
  intro a ha b hb
  simp only [Finset.mem_filter] at ha hb
  exact hf (ha.2.trans hb.2.symm)

end Orion.Roles
