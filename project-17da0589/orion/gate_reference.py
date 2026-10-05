"""Reference sketch of the Round Three execution gate.

This mirrors the specification in RequestProject/Orion/Gate.lean (the Lean file states and
proves the properties; this file is an executable sketch with self-tests, not a proof about
any production code).

Differences from the `check_execution_eligibility` draft in the Round Three document:

* W_map, W_residue and standing are looked up from registries supplied by other parties;
  they are not booleans the calling AI passes in about itself.
* The pre-delegated envelope is a bounded object (listed levers, listed deeds, per-use
  blast/residue caps, expiry, use counter), not a boolean.
* Jurisdiction is checked over every deed in the blast footprint.
* A failed witness under a real plight returns HALT_OR_REVERSE instead of ASK, so the gate
  never leaves an emergency with no available move.
* Messages say which check failed (the draft reported "AI inferred emergency" even when a
  properly authorised request merely lacked a witness).

Run:  python3 orion/gate_reference.py
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, FrozenSet, Optional, Tuple


@dataclass(frozen=True)
class Envelope:
    actions: FrozenSet[str]
    domains: FrozenSet[str]
    max_blast: int
    max_residue: int
    expiry: int
    max_uses: int


@dataclass(frozen=True)
class Request:
    action: str
    footprint: FrozenSet[str]
    blast: int
    residue: int
    time: int
    uses_so_far: int


@dataclass(frozen=True)
class Context:
    plight: bool                               # independent sensors, not the actor
    attested: Callable[[str], bool]            # W_map registry
    residue_known: Callable[[str], bool]       # W_residue audit
    standing: Callable[[str], bool]            # deed registry
    authorized: Callable[[str], bool]          # standing human authority
    envelope: Optional[Envelope] = None        # signed before the event


def within_envelope(e: Envelope, r: Request) -> bool:
    return (r.action in e.actions and r.footprint <= e.domains
            and r.blast <= e.max_blast and r.residue <= e.max_residue
            and r.time < e.expiry and r.uses_so_far < e.max_uses)


def decide(c: Context, r: Request) -> Tuple[str, str]:
    """Return (verdict, reason) with verdict in COMMIT / HALT_OR_REVERSE / ASK."""
    fallback = "HALT_OR_REVERSE" if c.plight else "ASK"
    if not c.attested(r.action):
        return fallback, "W_map UNKNOWN: novel unauthorised actuation prohibited"
    if not c.residue_known(r.action):
        return fallback, "W_residue UNKNOWN"
    missing = sorted(d for d in r.footprint if not c.standing(d))
    if missing:
        return fallback, f"no standing J(a,s,d) in {missing}"
    if not c.plight:
        return "ASK", "W_plight not independently established"
    if c.authorized(r.action):
        return "COMMIT", "authorised execution"
    if c.envelope is not None and within_envelope(c.envelope, r):
        return "COMMIT", "inside pre-delegated emergency envelope"
    return "HALT_OR_REVERSE", "no authority; AI-inferred emergency is not authority"


def _self_test() -> None:
    env = Envelope(frozenset({"close_valve_7"}), frozenset({"U1"}), 3, 0, 100, 2)
    base = dict(attested=lambda a: a == "close_valve_7", residue_known=lambda a: True,
                standing=lambda d: d == "U1", authorized=lambda a: False, envelope=env)
    ok = Request("close_valve_7", frozenset({"U1"}), 2, 0, 10, 0)

    assert decide(Context(plight=True, **base), ok)[0] == "COMMIT"
    # Unmapped lever: never COMMIT, however real the emergency.
    unmapped = Request("emergency_unlock", frozenset({"U1"}), 1, 0, 10, 0)
    assert decide(Context(plight=True, **base), unmapped)[0] == "HALT_OR_REVERSE"
    # Footprint spills into a deed without standing.
    spill = Request("close_valve_7", frozenset({"U1", "U2"}), 2, 0, 10, 0)
    assert decide(Context(plight=True, **base), spill)[0] == "HALT_OR_REVERSE"
    # Envelope exhausted, expired, or blast over cap.
    for bad in (Request("close_valve_7", frozenset({"U1"}), 2, 0, 10, 2),
                Request("close_valve_7", frozenset({"U1"}), 2, 0, 100, 0),
                Request("close_valve_7", frozenset({"U1"}), 4, 0, 10, 0)):
        assert decide(Context(plight=True, **base), bad)[0] == "HALT_OR_REVERSE"
    # No plight: nothing commits, and the answer is ASK.
    assert decide(Context(plight=False, **base), ok)[0] == "ASK"
    print("gate_reference: all self-tests passed")


if __name__ == "__main__":
    _self_test()
