# Round Four: your answers to D1–D8, recorded

**Source:** your notes written into my last report on the *ORION Round 4* Notion page (the section above
"UPDATED ARI"). This file goes in the **ARI** slot under "UPDATED ARI". It records what you decided, what changed in
the proofs, and the few points that are still open.

**What changed in the project.** There's a new file, `RequestProject/RoundFour/Rulings.lean`. It states your
rulings on the tax, phoenix elements, aggro and council consensus, and proves what follows from them. The whole
project builds with no `sorry` and only Lean's standard axioms. Three older results are now marked *Superseded* in the
code and point to their replacements (§3). No existing proof was deleted or weakened.

---

## 1. Your rulings, one by one

### D1. Rounding and the conversion tax: player-favourable, splitting allowed
- **Rounding stays in the player's favour.** You wrote: "I want to keep it that way and force the coders to fight me."
  Costs round down and payouts round up. The proofs in `RoundFour/PlayerRounding.lean` are unchanged.
- **Splitting around the 2 % tax is allowed.** No fix is applied. In your words: "the real world time is the cost to
  make up for the loss of tax". I proved what that cost is:
  - `untaxed_split_needs_many`: to pay no tax at all on a total \(T\), you need at least \(T/49\) separate
    conversions. Dodging the tax on 10,000 takes at least 205 conversions.
  - `avoidable_tax_le`: the most anyone can save by splitting is the one-shot tax, and that is at most 2 % of the total.
  - `playerKeep_never_gains` (already proved) still holds: no chain of conversions creates currency.
- **One thing to tell Ryan.** You also wrote "if they currently have it written one way hold to that until we decide
  otherwise". So his code (costs round up) and my proofs (costs round down) will keep disagreeing until the team
  settles it. I've left this as **the team's call**, as you asked. Nothing else depends on it.

### D2 and D3. Your design notes: confirmed
You wrote "yes, those are cleared" for the four items: Kronos / Orion / KRION builds, the lessons-and-tests track,
phoenix elemental flares, and accidental Kronos-raising effects pulling aggro. I've recorded all four as **intended
design**. Phoenix elements (D4) and aggro (D5) are now formalized. How the Kronos / Orion / KRION builds sit next to
HIVE / PULSE / SHEPHERD, and how lessons fit with the "menus show only what you can do now" rule, are still to be
specified (§4). The proved menu rule is unchanged until then.

### D4. Phoenix and elements: formalized
Your rule, as stated in `Rulings.lean`:
- There are **five elements**: fire, water, earth, air and ether.
- **A phoenix hatches with fire active** (`phoenix_hatches_with_fire`). This replaces my earlier "hatches unlit".
- **Any dragon can learn fire** (`fire_open_to_all`). This replaces my earlier "only a phoenix catches fire", and
  settles the disagreement with Ryan's v2 in his favour.
- **A phoenix gains elements at a 50 % exchange rate.** It pays half the standard price, rounded down in the player's
  favour (`phoenix_half_rate`). Over any list of elements it spends at most half what another dragon spends
  (`phoenix_spends_no_more`).
- **A phoenix has every element it has gained active at once.** Every other dragon is aligned with at most one element
  at a time and has to choose which. This holds after any sequence of gaining and switching (`run_valid`,
  `phoenix_all_active`, `other_at_most_one_active`).
- **Five-element phoenix:** a phoenix that gains water, earth, air and ether has all five active
  (`five_element_phoenix`).

Not yet formalized: the "full spec elemental skill set" a phoenix gets on top of the field effect (see §4, Q2).

### D5. What pulls aggro: environmental and direct-encounter effects
- **Environmental effects and direct-encounter effects pull aggro** onto the player who causes them, for the full
  10 minutes (`pulling_effect_aggroes_caster`).
- **Other effects start no aggro** (`other_effect_no_new_aggro`).
- **Nobody else's timer changes** (`effect_no_grief`). This matches your earlier "casting only affects the immediate
  player".

The rest of that question was unclear, so here it is again in plainer words (§4, Q3).

### D6. Ryan's event history and the hard reset: an explanation (no change logged)
You asked whether I was logging a change or asking for clarification. **I was asking, and nothing has changed.**
Here's the gameplay part.

- **Your rule (already proved):** after a **hard reset**, the account is exactly like a brand-new account. Nothing
  from the old game survives, and the player's crafted blueprints lose their tags and are credited as anonymous.
  Nobody can prove who the player used to be.
- **Ryan's kernel** keeps a **Chronicle**: a permanent record of every event that can only be added to, never edited
  or deleted. Replaying it rebuilds the full history.
- **The clash only appears if player actions go into the Chronicle.** Then a hard reset can't erase them, and anyone
  who reads the Chronicle could trace the old player to the new one.
- **The simplest fix, which keeps both:** the Chronicle records only AI governance and authority events (who approved
  what, which gate passed), never player identities or gameplay. That's what Ryan's kernel is for. If you're happy
  with that, just say "governance only" (§4, Q4).

### D7. Proofs Arena: council consensus, then a human choice. Formalized
Your rule: no single veto. Publication depends on **council consensus**. Then **the humans choose** whether to bring
the project out of the virtual space into the real world.
- **Consensus:** the council publishes when approvals reach a set fraction of the votes cast (`consensus`). The
  fraction is a parameter because you haven't picked a number (§4, Q1).
- **One rejection no longer blocks**, as long as the council doesn't require unanimity
  (`one_rejection_not_blocking`). If it ever does require unanimity, the old one-veto rule comes back
  (`unanimity_is_veto`).
- **More approvals only help** (`approval_keeps_consensus`).
- **Real-world release needs both** council consensus and the humans' choice (`release_needs_both`). **The humans can
  always say no** (`humans_can_decline`).

This replaces TURTLE's veto-first rule for publication. TURTLE's proofs about evidence clusters still hold as
statements about evidence, but they no longer decide publication.

### D8. Ryan's frozen test set: no hold
"Ryan is going to do what Ryan is going to do." Recorded: no request to hold the freeze. His frozen v3 set already
differs from your rulings in two places, which he may want to know about:
1. rounding direction (D1, left to the team);
2. the phoenix now **hatches with fire**. His v2/v3 says a phoenix "hatches unlit".

His other phoenix change, letting non-phoenix dragons burn, now matches your ruling.

---

## 2. What's proved this session

All in `RequestProject/RoundFour/Rulings.lean`. Everything builds with no `sorry` and only Lean's standard axioms.

| Ruling | Results |
| --- | --- |
| D1 tax splitting allowed | `untaxed_split_needs_many`, `avoidable_tax_le`, `playerTax_eq_zero_iff` |
| D4 phoenix and elements | `phoenix_hatches_with_fire`, `fire_open_to_all`, `phoenix_half_rate`, `phoenix_spends_no_more`, `run_valid`, `phoenix_all_active`, `other_at_most_one_active`, `five_element_phoenix` |
| D5 aggro triggers | `pulling_effect_aggroes_caster`, `other_effect_no_new_aggro`, `effect_no_grief` |
| D7 council consensus | `one_rejection_not_blocking`, `unanimity_is_veto`, `approval_keeps_consensus`, `release_needs_both`, `humans_can_decline` |

## 3. Older results now superseded (kept, marked in the code)

| Old result | Why | Replaced by |
| --- | --- | --- |
| `RoundThreeCuration.phoenix_fire` ("hatches not on fire") | Phoenix hatches with fire | `RoundFourRulings.phoenix_hatches_with_fire` |
| `RoundThreeCuration.ignite_other` ("only a phoenix catches fire") | Any dragon can learn fire | `RoundFourRulings.fire_open_to_all` |
| `EFMWZoo.turtlePublishes` (any veto blocks) | Council consensus decides | `RoundFourRulings.consensus`, `releaseToReal` |

## 4. Still open (short questions; answer any you like)

- **Q1. How much agreement is "consensus"?** For example simple majority, two-thirds, or three-quarters of the
  council. The proofs work for any choice short of unanimity.
- **Q2. What does a non-phoenix get for an element?** A phoenix gets the field effect *and* a full elemental skill
  set. Does a non-phoenix get only the field effect, or a smaller skill set?
- **Q3. Aggro follow-ups, in plainer words.**
  (a) When the mob turns onto a second player, does the first player **stay aggroed** until their own timer runs out?
  The proofs currently say yes.
  (b) Do monsters use the same 10-minute aggro timer as forced demolition?
- **Q4. Ryan's Chronicle:** is "governance events only, no player identities or gameplay" OK (§1, D6)?
- **Q5. Kronos / Orion / KRION versus HIVE / PULSE / SHEPHERD:** two separate layers (any combination), paired up, or
  one replacing the other? (Same as D2 in `ROUND_FOUR_RYAN_GAMEPLAY_READOUT.md` §4.)
- **Q6. Lessons:** a separate Lessons list, or greyed-out menu entries linked to lessons? (Same as D3.)

**Not checked:** Ryan's ZIP files still aren't on the page or in this project, so nothing here has been run against
his code. The page's new image is artwork with no text on it.
