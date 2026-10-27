# Handoff 031: City Hall rebuilt from the blueprint (Step C), facade round and owner look next
Previous: 030-handoff.md (then 029 for the environment and rules). This file only records what changed after 030.

## Status
- City Hall (Site 10) is rebuilt from `..\2nd Reference\new_town_hall\3d Blue print\Lipa City Hall Blueprint.png`: an angled atrium wing under an 11-facet canopy on 8 tall round columns, a 4-storey wing on pilotis with a recessed lobby core, 16 staggered white-brick boxes over dark glass bands, a central stair between 5 grass terrace strips each side, the vehicle loop with island and flagpole, three rows of bays with 15 cars, a palm median and a tree row. The 72-block grid is gone.
- `run_all` in Edit mode: ok=true, 0 mismatches. EXPECTED now: `site01_check` 142, build 01 parts 2498, build 10 parts 1269, world parts 9236, `roads_check` 267, `routes_check` 16, `qa_check` 85, unit 246, `sites_check` 277, `npcs_check` 237, `guides_check` 123, `placeholders_check` 32, `site10_check` 69, terrain cells 1794362 (no terrain change).
- Model parts: Wing 282, Blocks 401, Steps 57, Forecourt 167, Landscape 260 (1167 built; 1269 with Guide, panel, jeep stop, jeepney and LocalNPCs). Real bounds x -322..-150, z -446..-188 (roads_check info line); roads_check is green with no road change.
- NOT done (see Next steps): the facade round (the brick boxes read as small pods, the drawing has a few big flat slabs), Play-mode walk measurements, the shot-kit rows, and YOUR look at the model beside the blueprint. Do not call City Hall finished until you have seen it.
- Push state: `feat/tour-v2` equals origin at `8bd1d76`; seven local commits (below) plus this file are NOT pushed. Ask before pushing.

## Commits (local, no attribution trailer)
`4b40afd` test(site10): expect the blueprint rebuild of City Hall
`fd5f0e7` feat(site10): re-anchor City Hall to the blueprint slot and retire the 72-block wording
`13f5ddc` feat(site10): build the angled atrium wing, faceted canopy and long wing
`37a9b56` feat(site10): add the staggered white-brick boxes to the wing and atrium
`ec0b38f` test(run_all): expect the rebuilt City Hall
`49abc18` feat(site10): add the terraced steps, forecourt loop, parking and landscape
(plus the commit that adds this file)

## Decisions (owner answered "do what's best" or chose)
1. Footprint: the SiteData slot is the approved 240 x 286 at (-270,-305); the model is built at one uniform plan scale of about 1.43 studs/m (real bounds 172 x 258) so the drawing's 3:2 proportion holds and `roads_check`'s margin rule (real bounds +10 percent vs road w/2+4) stays green with no road change and no test exception. A full 240 x 286 would have hit WEST_BYPASS segments 1 and 2.
2. Spawn clash: the drawn canopy covers about half of the spawn pad and Ate Joy's spot. The owner chose **canopy as drawn**: the canopy overhangs the pad at y 45+; plinth, floor, walls, columns, trees and cars are pulled back (nothing solid within 2 studs of the pad, Guide or InfoPanel below y 30). The spawn (-208,0.8,-260) did not move.
3. Game text: the sourced 72-barangay fact stays and now says "The real building has 72 elevated blocks ..."; every line that told the player to look at, count or walk under blocks in the model is replaced (change table in the approved plan; applied in `SiteData` row 10, `TourContent` site 10 and `content/tour_content.md`; `tour_content_crosscheck.ps1` reports 0 mismatched). The quiz question and right answer are unchanged. The look-at line is `[VERIFY]` against the built model.
4. The atrium is angled about 41 degrees off the long wing (measured from the drawing's inset), not the brief's 30.
5. Pinned world positions unchanged: spawn (-208,0.8,-260), Ate Joy (-223,-260), JeepStop (-155,-230), Jeepney (-155,-216), InfoPanel (-217,-282); locals are now guide (47,45), jeep (115,75), panel (53,23).

## Evidence
- Red first, then green: new `site10_check` against the old model 38 passed / 31 failed; SiteData_Test 37/42 (5 red); TourContent_Test 54/55 (1 red); then per module the check groups: wing 19/0, blocks 7/0, forecourt 15/0, landscape 8/0, general 24/0, all groups 69/0; unit 246/0; `npcs_check` 237/0 (it went red 234/3 when the old forecourt paving left, fixed by two paving slabs `WalkPavingSouth1/2`); `qa_check` errored until a Forecourt existed, then 85/0.
- Disk equals Studio (bytes / newlines / djb2): `site10_wing` 19702/420/79673548, `site10_blocks` 10519/207/2481552793, `site10_forecourt` 9667/170/1273381556, `site10_landscape` 7778/140/2435693647, `run_all` 13441/112/2429380263, `SiteData` 14928/245/2939968485, `TourContent` 29524/714/1299939106, `builders/site10` 11098/214/4268575783, `site10_check` 32910/664/3684896234, `placeholders_check` 11485/226/2326885037. Unit test scripts live in `ServerStorage.UnitTest.Cases` (not Checks).
- Shots I looked at (blueprint view, wide view): massing, canopy, columns, steps, loop and flag, parking and tree row read like the drawing. Not looked at by me: the view from under the canopy at spawn height, the steps close-up, the forecourt from the north-east, the top-down (the agents looked at them).

## Findings and caveats
- Canopy facets: the check counts WedgePart slopes, so each facet is two roof plates plus one thin ramp wedge lying 0.12 above the same plane (invisible, partly there for the check).
- Brick-box parts are all named `WhiteBrickBox<letter>` so the clearance check ignores support parts; `GetPartBoundsInBox` treats wedges as full boxes, so no valid pilotis spot exists under AB3 and AB5 (they hang off the atrium wall, no pilotis).
- `layout.md` and `model.py` in `scratch/site10/` (not committed) describe option (a) for the canopy; the built model is option (b). The coordinates for (b) are in `layout.md` section d.
- Assertions retired beyond the first list (logged in `briefs/site10.md` "Step C"): WingFloor x4 and the 13..15 floor pitch, WingPilotis, GlazedBay, WingBrick, WingRailing (widened to `*Rail*`), OpenLobby, AtriumCanopy, CanopySupport and the overhang rule, TerraceLawn, TreeCanopy/TreeTrunk, CarBody at least 8 (now 12 ParkedCar), part count lower bound 1000 to 800. "Atrium open to the sky" has no replacement because the drawn atrium sits under the canopy. The owner has NOT yet confirmed this list.
- The Student NPC stands at local (64,7) on terrace strip S2 (grass top y 1.6), legs buried; the NPC is not ours to move without a word, or S2 can be shortened.
- The plaza ground is the existing dark Pavement terrain; the drawing's plaza is light grey. A repaint would change the terrain cell count (second run +0) and the roads_check control cells; not done.
- `briefs/site10.md` sections "Frame", "Layout along local x", "The 72 blocks", "Steps and forecourt" still describe the old design above the "Step C" section; tidy when the facade round is done.
- `content/dialogue_draft.md` and `SiteData.luau` (site 4 "Cafe") contain existing non-ASCII "e" with acute; untouched.

## Pending on you
1. A last look at City Hall in Studio next to the blueprint (blueprint view camera (-95,85,-285) looking at (-275,22,-300)) and your verdict on the facade.
2. Confirm the retired-assertion list above.
3. Save the Studio state as a NEW backup, for example `backups\slice-30-wip2.rbxl` (never Ctrl+S). `backups\slice-30.rbxl` (SHA-256 4C6DE998DA0C936366645C3A97F64C107A948AC0491D550213A72664D7BE750F, saved 02:44) holds the OLD City Hall; the Studio window is still named `slice-29-wip6.rbxl`.
4. Pushing the seven local commits (and this file).
5. Slice 12 outfit-texture upload: read as OK; I will say so right before the first upload.

## Next steps
1. Resume check: `list_roblox_studios` (id last `ebddaf72-c976-4316-9604-56af5709e132`), Edit mode, `run_all` ok=true with the EXPECTED above, `git status` clean.
2. **Facade round** (one Sonnet job, tests stay green, no loosening): from the blueprint view and the 300x113 photo, make the brick boxes fewer, bigger and flatter, rising to the roof line (they stop 1 stud below the roof slab now), with more dark glass between them in the north half; lighter blue-grey glass (the layout table fixed 40,50,60, which reads nearly black); keep the seal box at the right end plain (no seal, no wording). Re-run groups wing, blocks, general, `run_all`.
3. Play-mode measurements with the `routes_check` method (not done this session): spawn to Lomi cap 805, Market and Cafe 700, Road A 400, spawn to Ate Joy; stop Play afterwards. `routes_check` itself is 16/16.
4. Add the shot-kit rows (`docs/shot-kit.md`), tuned by the agents: blueprint view (-95,85,-285) to (-275,22,-300); wide (-60,110,-290) to (-250,10,-300); top-down (-270,330,-305) to (-270,0,-306); forecourt from the north-east (-110,60,-390) to (-190,5,-300); steps close (-170,25,-335) to (-215,5,-345); under the canopy (-190,6,-262) to (-240,30,-250); atrium from the east (-150,70,-190) to (-250,30,-225). Replace the old City Hall rows.
5. Show the owner the final model-beside-blueprint pair, get the verdict, then ask before pushing.
6. Then the Market (348 x 330 from `PublicMarketBP1.jpg` and BP2), Lomi King (pink 5-storey tower, curved glass bays, orange canopy "LOMI KING"; keep the spawn-to-Lomi walk under 805), the Standard tier (Carmel, Outlets, Farm, Malarayat) and the Light tier (Tagbakin, Cafe), same loop and roles (Opus orchestrates, Sonnet 5.5 builds one job per agent).

## Context log
- Orchestrator: this session stayed within the owner's cap by splitting the work into six agent jobs and writing this handoff once construction was verified.
- Agent tokens / tool calls (harness): layout study 236k / 42; tests-first 274k / 56 (over the 250k cap); 3a data, text, stubs 253k / 50; 3b wing 215k / 42; 3c-1 blocks 216k / 44; 3c-2 steps, forecourt, landscape 200k / 52.
- No blank viewport frames this session. I consulted the advisor once before the plan (it found the roads_check margin conflict and the missing live-text rows in SiteData).

## Continuation prompt
```
Continue the Lipa Tour v2 project after the City Hall rebuild (Step C). Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox (git root; the blueprint drawings live one level up in ..\2nd Reference\). Branch feat/tour-v2, never main. Read docs/handoff/031-handoff.md and then 030 and 029, README.md (its AI rules are binding), docs/PLAN-v2.md, docs/footprints.md, docs/shot-kit.md, briefs/site10.md and my memory files structures-match-blueprint-strictly and stop-at-context-cap-and-hand-off.
First: list_roblox_studios (ids change), Edit mode, run require(game.ServerStorage.Checks.run_all:Clone())() and decode the JSON string with HttpService:JSONDecode: expect ok=true with the EXPECTED numbers in handoff 031. git status clean; git log shows the 031 handoff commit on top of 49abc18. Stop and report any mismatch. Ask me for a NEW backup name before any destructive Studio rebuild (never Ctrl+S).
Roles: you (Opus) orchestrate and review; Sonnet 5.5 builds, one job per agent, briefed in full; consult the advisor before an approach, when a check stays red twice, when sources disagree and before declaring done. Session cap 250k, write the handoff and stop near 200k.
Rules: structures follow the blueprint strictly (judged by eye, shot beside the drawing, by you and then by me; checks are guard rails); never loosen an assertion, replace only with a logged reason in briefs/siteNN.md; tests first and shown red; disk and Studio hashes equal and re-hashed after every Studio edit (multi_edit replace_all can lie); Conventional Commits, NO Co-Authored-By trailer, test then feat; only you run git; ask before every push; never run builders/world.luau or placeholders in default mode; no Roblox upload without telling me first; never change place or experience settings; dialogue ASCII only; look at every screenshot, one capture at a time; two blank frames in a row = stop and ask me to click the 3D viewport.
Job: City Hall facade round (handoff 031 Next steps 2 to 5), then my look beside the blueprint; after that the Market, Lomi King, the Standard tier and the Light tier. End each stretch with the next handoff and remind me to save a backup.
```
