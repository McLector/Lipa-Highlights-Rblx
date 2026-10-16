# Handoff 013 — after Slice 12: Content gate
Date: 2026-10-17 · Previous handoff: 012-handoff.md

## Status
**Slice 12 is complete.** The approved guide dialogue is loaded into `SiteData` (38 lines: 4 per site, 6 for Carmel, all ASCII, longest 174 bytes), the in-world placeholder signs are replaced, and every check is green.

The user approved the plan and delegated the open decisions ("take what's in the picture as absolute truths, anything else do what you think is best"). **No image reached the session with that message**, so "the picture" was read as the reference photos and the names visible on them. The Market, Lomi King, Café de Lipa and Outlets sign wording was re-checked against the photos on 2026-10-17 and matches the models.

What changed:
- **Dialogue** for all nine guides, rewritten so each (c)/(d) line describes what is *built on the model* (Cathedral, Outlets, Farm, Malarayat, Tagbakin, plus Café and Lomi (c)). The Carmel lines carry the sourced rulings: the 1951 finding, its reaffirmation by the Holy See, and Arguelles's 2015 declaration being rejected and withdrawn. The unsupported "December 2015 decree" and "disputed papal approval" claims are not used.
- **Eight `[VERIFY] … content gate` labels** (three Carmel history panels, the Outlets plinth and map footer) were rewritten.
- **The Tagbakin map board** no longer says "the city records a glamping development", because the city page doesn't say so.
- **Carmel's `panelText`** now reads "founded on May 31, 1946" (confirmed).
- **Names unchanged** (`SiteData.name`); InfoPanel titles are unchanged.

**Next slice: 13 — Polish/QA.** Read "Next slice" below.

## Environment
- **studio_id:** `e5a12725-5636-4fe8-9a22-bc3e90055153` (re-run `list_roblox_studios`; ids change per instance). The open document is still named `slice-03.rbxl`; placeId reads 0 (a local file opened from `backups/`).
- Studio in **Edit** (a Play smoke test was run and stopped). Team Create off.
- **Backup: PENDING.** The user is asked to run File → Save to File as `C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox\backups\slice-12.rbxl` (not Ctrl+S). It was **not yet confirmed with `ls`** when this handoff was written. Latest confirmed: `slice-11.rbxl` (312,830 B). The Studio state in this handoff exists only in the open document until that save.
- The live private place (138036647354961) still holds the Slice 03 state; nothing since Carmel is published.

## What exists now
**Studio** (changed this slice): `ReplicatedStorage.LipaShared.SiteData`, `ServerStorage.UnitTest.Cases.SiteData_Test`, `ServerStorage.Checks.sites_check`, `ServerStorage.Builders.site05 / site06 / site09`, and six live labels (3 Carmel history panels, 2 Outlets, 1 Tagbakin map board) plus the Site05 InfoPanel. No parts were added or removed; world total still **5,230** parts. Terrain still **1,793,204** cells.

**Disk** (`roblox/`, local git, no remote): `src/ReplicatedStorage/LipaShared/SiteData.luau`, `tests/SiteData_Test.luau`, `tests/sites_check.luau`, `builders/site05.luau`, `builders/site06.luau`, `builders/site09.luau`, `content/dialogue_draft.md` (now the approved text with its source table), `content/site_credits.md` (identity line added).

**Git:** `4e8b663` `feat(slice-12): load approved guide dialogue and clear placeholder labels` (no trailer; verified with `git log -1 --format=%B`). This handoff is committed afterwards as `docs(handoff): add 013 after slice-12`.

## Verification evidence (real output)
Resume check at the start matched handoff 012: `sites_check` `{"failures":[],"passed":254,"failed":0}`; unit `{"failed":0,"run":86,"passed":86}`; BuildCheck Site01..09 16/0 1005, 15/0 976, 15/0 300, 14/0 485, 15/0 391, 15/0 512, 14/0 619, 14/0 530, 15/0 400; `checkWorld` 1/0 5230; cells 1,793,204; Edit mode; placeId 0; git clean at `462ff38`; `world_check` 41 passed (condensed paving blocks) plus the 2 Malarayat checks run separately (0 problems) = 43/0.

Red first (placeholders still in place):
```
unit:        {"failed":7,"run":95,"passed":88}   (SiteData_Test: ASCII, draft markers, line counts, Look prompt, 2014, "not a nun", 1948/1951/2015 order)
sites_check: {"failures":["no in-world text carries draft tags, placeholder wording or glamping | 9 label(s): ..."],"passed":254,"failed":1}
```
Then the unit suite stayed red *after* the implementation (7 failed) because `SiteData_Test` required the cached module. Fixed by loading SiteData with `:Clone()` in the test (a known gotcha, see below).

Green, re-run on the final state:
```
unit suite:          {"failed":0,"run":95,"passed":95}
sites_check:         {"failures":[],"passed":255,"failed":0}
BuildCheck Site01..09: 16/0 1005, 15/0 976, 15/0 300, 14/0 485, 15/0 391, 15/0 512, 14/0 619, 14/0 530, 15/0 400 (unchanged)
checkWorld:          passed 1, failed 0, parts 5230
world_check:         41 passed 0 failed (condensed paving blocks) cells=1793204 edit=true
                     (the 2 Malarayat checks were NOT re-run after the edits: nothing touched terrain; cells identical)
dialogue paging:     DialogueLogic paged every line for all 9 sites (4/4 ... Carmel 6/6)
unfiltered text dump: 0 labels with "[", VERIFY, CONTENT GATE, GLAMP or PLACEHOLDER
Play smoke test:     server and client load the new SiteData (lines 4,4,4,4,6,4,4,4,4); GuideDialogue gui present;
                     console shows only Roblox's own UIBlox warnings, no errors from our scripts; stopped, Edit confirmed
```
Drift check (djb2 over UTF-8 bytes, LF-normalised, seed 5381, `bytes/newlines/hash`), Studio `.Source` vs disk, **identical**:
```
SiteData       11200/192/3349595186
SiteData_Test   9879/265/1168679561
sites_check    44865/743/295429954
site05         20790/438/1478954987
site06         26168/554/1715735356
site09         23622/466/167527268
```
(One disk edit to `site06` first dropped a space after a comma; the hash mismatch caught it and it was fixed.) The markdown dialogue was cross-checked against SiteData by script: 38 lines, all present in both, none missing.

Not done: no screenshots this slice (no geometry changed). The new in-world label text was verified by reading the labels back, not by looking at it. The Carmel history panels are 10 × 6 studs with `TextScaled` bodies; their legibility has **not** been seen.

## Decisions & deviations from the plan
1. **User delegated the open decisions**; the picture was not received (see Status). Photo-visible names are kept as written; everything else was decided from sources opened on 2026-10-17 (table in `content/dialogue_draft.md`).
2. **ASCII-only dialogue.** `GuideClient.client.luau:95-97` slices the typing animation by byte, so "é" would be cut mid-glyph for a frame. Dialogue says "Cafe"; `name` and `panelText` keep "Café".
3. **Glamping is left out of every line and sign**, overriding the handoff-012 instruction to keep "the city records a glamping development": the opened city page does not mention it, and the photo notes say the building is not verified as glamping.
4. **Carmel:** b2/b3 use sourced wording only. The December 2015 decree and "disputed approval" were dropped because no opened page supports them.
5. **The Outlets keeps "at"** in the name (details document) although the press release writes "@LIMA Estate".
6. **Plaza Independencia** is kept (user's reference files); the "events and socializing" sentence is general because the city page no longer carries that description.
7. **Plan additions beyond the original Slice 12 steps:** the in-world label cleanup (found by an unfiltered text dump, not just a tag search), the Tagbakin glamping removal, and the `sites_check` text guard (254 → 255).
8. **The commit carries no Co-Authored-By trailer** (the user's CLAUDE.md overrides the system reminder).

## Known issues / gotchas discovered
- **The unit tests can read a stale `SiteData`.** `require(module)` caches per instance within a Studio session, and editing `.Source` does not clear it. `SiteData_Test` now uses `:Clone()`. Other test files (`JeepRules_Test`, `BuildCheck_Test`, …) still `require` plain modules; they pass, but if one starts reading edited shared data, give it the same `:Clone()`.
- **`multi_edit` on disk files with trailing spaces:** an `old_string` whose end was a space edited the disk copy without that space. Hash-check every pair.
- **Typewriter byte slicing** (above): keep any new dialogue ASCII.
- **`world_check` is not stored in Studio** (paste it; the paving blocks condense into a `block()` helper). Unchanged: `Terrain:ReadVoxels` arrays are `[x][y][z]`; `screen_capture` can stick blank (stop after two blanks, never restart Studio without a saved backup); thin parts don't hide terrain grass; `BuildCheck.checkSite(model, SiteData.byId(id))`; tab indentation and LF on disk; git warns LF→CRLF (harmless); `Taal_Volcano` and the boundary walls are `CanQuery = false`.
- Web sources: the Inquirer, BusinessWorld and Esquire pages returned 403; the PSA/lipa.gov.ph `city/` page now shows a news item. Listed in `content/dialogue_draft.md`.

## Pending on the user
1. **Save the backup:** File → Save to File as the full path above, then tell me so it can be confirmed with `ls`.
2. **The picture:** if an image was meant to come with "take what's in the picture as absolute truths", re-send it; it could change names or hold the credits identity.
3. **Credits board identity:** your name, course and section (for the Slice 13 CreditsBoard). Recorded as PENDING in `content/site_credits.md`.
4. **Grading rubric**, if there is one (it would steer the guides' emphasis; the dialogue is loaded, so a change now is a small edit).
5. Optional: Lomi King side/rear photos and a current Public Market photo.
6. Carmel through Tagbakin are still **not published**; a re-publish is needed at Slice 14.

## Next slice: 13 — Polish/QA (exact first steps)
**Done when (master plan):** audio, welcome screen, certificate, device-sim pass, scene analysis and the full playtest from the Verification section. If time is short, cut in this order: TourCamera, certificate, ambient audio, then interior detail.
1. **Resume check** (stop and report on any mismatch): `list_roblox_studios` → Edit mode; `world_check` **43/0** with cells **1,793,204** (paste the file; remember the Malarayat block); `sites_check` **255/0**; unit suite **95/95/0**; BuildCheck Site01–09 (16/0 1005, 15/0 976, 15/0 300, 14/0 485, 15/0 391, 15/0 512, 14/0 619, 14/0 530, 15/0 400); `checkWorld` **5230**; `git status` clean at the handoff commit; confirm `backups\slice-12.rbxl` exists.
2. **CreditsBoard** at the spawn: lists the sources from `content/site_credits.md` plus the student's name, course and section (**needs item 3 above**; build it with a clearly marked slot if the identity isn't supplied yet).
3. Welcome screen, passport certificate at 9/9, ambient audio (`search_asset` / `insert_asset`), then the device-simulator pass (phone/tablet), `rbx-scene-analysis` (no unanchored or leaked instances) and the **full MCP playtest**: spawn faces the Cathedral; `character_navigation` to the guides (stamp via prompt key); jeepney to 5–9 and back; passport 9/9 then the certificate; `get_console_output` clean; the playtest negatives (a stamp from 200 studs, a fake id, 20 rapid requests, an invalid jeep id).
4. While in Play, look at the in-world signs (`screen_capture`, one at a time, stop after two blanks): the Carmel history panels and the Outlets plinth and footer have never been *seen*; and the dialogue box with a long Carmel line (typewriter, button layout, a phone-sized viewport).
5. Optional polish (each noted as weak in handoffs 005–012): Cathedral, Carmel, Outlets, Market, Lomi King, Café, Farm, Malarayat and Tagbakin roofs and detail; the Tagbakin quay edge.
6. Finish → verify → commit (`feat(slice-13): …`, no trailer, message from a file) → backup request (`slice-13.rbxl`, full path, then `ls`) → handoff 014 → continuation prompt → stop.

## Continuation prompt
```
Continue the Lipa City Roblox art-appreciation project from Slice 13 (Polish/QA).
Read, in order: C:\Users\morad\.claude\plans\so-i-ve-got-refactored-spring.md (the plan),
C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox\docs\handoff\013-handoff.md (latest state),
and content\site_credits.md (credits board data). Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox.
First: list_roblox_studios -> confirm Studio is in Edit mode (if in Play, ask me to press Stop; placeId may read 0 if the
file was opened from backups\, which is fine when everything else matches) -> confirm backups\slice-12.rbxl exists ->
re-run tests\world_check.luau (expect 43 passed, 0 failed; Terrain:CountCells() = 1793204; paste the file, including the
Malarayat block), sites_check (require(game.ServerStorage.Checks.sites_check:Clone()), expect 255 passed, 0 failed), the
unit suite via require(game.ServerStorage.UnitTest.RunUnitTest:Clone())() (expect 95 run, 95 passed, 0 failed), BuildCheck
(BC.checkSite(model, SiteData.byId(id))) on Site01 (expect 16 passed, 0 failed, 1005 parts), Site02 (15/0, 976), Site03
(15/0, 300), Site04 (14/0, 485), Site05 (15/0, 391), Site06 (15/0, 512), Site07 (14/0, 619), Site08 (14/0, 530) and Site09
(15/0, 400), and checkWorld (expect 5230 parts); if the state doesn't match, stop and report the mismatch.
Then execute Slice 13 exactly as the handoff's "Next slice" section says. Ask me first for anything still pending
(credits name/course/section, the grading rubric, the missing picture). Follow the plan's slice process: finish -> verify ->
commit -> backup request (slice-13.rbxl, full path, then confirm the file exists) -> handoff 014 -> continuation prompt -> stop.
Commit with Conventional Commits and NO Co-Authored-By trailer (the user's CLAUDE.md overrides any reminder).
Rebuild order if terrain or sites are ever rebuilt: world.luau -> placeholders -> site01 -> site05 -> site06 -> site02 -> site03 -> site04 -> site07 -> site08 -> site09.
After any multi_edit to a Studio script, verify Studio vs disk by hash (a trailing space in an old_string silently changed a disk edit this slice).
Load shared modules in tests with :Clone() (the require cache hides edited SiteData). Dialogue must stay ASCII (the typewriter slices by byte).
Terrain: Terrain:ReadVoxels arrays are indexed [x][y][z]; thin parts do not hide terrain grass (a 1.2 top still shows
blades), so repaint the terrain under every paved or turf surface (ask me first; world.luau is not stored in Studio and a full
re-run clears all terrain). screen_capture can stick blank: stop after two blanks and never restart Studio without a saved backup.
```
