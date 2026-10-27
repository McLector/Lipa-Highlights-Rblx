# Handoff 030: Credits Plaza with APA 7 references done; City Hall redo next
Previous: 029-handoff.md (read it first: environment, rules, decisions, the Cathedral numbers). This file only records what changed after it.

## Status
- The credits board now lives in a dedicated **Credits Plaza** south of the Cathedral, east of Road E (floor x 24..150, z 274..346; entry path from Road E at z 310). It replaces the old six-panel board at z 205, whose aisle led to the closed Cathedral fence. The model keeps the name `Workspace.World.CreditsBoard` (61 parts, nine panels in two facing rows, a sign "CREDITS AND SOURCES", two benches, six lamps). Panel 1 carries the title, the group identity (Casanova, Nino Gabriel C.; Cruzat, Shana Czane M.; Gonzales, Khatrina Joice M.; Morada, Myre Lector - Art Appreciation - C4A; ASCII "Nino"), the two project lines (blueprints made with Gemini, reference photos) and four licence notices; panels 2 to 9 carry the 78 APA 7 references with italic titles (RichText on the `Ref<i>` labels only).
- `run_all` in Edit mode: ok=true, 0 mismatches. EXPECTED now: `site01_check` 142, build 01 parts 2498, world parts 9173, `roads_check` 267, `routes_check` 16, `qa_check` 85, unit 241, `sites_check` 277, `npcs_check` 237, `guides_check` 123, `placeholders_check` 30, terrain cells 1794362.
- Push state: `feat/tour-v2` was pushed once (at `3895ded`, handoff 029); the four credits commits below and this handoff are LOCAL. Ask the owner before pushing.

## Commits (local, no attribution trailer)
`1b942ae` test(credits): expect the APA 7 reference list in CreditsData
`c34b6c7` feat(credits): add 78 APA 7 references and notice lines to CreditsData
`86d9fdb` test(credits): expect the Credits Plaza and its APA 7 board
`4401a4c` feat(credits): build the Credits Plaza with the APA 7 reference board
(plus the commit that adds this file; earlier: `3895ded` docs(handoff): 029, already pushed)

## Evidence
- Unit suite 227 to 239 (12 reference cases; red 33 run / 21 passed / 12 failed on the CreditsData filter, then 239 / 239), then 241 / 241 after the plaza job (3 cases red, then green). `credits_crosscheck.ps1`: "10 sites, 28 urls, 25 tour sources, 78 references, 4 notices, 0 mismatched", exit 0, with a catch-a-mismatch proof (a lower-cased "Gemini" and a swapped pair both fail it).
- `qa_check` 68 / 17 failed on the old board, then 85 / 0; `site01_check` 141 / 1 then 142 / 0; `roads_check` section 6c red 265 / 2 (the plaza ground read Grass) then 267 / 0 after `roads_extra` repainted it (cells 1794162 to 1794362, second run +0).
- Route Road E start (0,225) to the plaza entrance (30,3,310) measured 97.47 studs in Play, cap 112; the aisle between the rows is open (110.0 studs straight).
- Disk equals Studio (bytes / newlines / djb2): `CreditsData.luau` 48644/231/1023657573, `CreditsData_Test.luau` 17732/404/1710128660, `qa_check.luau` 27896/435/3371647592, `roads_check.luau` 31676/550/1827852738, `routes_check.luau` 6657/97/3632899728, `site01_check.luau` 97535/1319/3999621071, `roads_extra.luau` 3230/59/2093407081, `WelcomeClient.client.luau` 4151/100/1870310590, `run_all.luau` 12513/111/868280494. `builders/credits.luau` (12235/251/1071755574) is disk only.
- Research: four lookup agents read 53 source pages; I spot-checked 8 against the live pages (The Poor Traveler x1, Jerome Doe's blog, the Carmelites page, Philippine Primer, Daily Tribune, WOWBatangas, Aboitiz press release, one Commons file) and all matched.
- Shots looked at: plaza from the north-west before and after the ground repaint (speckled floor with grass through it, then a clean pale slab), a panel close-up at reading distance (italic titles render, text sharp), the sign and entry path from Road E. Not looked at: the south-east view, the old spot at z 205 (should be empty), panels 2 to 9 other than the first references panel.

## Findings and fixes
- The plaza floor needs terrain repainted from Grass to Pavement (`builders/roads_extra.luau` PAVED regions { 24,152,272,348 } and { 4,24,304,316 }); without it the grass blades poke through the floor part and hide the entry path.
- Long URLs wrap mid-word, so the 78 references pack into 8 panels (9 with the title panel), not 12; the last panel is short (220 px of 520). The widest line is 683 px of 684.
- The data agent re-ordered the references into APA 7 letter-by-letter order with undated works first; the Ramon FVelasquez photo letters were reassigned (2013a to 2013i by title).
- Pages the research tool could not open (HTTP 403 or empty): Tripadvisor (two), Architizer, the Menufyy cafe page, the Farm event page, Ayala Land (two), Inquirer (two), the PIA mirror. Their entries use the group's own reference text or a bracketed description from the URL; the Ayala Land City Hall article title comes from its URL. `content/site_credits.md` "Notes for the group" lists them for a 30-second browser check.

## Decisions and deviations
1. `CreditsData.identity` (owner-only) was edited because the owner supplied the values; the board prints "Nino" for the owner's spelling with an n-tilde, because on-screen text is ASCII only.
2. WelcomeClient step 4 now reads "4. Photo sources are on the credits board in the Credits Plaza, south of the Cathedral. Take the jeepney, exit by a side gate, walk south." (the agent dropped two words so it stays two lines; the owner approved the plan that carried this wording, and it is shown for a last look).
3. RichText is on for the `Ref<i>` labels only (an exception to the RichText-off rule; the owner approved it with the plan); all other labels stay off.
4. The Gemini citation has no year or model ("Google. (n.d.-a). Gemini [Large language model]. https://gemini.google.com/"), as the owner chose.
5. The first plaza job built the floor without a terrain repaint (my brief said no terrain write); a follow-up job fixed it. A job agent also kept building after two blank frames instead of stopping; nothing was damaged.
6. I edited `EXPECTED` again as the orchestrator with a reason on every number.

## Known issues
- The two Flickr photos by "mollyboy" are marked All rights reserved on Flickr; they are cited and used only as visual reference.
- Stale text left untouched: the site01_check keep-out assertion names still quote the old board at z 199.8..210.2; a comment in `builders/site01.luau` (`PLAZA_S`) says the board is at z 203.8; a line in `content/site_credits.md` still says "Google Street View ... massing only"; `docs/PLAN.md` and older handoffs mention the old board. `PLAZA_S` (195) could now move back to 198 but would change the Road E walk, so it was left.
- The grass stands against the plaza slab at x 24 outside the entry path (hard edge, as specified).
- Site 01 has 2 spare parts and an exact-count assertion; see 029.

## Pending on you
1. Save the Studio state as `backups\slice-29-wip7.rbxl` (a new name, never Ctrl+S); `slice-29-wip6.rbxl` (23:06) holds the data job and the old board, not the plaza.
2. A last look at the Credits Plaza in Studio from the south-east and at the old spot at z 205.
3. A 30-second browser check of the blocked pages if you want their APA titles exact (list in `content/site_credits.md`).
4. Approve the City Hall change table for game texts that mention the "72 elevated blocks" when it is brought.
5. Slice 12 outfit-texture upload: read as OK, and I will say so right before the first upload.
6. Pushing the four credits commits (and this file).

## Next steps
1. Resume check: `list_roblox_studios`, Edit mode, `run_all` ok=true with the EXPECTED above, `git status` clean.
2. **City Hall (step C)**, planned but not started: rebuild strictly from `..\2nd Reference\new_town_hall\3d Blue print\Lipa City Hall Blueprint.png` (the owner: the blueprint is the absolute truth; pictures only if it is lacking). Angled atrium wing under a huge faceted canopy on tall round columns, a long 4-storey wing of large staggered white-brick boxes with dark glass bands, wide green terraced steps, a forecourt loop; the small-block grid (the "72 blocks") goes. Footprint 240 x 286 near (-270,-305), east edge x -150, no road changes. Keep `requiredProps` (`Blocks`, `Landscape`, `Wing`, `Forecourt`, `JeepStop`), SiteData row 10 pinned positions, Ate Joy, the spawn (-208,0.8,-260), and green `placeholders_check`, `roads_check`, `sites_check`. Bring the owner a plan first and a change table of every game text that says "72 elevated blocks" (quiz, three facts, art line, glossary in `content/tour_content*.md`); dialogue changes need approval. City Hall photos: the Ayala Land blog (credited already as Ayala Land (n.d.-c) in the references); the earlier "City Hall reference photos: Google Street View" wording is gone from the board.
3. Then the Market (348 x 330 from `PublicMarketBP1.jpg` and BP2), Lomi King, the Standard tier (Carmel, Outlets, Farm, Malarayat) and the Light tier (Tagbakin, Cafe), and the Blender pilot (the owner starts the Blender addon; the owner does every Studio import and upload).

## Context log
- This orchestrator session ran to about 544k tokens (the owner's cap is 250k, handoff at about 200k). I wrote handoff 029 at the advisor's warning and still started the credits jobs; the owner reminded me, and I saved the rule in my notes. Finish only the job in flight, then hand off.
- Agent tokens / calls (harness): APA research 74k / 22, 74k / 23, 78k / 27, 74k / 24; credits job A 174k / 44 then 196k / 13; credits job B 251k / 63 (it kept building after four blank frames); ground repaint 92k / 28.

## Continuation prompt
```
Continue the Lipa Tour v2 project after the Credits Plaza (Slice 4). Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox (git root; the blueprint drawings live one level up in ..\2nd Reference\). Branch feat/tour-v2, never main. Read docs/handoff/030-handoff.md and then 029-handoff.md, README.md (its AI rules are binding), docs/PLAN-v2.md, docs/footprints.md, docs/shot-kit.md and the memory files structures-match-blueprint-strictly and stop-at-context-cap-and-hand-off.
First: list_roblox_studios (ids change), Edit mode, run require(game.ServerStorage.Checks.run_all:Clone())() and decode the JSON string with HttpService:JSONDecode: expect ok=true with the EXPECTED numbers in handoff 030. git status clean, the handoff commit on top. Stop and report any mismatch. Ask me to save backups\slice-29-wip7.rbxl before any destructive Studio rebuild.
Roles: you (Opus) orchestrate and review; Sonnet 5.5 builds one job per agent, briefed in full; the advisor is consulted before an approach, when a check stays red twice and before declaring done. Session cap 250k, write the handoff and stop near 200k.
Rules: structures follow the blueprint strictly (judged by eye, shot next to the drawing, by you and then by me; checks are guard rails); never loosen an assertion, replace only with a logged reason in briefs/siteNN.md; tests first and shown red; disk and Studio hashes equal and re-hashed after every Studio edit (multi_edit replace_all can lie); Conventional Commits with NO Co-Authored-By, test then feat; only you run git; ask before every push (the four credits commits are local); never run builders/world.luau or placeholders in default mode; no Roblox upload without telling me first; never change place or experience settings; dialogue ASCII only; look at every screenshot, one capture at a time; two blank frames in a row = stop and ask me to click the 3D viewport; keep the Studio viewport rule: do not keep building after two blank frames.
Job: City Hall (step C): read the blueprint first, bring me a plan and the "72 elevated blocks" change table, wait for my go, then build. After City Hall: Market, Lomi King, then the Standard and Light tiers.
```
