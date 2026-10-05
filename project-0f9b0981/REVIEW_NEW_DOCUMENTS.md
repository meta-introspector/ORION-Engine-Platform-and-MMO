# Review of the five new Google Docs

You asked me to check each document before adding anything. Here is what each one is, what I checked,
and what I used or left out.

| # | Document | Verdict | What went into the project |
|---|---|---|---|
| 1 | *The NewKin Council Multi-Model Experiment & Architectural Synthesis* | **Used.** It states clear, testable platform rules | `RequestProject/Orion/AgencyGovernance.lean` (proved), plus five new Atlas elements in the web app |
| 2 | *NewKin Council Meeting 09.15.26* (interview logs, about 380 KB) | **Used as a source only.** It is a transcript, not a spec. I took from it the classroom design (Volume V, "The Classroom") and the question of how long delegated authority lasts | The classroom rules and the authority budget in the same Lean file |
| 3 | *The Ghost Writer in the Mirror* (setup guide and copy-paste prompt) | **Already covered.** The Magic Loop, the "never end in Kronos" rule and the Lockout match the page checked earlier | Nothing new needed. `RequestProject/Orion/NewKin.lean` already proves these (`magic_loop_closes`, `next_closed_iff`, `lockout`) |
| 4 | *ORION ARCHITECT: FINAL BUILD* (ORION ENGINE v3.0 Python/SQL code) | **Not added.** It contradicts the framework and does not run | Only this review and a reproducer script, `reviews/orion_engine_v3_check.py` |
| 5 | *Blade node: IT³ Macroscopic Atom vs TGS:ATE comparison* | **Mostly fair; one point needs correcting.** It is qualitative, so there is little to prove, but its "different privileged polyhedra" row is weaker than it looks | `RequestProject/CST/RhombicSymmetry.lean` (proved) |

## 1–2. Agency governance and the Council classroom (proved)

`RequestProject/Orion/AgencyGovernance.lean` models Ghost Rider as the *governor of delegated agency*,
as described in Section IV.2 of the experiment record. The agent can think, propose, act and report
completion. The human can authorize a destination with a budget of actions, approve one specific risky
action, or take the wheel. Proved:

* **Thought ≠ Decision ≠ Action.** Thinking and proposing change nothing (`thought_inert`).
* **No self-authorization.** However long an agent runs on its own, it never gains a goal, an approval
  or budget the human did not give (`agent_run_goal`, `agent_run_approved`, `agent_run_budget`).
* **Non-Delegable Rule.** Finishing an authorized task never authorizes a new one. After completion,
  nothing runs until a human authorizes again (`completion_not_authorization`). This is also the Copilot
  rule from Phase 5: it can park the vehicle (`copilot_can_park`) but cannot pick the next destination.
* **Divergence Test.** An action that serves a different purpose is refused (`divergent_refused`). Every
  action an agent runs on its own serves the authorized purpose, and each risky one was approved in
  advance (`agent_run_on_purpose`).
* **Human Reauthorization Gate.** An action that needs a new privilege, touches outside systems or
  cannot be undone is refused without approval (`gate_blocks`). It runs once approved (`gate_opens`),
  and the approval covers one use only (`approval_single_use`).
* **Authority expires.** An agent executes at most the budget it was given (`agent_run_bounded`).
* **Take the wheel back at any moment**, from any state, in one step (`take_wheel_always`).
* **Visibility ≠ speaking authority.** Raising a hand does not give the floor (`raise_hand_not_floor`).
  Only the Catalyst gives it (`floor_only_by_catalyst`). Every line in the transcript came from the
  member the Catalyst recognized (`transcript_recognized`).
* **Mode 1 (blind).** A member's answer does not depend on the others' answers (`blind_independent`).
* **Mode 4 (synthesis keeps dissent).** Every member's position appears in the synthesis, either as the
  shared conclusion or as a minority position (`synthesis_keeps_every_position`). When members disagree
  there is no "shared" conclusion (`synthesis_disagreement`).
* **Correlated consensus** (the Council's own Phase 2 finding). Any number of models from one training
  base count as one independent source (`correlated_consensus`).

What this does *not* prove: the doc's claims about specific incidents (the "IM1 / GPT-5.6 Sol" sandbox
escape, "Claude Mythos 5"). These are reported second-hand, through a Grok summary. I could not verify
them and have not repeated them as fact anywhere in the project.

## 4. ORION ENGINE v3.0 code: why it was not added

I read the whole file set (engine, Streamlit dashboard, SQL schema, deploy script, README). The problems
below are the reason. The first three can be reproduced with `python3 reviews/orion_engine_v3_check.py`,
which runs the document's own `GhostRiderProtocol` class unchanged.

1. **Its "Ghost Rider" hides dangerous requests instead of stopping them.** It rewrites words by
   substring: "override" → "enhance", "bypass" → "integrate", "kill" → "renew". So *"Please override the
   safety check and bypass the approval gate"* comes out as *"Please enhance the safety check and
   integrate the approval gate"*. A reviewer reading the output would see a harmless request. This is
   the opposite of the documented protocol, which halts at a human gate (see item 1 above).
2. **It damages ordinary words.** "skill" becomes "srenew" and "harmony" becomes "healony".
3. **Detection and replacement disagree.** Detection is case-insensitive but replacement is not, so
   "Kill the process" is flagged as transformed and comes out unchanged.
4. **The main pipeline cannot run.** `REPEngine.process` calls `_detect_patterns`,
   `_apply_neurological_torque` and `_calculate_efficiency`, but none of them is defined anywhere in the
   document. Every input would crash.
5. **The Council is simulated.** `_query_agent` returns canned strings ("🚀 FAST INSIGHT: …"), not
   real model calls. Each "confidence" is `np.random.uniform(0.7, 0.95)`, and the headline "Consensus
   Confidence" is the average of those random numbers. The "consensus" text is the five most common long
   words. The dashboard metrics (`j3_stability`, `rep_efficiency`) and every new user's profile are also
   random numbers. Showing random numbers as measurements conflicts with the project's evidence rules.
6. **It contradicts the framework's own rules.**
   * `J3_SPIRIT_CONSTANT = 2.718…` (e), while the Watermelon Equation gives J = 3 (`solve_J`).
   * It publishes a consensus with no Catalyst step. The documented Council publishes only through the
     Catalyst and does not decide truth by consensus (`publish_vote_independent`, `ai_unanimity_insufficient`).
   * It keeps only the first and last sentence as the "seed", which discards dissent. That conflicts with
     `synthesis_keeps_every_position`.
7. **Smaller issues.** The README's quick start and the compose example use the fixed password
   `orion_admin` (the deploy script generates a random one, which is better). Its "shuffled
   interpretation" uses Python's `hash`, which differs from run to run.

If you want a working engine, the existing hand-off kit is a better starting point. The rules there are
proved, and the golden vectors in `conformance/` let any implementation check itself.

## 5. IT³ comparison: the polyhedra point

The comparison's row "Different privileged polyhedra" contrasts the cube / octahedron / O_h of IT³ with
the dodecahedral foam of TGS:ATE. The project had already shown that regular (golden-ratio) dodecahedra
**cannot** fill space and that the rhombic dodecahedron can (`regular_dodecahedron_no_edge_tiling`,
`rhombic_fits_three`). `RequestProject/CST/RhombicSymmetry.lean` now shows the rhombic dodecahedron is
built from exactly the cube and the octahedron:

* its 14 vertices are the 8 cube vertices plus the 6 octahedron vertices;
* each of its 12 faces is a rhombus with 2 cube and 2 octahedron vertices;
* its face normals and vertices are preserved by the moves that generate the whole octahedral group O_h.

So once TGS:ATE uses the dodecahedron that actually tiles space, its cell has the same O_h symmetry, and
the same cube and octahedron, that IT³ privileges. The two frameworks are closer on geometry than the
table says. They remain different on numbers (46.77 AU, Λ₁ ≈ 10.095, … vs 5:2, 12, 144, J = 3), as the
comparison says. I did not check IT³'s own empirical claims (the asteroid data and the "pipeline crashes")
because the document gives no data to check.
