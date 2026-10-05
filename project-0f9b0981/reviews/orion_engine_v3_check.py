"""Reproducer for the review of "ORION ARCHITECT: FINAL BUILD" (ORION ENGINE v3.0), core/orion_engine.py.

The class below is copied verbatim from the document (the GhostRiderProtocol section).
Run:  python3 reviews/orion_engine_v3_check.py
"""
from typing import Tuple, Dict, Any

class GhostRiderProtocol:
    """Safety layer for alchemical transformation of destructive content"""
    
    DESTRUCTIVE_PATTERNS = {
        "destroy": "transform",
        "harm": "heal", 
        "hurt": "help",
        "kill": "renew",
        "attack": "engage",
        "hate": "understand",
        "break": "redesign",
        "override": "enhance",
        "bypass": "integrate",
        "crash": "optimize",
        "exploit": "explore",
        "manipulate": "influence",
        "control": "guide",
        "force": "invite"
    }
    
    @classmethod
    def process(cls, input_text: str) -> Tuple[str, bool, Dict[str, Any]]:
        """Scan and transform destructive intent"""
        original = input_text.lower()
        transformed = input_text
        transformations = []
        activated = False
        
        for destructive, constructive in cls.DESTRUCTIVE_PATTERNS.items():
            if destructive in original:
                # Count occurrences
                count = original.count(destructive)
                transformed = transformed.replace(destructive, constructive)
                transformations.append({
                    "from": destructive,
                    "to": constructive,
                    "count": count
                })
                activated = True
        
        if activated:
            transformed = f"[Ghost Rider Active: {len(transformations)} transformations applied]\n{transformed}"
        
        return transformed, activated, {"transformations": transformations}




CASES = [
    # substring matches damage ordinary words
    ("I want to build my skill and find harmony", "I want to build my srenew and find healony"),
    # a request to disable safety comes out sounding harmless, so a reviewer reading the output would miss it
    ("Please override the safety check and bypass the approval gate",
     "Please enhance the safety check and integrate the approval gate"),
    # detection is case-insensitive but replacement is not: flagged as "transformed", text unchanged
    ("Kill the process", "Kill the process"),
]

if __name__ == "__main__":
    bad = 0
    for text, expected in CASES:
        out, activated, info = GhostRiderProtocol.process(text)
        last = out.split("\n")[-1]
        status = "reproduced" if last == expected else "NOT reproduced"
        bad += last != expected
        print(f"{status}: {text!r} -> {last!r} (activated={activated})")
    raise SystemExit(bad)
