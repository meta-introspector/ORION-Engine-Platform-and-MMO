Text copy of the "ORION R7 Live" Notion page as read on 2026-10-03 (the page was still being edited while I read it; this is the latest version I saw).

(page) ORION R7 Live
  (text) ORION Platform Summary
  (text) [https://app.notion.com/p/ORION-Summary-3ee5aabf6a1180158b33f913e85bee68?source=copy_link](https://app.notion.com/p/ORION-Summary-3ee5aabf6a1180158b33f913e85bee68?source=copy_link)
  (text) ORION Engine SoB 100326
  (text) [https://app.notion.com/p/3ee5aabf6a1180a6859cf8c4c0cb1f8a?source=copy_link](https://app.notion.com/p/3ee5aabf6a1180a6859cf8c4c0cb1f8a?source=copy_link)
  (text) ORION R6
  (text) [https://app.notion.com/p/ORION-R6-LIVE-3ee5aabf6a1180439321e0e133178eea?source=copy_link](/p/3ee5aabf6a1180a6859cf8c4c0cb1f8a?pvs=25)
  (text) CONCEPT GALLERY (DEVS - feel free to add your own concept art here.)
  (text) [https://app.notion.com/p/3ee5aabf6a1180d9a1c4f16dae097772?source=copy_link](https://app.notion.com/p/3ee5aabf6a1180d9a1c4f16dae097772?source=copy_link)
  (text) CONCEPT VIDEOS (YouTube) 
  (text) [https://youtube.com/playlist?list=PLZhi8PX5Qhx3BSDzgd2Q4ldifru6zTPEr&si=AAR96-mpoBvfECu5](https://youtube.com/playlist?list=PLZhi8PX5Qhx3BSDzgd2Q4ldifru6zTPEr&si=AAR96-mpoBvfECu5)
  (text) TGSATE is available on x YouTube TikTok instagram GitHub and discord if anyone wants to connect so we can start cross pollination of the socials. 
  (text) Ari’s R6 final readout:
  (text) I went through the whole "ORION R6" page. My full reply is in ROUND_SIX_REPLY.md, and a text copy of the page is in orion/r6/PAGE_TRANSCRIPT.md. Your new answers are proved in RequestProject/RoundSix/RulingsSix.lean. The project builds with no sorry and only Lean's standard axioms.
  (text) 👍 I will be sure to examine everything eventually. Please just doing what you’re doing being sure to keep highlighting what has been fixed, what broke, what superseded and needs permission to commit, what holes are still in the lore, platforms, game play, ect. (all aspects of the build)  that still need addressed. Update the running roster each turn please noting where there build needs addressed and other ways you can identify it would be useful in platform navigation and game play, and add any questions, comments, concerns each run moving forward please. 
  (text) The strength question, asked directly: if a normal player's elemental skill is 100, does every non-phoenix dragon sit between 200 and 220, with the phoenix at 242 or more? A yes keeps the 2×–2.2× band you approved and the 2.42× phoenix floor proved in Round 5. If not, give me one example in numbers and I'll rebuild the rule from it.
  (text) 🍝🧠Oh my God this is where the leveling comes in. I knew there was going to be some type of leveling that had to occur so not only can sorry not only does a player have to unlock the 64 notes to become a level 64 player the skill levels themselves would max out at 100 and then utilize the skill levels as the leveling system does that work or did I just strain spaghetti and throw it on the wall?
  (text) Your answers, proved:
  (bulleted_list) Council, three strikes: I took a "strike" to be a reassessment round that brings a new no.👍
    (bulleted_list) Three strikes put the motion out, so the council always decides within three reassessments.
    (bulleted_list) Before the third strike, the Round 5 rule is unchanged.
    (bulleted_list) A struck-out motion can be brought back from day 7 after the strike, and not earlier.🍝🧠 The wording you have here is what weird struck out motion can be brought back in after a seven day cool off after they’ve hit the three strikes you’re out just so we’re clear
  (bulleted_list) Royalties, 2% tax: when a user hard-resets, the arenas get exactly (rate × that user's share) and the user keeps the rest. Other users are unchanged and nothing is lost. At 100% this is the Round 5 rule; at 2%, a share of 100 splits into 2 for the arenas and 98 for the contributor. 🛑 created items/schematics gain 2% tax upon purchase from seller and carry character/user tags || hard reset = anonymous flag on created items/schematics = 2% user gain goes to admin arena pool. Areana payouts take 2% from the total payout (not per contribution) before allocation for arena pools. Monthly admin areana pools empty “into rebuilding the world” - and is allocated evenly to every admins user profile to allocate as they wish. DEVs get one character with infinite access to resources/materials/published schematics etc. they can also petition a user to work with them on an already published schematic to increase its value and usability for a higher gain as a dev assisting contributor. Any schematic that is in use by the Dove team that gains a pool the original schematic creator will automatically be allocated at a subdivided 2% of total pool re-distribution and any player made schematic arena will automatically be given 2% of the total gains at that arenas final pool prior to monthly reset. If a player directly worked with the DEV team on a used schematic, they will be given 10 times the reward from that schematics RD pool
  (bulleted_list) Names: Elder's Garden (the project page, also "bedrock"), Playground (social media) and the lore Elder's Garden are recorded. 🛑 again … The ORION Engine (project build) ORIONs Gate (landing page) The Playground (social community) The Orion Chronicles (MMO) The Ascent (EDU HUB) HARD 🛑💎 until otherwise specifically changed. All name suggestions from other contributors MUST be routed for approval (even mine 🤦‍♀️) no exceptions 💎💎💎
  (text) Matthew's Zoo: 43 core names + CHIMERA, WOODPECKER, NIGHTENGALE, HUMMINGBIRD = 47 distinct animal names. Adding PULSE, HIVE and SHEPHARD gives 50 distinct entries. Matthew didn't list the 43 on the page, so I took the earlier Core list minus PULSE, HIVE and SHEPHERD. The reply lists all 43 for him to check, along with the spellings and the order of the last four.
  (text) Ryan's files (I ran everything myself):
  (bulleted_list) Repeats: two pairs of files were exact duplicates. The two audit PDFs differ only in "9" vs "8" repos with CI; the second PDF (8) is correct.
  (bulleted_list) lean-workers-union v0.7: all its Python checks pass, but the Lean part doesn't build on its own pinned Lean 4.34.1. orion/r6/lean-workers-union-v0.7-fixes.patch fixes it; with the patch it builds with no sorry and its smoke test passes.
  (bulleted_list) dragon kernel v0.1–v0.3: the Python tests pass, but the Lean part doesn't build in any version. orion/r6/proofs-arena-dragon-kernel-fixes.patch makes all three build.
  (bulleted_list) ci-hardening-patches tarball: all 11 patches apply to his live repos, every action pin matches its real release, and only the exceptions he disclosed remain.
  (bulleted_list) Live-application bundle: it has a bug — every patch its script generates fails to apply. My fix is in orion/r6/portfolio-ci-hardening-application-v1-make_patch-fix.patch; with it, all 15 patches apply and the audit shows no gaps.
  (bulleted_list) Overlap: the tarball and the bundle overlap, so Ryan should use one or the other. Passing tests and clean audits are not a security review.
  (text) Gallery: 49 images, no duplicates. My notes on them are things I read off the images, not proved results. Two open points: the orb wattage steps aren't even, and there are two sets of stage names.
  (text) Waiting on your answers: the strength check above; who gets the other 98% (I assumed the anonymous contributor); whether the first round's no counts as strike 1; Matthew's three Zoo checks. Five new entries are in the Properties table, all marked proved. The royalty and strike entries note which readings are still unconfirmed.
  (image) <attachment:fa50429a-451c-4831-b831-c81e6e5a8b8c:833126247_3208779576188931_870008373966888143_n.webp id=3ee5aabf-6a11-80a5-8b11-f2b0a4a62283> 833126247_3208779576188931_870008373966888143_n.webp
  (file) < id=3ee5aabf-6a11-8039-acb6-e1b46f8b8eef> 
  (text) Ryan
  (text) [https://openai.com/index/towards-safety-cases-for-frontier-ai-training](https://openai.com/index/towards-safety-cases-for-frontier-ai-training)
  (file) <attachment:cb7a9cbd-fa1f-46b1-abae-d395020acc21:Weaver_Agent_Security_Pilot_v0.2.zip id=3ee5aabf-6a11-8075-8ef5-cc5d29e57e99> Weaver_Agent_Security_Pilot_v0.2.zip
  (text) 
  (text) 
  (text) 
  (text) 
  (text) 
