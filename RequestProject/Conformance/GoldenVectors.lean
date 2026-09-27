module

public import RequestProject.Hub.ZooGate
public import RequestProject.Hub.Progression
public import RequestProject.Hub.Meters

/-!
# Golden test vectors for the game and platform builds

These are fixed input/output pairs for the hub's rules: evidence weight, claim score,
level, meter and admission gate. Lean checks every pair against the reference definitions,
so each value below is exactly what the definition computes.

A developer porting the rules to TypeScript, Rust, C# (Unity) or Python can copy the table
into a unit test. If the port gives a different answer on any row, the port has a bug (or the
rule was changed on purpose, and this file should be updated with it).

All numbers are exact fractions. A port should use exact rational or fixed-point arithmetic,
or compare floats with a small tolerance.
-/

@[expose] public section

namespace OrionConformance

open SnakeAndScale OrionHub

/-! ## 1. Evidence weight `W(e) = S_t × R_m × C_i × (1 − D_r)` -/

theorem W_primary_crypto_5_0 : evidenceWeight .primary .cryptographic 5 0 = 3 / 2 := by
  norm_num [evidenceWeight, corroboration, SourceTier.weight, Rigor.weight]
theorem W_primary_crypto_6_0 : evidenceWeight .primary .cryptographic 6 0 = 3 / 2 := by
  norm_num [evidenceWeight, corroboration, SourceTier.weight, Rigor.weight]
theorem W_primary_crypto_0_0 : evidenceWeight .primary .cryptographic 0 0 = 1 := by
  norm_num [evidenceWeight, corroboration, SourceTier.weight, Rigor.weight]
theorem W_audit_disclosed_3_0 : evidenceWeight .audit .disclosed 3 0 = 104 / 125 := by
  norm_num [evidenceWeight, corroboration, SourceTier.weight, Rigor.weight]
theorem W_secondary_disclosed_2_quarter :
    evidenceWeight .secondary .disclosed 2 (1 / 4) = 9 / 25 := by
  norm_num [evidenceWeight, corroboration, SourceTier.weight, Rigor.weight]
theorem W_unverified_opaque_100_0 : evidenceWeight .unverified .opaque 100 0 = 1 / 100 := by
  norm_num [evidenceWeight, corroboration, SourceTier.weight, Rigor.weight]
theorem W_primary_opaque_9_0 : evidenceWeight .primary .opaque 9 0 = 1 / 10 := by
  norm_num [evidenceWeight, corroboration, SourceTier.weight, Rigor.weight]
theorem W_primary_crypto_5_one : evidenceWeight .primary .cryptographic 5 1 = 0 := by
  norm_num [evidenceWeight, corroboration, SourceTier.weight, Rigor.weight]

/-! ## 2. Claim score (hub reliability, normalised to `[0, 1]`) -/

/-- Primary source, cryptographic proof, 5 independent sources. -/
def eGold : Evidence := ⟨.primary, .cryptographic, 5⟩
/-- Independent audit, disclosed method, 3 sources. -/
def eAudit : Evidence := ⟨.audit, .disclosed, 3⟩
/-- Secondary synthesis, disclosed method, no extra sources. -/
def eBlog : Evidence := ⟨.secondary, .disclosed, 0⟩
/-- Unverified, opaque, repeated by 50 accounts. -/
def eRumour : Evidence := ⟨.unverified, .opaque, 50⟩

theorem score_gold_alone : claimScore [eGold] [] = 1 := by
  norm_num [claimScore, discrepancy, best, Evidence.baseWeight, evidenceWeight, corroboration,
    SourceTier.weight, Rigor.weight, eGold]
theorem score_audit_alone : claimScore [eAudit] [] = 208 / 375 := by
  norm_num [claimScore, discrepancy, best, Evidence.baseWeight, evidenceWeight, corroboration,
    SourceTier.weight, Rigor.weight, eAudit]
theorem score_audit_vs_blog : claimScore [eAudit] [eBlog] = 36 / 125 := by
  norm_num [claimScore, discrepancy, best, Evidence.baseWeight, evidenceWeight, corroboration,
    SourceTier.weight, Rigor.weight, eAudit, eBlog]
theorem score_blog_vs_audit : claimScore [eBlog] [eAudit] = 0 := by
  norm_num [claimScore, discrepancy, best, Evidence.baseWeight, evidenceWeight, corroboration,
    SourceTier.weight, Rigor.weight, eAudit, eBlog]
theorem score_rumours_only : claimScore [eRumour, eRumour, eRumour] [] = 1 / 150 := by
  norm_num [claimScore, discrepancy, best, Evidence.baseWeight, evidenceWeight, corroboration,
    SourceTier.weight, Rigor.weight, eRumour]
theorem score_no_support : claimScore [] [eRumour] = 0 := by
  norm_num [claimScore, discrepancy, best, Evidence.baseWeight, evidenceWeight, corroboration,
    SourceTier.weight, Rigor.weight, eRumour]
theorem score_gold_vs_rumour : claimScore [eGold, eBlog] [eRumour] = 149 / 150 := by
  norm_num [claimScore, discrepancy, best, Evidence.baseWeight, evidenceWeight, corroboration,
    SourceTier.weight, Rigor.weight, eGold, eBlog, eRumour]

/-! ## 3. Level on the 13-level path (`k = 10` XP per level) -/

theorem level_0 : levelOf 10 0 = 1 := by norm_num [levelOf]
theorem level_9_99 : levelOf 10 (999 / 100) = 1 := by norm_num [levelOf]
theorem level_10 : levelOf 10 10 = 2 := by norm_num [levelOf]
theorem level_57 : levelOf 10 57 = 6 := by norm_num [levelOf]
theorem level_120 : levelOf 10 120 = 13 := by norm_num [levelOf]
theorem level_5000 : levelOf 10 5000 = 13 := by norm_num [levelOf]
theorem level_negative : levelOf 10 (-5) = 1 := by norm_num [levelOf]

/-! ## 4. Kronos/Orion meter (running average, `α = 1/4`, start at `1/2`) -/

theorem meter_one_orion_event : OrionMeters.run (1 / 4) (1 / 2) [1] = 5 / 8 := by
  norm_num [OrionMeters.run, OrionMeters.step]
theorem meter_three_events : OrionMeters.run (1 / 4) (1 / 2) [1, 0, 1] = 77 / 128 := by
  norm_num [OrionMeters.run, OrionMeters.step]
theorem meter_empty_history : OrionMeters.run (1 / 4) (1 / 2) [] = 1 / 2 := by
  norm_num [OrionMeters.run]

/-! ## 5. Zoo admission gate (human approval, preregistered, list of auditor vetoes) -/

theorem admit_all_clear : admit ⟨true, true, [false, false, false]⟩ = true := by decide
theorem admit_one_veto : admit ⟨true, true, [false, true, false]⟩ = false := by decide
theorem admit_no_human : admit ⟨false, true, []⟩ = false := by decide
theorem admit_not_frozen : admit ⟨true, false, [false]⟩ = false := by decide
theorem admit_no_auditors : admit ⟨true, true, []⟩ = true := by decide

end OrionConformance
