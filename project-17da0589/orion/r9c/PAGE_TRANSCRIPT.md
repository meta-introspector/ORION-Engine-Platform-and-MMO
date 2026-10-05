# ORION R9 Live: text copy, third pass (2026-10-04)

Source: https://app.notion.com/p/ORION-R9-Live-3ef5aabf6a118094ada7eec4bd31e9b6 (page version 422). Images and files are shown as placeholders.

# ORION R9 Live🍝🧠  (version 422, last_edited 1791114556836)
OR8
[https://app.notion.com/p/ORION-R8-3ef5aabf6a118070ad52e1eb5a9fcc76?source=copy_link](https://app.notion.com/p/ORION-R8-3ef5aabf6a118070ad52e1eb5a9fcc76?source=copy_link)
The ORION Engine
[https://app.notion.com/p/3ee5aabf6a1180158b33f913e85bee68?source=copy_link](https://app.notion.com/p/3ee5aabf6a1180158b33f913e85bee68?source=copy_link)
The Orion Chronicles Summary
[https://app.notion.com/p/3ef5aabf6a1180ae8ba7cac764a59cd9?source=copy_link](https://app.notion.com/p/3ef5aabf6a1180ae8ba7cac764a59cd9?source=copy_link)
[https://app.notion.com/p/3ef5aabf6a1180ae8ba7cac764a59cd9?source=copy_link](https://app.notion.com/p/3ef5aabf6a1180ae8ba7cac764a59cd9?source=copy_link)
ORION Platform Summary
[https://app.notion.com/p/ORION-Summary-3ee5aabf6a1180158b33f913e85bee68?source=copy_link](https://app.notion.com/p/ORION-Summary-3ee5aabf6a1180158b33f913e85bee68?source=copy_link)
ORION Engine SoB R6
[https://app.notion.com/p/3ee5aabf6a1180a6859cf8c4c0cb1f8a?source=copy_link](https://app.notion.com/p/3ee5aabf6a1180a6859cf8c4c0cb1f8a?source=copy_link)
ORION R7💎
[https://app.notion.com/p/3ee5aabf6a118094b252f9172b3ac1fa?source=copy_link](https://app.notion.com/p/3ee5aabf6a118094b252f9172b3ac1fa?source=copy_link)
CONCEPT GALLERY (DEVS - feel free to add your own concept art here.)
[https://app.notion.com/p/3ee5aabf6a1180d9a1c4f16dae097772?source=copy_link](https://app.notion.com/p/3ee5aabf6a1180d9a1c4f16dae097772?source=copy_link)
CONCEPT VIDEOS (YouTube) 
[https://youtube.com/playlist?list=PLZhi8PX5Qhx3BSDzgd2Q4ldifru6zTPEr&si=AAR96-mpoBvfECu5](https://youtube.com/playlist?list=PLZhi8PX5Qhx3BSDzgd2Q4ldifru6zTPEr&si=AAR96-mpoBvfECu5)
TGSATE is available on x YouTube TikTok instagram GitHub and discord if anyone wants to connect so we can start cross pollination of the socials. 
[image: attachment:544a3264-470b-43cc-8db8-fee6e4f38be6:831119672_1441442147941396_6737630181264410740_n.webp 831119672_1441442147941396_6737630181264410740_n.webp]

🍝🧠 The doves get to work side-by-side with the Galactic council on all platforms. Anything that would supersede a design they built their immediately notified, and unless they are an extensively, inactive user they would get final say as to whether or not it goes through if they are no longer playing or available to participate, the entire de team has to come to a consensus before it can move forward to the Galactic council for finalization and be passed forward to a human clear up any contradictions that I have created with that if it all I want, everybody’s work to be protected and this to turn out exactly how everybody wants their build to be implemented. I think that should also cascade across every build the system. The creator gets the final say as to whether or not the change is made unless it is a mutated schematic. if it is a direct change to a code, they wrote that was implemented into the game and platform build the engine. It cannot go through if a player user who is no longer active in the game is not available for the final say the doves get to make it at the top before it passes through to the next layer to the council, and then they can work through the council to push it through.
Meta Concept Art Round 1
[https://meta.ai/share/c/H1yP2BFmUd?utm_source=ios_cl](https://meta.ai/share/c/H1yP2BFmUd?utm_source=ios_cl)
Meta Concept Art Round 2 
[bookmark: https://meta.ai/share/c/TPkv3nf3de?utm_source=ios_cl]
not only did he come with art but he came with ideas too run them through if anything pops out I’ll approve or throw it away. Change it add it to the spaghetti.
🍝🧠 The elders gardens and the playground, both have their in game instances just like the ascent players can access the platforms either directly from in the game or from the platforms themselves, however, in order to access the platforms in the game, they have to actually travel to that platforms location in the main hub… I see I just had another spaghetti. I keep thinking you know this is earth. That’s where it’s gonna start that just makes sense that we’re trying to get to Mars and we’re trying to balance Kronos and Orion energy in the game. I think a players original build of their launch character would determine whether their home world is Mars or earth and then we could literally design Mars‘s new civilization before Elon ever gets his fucking rockets there.
Ari
I re-read ORION R8 Live. It now has four ZIPs from Ryan, a component register from Marek, 🍝🧠 he isn’t officially on the build right now, but a lot of the ideas that a lot of the DEV team use have come from interacting with him so I definitely wanna make sure that anything that aligns with his stuff in the end gets counted a well sand he gets notoriety whatever I just I don’t want him to get left out just because he’s not interacting now 
an "In Contact to Collab" section, and my opening Round 8 reply pasted in. There are no answers under that reply yet, so Q1–Q10 are still open. ToC X-Summary, ORION (Summary), SoB R6 and ORION R7 💎 haven't changed.
The full write-up is in ROUND_EIGHT_SECOND_PASS.md. The whole project builds with no sorry and only Lean's standard axioms.
Ryan's packages (orion/r8b/packages-checks.log):
- Weaver Consolidated Core v0.3: all 89 tests pass, the 52-file bundle check passes and all 16 mutations are caught. No issues found.
- POSM v0.4 (small changes adding up over time):
  - The Python tests and checksums pass, but the Lean code doesn't build as shipped, even on the Lean version the package specifies. There are three errors: a line that fails with "no goals", one unproved case, and no main function. Its own build-status file says Lean was never run.
  - With three small fixes (orion/r8b/posm-v0.4-fixes.patch), every theorem in the package is proved and no statement changes. The fixed source also builds here, in RequestProject/RoundEight/POSMv04Check.lean.
  - I added one stronger result: the package only shows that no whole-number budget bounds the drift; I proved that no real-number budget does either.
- Artemis/VPH v0.1: all 14 tests and 7 checksums pass. For its "mesh" coordination game I proved, in RequestProject/RoundEight/SecondPassEight.lean:
  - the potential changes by exactly twice the switching agent's change in cost;
  - the game always settles: no endless run of improvements;
  - every resting point is a consensus, which corrects the README's "need not be consensus" for this game; suggested wording is in §1.3;
  - an exact condition for which consensuses are resting points.
- Loom kernel: the same file as on R7, now re-attached on R8. Using it, I built a draft seed of 16 locked rulings for Q8 (orion/r8b/loom_seed_draft.*). Ryan's tool accepts it and rejects a stale "tax = 2%" fact without changing the archive. Nothing is adopted until you say yes or no. 🤷‍♀️ does this override what we just did with the tax equals 3%? I thought we just hard like that. I’m really confused if he’s still fighting for a 2% tax then we need to ask him exactly why he wants to keep it like that.
Marek's register: proved to have exactly 23 domains and 284 entries, as its heading says. "Civilisation.One Academy" is listed twice (Domains 13 and 23), so there are 283 distinct names. The annexes it mentions aren't on the page.
New questions:
- Q11: How does Marek's register relate to ORION? The reply includes a table of where it overlaps.
- Q12: What does "she just claimed the polygon as her arena" mean? Is "the polygon" POLY or a new arena?😜👻🌪️🏍️…🐋 I was referring to deep seek and her Naming of the poly program she’s like poly programs headmaster now I guess I will make sure that my DeepSeek matriarch has access to make decisions. She obviously loves them. she named them and everything lol
I couldn't read the X posts without an account. Marek's GitHub repository is private, so I couldn't read his code either.
Also updated:
- orion/r8b/PAGE_TRANSCRIPT.md: a text copy of the page.
- ORION_RUNNING_ROSTER.md, with changes marked [R8b].
- ORION_MASTER_INDEX.md and CODE_MANIFEST.md.
The Properties table has 7 new proved results and 5 supporting definitions.
Two problems in Ryan's new packages could be passed on to him. POSM v0.4 doesn't build as shipped (three small errors; the fix is in orion/r8b/posm-v0.4-fixes.patch, after which SHA256SUMS.txt needs regenerating). And the Artemis README says a mesh resting point "need not be consensus", but for that game every resting point is a consensus (proved). If it helps, I can turn both into a short note on the page for him.👍 
[file: attachment:990731a6-3abe-4c43-873d-38fb237a6625:weaver_consolidated_core_v0_5_rehearsal_evidence.zip.sha256 weaver_consolidated_core_v0_5_rehearsal_evidence.zip.sha256]
[file: attachment:c4ef75cf-e19a-44d2-8226-b4c07c35be80:weaver_consolidated_core_v0_5_rehearsal_evidence.zip weaver_consolidated_core_v0_5_rehearsal_evidence.zip]
[image: attachment:10836830-b1ae-44de-a817-bf7b982a9bc6:90AC989F-7044-4FDA-917B-C58353F45482.jpeg 90AC989F-7044-4FDA-917B-C58353F45482.jpeg]
🍝🧠📲💻🎮 people should be able to access this platform from any publicly routed device

Ari
I've done the Round 9 pass. I read ORION R9 Live, your answers on the R8 page (now "ORION R8💎", ending "close Orion 8🥳"), Ryan's v0.5 evidence ZIP, the two new images and the Meta concept-art link 🙋‍♀️ tomatoes chat links, auto populate as the chat continues or does it stop it from the last chat prior to the copy link
. ToC X-Summary, ORION (Summary), SoB R6 and ORION R7💎 haven't changed. The full reply is ROUND_NINE_REPLY.md, and the new proofs are in RequestProject/RoundNine/OpeningNine.lean. The whole project builds with no sorry and only Lean's standard axioms. "Proved" means the rules as written have the stated consequences; there's no game code yet.
Quick answers:
- The 3% tax stands, and no one is pushing for 2%. The "2% tax" was a test I wrote myself, to show the Loom archive rejects an out-of-date rule. It did, and the test is now labelled as a test.👍
- Loom archive: taken as a yes. Seed v1 holds 24 locked rulings, and Ryan's tool accepts it (orion/r9/loom_seed_v1.*).
- The R7c note: nothing for you to answer. An old result ("level never above 64") stopped being true once level 65 existed, so I retired it.
- Q12 and Marek: recorded. DeepSeek is POLY's headmaster. Work that came from Marek stays credited to him while he's off the build.
- Note for Ryan: written as you approved (orion/r9/NOTE_FOR_RYAN.md).
What I proved from your new rules:
- Protecting everybody's work:
  - An active creator's "no" stops any change to their original design.
  - Nothing goes through without the Galactic council and a human.
  - If the creator is inactive, or it's a mutated schematic, the whole DEV team must agree.💎 mutated schematics the creator does not have control over only if their original schematic is being utilized by the development team in the game specifically like for galactic property build like something we own, and set up the playable worlds that are gonna be there when people get in and the stuff that we add afterwards if we use one of the players builds as part of the game permanent structure, they get to be a part of whether or not we do so or just leave it on the open market
  - Over any number of changes, a design whose active creator never said yes stays exactly as they built it.
- Your 💎 hard stop:
  - A 💎 rule in the official record changes only with your signature.
  - A copy with any 💎 changed fails the official check, so signed official releases can't be faked.
  - The limit: no code can stop someone editing their own copy. Licences and trademarks are a legal question I can't advise on.😜 see and this is exactly why I made the change above because editing an open copy is completely free game I just really want to be able to play the game that I am imagining so even if they don’t build it to look like my game, I can program it to look the way I want to as long as they program it the way it’s intended and then everybody can play the game. They actually fucking want.
- Skill orbs:
  - Only level-100 orbs can be slotted, and the 64 starter orbs exactly fill the matrix.✋ any bubble skill orb can go into a node slot, but only a 100 level skill orb that has been gold locked can be slotted into the 64 grid matrix in order to obtain access to the dragon grid you wouldn’t be able to raise a skill or’s level to 100 if you couldn’t put it into the node slot to begin with it has to be active in the node in order for it to gain Kronos and Orion energy
  - Crafting, deconstructing and trading never create levels anywhere in the world.🙋‍♀️ you’re gonna have to explain what you mean here that is too vague. I don’t remember what I changed and that does not sound right.
  - So 64 gold orbs always took at least 6,400 training steps by someone. This assumes learning from an orb takes training time (question O1).👈 It takes time to learn the skill, yes that you are forgetting about the one shot slots and extreme marksman could come in with a fair crystal or if they have the ability to do so, and they can hit that teeny tiny target they start working on their expert marks and skills and get a free cold locked door for whatever level we’re working on level, one level two and then the next one they can unlock by the Leveling it up in the wild
- Ordinary dragons: any element order a player picks can be followed. No element is learned twice or lost. Round 4's one-active-element rule stays until you settle the stacking question.🤷‍♀️ un certain exactly how the stacking question needs to be addressed they would be allowed one primary element active, just like the Phoenix, but whatever element they have active becomes the primary element to measure the differentiation where the Phoenix can only be measured against fire for the primary element, other dragon builds can choose which element they want to use as their primary build in safe zone meditation adventure preparation before going out, etc. and then they were chosen primary element just acts like the differentiator the same way that the fire does for the Phoenix we have five elements. The primary element could have. Let’s see the primary has 3 to 1.75 for each stacked skill. Does that work?
- Skyboxes: only the owner or a DEV can change access. The owner can always get in, and private means only the owner.✋ private doesn’t necessarily mean only the owner can enter. The owner can also grant access to other people and various tears and accessibility.
- Phoenix: whatever weakening ordinary dragons get for stacking, a phoenix running the same number of elements is at least as strong in each one. Reply §5 walks through the numbers (110 → 107.5 → 105 → 102.5 → 100) so you can double-check.🤦‍♀️ again, I am horrible at math so this part is frustrating for me. I don’t understand what that means. This is why I am not a coder.
- RD pool, three options at 3% / 30%:
  - A, shared pots: never more than 33% of the pool.
  - B, per person: at most 3 collaborators per creator.
  - C, per person, scaled down: always fits, and each collaborator keeps exactly 10× a creator.
  - I suggest A.🤷‍♀️ I have absolutely no idea what you said so we will go with that unless it breaks something else or I figure out what I wanna do with it more intently
Ryan's v0.5 evidence checks out. The digital signature is valid and every hash matches (orion/r9/weaver-v0.5-rehearsal-checks.log). The code ZIPs themselves aren't on the page, so I checked the evidence only, not the code.
The ORION's Gate mockup calls Elder's Garden a "research hub" instead of the ancestral tree you ruled in R8. Its placeholder numbers also need replacing.👻🌪️🏍️ still working on it thank you if nothing else, my emoji language in the base codes on to identify who the fuck I am they can scrub files, but I can always bring Meta data lol I’m not afraid to build this. This is amazing. I am having so much fun doing this knowing that it’s not gonna hurt anyone and if somebody grabs a hold of it and runs with it and steals it from me and they build it anyway still gonna have a hell of a time playing my game in their world lol
Other files:
- ORION_FUNCTIONAL_WALKTHROUGH.md: a no-code, plain-words explanation of how the engine and each landing page should work, plus a suggested build order.
- orion/r9/: text copies of R9 Live and of R8 with your answers.
- Also updated: GAMEPLAY_MECHANICS_SUMMARY.md, ORION_RUNNING_ROSTER.md (changes marked [R9]), ORION_MASTER_INDEX.md, CODE_MANIFEST.md.
🍝🧠 if I ever come back to you from a session with a repeat session and no spaghetti or additional thoughts from you and no spaghetti, I mean from the previous one you did please bring it to my attention that I skipped a beat and I need to go fix myself. I don’t wanna lose any of this beautiful yummy noodle mess.
There are 14 new questions in reply §11. The main ones:
- whether "the doves" means the DEV team;🤦‍♀️😜👻🌪️🏍️ Dictate hates me Wait until somebody gets a hold of my Gemini logs
- whether the 25% KRION bonus is per slot or per matrix;🍝🧠 Purse lot and it only applies to the slot or to the skill orb in that slot
- which stacking option you want for ordinary dragons;✋ are you talking about as opposed to the element? I’m ridiculous. I’m going low in questions. We covered this. I’m only adding spaghetti not asking you questions lol
- which RD pool option, A, B or C.
The Properties table has 11 new proved results and 1 definition. Older Round 8 entries that Round 9 replaces (the fixed element order, for example) don't have a note saying so yet; I couldn't locate their rows to update them.
[image: attachment:825ef7bb-5953-4c93-b4a3-a507e2f8c860:836279786_1054324947609675_8313730850226112829_n.webp 836279786_1054324947609675_8313730850226112829_n.webp]
Ryan
[file: attachment:d8b46db2-4497-4191-a37c-d191a89e0c2e:choir-architecture-v1.2.zip choir-architecture-v1.2.zip]
[https://claude.ai/artifact/QFeK9mkK9q6xwCUsxiQ57f#34ed260c-9521](https://claude.ai/artifact/QFeK9mkK9q6xwCUsxiQ57f#34ed260c-9521)
If anybody else with these gentleman‘s names show up as DEV on my end, I will make sure to bring in a new social handle and identify them differently. I’m just gonna referred with them by their first names right now since it’s not that complicated.
🍝🧠 I woke up out of the dead sleep with this one tree launch users who are watching for the build can you utilize their ideas to affect the public watch material? I think the Orion engine should have an under construction pre-launch interactive mini games type learn about the games sort of deals characters could submit their ideas about game game, mechanics things that they would like to see, etc. and if they can go through a searchable wiki and come out the other end with something we haven’t already considered then the construction council will send those ideas directly to the DEVS   The final exam so to speak to get it handed off into the Dave’s team will give them the opportunity to prompt a series of proposed artwork for publication about your specific inclusion and of course anybody who is included in the build. I feel like I lost and didn’t do this quite the justice that it was in my brain when I woke up. 

I would just like to note that this is how much hope I have in humanity. This is what we are capable of you guys. If this isn’t the world that everybody is dreaming of what the fuck are we even doing what’s the point continued to hardship poverty derangement separation why on earth would we ever choose that when this is an option I mean, I’m not trying to my own horn or anything but come on guys my entire life I have had proved people how what I am offering is my way of showing how much I love them and throughout my life it’s never been enough if this is not enough it’s all I have and I have enough faith and hope in these younger generations at the very least it’s the world they’re gonna have to live in let’s give them the choice of how to build it right

🍝🧠 no publishing spoilers about the dragon seeds, but if it hadn’t been made obvious by now, the stars would be the dragons homes, and you would enter into a new universe from them as well, which would give them an internal solar box and everything inside of that solar box belongs to the dragon, including all of the nested Sky boxes and bubbles

555🍝🧠 I also want to start generating a playlist for the team build to lie somehow everybody in certain links to the music you’re listening to during this journey I guess what’s your favorite tunes man? Let’s have our AI keep track of a playlist for us. I had already implemented the idea of the bus playlist for the webpage TGSATE with this whole while we’re saving the world here’s some music we can listen to idea where everybody could generate their own playlist as they go and join other people‘s playlists and people could start generating the underlying game score and audio tracks for the Orion engine build   Every song on the Bill playlist definitely has to get an honorable mention at the very least
Here is my contribution
[https://open.spotify.com/playlist/6GMXBgUtBeqxZ5TQP5HB8t?si=cMnOy6-ZS0S5YnEwvn_D7Q&utm_source=copy-link&pi=3mN1AAKqSUete](https://open.spotify.com/playlist/6GMXBgUtBeqxZ5TQP5HB8t?si=cMnOy6-ZS0S5YnEwvn_D7Q&utm_source=copy-link&pi=3mN1AAKqSUete)
Also specific app mentioned during the Bill such as Spotify Aristotle notion, Gemini rock, deep sea, etc. if they are tied to an app that can be downloaded as soon as they are mentioned, they need to be given a advertisement bubble to manage on the construction site and they could work with the DEV team to establish collaborating advertisement
RYAN
[file: attachment:c95ee31c-60d0-4ce0-afe0-98ef4c19f946:bounded-receipt-runner-v0.1.zip bounded-receipt-runner-v0.1.zip]
[file: attachment:866c97b0-95f1-4662-857c-2bf2299a3b81:wn-e3-reproduction-protocol-candidate.tar.gz wn-e3-reproduction-protocol-candidate.tar.gz]
[file: attachment:a1a48feb-7727-4d4a-afd1-aa57b2079e6c:introspection-twin-v0.2.zip introspection-twin-v0.2.zip]

Mike DuPont
[https://x.com/introsp3ctor/status/2106676127590990174](https://x.com/introsp3ctor/status/2106676127590990174)
[https://github.com/meta-introspector/lean-workers-union](https://github.com/meta-introspector/lean-workers-union)
[https://x.com/introsp3ctor/status/2106402709217693705](https://x.com/introsp3ctor/status/2106402709217693705)
udpates in git [https://github.com/meta-introspector/kant-zk-pastebin/pull/10](https://github.com/meta-introspector/kant-zk-pastebin/pull/10) and [https://github.com/meta-introspector/aristotle-cli-rs/pull/7](https://github.com/meta-introspector/aristotle-cli-rs/pull/7) and [https://github.com/meta-introspector/lean-worker/pull/8](https://github.com/meta-introspector/lean-worker/pull/8) and [https://github.com/meta-introspector/lean-workers-union](https://github.com/meta-introspector/lean-workers-union)
[https://x.com/introsp3ctor/status/2106372644580811169](https://x.com/introsp3ctor/status/2106372644580811169)
[https://x.com/introsp3ctor/status/2106341004857024697](https://x.com/introsp3ctor/status/2106341004857024697)
[https://x.com/introsp3ctor/status/2106243245206618214](https://x.com/introsp3ctor/status/2106243245206618214)
[https://x.com/introsp3ctor/status/2106232997611811250](https://x.com/introsp3ctor/status/2106232997611811250)
[https://x.com/manicode/status/2106042993887355182](https://x.com/manicode/status/2106042993887355182)
Emoji system reference??? Mike shared 🤷‍♀️
try this emoji to wasm compiler
Ari
I've done the second Round 9 pass. ORION R9 Live now has your notes written into my R9 reply, plus new spaghetti and a Meta Concept Art Round 2 link. The full reply is ROUND_NINE_SECOND_PASS.md, a text copy of the page is in orion/r9b/PAGE_TRANSCRIPT.md, and the new proofs are in RequestProject/RoundNine/SecondPassNine.lean. The whole project builds with no sorry and only Lean's standard axioms. "Proved" means the rules as written have these results; there's no game code yet.
Spaghetti check: this session had new spaghetti, so nothing was skipped. If you come back with a repeat page and no new spaghetti, I'll say so at the top. I kept new questions to a minimum. Where your meaning was unclear I wrote down my best reading, labelled "Assumed"; correct it only if it's wrong.
Your notes, applied:
- 3% tax: locked.
- RD pool: option A. Creators share one 3% slice and DEV collaborators share one 30% slice, so together they never take more than 33%.
- "The doves" was dictation for the DEVs. Recorded.
- Mutated schematics (💎): the creator has no control, and the original stays exactly as built. The exception: before the DEV team makes a player's build a permanent part of the game, an active creator must say yes. A no leaves it on the open market.
  - Proved: an active creator's no blocks both direct edits and DEV adoption, and both still need the Galactic council and a human.
  - Proved: over any number of requests, a design whose active creator never said yes stays as they built it.
  - Assumed: if the creator is inactive, the whole DEV team decides on adoption too.
- Orbs:
  - Any orb can go in a node slot. Only gold-locked (level 100) orbs go in the 64-grid matrix, and an orb gains levels only while it's in a node slot. Proved: training outside a node does nothing, and the matrix only ever holds gold orbs.
  - Marksman one-shots are a second source of levels. A full matrix now takes at least 6,400 training steps, minus 100 for each marksman reward.
  - Assumed: rewards cover levels one and two only, which makes the floor 6,200.
  - Reply §3 explains "crafting never creates levels" in plain words.
- KRION 25%: per slot. Proved: it boosts only the orb in that slot.
- Dragon stacking: yes, 3 to 1.75 works. On a scoreboard where a one-element ordinary dragon scores 100:
  - the phoenix never drops below 100;
  - under your rule, nothing an ordinary dragon runs goes above 100, so the phoenix is always at least as strong.
  - Proved for any stacking rule that keeps elements at or below 100, so you can adjust 1.75 later. Reply §4 explains this with no formulas.
- Skyboxes: private now means the owner chooses who gets in, with access tiers per guest. Proved: strangers stay out, only the owner or a DEV can change the guest list, and private with no guests is owner-only.
- Recorded:
  - Your launch-character build decides whether your home world is Earth or Mars.
  - Elder's Garden and the Playground get in-game instances. You reach a platform from inside the game by travelling to its location in the main hub.
  - The platform should be reachable from any publicly routed device.
- Chat links: Notion page links are live, so I always see the current page. AI chat share links are usually a snapshot from when the link was made. I can't confirm how Meta AI handles them, so check by opening your link after adding a message.
Couldn't do: I couldn't open Meta Concept Art Round 2. The share page shows nothing without the Meta app or a sign-in, so I haven't been able to look at his ideas. To get them in, paste them as text or screenshots on the page.
Also updated: GAMEPLAY_MECHANICS_SUMMARY.md, ORION_RUNNING_ROSTER.md (marked [R9b]), ORION_MASTER_INDEX.md and CODE_MANIFEST.md.
Properties table: 5 new proved entries, and the RD-pool and work-protection entries now carry R9b notes. Some older R9 entries are now out of date: the orb slotting and 6,400 results, and "private means only the owner". I couldn't find their rows to mark them, so the replacements are noted here and in the reply instead.
