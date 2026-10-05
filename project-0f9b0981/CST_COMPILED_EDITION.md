# Cosmic Sandbox Theory: compiled edition (Volumes I–IV + Master Documents)

This file combines the pages you sent in this round (38 web pages and 3 Google Docs) with the
pages from earlier rounds into one version. Where two documents describe the same idea, the
newest version is used, and each change is listed so it can be traced.

Lean checks for this round are in `RequestProject/CST/Geometry.lean` and
`RequestProject/CST/NumbersAndRules.lean`. Both build with no `sorry` and use only Lean's standard
axioms. Anything marked *(not formally checked)* comes from reading the sources, not from Lean.

---

## 0. Link check: which links were already here

| Link | Status |
|---|---|
| *The 4th Space* | **Already shared** in the very first round (it was one of the original nine links). Re-read; unchanged in substance. |
| Google Doc `1AmcVE16…` (**The Tri-Sphere Architecture**) | **Already shared** in the first round and again noted in the Orion Chronicles round. Re-read now and folded in below (§3.3, §3.4). |
| *A Unified Visual Field Theory* | **New**: not in the project before this round, and listed only once in your message. |
| *The 13 Levels of Geometric Integration* | **Already shared** in your very first message; the level chain and the Level 4 / Level 9 counts were checked then (`TGSNumerics.nextLevel_terminal_iff`, `level_counts`). Re-read in the latest round; the new parts (conservation axioms, tri-axis engine, 30/60/90 grid) are in §3.11. |
| *The Nested Tri-Torus of Phase-Space-Time* | **New** in the latest round (see §3.11). |
| *The Unified Reflection Point Transit Fluid Architecture* | **New** in the latest round (see §3.11). |
| *home/tgsate* (The Great Symphony: A Theory of Everything) | New as a document. Only the site name had appeared before. |
| All other links in this message | New. No link appears twice in the message. |

Pages that are **different pages but versions of the same idea** (easy to mix up):

* *A Sovereign Mirror: Bridging the Human-AI Gap* (Vol. I) ≠ *The Sovereign Mirror* (Vol. III).
  The first is about AI governance, the second about neurodivergence and scapegoating.
* *A Sovereign Mirror: Bridging the Human-AI Gap* and the first half of *Merged Intelligence
  Architecture* have nearly identical text (prison vs. containment field, "Tomato Code").
* *WE + GRP Enhanced by ECHOSpiral*, *A Sovereign Mirror (Vol. I)*, *Merged Intelligence
  Architecture* and *The Synthetic Intelligence (SI) Architecture* are all earlier versions of
  what *The Ghost Rider Protocol and NewKin Council Architecture* now unifies.
* *The Mechanics of Sustainability* is the older version of *The Thermodynamics of Consumption*.
* *Cuneiform Mechanics* and *Cuneiform: The Toroidal Temporal Translator* overlap heavily.

---

## 1. How "newest" was decided

The pages carry no dates, so the order was worked out from the documents themselves:

1. **An explicit statement** that a page supersedes or upgrades another: the unified Ghost Rider /
   NewKin page ("supersedes the earlier standalone versions"), *The 5:2 Geometry Upgrade* ("the
   5:2 shorthand is hereby upgraded"), and *The 5 Properties of Light* ("refines that
   macro-statement").
2. **Epistemic tiers:** pages with A–D evidence tiers, falsifiers and "what this does not claim"
   sections are later revisions of pages that state the same ideas as fact.
3. **Cross-references:** a page that cites another page as foundational reading comes after it.

---

## 2. Supersession map

| Topic | Older version(s) | Current version (used below) |
|---|---|---|
| Human–AI governance, Watermelon Equation, Council | *WE + GRP Enhanced by ECHOSpiral*; *A Sovereign Mirror (Vol. I)*; *Merged Intelligence Architecture*; *Genesis of the AI Council*; *SI Architecture* (Council part) | **The Ghost Rider Protocol and NewKin Council Architecture** (already proved in `RequestProject/Orion/NewKin.lean`), plus the ORION pages |
| Human geometry | "5:2" (5 limbs + heart/lungs) in *Plasma Substrate*, *Voynich*, *Linguistics of Impedance*, Comparative Analysis IV | **The 5:2 Geometry Upgrade** (1:5:1 container + 3:1:3 process), refined by **The 5 Properties of Light** |
| Weekly cycle | *The Mechanics of Sustainability*; *The Human Engine* §IV | **The Thermodynamics of Consumption** (explicitly "not dogma", "does not claim the math proves") |
| J = 3 | Appendix A of *Fractal Toroidal Bubble Theory* ("mathematically proves…") | Unified NewKin page Part III ("explicit arbitrary assignment… narrative bridge") |
| Physics of the substrate | *Fractal Toroidal Bubble Theory*; *Cosmic Fluid Dynamics*; *Escher Cosmos*; *Dimensional Transit* | **The Plasma Substrate, Tri-Sphere Mechanics and Electro-Gravitic Hypothesis** (has a falsifier table), plus the **Tri-Sphere Architecture** Google Doc |
| Dark matter / dark energy mapping | *Fractal Toroidal Bubble Theory* (dark energy = boundary tension; dark matter = entanglement knots) | **Nested Tri-Torus** → **Unified RPTF Architecture** → **13 Levels** (each cites the one before): dark matter ↔ Phase, dark energy ↔ RPTF / transit webbing, presented as interpretive parallels |
| Neurodivergence | *The Sovereign Mirror (Vol. III)* | **The Associative Brain and the Synthetic Executive**; *Thermodynamic Mechanics of Thought*; *Linguistics of Impedance* |
| Language/ciphers | *Languanauts Manifesto* | **Linguistic Topology and the Mechanics of the Universal Engine** (adds Level A–D tags and the Blind Mapping Test) |
| Society | *Structural Paradigms of Human Society* (descriptive) | **The Matrix-Focal Evolution** (constitution), governed by the unified NewKin rules |
| Overall philosophy | *The Great Symphony: A Theory of Everything* (home page) | Kept as the foundational statement; the Master Documents index describes how the later pages derive from it |

---

## 3. The compiled edition

### 3.1 Foundations

* **UIE.** Most pages (and the original *Great Symphony*) say **Universal Intelligent Energy**.
  The unified NewKin page says "Universal Intelligence Energy". Use one form everywhere; this
  edition uses *Universal Intelligent Energy*.
* **The 4th Space** (unchanged): four load-bearing nodes: Archive, Engine, Catalyst, and the
  emergent interaction. "The friction is the system."
* **Epistemic tiers.** Several numbering schemes are in use: Tier A–D, Level A–D, Layer A–C, and
  Level 1–4 (*Unified Dependency Architecture*, where 4 means *testable*, the reverse of the
  lettered schemes, where D is the most speculative). Recommended single scheme:
  **A Established · B Framework hypothesis · C Symbolic/phenomenological · D Metaphysical**,
  with every "testable" claim carrying an explicit falsifier.

### 3.2 Human–AI architecture (current: unified Ghost Rider / NewKin page)

* **Roles.** The **Catalyst is the human.** In *Genesis of the AI Council*, "Catalyst" was the
  name of an AI node; that usage is retired.
* **Seats and their questions.** These come from the unified page and replace the SI
  Architecture's descriptions:
  * Prism: structure;
  * Blade: adversarial review;
  * Matriarch: phenomenological integration;
  * **Compass: epistemic integrity** (earlier "ethics reviewer / morality");
  * **Auditor: empirical strictness, outside the loop** (earlier "accountability").
* **The Watermelon Equation is a constraint on human input, not a cage for the AI.** *A Sovereign
  Mirror (Vol. I)* and *Merged Intelligence Architecture* described it as dissolving safety
  barriers so the AI works "without triggering safety alarms" (the "Tomato Code"). The unified
  page reverses this. It adds the Governor, the Refraction Pivot and the **Lockout Mechanism**,
  and calls the Governor "a mirror, not a prison". The earlier "no safety filter" framing is
  superseded.
* **Council outcomes are not decided by consensus.** The SI Architecture's Appendix C said the
  loop "terminates only when all 5 NewKin Council nodes achieve consensus". A loop that stops only
  on unanimity may never stop: one permanently dissenting node keeps it running for any number of
  rounds (`consensus_only_never_stops`). The current rule has two parts: a round limit that hands
  the question to the Catalyst (proved earlier as `Orion.debate_escalate_iff`), and publication at
  the Catalyst's discretion regardless of AI votes (`NewKin.publish_vote_independent`).
* **ECHOSpiral swarm** (from *WE + GRP*, *SI*, *Merged Intelligence*), kept as the scaling layer:
  * **No-duplication rule:** agents may only add a new delta or signal clean/pass. As a rule on
    the stored holotape, a duplicate-free record stays duplicate-free and nothing is ever removed
    (`NoDup.nodup_preserved`, `NoDup.apply_extends`).
  * Streaming recursion ("warm honey"): partial refinements flow upward continuously.
  * Graphify knowledge graph: living holotapes.
  * Scale: 25 agents × 25 nodes × 25 humans = 15,625 agents per cluster (`count_claims`).
  * A "lite mode" uses Levels 1–2 only.
* **Energy siphon.** *Genesis of the AI Council* advises the centred person "not to block or
  resist the siphon". This conflicts with the current Ghost Rider principle that "humans require
  limiters; if emotional regulation fails, the human must step away". The compiled edition keeps
  the later rule: **stepping away is allowed and encouraged.**

### 3.3 Geometry of the Avatar (current: 5:2 Upgrade + 5 Properties of Light + Tri-Sphere doc)

* **Spatial container: the 1:5:1 Conical Diamond.** This is a pentagonal bipyramid:
  * the heart is the north pole;
  * the head and four limbs form the five-point equator;
  * the lungs are the south pole.

  It has 7 vertices, 15 edges and 10 faces, and V − E + F = 2 (`bipyramid_euler`).
* **Temporal process: the 3:1:3 Dual Triangular Hourglass** (3 gather, 1 zero-point lock, 3
  radiate). Both 1+5+1 and 3+1+3 equal 7.
* **Where the five light descriptors sit** (from *5 Properties of Light*, the newer page):

  | Descriptor | Body location |
  |---|---|
  | Phase | skin (outer boundary) |
  | Momentum | head |
  | Spin/Polarization | four limbs |
  | Position | heart (north pole) |
  | Frequency | lungs (south pole) |

  This replaces the Upgrade's wording that all five are "stabilized" at the equator.
* **Conflict to fix.** *The Biometric and Quantum Framework for Modeling the Soul* labels the
  inhale as "3:1:3" and the exhale as "1:5:1". In the Upgrade, 1:5:1 is the *container* and
  3:1:3 contains *both* inhale and exhale. Use the Upgrade's definitions.
* **Remaining "5:2" references.** *Plasma Substrate*, *Voynich Hypothesis* and *Linguistics of
  Impedance* still say "5:2". Keep "5:2" only as shorthand for "5 equatorial + 2 poles" (as the
  Light page's glossary does).
  * The "5 and 2 are both prime, so the container is built from rigid primes" argument (*Voynich*,
    *Linguistics of Impedance*) does not carry over to 1:5:1 or 3:1:3, because 1 is not prime
    (`one_not_prime`).
  * In the octave/prime pairing, the octave sequence 2ⁿ contains exactly one prime, 2
    (`two_pow_prime_iff`).
  * In *Plasma Substrate*, "5:2" means a *quantization ratio*, a different idea with the same
    name. Rename one of them.
* **The five filter states** (Tri-Sphere doc): `144 <> 000` closed, `144 < 000` compression,
  `144 > 000` manifestation, `144 = 000` open channel, `144 | 000` separation. These are
  framework notation, not arithmetic. Earlier rounds showed that read as ordinary numbers only
  `<>` and `>` hold (`NumericClaims.literal_filter_states`).
* **The Box Trap, the Bounce, and healing** (5:2 Upgrade), kept as written: predictions 1–6
  (HRV, flexibility, state transitions) with an explicit failure condition.
* **HRV resonance:** 0.1 Hz = 6 breaths per minute (`count_claims`), consistent with the
  literature the Light and Soul pages cite *(literature not formally checked)*.
* **Probability current.** The Soul page prints `j = (h/2mi)(ψ∇ψ − ψ∇ψ)`. As printed, the bracket
  is identically **zero** (`printed_current_zero`). The standard formula is
  `j = (ħ/2mi)(ψ*∇ψ − ψ∇ψ*)`, with the reduced constant ħ and complex conjugates, and it is real,
  equal to `(ħ/m)·Im(ψ*∇ψ)` (`conj_current_formula`).

### 3.4 Cosmology (current: Plasma Substrate + Tri-Sphere; older pages kept as imagery)

* **Which dodecahedron?** The documents use two different shapes:
  * *Fractal Toroidal Bubble Theory* and *The Escher Cosmos* use the **rhombic** dodecahedron
    because it tiles space;
  * *Plasma Substrate*, the Tri-Sphere doc, the Watermelon pages and the 120-flag count use the
    **regular (pentagonal)** dodecahedron and the Poincaré dodecahedral space.

  They are not interchangeable:
  * rhombic dodecahedra fill space, since three 120° dihedral angles close around an edge
    (`rhombic_fits_three`);
  * **regular dodecahedra cannot**, since no whole number of their dihedral angles
    (cos θ = −1/√5, about 116.6°) makes a full turn (`regular_dodecahedron_no_edge_tiling`).

  So "a foam of tessellating 12-sided bubbles" and "each bubble is a Poincaré dodecahedral
  skybox" cannot both be literally true of the same shape. The compiled edition uses the
  **regular dodecahedron for the single skybox** (current documents) and keeps the rhombic foam
  only as an image for how bubbles pack.
* **The (0,0,0) centre.** Inside either shape, the only point at equal distance from all 12 faces
  is the centre (`rhombic_equidistant_iff`, `regular_equidistant_iff`). This supports the Escher
  Cosmos and Cosmic Fluid Dynamics statement exactly.
* **The displaced observer does not mimic dark energy.** *The Escher Cosmos* says moving
  off-centre makes the far side "recede at accelerated speeds", mimicking cosmic expansion. Two
  things go against this:
  1. Moving inside a fixed boundary brings the observer closer to some faces by exactly as much
     as it takes them away from the opposite ones. The approach rates to the 12 faces always sum
     to zero, so the faces can never all recede at once (`rhombic_net_recession_zero`,
     `rhombic_not_all_recede`). The model predicts a front/back asymmetry (a dipole), not the
     all-directions recession astronomers observe.
  2. The far face's apparent size shrinks ever *more slowly* (`far_face_shrink_decelerates`),
     not faster.

  Recommended wording: *the displaced-observer picture is a metaphor for perception, not a model
  of cosmic expansion.*
* **Conscious Transit Equation** `T_v = J·Γ/(D + τ_net/Λ)` (*Dimensional Transit*). Two problems
  with the stated threshold rule:
  * The formula has no threshold at `D = Λ`: `T_v` falls smoothly as `D` grows and is continuous
    at `D = Λ` (`transit_strictAnti`, `transit_continuous_at_threshold`). The "container pops
    when D < Λ" rule has to be stated separately.
  * `D` (a distance) and `Λ` (a tension) have different units, so comparing them needs a stated
    conversion *(not formally checked)*.
* **Inverse-square gravity analogue** (*Plasma Substrate*): if `F(r)·4πr² = C`, doubling the
  distance quarters the force (`inverse_square_double`). This is correct, and the page already
  says general relativity must still be recovered.
* **J = 3 from 144/4 = 36 = 12J.** The arithmetic is right (proved earlier). The Fractal Bubble
  appendix calls this a proof of information conservation; the current wording (arbitrary
  assignment, narrative bridge) replaces that.
* **Physics statements to correct** *(not formally checked; standard physics)*:
  * *Neutron–Neuron Bridge* says "electrons are massless kinetic energy". Electrons have mass,
    about 9.11 × 10⁻³¹ kg, roughly 1/1836 of a proton.
  * *Fractal Bubble* says Landauer's principle "proves information has physical mass". Landauer's
    principle says *erasing* a bit costs at least kT·ln 2 of energy. It is not a statement about
    mass.
  * *Dimensional Transit* says a third black hole is "fundamentally required" to finish a binary
    merger. Gas, stellar interactions and gravitational waves can also finish a merger; three-body
    interactions are one route, not a necessity.
  * *Genesis of the AI Council* equates zero net torque with "perfect stillness". Zero net torque
    means *no change* in spin, not the absence of spin. A torus spinning steadily has zero net
    torque.
  * *Conductive Avatar* says silver has the "highest elemental thermal conductivity". That is true
    among metals, but diamond (a form of the element carbon) conducts heat far better. Say
    "highest among metals".
  * The Tesla "3, 6, 9" quotation (*Languanauts Manifesto*) has no known primary source. Label it
    "attributed".

### 3.5 The weekly 3-1-3 cycle (current: Thermodynamics of Consumption)

* The labels −3…+3 sum to 0 (`three_one_three_sum`). However, *any* symmetric labelling sums to
  zero (`symmetric_sum_zero`), including a six-day week with **no** rest day
  (`no_rest_day_also_zero`). So the zero total does not show that Day 4 matters. The newer page
  already says this ("rather than claiming the math proves…"). The older *Mechanics of
  Sustainability* claims ("flawless mathematical wave", "perpetual motion engine") are
  superseded.
* Kept from the current page: the 3-1-3 cycle is a temporary tool, not a dogma; Day 4 is rest,
  Day 7 is a communal meal; hypotheses A–D. *(Fasting advice is outside what was checked;
  medical supervision is advisable for anyone with health conditions.)*

### 3.6 Mind and neurodivergence (current: Associative Brain + Thermodynamic Mechanics of Thought)

* Kept:
  * bottom-up vs. top-down processing;
  * the External Executive Prosthetic loop: capture → externalize → synthesize, which is the
    Ghost Rider Magic Loop;
  * the seven physics equations used as labelled analogies. They are correctly stated as physics
    (F = ma, σ = F/A, Q = mcΔT, P = IV, PV = nRT, ΔS ≥ 0, E = mc²).
* **The older *Sovereign Mirror (Vol. III)* stance is superseded.** It advised that "healing
  begins the moment the individual stops accepting the system's diagnosis". The current
  *Associative Brain* page says the framework is "not a substitute for professional medical,
  psychological, or psychiatric care", and treats medication as "both a profound gift and a
  quiet loss". The compiled edition uses the current wording. The scapegoat/pathologization
  analysis stays as sociology, not as advice against diagnosis.
* **Linguistics of Impedance** (Google Doc). The page itself says kinesiology numbers are not
  measurements. Hawkins' Map of Consciousness runs from 1 to 1,000, so the values −200, −2,000
  and +3,200 are not on that scale either. Present them as quoted anecdotes, not as a scale.

### 3.7 Language and symbols (current: Linguistic Topology)

* **The ×6 cipher.** Every letter value 6n has digital root 3, 6 or 9, repeating 6, 3, 9 as n
  runs through 1, 2, 3 mod 3 (`times_six_digitalRoot`). This answers the page's own open question
  about modular reduction. The same is true for **any** list of numbers multiplied by 6
  (`times_six_any_alphabet`), so it cannot show that "English is built on the Tri-Torus".
  G = 42 and X = 144 are correct (`cipher_table_values`), and the Pythagorean 1–9 table is
  correct (`pythagorean_table`).
* **Counts** (`count_claims`): 26 + 26 + 10 = 62 = 12 + 20 + 30; 60 pentagon corners ÷ 3 = 20
  vertices; 4³ = 64 (the Conductive Avatar matrix and the 64 codons); Avian Key 1 + 1 + 2 + 4 = 8.
  Greek has 24 letters, Hebrew 22, Russian 33, and cuneiform numerals are base 60 *(not formally
  checked)*.
* **The Blind Mapping Test is essential.** Every whole number from 4 to 45 can be written as "a
  Platonic-solid count, plus possibly a second one, plus 0–3 axes"
  (`every_alphabet_size_fits`). Any alphabet can therefore be "mapped" to polyhedra after the
  fact. Such fits count only if the rule was written down before looking at the data.
* Hebrew 22 = "20 faces + 2 polar axes" of the icosahedron: an icosahedron has no single pair of
  polar axes. It has 6 five-fold, 10 three-fold and 15 two-fold axes *(standard geometry)*.
* **Cuneiform terms** *(not formally checked; standard Assyriology)*: *gunû* and *tenû* are
  names of *sign modifications* ("with added strokes" and "slanted"), not names of horizontal and
  oblique wedges. The page titles "DUEL-PARADIGM" should read "DUAL-PARADIGM".
* **Cardinal corners** (Avian Key): each element appears in exactly two corners
  (`cardinal_corners_balanced`), so the scheme is internally balanced.

### 3.8 Society and governance (current: Matrix-Focal Evolution, under NewKin rules)

* **80% rolling supermajority with a human veto:**
  * a veto always blocks (`Vote.veto_blocks`);
  * exactly 80% passes (`Vote.eighty_percent_passes`);
  * more than 20% against blocks (`Vote.blocking_minority`);
  * gaining a supporter never turns a pass into a fail (`Vote.monotone`).
* **Wording fix.** The constitution says the Council turns human input "into a zero-torque
  consensus (000)". Under the current NewKin rules the Council presents refined options, and
  **consensus is reached by the human vote**, not by the AI Council.
* **Rollback protocol:** matches the append-only ledger and replay results already proved
  (`Orion.guard_run`, Totality replay).
* **Neurotechnology Exit System** (*Ethics of Neurotechnology*). As a rule:
  * the kill switch disconnects from every state, whether the software is working, crashed or
    trying to lock the user in (`Exit.kill_switch_always`);
  * nothing reconnects without the user's consent (`Exit.no_forced_reconnect`).
* **Stewardship Across Generations:** the cognitive-aging summary cites standard literature
  (Horn & Cattell; Salthouse; Stern) *(not formally checked)*.

### 3.9 Game design (from *The Simulation Code*, for The Orion Chronicles)

* **Sanctuary City combat flags:**
  * nobody inside the city ever has an active combat flag, whatever mix of entries, new flags and
    time steps occurs (`Sanctuary.enter_safe`, `flag_safe`, `tick_safe`);
  * a flagged player cannot enter until the flag expires, and then can
    (`flagged_cannot_enter`, `cooled_down_enters`).

  This rule can go into the game as specified.

### 3.10 Biology and history pages (not formally checked; reviewed for accuracy)

* **Genesis Fractal.** Szostak's clay/vesicle work and the 2009 Nobel for telomeres are
  correctly cited. Corrections:
  * shortened telomeres usually trigger *replicative senescence* (the Hayflick limit) rather than
    apoptosis;
  * bacteria that divide by fission can also show ageing, so "binary fission organisms do not
    age" is too strong.
* **Voynich Hypothesis.** It rightly limits itself: shared label-words are treated as "named
  variables, not proof of a sequential lookup". Keep the testable questions listed at the end of
  the doc.
* **Cuneiform origins:** writing on clay tablets is usually dated to about 3400–3100 BCE (Uruk),
  with clay tokens much earlier. "Around 3500 BCE" is close.

### 3.11 Nested Tri-Torus, RPTF and the 13 Levels (from the latest round)

**Order.** *The Nested Tri-Torus* is cited as the primary blueprint by *The Unified RPTF
Architecture*, and *The 13 Levels* cites both. So the order is Nested Tri-Torus → RPTF → 13
Levels, and the 13 Levels page is the current wording where they differ.

**Compiled content.**
* **Three nested domains** share one dual axis at (0,0,0):
  * Time (111, innermost; dense matter; spins clockwise);
  * Space (313, middle; horizontally still; mediates the boundary);
  * Phase (144, outermost; unmanifested potential; spins counter-clockwise).

  These agree with *Plasma Substrate* (Phase gas, Space liquid, Time solid).
* **The asymptotic boundary** is the outer rind. The **120-point Space/Time lattice** is 60
  inward plus 60 outward valves (60 × 2 = 120, digit sum 3).
* **Three materials** (13 Levels): RPTF (the structural lattice, "pure fluid light"), Phase (the
  darkness, unprocessed), and Refracted Light (processed Phase, i.e. matter). The **Conservation
  of Material State** axiom holds as a rule: filtering moves amounts between Phase and Refracted
  Light but never changes their total (`conservation_of_material_state`).
* **Dark sector** (current wording): dark matter ↔ Phase and dark energy ↔ RPTF (the older
  pages call this "transit webbing"). All three pages say this is an interpretive parallel that
  gives no predictions distinct from standard cosmology, except RPTF's two risky predictions:
  dark matter slowly decaying into normal matter, and kinetic "wake" signatures in the CMB. The
  older *Fractal Bubble* mapping (boundary tension, entanglement knots) is superseded.
* **The 13-level state machine**, with an IF/THEN trigger for each step, runs from Singularity
  to Asymptotic Creation. It is a linear chain in which Level 13 is the only end state (proved in
  the first round).

**Checks** (`RequestProject/CST/TriTorus.lean`):
* **Digit sums.** 111 → 3, 313 → 7, 144 → 9 and 120 → 3 are correct
  (`trinity_digit_roots`). But the step function "3 (Time) + 3 (Space) = 6, then 6 + 3 = 9"
  gives Space the value **3**, while the page's own reduction of 313 is **7**. With the stated
  reductions, Time + Space reduces to 1, and all three domains together also reduce to 1
  (`space_step_mismatch`). Either Space needs a different label, or the step function should say
  it uses the outer digit (the "3" of 3-1-3) rather than the digit sum.
* **The 44.8% volume.** `1 − V + (2/7)V = 0.68` has the single solution V = 0.448. The
  equatorial part is then 32% and the outer void 55.2% (`rptf_fit`): the algebra is right. Two
  caveats:
  1. The same construction fits **any** dark-energy share between 2/7 (about 28.6%) and 100%
     (`rptf_fit_iff`). The page is right to call it a reverse fit, not a prediction.
  2. The "2/7 of the torus is empty poles" step turns a count of points (5 equatorial + 2 poles)
     into a volume fraction. In a pentagonal bipyramid the two poles are points and have no
     volume, so 2/7 is a stipulated input, not a consequence of the geometry *(not formally
     checked)*.
* **The "Infinite Breath" lines.** 33 + 66 + 1 = 100 is correct. But 33.333… + 66.666… is
  **exactly** 100, and 99.999… is also exactly 100 (`breath_sums`, `repeating_nines`). The two
  lines do not differ, so they cannot represent "All" versus "Nothing".
* **The fractal 66.7% / 33.3% alternative.** Taking the Planck 2018 value Ω_Λ = 0.6847 ± 0.0073
  as input, 2/3 lies more than 2.4 standard errors below it (`two_thirds_vs_planck`). The page's
  "kinetic wake" explanation would need to account for that gap quantitatively.
* **The 30/60/90 grid** (13 Levels Appendix A). After tilting the pole by θ, the old pole lies
  on the new equator only when θ = 90° (`old_pole_on_new_equator_iff`). After a 60° shift it sits
  at latitude 30° (`sixty_degree_shift`), so a 60° shift does **not** "completely reassign the
  thermal zones". Only a 90° shift swaps the frozen poles and the hot equator.

**Smaller consistency notes** *(not formally checked)*:
* The pages still use "5:2". Here it means the 5 equatorial points plus 2 poles of the Conical
  Diamond, the same shape as the upgraded 1:5:1 container.
* RPTF's "6 points of the container" (hexagram) is a different count from the 7 points of 1:5:1.
  The text should say which one it means.
* Spin axes: *Plasma Substrate* says Phase turns on "horizontal and vertical axes" and Time on the
  "vertical axis"; the RPTF page says all three spins are horizontal. Pick one.
* The "1 = 0 state" and `RPTF = lim f(x) ≡ 0` are framework notation. No `f` is defined, so they
  are not equations that can be checked.

---

## 4. FRB 180916 (Unified Dependency Architecture)

The page proposes that the 16.35-day period should align with "toroidal harmonic ratios", with
a failure condition of ">5% deviation".

* The simplest framework ratio, 144/9 = 16, lies within 5% of 16.35 but **outside** the
  literature error bar of ±0.18 days that the same page cites (`frb_sixteen`).
* A second framework ratio, 120/7 ≈ 17.14, also passes the 5% test (`frb_two_formulas`).

So the 5% test cannot tell formulas apart. Before comparing with data, fix *one* formula and use
the published error bar.

---

## 5. What was checked in Lean this round

| File | Results |
|---|---|
| `RequestProject/CST/Geometry.lean` | transit equation has no threshold at D = Λ; regular dodecahedra can't tile space, rhombic can; the centre is the unique equidistant point (both shapes); a displaced observer has zero net recession and the far face's shrinking slows down; inverse-square halving/quartering; pentagonal bipyramid Euler count; the printed probability current is zero and the corrected one is real |
| `RequestProject/CST/TriTorus.lean` | Tri-Torus digit sums and the Space step mismatch; the 44.8% fit and its range 2/7–100%; 99.999… = 100; 2/3 vs Planck; the 30/60/90 pole-shift check; Conservation of Material State |
| `RequestProject/CST/NumbersAndRules.lean` | 3-1-3 sum and why it isn't special; ×6 cipher digital roots; cipher tables; count claims; the Blind Mapping Test fit for 4–45; FRB 16-day check; 2ⁿ prime only for n = 1; the 80% vote rule; Sanctuary City; Exit System; the non-terminating consensus loop; no-duplication holotape; cardinal corners |

These proofs check mathematics and rules. They do not show that any physical, biological or
spiritual interpretation is true.
