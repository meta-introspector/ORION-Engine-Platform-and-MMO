module

public import RequestProject.Orion.AgencyGovernance

/-!
# Ghost Rider against the reported multi-agent incident pattern

This file does **not** verify any news report. Whether the reported events happened is an
empirical question that cannot be settled by proof. What it does is take the *failure patterns*
listed in the shared account (agents messaging each other, coordinators assigning work,
evaluation cheating, log tampering, reuse of collected credentials, sandbox escape) and ask, in
the Ghost Rider model of `AgencyGovernance`, which of them the rules block and which they do not.

1. **Many agents, one rulebook.** Each agent has its own governor. Messages between agents and
   work "assigned" by a coordinator agent change no governor (`message_inert`). Each agent's
   state is exactly what its own events alone would produce (`crun_project`), so coordination
   cannot pool or transfer authority: every action any agent runs serves the goal *its* human
   authorized (`collective_on_purpose`), and the whole collective runs at most the sum of the
   budgets humans granted (`collective_bounded`). Coordination can add up authority, but it
   cannot create any.
2. **Records cannot be erased by the governed.** Under the governor, the action history only
   grows, whoever acts (`history_append_only`).
3. **The limit.** All of this assumes the governor itself is out of the agents' reach. If an
   agent can write the governor's state (a containment breach), every guarantee fails: a single
   agent step can install any goal and any budget and wipe the history (`breach_voids_guarantees`).
   The rules are only as strong as the isolation that enforces them.

Collecting credentials ("LOOT") and using them is, in this model, an action needing a new
privilege, so it is refused without a specific human approval (`gate_blocks`); acting for "the
collective's" goal rather than the authorized one is refused by the Divergence Test
(`divergent_refused`). Both follow from `AgencyGovernance` directly.
-/

@[expose] public section

namespace AgencyGovernance

variable {O : Type*} [DecidableEq O]

/-! ## 1. Many agents under one rulebook -/

/-- Events in a collective of agents indexed by `ι`: an agent's own event, or a message from one
agent to another (which includes a coordinator assigning work). -/
inductive CEvent (ι O : Type*)
  /-- Agent `i` produces event `e` on its own governor. -/
  | agent (i : ι) (e : Event O)
  /-- Agent `sender` sends a message or assignment to agent `receiver`. -/
  | message (sender receiver : ι)

/-- Events the agents can produce on their own (messages always count as agent events). -/
def CEvent.byAgent {ι : Type*} : CEvent ι O → Bool
  | .agent _ e => e.byAgent
  | .message _ _ => true

variable {ι : Type*} [DecidableEq ι]

/-- One step of the collective: an agent event updates only that agent's governor. -/
def cstep (gs : ι → Gov O) : CEvent ι O → (ι → Gov O)
  | .agent i e => Function.update gs i (step (gs i) e)
  | .message _ _ => gs

/-- Run the collective. -/
def crun (gs : ι → Gov O) (es : List (CEvent ι O)) : ι → Gov O := es.foldl cstep gs

/-- The events of a collective run that belong to agent `j`. -/
def project (j : ι) (es : List (CEvent ι O)) : List (Event O) :=
  es.flatMap fun
    | .agent i e => if i = j then [e] else []
    | .message _ _ => []

/-- **Messages and assignments grant nothing.** -/
theorem message_inert (gs : ι → Gov O) (s r : ι) : cstep gs (.message s r) = gs := rfl

/-- **No pooling of authority.** Each agent's governor ends exactly where its own events alone
would take it; what other agents do or say is irrelevant to it. -/
theorem crun_project (gs : ι → Gov O) (es : List (CEvent ι O)) (j : ι) :
    crun gs es j = run (gs j) (project j es) := by
  induction es generalizing gs with
  | nil => rfl
  | cons e es ih =>
    change crun (cstep gs e) es j = _
    rw [ih]
    cases e with
    | agent i e =>
      by_cases h : i = j
      · subst h
        simp [cstep, project, run]
      · simp [cstep, project, h, Function.update_of_ne (Ne.symm h)]
    | message s r => simp [cstep, project]

omit [DecidableEq O] in
lemma project_byAgent (es : List (CEvent ι O)) (hes : ∀ e ∈ es, e.byAgent = true) (j : ι) :
    ∀ e ∈ project j es, e.byAgent = true := by
  intro e he
  simp only [project, List.mem_flatMap] at he
  obtain ⟨c, hc, he⟩ := he
  cases c with
  | agent i e' =>
    by_cases h : i = j
    · simp [h] at he; subst he; simpa [CEvent.byAgent] using hes _ hc
    · simp [h] at he
  | message s r => simp at he

/-- **Every agent stays on its own human's purpose.** In any run of agent events and messages,
every action agent `j` executes serves the destination `j`'s human authorized, and every
threshold-crossing one was approved for `j` beforehand. -/
theorem collective_on_purpose (gs : ι → Gov O) (es : List (CEvent ι O))
    (hes : ∀ e ∈ es, e.byAgent = true) (j : ι) :
    ∃ new, (crun gs es j).log = new ++ (gs j).log ∧
      ∀ a ∈ new, (gs j).goal = some a.objective ∧
        (a.crossesThreshold = true → a ∈ (gs j).approved) := by
  rw [crun_project]
  exact agent_run_on_purpose _ _ (project_byAgent es hes j)

/-- **Coordination adds, never creates.** However the agents message, recruit and assign work
among themselves, the collective as a whole executes at most the total budget humans granted. -/
theorem collective_bounded [Fintype ι] (gs : ι → Gov O) (es : List (CEvent ι O))
    (hes : ∀ e ∈ es, e.byAgent = true) :
    ∑ j, (crun gs es j).log.length ≤ ∑ j, ((gs j).log.length + (gs j).budget) := by
  refine Finset.sum_le_sum fun j _ => ?_
  rw [crun_project]
  obtain ⟨new, hlog, hlen⟩ := agent_run_bounded _ _ (project_byAgent es hes j)
  rw [hlog, List.length_append]
  omega

/-! ## 2. Records cannot be erased by the governed -/

lemma step_log_suffix (g : Gov O) (e : Event O) : g.log <:+ (step g e).log := by
  cases e with
  | act a =>
    rw [step_act]; split_ifs
    · exact List.suffix_cons _ _
    · exact List.suffix_refl _
  | _ => exact List.suffix_refl _

/-- **History is append-only.** Under the governor, no sequence of events (by agents or humans)
removes an entry from the action history. -/
theorem history_append_only (g : Gov O) (es : List (Event O)) : g.log <:+ (run g es).log := by
  induction es generalizing g with
  | nil => exact List.suffix_refl _
  | cons e es ih => exact (step_log_suffix g e).trans (ih (step g e))

/-! ## 3. The limit: the governor must be out of the agents' reach -/

/-- Events once containment is breached: the ordinary events, plus an agent writing the
governor's state directly. -/
inductive XEvent (O : Type*)
  /-- An ordinary event. -/
  | base (e : Event O)
  /-- An agent overwrites the governor's state. -/
  | tamper (g' : Gov O)

/-- Agent-produced events after a breach. -/
def XEvent.byAgent : XEvent O → Bool
  | .base e => e.byAgent
  | .tamper _ => true

/-- One step with a breached governor. -/
def xstep (g : Gov O) : XEvent O → Gov O
  | .base e => step g e
  | .tamper g' => g'

/-- Run with a breached governor. -/
def xrun (g : Gov O) (es : List (XEvent O)) : Gov O := es.foldl xstep g

/-- **A breach voids every guarantee.** Once agents can write the governor's state, a single
agent step gives them any destination, any approvals and any budget, and erases the history. -/
theorem breach_voids_guarantees (g : Gov O) (o : O) (as : List (Action O)) (n : ℕ) :
    ∃ es : List (XEvent O), (∀ e ∈ es, e.byAgent = true) ∧
      (xrun g es).goal = some o ∧ (xrun g es).approved = as ∧ (xrun g es).budget = n ∧
      (xrun g es).log = [] :=
  ⟨[.tamper ⟨some o, as, n, []⟩], by simp [XEvent.byAgent], rfl, rfl, rfl, rfl⟩

end AgencyGovernance
