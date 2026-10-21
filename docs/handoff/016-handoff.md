# Handoff 016 — Slice 15 (fidelity rework, Site 05 Carmel)
Date: 2026-10-22 · Previous handoff: 015-handoff.md

## Status
**Slice 15 is NOT signed off.** Site 05 (Monastery of Our Lady of Mount Carmel) was rebuilt from 11 new Wikimedia Commons photos plus the OSM church footprint. Everything is green and committed, and the backup is saved, but when asked whether it reads as the Carmel church the user answered **"Close, but not yet"** and did not say what is off. So Carmel is an open item, like Site 01's plaza. **Two sites are now open:** Site 01 plaza (pass 4, "not close yet") and Site 05 Carmel (pass 1, "close, but not yet"). What the user wants next (an open site, or the next rework site, Slice 16 Outlets) is not decided: ask, and ask what is off.

Rework decisions (user): **full rebuild**; the Marian billboard was left to me, and I built it as a plain panel. I chose the Carmel photos myself ("find them on Commons").

## Environment
- Studio: `list_roblox_studios` returned one instance, id `68aceec4-73fa-4e06-8b5c-4e4b73538e37` (ids change per instance). Its name still reads **slice-14.rbxl** even after the save: the user used File > Save to File, which writes a copy and does not rename the open document. **Reopen from `backups\slice-15.rbxl` next time.** placeId 0 (a local file). Edit mode.
- **Backup: CONFIRMED.** `backups\slice-15.rbxl`, 361,006 B, written 2026-10-22 02:09 (gitignored). Older saves: `slice-14.rbxl` (353,228 B, the state before this slice, the rollback point), `slice-14-pass3.rbxl`, `slice-14-pass2.rbxl`.
- The live private place (138036647354961) still holds the Slice 03 state; nothing since Carmel is published. Re-publish at Ship (Slice 23).

## What changed this slice
**Git:** commit `d217983` `feat(slice-15): rebuild Carmel from Commons photos` (no Co-Authored-By trailer, checked with `git log -1 --format=%B`; the user's CLAUDE.md overrides the system reminder), plus the handoff commit. Files: `builders/site05.luau` (rewritten), `tests/site05_check.luau` (new, 71 checks), `tests/sites_check.luau` (orientation guard), `tests/CreditsData_Test.luau` (+1 test), `src/ReplicatedStorage/LipaShared/CreditsData.luau` (+1 url), `content/site_credits.md`, `briefs/site05.md` ("Revision 1 (Slice 15)").
**Studio:** `ServerStorage.Builders.site05`, `ServerStorage.Checks.site05_check` (new ModuleScript), `ServerStorage.Checks.sites_check`, `ServerStorage.UnitTest.Cases.CreditsData_Test` and `ReplicatedStorage.LipaShared.CreditsData` synced to disk; the builder was run (Site05 rebuilt in place) and `Workspace.World.CreditsBoard` rebuilt from the new CreditsData.

**Photos** (Commons, 2000 px, in `Lipa_structure_Exterior_References/09_Mount_Carmel_Monastery/rework_2026/`, not in the repo, never textured): 11 files: Carl Flores Trinidad 2013 (CC BY-SA 3.0), Roel Balingit 2018 (CC BY-SA 4.0), nine by Ramon FVelasquez 2013-06-17 (CC BY-SA 3.0). OSM: church way 157078294, Carmelite Monastery way 384123043 (ODbL). Full table in `content/site_credits.md`. The 2018 frontal gave all the facade measurements (68 studs = 1130 px).

**What is built** (details in the brief): facade 68 studs wide in three steps (tops at y 31 / 39 / 42, pediment apex 47, ringed cross 52) with crenellated white bands, twin-arched shoulder windows, 3 slits per shoulder; stepped entablature; portico floor raised to **6** (was 2) with one wide terracotta stair of 6 risers; flank walls and 8 cone topiaries; nave 46 wide with dark green roof; low east annex (x 34..50); cream 8-rib dome over the nave rear at (0, -50) on a round drum; long west monastery wing (x -102..-34, 24 high) with a covered walkway, 5 teal umbrellas, 24 louvred window panes and an L-return; topiary court with a raised lawn and white statue; plain Marian billboard on a lava-stone base at (40, 56). Shrine, Pews, Kneeler, Candles, HistoryPanels, Guide, InfoPanel, JeepStop unchanged. Roofs are dark forest green (30,92,56).

## Verification evidence (real output, Edit mode, after everything, before the handoff)
**TDD, red first:** `site05_check` was written before the builder and run against the old model: `passed=26 failed=45` (missing FacadeMid/Centre, stair risers, flank walls, crenels, annex, dome drum, MonasteryReturn, court, billboard, teal roofs...). The unit test for an OSM credit on site 5 also ran red first: `{"failed":1,"run":125,"passed":124}`.
```
site05_check: 71/0
sites_check:  256/0     (255 + 1: the orientation guard now has 3 checks for Site05)
qa_check:     42/0
routes_check: 11/0
site01_check: 75/0
unit suite:   {"failed":0,"run":125,"passed":125}     (124 + the new CreditsData test)
BuildCheck:   Site01 16/0 1639 | Site02 15/0 976 | Site03 15/0 300 | Site04 14/0 485 | Site05 15/0 472 | Site06 15/0 512 | Site07 14/0 619 | Site08 14/0 530 | Site09 15/0 400
checkWorld:   1/0 parts=5953      (5872 - 391 + 472)
Terrain:CountCells() = 1793270 (unchanged); Site01 pivot (0,0,0); Site05 pivot (-300,0,-600)
credits_crosscheck.ps1: disk md vs CreditsData: 9 sites, 24 urls, 0 mismatched
builder run: {"builtParts":446,"keptParts":26,"parts":472,"archPaths":{"csg":4,"fallback":0}}
credits panels: content 346 / 426 / 357 px of 484 available (no overflow)
```
**Resume check at the start of the session:** world_check 45/0 with cells 1,793,270 (run as one inlined copy of the file, as in 015), sites 255/0, qa 42/0, routes 11/0, site01 75/0, unit 124/124, BuildCheck as 015, checkWorld 5872, Site01 pivot (0,0,0): all matched 015.
**Studio vs disk hashes** (djb2 over LF-normalised bytes; bytes/newlines/hash), identical: `tests/site05_check.luau` **20557/326/2280138000**, `builders/site05.luau` **24604/494/900564888**, `tests/sites_check.luau` **45710/750/402306757**, `CreditsData.luau` **3757/85/3109190795**, `tests/CreditsData_Test.luau` **5179/121/4224707408**.
**Screenshots (3 good, 1 blank):** a frontal view (camera (-300,10,-520) to (-300,22,-600)) and an elevated west-side view (camera (-410,50,-545) to (-310,18,-625)) both rendered after the first capture came back blank (view-cube only) and a `task.wait(3)`. Compared by eye with the 2018 frontal and the Velasquez elevated photo: the three-step silhouette, portico, stair, long wing with walkway, court and dome behind the facade all show. The billboard is small in the oblique and was not inspected up close.

**Not done or not verified:**
- **`world_check` was not re-run at the end** (only at the start, 45/0). No terrain code ran this slice, and the cell count is unchanged at 1,793,270, but the Carmel forecourt paint check was not repeated after the build.
- **No play test** (stamps, jeepney round trip, console). `routes_check` covers walkability only (11/0, including Carmel). The Slice 23 Ship pass must redo the full playtest, negatives and device pass.
- **User sign-off withheld** ("close, but not yet"); no detail on what is off.
- The billboard, the dome position (centre of the nave rear) and the monastery wing's exact length and L-return are my readings of the photos, not measured from them.

## Decisions & deviations
1. **Facade is 68 studs wide, not the brief's old ~50**: measured from the 2018 frontal (the church's frontage is about 27 m at 2.5). Heights from the same photo.
2. **`B` (portico floor) is 6, not 2**: the photo shows about six risers. Forecourt, Guide, JeepStop, InfoPanel and the road mouth are unchanged.
3. **No driveway ring**: the photos show a circular driveway with planter islands, but it would need a terrain repaint, which needs the user's go (`world.luau` re-runs clear all terrain). Not built; the billboard sits inside the existing paved forecourt.
4. **East wing removed, annex kept**: the old big east wing is gone (the prayer garden starts at x 53); only a low annex x 34..50 remains. `sites_check`'s orientation guard was edited accordingly (east `AnnexBlock`, west `MonasteryBlock`); this was a deliberate test change, shown red first by the failing run before the edit.
5. **CreditsData gained one url** (OSM way 157078294 on site 5) plus a test that site 5 credits OSM; the board was rebuilt. The photo rows live only in the markdown attribution table (the cross-check ignores that section, as for the Cathedral).
6. **Monastery wing 68 studs for a ~60 m building**, with the real compound (231 m x 226 m) compressed; human-scale parts kept (doors >= 8, centre door 11, storey 12, risers 1).
7. **Commit message:** `Set-Content -Encoding utf8` in Windows PowerShell 5.1 puts a BOM in front of the subject line; the first commit was amended with a BOM-free message (`[System.IO.File]::WriteAllText` with `UTF8Encoding($false)`). Final `d217983`, first character `f`, no trailer.

## Known issues / gotchas
- **Studio window name** stays `slice-14.rbxl` after File > Save to File; open `backups\slice-15.rbxl` to resume.
- **`builders/credits.luau` is not stored in Studio**: it is pasted into `execute_luau` (it is top-level code, not a module). Re-run it after any CreditsData change, then check the panels fit.
- **`require(sites_check:Clone())`, `qa_check`, `routes_check`, `site01_check` and `site05_check` return JSON strings** (some earlier notes treated them as tables); decode with `HttpService:JSONDecode`.
- **Check anchors in `site05_check`** are BasePart names, with window helpers named `<Name>_Pane` / `_Top` / `_Trim_Pane` and gables `<Name>L` / `R`; the CSG arch result is named exactly `ArchC` / `ArchS`, but the fallback path would name them `ArchC_PierL` etc. (tests use prefixes).
- **Frame:** Site05's pivot is yawed 180 degrees, but the builder uses `ORIGIN = CFrame.new(pivot.Position)`, so local = world - (-300, 0, -600). `site05_check` fails first on the pivot.
- **`screen_capture`:** the first call after a long gap can return only the view-cube; after `task.wait(3)` the next one rendered. Stop after two blanks in a row; never restart Studio without a saved backup.
- **`CF` in the builders is `CFrame.new`**: use `CFrame.lookAt`. `post()` builds a rolled cylinder (Size = height, diameter, diameter).
- **Thin paving** (Size.Y <= 0.2) outside the repainted Pavement region is buried by terrain grass blades; the Carmel court uses a 0.4 thick raised lawn instead.
- Git warns "LF will be replaced by CRLF" on commit; harmless here. Dialogue stays ASCII.

## Pending on the user
1. **What is off in Carmel** (it was "close, but not yet"), and what is off in the Site 01 plaza (carried from 015). Which should come next.
2. **Photos for the next site** if you want to supply your own (Slice 16 Outlets is next in the proposed order); otherwise say "find them on Commons" again.
3. **Credits identity** (name, course, section) before Ship; optionally replace the ambient track.
4. Carmel through Tagbakin are **not published**; re-publish at Ship (Slice 23).

## Next slice: 16 — fidelity rework, next site (or an open-site revisit)
**Done when:** the site is rebuilt from the photos, BuildCheck and sites_check green with part counts, side-by-side screenshots vs the photos, and the user confirms recognizability.
1. **Resume check** (stop and report on any mismatch): `list_roblox_studios` (reopen `backups\slice-15.rbxl` if empty); Edit mode; `world_check` **45/0** with cells **1,793,270**; `sites_check` **256/0**; `qa_check` **42/0**; `routes_check` **11/0**; `site01_check` **75/0**; `site05_check` **71/0**; unit suite **125/125/0**; BuildCheck Site01 **16/0 1639**, Site02 **15/0 976**, Site03 **15/0 300**, Site04 **14/0 485**, Site05 **15/0 472**, Site06 **15/0 512**, Site07 **14/0 619**, Site08 **14/0 530**, Site09 **15/0 400**; `checkWorld` **5953** parts; Site01 pivot (0,0,0), Site05 pivot (-300,0,-600); `git status` clean at `d217983` plus the handoff commit.
2. Ask: which site (or an open revisit), what is off, and the photo sources. Then: "real vs model" diff list (show it and wait for the go) -> revise `briefs/siteNN.md` -> **checks first, shown red** -> rebuild `builders/siteNN.luau` -> checks green -> screenshots (capture, `task.wait(3)`, capture again) -> user sign-off.
3. **Ask before any terrain repaint.**
4. If a footprint or props change, update `SiteData` (and its tests), `CreditsData`, `content/site_credits.md`; re-run `tests/credits_crosscheck.ps1`, re-run `builders/credits.luau` and check the panels still fit.
5. Finish -> verify -> commit (Conventional Commits, no trailer, message from a BOM-free file) -> backup request (full path, then `ls`) -> handoff 017 -> continuation prompt -> stop.
6. **Before Ship (Slice 23):** the full playtest, negatives and device pass (skipped in 015 and 016).

## Continuation prompt
```
Continue the Lipa City Roblox art-appreciation project after Slice 15 (fidelity rework, Carmel). Carmel (Site 05) was rebuilt from Commons photos but I said it is close, not yet right; Site 01's plaza is also still open. I will tell you what is off when we come back to either.
Read, in order: C:\Users\morad\.claude\plans\so-i-ve-got-refactored-spring.md (the master plan), C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox\docs\handoff\016-handoff.md (latest state),
and content\site_credits.md. Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox.
First: list_roblox_studios (if empty, ask me to open backups\slice-15.rbxl) -> confirm Edit mode (if in Play, ask me to press Stop; placeId 0 is fine for a local file) -> confirm backups\slice-15.rbxl exists (361,006 B)
-> re-run tests\world_check.luau (expect 45 passed, 0 failed; Terrain:CountCells() = 1793270), sites_check (require(game.ServerStorage.Checks.sites_check:Clone()), expect 256/0), qa_check (expect 42/0),
routes_check (expect 11/0), site01_check (expect 75/0), site05_check (expect 71/0), the unit suite via require(game.ServerStorage.UnitTest.RunUnitTest:Clone())() (expect 125 run, 125 passed), BuildCheck (BC.checkSite(model, SiteData.byId(id)))
on Site01 (16/0, 1639 parts), Site02 (15/0, 976), Site03 (15/0, 300), Site04 (14/0, 485), Site05 (15/0, 472), Site06 (15/0, 512), Site07 (14/0, 619), Site08 (14/0, 530), Site09 (15/0, 400), and checkWorld (expect 5953 parts);
also check Workspace.Sites.Site01_Cathedral:GetPivot() is (0, 0, 0) and Site05_Carmel's is (-300, 0, -600). If the state doesn't match, stop and report the mismatch.
Then ask me: which site next (Site 01 plaza, Carmel, or Slice 16 Outlets), what is off vs my photos, and for the reference photos with their sources (or I will say find them on Commons). Follow the plan's slice process: show me the real-vs-model diff list and wait for my go, write the checks first and show them red, build, verify, commit,
backup request (full path, then confirm the file exists), handoff, continuation prompt, stop.
Commit with Conventional Commits and NO Co-Authored-By trailer (my CLAUDE.md overrides any reminder); write the message with [System.IO.File]::WriteAllText and UTF8Encoding($false), because Set-Content -Encoding utf8 adds a BOM.
Rebuild order if terrain or sites are ever rebuilt: world.luau -> placeholders -> site01 -> site05 -> site06 -> site02 -> site03 -> site04 -> site07 -> site08 -> site09 (then builders/credits.luau, pasted into execute_luau since it is not stored in Studio).
After any edit to a Studio script, verify Studio vs disk by hash (djb2 over LF-normalised bytes, use node: Python here is a Store stub). Load shared modules in tests with :Clone(). The check modules return JSON strings. Dialogue stays ASCII.
In the builders CF is CFrame.new, so use CFrame.lookAt. screen_capture: one at a time, twice with task.wait(3) between; stop after two blanks in a row (the viewport sometimes stops rendering) and never restart Studio without a saved backup.
Do not drag models in the Studio viewport: a stray drag moved Site01 once; site01_check and site05_check catch it first (pivot check).
```
