# Handoff 017 — Slice 16 (fidelity rework, Site 06 The Outlets)
Date: 2026-10-22 · Previous handoff: 016-handoff.md

## Status
**Slice 16 is built, verified and committed, but NOT signed off.** Site 06 (The Outlets at LIMA Estate + Aboitiz Pitch) was reworked from Wikimedia Commons photos and the LIMA Estate 2025 drone shot. The user was asked whether it reads as the real place and had not answered when the backup was saved, so recognizability is **unconfirmed**. **Three sites are now open:** Site 01 plaza (pass 4, "not close yet"), Site 05 Carmel (pass 1, "close, but not yet"), Site 06 Outlets (pass 1, no verdict yet). What the user wants next is not decided: ask, and ask what is off in each.

Scope decisions (user): photos from Commons ("find them on Commons"); for the facades, "go with your recommendations". That meant: Commons for the junction, road, landscaping, signage and entrance; the drone shot for roofs and layout; the existing architizer set for the shop facades, pitch and stand; one extra block rather than a full cluster re-layout.

## Environment
- Studio: `list_roblox_studios` returned one instance, id `68aceec4-73fa-4e06-8b5c-4e4b73538e37` (ids change per instance). Its name still reads **slice-14.rbxl**: File > Save to File writes a copy and does not rename the open document. **Reopen from `backups\slice-16.rbxl` next time.** placeId 0 (a local file). Edit mode.
- **Backup: CONFIRMED.** `backups\slice-16.rbxl`, 370,331 B, written 2026-10-22 03:04:50 (gitignored). A `slice-16.rbxl.lock` file sits beside it because Studio has the file open. Older saves: `slice-15.rbxl` (361,006 B, the state before this slice, the rollback point), `slice-14.rbxl` and the earlier ones.
- The live private place (138036647354961) still holds the Slice 03 state; nothing since Carmel is published. Re-publish at Ship (Slice 23).
- The repo has **no git remote**; nothing is pushed.

## What changed this slice
**Git:** commit `4b837ce` `feat(slice-16): rebuild the Outlets approach and roofs from Commons photos` (no Co-Authored-By trailer, checked with `git log -1 --format=%B`; the user's CLAUDE.md overrides the system reminder), plus the handoff commit. Files: `builders/site06.luau`, `tests/site06_check.luau` (new, 49 checks), `tests/CreditsData_Test.luau` (+1 test), `src/ReplicatedStorage/LipaShared/CreditsData.luau` (+2 urls), `content/site_credits.md`, `briefs/site06.md` ("Revision 1 (Slice 16)").
**Studio:** `ServerStorage.Builders.site06` rebuilt in place and run; `ServerStorage.Checks.site06_check` (new ModuleScript); `ServerStorage.UnitTest.Cases.CreditsData_Test` and `ReplicatedStorage.LipaShared.CreditsData` synced; `Workspace.World.CreditsBoard` rebuilt from the new CreditsData (9 parts, panel content 340 / 469 / 350 px of 484, no overflow).

**Photos** (Commons, 2000 px, in `Lipa_structure_Exterior_References/05_The_Outlets_LIMA/rework_2026/`, not in the repo, never textured): all 26 files of `Category:The_Outlets_at_Lipa` (Judgefloro, CC0, 2019-09-23) plus `LIMA Estate as of 2025.jpg` (Aboitiz Economic Estates, CC BY-SA 4.0). **Only 8 of the 26 were examined** (Junction 21, 24, 27, 30; 9803 #30, 34, 37, 40) and only those 8 plus the drone shot are credited; the other 18 are downloaded and not credited. All the Commons photos are road-side shots (no shop block, no pitch).

**What is built** (details in the brief): the 16-wide concrete `EntryPath` with 34 black and yellow painted kerb segments and 7 zebra stripes at z 91; two 0.4-thick paver sidewalks; 4 lamps with purple "NOW OPEN" banners; 2 orange water barriers; 4 avenue palms; a junction island (x -150..-136) with a lawn, 28 clipped `Topiary` domes in five greens, 3 palms, 2 lava rocks, 7 yellow chain bollards and 6 chain links; a billboard (24 x 10, bottom 17 above the ground, text only) at x -152; a 26-high tenant pylon at (-94, 98) with 7 panels (generic names plus ABOITIZ PITCH) and a red chevron on a dark backing; a white entrance office with a red door and canopy at (-87, 86); `ShopSolar` (6), `WingFascia`, a second two-storey block `SecondBlock` (shop frame x 56..92, z 46..60) with 8 solar panels and a maroon fascia, a courtyard (link slab, 2 planters, 4 shrubs); a long `PitchBlock` along the pitch's west fence with 6 solar panels and 3 doors; brighter pitch turf. The car park slab moved 9 studs south (z 62..106) and is light concrete. The old flat `Hedge` boxes and the old 11-stud pylon are gone. Guide, InfoPanel, JeepStop, Jeepney, entrance sign, estate pedestal, Lipa/Malvar panel, stand and walkway are unchanged.

## Verification evidence (real output, Edit mode, after everything)
**TDD, red first:** `site06_check` was written before the rebuild and run against the old model: `passed=18 failed=31`. The credits unit test also ran red first: `{"failed":1,"run":126,"passed":125}`. The bounds check was then tightened to measure rotated extents (as BuildCheck does) and run red on the two chevron parts before the fix.
**Caught by BuildCheck, not by my first check:** after the first build Site06 was `14/1` ("bounds within footprint +10%: z -749.2..-537.7, limit -540"): the rotated red chevron reached z 112.3. The check only tested part centres. The check was fixed first (red on PylonChevron and PylonChevronDark), then the chevron moved to z 101 (far corner 108.8).
```
site06_check: 49/0
sites_check:  256/0
qa_check:     42/0
routes_check: 11/0
site01_check: 75/0
site05_check: 71/0
unit suite:   {"failed":0,"run":126,"passed":126}     (125 + the new CreditsData test)
BuildCheck:   Site01 16/0 1639 | Site02 15/0 976 | Site03 15/0 300 | Site04 14/0 485 | Site05 15/0 472 | Site06 15/0 687 | Site07 14/0 619 | Site08 14/0 530 | Site09 15/0 400
checkWorld:   1/0 parts=6128      (5953 - 512 + 687)
Terrain:CountCells() = 1793270 (unchanged); Site01 pivot (0,0,0); Site05 (-300,0,-600); Site06 (550,0,-650)
credits_crosscheck.ps1: disk md vs CreditsData: 9 sites, 26 urls, 0 mismatched
builder run (final): parts 687 (661 built, 26 kept)
```
**Resume check at the start of the session:** world_check 45/0 with cells 1,793,270 (run as one inlined copy of the file), sites 256/0, qa 42/0, routes 11/0, site01 75/0, site05 71/0, unit 125/125, BuildCheck as 016, checkWorld 5953, pivots, backup 361,006 B and git clean at b372c16: all matched 016.
**Studio vs disk hashes** (djb2 over LF-normalised bytes; bytes/newlines/hash), identical: `builders/site06.luau` **34440/693/4111690256**, `tests/site06_check.luau` **18034/288/2260711956**, `CreditsData.luau` **3898/87/1772485958**, `tests/CreditsData_Test.luau` **5671/131/3713631682**.
**Screenshots (2, both rendered):** a junction view (camera (440,14,-480) to (440,8,-580)) showing the kerbed road, zebra crossing, topiary island with yellow bollards, billboard, pylon with the red chevron, office and the orange shop frame; and an elevated view (camera (470,90,-470) to (580,5,-680)) showing the solar roofs, second block, pitch with its block and the car park. Compared by eye with the Commons photos and the drone shot. No close-up of the billboard text or the pylon panels.

**Not done or not verified:**
- **`world_check` was not re-run in full at the end** (only at the start, 45/0). No terrain code ran, and the cell count is unchanged at 1,793,270.
- **No play test** (stamps, jeepney round trip, console). `routes_check` covers walkability only (11/0, including the Outlets). The Slice 23 Ship pass must redo the full playtest, negatives and device pass.
- **User sign-off not recorded.**
- The drone shot's compass orientation is my reading (pitch assumed south-east of the cluster, as built); the second block and the pitch-side block are approximations of a cluster the photos only show from above.
- The pylon lists generic names ("SPORTSWEAR OUTLET", "FOOTWEAR OUTLET", "FOOD HALL"...) plus "ABOITIZ PITCH", not the photographed brands.

## Decisions & deviations
1. **Shop facades, pitch and stand were not redone**: the Commons set has no view of them. They keep the architizer references (22 photos) from Slice 05.
2. **South pitch fence dropped** (it was in the diff list): the stand closes that side.
3. **One extra block, not a cluster re-layout**, to stay inside the deadline (user: "go with your recommendations").
4. **Car park moved 9 studs south** (z 62..106, light concrete) to leave room for `SecondBlock`. `SecondBlock` stays 13+ studs from the Guide and clear of the pad and the path (`site06_check` tests the landing box, the Guide box and the pad-to-Guide path).
5. **Part-count floor in `site06_check` is 600** (the old model's 512 must fail it); the plan's first guess of 750 was too high for the final 687.
6. **Credits:** the 2 new urls are the Commons category page and the drone file; the photo rows live only in the markdown attribution table (the cross-check ignores that section, as for the Cathedral and Carmel). `Set-Content -Encoding utf8` was not used; the commit message was written with `[System.IO.File]::WriteAllText` and `UTF8Encoding($false)`.
7. **No terrain repaint**; every ground surface is a part at least 0.4 thick.

## Known issues / gotchas
- **Studio window name** stays `slice-14.rbxl` after File > Save to File; open `backups\slice-16.rbxl` to resume.
- **`builders/credits.luau` is not stored in Studio**: it is pasted into `execute_luau` (it is top-level code). Re-run it after any CreditsData change, then check the panels fit (panel 2 is now 469 of 484 px: one more url there will overflow).
- **The check modules return JSON strings**; decode with `HttpService:JSONDecode`. `world_check` is not stored in Studio either and must be pasted inlined.
- **BuildCheck measures rotated extents**: a 45-degree-rotated part's far corner counts. `site06_check` now measures the same way.
- **Frames:** Site06's pivot is yawed SW, but the builder uses `ORIGIN = CFrame.new(pivot.Position)` (world-aligned, +X east, +Z south) and `SH` via `CFrame.fromMatrix`; `site06_check` fails first on the pivot.
- **`screen_capture`:** one at a time, twice with `task.wait(3)` between; both captures this slice rendered. Stop after two blanks in a row; never restart Studio without a saved backup.
- **`CF` in the builders is `CFrame.new`**: use `CFrame.lookAt`. `post()` builds a rolled cylinder (Size = height, diameter, diameter).
- **Thin paving** (Size.Y <= 0.2) outside the repainted Pavement region is buried by terrain grass blades; zebra stripes and bay lines (0.05) sit on top of a 0.4 slab, which is fine.
- Git warns "LF will be replaced by CRLF" on commit; harmless here. Dialogue stays ASCII.

## Pending on the user
1. **Recognizability of the Outlets** (not answered), what is off in Carmel (carried from 016: "close, but not yet") and in the Site 01 plaza (carried from 015). Which should come next.
2. **Photos for the next site** if you want to supply your own; otherwise say "find them on Commons" again. For the Outlets, Commons has only road-side photos, so better shop-block and pitch references would have to come from you or the architizer set.
3. **Credits identity** (name, course, section) before Ship; optionally replace the ambient track.
4. Carmel through Tagbakin are **not published**; re-publish at Ship (Slice 23).

## Next slice: 17 — fidelity rework, next site (or an open-site revisit)
**Done when:** the site is rebuilt from the photos, BuildCheck and sites_check green with part counts, side-by-side screenshots vs the photos, and the user confirms recognizability. Proposed order for the rest: 17 Market, 18 Lomi, 19 Cafe, 20 Farm, 21 Malarayat, 22 Tagbakin (reorder freely, or revisit Site 01, Carmel or the Outlets).
1. **Resume check** (stop and report on any mismatch): `list_roblox_studios` (reopen `backups\slice-16.rbxl` if empty); Edit mode; `world_check` **45/0** with cells **1,793,270**; `sites_check` **256/0**; `qa_check` **42/0**; `routes_check` **11/0**; `site01_check` **75/0**; `site05_check` **71/0**; `site06_check` **49/0**; unit suite **126/126/0**; BuildCheck Site01 **16/0 1639**, Site02 **15/0 976**, Site03 **15/0 300**, Site04 **14/0 485**, Site05 **15/0 472**, Site06 **15/0 687**, Site07 **14/0 619**, Site08 **14/0 530**, Site09 **15/0 400**; `checkWorld` **6128** parts; pivots (0,0,0), (-300,0,-600), (550,0,-650); `git status` clean at `4b837ce` plus the handoff commit.
2. Ask: which site (or an open revisit), what is off, and the photo sources. Then: "real vs model" diff list (show it and wait for the go) -> revise `briefs/siteNN.md` -> **checks first, shown red** -> rebuild `builders/siteNN.luau` -> checks green -> screenshots (capture, `task.wait(3)`, capture again) -> user sign-off.
3. **Ask before any terrain repaint.**
4. If a footprint or props change, update `SiteData` (and its tests), `CreditsData`, `content/site_credits.md`; re-run `tests/credits_crosscheck.ps1`, re-run `builders/credits.luau` and check the panels still fit.
5. Finish -> verify -> commit (Conventional Commits, no trailer, message from a BOM-free file) -> backup request (full path, then `ls`) -> handoff 018 -> continuation prompt -> stop.
6. **Before Ship (Slice 23):** the full playtest, negatives and device pass (skipped in 015, 016 and 017).

## Continuation prompt
```
Continue the Lipa City Roblox art-appreciation project after Slice 16 (fidelity rework, the Outlets). The Outlets (Site 06) was reworked from Commons photos and the LIMA Estate drone shot, but I have not signed it off; Carmel (Site 05, "close, but not yet") and Site 01's plaza are also still open. I will tell you what is off when we come back to any of them.
Read, in order: C:\Users\morad\.claude\plans\so-i-ve-got-refactored-spring.md (the master plan), C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox\docs\handoff\017-handoff.md (latest state),
and content\site_credits.md. Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox.
First: list_roblox_studios (if empty, ask me to open backups\slice-16.rbxl) -> confirm Edit mode (if in Play, ask me to press Stop; placeId 0 is fine for a local file) -> confirm backups\slice-16.rbxl exists (370,331 B)
-> re-run tests\world_check.luau (expect 45 passed, 0 failed; Terrain:CountCells() = 1793270; it is not stored in Studio, so paste it inlined), sites_check (require(game.ServerStorage.Checks.sites_check:Clone()), expect 256/0), qa_check (expect 42/0),
routes_check (expect 11/0), site01_check (expect 75/0), site05_check (expect 71/0), site06_check (expect 49/0), the unit suite via require(game.ServerStorage.UnitTest.RunUnitTest:Clone())() (expect 126 run, 126 passed), BuildCheck (BC.checkSite(model, SiteData.byId(id)))
on Site01 (16/0, 1639 parts), Site02 (15/0, 976), Site03 (15/0, 300), Site04 (14/0, 485), Site05 (15/0, 472), Site06 (15/0, 687), Site07 (14/0, 619), Site08 (14/0, 530), Site09 (15/0, 400), and checkWorld (expect 6128 parts);
also check Workspace.Sites.Site01_Cathedral:GetPivot() is (0, 0, 0), Site05_Carmel's is (-300, 0, -600) and Site06_Outlets' is (550, 0, -650). If the state doesn't match, stop and report the mismatch.
Then ask me: which site next (Site 01 plaza, Carmel, the Outlets, or Slice 17 Market), what is off vs my photos, and for the reference photos with their sources (or I will say find them on Commons). Follow the plan's slice process: show me the real-vs-model diff list and wait for my go, write the checks first and show them red, build, verify, commit,
backup request (full path, then confirm the file exists), handoff, continuation prompt, stop.
Commit with Conventional Commits and NO Co-Authored-By trailer (my CLAUDE.md overrides any reminder); write the message with [System.IO.File]::WriteAllText and UTF8Encoding($false), because Set-Content -Encoding utf8 adds a BOM.
Rebuild order if terrain or sites are ever rebuilt: world.luau -> placeholders -> site01 -> site05 -> site06 -> site02 -> site03 -> site04 -> site07 -> site08 -> site09 (then builders/credits.luau, pasted into execute_luau since it is not stored in Studio).
After any edit to a Studio script, verify Studio vs disk by hash (djb2 over LF-normalised bytes, use node: Python here is a Store stub). Load shared modules in tests with :Clone(). The check modules return JSON strings. Dialogue stays ASCII.
In the builders CF is CFrame.new, so use CFrame.lookAt. BuildCheck measures rotated extents, so a rotated part's far corner counts toward the footprint +10%. screen_capture: one at a time, twice with task.wait(3) between; stop after two blanks in a row (the viewport sometimes stops rendering) and never restart Studio without a saved backup.
Do not drag models in the Studio viewport: a stray drag moved Site01 once; site01_check, site05_check and site06_check catch it first (pivot check).
```
