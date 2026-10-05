module

public import Mathlib

/-!
# EFMW Zoo → Orion Proofs Arena: checkable rules

Exact statements about the two documents of this round:

* the *EFMW Zoo Inventory v1* (23 animals, 20 August 2026), and
* Grok's *EFMW Zoo → Orion Proofs Arena — Complete Design Compilation*.

What is checked here:

1. **Roster.** The 46-animal Core list in the compilation has no duplicates, and its first
   23 entries are exactly the 23 animals of the v1 inventory, in the same order.
2. **Names.** Each of the 23 expanded names in the inventory spells its animal's name
   through its capital letters (for example `Feedback Oscillation eXplorer` gives `FOX`).
3. **TURTLE is not majority rule.** In the veto-first synthesis rule, no amount of added
   positive evidence overturns a veto, and duplicates inside one evidence cluster count once.
   A plain majority vote, by contrast, is flipped by copying one positive result.
4. **Re-entry.** If failed claims may re-enter without limit and a false claim slips past the
   gauntlet with some fixed chance each time, the chance that it has *never* slipped through
   goes to zero. A total error budget split across attempts (`∑ αₖ ≤ α`) keeps the overall
   chance at most `α`.
5. **Discovery wave range.** Read as a range of roster numbers, "OCTOPUS…MOTH" (#3–#16) also
   contains CAT and RAVEN, which belong to the skeptic wave, and SHEPHERD and PULSE.

None of these is a statement about any game code or about the scientific frameworks behind
the animals.
-/

@[expose] public section
namespace EFMWZoo

/-! ## 1. Roster -/

/-- The 46 Core animals, in the order of the design compilation (§2). -/
def coreRoster : List String :=
  ["TORTOISE", "OWL", "OCTOPUS", "GECKO", "HIVE", "EAGLE", "CRAB", "SHEPHERD", "PULSE", "CAT",
   "FOX", "SPIDER", "RAVEN", "DOLPHIN", "ANT", "MOTH", "SHARK", "PENGUIN", "BAT", "HEDGEHOG",
   "CROCODILE", "DRAGON", "TURTLE",
   "MAGPIE", "WOLF", "ELEPHANT", "CHAMELEON", "JELLYFISH", "BEAVER", "MANTIS", "BISON",
   "WEASEL", "SALMON", "ORCA", "MOLE", "LYNX", "HORSE", "TERMITE", "PHOENIX", "COBRA", "WHALE",
   "FALCON", "RHINO", "BONOBO", "AXOLOTL", "BUTTERFLY"]

/-- The 23 animals of the v1 inventory, each with the expanded name given on its card. -/
def inventoryV1 : List (String × String) :=
  [("TORTOISE", "Temporal Out-of-sample Recursive Testing of Operational Information Structure through Exclusion"),
   ("OWL", "Observational Witness Layer"),
   ("OCTOPUS", "Observational Coupling and Temporal Orchestration of Partially Unobserved Systems"),
   ("GECKO", "Gradient Evaluation of Coherence and Kinetic Outliers"),
   ("HIVE", "Hierarchical Interaction and Variance Engine"),
   ("EAGLE", "Early Anomaly and Gradient Loss Estimator"),
   ("CRAB", "Contradiction Resolution and Anomaly Benchmark"),
   ("SHEPHERD", "Systemic Hazard Evaluation through Persistent History, Error, Recursion and Drift"),
   ("PULSE", "Predictive Uncertainty and Longitudinal Safety Evaluation"),
   ("CAT", "Coherence Ablation Tester"),
   ("FOX", "Feedback Oscillation eXplorer"),
   ("SPIDER", "Systemic Precursor Inference through Distributed Edge Relations"),
   ("RAVEN", "Recursive Anomaly and Variance Evaluation Network"),
   ("DOLPHIN", "Dynamic Observation of Latent Patterns through Historical Interaction Networks"),
   ("ANT", "Adaptive Network Tracer"),
   ("MOTH", "Multiscale Oscillation and Temporal Harmonics"),
   ("SHARK", "Systemic Hazard Assessment through Recursive Kinematics"),
   ("PENGUIN", "Predictive Evaluation of Network Gradients under Uncertainty and Information Noise"),
   ("BAT", "Baseline Adversarial Tester"),
   ("HEDGEHOG", "Held-out Evaluation of Dynamic Generalization, Error, Habitat and Out-of-sample Gain"),
   ("CROCODILE", "Causal Recursive Observation of Coupling, Outcomes, Drift, Intervention, Latency and Effects"),
   ("DRAGON", "Distributed Recursive Attractor and Gradient Organization Network"),
   ("TURTLE", "Top-level Unification of Recursive Transformations, Layers and Emergence")]

/-- The Core roster has 46 distinct animals, and its first 23 are exactly the v1 inventory,
in the same order. -/
theorem coreRoster_spec :
    coreRoster.length = 46 ∧ coreRoster.Nodup ∧
      coreRoster.take 23 = inventoryV1.map Prod.fst := by
  decide

/-! ## 2. Expanded names -/

/-- The capital letters of an expanded name, read left to right. -/
def capitals (s : String) : String := String.ofList (s.toList.filter Char.isUpper)

/-- Every one of the 23 expanded names in the inventory spells its animal's name through its
capital letters. -/
theorem inventory_names_spell_animals :
    ∀ p ∈ inventoryV1, capitals p.2 = p.1 := by
  decide

/-! ## 3. TURTLE synthesis versus majority rule -/

/-- Outcome of one animal's run on a claim. -/
inductive Outcome
  | pass
  | fail
  | veto
  deriving DecidableEq, Repr

/-- One piece of evidence: the evidence cluster it belongs to and its outcome. Runs in the
same cluster are correlated and do not count as independent replications. -/
structure Evidence where
  cluster : ℕ
  outcome : Outcome
  deriving DecidableEq, Repr

/-- Number of independent positive results: distinct clusters with a passing run
("correlated wins count once"). -/
def independentPositives (ev : List Evidence) : ℕ :=
  ((ev.filter (fun e => e.outcome = .pass)).map Evidence.cluster).dedup.length

/-- TURTLE's ruling: publishable when no veto was issued and at least one positive result
survives (the invariant set is non-empty).

*Superseded* for publication by `RoundFourRulings.consensus`: the designer has ruled (Round Four,
D7) that council consensus decides publication, not a single veto. -/
def turtlePublishes (ev : List Evidence) : Bool :=
  !(ev.any (fun e => e.outcome = .veto)) && 0 < independentPositives ev

/-- A plain majority vote over runs: more passes than non-passes. -/
def majorityPublishes (ev : List Evidence) : Bool :=
  (ev.filter (fun e => e.outcome ≠ .pass)).length < (ev.filter (fun e => e.outcome = .pass)).length

/-- **Veto dominance.** Once any run has issued a veto, no further evidence, however many
positive runs it contains, makes TURTLE publish. -/
theorem veto_dominates (ev extra : List Evidence) (h : ∃ e ∈ ev, e.outcome = .veto) :
    turtlePublishes (ev ++ extra) = false := by
  obtain ⟨e, he, hv⟩ := h
  have : (ev ++ extra).any (fun e => e.outcome = .veto) = true :=
    List.any_eq_true.mpr ⟨e, List.mem_append_left _ he, by simp [hv]⟩
  simp [turtlePublishes, this]

/-- **Correlated wins count once.** Adding a passing run in a cluster that already has a
passing run does not change the count of independent positives. -/
theorem duplicate_in_cluster_counts_once (ev : List Evidence) (c : ℕ)
    (h : ⟨c, .pass⟩ ∈ ev) :
    independentPositives (⟨c, .pass⟩ :: ev) = independentPositives ev := by
  have hc : c ∈ (ev.filter (fun e => e.outcome = .pass)).map Evidence.cluster :=
    List.mem_map.mpr ⟨⟨c, .pass⟩, List.mem_filter.mpr ⟨h, by simp⟩, rfl⟩
  simp [independentPositives, List.dedup_cons_of_mem hc]

/-- **Majority rule can be gamed.** One vetoing run and one passing run: neither rule
publishes. Copy the passing run twice inside its own cluster: majority vote now publishes,
TURTLE still does not, and TURTLE's count of independent positives is unchanged. -/
theorem majority_flipped_by_copies :
    let ev : List Evidence := [⟨0, .veto⟩, ⟨1, .pass⟩]
    let ev' : List Evidence := ev ++ [⟨1, .pass⟩, ⟨1, .pass⟩]
    majorityPublishes ev = false ∧ turtlePublishes ev = false ∧
      majorityPublishes ev' = true ∧ turtlePublishes ev' = false ∧
      independentPositives ev' = independentPositives ev := by
  decide

/-! ## 4. Unlimited re-entry -/

open MeasureTheory ProbabilityTheory

/-- **Unlimited re-entry eventually publishes a false claim.** Let `E k` be the event that
attempt `k` of a false claim slips past the gauntlet. If each attempt is stopped with the
same probability `q < 1` and the stopping events are independent, then for every `ε > 0`
there is a number of attempts after which the probability that *every* attempt so far was
stopped is below `ε`. -/
theorem unlimited_reentry_eventually_passes {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (E : ℕ → Set Ω) (q : ENNReal) (hq : q < 1)
    (hstop : ∀ k, μ (E k)ᶜ = q) (hind : iIndepSet (fun k => (E k)ᶜ) μ)
    (ε : ENNReal) (hε : 0 < ε) :
    ∃ N, ∀ n ≥ N, μ (⋂ k ∈ Finset.range n, (E k)ᶜ) < ε := by
  have hprod : ∀ n, μ (⋂ k ∈ Finset.range n, (E k)ᶜ) = q ^ n := by
    intro n
    rw [hind.meas_biInter, Finset.prod_congr rfl (fun k _ => hstop k), Finset.prod_const,
      Finset.card_range]
  have ht := ENNReal.tendsto_pow_atTop_nhds_zero_of_lt_one hq
  have hev := (ht.eventually (gt_mem_nhds hε))
  obtain ⟨N, hN⟩ := Filter.eventually_atTop.mp hev
  exact ⟨N, fun n hn => by rw [hprod]; exact hN n hn⟩

/-- **An error budget fixes it.** If attempt `k` lets a false claim through with probability
at most `α k`, and the per-attempt budgets over the first `n` attempts add up to at most
`total`, then the probability that some one of those attempts lets it through is at most
`total`. No
independence is needed. -/
theorem error_budget_bounds_reentry {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (E : ℕ → Set Ω) (α : ℕ → ENNReal) (total : ENNReal) (n : ℕ)
    (hE : ∀ k, μ (E k) ≤ α k) (hbudget : ∑ k ∈ Finset.range n, α k ≤ total) :
    μ (⋃ k ∈ Finset.range n, E k) ≤ total :=
  (measure_biUnion_finset_le _ _).trans ((Finset.sum_le_sum fun k _ => hE k).trans hbudget)

/-! ## 5. The "OCTOPUS…MOTH" discovery range -/

/-- Read as roster numbers, "OCTOPUS…MOTH" is #3–#16. That range also contains CAT and
RAVEN (skeptic wave) and SHEPHERD and PULSE (domain safety). -/
theorem discovery_range_overlaps :
    let range := (coreRoster.drop 2).take 14
    range.head? = some "OCTOPUS" ∧ range.getLast? = some "MOTH" ∧
      "CAT" ∈ range ∧ "RAVEN" ∈ range ∧ "SHEPHERD" ∈ range ∧ "PULSE" ∈ range := by
  decide

end EFMWZoo
