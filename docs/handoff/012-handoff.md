# Handoff 012 — after Slice 11: Tagbakin, Brgy. Halang
Date: 2026-10-16 · Previous handoff: 011-handoff.md

## Status
**Slice 11 is complete: all nine sites are now built.** The Site09 placeholder is replaced by a built Tagbakin (400 parts: 26 kept + 374 built, rigs included). One **generic lakeshore building** (from `Tagbakin_Shoreline_Building_From_Lake`, `_Oblique` and `_From_Above`; never called glamping): a grey-white two-storey block with two end pavilions under low stepped grey roofs, a recessed centre bay with a double glass door, a roof deck behind a parapet, 12 `ShoreWindow` panes on the lake face and a plainer rear with a door facing the Guide. It stands on a raised terrace behind a six-segment concrete seawall that follows the lake's real arc, with a promenade strip and a 10-wide gap for a **dock** (16 deck parts, 16 posts, rails, benches, a ladder, bollards) that runs 60 studs out over the water toward the volcano. Plus four outrigger **bancas**, two R15 **anglers** with rods and buckets, drying nets and a fish rack, a **location map board** on two posts (schematic, no distances), 12 palms, 6 lamp posts and a kiosk. No interior.

Terrain work this slice, **both passes with the user's OK, live patches only** (see Decisions): Road E now reaches the Guide plaza, the plaza is Pavement, and the ground under the terrace and promenade is Pavement.

Acceptance, stated plainly: the user chose **Accept as first pass**. They were asked twice to confirm by picture and the viewport had gone blank both times (see Known issues), so they accepted on the numeric evidence and on the two captures that did render. Built by **one Haiku 5.5 (effort high) worker** holding the Studio lease; Sonnet 5.5 did the pre-work (brief, both terrain passes, guards) and re-ran every check itself. No escalation was needed.

**Next slice: 12 — Content gate.** Read "Next slice" below.

## Environment
- **studio_id:** `e5a12725-5636-4fe8-9a22-bc3e90055153` (re-run `list_roblox_studios`; ids change per instance). The open document is still named `slice-03.rbxl`.
- **placeId reads 0** (a local file opened from `backups/`); the live place 138036647354961 still holds the Slice 03 state (Carmel through Tagbakin are not published).
- Studio in **Edit**. Team Create off. `LightingStyle` Realistic, `ClockTime` 15.5.
- **Backups (gitignored):** **`backups/slice-11.rbxl`** (312,830 B, saved 2026-10-16 20:50:36, verified with `ls`), plus `slice-10` (297,570 B) … `slice-01`, `slice-02-pre-polish` and the blank baseline. A `.lock` file sits beside the newest. Do not press Ctrl+S; use File → Save to File with a full path.

## What exists now
**Studio**
- Unchanged from handoff 011 except: `ServerStorage.Builders.site09` (new ModuleScript), `ServerStorage.Checks.sites_check` (edited), the terrain (two live patches) and `Workspace.Sites.Site09_Tagbakin`.
- `Site09_Tagbakin` direct children: `Guide`, `InfoPanel`, `JeepStop`, `JeepSignPole`, `JeepSign`, `Jeepney` (kept, untouched), plus `Structure` (Folder: `Terrace`, `Quay` with 6 `SeawallSegment` + 7 `PromenadeStrip`, `ShoreBuilding`, `Dressing`; 202 parts), `Dock` (43), `Bancas` (4 boats, 76), `FishingActivity` (19 children, 49 parts incl. 2 rigs) and `LocationMapPanel` (4 children).
- Anchor parts the guards use (one uniquely named BasePart each): `ShoreBody`, `PavilionL`, `PavilionR`, `ShoreRoofDeck`, `PavilionRoofL`, `PavilionRoofR`, `RearDoor`, `DockEnd`, `BancaMain`, `MapBoard`, `KioskFloor`. Repeated names (guard targets): `ShoreWindow` (12), `SeawallSegment` (6).
- World total **5,230** parts (budget 20,000) = 4,857 − 27 placeholder + 400.
- **Terrain: 1,793,204 cells** (was 1,792,978: +112 from the Road E / plaza patch, +114 from the quay paint, both edge cells at material boundaries).

**Disk** (`roblox/`, local git, no remote, nothing pushed)
- New: `briefs/site09.md`, `builders/site09.luau`.
- Changed: `builders/world.luau` (Road E polyline extended, `PAVED` gains the Guide plaza and 30 quay rectangles), `tests/world_check.luau` (two Tagbakin blocks), `tests/sites_check.luau` (`BUILT[9]`, the Site09 guards).
- **Git:** `a7f3b84` `feat(slice-11): build Tagbakin lakeside site` (no trailer). This handoff is committed afterwards as `docs(handoff): add 012 after slice-11`.
- Rebuild order if terrain or sites are ever rebuilt: `world.luau` → `placeholders` → `site01` → `site05` → `site06` → `site02` → `site03` → `site04` → `site07` → `site08` → `site09`.

## Verification evidence (real output)
Resume check at the start (matched handoff 011): `sites_check` `{"failures":[],"passed":228,"failed":0}`; unit `{"run":86,"passed":86,"failed":0}`; BuildCheck Site01 16/0 1005, Site02 15/0 976, Site03 15/0 300, Site04 14/0 485, Site05 15/0 391, Site06 15/0 512, Site07 14/0 619, Site08 14/0 530; `checkWorld` 1/0 4857; cells 1,792,978; Edit mode; placeId 0; git clean at `5fc5365`; `world_check` `{"failures":[],"passed":41,"failed":0}` (the file's checks pasted with the paving blocks condensed into a `block()` helper, as in handoffs 008–011).

Red first:
```
world_check Tagbakin plaza/road probe on the unpatched terrain: 17 of 18 target cells wrong (all 10 plaza cells Grass, 7 of 8 road cells Grass; the old road end (-480,446), the 11 Grass controls and the 3 lake cells were right).
world_check quay probe (second pass): 14 of 14 quay cells still Grass. It also caught a bug in my own probe: a control cell (-710,594) is lake Water, replaced by the land cell (-702,548).
sites_check with BUILT[9] and the guards on the placeholder: {"passed":234,"failed":20} (the Block/Structure check, 10 orientation and prop guards "part missing", lane (b) and the Guide and JeepStop keep-clear boxes blocked by the placeholder Block, lanes (d) and (e) "no built surface", the window, Guide and volcano sight-lines).
```
Green, re-run by Sonnet on the final state (not copied from the worker):
```
terrain patch 1:     cells 1792978 -> 1793090
terrain patch 2:     cells 1793090 -> 1793204; quay probe 27 checked, 0 wrong
world_check:         {"failures":[],"passed":43,"failed":0} cells=1793204 (41 + 2 Tagbakin blocks)
sites_check:         {"failures":[],"passed":254,"failed":0}
unit suite:          {"run":86,"passed":86,"failed":0}
BuildCheck Site09:   passed 15, failed 0, parts 400
BuildCheck Site01..08: 16/0 1005, 15/0 976, 15/0 300, 14/0 485, 15/0 391, 15/0 512, 14/0 619, 14/0 530 (unchanged)
checkWorld:          passed 1, failed 0, parts 5230
builder idempotency: Sonnet ran site09 twice more: before / run 1 / run 2 all Structure 4/202, Dock 43/43, Bancas 4/76, FishingActivity 19/49, LocationMapPanel 4/4, site 400 parts, 11 children
```
Drift check (djb2 over UTF-8 bytes, LF-normalised, seed 5381, `bytes/newlines/hash`), Studio `.Source` vs disk, **identical**:
```
site09      23622/466/441115804
sites_check 44157/729/2543973347
```
Sonnet's independent checks:
- **Thin-part sweep:** 72 flat parts, 0 thin over Grass, LeafyGrass or Sand (9 sample points per part, material read from the terrain voxels). This sweep passes the terrace at top 1.2, **yet grass blades visibly poked through it**, which is why the quay was repainted (Known issues).
- **Positive controls**, a temporary blocker at each, all caught by the matching guard, state restored to 254/0 with 0 temp parts and 400 parts: lanes (b), (c), (c'), (d), (e) (each also tripped its walkability guard where the surface was affected, and lane (b) also its Guide-side sight-line), keep-clear Guide / InfoPanel / JeepStop (the Guide-box and InfoPanel controls also tripped the neighbouring box, as in Slice 10: the boxes overlap), a wall between the dock-end eye and the building (windows seen 0 of 12), a wall beyond the dock end (volcano view blocked, 3 rays), a 1.8-high step on the dock deck.
- Measured: shore on the facade axis at lz 32.63 (water cells start 0–4 studs beyond the circle), kept children's poses (in `briefs/site09.md`), `Taal_Volcano` is a Ball with `CanQuery = false`.

Screenshots (`screen_capture`, one at a time): two rendered, then the viewport went blank. **`ScreenCapture_1`** from the lake (camera (-728,14,666) → (-654,12,592)): two pavilions with windows, a recessed centre bay and door, a long seawall with the dock gap, a dock with an angler and a bucket, four bancas with blue and red stripes and bamboo outriggers, palms, lamp posts, a distant hazy ridge: reads as the `From_Lake` composition. **`ScreenCapture_2`** high oblique (camera (-742,45,623) → (-655,5,595)): the building as a block with stepped roofs, the curved quay, the dock; **the paving looked speckled with grass** (taken before the second terrain pass). Every later capture (6 attempts, including one after the user saved and one after they brought Studio forward) returned a blank viewport with a stray view cube. **Not taken (blank viewport):** the repainted paving, the Guide-side view, the dock-to-volcano view, the map board close-up, the rear of the building.

## Decisions & deviations from the plan
1. **Frame:** `ORIGIN = (-650, 0, 588)` (on the site axis, 76 studs toward the lake), `CFL = fromMatrix(ORIGIN, (s,0,s), (0,1,0))`: local +X = SE, local +Z = SW (the lake and the facade); world = (-650 + s(lx − lz), ly, 588 + s(lx + lz)). The pivot (-600, 0, 550) is never used as an origin.
2. **User choices this slice:** the photographed facade faces the **lake (SW)**, not the Guide; the seawall and promenade are **parts** on the unchanged terrain shore (no terrain reshaping).
3. **Footprint limits drive the layout:** BuildCheck's bounds (footprint +10%) leave x -732..-468, z 440..660. The quay can run only from lx -60 to lx 56 and the dock tip may reach lz 84; the building is centred in that frontage.
4. **Terrain, two live patches, both OK'd by the user:** (a) Road E extended south to z 532 and west to x -548 (asphalt) and the Guide plaza (x -604..-548, z 508..564) painted Pavement so the 0.4-thick JeepStop pad is visible; (b) 30 stair-stepped 4-aligned rectangles (352 cells, x -724..-600, z 540..652) painted Pavement under the terrace and promenade. Only Grass is converted; the lake, shore and water are unchanged. **A full `world.luau` re-run was NOT done**, so the file reproducing the live terrain exactly is **unproven** (Slice 10's re-run reproduced 1,792,978; this slice's expected full-run count is 1,793,204).
5. **Terrace and promenade tops are 1.2** (risers of 1.2, accepted); seawall lip 2.4, dock deck 1.2 and the wall's dock gap is 10 wide, so a lane never crosses the lip.
6. **Guards (new this slice):** orientation (building SW of the Guide, windows on the SW face, pavilion L NW of R so a mirror fails, roof deck, rear door NE, dock tip over Water, every seawall segment straddles the water edge, banca on water, map board near the Guide with text, kiosk SE, two anglers and 3+ bancas), five lanes (rear approach, both flanks, promenade, dock), a **walkability guard** (surface sampled every 2 studs, no step over 1.3, promenade and dock must be built surface, so a missing plank reads red), three keep-clear boxes, and sight-lines (dock-end eye to the windows, Guide-side eye to the pavilions and the rear door, dock-end eye to the volcano). `sites_check` went 228 → **254**.
7. **Two guard design corrections, found by thinking before running:** (a) the Guide-side sight-line first targeted the roof caps, which a low eye can never see (the rear wall and tier-1 edge hide them), so it now targets the pavilion bodies and the rear door; (b) `Taal_Volcano` is `CanQuery = false`, so the view guard asserts that no built part blocks rays aimed at it instead of requiring a hit on it.
8. **Worker deviations (accepted):** (a) 400 parts, below the 700–1,300 aim (under the 2,500 maximum); (b) dock rails start at lz 27 and post pairs sit at lz 28, 36, …, 76 plus 82, because the promenade lane box (lz 22..26) touched the first ones; (c) palm (54, 8) moved to (60, 6) and palm (18, -34) to (14, -34) (kiosk footprint and the Guide's sight-line); (d) drying net centre (46, -4) → (47, -4), fish rack (50, 8) → (56, -14) (lane (c) and the kiosk); (e) 16 deck parts, not 15; (f) no separate shoe parts (the rig feet serve); (g) dock benches read 2 long and 1 deep, their facing to the SW is not exact; (h) pavilion roof tiers 1 and 2 are named `PavilionTier1L/2L/1R/2R` (tier 3 = `PavilionRoofL/R` as briefed). The worker's first two guard failures (a rail and post blocking lane (d); a palm trunk blocking the Guide's view of pavilion R) were fixed in the build, not by weakening a guard.
9. **Acceptance is first-pass only.** Weak points for a later polish pass: the roofs are stepped tiers, not pitched sheets; 400 parts is sparse (no shore road, cars or houses, no interior, plain grey render); the terrace-to-lawn edge is a 1.2 riser; the stair-stepped paint leaves small grey jags just outside the slab edges; the lake colour is the global bright blue, not the photos' dark teal; anglers are stock R15 rigs; the map board's face, text and orientation are verified numerically only (its Back normal points at the walking lane) and never seen.
10. The commit carries no Co-Authored-By trailer (the user's CLAUDE.md overrides the system reminder).

## Known issues / gotchas discovered
- **`screen_capture` can stick on a blank viewport** (a dark frame with a view cube or a "Back" face gizmo). Here it rendered twice, then stayed blank for 6 attempts, across a user-saved file and a user bringing Studio forward. Do not loop: stop after two blanks. Do **not** restart Studio without a fresh `File → Save to File`, because the open document holds unsaved work between backups.
- **Thin-part rule is not enough at 1.2:** terrain grass blades are taller than the "within 0.8" sweep assumes. A part with a top at 1.2 over Grass still shows blades, so every raised paved slab on Grass needs Pavement painted underneath (as done for the quay), whatever the sweep says.
- **A rotated slab needs stair-stepped paint:** `ReplaceMaterial` takes axis-aligned 4-aligned regions only; generate cells whose centres lie within 1 stud of the slab and merge them per row (the generator ran from the scratchpad; the result is in `world.luau`).
- **`Taal_Volcano`, `Taal_Ridge` and the boundary walls are `CanQuery = false`:** rays and `GetPartBoundsInBox` never see them.
- **Water cells begin 0–4 studs beyond the lake circle** (4-stud voxels); a wall centred 1 stud beyond the circle with 6 studs of thickness straddles the edge for the whole arc. The shore tangent at the facade axis is within 1.2° of the building frame; the circle is 9 studs off a straight line at ±72.
- **Probe controls can land in the wrong material:** a control cell chosen from a generated pool was lake Water. Check each control by a read before relying on it (the red run caught it).
- **The worker's `replace_all` on a Studio script silently failed once more**; the per-edit hash caught it (four unique edits fixed it). Keep hash-checking.
- Unchanged from before: `Terrain:ReadVoxels` arrays are `[x][y][z]`; `world_check` is not stored in Studio (paste it, the old paving blocks condensed into `block()`); a rotated part's `Size` is in local axes; `BuildKit:arch` always tries CSG first; BuildKit materials are not colours; rigs carry their own `Animate` script; `GetPartBoundsInBox` takes `OverlapParams` and exact sizes; `BuildCheck.checkSite(model, SiteData.byId(id))`; tab indentation and LF on disk; PowerShell 5.1 here-strings can't feed `git commit -F -` (use a message file); git warns LF→CRLF (harmless).

## Pending on the user
1. Still open: **review `content/dialogue_draft.md`** (gated at Slice 12); the grading rubric if there is one; name / course / section for the credits board; optional Lomi King side/rear photos and a current Public Market photo.
2. Carmel, the Outlets, the Market, Lomi King, the Café, the Farm, Malarayat and Tagbakin are **not published**; the live private place still has the Slice 03 state. A re-publish is only needed at Slice 14 unless the user wants it earlier.
3. A polish pass on the Cathedral, Carmel, the Outlets, the Market, Lomi King, the Café, the Farm, Malarayat and Tagbakin is wanted later (Decision 9 here and in handoffs 005–011); it is not scheduled.
4. Optionally, when Studio's viewport renders again: retake the oblique (confirm the paving), the Guide-side view and the dock-to-volcano view, and look at the map board. A full `world.luau` re-run (needs the user's OK; it clears all terrain) would prove the file reproduces the live terrain.

## Next slice: 12 — Content gate (exact first steps)
**Done when (master plan):** `dialogue_draft.md` approved by the user, loaded into SiteData, tests at 0 failed. Steps:
1. **Resume check** (stop and report on any mismatch): `list_roblox_studios` → Edit mode (placeId 0 is fine); `world_check` **43 passed, 0 failed** with `Terrain:CountCells()` = **1,793,204** (paste the file text into `execute_luau`); `sites_check` **254/0**; unit suite **86/86/0**; BuildCheck Site01 **16/0, 1005 parts**, Site02 **15/0, 976**, Site03 **15/0, 300**, Site04 **14/0, 485**, Site05 **15/0, 391**, Site06 **15/0, 512**, Site07 **14/0, 619**, Site08 **14/0, 530**, Site09 **15/0, 400**; `checkWorld` **5230 parts**; `git status` clean at the handoff commit.
2. Read `content/dialogue_draft.md` (13 KB, 9 sites, 4 lines each, Carmel 6, every proper name tagged `[VERIFY]`, every spoken line ≤ 220 chars) and `content/site_credits.md`; read `src/ReplicatedStorage/LipaShared/SiteData.luau` and `tests/SiteData_Test.luau` (≥ 3 non-empty lines of ≤ 220 chars, credits and requiredProps non-empty).
3. **Do not edit `SiteData` before the user has reviewed.** Bring the user the draft with the open `[VERIFY]` items, the grading rubric question, and the credits-board identity (name, course, section) in one batch, and wait for their edits and approval. Sourcing: the draft says only the barangay profiles page was opened; the Tagbakin line must keep "the city records a glamping development" and nothing more, the Carmel lines must carry the neutral sourced rulings, the Café interior is labelled representative, the Market's photos date from 2014.
4. After approval: tests first (extend `SiteData_Test` for the approved text if needed), load the lines into `SiteData` (`dialogue`, `panelText`, `credits`), push to Studio with `multi_edit`, **hash-verify**, run the unit suite and `sites_check` and the nine BuildChecks, and confirm the InfoPanel text and the guides' dialogue still pass their checks. Finish → verify → commit (`feat(slice-12): …`, no trailer, message from a file) → backup request (`slice-12.rbxl`, full path, then `ls`) → handoff 013 → continuation prompt → stop.

## Continuation prompt
```
Continue the Lipa City Roblox art-appreciation project from Slice 12 (Content gate).
Read, in order: C:\Users\morad\.claude\plans\so-i-ve-got-refactored-spring.md (the plan),
C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox\docs\handoff\012-handoff.md (latest state),
and the content files it names (content\dialogue_draft.md and content\site_credits.md).
Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox.
First: list_roblox_studios -> confirm Studio is in Edit mode (if in Play, ask me to press Stop; placeId may read 0 if the
file was opened from backups\, which is fine when everything else matches) -> re-run tests\world_check.luau (expect 43 passed,
0 failed; Terrain:CountCells() = 1793204), sites_check (require(game.ServerStorage.Checks.sites_check:Clone()), expect
254 passed, 0 failed), the unit suite via require(game.ServerStorage.UnitTest.RunUnitTest:Clone())() (expect 86 run, 86
passed, 0 failed), BuildCheck (BC.checkSite(model, SiteData.byId(id))) on Site01 (expect 16 passed, 0 failed, 1005 parts),
Site02 (15/0, 976), Site03 (15/0, 300), Site04 (14/0, 485), Site05 (15/0, 391), Site06 (15/0, 512), Site07 (14/0, 619),
Site08 (14/0, 530) and Site09 (15/0, 400), and checkWorld (expect 5230 parts); if the state doesn't match, stop and report
the mismatch.
Then execute Slice 12 exactly as the handoff's "Next slice" section says: do not edit SiteData until I have reviewed
dialogue_draft.md; bring me the draft with the open [VERIFY] items, the rubric question and the credits identity in one batch.
After approval: tests first, load into SiteData, hash-verify Studio vs disk, rerun every check. Follow the plan's slice
process: finish -> verify -> commit -> backup request (slice-12.rbxl, full path, then confirm the file exists) -> handoff 013
-> continuation prompt -> stop.
Commit with Conventional Commits and NO Co-Authored-By trailer (the user's CLAUDE.md overrides any reminder).
Rebuild order if terrain or sites are ever rebuilt: world.luau -> placeholders -> site01 -> site05 -> site06 -> site02 -> site03 -> site04 -> site07 -> site08 -> site09.
After any multi_edit to a Studio script, verify Studio vs disk by hash (replace_all silently failed again this slice).
Terrain: Terrain:ReadVoxels arrays are indexed [x][y][z]; thin parts do not hide terrain grass or sand (a 1.2 top still shows
blades), so repaint the terrain under every paved or turf surface (ask me first; world.luau is not stored in Studio and a full
re-run clears all terrain). screen_capture can stick blank: stop after two blanks and never restart Studio without a saved backup.
```
