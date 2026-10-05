# Round Three — Responses to the Remaining Questions, Comments and Concerns

Sources read: the Round Three documents (Ryan's contribution summary and transcript, the
"Spaghetti-free" collab session, the Round Three collaboration summary with its list of
remaining questions, and the round index with the earlier open questions).

**How to read this document.** Each of the 17 questions gets an answer in three parts:

* **Answer**: a concrete mechanism you can build.
* **Proved**: the mathematical part, where there is one, stated and proved in Lean 4 under
  `RequestProject/Orion/`. Theorem names are given in backticks. The whole project builds
  with no `sorry` and only the standard axioms.
* **Open / human decision**: what no mechanism settles, which has to be a policy choice,
  an empirical measurement, or professional (legal, medical, safeguarding) advice.

The Lean files are a specification of the *rules*. They are not a proof about any
production code, which does not exist yet. `orion/gate_reference.py` is a short executable
sketch of the gate with self-tests (`python3 orion/gate_reference.py`).

**Legal questions.** Several questions ask who is *legally* liable, what makes equity
*legally binding*, or how to meet KYC/AML and child-protection law. I can't give legal
advice. Where those questions come up, I only describe the platform's internal accounting
or engineering, and mark the legal part for qualified counsel in each jurisdiction
involved.

---

## A correction to the Round Three code draft first

The `check_execution_eligibility` draft in the collab document has five problems. They are
fixed in `orion/gate_reference.py` and specified in `RequestProject/Orion/Gate.lean`:

1. `w_map`, `w_residue` and `predelegated_envelope` are **booleans passed in by the
   caller**, so the acting AI can assert its own witnesses. This is the self-authorisation
   loophole Ryan's work is meant to close. In the fix they are looked up in registries
   kept by other parties: the attestation registry, the residue audit, the deed registry
   and envelopes signed by humans.
2. The envelope is a yes/no flag, i.e. a blank cheque. In the fix it is a bounded object
   (see I.3).
3. `W_residue` is never consulted by the hard lock.
4. When an authorised request merely lacks a witness, the draft returns *"AI inferred
   emergency cannot overwrite lack of authority"*, which is the wrong reason.
5. Under a real plight with a failed check it returns `ASK` instead of offering
   `V_halt`/`V_reverse`.

---

## I. Emergency actuator semantics and human override

### I.1 Real-time `W_map` for legacy, third-party or undocumented hardware

**Answer.** `W_map` cannot honestly be produced *in real time* for a lever nobody has
characterised. Understanding a lever's blast radius is exactly what a crisis does not leave
time for. So the design moves the work earlier:

* **Attestation registry, built before the crisis.** Each lever is given one of three
  levels: `UNKNOWN`, `BOUNDED` (some effects known, blast radius has a proven upper bound)
  and `KNOWN`. The level is raised by independent mappers using vendor documentation,
  digital-twin or sandbox runs, read-only probing and incident history. Each step is signed
  and recorded. A function's name (`emergency_unlock`) never counts as evidence.
* **Unknown-lever drills.** Galactic Devs and guilds regularly list the levers in their
  domain that are still `UNKNOWN` and characterise the ones most likely to matter. This
  turns the "only an unmapped lever exists" scenario into a backlog that is visible and
  shrinking.
* **Probe ladder for `BOUNDED` levers.** First read-only interrogation, then a twin or
  sandbox run, then the smallest reversible actuation under a blast cap. Each probe is
  itself an action with a known, tiny map, so probing never needs an exception.
* **No paralysis.** The gate never leaves an emergency with no available move. Under a real
  plight it either commits a mapped action or offers `V_halt`/`V_reverse` (stop, alarm,
  isolate, roll back to a verified safe state).

**Proved** (`Gate.lean`):
* `not_eligible_of_unmapped` and `plight_does_not_unlock`: `W_map = UNKNOWN ⇒` not
  eligible, even when the plight evidence is set to `True`.
* `decide_never_commits_unmapped`: the gate never commits an unmapped lever.
* `decide_not_paralysed`: under a plight the verdict is always `commit` or
  `haltOrReverse`, never "nothing".

**Open / human decision.** There remains a case the design deliberately refuses: the only
lever is unmapped *and* irreversible. The machine will not pull it. The decision goes to
humans through the break-glass path (I.2), and only for reversible actions under a cap.
Whether some domains need an even more restricted human path for irreversible unmapped
levers is a policy choice, not something to derive. My recommendation is "no
machine-mediated path at all".

### I.2 Stopping "driver panic" from forcing a manual `W_map` bypass

**Answer.** Treat the manual bypass as *break-glass* with four conditions, each borrowed
from established safety practice:

1. **Two-person rule.** At least two distinct registered humans must sign.
2. **Cold second signer.** The second signer is routed the request *without* the live
   crisis feed. They see the lever, its unknown map and the blast estimate, so the second
   key is not exposed to the same emotional stimulus.
3. **Cooling-off delay δ**, which grows with the blast estimate. Meanwhile
   `V_halt`/`V_reverse` remain available, so waiting never means doing nothing.
4. **Reversible-only and under a hard blast cap.** Irreversible unmapped actions have no
   bypass at all.

Add a read-back step (the operator restates the lever and its *unknown* blast radius in
their own words, as in aviation read-back).

**On biometrics.** Use heart rate or HRV only as an *advisory* signal, for example to
lengthen δ or require a third signer. Do not use it as the key, because:
* it is spoofable;
* it gives false positives and negatives;
* its baselines differ for disabled users and for some medications;
* it puts medical-grade data inside a safety interlock.

**Proved** (`Gate.lean`):
* `breakGlass_needs_two`: no single person can open the path.
* `breakGlass_needs_delay`: nobody can open it before the delay has passed.
* The predicate `BreakGlassOK` also requires reversibility and the blast cap.

**Open / human decision.** The values of δ and the cap for each domain, who is on the
signer roster, and whether a third signer is required above some blast level.

### I.3 Mathematical bounds on the pre-delegated emergency envelope

**Answer.** An envelope is a signed, immutable object with **no wildcards**:
* an enumerated finite set of levers;
* an enumerated finite set of deeds;
* a per-use blast cap and residue cap;
* an expiry time;
* a maximum use count.

Three extra rules close the "blank cheque under a pre-approved label" route:

* **Every listed lever must still pass `W_map` at use time.** Being in the envelope never
  replaces the map.
* **Non-amplification.** A delegate can only issue a sub-envelope that is no wider than its
  own on any component, and nobody can sign an envelope whose total exposure
  (`maxUses × maxBlast`) exceeds their own authority budget.
* **Width-scaled quorum.** Define width = `|levers| × |deeds| × maxBlast × maxUses ×
  (expiry − now)`. A wider envelope requires more signers and a shorter renewal period.
  The AI can never extend or modify an envelope; renewal means re-signing.

**Proved** (`Gate.lean`):
* `emergency_path_bounded`: any execution without standing authority is literally inside
  the envelope (listed lever, listed deeds, under both caps, before expiry).
* `envelope_total_exposure`: an entire run of envelope uses has at most `maxUses` steps and
  total blast radius at most `maxUses × maxBlast`.
* `within_of_subEnvelope`: a sub-delegated envelope never permits more than its parent.

**Open / human decision.** The concrete caps per domain and the quorum-versus-width table.

---

## II. Multi-domain jurisdiction and role separation

### II.1 Overlapping or nested Skybox deeds (`U₁ ∩ U₂`), and private-to-public spillover

**Answer.** Evaluate `J(a,s,d)` over the **whole blast footprint**: an actor needs standing
in *every* deed the action's mapped blast radius touches. This settles overlap
mechanically. Primary standing then follows from footprints:

* **The private owner** acts inside the private Skybox.
* **The civic authority** acts on the public side with actions whose footprint is public
  only: isolate the boundary, shut public intake, evacuate. This runs under its own civic
  pre-delegated envelope.
* **Crossing into the private deed** (e.g. to put out the source) needs the owner's
  consent, *or* a **civic easement** written into the deed when it is issued, like a
  fire-code right of entry. The easement is listed, capped and logged like any envelope.
  Putting it in the deed means nobody has to argue about standing in the middle of the
  crisis.
* **Nested deeds.** The inner holder has standing inside; the outer holder only where the
  inner deed reserves rights to it.
* **Everyone else** gets *witness standing* only: they may alert and petition, which the
  Round Three docs already propose for AFK councils.

**Proved** (`Gate.lean`):
* `jurisdiction_overlap`: a footprint containing `U₁` and `U₂` needs standing in both.
* `jurisdiction_antitone`: enlarging a footprint can only remove standing, so splitting an
  action into confined parts is the way to act quickly.

**Open / human decision.** The default civic easement terms in deeds, and who the civic
authority is in each world or region.

### II.2 Four-way role separation when offline with a single copilot

**Answer.** Taken literally, with one principal it is **impossible**, and that is proved.
But Ryan's own wording says the roles need not be four machines: they must not collapse
into one unchecked inference chain. Offline, the player already has four distinct local
principals:

| Role | Offline principal |
|---|---|
| Discoverer | the 1:1 Ghost Rider copilot |
| Mapper | the **cached attestation registry**, signed earlier by independent mappers and synced whenever online |
| Justifier | a **local deterministic checker**: plain code with no model inference that checks the envelope, caps and standing (a candidate for formal verification) |
| Executor | the human player |

If the cached registry does not contain the lever, `W_map = UNKNOWN`, so the only moves are
halt/reverse. The whole episode is queued for independent review at the next sync.

**Proved** (`Roles.lean`):
* `no_separation_of_card_lt` and `copilot_alone_cannot_separate`: fewer than four
  principals means no separated assignment exists.
* `offline_separation_exists`: the four offline principals above work.
* `copilot_at_most_one_role`: in any separated assignment the copilot holds at most one
  role.

### II.3 Liability when a human delegate exceeds the Governor's intent

**Legal note.** Who is *legally* liable is decided by applicable law and contracts, not by
the platform. Please take that question to qualified counsel. What the platform can fix is
its **internal accountability ledger**:

* Delegations carry a **machine-readable scope**: levers, deeds, budget, expiry. The
  Governor's "intent" counts only to the extent it was written into that scope.
* An act **inside scope** is attributed to the whole authorisation chain. With a progenitor
  plus `n` others, each member carries `1/(n+1)`.
* An act **outside scope** is attributed to the acting delegate alone, and the delegators
  carry zero.
* If the scope was ambiguous, record that as a separate finding against the scope's author
  instead of quietly spreading it over the roster.

**Proved** (`Shares.lean`):
* `share_sum_one`: shares sum to 1.
* `in_scope_share`: in scope, each member of a chain of `n+1` carries `1/(n+1)`.
* `out_of_scope_share_zero`: out of scope, every delegator other than the actor carries 0.

---

## III. Database physics, provenance and test generation

### III.1 Database bloat vs. zero information loss

**Answer.** "Never erase `R₀`" does not require keeping everything in hot storage:

* **Append-only, hash-chained records.** Each record's history is fixed by one head digest
  (32 bytes for SHA-256). Light clients and interplanetary nodes keep only digests and
  fetch bodies on demand.
* **Content addressing and deltas.** Successive drafts share most of their text, so each
  blob is stored once and each revision is stored as a delta.
* **Tiering.** A hot window of the newest `W` entries per record; everything older goes to
  compressed cold object storage. This is lossless, and the hot cost stays bounded however
  long the history grows.
* **Rough illustration** (assumed numbers, not measured): 1 M users × 50 sessions a month
  × 20 KB of compressed deltas ≈ 1 TB a month of cold storage.

**Proved** (`Record.lean`):
* `push_keeps_history` and `r0_preserved`: every later state contains the earlier history,
  and `R₀` stays the oldest entry.
* `digest_injective`: the head digest determines the whole history, *under the
  idealisation* that the hash step is collision-free. Real hashes are only
  collision-resistant.
* `tiering_lossless` and `tiered_cost_le`: tiering loses nothing, and the hot cost is at
  most `W·b` plus the cold cost.
* `dedup_le`: content-addressed storage never stores more blobs than entries.

**Open / human decision.** "Never erase" conflicts with personal-data deletion rights in
some jurisdictions. One common engineering pattern keeps the hash chain and deletes
per-user encryption keys ("crypto-shredding"). Whether that is acceptable is a question for
counsel.

### III.2 A metric for "consensus texture"

**Answer.** Measure how correlated the agents' *errors* are, not how often they agree:

* On a calibration set with known answers, estimate the pairwise error correlation `ρ`.
  Use an upper confidence bound, and set `ρ = 1` outright for agents sharing a base model.
* Compute the **effective number of independent agents**
  `n_eff = n / (1 + (n − 1) ρ)`.
* Raise **`ConsensusTexture` when `n_eff < 2`**.
* Whatever `n_eff` is, agreement only *raises a hypothesis's priority*. It becomes
  `IndependentEvidence` only through a channel outside the models: measurement,
  reproduction, or a checked formal proof.

An information-theoretic alternative is the conditional mutual information
`I(A; B | truth)`, which is high when agents share errors beyond what the truth explains.

**Proved** (`Consensus.lean`):
* `variance_of_mean`: the formula is derived as the variance of the mean of equicorrelated
  signals, which equals `1/n_eff`.
* `neff_full_corr`: fully correlated agents are worth exactly one, however many agree.
* `neff_indep`: independent agents are worth `n`.
* `one_le_neff` and `neff_le`: always `1 ≤ n_eff ≤ n`.
* `neff_antitone`: more correlation means less evidence.
* `texture_iff`: the alert fires exactly when `ρ > (n−2)/(2(n−1))`. For example, for two
  agents any positive correlation triggers it.

**Open.** A `ρ` estimated on calibration data may differ in a new domain. This needs
empirical monitoring.

### III.3 Procedurally generating held-out cousin cases

**Answer.** Use metamorphic testing:

1. **The claim's author declares** its domain and the transformations that should not
   change its truth: renaming, change of units, permutation, rescaling, re-skinning the
   story, perturbing parameters inside the stated range.
2. **The generator** draws cousins only by applying declared transformations to seen
   cases, from a secret pool that is rotated.
3. **Human reviewers** add new transformation templates over time.

Because cousins come only from declared in-domain transformations, they cannot introduce
outside variables. A claim that fails a cousin has shown that it was memorising or
pattern-matching rather than applying the stated logic. Disputes over whether a
transformation really preserves the claim go to human review.

**Proved** (`Tests.lean`):
* `cousins_in_domain`: cousins never leave the declared domain.
* `genuine_passes_cousins`: an answer that encodes the logic and is right on seen cases is
  right on every cousin.
* `cousin_failure_exposes`: passing the seen cases but failing a cousin proves the answer
  is not encoding the logic.

---

## IV. Enterprise Pop-Out and economic translation

### IV.1 Turning 1/(n+1) weights and labour logs into equity for a 50-player guild

**Legal note.** Making equity *legally binding* across tax, labour and securities regimes
is legal work. The engine cannot do it, and I can't advise on it. The engine *can* produce
a sound, auditable **proposal**:

* contribution weights from the verified labour logs and progenitor weights;
* a whole-unit allocation that sums exactly to the authorised share count, with each
  member within one unit of their exact entitlement;
* the full ledger trail behind it.

That proposal becomes an *input* to a founders' agreement that each member consents to and
counsel drafts in the chosen jurisdiction. It is not self-executing.

**Proved** (`Shares.lean`):
* `final_alloc_sum`: exactly `N` units are allocated.
* `final_alloc_lower` and `final_alloc_upper`: each holder is within one unit of
  `N·wᵢ/W`.
* `floor_deficit_lt`: rounding down leaves fewer than `m` units over.

### IV.2 Vetting sponsors of "Epic Real-World Quests"

**Answer.** Layered and human-gated:

* **Verified sponsor identity.**
* **A mandatory bounty charter**, covering: the problem, success criteria, a declaration of
  what data is collected (no personal data by default), IP terms, and **payment escrowed
  upfront**.
* **Automated screens** that only *flag*: data-permission diffs, persuasion or advertising
  classifiers, duplicate detection.
* **A review panel** with conflict-of-interest rules and a published policy on political
  content.
* **A sponsor bond** that is forfeited on violation.
* **Clear "sponsored" labelling**, per-sponsor rate limits, and player reports and Zoo
  audits after launch.

---

## V. Metaphor engine and data compilation

### V.1 Preventing semantic poisoning of the Public Dictionary

**Answer.** Separate *coining* from *indexing*:

* Anyone can coin a term in their own or their guild's lexicon.
* Promotion to the global index requires a **checkable claim** attached to the term, and a
  **label** that says what kind of claim it is: *identity*, *analogy*, *physical claim* or
  *history*.
* The automated checks run first: formal proof, decidable checks, numeric tests.
* Then a named human reviewer, with reputation at stake, signs off.
* Rollout is staged (guild → region → global) and every entry is reversible with full
  provenance.

The project's own example shows why the labels matter:

* The mathematical content of "Seashell Spirals = Fibonacci" passes. The recurrence holds,
  and consecutive ratios tend to the golden ratio. Both are proved.
* A troll substitution ("powers of two") fails automatically.
* The *physical* reading, that seashells grow by the golden ratio, is widely repeated, but
  published measurements of nautilus shells generally do not match it. So the entry should
  be labelled *analogy*, not *identity*, unless a reviewer attaches a source.

**Proved** (`Tests.lean`):
* `seashell_recurrence`: the Fibonacci recurrence holds for every `n`.
* `seashell_ratio_tendsto`: consecutive ratios tend to the golden ratio, using Mathlib's
  `tendsto_fib_succ_div_fib_atTop`.
* `troll_powers_of_two_rejected`: the powers-of-two substitute fails the recurrence check.

### V.2 Compiling raw enterprise data into playable quests

**Answer.** Devs design **archetypes once**, not quests each time. Each archetype is a
structure-preserving game form for a class of problem:

| Problem class | Archetype |
|---|---|
| Network flow and logistics | routing dungeons |
| Scheduling | timing puzzles |
| Optimisation | resource puzzles |
| Classification | sorting challenges |
| Molecular structure | spatial folding puzzles (Foldit is a well-known precedent) |

The pipeline is: schema inference → problem-type classification → archetype selection →
parameter binding → asset kit → **round-trip validation**, meaning every in-game solution
maps back to a real candidate solution that is scored by the real objective. After that,
human review is needed only for new archetypes. Data is anonymised or aggregated before
it reaches players.

**Open.** Problems that fit no archetype still need Dev design. Track that fraction as a
metric.

---

## VI. Compute, minors and hardware

### VI.1 Hosting the 10-slot council overflow swarm

**Answer.** **Frozen by default.** A reserve agent is a stored snapshot (model reference,
memory and context, permissions), encrypted with a key held by the user. It uses no compute
until a human action, or a schedule the human pre-delegated, wakes it. Any background
running comes out of an explicit per-user compute budget. The ongoing cost is storage only.

### VI.2 Emotional and social maturity of accelerated minors

**Answer.** Keep *academic acceleration* separate from *access to adult real-world teams*.
Competence can unlock coursework; it should not unlock adult spaces. Recommendations:

* **Do not build an automated or biometric "emotional maturity score".** It would be
  unreliable and invasive.
* Base access on age, verified guardian consent, and judgement by trained human mentors
  and educators.
* Use graduated exposure: observer → mentored contributor in supervised, logged channels →
  limited role.
* Safeguarding: no private adult–minor channels, and background-checked mentors.
* No minor acts as the accountable expert at Level 13.

Child-protection and child-labour law vary by country and need specialist advice.

### VI.3 Hardware-gated launch or software-first?

**Recommendation: software-first.**

* Design every core loop for phone, keyboard, mouse and camera.
* Make every suit-dependent mechanic have a fallback.
* Treat the 64-node suit and AR HUD as optional enhancers, introduced once retention data
  shows the loops work.

Accessibility parity and zero-knowledge disability attestations must not depend on
proprietary hardware: the attestation comes from a medical attestation, not from the suit.
AR chores and physical tasks also need their own physical-safety review. This is a
business decision for the team; the recommendation is mine.

---

## Index of the new Lean results

| File | What it proves |
|---|---|
| `RequestProject/Orion/Gate.lean` | unmapped ⇒ no execution; plight cannot unlock; envelope bounds and total exposure; non-amplification; jurisdiction over the whole footprint; never paralysed; break-glass needs two people and the delay; audit ignores outcome |
| `RequestProject/Orion/Roles.lean` | four-way separation impossible with fewer than four principals; offline assignment works; copilot holds at most one role |
| `RequestProject/Orion/Consensus.lean` | derivation of `n_eff`; bounds; monotonicity; exact alert threshold |
| `RequestProject/Orion/Record.lean` | `R₀` preserved; hash-chain identifies history (idealised hash); lossless tiering; bounded hot cost; dedup |
| `RequestProject/Orion/Shares.lean` | exact whole-unit allocation within one unit of entitlement; accountability shares and scope rule |
| `RequestProject/Orion/Tests.lean` | cousin cases stay in the domain and expose memorisation; Fibonacci/golden-ratio check; troll rejection |
