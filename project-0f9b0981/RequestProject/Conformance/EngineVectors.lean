module

public import RequestProject.Orion.Engine

/-!
# Golden test vectors for the ORION Engine orchestration rules

Fixed input/output pairs for the rules in `RequestProject/Orion/Engine.lean`: the loop's
permitted moves, the Independent Stop Mechanism, resume rights, the intervention ladder, the
debate loop and the decision-ledger guard. Lean checks every row. The same rows are in
`conformance/engine_vectors.json`, and `conformance/reference.py` checks a Python port
against them.
-/

@[expose] public section

namespace OrionConformance

open Orion

/-! ## 1. Permitted moves in the eleven-phase loop -/

instance (p q : Phase) : Decidable (Step p q) := by unfold Step; infer_instance

theorem step_attack_generate : Step .attack .generate := by decide
theorem step_reuse_define : Step .reuse .define := by decide
theorem step_review_test : Step .humanReview .test := by decide
theorem step_define_evaluate : ¬ Step .define .evaluate := by decide
theorem step_refine_test : ¬ Step .refine .test := by decide
theorem step_generate_review : ¬ Step .generate .humanReview := by decide

/-! ## 2. Independent Stop Mechanism -/

theorem stops_none : stopReasons ⟨true, true, true⟩ = [] := by decide
theorem stops_evidence : stopReasons ⟨false, true, true⟩ = [.evidence] := by decide
theorem stops_safety_authority :
    stopReasons ⟨true, false, false⟩ = [.safety, .authority] := by decide
theorem stops_all : stopReasons ⟨false, false, false⟩ = [.evidence, .safety, .authority] := by
  decide

theorem resume_user_clear : canResume .user ⟨true, true, true⟩ = false := by decide
theorem resume_operator_clear : canResume .operator ⟨true, true, true⟩ = true := by decide
theorem resume_operator_unsafe : canResume .operator ⟨true, false, true⟩ = false := by decide

/-! ## 3. Intervention ladder (`step = 10` risk points per rung) -/

theorem ladder_empty : rungLevel 10 [] = 0 := by decide
theorem ladder_low : rungLevel 10 [3, 4] = 0 := by decide
theorem ladder_ten : rungLevel 10 [9, 1] = 1 := by decide
theorem ladder_single_25 : rungLevel 10 [25] = 2 := by decide
theorem ladder_fragmented_25 : rungLevel 10 [5, 5, 5, 5, 5] = 2 := by decide
theorem ladder_cap : rungLevel 10 [30, 30, 30] = 8 := by decide
theorem ladder_rung_top : rung 10 [30, 30, 30] = .endInteraction := by decide
theorem ladder_rung_clarify : rung 10 [9, 1] = .clarify := by decide

/-! ## 4. Debate loop (Operation Snake and Scale) -/

theorem debate_converges_at_3 :
    debate 5 (fun k => decide (k = 3 ∨ k = 4)) = .converged 3 := by decide
theorem debate_never : debate 5 (fun _ => false) = .escalateToCatalyst := by decide
theorem debate_too_late : debate 3 (fun k => decide (k = 3)) = .escalateToCatalyst := by decide

/-! ## 5. Decision-ledger guard -/

theorem guard_extend : guard [1, 2] [1, 2, 3] = some [1, 2, 3] := by decide
theorem guard_edit : guard [1, 2] [1, 5] = none := by decide
theorem guard_delete : guard [1, 2] [1] = none := by decide

end OrionConformance
