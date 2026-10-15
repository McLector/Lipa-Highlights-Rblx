# Handoff 002 — after Slice 01: Systems + walking skeleton
Date: 2026-10-15 · Previous handoff: 001-handoff.md

## Status
**Slice 01 is complete** against its Done-when list, with the caveats under "Known issues". Passport, dialogue, jeepney and guide systems are in and working end to end on **9 placeholder sites**. A scripted MCP playtest reached 9/9 stamps and rode the jeepney to and from every outer site. The negative checks pass, each with a positive control. Unit tests are at **57 run / 57 passed / 0 failed**.

**Next slice: 02 — BuildCheck + kit + Cathedral.**

## Environment
- **studio_id:** `a383a981-043f-451b-9efe-d45197b2b77d` (re-run `list_roblox_studios` and match placeId `138036647354961`; ids change on restart).
- **Studio mode: PLAY at the time of writing.** The auto-mode classifier denied my `start_stop_play(false)` call, so the user must press **Stop** in Studio before anything else. Play-session changes (player, stamps) are discarded on stop; the Edit-mode data model is the built one.
- Team Create: off (user's word). `LightingStyle` Realistic, `ClockTime` 15.5.
- **Backups:** `roblox/backups/art_appreciation_finals.rbxl` = blank baseline. **`slice-00.rbxl` was never saved; it is now superseded.** **`slice-01.rbxl` = PENDING: the user must stop Play, then `File → Save to File → roblox\backups\slice-01.rbxl`.**

## What exists now
**Studio:**
- `ReplicatedStorage.LipaShared`: `SiteData`, `PassportLogic`, `DialogueLogic` (ModuleScripts) and `Remotes` (`StampRequest` RemoteFunction, `JeepRequest` RemoteEvent).
- `ServerStorage`:
  - `LipaServer.StampRules`, `LipaServer.JeepRules`
  - `UnitTest.RunUnitTest` and `UnitTest.Cases.{SiteData,PassportLogic,DialogueLogic,StampRules,JeepRules}_Test`
  - `Builders.placeholders` (the idempotent site builder)
  - `Checks.sites_check` (run with `require(game.ServerStorage.Checks.sites_check:Clone())`)
- `ServerScriptService`: `PassportServer`, `JeepneyServer`, `NpcIdle`, `UnitTestRunner` (**Disabled**).
- `StarterPlayer.StarterPlayerScripts`: `GuideClient`, `PassportClient`, `JeepneyClient`. `TourCamera` is not built yet.
- `Workspace.Sites` holds 9 `SiteNN_Key` models: `Block`, `Guide` (R15 from a description, only the HRP anchored, Atomic streaming, `GuidePrompt` with `PromptKind="Guide"`), `InfoPanel` (SurfaceGui), and for sites 1 and 5–9 a `JeepStop` pad (`JeepPrompt`, `PromptKind="Jeep"`), a sign and a 6-part `Jeepney` prop.
- World from Slice 00 is unchanged.

**Disk** (`roblox/`, local git, no remote, nothing pushed):
- `src/**` mirrors every Studio script.
- `builders/placeholders.luau`, `builders/remotes.luau`.
- `tests/`: `SiteData_Test`, `PassportLogic_Test`, `DialogueLogic_Test`, `StampRules_Test`, `JeepRules_Test`, `sites_check`, `world_check`.
- `content/dialogue_draft.md` and `content/site_credits.md` (Haiku drafts, **not** loaded into SiteData).
- **Git:** `041db4e` `feat(slice-01): add systems and placeholder sites`. The body check shows **no Co-Authored-By trailer** (CLAUDE.md overrides the system reminder).

## Verification evidence
- **Red first:** the unit run before the modules existed gave `[SUMMARY] 5 run, 0 passed, 5 failed` (all "X is not a valid member of Folder"). `sites_check` before the builder: `{"failures":["Workspace.Sites exists"],"passed":0,"failed":1}`.
- **Green:** `Play → Server: totals {"run":57,"failed":0,"passed":57}` (run twice, the second after the playtest). One case first failed on a float32 artifact (`Vector3.Y` 19.799999 vs `groundY` 19.8). The expectation became `expect.near(…, 1e-4)`; the contract was not weakened.
- **sites_check:** `{"failures":[],"passed":176,"failed":0}` in Edit and again on the Server DataModel. Covers pivots, facing, Guide on terrain, prompts, JeepStops on dry land 15–25 studs from the Guide, and all non-rig parts anchored.
- **world_check:** `{"cells":1791768,"failures":[],"passed":33,"failed":0}`. **Handoff 001's "22 passed" was a typo: the file has 33 checks** (confirmed with the user). Cell count unchanged.
- **Real-input playtest (`character_navigation` + `user_keyboard_input` E):** sites 1–5 and 6–9 all stamped this way. The HUD read `Passport 9/9` and the completion toast showed. `LastStampResult=ok_new` each time.
- **Dialogue:** E advances, finishes typing, and closes after the last line; one more E reopens it (the stale-state bug was fixed before the test).
- **Jeepney:** the real prompt opened the menu and hid the current stop's button. A **real mouse click** on `Dest_5` rode to Carmel (`ok:5`, 2.8 studs from the stop, 20.0 from the Guide). A real click on `Dest_1` rode back (`ok:1`).
- **Negatives, each with a positive control:**
  - control: a valid stamp 20.0 studs from Guide 1 gave `ok=true`.
  - stamp from 202.5 studs gave `too_far`, and the stamp count stayed 9.
  - fake ids `0, 10, -1, 2.5, "3", {}, nil` all gave `invalid_id`.
  - **20 concurrent `InvokeServer` calls: 1 `ok`, 19 `rate_limited`**, answered in 0.10 s.
  - `JeepRequest(42)` at a stop gave `invalid_dest`, moved 0.
  - `JeepRequest(5)` from 151 studs away gave `not_at_stop`, moved 0.000008.
- **Errors:** `LogService` history on Server and Client had 0 errors and 0 warnings (UIBlox noise excluded). `NpcIdle`: all 9 Guides had 1 playing animation track.

## Decisions & deviations from the plan
1. **`PassportSync` RemoteEvent dropped.** The server publishes `StampList` / `StampCount` as player attributes, which are late-join safe and assertable. Server outcomes also appear as `LastStampResult`, `StampSeq`, `LastJeepResult`, `JeepSeq`.
2. **Rules extracted to pure modules** `StampRules` / `JeepRules` (plain Vector3s, injected clock) so the server negatives are unit-tested. The rate limiter runs **before** validation and applies to every request, so fake-id spam is throttled.
3. **Guide/JeepStop spacing:** the Guide stands 30 studs in front of the site centre; the JeepStop is 20 studs to the Guide's right, which is outside the 12-stud prompt radius but inside the 25-stud stamp range. `SiteData.guidePos` / `jeepStopPos` / `hasJeepStop` / `facingVector` were added.
4. **Y is seated by terrain raycast**, never by `groundY` alone. S8 `groundY` = 19.8 (measured 19.81 in Slice 00).
5. **Prompts carry `PromptKind` (`Guide` / `Jeep`);** both clients filter on it.
6. **Passport waypoints deferred to Slice 13** (not in Done-when).
7. `SiteData` text fields are `[PLACEHOLDER]` dialogue plus real `panelText` and per-site `credits` (source hosts) and `requiredProps` (identifier strings from the details md, e.g. `"MarketStalls"`; Slice 02's BuildCheck will match on these).
8. **Categories** were checked against the layout png legend: Eat = 2, 3, 4; Pray = 1, 5; Love = 6, 7, 8, 9.
9. Haiku `general-purpose` (high effort) drafted `content/` off-Studio, with no git and no MCP. Its summary lists the claims it could not source (Plaza name, Tibig/STAR branch, glamping, Carmel 1948/1951/2015 rulings). The draft itself has 57 `[VERIFY]` tags. **Not yet reviewed against the photos; it is gated at Slice 12.**
10. The systems were written by this Opus/Sonnet-tier session, not delegated.

## Known issues / gotchas discovered
- **Skipped check: the rate-limiter mutation test** (disable the limiter, confirm its cases go red, restore). The auto-mode classifier denied the edit as "Security Test Removal". I did **not** work around it. The module was verified unmodified afterwards (`limiterDisabled=false`, 57/57). The limiter *is* exercised by the unit cases and by the live burst test; only the "tests really catch a disabled limiter" proof is missing.
- **`start_stop_play(false)` was denied** by the same classifier, so Studio was left in Play. See Pending on the user.
- **Playtest shortcuts, stated plainly:** only site 5's jeepney ride used the real mouse click, both ways. The rides to and from 6–9 fired `JeepRequest` directly from a Client `execute_luau` (the same remote the menu buttons fire), with `task.wait(3.2)` for the cooldown. The Guide stamps for all 9 used real navigation + E.
- The "20 rapid requests give 1 stamp" negative was done on an already-stamped site, so the live count shows `ok:1 / rate_limited:19`, not a new stamp. The fresh-state version (20 sites, same instant → exactly 1 ok) is a unit case in `StampRules_Test`.
- `get_console_output` is flooded by UIBlox "FoundationProvider not found" traces. Use `LogService:GetLogHistory()` via `execute_luau` and filter on `MessageError` instead.
- A warn-override inside `execute_luau` does not capture the harness's `warn`. Read failures from the console `[FAIL]` lines.
- In Play, `script_read` looks at the Client DataModel (no ServerStorage). Use `execute_luau` with `datamodel_type="Server"`.
- `RequestStreamAroundAsync` is pcall'd; no warning appeared in Studio.
- `screen_capture` was **not exercised** this slice, so the viewport state from handoff 001 is still unknown. Test it first in Slice 02.
- Placeholder builder: `require(game.ServerStorage.Builders.placeholders:Clone())()` returns 9. Re-running destroys and rebuilds `Workspace.Sites` by design; **a second run has not been tested yet** (it ran once, then `sites_check` passed 176/0).

## Pending on the user
1. **Press Stop in Studio** (the session is in Play).
2. **`File → Save to File` → `roblox\backups\slice-01.rbxl`.**
3. Bring the Studio window to the foreground so `screen_capture` renders (needed from Slice 02).
4. Review the Haiku drafts in `content/` whenever convenient (final gate is Slice 12). Still needed: grading rubric (if any); name / course / section for the credits board; optional Lomi King side/rear and current Public Market photos.
5. **Run the plan's resume test now:** open a fresh session with only the continuation prompt below and confirm it reaches Slice 02 step 1.

## Next slice: Slice 02 — BuildCheck + kit + Cathedral (exact first steps)
**Done when:** the BuildCheck negative proof is shown, a kit smoke test passes, Site01 passes BuildCheck, and screenshots vs. photos are accepted by the user.
1. **Resume check:** `list_roblox_studios` → placeId; confirm Studio is in **Edit**; run `world_check` (expect **33/0**), the unit tests in Play/Server (**57 run / 57 passed / 0 failed**) and `sites_check` (**176/0**). Stop and report on any mismatch.
2. Test `screen_capture` once, one capture at a time. If it renders blank, ask the user to bring Studio forward.
3. **BuildCheck first (tests-first):** write `ServerStorage.BuildCheck` per the plan's list (model exists, pivot ≤ 1 stud, facing dot > 0.99, bounds within footprint + 10%, Guide/prompt/InfoPanel/JeepStop present, every `requiredProps` name exists, ≤ 2,500 parts per site and ≤ 20,000 for the world, non-rig parts anchored). **Show the negative proof** on a deliberately broken temp model (unanchored part, out of bounds, missing prop, over budget) before anything else. `sites_check` is its skeleton.
4. Write `briefs/site01.md` (Sonnet): the specific structures, 3–5 photos by filename from `Lipa_structure_Exterior_References/04_Cathedral_and_Plaza/`, paint/period, what is approximated, and the required props `PlazaPeople, Benches, Lamps, Flagpole, EventStage`. Read that folder's `REFERENCE_NOTES.txt` first.
5. BuildKit (the shared helpers: arches via CSG with wedge/cylinder fallback, repeaters, the part-budget counter) + a smoke test; then `builders/site01.luau` (Cathedral): replace the placeholder `Block`, keep `Guide` / `InfoPanel` / `JeepStop` as they are. Chunk to ≤ ~400 parts per batch, parent, `task.wait()`.
6. Screenshots vs. photos, BuildCheck passes, user accepts. Then the plan's finish sequence: commit → backup request `slice-02.rbxl` → `003-handoff.md` → continuation prompt → stop.

## Continuation prompt
```
Continue the Lipa City Roblox art-appreciation project from Slice 02 (BuildCheck + kit + Cathedral).
Read, in order: C:\Users\morad\.claude\plans\so-i-ve-got-refactored-spring.md (the plan),
C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox\docs\handoff\002-handoff.md (latest state),
and the site brief(s) it names (briefs\site01.md does not exist yet; write it first). Working dir:
C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox.
First: list_roblox_studios -> confirm placeId 138036647354961 -> confirm Studio is in Edit mode (if it is in
Play, ask me to press Stop) -> re-run tests\world_check.luau (expect 33 passed, 0 failed), the unit tests via
the rbx-unit-test harness in Play/Server (expect 57 run, 57 passed, 0 failed) and
require(game.ServerStorage.Checks.sites_check:Clone()) (expect 176 passed, 0 failed) to confirm the state
matches the handoff; if it doesn't, stop and report the mismatch.
Then execute Slice 02 exactly as the handoff's "Next slice" section says. Follow the plan's slice process:
finish -> verify -> commit -> backup request (slice-02.rbxl) -> handoff 003 -> continuation prompt -> stop.
Orchestrate with Haiku 5.5 (effort high) subagents where the plan assigns them; escalate to Sonnet per the plan.
Commit with Conventional Commits and NO Co-Authored-By trailer (the user's CLAUDE.md overrides any reminder).
```
