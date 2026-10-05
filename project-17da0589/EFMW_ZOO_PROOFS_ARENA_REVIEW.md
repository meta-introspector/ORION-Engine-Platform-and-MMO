# EFMW Zoo → Orion Proofs Arena — review

**Sources (read 2 October 2026):**
1. Google Doc "Matthews zoo for comparative creature builds and proofs arena" (`1Pp_Pvbs…`): Grok's *EFMW Zoo → Orion Proofs Arena — Complete Design Compilation* (46-animal roster, arena rules, boss kits, items, platform hooks).
2. Word file `1rfBxk9w…`: *THE EFMW ZOO — Inventory, Habitats & Interrelationships*, v1, 23 animals, dated 20 August 2026 (Matthew's inventory).

The checkable parts are stated and proved in `RequestProject/Zoo/Arena.lean`. It builds with no `sorry` and uses only the standard axioms. As in earlier rounds, the proofs cover the rules **as written in the documents**. There is no arena code yet, so they say nothing about an implementation, and nothing here evaluates the science behind any animal.

---

## 0. Notes for collaborators

- **Matthew (enuminous).** Your inventory survived its translation into a game well. Three things changed on the way, though (§2): rule 6 lost "or an independently justified causal design", rule 10 lost "correlated", and TORTOISE fell out of the gauntlet. Please also confirm the Ring 2 (#24–46) one-line functions. They come from Grok, not from the inventory.
- **Whoever codes the arena.** Fix the veto list before building the state machine (§3, item 4). `hedgehog_conditional_only` is listed as a veto, but habitat-conditional success is supposed to be a *pass with a label*. OWL provenance failure has no flag at all. Also decide how re-entry is limited (§4.2).
- **Education Hub.** "Failed runs preserved as teaching cases" needs the claim owner's consent or anonymisation (§5).
- **UI/UX.** The word "published" should say "Proofs Arena published", so nobody mistakes it for peer review (§5).

---

## 1. What checks out

- **The 46-animal roster.** It matches Matthew's public `Monolithic-Zoo-Lean4` repository on GitHub. Its `Registry.lean` lists the same 46 names in the same order. That repository describes itself as an "uncompiled formalization draft", so this confirms the *names and order* only. Each of the 46 animals also has its own public repository under the same account. I did not compare their contents with Grok's Ring 2 descriptions.
- **Ring 1 (#1–23).** The names and order match the v1 inventory exactly. Proved: `coreRoster_spec` (46 entries, no duplicates, first 23 = the inventory). Grok's one-line functions for #1–23 are fair short versions of the inventory cards.
- **The expanded names.** All 23 expanded names in the inventory spell their animal through their capital letters, e.g. *Feedback Oscillation eXplorer* → FOX and *Top-level Unification of Recursive Transformations, Layers and Emergence* → TURTLE. Proved: `inventory_names_spell_animals`.
- **"50" vs 46.** Treating 46 as the frozen Core and #47+ as out-of-sample extensions agrees with the repository. The same account also has repositories named Chimera, Nightengale, Harlequinn and woodpecker. These may be candidates for #47+, but nothing in either document says so.

## 2. Where the compilation differs from Matthew's inventory

| # | Inventory (v1) | Compilation | Recommendation |
|---|---|---|---|
| 1 | Rule 6: causal language requires intervention **or an independently justified causal design**. CROCODILE is the *preferred* path. | "Causal language requires intervention (CROCODILE path)." The table makes CROCODILE required for every causal claim. | Restore the alternative. Otherwise causal claims that can't be perturbed (natural experiments, historical data) can never pass. Let them reach TURTLE through a "justified design" route, with that labelled on the audit trail. |
| 2 | Rule 10: strong falsification can veto a pile of **correlated** positives. | "…can veto a pile of positives." | Small. The veto-first rule in §3 handles both readings, but quote the original. |
| 3 | Foundation layer: **OWL → TORTOISE**. TORTOISE "provides the common test discipline for the entire zoo". | The gauntlet starts at OWL and never calls TORTOISE. | Add TORTOISE as step 1b (frozen protocol run), or say explicitly that every fight runs under TORTOISE rules. |
| 4 | No Ring 2, no game layer. | Ring 2 functions, VFX, items, badges, enrage. | Label all of this as game adaptation, so it isn't read as part of Matthew's framework. |
| 5 | The inventory names no author. | "Matthew's (@enuminous)". | Matches the copyright line in the GitHub repository. Use the attribution rules adopted in Round Four. Questions about reuse terms go to Matthew. I can't advise on licensing. |

## 3. Contradictions inside the compilation

1. **HEDGEHOG: who must face it?** §4 step 4 says it is "required for universal claims". The §6 table lists it as *required* for **generic predictive lift**. Pick one. The inventory's habitat language suggests requiring it always, with "habitat-conditional" as an accepted outcome.
2. **The skeptic wave.** §4 says RAVEN → CAT → BAT is *required*. In the §6 table, CAT is only *recommended* for generic claims, and RAVEN doesn't appear anywhere.
3. **"Discovery wave (subset of OCTOPUS…MOTH)".** As a range of roster numbers this is #3–#16. That range also contains **CAT and RAVEN** (skeptic wave) and **SHEPHERD and PULSE** (domain safety). Proved: `discovery_range_overlaps`. Use the inventory's explicit list instead: OCTOPUS, GECKO, HIVE, EAGLE, CRAB, FOX, SPIDER, DOLPHIN, ANT, MOTH.
4. **The veto flags don't match the rules.**
   - `hedgehog_conditional_only` is listed as a *veto flag*. But rule 4 and the HEDGEHOG kit both say an explicit habitat-conditional label is a **pass**. Make it an outcome label, not a veto. It should block only a claim that insists on being universal.
   - Along the same lines, "Lose = … habitat-only lock" should read "Lose = claims universality but only holds in its home habitat".
   - Rule 8 says provenance failure contaminates everything downstream, but OWL has no flag. Add `owl_provenance_break`. It should invalidate the run *and* every later run that used the same evidence.
5. **"No HP combat" vs "optional enrage for high-tier publish".** "Enrage" is an HP-boss idea. Define it as stricter, pre-registered thresholds (for example a harder baseline or more held-out habitats), and nothing else.
6. **The "+" in the §6 table** ("Causal mechanism: + CROCODILE, CAT") presumably means "the generic required set plus these". Say so in the table header.

## 4. Mechanics with arithmetic in them

### 4.1 TURTLE is not majority rule (proved)

Model: each run has an evidence cluster and an outcome (pass / fail / veto). TURTLE publishes when there is no veto and at least one independent positive. Positives are counted once per cluster.

- `veto_dominates`: once any run has vetoed, **no amount of added evidence** makes TURTLE publish.
- `duplicate_in_cluster_counts_once`: a second passing run in a cluster that already passed doesn't change the count of independent positives.
- `majority_flipped_by_copies`: start with one veto and one pass. Copy the pass twice inside its own cluster. A plain majority vote now publishes; TURTLE still doesn't.

This is what rules 3, 10 and 11 ask for. The proofs show that the simple veto-first rule above meets them. Your rules don't say exactly how TURTLE's invariant extraction works, so this model only fixes the publish/no-publish decision.

### 4.2 Unlimited re-entry is a loophole (proved)

The re-entry rule is "fail → fix evidence → new OWL freeze → re-queue", with no limit. Suppose a claim is actually false, but on each attempt it slips through with some fixed chance. Then the chance that it has been stopped *every* time goes to zero as attempts pile up. So with enough retries, a false claim is almost certain to be published eventually. Proved: `unlimited_reentry_eventually_passes` (assumes each attempt is stopped independently with the same probability \(q < 1\)).

**Fix.** Give each claim a total error budget \(\alpha\) and split it across attempts (\(\alpha_1 + \alpha_2 + \dots \le \alpha\), e.g. halve it each time). Then the chance that a false claim ever gets through stays at most \(\alpha\), *without* any independence assumption. Proved: `error_budget_bounds_reentry`. Practical versions:
- show the attempt number on the audit trail;
- tighten the BAT threshold on each re-entry;
- require fresh held-out habitats for HEDGEHOG on re-entry;
- "Failures are kept" already makes this auditable, which is good.

## 5. Privacy and safety (recommendations only)

- **Failed runs as teaching cases.** Make this opt-in, or strip the owner's identity first. This matches the privacy baseline adopted in earlier rounds.
- **Share cards and "no surveillance beyond the OWL freeze".** Both agree with the earlier baseline. Keep them.
- **"Published".** Inside the game this means "survived the gauntlet". Label it as Proofs Arena status so it isn't confused with peer-reviewed publication. This matters most for PULSE/SHARK ("safety-critical / clinical") claims: surviving a game boss is not clinical or safety validation, and the UI should say so.
- **Ghost Rider mapping.** Linking HORSE / ORCA / COBRA / SHEPHERD to intent-safety evaluation is a reasonable design analogy. It doesn't replace the refuse-first rule adopted in Round Four.

## 6. Not checked

- Whether Grok's Ring 2 functions (#24–46) match Matthew's per-animal repositories.
- Whether any animal's method works scientifically. The Zoo's own README says the formal contracts "do not establish that real systems satisfy those assumptions".
- The boss kits not written out in the compilation ("remaining animals use the same pattern").
