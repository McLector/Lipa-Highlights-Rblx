# Handoff 015 — Slice 14 (fidelity rework, Site 01): plaza pass 4
Date: 2026-10-19 (work done 2026-10-17) · Previous handoff: 014-handoff.md

## Status
**Slice 14 is NOT signed off.** Site 01 (Cathedral + Plaza Independencia) has been rebuilt four times from photos; pass 4 (this handoff) rebuilt the **lower plaza** from the user's ground-level photo. All checks are green and the work is committed and saved, but the user looked at it and said **"it's not close yet, but we will come back to that later."** So Site 01's plaza is an open item, not a finished one. What the user wants next (which site, or back to the plaza) is not decided: ask.

Pass 4 build (user decisions): a **fountain and statue** replace the gazebo stage at the centre of the stairs; the pavilion gets a **curved roof**; the **vans and tents are removed**. Also built: terracotta paving, two kiosks with orange stepped roofs at the top of the steps, a round pergola garden, a vaulted covered court with a shade tree, planter walls and flower beds. Details and the photo-vs-model table are in `briefs/site01.md` "Revision 4".

## Environment
- **Studio was not connected at handoff time** (`list_roblox_studios` returned `[]` after the user saved, so Studio had been closed). Re-run `list_roblox_studios`; the open document should be `slice-14.rbxl`, placeId 0 (a local file). The studio_id changes per instance (last seen `d9a6fe7a-2d05-4eed-a777-fcfbd5d6738f`).
- **Backup: CONFIRMED.** `backups\slice-14.rbxl`, 353,228 B, written 2026-10-19 15:35 (the user saved it after pass 4). Older saves, all gitignored: `slice-14-pass3.rbxl` (347,150 B, the state before pass 4, the rollback point) and `slice-14-pass2.rbxl`.
- The live private place (138036647354961) still holds the Slice 03 state; nothing since Carmel is published. Re-publish at Ship (Slice 23).

## What changed this pass
**Disk (`roblox/`), commit `d730265` `feat(slice-14): rebuild Plaza Independencia from the ground photo`** (no Co-Authored-By trailer; the user's CLAUDE.md overrides the system reminder): `builders/site01.luau`, `tests/site01_check.luau`, `briefs/site01.md`.
**Studio:** `ServerStorage.Builders.site01` and `ServerStorage.Checks.site01_check` edited to match disk, then the builder was run (Site01 rebuilt in place).

Pass 4 also **restored Site01's pivot**: during the session the whole `Site01_Cathedral` model had been dragged in Studio to (-57.5, 0.196, 20.3). Moved back to (0, 0, 0), same orientation (yawed to face +Z). `site01_check` now fails first on "site pivot is at the SiteData pos (0, 0, 0), facing +Z".

New / renamed parts (all in `Workspace.Sites.Site01_Cathedral`): `EventStage` now holds `FountainBasin`, `FountainBasinUpper`, 2 `FountainWater` (translucent, non-colliding), `FountainColumn`, `FountainPlinth`, `FountainStatue` (+ head), `StairFlightL/R`, `BleacherL/R` (x -76..-22 and 22..98), 2 `KioskBody` (x +-32, z 44, podium) with `KioskRoof` discs, the side stairs. `PlazaLower`: terracotta `ForecourtPaving`, `PavingInlay`, `PergolaRing` (-52, 80), `PergolaColumn`/`Beam`/`Rafter`, `PlanterWall`, `FlowerBed`. `PlazaBuildings`: `CoveredCourt`, `CourtPost`, `VaultPanel` x9, `ShadeTreeTrunk`/`Canopy`. **Removed:** `StageLanding`, `StagePost`, `StageCanopy`, `StageFascia`, `CivicBuildingS`, `CivicRoof`, `PlazaTent`, `TentPost`, `PlazaSlab`, the 7 lower-plaza vans, 2 west palms.

## Verification evidence (real output, Edit mode, after the pass-4 build and before the save)
**TDD, red first:** the new `site01_check` ran before the builder change: `passed=53 failed=23` (fountain, flights, kiosks, court, pergola, planters, tents and vans all red). Two of the first-draft checks (Guide / InfoPanel keep-clear boxes) were wrong, not the model (the box touched the podium top; the original lamp row at x 14 stands in front of the InfoPanel by design); the Guide box was lifted above the podium and the InfoPanel one dropped (comment in the file).
```
site01_check: passed=75 failed=0
sites_check:  passed=255 failed=0
qa_check:     passed=42  failed=0
routes_check: passed=11  failed=0     (all 11 routes by PathfindingService, no jumping)
world_check:  {"failures":[],"passed":45,"failed":0}   cells=1793270 (unchanged; run as one inlined copy of the file)
unit suite:   {"failed":0,"run":124,"passed":124}
BuildCheck:   Site01 16/0 1639 | Site02 15/0 976 | Site03 15/0 300 | Site04 14/0 485 | Site05 15/0 391 | Site06 15/0 512 | Site07 14/0 619 | Site08 14/0 530 | Site09 15/0 400
checkWorld:   1/0 parts=5872      (5835 + 37)
```
Site01 builder result: 1,639 parts of the 2,500 budget (was 1,602). Studio vs disk (djb2, bytes/newlines/hash), identical: `builders/site01.luau` **51335/907/168447248**, `tests/site01_check.luau` **29128/414/3749314863**. (The unit suite is 124, not 121: it grew in the previous session.)

**Not done or not verified:**
- **No play test this pass.** The Studio viewport stopped rendering (captures showed only the view-cube gizmo, the known problem in 014), so stamps, the jeepney round trip and the console were not re-checked. `routes_check` covers walkability only.
- **Screenshots:** one good aerial of the plaza was seen (fountain, flights, kiosks, ring, court, tree, planters visible). The spawn view and a street-corner view (the photo's vantage) came back blank, so **the plaza was not compared against the photo by eye.** One `screen_capture` call hung and failed with "Request timeout".
- **`world_check` was run as an inlined copy** (same checks, helper-factored), not by pasting the file verbatim; the count matched (45).
- **Studio could not be re-checked after the user's save** (not connected). The numbers above are from just before it.

## Decisions & deviations
1. **User:** fountain + statue at the stair centre; curved pavilion roof; remove vans and tents; "it's not close yet" to the photo, revisit later; **credits: "we credit enough"**, so the plaza photo gets **no** new `CreditsData` / `site_credits.md` entry (it carries a campaign watermark; its source was not named). Nothing from it is copied or textured.
2. **Kiosks at x +-32** (not the planned +-36): at 36 their roofs touched the garden lawn and hedges.
3. **Kept fixed:** RAISE 5, WALL_Z 48, footprint 240 x 200, massScale 2.0, the forecourt, church, Welcome Arch, spawn (0, 70), CreditsBoard strip, open centre x -34..30 z 64..88, the east fence opening toward Road C.
4. **Approximated** (also in the brief): the photo's street-corner steps are not built (the lower plaza stays level with the street so routes and the spawn are untouched); block-figure statue; static water disc; round (not six-sided) kiosks; the vault has no end arches or ribs.
5. **Likely reasons it is "not close"** (my reading, not confirmed by the user): the vault reads as a pale slab rather than the photo's big curved roof; the pergola is a small gazebo, not the photo's long half-ring; the photo's plaza is far more open and larger in scale; the fountain's scale and tiers are rough. **Ask the user what is off** before another pass.
6. **No Co-Authored-By trailer** on any commit this pass.

## Known issues / gotchas
- **Moving a site by accident** shows up as a dozen unrelated failures. If `site01_check` fails on many geometry checks, read the pivot check first.
- **`screen_capture`**: the viewport stopped rendering again, as in 014 (blank or view-cube only, even after `task.wait(3)`). One call also hung; the harness moved it to the background and it later failed with a timeout. Stop after two blanks, and never restart Studio without a saved backup.
- **`CF` in the builders is `CFrame.new`**, so `CF.lookAt` fails: use `CFrame.lookAt`.
- **`post()` in `site01.luau` builds a rolled cylinder**: Size is (height, diameter, diameter) with the axis along X, so tests read height from `Size.X` and diameter from `Size.Y`, and the generic `topY` helper (which uses `Size.Y`) is wrong for them.
- **`multi_edit` to Studio** replays an edit list onto the Studio script; it needs the exact old text. Hash-check after each sync (djb2 over LF-normalised bytes; the Python on this machine is a Store stub, use `node`).
- Git warns "LF will be replaced by CRLF" on commit; harmless here.
- Carried from 014: UI/device-simulator facts, `user_mouse_input` aim offset, the `:Clone()` rule for shared modules in tests, dialogue is ASCII.

## Pending on the user
1. **Which site next** (Slice 15 is the next rework site) **or** whether to go back to the Site 01 plaza first, and what exactly is off vs the photo.
2. **New reference photos** for the next site (where they live, how each is sourced).
3. **Credits identity** (name, course, section) before Ship; optionally replace the ambient track.
4. Carmel through Tagbakin are **not published**; re-publish at Ship (Slice 23).

## Next slice: 15 — fidelity rework, next site (or Site 01 revisit)
**Done when:** the site is rebuilt from the new photos, BuildCheck and sites_check green with part counts, side-by-side screenshots vs the photos, and the user confirms recognizability.
1. **Resume check** (stop and report on any mismatch): `list_roblox_studios` (Studio may need reopening from `backups\slice-14.rbxl`); Edit mode; `world_check` **45/0** with cells **1,793,270**; `sites_check` **255/0**; `qa_check` **42/0**; `routes_check` **11/0**; `site01_check` **75/0**; unit suite **124/124/0**; BuildCheck Site01 **16/0 1639**, Site02-09 as above; `checkWorld` **5872** parts; Site01 pivot (0, 0, 0); `git status` clean at `d730265` plus the handoff commit.
2. Ask for the photos and the site; then: write a short "real vs model" diff list -> revise `briefs/siteNN.md` -> **write the checks first, show them red** -> rebuild `builders/siteNN.luau` -> checks green -> screenshots (capture twice, wait between) -> user sign-off.
3. **Ask before any terrain repaint** (`world.luau` re-runs clear all terrain; repaint terrain under every paved or turf surface).
4. If a footprint or props change, update `SiteData` (and its tests), `CreditsData` and `content/site_credits.md`, and re-run the credits cross-check.
5. Finish -> verify -> commit (Conventional Commits, no trailer, message from a file) -> backup request (full path, then `ls`) -> handoff 016 -> continuation prompt -> stop.
6. **Before Ship (Slice 23):** re-run the full playtest, the negatives and the device pass, because Slice 13's ran on the old geometry (and this pass skipped the play test).

## Continuation prompt
```
Continue the Lipa City Roblox art-appreciation project after Slice 14 (fidelity rework). Site 01's plaza was rebuilt from my ground photo (pass 4) but I said it is not close yet; I will tell you what is off when we come back to it.
Read, in order: C:\Users\morad\.claude\plans\so-i-ve-got-refactored-spring.md (the master plan), C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox\docs\handoff\015-handoff.md (latest state),
and content\site_credits.md. Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox.
First: list_roblox_studios (if empty, ask me to open backups\slice-14.rbxl) -> confirm Edit mode (if in Play, ask me to press Stop; placeId 0 is fine for a local file) -> confirm backups\slice-14.rbxl exists (353,228 B)
-> re-run tests\world_check.luau (expect 45 passed, 0 failed; Terrain:CountCells() = 1793270), sites_check (require(game.ServerStorage.Checks.sites_check:Clone()), expect 255/0), qa_check (expect 42/0),
routes_check (expect 11/0), site01_check (expect 75/0), the unit suite via require(game.ServerStorage.UnitTest.RunUnitTest:Clone())() (expect 124 run, 124 passed), BuildCheck (BC.checkSite(model, SiteData.byId(id)))
on Site01 (16/0, 1639 parts), Site02 (15/0, 976), Site03 (15/0, 300), Site04 (14/0, 485), Site05 (15/0, 391), Site06 (15/0, 512), Site07 (14/0, 619), Site08 (14/0, 530), Site09 (15/0, 400), and checkWorld (expect 5872 parts);
also check Workspace.Sites.Site01_Cathedral:GetPivot() is (0, 0, 0). If the state doesn't match, stop and report the mismatch.
Then ask me: which site next (or the Site 01 plaza first), what is off vs my photo, and for the reference photos with their sources. Follow the plan's slice process: write the checks first and show them red, build, verify, commit,
backup request (full path, then confirm the file exists), handoff, continuation prompt, stop.
Commit with Conventional Commits and NO Co-Authored-By trailer (my CLAUDE.md overrides any reminder).
Rebuild order if terrain or sites are ever rebuilt: world.luau -> placeholders -> site01 -> site05 -> site06 -> site02 -> site03 -> site04 -> site07 -> site08 -> site09 (then builders/credits.luau).
After any edit to a Studio script, verify Studio vs disk by hash (djb2 over LF-normalised bytes, use node: Python here is a Store stub). Load shared modules in tests with :Clone(). Dialogue stays ASCII.
In the builders CF is CFrame.new, so use CFrame.lookAt. screen_capture: one at a time, twice with task.wait(3) between; stop after two blanks in a row (the viewport stops rendering after a while) and never restart Studio without a saved backup.
Do not drag models in the Studio viewport: a stray drag moved Site01 once; site01_check now catches it first.
```
