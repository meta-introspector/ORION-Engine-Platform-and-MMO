# ORION R7 Live, second pass: reply

I re-read *ORION R7 Live* after you answered my Round 7 reply on it. I also read the **ORION SoB 100326** page, which is
public now, and ran Ryan's two new files.

- Text copies: `orion/r7b/PAGE_TRANSCRIPT.md` (the page as it is now) and `orion/r7b/SOB_100326_TRANSCRIPT.md`.
- Check log for Ryan's packages: `orion/r7b/new-packages-checks.log`.
- New proofs: `RequestProject/RoundSeven/FollowUpSeven.lean`. The whole project builds with no `sorry` and only Lean's
  standard axioms.
- The running roster (`ORION_RUNNING_ROSTER.md`) is updated. Changes from this pass are marked **[R7b]**.

---

## 1. "Notes" was "nodes": no permission needed for levels

Thanks for the correction. With **nodes**, your idea matches what we settled in Round 3 (`ROUND_THREE_CLARIFICATIONS.md`):

> "Level" means one of the 64 character nodes being unlocked or gold-locked. "Level 64" means all 64 nodes are gold-locked.
> Skills are levelled separately.

So this doesn't bring levels back, and I've **withdrawn my request for permission** to supersede Round 3. The Lean file now
says "character nodes" instead of "notes" (`nodeCount = 64`; the proofs are unchanged). The 144 is the dragon matrix (the
"Black Hole lock" grid), as in Round 3 and in gallery image 20 (human 64 + dragon 80 = 144).

**One thing is still open: the skill cap.** In Round 3 (`ROUND_THREE_RULINGS.md` §6) skills capped at **144**. In R7 you
wrote that skills "max out at 100".
- **Q1.** Is the skill cap now **100**, with 144 kept only as the dragon matrix's node count? Or do skills still cap at 144?

## 2. Phoenix: yes, that's what I meant, and now it's explicit

You wrote that a phoenix isn't better than another dragon at full skill, that the difference is only the phoenix's
**elemental** side, and that every dragon reaches the same full skill. That's how I read it too. The numbers 200–220 and
242+ were **elemental power only**. I've now written the rule so it can't be read any other way. Proved in
`FollowUpSeven.lean`:

- Every dragon, phoenix included, has the same skill cap (`same_skill_cap`).
- In every **non-elemental** ability, a phoenix and any other dragon at the same skill have exactly the same power
  (`phoenix_same_nonelemental`).
- Only in **elemental** abilities is the phoenix at least 10% ahead at the same skill (`phoenix_elemental_ahead`).
- So the phoenix is **not** stronger overall: there's always an ability where it isn't ahead (`phoenix_not_ahead_overall`).

This also answers the SoB page's question 9.4 ("dragon, player or elemental abilities?"): **elemental only**. Round 4
already settled the 50% element price for the phoenix as a **price** rule (`ROUND_FOUR_RULINGS_UPDATE.md`). It doesn't
change power.

## 3. The arena 2%, explained plainly

The game uses whole coins, and rounding goes in the player's favour (your Round 4 ruling D1). So whenever 2% of something
isn't a whole number, the fraction is dropped.

**Example.** Two players each put 49 coins into an arena, so the payout is 98 coins.
- **Your rule (2% of the total):** 2% of 98 is 1.96. Drop the fraction and the arena takes **1 coin**.
- **The other way (2% of each contribution):** 2% of 49 is 0.98. Drop the fraction and it's 0 coins, twice. The arena
  takes **0 coins**.

So taking 2% of each piece can lose coins to rounding, and taking it once from the total can't lose more than one coin's
fraction. **Your wording ("from the total, not per contribution") is the better rule.** There's nothing for you to decide
here. I was confirming that your choice is the right one.

The same rounding means 2% of any amount **under 50 coins** is 0. That's the small-sale question from before
(`FOLLOW_UPS.md` A5).

## 4. The RD pool: your exact words

Copied exactly from your 🛑 note on the R7 page (spelling as written):

> "DEVs get one character with infinite access to resources/materials/published schematics etc. they can also petition a
> user to work with them on an already published schematic to increase its value and usability for a higher gain as a dev
> assisting contributor. Any schematic that is in use by the Dove team that gains a pool the original schematic creator
> will automatically be allocated at a subdivided 2% of total pool re-distribution and any player made schematic arena will
> automatically be given 2% of the total gains at that arenas final pool prior to monthly reset. If a player directly worked
> with the DEV team on a used schematic, they will be given 10 times the reward from that schematics RD pool"

**What I took from it:** the original creator gets 2% of the pool, and a player who worked with the DEV team gets 10 times
the reward, which I read as 10 × 2% = 20%. **The problem:** with six such collaborators on one schematic that's 6 × 20% = 120%,
more than the pool holds. To work it out, I need to know:
- **Q2.** Does "10 times the reward" mean 10 × the creator's 2% (= 20% each), or something else?
- **Q3.** "Subdivided 2%": if several creators feed one pool, do they **share** one 2%, or does **each** get 2%?
- **Q4.** If the shares add up to more than 100%, should everyone be **scaled down** in proportion, or should the number of DEV
  collaborators per schematic be **capped**? (At 20% each, five is the most that fits.)
- **Q5.** "Dove team" means the **DEV team**? (Dictation, I assume.)

## 5. Names: Elder's Garden held for the landing page, the rest 💎

Recorded:
- **The ORION Engine, ORION's Gate, The Playground, The Orion Chronicles and The Ascent: diamond-locked.**
- **Elder's Garden:** a **placeholder title** for a landing page that explains the whole engine. It's open for the team's
  ideas, and you may replace it. It isn't locked.

Your new image is the crest for **The Orion Chronicles**, spelled exactly like that ("Orion", not "ORION"). That fits the
locked name. (My description of the image, not a checked result.)

- **Q6.** If Elder's Garden (or its replacement) is now the landing page, what is **ORION's Gate**? My Round 7 table had it
  as the landing page. One gallery cover reads "THE ORION CHRONICLES MMO on the ORION'S GATE platform", which suggests the
  Gate is the platform or portal that hosts everything. Is that right?

## 6. The ORION SoB 100326 page (now open)

It's a detailed state-of-build summary, and its overall picture matches mine. The build is several connected layers
(governance, formal proofs, runtime security, federation, game, CI, lore), not yet one integrated system. Its main
recommendation, an **ORION Master Index**, is a good one (§6.3 below).

### 6.1 Where it is out of date (corrections from the rounds it couldn't see)

| SoB says | Current state | Where |
|---|---|---|
| R7 Live's body says "ORION R1" (9.10) | The page as it reads now has no "R1" in it. The label has been fixed | `orion/r7b/PAGE_TRANSCRIPT.md` |
| Naming isn't settled; Elder's Garden is the main project | Five names are 💎 locked; Elder's Garden is a placeholder landing-page title | §5 above |
| Rounding isn't frozen (6.10, 9.3) | You ruled player-favourable rounding (costs down, payouts up) in Round 4 (D1). Splitting is allowed. Only Ryan's vectors still use the other direction | `ROUND_FOUR_RULINGS_UPDATE.md` D1 |
| Phoenix ratio isn't settled (6.4, 9.4) | Phoenix ≥ 1.1 × the strongest ordinary dragon, elemental only; same skill cap and non-elemental power as every dragon | §2 above; Round 5 |
| Council reassessment sequence isn't frozen (6.7, 9.5) | Frozen. A first-round no isn't a strike; three strikes, then a 7-day cool-off; 4/5 to pass | `RoundSix/RulingsSix.lean`; R7 |
| Hard reset / royalties open (9.7) | Partly settled in R7: anonymous items' 2% goes to the admin arena pool; monthly admin pool split evenly. RD overflow still open | `RoundSeven/RulingsSeven.lean`; §4 above |
| The Agent Audit Gateway 47 tests weren't rerun (4.5) | I reran them in Round 5 with `jsonschema` installed: 47/47 pass | `orion/r5/agent_audit_gateway_run_checks.log` |
| lean-workers-union: "patched build passed a smoke test" | Both the v0.3 and v0.7 fix patches build with no `sorry`. Ryan still needs to apply them upstream | `orion/r5/`, `orion/r6/` |
| The Aristotle project couldn't be inspected | The whole project (Lean files, replies, logs, manifests) is in the files returned to you. You can share them with whoever writes the next summary | `CODE_MANIFEST.md` |

### 6.2 Where it's right, and it's still open

- **43 / 46 / 47 / 50 counts** need one glossary saying which list is which. That's waiting on Matthew's three Zoo checks.
- **SHEPHARD vs SHEPHERD** spelling (and the Kronos/Orion/KRION ↔ HIVE/PULSE/SHEPHARD table) still need consolidating.
- **Lessons: how far ahead** a guided lesson may reach is still vague (`FOLLOW_UPS.md` §5A).
- **"Independent"** witnesses and reproductions: none of Ryan's packages has an outside, institutionally independent
  reproduction yet. My reruns help, but I'm not an independent organisation.
- **The Chronicles page is empty.**
- The SoB page flags the administrator-access / private-communications rule for **qualified legal review**. I can't
  advise on that, but I agree it needs counsel before it becomes policy.

### 6.3 The "Master Index" it recommends

Most of its eight parts already exist here in some form. The package registry and SHA-256 manifest are `CODE_MANIFEST.md`
(regenerated this round). The contributor registry, open-decision ledger and readiness status are
`ORION_RUNNING_ROSTER.md`. The rule-to-proof table is the Properties panel and `CODE_MANIFEST.md`'s theorem index.
**Missing:** a namespace glossary and an archive of the external sources.
- **Q7.** Do you want me to start an `ORION_MASTER_INDEX.md` that pulls these together and adds the glossary skeleton?

## 7. Ryan's two new packages (I ran everything myself)

Full log: `orion/r7b/new-packages-checks.log`. Python 3.11.

### Weaver Integration Demonstrator v0.1

A small reference model. A source-bound observation becomes a candidate lesson, a grant-checked "accept" step follows,
the receipts are hash-chained, and a separate verifier replays them.
- **All 12 checksums match. 12/12 tests pass.** The demo gives NO_GRANT / PASS / REPLAY, and the verifier says VERIFIED. A
  fresh demo run is **byte-identical** to his shipped `examples/`.
- **Proved in Lean, on a model of his `accept` rule** (`FollowUpSeven.lean`):
  - a denied decision leaves the protected state unchanged (`decide_denied_preserves`);
  - PASS happens exactly when every condition holds (lesson exists, command unused, grant present with the right actor,
    action and target, not expired, still a candidate) (`decide_pass_iff`);
  - once a command ID passes, it **never passes again**, whatever follows (`no_double_pass`).

  These are his first two "bounded claims", proved for the model. That doesn't make his Python proved.
- **Findings (small; nothing is wrongly accepted):**
  1. Some malformed ledgers make the verifier crash with a Python error (`TypeError` / `AttributeError`) instead of
     rejecting them cleanly with `ValueError`. Examples are a list where a lesson ID should be, a string where the claim
     should be, or a list as the payload. The ledger is still refused, but the command-line tool prints a crash trace. Suggest
     checking `payload` and `claim` are dicts and IDs are strings before using them.
  2. Time can go backwards: a decision at time 5 is accepted after one at time 10. His README says callers supply
     time, so this is a known limit. Still worth a monotonic-time check before any real use.
  3. A command ID that was **denied** can be reused later for a PASS. That matches his claim, which only covers
     *successful* IDs. Say so explicitly if that's intended.
  4. The demo prints `"verification": "PASS"` while the verifier prints `VERIFIED`. One word for both would be clearer.

### Loom / Mythos Continuity Kernel v0.2.0

A local tool for lore continuity: concepts, interpretations, typed relations, alternate worlds ("branches"), and
fictional facts checked against versioned world contracts.
- **All 22 manifest hashes match. 64/64 tests pass. 10/10 mutation probes are caught.** A fresh demo archive is
  **byte-identical** to his shipped one. Checkpoint and verify work. Applying the shipped conflicting fact is **rejected
  (exit code 2) and the archive is unchanged**.
- **Proved in Lean:** his contract check (`equals` / `not_equals` over strings, booleans and integers, with `true` ≠ `1`)
  is **exact**. It accepts a contract **exactly when** some world could satisfy all of its constraints at once
  (`contractCheck_iff_satisfiable`). It never rejects a contract that could hold and never accepts one that can't. This is
  a model of his check, not his Python itself.
- **Small notes:**
  1. `conflicts --fact-payload` (the preview) exits with code 0 even when it reports VIOLATED. That's fine for a preview, but
     a script would need to read the JSON. Consider a nonzero exit code, or a `--strict` flag.
  2. `MANIFEST_SHA256.json` doesn't list itself (normal), so it needs an outside hash if it's ever used as an anchor. His
     README already says the checkpoint must be kept separately.
- **For the game:** this is the closest thing yet to a **lore-consistency checker for The Orion Chronicles**. It could hold
  world facts (for example "phoenix.elements_active_in_combat = multiple") with contracts that reject contradictions before
  they're published.
  - **Q8.** Do you want me to seed a Loom archive with the locked rulings (names, phoenix, council, aggro) as world facts?

## 8. All questions

1. Skill cap: 100 now, with 144 only the dragon-matrix node count? (§1)
2. RD "10 times the reward" = 20% each? (§4)
3. "Subdivided 2%": shared or each? (§4)
4. RD overflow: scale down or cap collaborators? (§4)
5. "Dove team" = DEV team? (§4)
6. What is ORION's Gate now that Elder's Garden holds the landing-page slot? (§5)
7. Start an ORION Master Index file? (§6.3)
8. Seed a Loom archive with the locked rulings? (§7)

Still open from Round 7: who receives the arena 2% skim; leftover coins from the even admin split; DEV characters selling
into the player economy; whether the 2% sale tax is added on top of the price or taken out of it. Matthew's three Zoo checks,
the gallery's wattage steps and the stage names are also still open.
