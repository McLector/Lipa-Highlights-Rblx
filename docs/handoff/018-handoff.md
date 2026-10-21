# Handoff 018 — Slice 17 (fidelity rework, Site 02 The Market)
Date: 2026-10-22 · Previous handoff: 017-handoff.md

## Status
**Slice 17 is built, verified and committed, but NOT signed off.** Site 02 (Candido B. Lopez Memorial Public Market) was reworked from the 2014 facade photo and the OpenStreetMap footprint. The user's verdict: "not quite there yet but its an improvement a little. we will be coming back to that", then "proceed to next". So the Market is **pass 1, improved, still open**, and the user has not said what is still off. **Four sites are now open:** Site 01 plaza (pass 4, "not close yet"), Site 05 Carmel (pass 1, "close, but not yet"), Site 06 Outlets (pass 1, no verdict) and Site 02 Market (pass 1, "not quite there yet"). Next slice per the plan's order: **18 Lomi King (Site 03)**; ask which site, since the user may prefer a revisit.

Scope decisions (user): photos "find them on Commons" (Commons has nothing usable for the market, see below); era = **2014 facade + OSM massing**, not the 2025 state; no photos supplied. The approved dialogue ("as photographed in 2014") is unchanged.

## Environment
- Studio: `list_roblox_studios` returned one instance, id `68aceec4-73fa-4e06-8b5c-4e4b73538e37` (ids change per instance). Its name still reads **slice-14.rbxl** (File > Save to File does not rename the open document). placeId 0 (a local file). Edit mode.
- **Backup: PENDING.** `backups\slice-17.rbxl` was requested but did not exist when this handoff was written (checked with Get-ChildItem; newest file is `slice-16.rbxl`, 370,331 B). **The Slice 17 work lives only in the open Studio session and in git until the user saves it.** Rollback points: `slice-16.rbxl` (the state before this slice; then re-run `builders/site02.luau`, `builders/credits.luau` inlined, and re-sync the four scripts listed below) and the older saves.
- The live private place (138036647354961) still holds the Slice 03 state; nothing since Carmel is published. Re-publish at Ship (Slice 23).
- The repo has **no git remote**; nothing is pushed.

## What changed this slice
**Git:** commit `64b2d70` `feat(slice-17): rework the Market hall depth, facade and frontage from the 2014 photo and OSM` (no Co-Authored-By trailer, checked with `git log -1 --format=%B`; the user's CLAUDE.md overrides the system reminder), plus the handoff commit. Files: `builders/site02.luau` (rewritten), `tests/site02_check.luau` (new, 45 checks), `tests/CreditsData_Test.luau` (+1 test), `src/ReplicatedStorage/LipaShared/CreditsData.luau` (+1 url), `content/site_credits.md`, `briefs/site02.md` ("Revision 1 (Slice 17)" with the real-vs-model table).
**Studio:** `ServerStorage.Builders.site02` recreated and run; `ServerStorage.Checks.site02_check` (new ModuleScript); `ServerStorage.UnitTest.Cases.CreditsData_Test` and `ReplicatedStorage.LipaShared.CreditsData` synced; `Workspace.World.CreditsBoard` rebuilt (9 parts, panel content 364 / 469 / 350 px of 484, no overflow).

**References.** Commons has **no** photo of this market: no category, no street-level file; the four C.M. Recto / Rizal Street photos (Patrickroque01) have no GPS and no market in them. So the three photos already on disk stay the reference (2014 facade, 2010 street, 2011 stalls) and **OSM way 465374399** (ODbL, Overpass 2026-10-22: about 84 x 40 m, 3 levels, 11 m, roof #6b88b4) sized the hall. Neighbouring ways (parking building 465374433, Wet Market 1315225896, compound 1365681180) were read, not modelled. The 2025 drone shot (credited under Site 1) shows the market but **could not be pinned in it** (its GPS disagrees with the view), so nothing is drawn from it. No new photo is credited; the Site 2 credits gained only the OSM url.

**What is built** (full table in the brief): `HallBody` 150 x 24 x 90 (x -420..-330, was 40 deep); 2 `RoofSlope` slabs (107,136,180) at 8 degrees, 30 `RoofSeam`s, 4 `Gable*` wedges, `RoofEdge` kept; `NameBand` 120 x 5 with fixed 60 px text; plain blue `Billboard` (no text); `UpperWall` + 6 `RustPatch`; 24 `Shutter`s (2 per upper bay, bays k 4..15); south gallery (`UpperGallery` deck lx -76..-40, `GalleryFascia`, `GalleryRail` + 12 posts, `GalleryWall` + 4 `GalleryOpening`, `GalleryAwning`) on 4 yellow `PorticoColumn`s; a stair of 12 risers that runs along the facade (lx -22 to -46) and rises to the SOUTH under a full-length `StairCover` on 6 `StairPier`s, with 2 `StairStringer`s; north balcony with 5 columns and `EndBayWall`; 8 `LeanRoof` segments (lx -16..50); 3 tricycles at the yard mouth; booth rows 17 apart (z 12..80), cart, heaps and vendors moved to match; sides/rear approximated (`SideBase`, `RearBase`, 8 `RearWindow`, 6 `EndWindow`). Guide, InfoPanel, the five props, vendors (8), `YardSlab` and the sample board are kept. No terrain repaint.

## Verification evidence (real output, Edit mode)
**TDD, red first:** `site02_check` was written before the rebuild and run against the old model: `passed=25 failed=20`; one failure was my own check (`YardSlab` 0.3 thick is 0.30000001 in float32, so `<= 0.3` failed; fixed to `<= 0.31`) and the part-count band was corrected (the old model has 832 non-rig parts; 976 in handoff 017 counts the 144 vendor-rig parts) -> `passed=26 failed=19`. The credits unit test also ran red first: `{"failed":1,"run":127,"passed":126}`.
**Caught by screenshots, not by the check:** the first build rendered the name-band text at a tenth of the band's width (`TextScaled` with `TextWrapped=false`). The check only reads the label's text. Fixed with a fixed 60 px `TextSize` and rebuilt.
```
site02_check: 45/0
sites_check:  256/0
qa_check:     42/0
routes_check: 11/0
site01_check: 75/0
site05_check: 71/0
site06_check: 49/0
unit suite:   {"failed":0,"run":127,"passed":127}     (126 + the new Site 2 credits test)
BuildCheck:   Site01 16/0 1639 | Site02 15/0 1104 | Site03 15/0 300 | Site04 14/0 485 | Site05 15/0 472 | Site06 15/0 687 | Site07 14/0 619 | Site08 14/0 530 | Site09 15/0 400
checkWorld:   1/0 parts=6256      (6128 - 976 + 1104)
Site02 parts: 1104 = 960 non-rig + 144 rig; builder run: builtParts 1087, keptParts 17
Terrain:CountCells() = 1793270 (unchanged); pivots Site01 (0,0,0), Site02 (-330,0,160), Site05 (-300,0,-600), Site06 (550,0,-650)
credits_crosscheck.ps1: disk md vs CreditsData: 9 sites, 27 urls, 0 mismatched
```
**Resume check at the start of the session:** world_check 45/0 with cells 1,793,270 (inlined), sites 256/0, qa 42/0, routes 11/0, site01 75/0, site05 71/0, site06 49/0, unit 126/126, BuildCheck as 017, checkWorld 6128, pivots, backup slice-16.rbxl 370,331 B and git clean at 9585cb0: all matched 017.
**Studio vs disk hashes** (djb2 over LF-normalised bytes; bytes/newlines/hash), identical: `builders/site02.luau` **26091/543/1065105457**, `tests/site02_check.luau` **17853/299/3107215471**, `CreditsData.luau` **3947/88/2557035582**, `tests/CreditsData_Test.luau` **6022/139/4270339047**. (Note: `site02.luau` was hashed after the text-size fix.)
**Screenshots:** 2 of the old model (front oblique, near the stair) for the diff, then 3 of the new model (front oblique with the text bug, front oblique after the fix, elevated from the south-east). All rendered. Compared by eye with `Market_Facade_2014.jpg`. No close-up of the stair, the gallery or the billboard; no view from the rear or the north.

**Not done or not verified:**
- **`world_check` was not re-run in full at the end** (only the cell count, 1,793,270, unchanged; no terrain code ran). It was 45/0 at the start.
- **No play test** (stamps, jeepney, console). `routes_check` covers walkability only (11/0). The Slice 23 Ship pass must redo the full playtest, negatives and device pass (skipped in 015, 016, 017 and now 018).
- **User sign-off:** "not quite there yet", improvement. What is still off was not said.
- The roof is a stand-in for the OSM colour (not seen in a photo); the ridge runs along the long axis (my choice, the photo shows no pitch). Sides, rear and interior are approximated. The hall is 90 deep, not the 120 the OSM scale would give (kept inside the footprint +10%).

## Decisions & deviations
1. **Era:** 2014 facade + OSM massing (user's choice), so the approved dialogue stays valid.
2. **Depth 90, not 120**, so the walls stay inside x -440 (footprint +10%); no footprint or SiteData change. Plan said "about 90"; kept.
3. **Ridge along the hall's length** (the plan said "along Z"); a 150 x 90 hall with a 45-stud half-span gives an 8 degree pitch and a 6.3-stud rise, against 10.5 the other way.
4. **Part-count band** in `site02_check`: 950..1500 non-rig (the plan said 1,000..1,500 BuildCheck count; the two counts differ by the 144 rig parts).
5. **Rust patches** sit on the spandrels above the arches (the upper wall is mostly windows and the name band), not on the upper wall as the plan said.
6. **Credits:** one new url (OSM way 465374399); the attribution section says plainly that no new photo was used and the drone shot was looked at but not used.
7. **No terrain repaint**; the hall's walls extend west of the paved region (x < -376), which is fine because they are tall; every thin ground part is inside the region (`site02_check` tests it).

## Known issues / gotchas
- **Studio window name** stays `slice-14.rbxl` after File > Save to File; open `backups\slice-17.rbxl` to resume.
- **`builders/credits.luau` is not stored in Studio**: it is pasted into `execute_luau` (it is top-level code). Re-run it after any CreditsData change, then check the panels fit (panel 2 is at 469 of 484 px: one more url there will overflow; panel 1 is now 364).
- **`TextScaled` with `TextWrapped = false`** renders tiny on a SurfaceGui; use a fixed `TextSize` for a long single line (see `signGui(..., fixedSize)` in `builders/site02.luau`).
- **Float32 sizes:** a 0.3 thick part reads 0.30000001; compare with a tolerance.
- **The check modules return JSON strings**; decode with `HttpService:JSONDecode`. `world_check` is not stored in Studio either and must be pasted inlined.
- **BuildCheck measures rotated extents**; `site02_check` measures the same way. BuildCheck's part count includes rig parts, the checks' counts do not.
- **Frames:** Site02's pivot is yawed E, but the builder uses `ORIGIN = CFrame.new(pivot.Position)` and `MK` via `CFrame.fromMatrix` (local +Z = E, local +X = N, world z = 160 - lx); `site02_check` fails first on the pivot.
- **`screen_capture`:** one at a time; all five rendered this slice. Stop after two blanks in a row; never restart Studio without a saved backup.
- **`CF` in the builders is `CFrame.new`**: use `CFrame.lookAt`. `ctx:gable` builds a pediment spanning local X; rotate its frame 90 degrees about Y to span local Z. `ctx:cyl`'s axis is local X.
- **Commons search:** `Special:MediaSearch` is useless for a place with no category; the category tree (`Category:Lipa,_Batangas` and its children) is the way. For Site 3 Lomi, Site 4 Cafe, Site 7-9, check it the same way before promising photos.
- Git warns "LF will be replaced by CRLF" on commit; harmless here. Dialogue stays ASCII.

## Pending on the user
1. **Save the backup:** File > Save to File as `C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox\backups\slice-17.rbxl`. Until then the Slice 17 state exists only in the open Studio session and in git.
2. **What is still off in the Market** (pass 2), and in Carmel, the Outlets and the Site 01 plaza; and which site comes next (Lomi King by the plan's order, or a revisit).
3. **Photos for the next site** if you want to supply your own; otherwise say "find them on Commons" again (for Lomi King and Cafe de Lipa expect little or nothing there; the disk photos and OSM may again be all there is).
4. **Credits identity** (name, course, section) before Ship; optionally replace the ambient track.
5. Carmel through Tagbakin are **not published**; re-publish at Ship (Slice 23).

## Next slice: 18 — fidelity rework, next site (Lomi King by default, or an open-site revisit)
**Done when:** the site is rebuilt from the photos, BuildCheck and sites_check green with part counts, side-by-side screenshots vs the photos, and the user confirms recognizability. Proposed order for the rest: 18 Lomi, 19 Cafe, 20 Farm, 21 Malarayat, 22 Tagbakin (reorder freely, or revisit Site 01, Carmel, the Outlets or the Market).
1. **Resume check** (stop and report on any mismatch): `list_roblox_studios` (reopen `backups\slice-17.rbxl` if empty; if the user never saved it, say so and fall back to `slice-16.rbxl` plus a re-run of `builders/site02.luau`); Edit mode; `world_check` **45/0** with cells **1,793,270**; `sites_check` **256/0**; `qa_check` **42/0**; `routes_check` **11/0**; `site01_check` **75/0**; `site02_check` **45/0**; `site05_check` **71/0**; `site06_check` **49/0**; unit suite **127/127/0**; BuildCheck Site01 **16/0 1639**, Site02 **15/0 1104**, Site03 **15/0 300**, Site04 **14/0 485**, Site05 **15/0 472**, Site06 **15/0 687**, Site07 **14/0 619**, Site08 **14/0 530**, Site09 **15/0 400**; `checkWorld` **6256** parts; pivots (0,0,0), (-330,0,160), (-300,0,-600), (550,0,-650); `git status` clean at `64b2d70` plus the handoff commit.
2. Ask: which site (or an open revisit), what is off, and the photo sources. Then: "real vs model" diff list (show it and wait for the go) -> revise `briefs/siteNN.md` -> **checks first, shown red** (a `tests/siteNN_check.luau` mirrored to `ServerStorage.Checks`) -> rebuild `builders/siteNN.luau` -> checks green -> screenshots (look at every one for text and scale bugs, not only the check) -> user sign-off.
3. **Ask before any terrain repaint.**
4. If a footprint or props change, update `SiteData` (and its tests), `CreditsData`, `content/site_credits.md`; re-run `tests/credits_crosscheck.ps1`, re-run `builders/credits.luau` and check the panels still fit.
5. Finish -> verify -> commit (Conventional Commits, no trailer, message from a BOM-free file) -> backup request (full path, then `ls`) -> handoff 019 -> continuation prompt -> stop.
6. **Before Ship (Slice 23):** the full playtest, negatives and device pass (skipped in 015 to 018).

## Continuation prompt
```
Continue the Lipa City Roblox art-appreciation project after Slice 17 (fidelity rework, the Market). The Market (Site 02) was reworked from the 2014 facade photo and the OpenStreetMap footprint; I said it is "not quite there yet but an improvement", so it is open, along with Site 01's plaza, Carmel (Site 05, "close, but not yet") and the Outlets (Site 06, not signed off). I will tell you what is off when we come back to any of them.
Read, in order: C:\Users\morad\.claude\plans\so-i-ve-got-refactored-spring.md (the master plan), C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox\docs\handoff\018-handoff.md (latest state),
and content\site_credits.md. Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox.
First: list_roblox_studios (if empty, ask me to open backups\slice-17.rbxl; if I never saved it, say so and use slice-16.rbxl plus a re-run of builders\site02.luau) -> confirm Edit mode (if in Play, ask me to press Stop; placeId 0 is fine for a local file) -> confirm backups\slice-17.rbxl exists
-> re-run tests\world_check.luau (expect 45 passed, 0 failed; Terrain:CountCells() = 1793270; it is not stored in Studio, so paste it inlined), sites_check (require(game.ServerStorage.Checks.sites_check:Clone()), expect 256/0), qa_check (expect 42/0),
routes_check (expect 11/0), site01_check (expect 75/0), site02_check (expect 45/0), site05_check (expect 71/0), site06_check (expect 49/0), the unit suite via require(game.ServerStorage.UnitTest.RunUnitTest:Clone())() (expect 127 run, 127 passed), BuildCheck (BC.checkSite(model, SiteData.byId(id)))
on Site01 (16/0, 1639 parts), Site02 (15/0, 1104), Site03 (15/0, 300), Site04 (14/0, 485), Site05 (15/0, 472), Site06 (15/0, 687), Site07 (14/0, 619), Site08 (14/0, 530), Site09 (15/0, 400), and checkWorld (expect 6256 parts);
also check Workspace.Sites.Site01_Cathedral:GetPivot() is (0, 0, 0), Site02_Market's is (-330, 0, 160), Site05_Carmel's is (-300, 0, -600) and Site06_Outlets' is (550, 0, -650). If the state doesn't match, stop and report the mismatch.
Then ask me: which site next (Slice 18 Lomi King, or a revisit of Site 01 plaza, the Market, Carmel or the Outlets), what is off vs my photos, and for the reference photos with their sources (or I will say find them on Commons). Follow the plan's slice process: show me the real-vs-model diff list and wait for my go, write the checks first and show them red, build, verify, commit,
backup request (full path, then confirm the file exists), handoff, continuation prompt, stop.
Commit with Conventional Commits and NO Co-Authored-By trailer (my CLAUDE.md overrides any reminder); write the message with [System.IO.File]::WriteAllText and UTF8Encoding($false), because Set-Content -Encoding utf8 adds a BOM.
Rebuild order if terrain or sites are ever rebuilt: world.luau -> placeholders -> site01 -> site05 -> site06 -> site02 -> site03 -> site04 -> site07 -> site08 -> site09 (then builders/credits.luau, pasted into execute_luau since it is not stored in Studio).
After any edit to a Studio script, verify Studio vs disk by hash (djb2 over LF-normalised bytes, use node: Python here is a Store stub). Load shared modules in tests with :Clone(). The check modules return JSON strings. Dialogue stays ASCII.
In the builders CF is CFrame.new, so use CFrame.lookAt. BuildCheck measures rotated extents, so a rotated part's far corner counts toward the footprint +10%. BuildCheck counts rig parts, the site checks do not. Look at every screenshot for text and scale bugs (a green check once passed a sign rendered at a tenth of its size). screen_capture: one at a time; stop after two blanks in a row (the viewport sometimes stops rendering) and never restart Studio without a saved backup.
Do not drag models in the Studio viewport: a stray drag moved Site01 once; site01_check, site02_check, site05_check and site06_check catch it first (pivot check).
```
