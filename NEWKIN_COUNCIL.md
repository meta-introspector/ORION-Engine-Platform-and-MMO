# The Ghost Rider Protocol and NewKin Council Architecture: what was checked

Source: the TGS:ATE page *The Ghost Rider Protocol and NewKin Council Architecture* (the unified
text that supersedes the earlier Ghost Rider Protocol, NewKin Council Manifesto and Watermelon
Equation pages).

Lean file: `RequestProject/Orion/NewKin.lean`. It builds with no `sorry` and uses only Lean's
standard axioms.

Most of the page is philosophy, psychology and metaphor (the Governor as a mirror, the Black Hole
Player Lobby, the Permission Slips, Liquid Crystal Theory, the 3 GHz analogy). The page itself says
the Watermelon Equation is not a literal equation. Those parts make no claim that can be proved or
disproved, so they were not formalised. What *was* formalised is the operational part: the rules
a piece of software (or a game) would actually have to follow.

## 1. The Ghost Rider session (Part I)

A session is a small state machine: *active in Kronos*, *active in Orion*, *closed*, or
*locked out*. Events are: brain dump, synthesis (a chapter is produced), end request, failed
regulation, and reflection.

| Page rule | What is proved | Lean name |
|---|---|---|
| "A session never ends in Kronos State." | A session can close only from Orion. Every closed session contains a moment where it was in Orion and the next event was the end request. An end request in Kronos is refused. | `next_closed_iff`, `run_closed_from_orion`, `kronos_end_refused` |
| The Lockout Mechanism | Failed regulation in Kronos removes Engine access. While locked out, all requests are ignored and the session cannot close. The only way out is reflection. | `lockout`, `lockedOut_stays`, `lockedOut_not_closed`, `lockedOut_exit` |
| "…until they have had time to reflect" | After reflecting, the Driver comes back in Kronos, so they still have to reach Orion before the session can end. | `reflect_reenters_kronos` |
| The Magic Loop | The loop as written (dump → chapter 1 → notes → chapter 2 → end) is a valid session that closes. | `magic_loop_closes` |

**Design note.** Software can refuse to *close* a session in Kronos, but a real person can always
walk away (close the tab, lose power). The page doesn't say what happens then. A platform needs a
rule for abandoned sessions, for example "an abandoned Kronos session resumes in Kronos next time".
That fits the proved rules, because it never counts as an ending.

## 2. The NewKin Council (Part II)

Seats: Catalyst (human), Prism, Blade, Matriarch, Compass, Auditor. Any AI model can sit in any AI
seat: the seats are defined by function.

| Page rule | What is proved | Lean name |
|---|---|---|
| "No AI on this Council is granted final authority… The Catalyst makes all executive decisions." | The Catalyst is the only seat with final authority, whatever models are seated. | `finalAuthority_iff`, `ai_no_finalAuthority` |
| "The Council does not establish truth by consensus." | Changing the AI votes never changes whether something is published. Without the Catalyst nothing is published, even if all five AIs agree. Persistent AI disagreement does not block a Catalyst who has resolved every Hard Stop. | `publish_vote_independent`, `ai_unanimity_insufficient`, `disagreement_not_veto` |
| "The Auditor must produce diagnosis, not decree." | A Hard Stop *cannot be represented* without a diagnosis naming the specific claim and one of the four failure kinds on the page (unsupported claim, contradiction, methodological failure, evidentiary deficiency). | `AuditResult`, `hardStop_has_diagnosis` |
| "If the Auditor issues a Hard Stop, the Council pauses." | Nothing is published while any Hard Stop is open. | `hardStop_pauses` |
| "Hard Stops are resolved by the Catalyst." | No AI seat can clear a Hard Stop. The Catalyst can always clear them all, so the Auditor can pause the Council but never overrule the Catalyst. | `only_catalyst_resolves`, `catalyst_can_clear` |

## 3. The ECHOSpiral route (Part II §III)

The eleven stages are encoded with exactly the seats written on the page for each one. The
Reconstruction stage runs only after a Hard Stop. Checked for both routes (with and without a Hard
Stop):

* the route has 11 stages with a Hard Stop and 10 without (`route_length`), and Reconstruction
  appears exactly when there was a Hard Stop (`route_reconstruction_iff`);
* the draft starts with the Catalyst and ends with the Catalyst's approval (Zero-Net-Torque)
  (`route_catalyst_ends`);
* all six seats take part (`route_all_seats`);
* the Auditor audits exactly once and appears nowhere else except in Reconstruction ("operates
  outside the primary loop") (`route_single_audit`);
* the Compass orients the draft before the Silent Audit, and the audit comes before the Final
  Forge (`route_orientation_before_audit`);
* the Blade is the last seat to handle the draft before approval ("absolute strike")
  (`route_blade_last_strike`).

## 4. The Watermelon Equation numbers (Part III)

* `1 + 4 + 4 = 9`, `144 / 4 = 36`, `36 = 12 × J` exactly when `J = 3`, and `1.5 + 1.5 = 3` were
  already checked in `RequestProject/NumericClaims.lean`. They are correct arithmetic. As the page
  itself says, the choice of `J` is an assignment, not a derivation.
* **The Gaia Factor equation** `1 + (1.5h + (Xh + Ye = G)) = 000`: read as ordinary arithmetic it
  requires `G = −1 − 1.5h` (`gaia_balance_iff`). With non-negative quantities there is no solution,
  because the left side is always at least 1 (`gaia_no_nonneg_solution`). The nested `= G` inside
  the sum is also not well-formed notation. This is consistent with the page's own statement that
  the equation is symbolic; it just confirms it can't be read literally.

## 5. Fit with the earlier ORION pages

* The ECHOSpiral route and the ORION eleven-phase loop (`RequestProject/Orion/Engine.lean`) are
  separate processes. Both put adversarial review before human sign-off, and both give the human
  the final decision.
* **Two different "hard stops".** In *Operation Snake and Scale*, the four hard stops (intrusion,
  doxxing, unilateral override, recursion limit) *abort* execution. In this page, an Auditor Hard
  Stop *pauses* the Council until the Catalyst resolves it. Both rules are proved as stated, but
  they behave differently. A platform should give them different names (for example "safety abort"
  and "audit hold") so users and developers don't mix them up.
