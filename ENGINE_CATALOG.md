# TGS:ATE Engine Architecture Catalog — what it adds

Source: the Google Doc "TGS:ATE Engine Architecture Catalog" (rough draft / synthesis catalog).

## Short answer

Yes, in three concrete ways, although it adds no new physics to test:

1. **It supplies the claim-status labels the hub needs.** Its §V table says, for each engine,
   whether it makes a physical energy claim. That maps directly onto the Zoo gate's statuses:
   eight engines are geometry, process, rendering or practice models, and exactly one (TVT) is a
   physical hypothesis. Filed as *proposed*, TVT scores 0 in the hub until an observed or
   replicated result arrives. The Lean file proves this follows from the existing Zoo-gate rules.
2. **It is internally consistent.** Encoded as data, the table has exactly one energy hypothesis
   (TVT), which agrees with the §VIII one-sentence summary. The §IV nesting picture uses six
   different engines with no repeats, and none of them is the energy hypothesis.
3. **It clears up the earlier "infinite energy / zero point" wording.** The catalog itself says
   those phrases are framework terms, not device claims. That matches how earlier rounds handled
   them.

## What was checked in Lean (`RequestProject/Submissions/EngineCatalog.lean`)

| Result | Lean name |
|---|---|
| Nine engines; exactly one (TVT) makes a physical energy claim | `card_engines`, `energy_claim_iff_tvt` |
| Six engines are a plain "No" in the table | `no_claim_count` |
| Nesting picture: six distinct engines, none an energy hypothesis | `nest_nodup`, `nest_no_hypothesis` |
| The energy branch contains exactly one hypothesis, TVT | `energyBranch_hypotheses` |
| Proposed/derived/simulated records (e.g. TVT today) score 0 | `proposed_records_score_zero` |
| J = 3: three equal pushes 120° apart cancel exactly | `j3_zero_net_torque` |
| The five 5:2 equatorial aspects also cancel; so does any n ≥ 2; n = 1 does not | `five_aspects_zero_net`, `netPush_eq_zero`, `netPush_one` |
| 5 + 2 = 7, 3 + 1 + 3 = 7, 97 + 3 = 100 | `catalog_sums` |
| "120-point boundary": a dodecahedron has 120 flags, counted three ways | `dodecahedron_flags` |

A caveat on J = 3: zero net torque from equally spaced beats is **not special to 3**. Any
two or more equally spaced beats cancel. What 3 gives is the smallest balanced set that is not
just a back-and-forth pair along one line.

## What cannot be checked

- The TVT equation is described only as "symbolic", and the catalog does not reproduce it, so
  there is nothing to check yet. If a falsifiable TVT paper is written (catalog §VII.2), its
  predictions could be entered in the hub's append-only prediction ledger before any test.
- RPTF ↔ dark energy, and 144 → 000 as extractable energy: the catalog itself lists these as not
  provided (§VI).

## Suggested use in the platform

- Add the nine engines as claims in the web app's Claims tab, with the §V column as their status.
  Only TVT should ever be able to earn an evidence score from physical measurements.
- The §IV nesting picture could serve as the level map for the Totality "room → house → world"
  scaling: the proved Totality guarantees hold at every scale, so they apply to each shell.
