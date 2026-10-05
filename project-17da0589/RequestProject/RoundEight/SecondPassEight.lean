module

public import Mathlib

/-!
# Round Eight, second pass: Ryan's Artemis/VPH mesh and Marek's component register

New on *ORION R8 Live* since the opening pass: four packages from Ryan, a numbered component
register from Marek, and an "In Contact to Collab" section. Ryan's POSM v0.4 is checked
separately, in `RequestProject/RoundEight/POSMv04Check.lean`.

## Artemis/VPH v0.1: the "mesh" coordination game (`kernel.py`, function `mesh`)

`n` agents each pick an action. Agent `i`'s loss for action `a` is the number of *other* agents
whose action differs from `a`, plus a penalty for `a` (in the package: 100 if `a` is marked
unreplayable, else 0; the same penalty table for every agent). An agent moves only for a strict
improvement.

* **Exact potential** (`potential_update`): when one agent switches, the change in the potential
  (disagreeing ordered pairs plus twice the total penalty) is exactly twice the change in that
  agent's own loss. Counting ordered pairs counts each disagreeing pair twice, which is why both
  sides carry the factor 2; it is the README's potential, doubled.
* **No endless improvement** (`no_infinite_improvement`): there is no infinite run of strict
  unilateral improvements. This is the README's argument, now proved.
* **Every resting point is a consensus** (`fixed_point_consensus`): if no agent can strictly
  improve, all agents have chosen the same action. The README says "a fixed point need not be
  consensus"; for general games that is right, but for this game, with one penalty table shared
  by all agents, it can't happen.
* **Which consensuses rest** (`consensus_fixed_iff`): everyone on `a` is a resting point exactly
  when, for every other action `b`, `penalty a ≤ penalty b + (n - 1)`. With the package's penalty
  of 100 and fewer than 101 agents, that means: everyone on one replayable action. So there can
  be several resting points (one per replayable action), as the README says.

## Marek's register (`register_*`)

The register on the page lists 23 domains and 284 named components, as its heading says
(`register_domain_count`, `register_component_count`). One name appears twice:
"Civilisation.One Academy" is both a component of Domain 13 (Education and Talent System) and a
programme in Domain 23 (Major Strategic Programmes), so there are 283 distinct names
(`register_distinct_count`, `register_academy_twice`).
-/

@[expose] public section

namespace RoundEightSecond

/-! ## The mesh game -/

section Mesh

variable {n : ℕ} {α : Type*} [DecidableEq α]

/-- `1` if two actions differ, else `0`. -/
def dis (x y : α) : ℤ := if x = y then 0 else 1

lemma dis_comm (x y : α) : dis x y = dis y x := by
  unfold dis; by_cases h : x = y <;> simp [h, eq_comm]

/-- Agent `i`'s loss for action `a` against profile `p`: disagreements with every other agent,
plus the action's penalty. -/
def loss (pen : α → ℕ) (p : Fin n → α) (i : Fin n) (a : α) : ℤ :=
  (∑ j ∈ Finset.univ.erase i, dis a (p j)) + pen a

/-- The potential: disagreeing ordered pairs plus twice the total penalty (twice the README's
potential, which counts unordered pairs once). -/
def potential (pen : α → ℕ) (p : Fin n → α) : ℤ :=
  (∑ j, ∑ k, dis (p j) (p k)) + 2 * ∑ j, (pen (p j) : ℤ)

lemma potential_nonneg (pen : α → ℕ) (p : Fin n → α) : 0 ≤ potential pen p := by
  unfold potential dis
  have h1 : 0 ≤ ∑ j, ∑ k, (if p j = p k then (0 : ℤ) else 1) :=
    Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => by split_ifs <;> norm_num
  have h2 : 0 ≤ ∑ j, (pen (p j) : ℤ) := Finset.sum_nonneg fun _ _ => by positivity
  linarith

/-- An agent's own loss does not depend on its own current action. -/
lemma loss_update (pen : α → ℕ) (p : Fin n → α) (i : Fin n) (a b : α) :
    loss pen (Function.update p i b) i a = loss pen p i a := by
  unfold loss
  congr 1
  refine Finset.sum_congr rfl fun j hj => ?_
  rw [Function.update_of_ne (Finset.ne_of_mem_erase hj)]

/-- Splitting the double sum at agent `i`. -/
lemma double_sum_split (p : Fin n → α) (i : Fin n) :
    (∑ j, ∑ k, dis (p j) (p k)) =
      2 * (∑ k ∈ Finset.univ.erase i, dis (p i) (p k)) +
        ∑ j ∈ Finset.univ.erase i, ∑ k ∈ Finset.univ.erase i, dis (p j) (p k) := by
  have hi : i ∈ (Finset.univ : Finset (Fin n)) := Finset.mem_univ i
  rw [← Finset.add_sum_erase _ _ hi, ← Finset.add_sum_erase _ _ hi]
  have hrow : ∀ j, (∑ k, dis (p j) (p k)) =
      dis (p j) (p i) + ∑ k ∈ Finset.univ.erase i, dis (p j) (p k) := fun j =>
    (Finset.add_sum_erase _ _ hi).symm
  simp_rw [hrow, Finset.sum_add_distrib]
  simp_rw [dis_comm _ (p i)]
  simp [dis]
  ring

/-- **Exact potential.** When agent `i` switches to `a`, the potential changes by exactly twice
the change in agent `i`'s own loss. -/
theorem potential_update (pen : α → ℕ) (p : Fin n → α) (i : Fin n) (a : α) :
    potential pen (Function.update p i a) - potential pen p =
      2 * (loss pen p i a - loss pen p i (p i)) := by
  have hi : i ∈ (Finset.univ : Finset (Fin n)) := Finset.mem_univ i
  set q := Function.update p i a with hq
  have hqi : q i = a := by simp [hq]
  have hqj : ∀ j ∈ Finset.univ.erase i, q j = p j := fun j hj => by
    simp [hq, Function.update_of_ne (Finset.ne_of_mem_erase hj)]
  unfold potential loss
  rw [double_sum_split q i, double_sum_split p i,
    ← Finset.add_sum_erase _ _ hi, ← Finset.add_sum_erase (s := Finset.univ) (a := i)
      (f := fun j => (pen (p j) : ℤ)) hi]
  have e1 : ∑ k ∈ Finset.univ.erase i, dis (q i) (q k) =
      ∑ k ∈ Finset.univ.erase i, dis a (p k) :=
    Finset.sum_congr rfl fun k hk => by rw [hqi, hqj k hk]
  have e2 : ∑ j ∈ Finset.univ.erase i, ∑ k ∈ Finset.univ.erase i, dis (q j) (q k) =
      ∑ j ∈ Finset.univ.erase i, ∑ k ∈ Finset.univ.erase i, dis (p j) (p k) :=
    Finset.sum_congr rfl fun j hj => Finset.sum_congr rfl fun k hk => by
      rw [hqj j hj, hqj k hk]
  have e3 : ∑ j ∈ Finset.univ.erase i, (pen (q j) : ℤ) =
      ∑ j ∈ Finset.univ.erase i, (pen (p j) : ℤ) :=
    Finset.sum_congr rfl fun j hj => by rw [hqj j hj]
  rw [e1, e2, e3, hqi]
  ring

/-- A strict improvement by one agent strictly lowers the potential. -/
theorem potential_strict_decrease (pen : α → ℕ) (p : Fin n → α) (i : Fin n) (a : α)
    (h : loss pen p i a < loss pen p i (p i)) :
    potential pen (Function.update p i a) < potential pen p := by
  have := potential_update pen p i a
  linarith

/-- One step of the mesh: some agent switches to an action that strictly lowers its loss. -/
def ImprovingStep (pen : α → ℕ) (p q : Fin n → α) : Prop :=
  ∃ i a, loss pen p i a < loss pen p i (p i) ∧ q = Function.update p i a

/-- **No endless improvement.** No infinite sequence of profiles has every step a strict
unilateral improvement. -/
theorem no_infinite_improvement (pen : α → ℕ) :
    ¬ ∃ s : ℕ → (Fin n → α), ∀ t, ImprovingStep pen (s t) (s (t + 1)) := by
  rintro ⟨s, hs⟩
  have hdec : ∀ t, potential pen (s (t + 1)) < potential pen (s t) := fun t => by
    obtain ⟨i, a, hlt, heq⟩ := hs t
    rw [heq]; exact potential_strict_decrease pen _ i a hlt
  have hbound : ∀ t : ℕ, potential pen (s t) ≤ potential pen (s 0) - t := by
    intro t
    induction t with
    | zero => simp
    | succ t ih => have := hdec t; push_cast; linarith
  have h1 := hbound ((potential pen (s 0)).toNat + 1)
  have h2 := potential_nonneg pen (s ((potential pen (s 0)).toNat + 1))
  have h3 := Int.self_le_toNat (potential pen (s 0))
  push_cast at h1
  linarith

/-- A resting point: no agent can strictly lower its own loss by switching. -/
def IsFixed (pen : α → ℕ) (p : Fin n → α) : Prop :=
  ∀ i a, loss pen p i (p i) ≤ loss pen p i a

/-- **Every resting point is a consensus.** -/
theorem fixed_point_consensus (pen : α → ℕ) (p : Fin n → α) (hp : IsFixed pen p) :
    ∀ i j, p i = p j := by
  intro i j
  by_contra hne
  have hij : i ≠ j := fun h => hne (h ▸ rfl)
  have h1 := hp i (p j)
  have h2 := hp j (p i)
  have hi : i ∈ (Finset.univ : Finset (Fin n)) := Finset.mem_univ i
  have hj : j ∈ (Finset.univ : Finset (Fin n)) := Finset.mem_univ j
  set g : Fin n → ℤ := fun k => dis (p j) (p k) - dis (p i) (p k) with hg
  have key : (∑ k ∈ Finset.univ.erase i, g k) - (∑ k ∈ Finset.univ.erase j, g k) = g j - g i := by
    have a1 := Finset.add_sum_erase _ g hi
    have a2 := Finset.add_sum_erase _ g hj
    linarith
  have hgj : g j = -1 := by simp [hg, dis, hne]
  have hgi : g i = 1 := by simp [hg, dis, Ne.symm hne]
  rw [hgj, hgi] at key
  unfold loss at h1 h2
  simp only [hg, Finset.sum_sub_distrib] at key
  linarith

/-- **Which consensuses rest.** Everyone on `a` (with at least one agent) is a resting point
exactly when `penalty a ≤ penalty b + (n - 1)` for every action `b`. -/
theorem consensus_fixed_iff (pen : α → ℕ) (a : α) (hn : 0 < n) :
    IsFixed pen (fun _ : Fin n => a) ↔ ∀ b, b ≠ a → (pen a : ℤ) ≤ pen b + (n - 1) := by
  have hcount : ∀ i : Fin n, ((Finset.univ.erase i).card : ℤ) = n - 1 := fun i => by
    rw [Finset.card_erase_of_mem (Finset.mem_univ i), Finset.card_univ, Fintype.card_fin]
    push_cast [Nat.one_le_iff_ne_zero.mpr hn.ne']; ring
  have hloss : ∀ (i : Fin n) (b : α), loss pen (fun _ => a) i b =
      (if b = a then 0 else (n - 1 : ℤ)) + pen b := fun i b => by
    unfold loss dis
    by_cases hb : b = a
    · simp [hb]
    · simp only [hb, if_false, Finset.sum_const, nsmul_eq_mul, mul_one]
      rw [hcount i]
  constructor
  · intro h b hb
    have := h ⟨0, hn⟩ b
    rw [hloss, hloss] at this
    simp [hb] at this
    linarith
  · intro h i b
    rw [hloss, hloss]
    by_cases hb : b = a
    · simp [hb]
    · simp [hb]; linarith [h b hb]

end Mesh

/-! ## Marek's register -/

/-- Marek's register as written on the page: each domain's name and its components, in order. -/
def register : List (String × List String) := [
  ⟨"User Experience Layer",
    ["Civilisation.One Website",
     "Member Portal",
     "MirrorME Interface",
     "Research Dashboard",
     "Governance Dashboard",
     "Civilisation.One Administration Console",
     "Developer Portal",
     "Civilisation.Store Interface"]⟩,
  ⟨"MirrorME Personal AI System",
    ["MirrorME Personal Node",
     "MirrorME Professional Node",
     "MirrorME Research Node",
     "Local-first AI runtime",
     "Identity and persona configuration",
     "User-controlled persistent memory",
     "Consent and permission controls",
     "Context and knowledge retrieval",
     "Local file and workspace access",
     "Personal tools and agent workflows",
     "Local-to-platform synchronisation",
     "Audit and provenance records"]⟩,
  ⟨"MKONE Intelligence Architecture",
    ["MKONE Agent Router",
     "Global Intelligence Router",
     "Task decomposition and workflow engine",
     "Model-selection system",
     "Local-model adapter",
     "External-model adapters",
     "Tool-selection and invocation layer",
     "Multi-agent coordination",
     "Structured reasoning pipeline",
     "Uncertainty and confidence evaluation",
     "Safety and policy controls",
     "Evaluation and benchmarking system"]⟩,
  ⟨"AI Model Layer",
    ["Local Ollama models",
     "Civilisation MirrorME model configuration",
     "Cloud AI providers",
     "Specialised research models",
     "Embedding models",
     "Reranking models",
     "Vision and multimodal models",
     "Fine-tuned and adapter-based models",
     "Model registry",
     "Model manifest translator",
     "Inference monitoring",
     "Performance and cost controls"]⟩,
  ⟨"Symbolic Intelligence and Reasoning",
    ["Symbolic Reasoning Engine",
     "MKcode representation system",
     "Typed symbolic addresses",
     "Logic and rule engine",
     "Mathematical-expression representation",
     "Knowledge-graph reasoning",
     "Counterfactual transformation engine",
     "Klein Spiral Mirror",
     "Quantum Reasoning Core",
     "Irreducible Intelligence Logic",
     "Evidence and claim classification",
     "Human-readable reasoning reports"]⟩,
  ⟨"Memory Identity and Persistence",
    ["SEIS-UGFM persistent-state system",
     "Short-term conversational memory",
     "Long-term personal memory",
     "Semantic memory",
     "Episodic memory",
     "Project memory",
     "Synthetic-memory classification",
     "Identity registry",
     "Consent ledger",
     "Memory provenance",
     "Retention and deletion controls",
     "Cross-device state synchronisation"]⟩,
  ⟨"Civilisation.One Knowledge System",
    ["Versioned knowledge repository",
     "Document-ingestion pipeline",
     "Vector database and semantic search",
     "Qdrant collections",
     "Relational database services",
     "Knowledge graph",
     "Dataset catalogue",
     "Research-paper library",
     "Citation and source tracking",
     "Evidence-quality classification",
     "Retrieval-augmented generation",
     "Knowledge update and validation pipeline"]⟩,
  ⟨"Scientific and Engineering Laboratories",
    ["Thin Line Lab",
     "Quantum Reasoning Lab",
     "Quantum Network Simulator",
     "Interstellar Communication Lab",
     "Orbital Radio Telescope research environment",
     "Gross-Pitaevskii equation solvers",
     "Tensor-network and TT-Cross tools",
     "Bose-Einstein condensate simulations",
     "Topological-field simulations",
     "Wave and ocean simulation tools",
     "Vacuum and lattice models",
     "Open quantum-system simulations",
     "Cryptography and protocol testing",
     "Distributed-systems laboratory",
     "Data-analysis and visualisation tools",
     "Reproducible experiment registry"]⟩,
  ⟨"Thin Line Framework",
    ["Thin Line theoretical model",
     "Thin Line mathematical functional",
     "Protocol One 33 Hz processing framework",
     "Phi33 metric",
     "Pattern-versus-noise classification",
     "Topological-state analysis",
     "PFS-4D simulations",
     "Hopfion and soliton experiments",
     "Thin Line Atlas",
     "Validation datasets",
     "Reproducibility tests",
     "Scientific-claim boundary system"]⟩,
  ⟨"Platform Node Architecture",
    ["Centre Node",
     "Country and Government Nodes",
     "MirrorME Member Nodes",
     "Institutional Nodes",
     "Educational Nodes",
     "Research Nodes",
     "Business Nodes",
     "Body and Sensor Nodes",
     "Developer Nodes",
     "Edge-computing Nodes",
     "Platform Gateway Nodes",
     "Backup and Archival Nodes"]⟩,
  ⟨"Governance System",
    ["Omega Centre Node leadership proposal",
     "Omega-1 Core Council proposal",
     "Omega-2 Development Council proposal",
     "Member participation mechanisms",
     "Proposal system",
     "Review and voting mechanisms",
     "Decision ledger",
     "Role and authority management",
     "Conflict-of-interest controls",
     "Transparency and accountability records",
     "Governance audit system",
     "Appeal and dispute-resolution process"]⟩,
  ⟨"Civilisation.One Score",
    ["CV1 Score model",
     "Contribution measurement",
     "Education and skill assessment",
     "Research contribution records",
     "Project participation records",
     "Reliability and verification factors",
     "Transparent scoring rules",
     "Score-history ledger",
     "Appeal and correction mechanism",
     "Anti-manipulation controls",
     "Talent discovery",
     "Sponsorship qualification"]⟩,
  ⟨"Education and Talent System",
    ["Civilisation.One Academy",
     "Age-adaptive learning paths",
     "Mathematics programmes",
     "Physics programmes",
     "AI and programming courses",
     "Engineering programmes",
     "Research-methodology training",
     "Interactive laboratories",
     "Mentorship system",
     "Skills and project portfolios",
     "Certification framework",
     "Talent-discovery engine",
     "Scholarships and sponsorships",
     "Educator and institutional tools"]⟩,
  ⟨"Project and Collaboration System",
    ["Project registry",
     "Team formation",
     "Task and milestone tracking",
     "Research collaboration spaces",
     "Engineering workspaces",
     "Issue and risk tracking",
     "Funding and resource requests",
     "Contributor attribution",
     "Version-controlled documentation",
     "Project evaluation",
     "Public progress reporting",
     "International coordination tools"]⟩,
  ⟨"Communication Architecture",
    ["ChatLink encrypted communication",
     "Agent-to-agent messaging",
     "Typed JSON message format",
     "JSON Schema tool interfaces",
     "Protocol Buffers production messaging",
     "MessagePack or CBOR constrained-link messaging",
     "JSON Lines and streaming events",
     "Notification service",
     "Secure group communication",
     "Inter-node message routing",
     "Communication audit records",
     "Delay-tolerant networking support"]⟩,
  ⟨"Security Trust and Cryptography",
    ["MirrorME Handshake Protocol Two",
     "MK-RITUAL identity handshake",
     "Ed25519 signatures",
     "Cryptographic nonces",
     "Session-key derivation",
     "Transcript binding",
     "Role-claim verification",
     "Device and client fingerprints",
     "Encryption in transit and at rest",
     "Key-management service",
     "Replay-attack protection",
     "Tamper-evident audit chains",
     "Zero-trust access controls",
     "Incident detection and response"]⟩,
  ⟨"Consent Safety and Audit",
    ["Explicit-consent engine",
     "Data-access permissions",
     "Memory-write authorisation",
     "Tool-execution authorisation",
     "Human-approval gates",
     "CFR Auditor",
     "Claim and evidence audit",
     "Model-output evaluation",
     "Risk classification",
     "Immutable audit records",
     "Data export and deletion",
     "Safety-policy enforcement"]⟩,
  ⟨"Data and Infrastructure Layer",
    ["PostgreSQL data services",
     "SQLite local-node storage",
     "Qdrant vector storage",
     "Object and document storage",
     "Knowledge-graph database",
     "Event bus and message queues",
     "Caching services",
     "API gateway",
     "Authentication service",
     "Containerised deployment",
     "Cloud and local infrastructure",
     "Backup and disaster recovery",
     "Monitoring and observability",
     "Configuration and secret management"]⟩,
  ⟨"Developer and Repository Ecosystem",
    ["Civilisation.One web repository",
     "MirrorME repository",
     "LangGraph workflow repository",
     "Modules repository",
     "Router repository",
     "CVscore repository",
     "Organisation profile and documentation repository",
     "MKcode developer toolkit",
     "Shared schemas and protocol definitions",
     "Testing frameworks",
     "Continuous-integration pipelines",
     "Release and version management",
     "Issue and pull-request governance",
     "Software bill of materials"]⟩,
  ⟨"Integration and Synchronisation",
    ["Local Node API",
     "Civilisation.One Platform API",
     "Secure synchronisation gateway",
     "Offline-first operation",
     "Conflict-free replicated data types",
     "State reconciliation",
     "Event synchronisation",
     "Repository integrations",
     "External AI-provider adapters",
     "Research-tool connectors",
     "Institutional integrations",
     "Import and export services"]⟩,
  ⟨"Economic and Funding System",
    ["Membership system",
     "Project-funding mechanisms",
     "Talent sponsorship",
     "Transparent contribution rewards",
     "Grant-management tools",
     "Research-funding records",
     "Budget and expenditure reporting",
     "Economic participation rules",
     "Institutional subscriptions",
     "Commercial licensing",
     "Revenue allocation",
     "Financial accountability controls"]⟩,
  ⟨"Civilisation.Store Integration",
    ["Digital product catalogue",
     "MirrorME editions",
     "MKONE modules",
     "Developer tools and APIs",
     "Educational products",
     "Research reports and publications",
     "Scientific simulation packages",
     "Physical merchandise",
     "AI-node hardware",
     "Institutional services",
     "Licensing and subscriptions",
     "Order, payment and fulfilment systems"]⟩,
  ⟨"Major Strategic Programmes",
    ["MirrorME Personal Intelligence Network",
     "MKONE Modular Intelligence Programme",
     "Thin Line Scientific Research Programme",
     "Civilisation.One Academy",
     "Global Node Network",
     "Talent Sponsorship Programme",
     "Planetary Decision-Support System",
     "Orbital Radio Telescope Programme",
     "Quantum Network Programme",
     "Interstellar Communication Programme",
     "Civilisation.Store Commercial Programme",
     "Long-term Civilisational Planning Programme"]⟩]

/-- All component names, in order. -/
def registerComponents : List String := register.flatMap Prod.snd

theorem register_domain_count : register.length = 23 := by decide +kernel

theorem register_component_count : registerComponents.length = 284 := by decide +kernel

theorem register_distinct_count : registerComponents.dedup.length = 283 := by decide +kernel

theorem register_academy_twice : registerComponents.count "Civilisation.One Academy" = 2 := by
  decide +kernel

end RoundEightSecond

end
