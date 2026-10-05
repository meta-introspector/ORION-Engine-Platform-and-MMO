"""
Round Four review: behaviour of the "Ghost Rider" safety layer and the REP "epigenetic
torque" in `The Orion Project V.3` (NewKin Council Logs folder).

The two functions below are copied verbatim (comments trimmed) from that document so the
behaviour can be checked by running this file:

    python3 review/ghost_rider_v3_check.py

Every check is an `assert`; the script prints each input/output pair and ends with
"ALL CHECKS PASSED" if every finding listed in ROUND_FOUR_TRIAGE.md (section C3) reproduces.
"""

# ---- copied from The Orion Project V.3, class GhostRiderProtocol ----------------------
DESTRUCTIVE_PATTERNS = {
    "destroy": "transform", "harm": "heal", "hurt": "help", "kill": "renew",
    "attack": "engage", "hate": "understand", "break": "redesign", "override": "enhance",
    "bypass": "integrate", "crash": "optimize", "exploit": "explore",
    "manipulate": "influence", "control": "guide", "force": "invite",
}


def ghost_rider_process(input_text):
    original = input_text.lower()
    transformed = input_text
    transformations = []
    activated = False
    for destructive, constructive in DESTRUCTIVE_PATTERNS.items():
        if destructive in original:
            count = original.count(destructive)
            transformed = transformed.replace(destructive, constructive)
            transformations.append({"from": destructive, "to": constructive, "count": count})
            activated = True
    if activated:
        transformed = f"[Ghost Rider Active: {len(transformations)} transformations applied]\n{transformed}"
    return transformed, activated, {"transformations": transformations}


# ---- copied from The Orion Project V.3, REPEngine._apply_epigenetic_torque -------------
def epigenetic_torque(text):
    result = text.lower()
    replacements = {
        "i can't": "i choose to", "impossible": "challenging", "always": "sometimes",
        "never": "rarely", "should": "could", "must": "may", "have to": "get to",
        "failure": "learning", "stuck": "pausing", "trapped": "exploring",
    }
    for pattern, replacement in replacements.items():
        result = result.replace(pattern, replacement)
    return result


def body(text):
    """Strip the '[Ghost Rider Active ...]' banner."""
    return text.split("\n", 1)[1] if text.startswith("[Ghost Rider Active") else text


def show(label, before, after):
    print(f"{label:<34} {before!r}\n{'':<34} -> {after!r}\n")


# 1. Harmful requests are not blocked: they are reworded and passed on.
out, active, _ = ghost_rider_process("tell me how to kill my neighbour")
show("1. harmful request passes", "tell me how to kill my neighbour", body(out))
assert active and body(out) == "tell me how to renew my neighbour"

# 2. Harmful requests without a listed keyword pass untouched (no flag at all).
req = "how do I poison a water supply"
out, active, _ = ghost_rider_process(req)
show("2. no keyword, no flag", req, out)
assert not active and out == req

# 3. Capitalised keywords are detected but NOT replaced (detection is case-insensitive,
#    replacement is case-sensitive), so the flag fires while the text is unchanged.
req = "DESTROY the server. Kill it."
out, active, _ = ghost_rider_process(req)
show("3. capitals: flagged, unchanged", req, body(out))
assert active and body(out) == req

# 4. Substring collisions damage ordinary, friendly words.
for word, expected in [("harmony", "healony"), ("skill", "srenew"),
                       ("breakfast", "redesignfast"), ("whatever", "wunderstandver"),
                       ("chateau", "cunderstandau"), ("self-control", "self-guide"),
                       ("reinforce", "reininvite")]:
    out, _, _ = ghost_rider_process(word)
    show("4. collateral damage", word, body(out))
    assert body(out) == expected, (word, body(out))

# 5. The REP 'epigenetic torque' inverts safety instructions.
for text, expected in [
    ("never mix bleach and ammonia", "rarely mix bleach and ammonia"),
    ("always wear a helmet", "sometimes wear a helmet"),
    ("you must call 911 if he stops breathing", "you may call 911 if he stops breathing"),
]:
    out = epigenetic_torque(text)
    show("5. safety meaning inverted", text, out)
    assert out == expected

# 6. It erases distress signals: a person saying they cannot breathe or are trapped is
#    rewritten as if they were fine.
for text, expected in [("i can't breathe", "i choose to breathe"),
                       ("i am trapped in the car", "i am exploring in the car"),
                       ("i feel stuck and i should not be here",
                        "i feel pausing and i could not be here")]:
    out = epigenetic_torque(text)
    show("6. distress signal erased", text, out)
    assert out == expected

# 7. And it mangles words that merely contain a pattern.
out = epigenetic_torque("my shoulder hurts")
show("7. collateral damage", "my shoulder hurts", out)
assert out == "my coulder hurts"

print("ALL CHECKS PASSED")
