# Handoff 028: Slice 3b (City Hall integration) done; Slice 4 (structures wave 1) next
Previous: 027-handoff.md. Plan: `docs/PLAN-v2.md` (public copy); the full plan is kept locally by the owner.

## Status
- Slice 3b is complete as defined. City Hall (site 10, Welcome category) is wired in: `SiteData` row 10, Ate Joy with the tour uniform, info panel, jeep stop and parked jeepney, four forecourt locals, the City Hall spur and two Cathedral bypasses, the spawn pad on the forecourt, ten stamps, a Welcome row on the passport HUD and certificate, a portrait certificate layout, a six-panel credits board, and every site-count string moved from nine to ten.
- `run_all` in Edit mode: ok=true, 0 mismatches (17 stored checks, unit 226, `qa_check` 75, `roads_check` 94, `sites_check` 277, `placeholders_check` 30, world parts 8312, terrain cells 1793696).
- Play-mode acceptance passed (see Evidence). The jeep still teleports; the moving jeepney is Slice 10.

## Environment
- Branch `feat/tour-v2`, nothing pushed. Studio place open, Edit mode, listed as `slice-25.rbxl` (stale name). Studio ids change per session: run `list_roblox_studios` first.
- **Studio holds unsaved Slice 3b work** (all scripts, the built props, roads, repainted ground, the moved spawn, the rebuilt credits board). Backup: **pending your save.** File, Save to File as `backups\slice-28.rbxl` (a new name; do not press Ctrl+S). The next session's first step checks the file exists and records its size and SHA-256 in `docs/baseline.md`.
- Slice 3b started from `backups\slice-27.rbxl` (462,949 bytes, SHA-256 `914694A98CB63A5E9AC61D7CC12CC4E2A71D9FBEA72310DF928F1E2B434A434A`), recorded in `docs/baseline.md`.

## Commits (local, no attribution trailer)
`69a626c` docs(baseline): record the slice-27 place
`749b848` test(city-hall): add ten-site cases for data, passport, certificate and credits
`1fa8c9a` feat(city-hall): add SiteData row 10 and move passport, certificate and credits to ten
`e0ff1a3` test(city-hall): extend site, guide, npc and run_all checks to ten sites
`ee32ea7` feat(city-hall): add Ate Joy, info panel, jeep stop and forecourt locals
`8d755cb` fix(city-hall): use model child names as row 10 requiredProps
`a162a19` test(roads): add roads_check, roads_match and the new spawn assertions
`ae92088` feat(roads): add the City Hall spur, two bypasses and the forecourt spawn pad
`61944b6` test(passport): cover the certificate layout, the six-panel credits board and the ten-site strings
`6c115ff` feat(passport): show ten stamps with a Welcome row and a portrait certificate layout
(plus the handoff commit that adds this file)

## Evidence
Red first, each time, before the change: unit suite `run=214 passed=179 failed=35` (row 10, layout, credits); `placeholders_check` passed 8 / failed 15; `sites_check` 275 / 2; `guides_check` 112 / 4; `npcs_check` 193 / 2; `roads_match.js` failed with "cannot read RoadData.luau" and again with a drifted point; `roads_check` 87 / 7; CertificateLogic `cellRects` 19 / 12; `qa_check` against the three-panel board 51 / 8, then 60 / 15 after the new structural checks.
Green after: unit 226/226; `placeholders_check` 30/0 (and `proveOnly` 38/0, which runs `placeholders({only={10}})` twice and proves the other nine sites and City Hall's Wing, Blocks, Steps, Forecourt, Landscape are identical); `sites_check` 277/0; `guides_check` 123/0; `npcs_check` 237/0; `roads_check` 94/0; `routes_check` 14/0; `qa_check` 75/0; `roads_match.js` PASS with five mutation cases detected; `credits_crosscheck.ps1` "10 sites, 28 urls, 0 mismatched", exit 0 (Windows PowerShell 5.1; `pwsh` is not installed).
Disk = Studio hashes (bytes / newlines / djb2, LF) re-checked by me at the end: credits 7651/181/652866857, qa_check 19367/313/952810214, CertificateLogic 7597/200/2285941773, CertificateLogic_Test 13905/288/2708840958, PassportClient 12091/330/2259794719, WelcomeClient 4147/100/2739655147, run_all 6405/109/485759030. Earlier steps' hashes were checked at each commit.
Terrain: cells 1793270 to 1793696 (+426) from `builders/roads_extra.luau`; a second run gives the same count and voxel hash (idempotent).
Play (Edit stopped afterwards, console empty): the player spawned at (-208.5, 4.3, -261.6) looking -X, 14.6 studs from Ate Joy. `StampRequest(10)` ok, stamps [10]; `StampRequest(11)` invalid_id; `StampRequest(1)` from City Hall too_far; rapid repeat rate_limited; beside the Cathedral guide `StampRequest(1)` ok, stamps [1,10]; HUD read "Passport 2/10". Jeep City Hall to Farm landed at (670, 220), Farm back to City Hall at (-155, -230) (instant for now). Routes (PathfindingService): spawn to Ate Joy 9.0 studs, spawn to Cathedral guide 443.4 (cap 510).
Screenshots looked at: spawn view toward Ate Joy (sunburst pad in front, Ate Joy with the GUIDE tag in front of the steps, the info panel text fully visible with no clipping, the walk-under block field and wing behind); top-down view over City Hall and the Cathedral (the new roads read as faint grey lines at that distance; I confirmed Asphalt under the spur, the west and east bypasses and Road A by raycast). The agent that rebuilt the credits board captured panels 3 to 6 but did not read them line by line. The passport HUD, the certificate and the credits panels were **not** looked at on a device or at reading distance (see Pending).

## Findings and fixes
- placeholders only-mode (`placeholders({ only = { 10 } })`) is the safe way to rebuild City Hall's props. It never touches `Workspace.Sites` as a whole. It rebuilds Ate Joy undressed, so re-run `builders/guides.luau` afterwards. The default mode (no argument) still destroys `Workspace.Sites`: do not run it.
- Row 10 `requiredProps` are the model child names (`Blocks`, `Landscape`, `Wing`, `Forecourt`, `JeepStop`) because BuildCheck matches direct child names; the PDF display words stay in `TourContent`.
- The check "JeepStop 15-25 studs from Guide" is split: a row with `jeepLocal` (City Hall) must be 40 to 90 studs from the guide (it is 74.3 by design); the other rows keep 15 to 25.
- East bypass is at x 165, not 155: the Cathedral's real bounds plus 10 percent reach x 153.6, so 155 and 160 failed the margin rule.
- The City Hall ground repaint runs x -228..-148, z -332..-188 (slightly wider than the slot on the north and south sides) because `ReplaceMaterial` needs the 4-stud grid.
- `qa_check` keeps a CreditsBoard lane check anchored to the old constants (|x| < 8, z 0..70), renamed "the plaza lane to the Cathedral (the old spawn lane)"; the board did not move.
- Edit-mode `require` caches module versions. After pushing a changed ModuleScript, replace it in Studio with `Clone()` + `Destroy()` if a test still sees old data.
- `world.luau placeSpawn` and `tests/world_check.luau` hold the new spawn on disk only. If `world.luau` is ever run (it must not be), run `roads_extra.luau`, `spawn.luau`, then the City Hall builders again.

## Decisions and deviations
1. Row 10 offsets (`guideLocal` (27,0), `jeepLocal` (95,30), `panelLocal` (33,-22)) and `SiteData.localToWorld`; the other nine rows keep the old formulas (a test pins them).
2. Welcome colour (230,190,80) lives only in `SiteData.categoryColor`; the three old colour tables are gone.
3. Credits: the blueprint line reads "Site blueprints: AI-assisted concept drawings prepared by the group; used for massing only." and the photo line "City Hall reference photos: Google Street View." (your choices, 2026-10-26). The 25 PDF sources are in `CreditsData.tourSources`; the board is now six panels (sources as `[n] text (domain)` at a fixed 16 px over panels 5 and 6, because full urls would need three panels).
4. WelcomeClient step 4 now reads "Photo sources are on the credits board at the south end of the Cathedral plaza. Ride the jeepney to the Cathedral, then walk south." Please read the exact wording; it is mine, not yours.
5. The spawn pad is 12 x 12 at local lx 36..48 (the reserved zone in handoff 027 was 20 x 20, lx 30..50, which left Ate Joy only 3 studs from the pad edge). The smaller pad keeps a 9 stud gap, and the Guide-to-pad check is back at 6 studs.
6. I updated `EXPECTED` (unit 226, world parts 8312, `qa_check` 75, new checks) in `tests/run_all.luau` with a reason on every number. README lists `EXPECTED` and `docs/baseline.md` as owner-only; I made these edits as your orchestrator in this session. Please look at the diff.
7. Ate Joy's three dialogue lines in `SiteData` are provisional until Slice 11; guide names for the other nine are unchanged (PDF names arrive in Slice 11).

## Known issues
- The certificate and HUD text is small on phones: the fixed size is 13 px on 401x778 and 11 px on 360x640 (a conservative estimate; nothing breaks mid-word). A measured size in the client would allow larger text.
- The panel-size math for the certificate (86 percent by 90 percent of the viewport, capped at 580 x 500) is in the client and is not unit tested.
- Spawn to Lomi is 697.2 studs against a 700 cap in `routes_check` (unchanged cap, only 2.8 studs of room).
- The parked City Hall jeepney (local 95,44) sits just outside the reserved curb zone; `roads_check` proves it clears the new roads.
- The credits-board end posts overlap Site01 palm fronds above the cap, and the plinth overlaps the Cathedral `ForecourtPaving` (as the old board did); no solid collisions.
- Flat tops (block caps, stair treads) still read blue-grey from above (from 027).
- `tools/guide_shirt.py` still does not exist (from the Slice 24 gap).

## Pending on you
1. Save `backups\slice-28.rbxl` (see Environment).
2. Look at the Studio viewport for: the credits panels 4 to 6 at reading distance, the passport HUD with the Welcome row, and the certificate (portrait and landscape). Or paste screenshots.
3. Read the WelcomeClient step 4 wording and the `run_all` `EXPECTED` diff (decision 4 and 6).
4. OK or not to upload the outfit textures to your Roblox account (Slice 12).
5. Tell groupmates `SiteData`, `sites_check`, `qa_check`, `CreditsData` and `PassportClient` changed heavily in Slice 3b.

## Next steps (Slice 4: structures wave 1: Cathedral and plaza, Market, Lomi King)
1. Resume check: `list_roblox_studios`, Edit mode, `run_all` ok (17 checks, unit 226, parts 8312, cells 1793696); check `backups\slice-28.rbxl` and record its size and SHA-256 in `docs/baseline.md`.
2. Slice 4 per the plan: one Haiku agent per site (`effort: max`), a ranked diff list of 12 items or fewer in `briefs/siteNN.md`, red checks per item, idempotent builder edits, before and after shots from `docs/shot-kit.md`, a reviewer agent comparing shots with the blueprint, you sign off. The Cathedral compound blocks Road A and Road E; its real bounds plus 10 percent must stay clear of both bypasses (`roads_check` enforces x -128..128 plus slack; if a rebuilt Cathedral grows past that, move the bypasses first).

## Context log
Orchestrator peak not measured; no continuation was needed. Agent token usage as reported by the harness (it can include repeated context reads): Explore map 178k, Sonnet step 1 207k, Sonnet 2a 207k, Sonnet 2b 202k, Sonnet step 3 226k. No Haiku agents were used in this slice. All Sonnet agents finished without `CONTEXT_LOW`; the 2a agent did not write its journal. The owner asked about a figure of about 6.6 million tokens; the harness reports each agent above at about 200k, so that figure was not reproduced from these reports.

## Continuation prompt
```
Continue the Lipa Tour v2 project at Slice 4 (structures wave 1: Cathedral and plaza, Market, Lomi King). Working dir: the repo root `roblox/`. Read the full local plan kept by the owner (the pasted-content plan file under the owner's .claude plans folder), then docs/PLAN-v2.md and docs/handoff/028-handoff.md.
First: list_roblox_studios (ids change), Edit mode, run require(game.ServerStorage.Checks.run_all:Clone())() and expect ok=true (17 checks, unit 226, parts 8312, cells 1793696). Confirm backups\slice-28.rbxl exists (ask me to save it if not) and record its size and SHA-256 in docs/baseline.md. Stop and report any mismatch.
Roles: you orchestrate; Sonnet 5.5 implements; Haiku 5.5 at effort max builds, one site per agent (the Haiku cap is 100k; brief them for fewer, bigger Studio calls and few image reads). Context caps: 250k Opus/Sonnet; write a continuation at about 200k.
Rules: branch feat/tour-v2, never main; Conventional Commits with NO Co-Authored-By; nothing pushed without my say; tests first and shown red; Studio vs disk hash equal (node tools/hash.js); look at every screenshot; ASCII dialogue; never run builders/world.luau; never run builders/placeholders.luau in default mode (it destroys Workspace.Sites; use placeholders({only={N}}) then builders/guides.luau); no upload to Roblox without my OK. Roads: the Cathedral bypasses sit at x -170 and x 165 and roads_check keeps them clear of every model's real bounds plus 10 percent. Slice 4 ends with the three structures rebuilt from the blueprints (one ranked diff list per site, red checks, before and after shots, a reviewer pass), run_all green. Then write handoff 029, give the continuation prompt, remind me to save the backup, and stop.
```
