"""Loom seed v1 of locked ORION rulings (adopted on ORION R8: "💎 so pretty much what I just asked for").

Extends the R8b draft (orion/r8b/loom_seed_draft.py) with the rulings written under the R8 reply
and on ORION R9 Live. Owner-approved changes go in as a new contract revision; anything else that
contradicts a seeded ruling is rejected.

Usage: python3 loom_seed_v1.py PATH/TO/loom_mythos_continuity_v0_2 OUTPUT.json

Builds a Loom/Mythos v0.2 archive (Ryan's package, re-attached on ORION R8 Live) with one
contract and one fact per ruling on branch "main", then shows that a contradicting fact
(tax 2%) is flagged VIOLATED and rejected without changing the archive.
"""
import json, sys, copy
sys.path.insert(0, sys.argv[1])
from loom_mythos.kernel import Kernel

SRC = lambda where: [{"id": "orion-rulings", "locator": where, "lineage": "A. Beth Jones rulings on the ORION Notion pages",
                      "note": "Design ruling recorded by Aristotle; fictional game canon, not empirical evidence"}]

# (key, value, where it was ruled)
RULINGS = [
    ("name.project", "The ORION Engine", "ORION R7 Live (locked)"),
    ("name.landing_page", "ORION's Gate", "ORION R7 Live (locked); landing page per R8"),
    ("name.social", "The Playground", "ORION R7 Live (locked)"),
    ("name.mmo", "The Orion Chronicles", "ORION R7 Live (locked)"),
    ("name.education", "The Ascent", "ORION R7 Live (locked)"),
    ("name.poly", "Path of the Living Ylem", "ORION R7 💎 / R8 Live (locked)"),
    ("economy.tax_percent", 3, "ORION R8 Live: 3% across all taxable incomes"),
    ("economy.surplus_orb_exchange_percent", 50, "ORION R8 Live"),
    ("orbs.skill_cap", 100, "ORION R7 Live (R7c)"),
    ("orbs.grid_size", 64, "ORION R7 Live (R7c) / R8 Live"),
    ("level.dragon_rider", 65, "ORION R8 Live: meditate with the 64-orb grid"),
    ("dragon.matrix_nodes", 144, "Round 3 / R7c"),
    ("phoenix.one_element_permille", 1100, "Round 5 (+10%) / R8 taper"),
    ("phoenix.five_element_permille", 1000, "ORION R8 Live taper"),
    ("council.strikes", 3, "ORION R6 / R7"),
    ("council.cooloff_days", 7, "ORION R7 Live"),
    # added in Round 9
    ("orbs.player_matrix_nodes", 64, "ORION R8 (answers): the player's matrix has 64 nodes"),
    ("orbs.slot_requires_level", 100, "ORION R8 (answers): gold-locked 100 times before it can be equipped"),
    ("orbs.starter_orbs", 64, "ORION R8 (answers): everybody starts off with 64"),
    ("orbs.locked_slot_krion_bonus_percent", 25, "ORION R8 (answers): 25% increase to KRION energy management"),
    ("orbs.levels_craftable", False, "ORION R8 (answers): levels are carried by trading/transmuting, not crafted"),
    ("dragon.ordinary_element_path", "player-chosen, one element at a time", "ORION R8 (answers) 💎"),
    ("skybox.access_set_by", "owner or DEV", "ORION R8 (answers) 💎"),
    ("governance.change_pipeline", "active creator (or whole DEV team if inactive/mutated) -> Galactic council -> human", "ORION R9 Live"),
]

k = Kernel()
k.commit("world_contract", "main", {
    "revision": 1, "previous_revision": 0, "register": "fictional",
    "sources": SRC("ORION_RUNNING_ROSTER.md (locked rulings)"),
    "constraints": [{"id": f"canon-{key}", "key": key, "op": "equals", "value": value} for key, value, _ in RULINGS]})
for key, value, where in RULINGS:
    k.commit("world_fact", "main", {"id": f"seed-{key}", "key": key, "value": value,
                                    "register": "fictional", "sources": SRC(where)})
k.save(sys.argv[2])

report = k.conflicts("main")
print("seeded", len(RULINGS), "rulings; verdicts:", sorted({r["verdict"] for r in report["constraints"]}) if isinstance(report, dict) and "constraints" in report else report)
head = k.snapshot()["head"]
bad = {"id": "stale-tax", "key": "economy.tax_percent", "value": 2, "register": "fictional",
       "sources": SRC("deliberate test: a stale page repeating the old 2% rate")}
preview = k.conflicts("main", bad)
print("preview of a deliberately stale 2% tax fact (test only): consistent =", preview["consistent_known_facts"],
      "| violated:", [(r["constraint"]["key"], r["constraint"]["value"], r["actual"]) for r in preview["constraints"] if r["verdict"] == "VIOLATED"])
try:
    k.commit("world_fact", "main", bad)
    print("UNEXPECTED: stale fact accepted")
except Exception as exc:
    print("commit rejected:", exc)
print("archive head unchanged:", k.snapshot()["head"] == head)
