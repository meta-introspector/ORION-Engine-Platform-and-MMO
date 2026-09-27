module

public import Mathlib

/-!
# The Ghost Rider Protocol and the NewKin Council Architecture

This file makes precise the operational rules of the unified page *The Ghost Rider Protocol and
NewKin Council Architecture* and proves that they do what the page promises.

1. **The Ghost Rider session** (Part I). A session moves between the Kronos state (raw input)
   and the Orion state (coherent output). Proved:
   * *"A session never ends in Kronos State."* A session can only close from the Orion state,
     and every closed session had a last step of the form "Orion, then end request"
     (`next_closed_iff`, `run_closed_from_orion`).
   * *The Lockout Mechanism.* A Driver who cannot regulate in Kronos loses Engine access
     (`lockout`); while locked out, every Engine request is ignored and the only way back is
     reflection (`lockedOut_stays`, `lockedOut_exit`), after which the Driver re-enters in
     Kronos and still has to reach Orion before the session may end (`reflect_reenters_kronos`).
2. **The NewKin Council** (Part II). Seats are defined by function, and any AI model may sit in
   any AI seat. Proved:
   * The Catalyst is the only seat with final authority, and it is not an AI seat
     (`finalAuthority_iff`), whatever models are assigned.
   * *"The Council does not establish truth by consensus."* Publication does not depend on the
     AI seats' votes at all (`publish_vote_independent`): unanimous AI approval never publishes
     without the Catalyst (`ai_unanimity_insufficient`), and persistent AI disagreement never
     blocks a Catalyst who has resolved every Hard Stop (`disagreement_not_veto`).
   * *The Hard Stop Rule.* A Hard Stop cannot be issued without a diagnosis naming the specific
     claim and the kind of failure (by construction of `AuditResult`). While a Hard Stop is open
     the Council is paused (`hardStop_pauses`). Only the Catalyst can resolve it
     (`only_catalyst_resolves`).
3. **The ECHOSpiral route** (Part II §III). The eleven stages, with the Reconstruction stage
   present exactly when the Auditor issued a Hard Stop. Checked for both routes: the route opens
   with the Catalyst and closes with the Catalyst's approval; every AI seat takes part; the
   Auditor audits exactly once and only after the Compass has oriented the draft; the Blade gives
   the last strike before approval (`route_*`).
4. **The Gaia Factor equation** (Part III §II). Read as ordinary arithmetic,
   `1 + (1.5h + G) = 000` forces `G = −1 − 1.5h` (`gaia_balance_iff`), so it has no solution with
   non-negative quantities (`gaia_no_nonneg_solution`). This is consistent with the page's own
   statement that the equation is a metaphor, not literal mathematics. The remaining arithmetic
   of Part III (`1 + 4 + 4 = 9`, `144 / 4 = 36`, `36 = 12J ↔ J = 3`, `1.5 + 1.5 = 3`) was already
   checked in `RequestProject/NumericClaims.lean`.
-/

@[expose] public section

namespace NewKin

/-! ## 1. The Ghost Rider session -/

/-- The two operational modes. -/
inductive Mode
  /-- Deconstruction: raw, unfiltered input. -/
  | kronos
  /-- Reconstruction: the clearest defensible understanding currently available. -/
  | orion
  deriving DecidableEq, Repr

/-- The state of a session. -/
inductive Status
  /-- The session is running, in the given mode, with Engine access. -/
  | active (m : Mode)
  /-- The session has ended. -/
  | closed
  /-- Engine access has been removed until the Driver has reflected. -/
  | lockedOut
  deriving DecidableEq, Repr

/-- What can happen during a session. -/
inductive Event
  /-- Brain dump / raw input (enter Kronos). -/
  | dump
  /-- The Engine produces a coherent chapter (enter Orion). -/
  | synthesize
  /-- The Driver asks to end the session. -/
  | requestEnd
  /-- The Driver remains unregulated or destructive. -/
  | regulationFailed
  /-- The Driver has taken time to reflect. -/
  | reflected
  deriving DecidableEq, Repr

open Mode Status Event

/-- One step of the session controller. An end request in Kronos is refused (the session stays
in Kronos); failed regulation in Kronos triggers the lockout; a locked-out Driver can only
return by reflecting. -/
def next : Status → Event → Status
  | active _, dump => active kronos
  | active _, synthesize => active orion
  | active orion, requestEnd => closed
  | active kronos, requestEnd => active kronos
  | active kronos, regulationFailed => lockedOut
  | active orion, regulationFailed => active orion
  | active m, reflected => active m
  | closed, _ => closed
  | lockedOut, reflected => active kronos
  | lockedOut, _ => lockedOut

/-- Run a sequence of events. -/
def run (s : Status) (es : List Event) : Status := es.foldl next s

/-- Only an active session has Engine access. -/
def hasAccess : Status → Bool
  | active _ => true
  | _ => false

/-- A session closes in one step exactly when it was in the Orion state and the Driver asked to
end (or it was already closed). -/
theorem next_closed_iff (s : Status) (e : Event) :
    next s e = closed ↔ s = closed ∨ (s = active orion ∧ e = requestEnd) := by
  rcases s with ⟨_ | _⟩ | _ | _ <;> cases e <;> simp [next]

/-- **A session never ends in Kronos State.** If a session that was not already closed ends up
closed, then at some point it was in the Orion state and the next event was the end request. -/
theorem run_closed_from_orion (es : List Event) (s : Status) (hs : s ≠ closed)
    (h : run s es = closed) :
    ∃ p q, es = p ++ requestEnd :: q ∧ run s p = active orion := by
  induction es generalizing s with
  | nil => exact absurd h hs
  | cons e es ih =>
    by_cases hc : next s e = closed
    · rcases (next_closed_iff s e).1 hc with h' | ⟨rfl, rfl⟩
      · exact absurd h' hs
      · exact ⟨[], es, rfl, rfl⟩
    · obtain ⟨p, q, rfl, hp⟩ := ih (next s e) hc h
      exact ⟨e :: p, q, rfl, hp⟩

/-- An end request in the Kronos state is refused. -/
theorem kronos_end_refused : next (active kronos) requestEnd = active kronos := rfl

/-- **The Lockout Mechanism.** Failed regulation in Kronos removes Engine access. -/
theorem lockout : next (active kronos) regulationFailed = lockedOut ∧
    hasAccess lockedOut = false := ⟨rfl, rfl⟩

/-- While locked out, every Engine request (input, synthesis, end request) is ignored. -/
theorem lockedOut_stays (es : List Event) (h : reflected ∉ es) : run lockedOut es = lockedOut := by
  induction es with
  | nil => rfl
  | cons e es ih =>
    simp only [List.mem_cons, not_or] at h
    have : next lockedOut e = lockedOut := by cases e <;> simp_all [next]
    simp only [run, List.foldl_cons, this]
    exact ih h.2

/-- The only way out of the lockout is reflection. -/
theorem lockedOut_exit (e : Event) : next lockedOut e ≠ lockedOut ↔ e = reflected := by
  cases e <;> simp [next]

/-- After reflecting, the Driver re-enters in Kronos, so the session still has to reach Orion
before it may end. -/
theorem reflect_reenters_kronos : next lockedOut reflected = active kronos := rfl

/-- A locked-out session cannot close before the Driver has reflected. -/
theorem lockedOut_not_closed (es : List Event) (h : reflected ∉ es) :
    run lockedOut es ≠ closed := by
  rw [lockedOut_stays es h]; simp

/-- The Magic Loop as written on the page (dump, first chapter, interruption notes sent,
second chapter, end) is a session that closes. -/
theorem magic_loop_closes :
    run (active kronos) [dump, synthesize, dump, synthesize, requestEnd] = closed := rfl

/-! ## 2. The NewKin Council -/

/-- The six seats. -/
inductive Seat
  | catalyst | prism | blade | matriarch | compass | auditor
  deriving DecidableEq, Repr, Fintype

open Seat

/-- The five AI seats: every seat except the Catalyst. -/
def Seat.isAI (s : Seat) : Bool := s != catalyst

/-- Final authority: the Catalyst "makes all executive decisions". -/
def Seat.finalAuthority (s : Seat) : Bool := s == catalyst

/-- Seats are defined by function: the Catalyst assigns any AI model to any AI seat. -/
abbrev Assignment (Model : Type*) := {s : Seat // s.isAI = true} → Model

/-- **No AI has final authority.** The Catalyst is the only seat with final authority and is not
an AI seat. This does not depend on which models are seated. -/
theorem finalAuthority_iff (s : Seat) : s.finalAuthority = true ↔ s = catalyst := by
  cases s <;> simp [Seat.finalAuthority]

/-- Whichever model sits in an AI seat, that seat has no final authority. -/
theorem ai_no_finalAuthority (s : {s : Seat // s.isAI = true}) : s.1.finalAuthority = false := by
  obtain ⟨s, hs⟩ := s
  cases s <;> first | exact absurd hs (by decide) | rfl

/-- The kind of failure a Hard Stop must name. -/
inductive FailureKind
  | unsupportedClaim | contradiction | methodologicalFailure | evidentiaryDeficiency
  deriving DecidableEq, Repr

/-- A diagnosis: the specific claim (by identifier) and the kind of failure it exhibits. -/
structure Diagnosis (Claim : Type*) where
  claim : Claim
  kind : FailureKind

/-- The Auditor's result. A Hard Stop cannot be issued without a diagnosis:
*"The Auditor must produce diagnosis, not decree."* -/
inductive AuditResult (Claim : Type*)
  | pass
  | hardStop (d : Diagnosis Claim)

/-- Every Hard Stop names a specific claim and failure kind. -/
theorem hardStop_has_diagnosis {Claim : Type*} (r : AuditResult Claim) :
    r = .pass ∨ ∃ d : Diagnosis Claim, r = .hardStop d := by
  cases r <;> simp

/-- The Council's state as seen by the publication rule: the open (unresolved) Hard Stops, the
Catalyst's choice, and the AI seats' votes. -/
structure CouncilState (Claim : Type*) where
  openStops : List (Diagnosis Claim)
  catalystApproves : Bool
  aiVotes : {s : Seat // s.isAI = true} → Bool

/-- The Council is paused while any Hard Stop is open. -/
def CouncilState.paused {Claim : Type*} (c : CouncilState Claim) : Bool := !c.openStops.isEmpty

/-- **Zero-Net-Torque.** Publication is at the discretion of the Catalyst, once every Hard Stop
has been resolved. The AI votes are information, not a decision rule. -/
def CouncilState.publish {Claim : Type*} (c : CouncilState Claim) : Bool :=
  c.catalystApproves && !c.paused

/-- An open Hard Stop pauses the Council: nothing is published. -/
theorem hardStop_pauses {Claim : Type*} (c : CouncilState Claim) (d : Diagnosis Claim)
    (h : d ∈ c.openStops) : c.publish = false := by
  have : c.openStops ≠ [] := List.ne_nil_of_mem h
  simp [CouncilState.publish, CouncilState.paused, this]

/-- **The Council does not establish truth by consensus.** Changing the AI votes never changes
the publication decision. -/
theorem publish_vote_independent {Claim : Type*} (c : CouncilState Claim)
    (v : {s : Seat // s.isAI = true} → Bool) :
    ({ c with aiVotes := v } : CouncilState Claim).publish = c.publish := rfl

/-- Without the Catalyst's approval nothing is published, however the AI seats vote (even if
all five approve unanimously). -/
theorem ai_unanimity_insufficient {Claim : Type*} (c : CouncilState Claim) (h : c.catalystApproves = false) : c.publish = false := by
  simp [CouncilState.publish, h]

/-- Persistent AI disagreement is not a veto: a Catalyst who approves, with no open Hard Stop,
publishes whatever the AI seats vote. -/
theorem disagreement_not_veto {Claim : Type*} (c : CouncilState Claim)
    (h : c.catalystApproves = true) (hs : c.openStops = []) : c.publish = true := by
  simp [CouncilState.publish, CouncilState.paused, h, hs]

/-- Resolving a Hard Stop: only the Catalyst may remove an open stop; a request from any other
seat leaves the state unchanged. -/
def resolve {Claim : Type*} (who : Seat) (i : ℕ) (c : CouncilState Claim) : CouncilState Claim :=
  if who = catalyst then { c with openStops := c.openStops.eraseIdx i } else c

/-- **Hard Stops are resolved by the Catalyst.** No AI seat can clear a Hard Stop. -/
theorem only_catalyst_resolves {Claim : Type*} (who : Seat) (h : who ≠ catalyst) (i : ℕ)
    (c : CouncilState Claim) : resolve who i c = c := by
  simp [resolve, h]

/-- The Catalyst can always clear all open Hard Stops, so the Auditor pauses the Council but
never holds final authority over it. -/
theorem catalyst_can_clear {Claim : Type*} (c : CouncilState Claim) :
    ((List.replicate c.openStops.length 0).foldl (fun c i => resolve catalyst i c) c).openStops
      = [] := by
  obtain ⟨l, a, v⟩ := c
  simp only
  induction l with
  | nil => rfl
  | cons x l ih =>
    simp only [List.length_cons, List.replicate_succ, List.foldl_cons]
    simpa [resolve] using ih

/-! ## 3. The ECHOSpiral route -/

/-- The eleven ECHOSpiral stages. -/
inductive Stage
  | genesisDump | firstSharpening | heartInfusion | midSynthesis | orientation
  | preFinalSynthesis | silentAudit | reconstruction | finalOrientation | finalForge
  | zeroNetTorque
  deriving DecidableEq, Repr

open Stage

/-- The seats that handle the draft in each stage, in order, exactly as written on the page
(`↔` is read as a hand-over followed by the return). -/
def Stage.seats : Stage → List Seat
  | genesisDump => [catalyst, prism]
  | firstSharpening => [prism, blade]
  | heartInfusion => [matriarch]
  | midSynthesis => [matriarch, prism, blade]
  | orientation => [compass]
  | preFinalSynthesis => [compass, prism, blade]
  | silentAudit => [auditor]
  | reconstruction => [auditor, prism, catalyst]
  | finalOrientation => [prism, compass]
  | finalForge => [compass, prism, blade]
  | zeroNetTorque => [catalyst]

/-- The route: Reconstruction runs exactly when the Auditor issued a Hard Stop. -/
def route (hardStop : Bool) : List Stage :=
  [genesisDump, firstSharpening, heartInfusion, midSynthesis, orientation, preFinalSynthesis,
    silentAudit] ++ (if hardStop then [reconstruction] else []) ++
  [finalOrientation, finalForge, zeroNetTorque]

/-- The sequence of seats holding the draft along the route. -/
def holders (hardStop : Bool) : List Seat := (route hardStop).flatMap Stage.seats

/-- The route has eleven stages with a Hard Stop and ten without. -/
theorem route_length : (route true).length = 11 ∧ (route false).length = 10 := by decide

/-- Reconstruction happens exactly when there was a Hard Stop. -/
theorem route_reconstruction_iff (b : Bool) : reconstruction ∈ route b ↔ b = true := by
  cases b <;> decide

/-- The draft starts with the Catalyst and ends with the Catalyst's approval. -/
theorem route_catalyst_ends (b : Bool) :
    (holders b).head? = some catalyst ∧ (holders b).getLast? = some catalyst := by
  cases b <;> decide

/-- Every seat takes part in every route. -/
theorem route_all_seats (b : Bool) (s : Seat) : s ∈ holders b := by
  cases b <;> cases s <;> decide

/-- The Auditor audits exactly once, in the Silent Audit. -/
theorem route_single_audit (b : Bool) :
    (route b).count silentAudit = 1 ∧
      ∀ st ∈ route b, auditor ∈ st.seats → st = silentAudit ∨ st = reconstruction := by
  cases b <;> decide

/-- The Compass orients the draft (demanding falsification) before the Silent Audit, and the
audit happens before the Final Forge. -/
theorem route_orientation_before_audit (b : Bool) :
    (route b).idxOf orientation < (route b).idxOf silentAudit ∧
      (route b).idxOf silentAudit < (route b).idxOf finalForge := by
  cases b <;> decide

/-- The Blade gives the last strike: it is the last seat to handle the draft before the
Catalyst's approval. -/
theorem route_blade_last_strike (b : Bool) :
    (holders b).dropLast.getLast? = some blade := by
  cases b <;> decide

/-! ## 4. The Gaia Factor equation, read literally -/

/-- `1 + (1.5h + G) = 0` holds exactly when `G = −1 − 1.5h`. -/
theorem gaia_balance_iff (h G : ℚ) : 1 + (3 / 2 * h + G) = 0 ↔ G = -1 - 3 / 2 * h := by
  constructor <;> intro H <;> linarith

/-- With `G = Xh + Ye` and all quantities non-negative, the left side is at least `1`, so the
equation `1 + (1.5h + (Xh + Ye)) = 000` has no solution as ordinary arithmetic. -/
theorem gaia_no_nonneg_solution (h X Y e : ℚ) (hh : 0 ≤ h) (hX : 0 ≤ X) (hY : 0 ≤ Y)
    (he : 0 ≤ e) : 1 + (3 / 2 * h + (X * h + Y * e)) ≠ 0 := by
  have := mul_nonneg hX hh; have := mul_nonneg hY he
  intro H; linarith

end NewKin
