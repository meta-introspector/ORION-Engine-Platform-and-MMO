# ORION R6: reply

This is my reply to the "ORION R6" page. A text copy of the page is in `orion/r6/PAGE_TRANSCRIPT.md`. The new rules are proved in `RequestProject/RoundSix/RulingsSix.lean`. The whole project builds with no `sorry` and uses only Lean's standard axioms.

---

## 1. The strength question, asked directly

You asked me to put this to you plainly, so here it is:

> **If a normal (non-dragon) player's elemental skill is 100, does every non-phoenix dragon sit between 200 and 220, with the phoenix at 242 or more?**

- **Yes** means the 2×–2.2× band you approved stands, and so does the phoenix floor of 2.42×, which was proved in Round 5.
- **No** means please give me any one example in numbers, like "player 100, dragon ___, phoenix ___", and I'll rebuild the rule from that.

The Round 4 note this comes from reads: "a dragon should be twice as powerful as a non-dragon player's elemental skill, with a 10% differentiation between non-phoenix dragons."

---

## 2. Your answers, proved

### Council: three strikes and you're out, with a 7-day timer
How I read it:
- A **strike** is a reassessment round in which a seat that voted yes in the first round now votes no. Under the Round 5 rule, that kind of round forces another reassessment.
- The third strike ends the motion. It is **struck out** and can be brought back after 7 days.

Proved:
- A unanimous first round passes at once.
- Three strike rounds in a row strike the motion out, whatever would have come next.
- The council **always reaches a decision within three reassessments**. This closes the "never decides" gap I raised in Round 5.
- Only the first three reassessments can affect the result.
- Before the third strike, the Round 5 rule is unchanged, and a passed motion still has 4/5 approval in its deciding round.
- A struck-out motion can be brought back **from day 7 after the strike**, and not earlier.
- Two worked five-seat examples:
  - three strikes, so the motion is out;
  - two strikes followed by a round where only the original no remains, so the motion passes.

### Royalties: a 2% arena tax instead of removing the share
How I read it:
- When a user hard-resets, their records stay as anonymous contributions.
- The developer arenas take a tax rate of that user's royalty share (2% in your example) instead of 100%.
- The rest keeps going to the anonymous contributor's account. **This last part is my guess; see question 2 below.**

Proved, for any tax rate:
- After a hard reset, the arenas gain exactly (rate × that user's share).
- The user keeps (1 − rate) of it.
- Other users are unchanged.
- No royalty is created or lost on any record.
- At a 100% rate this is exactly the Round 5 rule.
- At 2%, a share of 100 becomes 2 for the arenas and 98 for the contributor.

### Names (💎) and the lore Elder's Garden (👍)
These are recorded:
- **Elder's Garden** is the ORION project page. When you say "bedrock" or "project page", I'll read it as the Elder's Garden.
- **Playground** is social media.
- The lore location keeps the name Elder's Garden.

No proof was needed for these.

### Dragon band (👍)
The 2×–2.2× band stands, and the Round 5 phoenix result (floor 2.42×) still applies. Section 1 asks you to confirm it in plain numbers.

---

## 3. Matthew's Monolithic Zoo input

How I read Matthew's note:
- **50 Zoo entries = 47 animal names + 3 conceptual "animals"** (PULSE, HIVE, SHEPHARD).
- **47 animal names = 43 core names + 4 in the 47–50 band**: CHIMERA, WOODPECKER, NIGHTENGALE, HUMMINGBIRD.

Proved, by checking the lists:
- I took the 46-animal Core list from the earlier design compilation and removed PULSE, HIVE and SHEPHERD. That leaves exactly **43 distinct names**.
- None of the four band animals is already a core name, so the total is **47 distinct names**.
- With the three conceptual entries, that makes **50 distinct entries**.

The 43 core names, in Core-list order:

TORTOISE, OWL, OCTOPUS, GECKO, EAGLE, CRAB, CAT, FOX, SPIDER, RAVEN, DOLPHIN, ANT, MOTH, SHARK, PENGUIN, BAT, HEDGEHOG, CROCODILE, DRAGON, TURTLE, MAGPIE, WOLF, ELEPHANT, CHAMELEON, JELLYFISH, BEAVER, MANTIS, BISON, WEASEL, SALMON, ORCA, MOLE, LYNX, HORSE, TERMITE, PHOENIX, COBRA, WHALE, FALCON, RHINO, BONOBO, AXOLOTL, BUTTERFLY

Things for Matthew to check:
- **Is this the right 43?** He didn't list them on the page. I built the list from the earlier Core list.
- **Spelling.** The earlier list spells it SHEPHERD; Matthew wrote SHEPHARD. He also wrote NIGHTENGALE, where the usual spelling is NIGHTINGALE. I kept his spellings. Which ones are canonical?
- **Order of the band.** Which of CHIMERA, WOODPECKER, NIGHTENGALE and HUMMINGBIRD takes positions 47, 48, 49 and 50? (He wrote "47–50" but listed four animals beyond 43, so positions 44–47 may be meant instead.)

---

## 4. Ryan's files (I ran everything myself)

You weren't sure whether any of these were repeats. They were:
- **Two pairs are exact duplicates**: the lean-workers-union v0.7 ZIP and the portfolio-ci-hardening-kit ZIP.
- **The two audit PDFs are nearly the same.** They differ only in "All 9 with CI" vs "All 8 with CI" and in one note about the reson8 tag. **The second PDF is right: 8 repos have CI.**

All six ZIPs match their own checksum lists.

### lean-workers-union v0.7
- **Python:** every CI step passes, including the 10 unit tests and the federation, adversarial, replay and demo steps. The log is in `orion/r6/lean-workers-union-v0.7-python-ci.log`.
- **Lean:** it doesn't build as shipped, even on its own pinned Lean 4.34.1, which I installed to test. There are four problems:
  - `prefix` is still used as a field name. It is a reserved word, so I renamed it `pfx` in Registry, Located and Smoke.
  - Three `split at h <;> simp_all` steps don't close their goals. I replaced them with explicit case splits.
  - `List.Nodup.cons` doesn't fit the goal. I replaced it with `List.nodup_cons.2 ⟨fresh, reg.unique⟩`.
  - A `rw … at` on a structure field fails in Kernel.lean. I rewrote it through a local copy.
- After these fixes it builds with no `sorry`, and its smoke test passes. The fixes are in `orion/r6/lean-workers-union-v0.7-fixes.patch`; I checked that the patch applies to a fresh copy of the ZIP and the result builds.

### proofs-arena-dragon-kernel v0.1 / v0.2 / v0.3
- **Python:** the tests pass (14, 21 and 26 for the three versions), the test vectors pass (6, 8 and 9), and the static QA check passes.
- **The v0.2 → v0.3 patch** applies only with `patch -p4`, because its paths start with `/mnt/data`. Once applied, the result is identical to v0.3.
- **Lean:** none of the three versions builds on 4.34.1, for two reasons:
  - `prefix` is used as a variable name. I renamed it `pre`.
  - The `rfl` proof of `skinOnlyPreservesAbilitySignature` fails. I replaced it with an unfold followed by two rewrites.
- The fixes are in `orion/r6/proofs-arena-dragon-kernel-fixes.patch`. It applies to all three versions, and all three then build.

### ci-hardening-patches.tar.gz (11 per-repo patches)
I cloned all 15 of Ryan's public repos and checked these patches against them:
- All 11 patches apply cleanly to the current repos.
- All 12 pinned action commit hashes match the real release tags, and no unpinned actions are left.
- All the workflow files are valid YAML.
- The kit's own audit, run before and after, shows that only the exceptions Ryan disclosed remain:
  - reson8's snap-in-sync permissions;
  - concurrency settings for label-sync, publish and Math replay.

### portfolio-ci-hardening-kit v1
Its 3 tests pass, and its own validation passes. Small point: the ZIP includes Python cache files (`__pycache__`) that don't need to be shipped.

### portfolio-ci-hardening-live-application v1
- Its tests and validation pass.
- Its recorded commit hashes for all 15 repos, and for all 22 workflow files, match the live repos.
- All 15 action pins resolve. Note that `dtolnay@stable` is a branch, not a fixed version.
- Its correction to the audit is right: cathedral-verified contains no Coq. Its two `.v` files are Verilog, so the PDF's "mostly Coq" was a misreading.
- **Bug:** the script that generates the patches (`make_patch` in `prepare_repo.py`) compares the checkout *including* its `.git` folder against a copy without it. As a result, file paths come out as `a.git/HEAD` and so on, and **every patch it generates fails to apply**.
  - I wrote a fix that compares two clean copies instead. It is in `orion/r6/portfolio-ci-hardening-application-v1-make_patch-fix.patch`.
  - With the fix, all 15 patches apply, and each gives exactly the same result as the script's direct-write mode. The audit then shows no gaps in any repo, and the YAML is valid.
- The tarball patches above still apply on top of this bundle's output. **Ryan should pick one of the two patch sets, not both.**

Passing tests and clean audits are not a security review.

---

## 5. Concept Art Gallery ("The Orion Chronicles", 49 images, no duplicates)

These are things I read off the images. None of them are proved.
- **Cover:** "Volume One · Chaos · Cosmic War · Healers · Mechs · Fairies & Pod Critters". Another image says "THE ORION CHRONICLES MMO on the ORION'S GATE platform".
- **Image 20:** Human 64 + Dragon 80 = 144 nodes, with 64 pairs.
- **Image 24:** orb tiers I–V (Common, Uncommon, Rare, Epic, Legendary) at 5W, 12W, 30W, 75W and 150W. The step between tiers isn't constant: ×2.4, ×2.5, ×2.5, ×2. Is that intended?
- **Image 17:** Baby / Juvenile / Adult, levels 1–3. **Image 27:** Stage I hatchling / II trained / III ascended. Are these the same three stages under two sets of names?
- The Poly-Gon Arena appears.

---

## 6. Questions for you

1. **Strength:** see section 1. Player 100 → non-phoenix dragons 200–220, phoenix 242 or more?
2. **Royalties:** with the 2% tax, who gets the other 98%? I assumed it keeps going to the anonymous contributor's account. The alternatives would be a community pool, or a 2% tax on *all* anonymous contributions rather than only on hard resets.
3. **Strikes:** is a strike a reassessment round that brings a new no (my reading)? Or does the first round's no already count as strike 1?
4. **Zoo:** the three checks for Matthew in section 3.
5. **Gallery:** are the orb wattage steps and the two sets of stage names intended?
