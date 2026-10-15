# Handoff 001 — after Slice 00: Foundation
Date: 2026-10-15 · Previous handoff: none (this is the first)

## Status
**Slice 00 is complete.** The world is built by one re-runnable script: grass terrain floor (±1400), 8 asphalt road polylines, a two-part SW lake, the Malarayat slope (wedge + plateau), invisible boundary walls at ±1000, Persistent backdrops (Malarayat range + Taal volcano), spawn at (0, 0.5, 70) facing north, and `ClockTime` 15.5. The Baseplate has been deleted, after the terrain was confirmed by raycast. The write-capable Haiku pilot passed.

**Next slice: 01 — Systems + walking skeleton.**

## Environment
- **studio_id:** `a383a981-043f-451b-9efe-d45197b2b77d` (it changed once after Team Create was toggled; **always re-run `list_roblox_studios` and match on placeId `138036647354961`**).
- Studio mode: Edit. Team Create: off (user's word; not verifiable from Luau). `Lighting.LightingStyle` = Realistic (`Technology` is unreadable and legacy). `ClockTime` = 15.5.
- **Backups:**
  - `roblox/backups/art_appreciation_finals.rbxl` = the pre-build baseline (blank Baseplate).
  - **`roblox/backups/slice-00.rbxl` = PENDING: the user still needs to do `File → Save to File`.** Until then the only copy of the built world is the open Studio session, but `builders/world.luau` rebuilds it from disk.

## What exists now
**Studio** (`Workspace` roots: `Camera, Terrain, SpawnLocation, World`; **0 scripts anywhere**):
- `Terrain`: 1,791,768 cells.
- `SpawnLocation` at (0, 0.5, 70), look vector −Z.
- `World/Boundary`: 4 invisible, collidable, anchored walls (`WallNorth/South/West/East`) with inner faces at ±1000.
- `World/Backdrops`: a Model with `ModelStreamingMode = Persistent` and 6 anchored non-colliding ball parts (`Malarayat_A–D`, `Taal_Volcano`, `Taal_Ridge`).
- No `Sites`, no modules, no remotes, no NPCs yet.

**Disk** (`C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox\`, own git repo; the photos folder is outside it):
- `builders/world.luau`: the idempotent world builder.
- `tests/world_check.luau`: the world verification (an execute_luau script returning `{passed, failed, failures}`).
- `tests/SiteData_Test.luau`: **written first, not yet runnable**, because `SiteData` doesn't exist. Format: `rbx-unit-test` harness case (`return function(t) ... t.test(...)`), expecting `ReplicatedStorage.LipaShared.SiteData` with `.sites`, `.byId(id)`, `.facingToYaw(facing)`, `.jeepStopPos(id)`.
- `.gitignore` (`backups/`, `*.rbxl`, `*.rbxlx`, `*.bak`) and empty `src/`, `briefs/`, `content/`.
- **Git:** `1f334a0` `feat(slice-00): add world builder and terrain checks`. No remote and nothing pushed. Commits have no Co-Authored-By trailer (CLAUDE.md overrides the system reminder).

## Verification evidence
- **Red first:** `world_check` against the empty place: `passed 2, failed 17`.
- **Green with the Baseplate present:** `{"passed":32,"failures":[],"failed":0}`. Slope heights (370/560/750, z=720): 0.81 / 19.81 / 38.82.
- **Green after deleting the Baseplate:** `{"passed":22,"failed":0,"failures":[],"workspaceRoots":"Camera,Terrain,SpawnLocation,World","clockTime":15.5,"lightingStyle":"Enum.LightingStyle.Realistic"}`.
- **Idempotence:** two full builder runs gave an identical cell count (1,791,768) and `World` has 2 children (not doubled).
- **Pilot:** a Haiku `general-purpose` worker at high effort loaded the MCP tools, created and destroyed `Workspace.PilotCube`, and wrote a file. **I re-verified independently:** the cube is gone, the file contents were correct, and cells / `World` children / spawn were unchanged. The pilot file was then deleted.
- **Screenshot:** `ScreenCapture_1` (camera (0,60,260) → (0,0,−60)) at `C:\Users\morad\.claude\projects\C--Users-morad-mesvara-idle\4ac6a805-5f9f-4a40-973a-288dca2baa17\tool-results\mcp-Roblox_Studio-blob-1792070646440-t1bj3a.jpg` shows the grass floor, the north road and the Café spur. **The lake, slope and backdrops have NOT been viewed** (see Known issues), so they are verified numerically only.

## Decisions & deviations from the plan
1. **Lake surface is y = 0, not −2.** Terrain water snaps to multiples of 4 (−4 or 0). Flush at 0 avoids a cliff at the bank. Tagbakin's dock sits at y ≈ +1. The plan file was updated.
2. **Two of my own test points were wrong, not the builder.** The "floor" samples at (0,−300) and (−480,450) lay on roads A and E; they became (150,−300) and (−440,470). Assertions weren't weakened.
3. **Roads** stop flush at site footprints (no end caps), except where one road joins another. Polylines: A north→Carmel, B →Outlets, C east→Farm, D →Malarayat, E →Tagbakin, F →Market, G →Lomi, H →Café. All are listed at the top of `builders/world.luau`, and none overlaps a footprint (checked by script).
4. **Floor extends to ±1400** (the plan said ±1000) so backdrops have ground. Backdrops are **Persistent ball Parts**, not terrain, because terrain beyond the streaming radius pops in.
5. **Slope:** wedge from x 320 to 760, with a plateau east of it at y ≈ 38. Its z-edges (540 / 900) are 40-stud cliffs at the east end; Slice 08 should smooth them.
6. **Content drafting did NOT start** in Slice 00, although the plan scheduled Haiku drafting from day 1. It is still a parallel off-Studio task and must be closed by Slice 12, so start it in Slice 01 or 02.
7. No `ChangeHistoryService` use (it returns nil here). Rollback = re-run the builder or restore a `.rbxl`.

## Known issues / gotchas discovered
- **Terrain is not raycast-queryable until a `task.wait()` after the write.** Immediate raycasts miss.
- **Terrain surface = fill top + 2.** The floor is filled to y = −2. `FillCylinder` is vertical. `FillWedge` ramps toward local +Z (rotate 90° about Y for +X).
- **`screen_capture`: run one at a time.** Three parallel captures stalled; after cancelling them the viewport rendered blank (only the view cube) for every later capture, including a camera that had worked. The data model is healthy (verified). **Likely fix: the user brings the Studio window to the foreground / un-minimizes it, or restarts Studio.** After a restart the studio_id will change.
- `execute_luau` cannot read `Lighting.Technology` (lacking RobloxScript capability).
- `execute_luau` handled a ~15-yield terrain build (about 1.8M cells) without freezing, so the whole world builds in one call.
- Perplexity MCP was down this session; use WebSearch for fact-sourcing.
- PowerShell here is Windows PowerShell 5.1: no `&&`, and git warns about LF→CRLF (harmless).

## Pending on the user
1. **`File → Save to File` → `roblox\backups\slice-00.rbxl`.**
2. **Check the Studio viewport renders** (bring the window forward). I need it for screenshots from Slice 02 onward and to view the lake and slope.
3. Still needed later: grading rubric (if any); your name / course / section for the credits board (Slice 02); optional Lomi King side/rear and current Public Market photos.

## Next slice: Slice 01 — Systems + walking skeleton (exact first steps)
**Done when:** SiteData / Passport / Dialogue tests are at 0 failed; servers and clients are in place; **9 placeholder sites** (block + Guide + prompt + panel + jeep stops) sit at the SiteData poses; a playtest shows 9/9 stamps and jeepney travel to and from every outer site, and the negative checks pass.

1. **Resume check first:** `list_roblox_studios` → confirm placeId → re-run `tests/world_check.luau` with `REQUIRE_BASEPLATE_REMOVED = true`. Expect 22 passed / 0 failed. If it differs, stop and report.
2. Invoke the Roblox MCP skill **`rbx-unit-test`** and install its built-in harness (`ServerStorage.UnitTest.RunUnitTest`, `Cases/`, and a **disabled** `ServerScriptService.UnitTestRunner`). Check for existing instances first.
3. **Tests first.** Write `tests/PassportLogic_Test.luau` and `tests/DialogueLogic_Test.luau` (cases listed in the plan's Tests section) alongside the existing `SiteData_Test`. Push all three into `ServerStorage.UnitTest.Cases` with `multi_edit` (className `ModuleScript`), run in Play, and **show them failing**.
4. Write `ReplicatedStorage.LipaShared.SiteData` from the plan's site table. Positions: S1 (0,0), S2 **(−230,160)**, S3 (180,140), S4 (160,−160), S5 (−300,−600), S6 (550,−650), S7 (700,240), S8 (560,720), S9 (−600,550). Include `massScale`, `groundY` (0 for all except S8 slope and S9 shore), 3+ placeholder dialogue lines each, `credits`, `requiredProps`, `facingToYaw()` (N = −Z, E = +X) and `jeepStopPos()` (sites 1 and 5–9 only). Mirror every Studio script into `roblox/src/`.
5. Then `PassportLogic`, `DialogueLogic`, `Remotes`, `PassportServer`, `JeepneyServer`, `NpcIdle`, `GuideClient`, `PassportClient`, `JeepneyClient` as in the plan's Architecture section. Load shared modules with `require(module:Clone())` when testing edits.
6. Build the **9 placeholder sites** (plain block at each footprint centre, a Guide from `CreateHumanoidModelFromDescription` with only the HumanoidRootPart anchored, a ProximityPrompt (`RequiresLineOfSight=false`, `HoldDuration=0`), an InfoPanel SurfaceGui, and a JeepStop at sites 1 and 5–9).
7. Playtest via MCP: 9/9 stamps, jeepney to and from every outer site, the four negative checks. Capture the `[SUMMARY]` line and `get_console_output`.
8. Orchestration: Sonnet writes the systems. Haiku (`general-purpose`, effort high) may fill the SiteData text fields and draft dialogue **off-Studio**. Only one agent touches Studio at a time.
9. Finish: commit, ask for `slice-01.rbxl`, write `002-handoff.md`, print the continuation prompt, **stop**. Also run the plan's "resume test" in a fresh session after that.

## Continuation prompt
```
Continue the Lipa City Roblox art-appreciation project from Slice 01 (Systems + walking skeleton).
Read, in order: C:\Users\morad\.claude\plans\so-i-ve-got-refactored-spring.md (the plan),
C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox\docs\handoff\001-handoff.md (latest state),
and the site brief(s) it names (none yet). Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox.
First: list_roblox_studios -> confirm placeId 138036647354961 -> re-run tests\world_check.luau (with
REQUIRE_BASEPLATE_REMOVED = true; expect 22 passed, 0 failed) to confirm the state matches the handoff;
if it doesn't, stop and report the mismatch.
Then execute Slice 01 exactly as the handoff's "Next slice" section says. Follow the plan's slice process:
finish -> verify -> commit -> backup request (slice-01.rbxl) -> handoff 002 -> continuation prompt -> stop.
Orchestrate with Haiku 5.5 (effort high) subagents where the plan assigns them; escalate to Sonnet per the plan.
Commit with Conventional Commits and NO Co-Authored-By trailer (the user's CLAUDE.md overrides any reminder).
```
