# Handoff 014 — after Slice 13: Polish/QA
Date: 2026-10-17 · Previous handoff: 013-handoff.md

## Status
**Slice 13 is complete.** The experience now has a credits board, a welcome screen, a 9/9 certificate and ambient audio with a mute button. The device-simulator pass found and fixed three real layout defects, and a full MCP playtest (real stamping to 9/9, jeepney round trips, negatives) passed.

**Direction change (user, 2026-10-17):** the models are "quite far" from the real structures. The user will supply a **new set of reference photos for every structure**. Slices 14-22 are now a proposed one-site-per-slice **fidelity rework** (user can batch sites); **Ship moves from Slice 14 to Slice 23**. The master plan's slice table was updated accordingly (it lives outside the repo).

**Next slice: 14 — fidelity rework, first site.** It cannot start until the user supplies the new photos for that site (see "Pending on the user").

## Environment
- **studio_id:** `e5a12725-5636-4fe8-9a22-bc3e90055153` (re-run `list_roblox_studios`; ids change per instance). The open document is still titled `slice-03.rbxl`; placeId reads 0 (a local file). Studio in **Edit**, device simulation reset to default. Team Create off.
- **Backup: CONFIRMED.** `backups\slice-13.rbxl`, 329,567 B (also `slice-13-wip.rbxl`, same size, an interim save; both are gitignored).
- The live private place (138036647354961) still holds the Slice 03 state. Nothing since Carmel is published; a re-publish is needed at Ship.

## What exists now
**Studio (new or changed this slice):**
- `Workspace.World.CreditsBoard` (9 parts: plinth, 4 posts, cap, 3 panels) at x -28..28, z 94, facing north; text from `CreditsData`.
- `SoundService.AmbientTown` (Sound, `rbxassetid://9112833822`, "Neighborhood 3 (SFX)" by ProSoundEffects, Creator Store, free; 67.7 s; Looped, Volume 0.25, attribute `Ambient=true`).
- `ReplicatedStorage.LipaShared.CertificateLogic`, `CreditsData` (modules).
- `StarterPlayerScripts.WelcomeClient` (new LocalScript); `PassportClient`, `GuideClient`, `JeepneyClient` rewritten.
- `ServerStorage.UnitTest.Cases.CertificateLogic_Test`, `CreditsData_Test`; `ServerStorage.Checks.qa_check`.
- **Removed:** a stray unanchored `Workspace.Part` (plain grey 4x1x2 at (109, 0.5, 73), no children or attributes, referenced nowhere).

**Disk (`roblox/`):** `builders/credits.luau`, `src/ReplicatedStorage/LipaShared/{CertificateLogic,CreditsData}.luau`, `src/StarterPlayer/StarterPlayerScripts/{WelcomeClient,PassportClient,GuideClient,JeepneyClient}.client.luau`, `tests/{CertificateLogic_Test,CreditsData_Test,qa_check}.luau`.

**Git:** `60dc8f2` `feat(slice-13): add credits board, welcome screen, certificate and ambient audio` (no trailer; `git log -1 --format=%B` has no Co-Authored-By). This handoff is committed afterwards as `docs(handoff): add 014 after slice-13`.

## Verification evidence (real output)
Resume check at the start matched handoff 013 exactly: world_check 43/0, cells 1,793,204, Edit mode; sites_check 255/0; unit 95/95/0; BuildCheck Site01..09 16/0 1005, 15/0 976, 15/0 300, 14/0 485, 15/0 391, 15/0 512, 14/0 619, 14/0 530, 15/0 400; checkWorld 1/0 5230; git clean at `7c9597d`; `slice-12.rbxl` present.

**TDD, red first** (new cases run before the modules existed):
```
unit:     {"failed":2,"run":97,"passed":95}     (CertificateLogic / CreditsData "is not a valid member of LipaShared")
qa_check: {"failed":7,"passed":3}               (no board, no audio, no WelcomeClient, PassportClient still deferring to Slice 13)
```
Later red steps, each shown before its fix: GuideClient 3 failing, JeepneyClient 4 failing, PassportClient HUD wrap 2 failing.

**Final state (Edit mode, after everything):**
```
unit suite:   {"failed":0,"run":121,"passed":121}
sites_check:  {"failures":[],"passed":255,"failed":0}
qa_check:     {"failures":[],"passed":42,"failed":0}
BuildCheck:   Site01 16/0 1005 | Site02 15/0 976 | Site03 15/0 300 | Site04 14/0 485 | Site05 15/0 391 | Site06 15/0 512 | Site07 14/0 619 | Site08 14/0 530 | Site09 15/0 400  (unchanged)
checkWorld:   1/0 parts=5238     (5230 + 9 board parts - 1 stray part)
Terrain:      CountCells = 1793204 (unchanged); world_check itself was NOT re-run at the end (nothing touched terrain)
disk md vs CreditsData: 9 sites, 22 urls, 0 mismatched
```
**Studio vs disk (djb2, bytes/newlines/hash), identical for all nine files:**
```
CertificateLogic       2204/69/2927163685     CreditsData            3659/83/2129714055
CertificateLogic_Test  5432/111/2043170511    CreditsData_Test       4522/105/909224069
qa_check               9959/180/17742116      WelcomeClient          4074/100/3248375318
PassportClient         9085/267/1751019146    GuideClient            6916/215/389946618
JeepneyClient          4437/119/1320477140
```
**Device pass** (measured on the client; setters must run before Play): Samsung Galaxy A06 landscape 705x338, iPad 10th gen 1179x819, iPhone 17 Pro portrait 401x778. Final: no element off screen, no button under 44 px, no clipped text; all 38 dialogue lines fit (tallest box 150 px landscape / 202 px portrait); certificate cells 16-20 px.
Defects found, measured, then fixed: dialogue buttons **65x12 px** (now 110x48); jeep menu **420 px in a 338 px viewport** (now a scrollable grid); HUD Certificate button at **x 438 on a 401 px screen** (row now wraps).

**Playtest (phone viewport, real input):** spawn look vector (0,0,-1). Real stamps 1-9 via E (guides 1-4 on foot; 5-9 by jeepney, menu clicked with the mouse); certificate opened automatically at 9/9 with the local date; return ride to the Cathedral stop. Mute toggle verified both ways (volume 0.25 -> 0 -> 0.25). Audio: `IsLoaded` true, `TimeLength` 67.7, `IsPlaying` true after Start.
Negatives (all rejected): stamps from 168-735 studs -> `too_far`, passport stays empty; ids 99, 0, -1, 3.5, "9", nil, table, NaN, inf -> `invalid_id`; burst of 20 same-instant requests -> **1 accepted, 19 rate-limited**; jeep requests with invalid ids, a stop-less site (2), the same stop, 44 studs from any stop, and 57 studs from a stop -> 0.00 studs moved.
Console: only Roblox's own `UIBlox - Warning FoundationProvider not found` lines; nothing from our scripts.
Scene analysis (Play): only unparented instance is Roblox's `PlayerModule.PlayerModuleEventBus` BindableEvent; 1 unanchored non-rig part (the stray Part, since deleted).

**Screenshots seen:** credits board at final text size (all 9 sites, URLs, identity slot readable); Carmel history panels (approved wording); Outlets map board (title, regions, footer) and plinth. The welcome panel was seen on the phone; the final dialogue, jeep-menu and certificate layouts were verified by measurement and hit tests, not by eye.

## Decisions & deviations from the plan
1. **Fidelity rework added** (user decision); Ship is now Slice 23. Photo folder convention is NOT prescribed: the user decides where the new photos go.
2. **Waypoints cut** (the PassportClient header and the master plan both promised them; the jeepney menu covers navigation). Recorded in the PassportClient header.
3. **Three UI fixes beyond the written plan** (GuideClient, JeepneyClient, HUD wrap), each found by measurement on a phone and covered by `qa_check` checks.
4. **Stray `Workspace.Part` deleted** (guarded delete in Edit; baseline part count 5230 -> 5229 before the board).
5. **Credits identity is a marked slot** ("Name / Course / Section: TO BE ADDED"), per the user. Fill `CreditsData.identity` (`pending = false`) before Ship.
6. **Studio-side tests are structural**: they do not pin the URL count or the identity text, because both change before Ship. The 22-URL equality is a disk-side check (script in the session; re-run it after the credits data changes).
7. **Ambient asset choice:** "Neighborhood 3 (SFX)" was the only result tagged as a loop. Its description includes "distant jet fly by"; the user may want a different track.
8. **Commit carries no Co-Authored-By trailer** (CLAUDE.md overrides the system reminder).

## Known issues / gotchas discovered
- **Playtest, device and UI facts:** `StudioDeviceSimulatorService` setters error in Play and orientation can only be set after a device is active (set device -> orientation -> Play). `TextSize` reads 8 for TextScaled labels; judge text by `TextBounds` / `GetTextBoundsAsync`. `AbsolutePosition` is shifted by `GuiService:GetGuiInset()` (0,58 here): real position = abs + inset. `get_console_output` is dominated by repeated UIBlox warnings.
- **`user_mouse_input` with `instance_path` aims ~22 px high on GUIs that respect the inset** (it assumes a 36 px inset; the simulated phone has 58). It clicked the wrong button once. Use explicit x,y for those; GUIs with `IgnoreGuiInset = true` aim correctly. Mouse position is not kept between separate calls.
- **Studio viewport can stop rendering after Play sessions** (first seen in Play session 2; captures showed only UI or the view-cube gizmo). It did not recover until the user fixed Studio. After a restore, **the first capture of a new location can show stale SurfaceGui text** (it showed the pre-Slice-12 "[VERIFY]" wording while the live labels were correct) or nothing. Capture twice, with a `task.wait(3)` between. Never restart Studio without a saved backup.
- **Typewriter:** the dialogue box height is driven by a transparent "ghost" label holding the whole line, so it does not jump. Keep dialogue ASCII (byte slicing).
- `CertificateLogic` requires `PassportLogic` by absolute path (a cloned module has no `script.Parent`). Load shared modules in tests with `:Clone()`.
- Plinth text on the Outlets estate model hugs the left edge of the face (cosmetic; the Outlets is rebuilt in the rework).
- Not testable yet: whether audio is audible on a published server (needs Ship), and real touch hardware.

## Pending on the user
1. **New reference photos for every structure** (start with the first rework site). Tell me where they live and how each is sourced (URL or own photo), so `CreditsData` and `content/site_credits.md` can be updated. The existing convention is a folder per site with `REFERENCE_NOTES.txt` plus a root `SOURCES.csv`; say if you want the same or something else.
2. **Which site first, and whether to batch sites** given the original 1-2 week deadline.
3. **Credits identity** (name, course, section) before Ship.
4. Optional: replace the ambient track if the distant jet bothers you.
5. Carmel through Tagbakin are still **not published**; a re-publish is needed at Ship (Slice 23).

## Next slice: 14 — fidelity rework (first site)
**Done when:** the site is rebuilt from the new photos, BuildCheck and sites_check green with part counts reported, side-by-side screenshots vs the photos, and the user confirms recognizability.
1. **Resume check** (stop and report on any mismatch): `list_roblox_studios`; Edit mode; `world_check` **43/0** with cells **1,793,204** (paste `tests\world_check.luau`; remember the Malarayat block); `sites_check` **255/0**; unit suite **121/121/0**; `qa_check` **42/0** (`require(game.ServerStorage.Checks.qa_check:Clone())`); BuildCheck Site01-09 as above; `checkWorld` **5238** parts; `git status` clean at the handoff commit; `backups\slice-13.rbxl` exists.
2. **Wait for the photos**, then for the chosen site: write a short "real vs model" diff list (massing, proportions, roofline, openings, colours, signage) -> revise `briefs/siteNN.md` -> rebuild `builders/siteNN.luau` -> BuildCheck + sites_check -> screenshots (capture twice, wait between) -> user sign-off.
3. **Ask before any terrain repaint** (`world.luau` re-runs clear all terrain; repaint terrain under every paved or turf surface, since thin parts do not hide grass blades).
4. If the site's footprint or props change, update `SiteData` (and its tests) and `CreditsData` + `content/site_credits.md`; re-run the credits md vs module cross-check.
5. Finish -> verify -> commit (Conventional Commits, no trailer, message from a file) -> backup request (`slice-14.rbxl`, full path, then `ls`) -> handoff 015 -> continuation prompt -> stop.
6. **Before Ship (Slice 23):** re-run the full playtest, the negatives and the device pass, because Slice 13's ran on the old geometry.

## Continuation prompt
```
Continue the Lipa City Roblox art-appreciation project from Slice 14 (fidelity rework, first site).
Read, in order: C:\Users\morad\.claude\plans\so-i-ve-got-refactored-spring.md (the plan; its slice table now has the rework slices 14-22 and Ship as 23),
C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox\docs\handoff\014-handoff.md (latest state),
and content\site_credits.md (credits data). Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox.
First: list_roblox_studios -> confirm Studio is in Edit mode (if in Play, ask me to press Stop; placeId reads 0 for a local file, which is fine when
everything else matches) -> confirm backups\slice-13.rbxl exists -> re-run tests\world_check.luau (expect 43 passed, 0 failed; Terrain:CountCells() = 1793204;
paste the file, including the Malarayat block), sites_check (require(game.ServerStorage.Checks.sites_check:Clone()), expect 255 passed, 0 failed), qa_check
(require(game.ServerStorage.Checks.qa_check:Clone()), expect 42 passed, 0 failed), the unit suite via require(game.ServerStorage.UnitTest.RunUnitTest:Clone())()
(expect 121 run, 121 passed, 0 failed), BuildCheck (BC.checkSite(model, SiteData.byId(id))) on Site01 (16 passed, 0 failed, 1005 parts), Site02 (15/0, 976),
Site03 (15/0, 300), Site04 (14/0, 485), Site05 (15/0, 391), Site06 (15/0, 512), Site07 (14/0, 619), Site08 (14/0, 530), Site09 (15/0, 400), and checkWorld
(expect 5238 parts); if the state doesn't match, stop and report the mismatch.
Then execute Slice 14 exactly as the handoff's "Next slice" section says. Ask me first for the new reference photos (where they are, how each is sourced), which
site to start with, and whether to batch sites. Follow the plan's slice process: finish -> verify -> commit -> backup request (slice-14.rbxl, full path, then
confirm the file exists) -> handoff 015 -> continuation prompt -> stop.
Commit with Conventional Commits and NO Co-Authored-By trailer (the user's CLAUDE.md overrides any reminder).
Rebuild order if terrain or sites are ever rebuilt: world.luau -> placeholders -> site01 -> site05 -> site06 -> site02 -> site03 -> site04 -> site07 -> site08 -> site09 (then builders/credits.luau).
After any edit to a Studio script, verify Studio vs disk by hash (djb2 over LF-normalised bytes). Load shared modules in tests with :Clone() (the require cache
hides edits). Dialogue must stay ASCII (the typewriter slices by byte). Terrain: Terrain:ReadVoxels arrays are indexed [x][y][z]; thin parts do not hide terrain
grass, so repaint the terrain under every paved or turf surface (ask me first; world.luau is not stored in Studio and a full re-run clears all terrain).
screen_capture: capture one at a time, twice with task.wait(3) between (the first capture of a new spot can be stale or blank); stop after two blanks in a row and never
restart Studio without a saved backup. UI checks: set the device simulator before Play (device -> orientation -> Play), measure on the client, real position = AbsolutePosition + GuiService:GetGuiInset();
user_mouse_input with instance_path aims ~22 px high on inset-respecting GUIs, so click by explicit x,y there.
```
