# ORION R7 Live: reply

I read the whole *ORION R7 Live* page, the linked *ORION (Summary)* page, and Ryan's new attachment.
Text copies are in `orion/r7/PAGE_TRANSCRIPT.md` and `orion/r7/ORION_SUMMARY_TRANSCRIPT.md`. Your new answers are
proved in `RequestProject/RoundSeven/RulingsSeven.lean`. The whole project builds with no `sorry` and only Lean's
standard axioms.

As you asked, the running status board is now its own file, `ORION_RUNNING_ROSTER.md`. It lists what's fixed, what
broke, what is superseded and needs your permission, open holes across the build, navigation and gameplay ideas, and
questions. I'll update it every round.

**What I couldn't open:** the *ORION Engine SoB 100326* page is private. Notion reports "no public access" for it.
To have it reviewed, set **Share → General access → "Anyone on the web with link"** and send the link again. The empty
file block under the image has no file attached.

---

## 1. Leveling: 64 notes for level, skills capped at 100

Your idea: a player unlocks 64 notes to become a level-64 player, and every skill maxes out at 100.

**Does it work? Yes, as a structure, with one decision needed first.** In Round 3 you removed levels (`ROUND_THREE_DECISIONS.md` §3,
`FOLLOW_UPS.md` §3), and Mike's task was "remove all leveling code". This idea brings levels back, so I need your **permission to
supersede that decision** before I treat it as a rule. Until then it's recorded as a proposal. It also replaces the earlier
**144 skill cap** (`FOLLOW_UPS.md` A1) with **100**.

How I modelled it, proved in Lean:
- Training adds to a skill but stops at 100 (`train_le_cap`). It never lowers a skill (`le_train`), and enough training reaches
  exactly 100 (`train_saturates`).
- A player's level is the number of notes unlocked. It runs from 0 to 64 (`playerLevel_le`), and level 64 means all 64 notes are unlocked
  (`playerLevel_eq_max_iff`).

**This also answers the strength question.** With normal players capped at 100:
- a non-phoenix dragon (2×–2.2×) at full skill sits **between 200 and 220** (`dragon_at_full_skill`);
- a phoenix at 2.42× or more sits at **242 or more** (`phoenix_at_full_skill`);
- **at the same skill**, the phoenix is at least 10% above every non-phoenix dragon and every normal player (`phoenix_above_at_equal_skill`).

**Caveat (proved):** across *different* skills the 10% rule doesn't hold. A phoenix at skill 50 (121) is weaker than a 2× dragon at skill 100 (200)
(`phoenix_low_skill_example`). I assume that's intended, since skill should matter.

**Questions:**
1. May I supersede the Round 3 "no levels" decision and the 144 cap with this? (yes / no)
2. What are the 64 notes, and how is one unlocked: by reaching a skill threshold, by a quest, or by meditation?
3. Is "level" only notes, or should skill totals feed into it too? You wrote "utilize the skill levels as the leveling system". In my
   model, level comes only from notes and skills are a separate 0–100 scale for each skill.

## 2. Council strikes (👍, confirmed)

You confirmed my wording: after the third strike a motion is out, and it can be brought back after a seven-day cool-off. The Round 6 proofs
(`retry_allowed_iff`: allowed exactly from day 7 after the strike) stand unchanged. The open point is whether the first round's no counts as
strike 1. Your 👍 on "a strike is a reassessment round that brings a new no" settles it: **it doesn't**. I've closed this item.

## 3. Royalties and pools (🛑, the Round 6 model is replaced)

You corrected my Round 6 reading. The new rules and what I proved:

**Sale tax.** Created items and schematics carry character/user tags. On every purchase 2% of the price goes to the creator and the seller keeps 98%
(`sale_seller`, `sale_tagged`). If the creator hard-reset, the item carries the anonymous flag and that 2% goes to the **admin arena pool**
instead (`sale_anonymous`). Nothing is created or lost (`sale_conserves`). *Replaces* `taxReset_*` from Round 6, which put a tax on the user's royalty share.

**Arena payouts: 2% off the total, not per contribution.** In exact amounts the two give the same number (`skim_total_eq_sum`). The difference only shows up
with whole coins. Rounding each contribution down separately never takes more than rounding the total once (`skimEach_le_skimTotal`), and it can take
less. For example, two contributions of 49 coins give 0 coins per contribution but 1 coin on the total (`skim_rounding_example`). So your
"from the total" wording is the version that actually collects the 2%. The same rounding issue hits the sale tax on small prices: 2% of anything under 50
coins rounds down to 0 (see `FOLLOW_UPS.md` A5).

**Monthly admin pools: split evenly.** Every admin gets the same whole-coin amount, and fewer coins than there are admins are left over
(`evenSplit_conserves`, `evenSplit_remainder_lt`). Example: 100 coins among 3 admins gives 33 each with 1 left over (`evenSplit_example`).

**RD pool: 2% for original creators, 10× for DEV collaborators.** A player who worked with the DEV team on a used schematic gets 10 × 2% = 20%.
The payouts fit in the pool exactly when 2 × (creators) + 20 × (collaborators) ≤ 100 (`rdPayout_fits_iff`). **Six collaborators on one pool would be owed
120%** (`six_collaborators_overflow`). This is a hole that needs a rule (see the questions).

**Questions:**
4. **Who receives the 2% arena skim?** The admin arena pool, the RD pool, or something else?
5. **Leftover coins** from the even admin split: carry over to next month, or go to the world-rebuild fund?
6. **RD overflow:** if collaborators plus creators would get more than 100%, should everyone be scaled down proportionally, or should the number of
   collaborators per schematic be capped? (Five is the most that fits with no other creators.)
7. **"Subdivided 2%":** if several original creators' schematics feed one pool, do they **share** one 2% between them, or does **each** get 2%?
8. **"Dove team":** did you mean the DEV team? (It reads like a dictation slip.)
9. **DEV characters with infinite resources:** may a DEV character sell or trade into the player economy? If it can, infinite supply sets every price to
   zero. I suggest DEV characters can build and test but not sell, trade or gift to players. That fits the Summary page's "capability isn't authority".
10. **Is the 2% sale tax added on top of the price, or taken out of it?** I modelled it as taken out, so the seller gets 98%.

## 4. Names (🛑💎, locked)

Recorded as hard names until you specifically change them (`hardName`):

| Platform | Locked name |
|---|---|
| Project build | **The ORION Engine** |
| Landing page | **ORION's Gate** |
| Social community | **The Playground** |
| MMO | **The Orion Chronicles** |
| EDU hub | **The Ascent** |

**Routing for approval, with no exceptions:** in my model anyone, including you, can only *propose* a name. A name changes only when a routed proposal is
approved. Any run of events with no approval leaves every name unchanged, whoever proposed (`names_unchanged_without_approval`). Approving something
never proposed does nothing (`approve_unproposed_noop`), and an approval changes only the one platform it names (`approve_sets_name`).

**Conflict to resolve:** the linked *ORION (Summary)* page lists **Elder's Garden** as the fourth platform (the global community and projects page).
It doesn't mention ORION's Gate. Your locked list has ORION's Gate and no Elder's Garden. My Round 6 note recording Elder's Garden as the project page is
**withdrawn**.

11. Is **Elder's Garden** (a) a fifth platform, the global projects page, (b) a lore location only, or (c) dropped? Until you answer, it stays as the lore
    location only, and I've marked the Summary page as needing correction.
12. The Summary page writes **ORION** for the Engine but "The Orion Chronicles" for the MMO. Is that capitalisation part of the locked names?

## 5. Ryan's new file: *Weaver Agent Security Pilot v0.2* (I ran everything myself)

Log: `orion/r7/weaver-agent-security-pilot-v0.2-checks.log`.
- The ZIP is intact and all 23 files match its own `SHA256SUMS.json`.
- **22/22 unit tests pass and 14/14 demo checks pass** on Python 3.11, and the shipped `DEMO_RESULTS.json` matches a fresh run exactly. This
  confirms his `VALIDATION.md`.
- **His notes are out of date about the gateway.** `START_HERE.md` and `DELIVERY_READINESS.md` say the Agent Audit Gateway v0.3 retest "remains
  unresolved" because `jsonschema` was missing. I reran that suite in Round 5 with the library installed, and all 47 tests passed
  (`orion/r5/agent_audit_gateway_run_checks.log`). Ryan can rerun it himself after `pip install jsonschema`. A rerun by me still isn't independent validation of
  production security, as his own CLAIMS.md says.
- **A confusing label in the demo.** The cases `tail deletion detected` and `full rewrite detected` report `observed: false, expected: false`.
  The value recorded is actually "does the checkpoint still verify?". `false` means the tampering **was** caught. A customer reading the report would
  likely take "detected: false" to mean *not* detected. I suggest renaming them, for example to `tail deletion: checkpoint verifies`, or recording
  `not verify_checkpoint(...)` with expected `true`.
- His claim discipline is sound. The package doesn't claim certification or demand, and it says plainly that the checkpoint digest has to be stored
  outside the attacker's reach.
- The OpenAI "safety cases" link Ryan posted is background reading. It contains nothing for me to run.

## 6. The new image

A meditating figure on a floating island at the centre of a galactic whirlpool, with ghostly figures and rock debris circling. It fits safe-zone
meditation as the progression boundary. This is my description of the image, not a checked result.

## 7. All questions in one place

1–3 leveling (§1); 4–10 economy (§3); 11–12 names (§4); plus Matthew's three Zoo checks from Round 6, and the gallery's orb wattage steps and two sets of stage
names. Everything is also tracked in `ORION_RUNNING_ROSTER.md`.
