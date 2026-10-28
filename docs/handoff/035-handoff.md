# Handoff 035: the atrium rebuilt against the blueprint; pushed up to 034; Market, Lomi King and the tiers next
Previous: 034-handoff.md (then 033, 032, 031, 030, 029 for the environment and rules). This file only records what changed after 034.

## Status
- The owner saved a backup after the concrete repaint, said replaced assertions are fine "as long as they mirror the actual blueprint as the source of truth" (closes the open retired-assertion confirmation from 031 to 034; every replacement still needs a logged reason), and approved the push.
- **Pushed**: `feat/tour-v2` went `8bd1d76..095f6de` (23 commits, only `.luau` and `.md`, no secrets; the public repo McLector/Lipa-Highlights-Rblx; `main` untouched, no PR). The four commits below and this file are LOCAL; ask before the next push.
- **Atrium round done** (the owner left the choice of what to fix to me): the tests agent measured the drawing and cross-checked screenshots. Confirmed and fixed: outer-end slab proportions (two tall slabs plus one low wide slab, was all wide and low), column layout (4 thick front columns with uneven gaps and 4 slim ones about 16 studs further in, was 8 identical columns on one line), glazing (pane grid: mullions at most 4 studs apart and horizontal transoms per wall, was bare mullions 5.4 apart). Dropped as not confirmed: roof shape and plinth (the model already has a ridge, fold lines, edge band, thick white base and balcony stack).
- `run_all` in Edit mode: ok=true, 0 mismatches. EXPECTED now: `site01_check` 142, build 01 parts 2498, build 10 parts 1273, world parts 9240, `roads_check` 267, `routes_check` 16, `qa_check` 85, unit 246, `sites_check` 277, `npcs_check` 237, `guides_check` 123, `placeholders_check` 32, `site10_check` 96, terrain cells 1794962.
- NOT done: the owner's look at the new atrium beside the blueprint; the Market, Lomi King, the Standard and Light tiers.

## Commits (local, no attribution trailer)
`7905039` test(site10): expect the atrium columns, slabs and glazing from the blueprint
`dd52ce9` feat(site10): rebuild the atrium slabs, columns and glazing from the blueprint
`6ce2d45` test(run_all): expect the atrium round of City Hall
`35bcaa5` docs(site10): log the atrium round and the owner's word on assertions
(plus the commit that adds this file; pushed already: everything up to `095f6de`)

## Evidence
- Red first: eight assertions added (nothing replaced, nothing loosened), whole check 89 passed / 7 failed against the old atrium (0 tall slabs, 8 columns in the front row, 0 behind it, SE mullions 5.36 apart and 0 transoms, SW 5.40 and 0); negative controls on a throwaway clone each failed the right rule and a faithful clone passed 96/96. Green after the build: whole 96/0, blocks 28/0, wing 25/0, general 24/0, forecourt 15/0, landscape 8/0; two builder runs in a row gave identical counts (Wing 332, Blocks 355, build 10 1273).
- I re-ran the check and `run_all` myself after each agent job. Disk equals Studio (bytes / newlines / djb2): `site10_wing` 20896/434/115855016, `site10_blocks` 16586/321/662262913, `site10_check` 57917/1076/847882002, `run_all` 15264/115/1213358059; `builders/site10.luau` unchanged 11098/214/4268575783.
- Shots I looked at: the owner's angle (-165,80,-215) to (-285,28,-235) and the blueprint view (-95,85,-285) to (-275,22,-300). The agent also looked at the south-east, under-canopy and top-down views. Two blank-viewport stops happened this stretch (the tests agent once, I asked the owner to click; fine afterwards).

## Findings and caveats
- The tall slabs read slightly barrel-shaped (the inherited centre-facet push-out); the drawing's are flat. AB3 is now a small 7.5 x 8 slab: a longer AB3 broke the 10-stud clearance rule over BalconySW1 (0.40) and the RailSW2 hazard still applies to anything upper-tier near u 46.
- Seen end-on from under the canopy the SE wall still reads as a plain dark panel; the roof was left alone on purpose.
- AB6 is excluded from the "tall slab" rule on purpose (a 6.6-wide strip); AB4 and AB5 keep the low-slab guard satisfied.
- The viewport goes blank after the Studio window idles: click the 3D view and retake.

## Pending on you
1. A last look at the atrium beside the blueprint (owner's angle camera (-165,80,-215) looking at (-285,28,-235); blueprint view (-95,85,-285) looking at (-275,22,-300)) and your verdict (barrel-shaped slabs, columns, glazing).
2. Save the Studio state as a NEW backup (never Ctrl+S); the one after the concrete repaint does not hold the atrium.
3. Pushing the four local commits and this file.
4. Slice 12 outfit-texture upload: read as OK; I will say so right before the first upload.

## Next steps
1. Resume check: `list_roblox_studios` (id last `9835b37f-176c-4874-8675-ab463aaf9372`), Edit mode, `run_all` ok=true with the EXPECTED above, `git status` clean.
2. Take the owner's verdict on the atrium; fix what the owner names (flatten the slab faces if barrel-shaped reads wrong; one Sonnet job, tests first).
3. Then the Market (348 x 330 from `PublicMarketBP1.jpg` and BP2; footprint per `docs/footprints.md`: east edge stays x -228, about 348 x 330 at (-402,160)), Lomi King (pink 5-storey tower, curved glass bays, orange canopy "LOMI KING"; the spawn-to-Lomi walk was 690.81 against a cap of 805 and must stay under it), the Standard tier (Carmel, Outlets, Farm, Malarayat) and the Light tier (Tagbakin, Cafe). Same loop and roles (Opus orchestrates, Sonnet 5.5 builds one job per agent, tests first and red, shots beside the drawing). Repaint the terrain under each site's footprint to concrete as part of its rebuild (the owner dislikes the swaying grass blades through paving; ask the owner for the scope per site). The logo rule is City Hall only; every other site keeps the text-only rule unless the owner says otherwise.

## Context log
- Orchestrator: one agent per job. Atrium tests 110k then 149k tokens (resumed once after a blank viewport), atrium build 146k / 40 calls (one round, check already green). I consulted the advisor before the concrete job (it fixed the scope, asked for the Concrete colour check and the grep for other pins) and not again for the atrium (the design carried over). This is a fourth stretch in one session: start the Market in a NEW session.

## Continuation prompt
```
Continue the Lipa Tour v2 project after the City Hall atrium round. Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox (git root; the blueprint drawings live one level up in ..\2nd Reference\). Branch feat/tour-v2, never main. Read docs/handoff/035-handoff.md and then 034, 033, 032, 031, 030 and 029, README.md (its AI rules are binding), docs/PLAN-v2.md, docs/footprints.md, docs/shot-kit.md, briefs/site10.md and my memory files structures-match-blueprint-strictly and stop-at-context-cap-and-hand-off.
First: list_roblox_studios (ids change), Edit mode, run require(game.ServerStorage.Checks.run_all:Clone())() and decode the JSON string with HttpService:JSONDecode: expect ok=true with the EXPECTED numbers in handoff 035. git status clean; git log shows the 035 handoff commit on top of 35bcaa5; origin/feat/tour-v2 is at 095f6de. Stop and report any mismatch. Ask me for a NEW backup name before any destructive Studio rebuild (never Ctrl+S).
Roles: you (Opus) orchestrate and review; Sonnet 5.5 builds, one job per agent, briefed in full; consult the advisor before an approach, when a check stays red twice, when sources disagree and before declaring done. Session cap 250k, write the handoff and stop near 200k.
Rules: structures follow the blueprint strictly (judged by eye, shot beside the drawing, by you and then by me; checks are guard rails; a replaced assertion is fine when it mirrors the blueprint, with a logged reason in briefs/siteNN.md); tests first and shown red; disk and Studio hashes equal and re-hashed after every Studio edit (multi_edit replace_all can lie); Conventional Commits, NO Co-Authored-By trailer, test then feat; only you run git; ask before every push; never run builders/world.luau or placeholders in default mode; no Roblox upload without telling me first; never change place or experience settings; dialogue ASCII only; look at every screenshot, one capture at a time; two blank frames in a row = stop and ask me to click the 3D viewport.
Job: first my verdict on the City Hall atrium (fix what I name), then the Market, Lomi King, the Standard tier and the Light tier. End each stretch with the next handoff and remind me to save a backup.
```
