"""Minimal Python port of the ORION hub rules, tested against golden_vectors.json.

This is a starting point for the platform/game teams, not a verified implementation:
the Lean files are the reference, and this port is only checked on the golden vectors.
Run:  python3 conformance/reference.py
"""
import json
import math
from fractions import Fraction as F
from pathlib import Path

TIER = {"primary": F(1), "audit": F(4, 5), "secondary": F(1, 2), "unverified": F(1, 10)}
RIGOR = {"cryptographic": F(1), "disclosed": F(4, 5), "opaque": F(1, 10)}


def corroboration(rigor, n):
    r = RIGOR[rigor]
    return F(1) if r < F(4, 5) else min(1 + F(n, 10), F(3, 2))


def evidence_weight(tier, rigor, n, d=F(0)):
    return TIER[tier] * RIGOR[rigor] * corroboration(rigor, n) * (1 - d)


def best(items):
    return max((evidence_weight(e["tier"], e["rigor"], e["sources"]) for e in items), default=F(0))


def claim_score(support, conflict):
    bs, bc = best(support), best(conflict)
    d = F(1) if bs == 0 else min(F(1), bc / bs)
    return bs * (1 - d) / F(3, 2)


def level_of(k, xp):
    return min(13, 1 + math.floor(max(F(0), xp) / k))


def meter_run(alpha, m, events):
    for s in events:
        m = (1 - alpha) * m + alpha * s
    return m


def admit(human_approved, frozen_before_outcome, vetoes):
    return human_approved and frozen_before_outcome and not any(vetoes)


PHASES = ["define", "retrieve", "evaluate", "connect", "generate", "attack", "refine",
          "human_review", "test", "record", "reuse"]


def step_ok(p, q):
    i, j = PHASES.index(p), PHASES.index(q)
    return j == i + 1 or j < i


def stop_reasons(enough_evidence, acceptable_risk, authorized):
    return ([] if enough_evidence else ["evidence"]) + \
        ([] if acceptable_risk else ["safety"]) + \
        ([] if authorized else ["authority"])


def can_resume(actor, *flags):
    return actor == "operator" and not stop_reasons(*flags)


def rung_level(step, turns):
    return min(8, sum(turns) // step)


def debate(limit, converges):
    for k in range(limit):
        if converges(k):
            return k
    return "escalate_to_catalyst"


def ledger_guard(current, proposed):
    return proposed if proposed[:len(current)] == current else None


def check_engine(check):
    e = json.loads((Path(__file__).parent / "engine_vectors.json").read_text())
    for c in e["step"]["cases"]:
        check(c, step_ok(c["from"], c["to"]), c["expected"])
    flags = lambda c: (c["enough_evidence"], c["acceptable_risk"], c["authorized"])
    for c in e["stops"]["cases"]:
        check(c, stop_reasons(*flags(c)), c["expected"])
    for c in e["resume"]["cases"]:
        check(c, can_resume(c["actor"], *flags(c)), c["expected"])
    for c in e["ladder"]["cases"]:
        check(c, rung_level(e["ladder"]["step"], c["turns"]), c["expected"])
    for c in e["debate"]["cases"]:
        check(c, debate(c["limit"], lambda k: k in c["converging_rounds"]), c["expected"])
    for c in e["ledger_guard"]["cases"]:
        check(c, ledger_guard(c["current"], c["proposed"]), c["expected"])


def main():
    v = json.loads((Path(__file__).parent / "golden_vectors.json").read_text())
    fails = 0

    def check(name, got, want):
        nonlocal fails
        if got != want:
            fails += 1
            print(f"FAIL {name}: got {got}, expected {want}")

    for c in v["evidence_weight"]["cases"]:
        check(c, evidence_weight(c["tier"], c["rigor"], c["sources"], F(c["d"])), F(c["expected"]))
    ev = v["claim_score"]["evidence"]
    for c in v["claim_score"]["cases"]:
        got = claim_score([ev[x] for x in c["support"]], [ev[x] for x in c["conflict"]])
        check(c, got, F(c["expected"]))
    for c in v["level"]["cases"]:
        check(c, level_of(F(10), F(c["xp"])), c["expected"])
    for c in v["meter"]["cases"]:
        check(c, meter_run(F(1, 4), F(1, 2), [F(s) for s in c["events"]]), F(c["expected"]))
    for c in v["zoo_admit"]["cases"]:
        check(c, admit(c["human_approved"], c["frozen_before_outcome"], c["vetoes"]), c["expected"])

    check_engine(check)

    print("all golden vectors pass" if fails == 0 else f"{fails} failure(s)")
    raise SystemExit(1 if fails else 0)


if __name__ == "__main__":
    main()
