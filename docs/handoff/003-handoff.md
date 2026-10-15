# Handoff 003 — after Slice 02: BuildCheck + kit + Cathedral
Date: 2026-10-16 · Previous handoff: 002-handoff.md

## Status
**Slice 02 is complete** against its Done-when list: the BuildCheck negative proof was shown, the kit smoke test passed, Site01 passes BuildCheck, and the user accepted the Cathedral against their photos (they pasted screenshots because `screen_capture` renders blank on this machine). The slice also covered a polish pass the user asked for (paved plaza ground, bigger dome and transept, terracotta roofs, plaza extras). Site01 is now the real Cathedral + Plaza Independencia (1,005 parts); the other eight sites are still placeholders.

This session was also the plan's **resume test** for handoff 002: it started from the continuation prompt alone and reached Slice 02 step 1. It surfaced two stale items (Studio left in Play; `world_check` hitting Site08's placeholder block), both fixed and recorded below.

**Next slice: 03 — Early private publish (needs the user).**

## Environment
- **studio_id:** `a383a981-043f-451b-9efe-d45197b2b77d` (re-run `list_roblox_studios` and match placeId `138036647354961`; ids change on restart).
- **Studio mode: Edit** at the time of writing. Team Create off (user's word). `LightingStyle` Realistic, `ClockTime` 15.5 (set by `world.luau`).
- **Backups (all gitignored):** `backups/art_appreciation_finals.rbxl` (blank baseline), `slice-01.rbxl` (169,847 B; the user saved it to the Desktop and it was copied here), `slice-02-pre-polish.rbxl` (208,528 B, 2026-10-16 01:59, state at commit `2cddfca`), **`slice-02.rbxl` (211,275 B, 2026-10-16 02:26, final state of this slice)**. Studio leaves a `slice-02.rbxl.lock` next to the last saved file; **do not press Ctrl+S** (it may write to that file). Use File → Save to File and type the full path (the dialog first defaulted to the Desktop).

## What exists now
**Studio** (Edit data model):
- `ReplicatedStorage.LipaShared`: `SiteData`, `PassportLogic`, `DialogueLogic`, `Remotes` (unchanged).
- `ServerStorage`: `LipaServer.{StampRules,JeepRules}`; **`BuildCheck`**, **`BuildKit`** (new); `Builders.{placeholders,site01}` (`site01` new); `Checks.sites_check`; `UnitTest.RunUnitTest` (now requires `module:Clone()`) and `UnitTest.Cases.{SiteData,PassportLogic,DialogueLogic,StampRules,JeepRules,BuildCheck,BuildKit}_Test`.
- `ServerScriptService`: `PassportServer`, `JeepneyServer`, `NpcIdle` (now Humanoid-based), `UnitTestRunner` (Disabled). `StarterPlayerScripts`: `GuideClient`, `PassportClient`, `JeepneyClient`. `TourCamera` not built yet.
- `Workspace.Sites`: 9 `SiteNN_Key` models. **Site01_Cathedral** = `Guide`, `InfoPanel`, `JeepStop`, `JeepSignPole`, `JeepSign`, `Jeepney` (all kept from the placeholder) plus `Structure` (Facade, Tower, Nave, Dome, Wing), `Plaza`, `Benches`, `Lamps`, `Flagpole`, `EventStage`, `PlazaPeople` (Visitor1–4, R15 idle rigs). Sites 2–9 are still placeholders (Block + Guide + InfoPanel + JeepStop where applicable); their floating "(placeholder)" billboard labels are visible from far away and are expected.
- `Workspace.World` unchanged except the terrain: the plaza ground (x −100…100, z 0…100) is now **Pavement**.
- Final part counts, Site01: **1,005** (kept 26 + built 979). Components: Facade 65, Tower 153, Nave 103, Dome 155, Wing 146, Plaza 175, Benches 40, Lamps 56, Flagpole 5, EventStage 17, PlazaPeople 64. 9 CSG arches, 0 fallbacks. World total 1,206 parts (budget 20,000).

**Disk** (`roblox/`, local git, no remote, nothing pushed):
- New: `src/ServerStorage/{BuildCheck,BuildKit}.luau`, `tests/{BuildCheck,BuildKit}_Test.luau`, `builders/site01.luau`, `briefs/site01.md`.
- Changed: `src/ServerStorage/UnitTest/RunUnitTest.luau`, `src/ServerScriptService/NpcIdle.server.luau`, `tests/sites_check.luau`, `tests/world_check.luau`, `builders/placeholders.luau` (header note), `builders/world.luau` (paving step).
- **Git:** `2cddfca` `feat(slice-02): add BuildCheck, build kit and Cathedral`, `fb5b76f` `feat(slice-02): polish Cathedral and pave plaza ground`. Neither has a Co-Authored-By trailer (checked with `git log -1 --format=%B`; CLAUDE.md overrides the session reminder).
- **Rebuild order is now: world → placeholders → site01** (`placeholders` wipes all of `Workspace.Sites`; `world.luau` wipes terrain, which removes the plaza paint until it re-runs its paving step).

## Verification evidence (real output)
**Red first.** New suites before their modules existed: `{"buildCheck":{"failed":17,"run":17,"passed":0},"buildKit":{"failed":9,"run":9,"passed":0}}`, each failing with `BuildCheck is not a valid member of ServerStorage "ServerStorage"` (the modules are required inside each test, so a missing module fails every case by name). Later red runs: octagonRing centre case `expected 56.56854248046875 within 0.001 of 10`; window material case `expected Enum.Material.Concrete, got Enum.Material.Glass`; `sites_check` with the new Site01 rule `{"failures":["Site01_Cathedral Structure present and Block absent"],"passed":175,"failed":1}`; BuildCheck on the placeholder Site01 `required prop PlazaPeople | missing` … (5 missing props); the paving check with the paint reverted: all 7 plaza cells `is Enum.Material.Grass, expected Pavement`.

**BuildCheck negative proof (shown first):** one unparented broken Site01 model vs a valid control, same module:
```
brokenModel: failed 4, passed 12, parts 2510
  bounds within footprint +10% | x -26.0..302.0 (limit -132.0..132.0), z -30.5..36.0 (limit -110.0..110.0)
  required prop Benches | missing
  part budget <= 2500 | 2510 parts
  all non-rig parts anchored | unanchored: 1
positiveControl: failed 0, passed 16, parts 9
```

**Kit smoke test (Edit, scratch model at (0,0,-900), then destroyed):** `{"ctxParts":70,"ctx2Parts":5,"flushed":[70,5],"basePartsInModel":75,"anchored":75,"archPaths":["csg","fallback"],"secs":0.057,"scratchLeft":false}`. Orientation checks by raycast: gable heights 23.63 / 21 / 18.38 and symmetric; fallback-arch spandrels 8.5 / 11 / 12 as designed; 48 dome ribs on the sphere (radius error 2e-5, radial alignment 0.9999999).

**Cathedral builder, final state:**
```
builder run:   builtParts 979, keptParts 26, parts 1005, archPaths {csg 9, fallback 0}
BuildCheck Site01: {"failed":0,"passed":16,"parts":1005}      checkWorld: failed 0, parts 1206
sites_check:   {"failures":[],"passed":176,"failed":0}
world_check:   {"cells":1792122,"failures":[],"passed":33,"failed":0}
unit suite (Edit and Play/Server): {"failed":0,"run":86,"passed":86}   (57 old + 17 BuildCheck + 12 BuildKit)
second builder run: identical (same parts, components, arch paths)
rebuild order: world.luau (cells 1792122) -> placeholders (built 9; sites_check 175/1, the one expected red) -> site01 -> sites_check 176/0, BuildCheck 0 failed, 1005 parts
```
Geometry by raycast (final): arm roof ridge 39.50, eaves 36.70; arm end gables at x 30.15; drum east window pane is the first hit at y 43; turret beside-roof 37.35 vs base 37.0; dome cross top 73.40, tower cross top 75.70; kerb present at the sides and south, open at the road mouth (x 0); hedges leave the pavilion gap; nave roof profile 35.8 / 40.7 / 46.9 / 40.7 / 35.8; wing roof 27.7 / 30.5 / 33.9 / 30.5 / 27.7.

**Disk vs Studio parity** (djb2 over LF-normalised text; Studio via `execute_luau` reading `.Source`): all nine mirrored scripts identical in chars, newlines and hash, e.g. `site01 chars=28161 newlines=552 hash=2425855947`, `BuildCheck 6620/187/3208423741`, `BuildKit 10927/254/3501999071`, `sites_check 5685/122/2032210765`, `NpcIdle 1286/39/3114079726`, `RunUnitTest 4085/107/3656484938`, `placeholders 7314/182/616413949`, `BuildCheck_Test 12274/315/3348271517`, `BuildKit_Test 8651/205/3441378978`.

**Play (real input, user pressed Play/Stop):** suite 86/86; 13 rigs (9 Guides + 4 visitors) each with exactly 1 playing idle track; a real E press at the Cathedral Guide gave `LastStampResult=ok_new` and opened the dialogue; the jeep stop prompt opened the menu with `Dest_5…Dest_9` (current stop hidden); `jeepSeq` reached 9 with `lastJeep=ok:1` (rides to and from outer sites worked); 0 server errors and 0 client errors (`LogService`, UIBlox noise excluded).

**Terrain probes:** patch test (x 0…8, z 48…56) converted exactly the surface voxel row (`Pavement(0.50)` over `Grass(1.00)` rows), height unchanged; revert (`Pavement → Grass`, same region) restored the cell count to exactly the Slice 00 baseline **1,791,768**; with the paint applied it is **1,792,122**.

## Decisions & deviations from the plan
1. **Test counts:** BuildCheck 17 and BuildKit 12 cases (plan said about 15 and 8; I split merged cases so each failure names its check, and added characterisation tests for window/gable/dome). Suite total **86**, not 80.
2. **BuildCheck bounds use each part's own 8 corners**, not `Model:GetBoundingBox` corners (that box is oriented to the pivot and overshot a 45° fixture: z ±141 for a part that was 2 studs thick). `checkWorld(root?, limit?)` takes injectable arguments so it is unit-testable.
3. **Paving moved into `world.luau`** (it owns terrain; the master plan puts the plaza under World) instead of `site01`, so `site01` stays strictly inside its own site. `world_check` gained one check: **33 checks now**. The file really had **32** before; handoff 002's "33" was a miscount (001 had said 22 for the same file), and the coincidence that the number is now 33 is just the new check. The check reads surface voxels (`Terrain:ReadVoxels`), not raycasts (see gotchas).
4. **`world_check` now excludes `Workspace.Sites`** from its terrain rays (it failed 31/1 at the start of this slice because Site08's placeholder block sat on the slope sample point).
5. **Polish (user's picks plus extras):** terracotta roofs, bigger dome (radius 15, top 64.5, cross 73.4) and transept (crossing 60 wide, gabled arm roofs with ridge y 39.5, end gables), plaza kerb with a gap at the road mouth, 6 more palms, 4 hedges, paved terrain. The user ticked both "Accept as is" and the refinements plus a request for extras; I read that as "polish, then finish", they accepted the result after looking.
6. **Two commits** (a verified checkpoint, then the polish), so the checkpoint is a real rollback point.
7. **No Haiku workers this slice:** the plan assigns the kit, BuildCheck and Cathedral to the orchestrator tier. Independent review passes used Plan subagents.
8. **PlazaPeople:** 4 R15 rigs named `Visitor1…4` (never `Guide`, which `PassportServer` finds by name), HRP-only anchored, Atomic streaming, name tags hidden. `NpcIdle` now watches for any Humanoid under `Sites` and marks each rig with an `IdleStarted` attribute so no rig gets a second track.
9. **Text on the model:** only the stage backdrop label "PUBLIC EVENTS" (generic) and the placeholder InfoPanel; proper names stay `[VERIFY]` until Slice 12. The flag is a plain blue/red banner, not claimed as the national flag.
10. **`sites_check`:** Site 1 now expects `Structure` present and `Block` absent; the anchored check exempts every rig (any Model with a Humanoid), not only `Guide`. Count unchanged at 176.

## Known issues / gotchas discovered
- **`screen_capture` returns a blank viewport on this machine** (only the axis gizmo shows) in Edit, including after the user brought Studio to the front and pressed Stop (four tries). The user pastes screenshots (Win+Shift+S, Ctrl+V) instead. The user can see the 3D view fine; the problem is in the capture tool.
- **Terrain:** `Terrain:ReplaceMaterial` takes a `Region3` in studs aligned to multiples of 4 with resolution exactly 4 (not `Region3int16`). A single `task.wait()` is **not** enough before raycasting a fresh terrain edit (about 1 s was). **Raycasts within about 2 studs of a material boundary report a blended material**, so edge samples are unreliable; use `ReadVoxels` of the 4-stud cell for exact checks. `Terrain.Decoration` is not readable. `Region3int16` (used by `CopyRegion`) is inclusive at both ends.
- **Terrain revert for the plaza paint:** `workspace.Terrain:ReplaceMaterial(Region3.new(Vector3.new(-100,-4,0), Vector3.new(100,4,100)), 4, Enum.Material.Pavement, Enum.Material.Grass)` (safe if the region holds no other Pavement; every sample was Grass before).
- **Roblox shapes:** a `WedgePart` slopes down toward −Z (right angle at +Z, bottom); a Cylinder part's axis is its local X; `SubtractAsync` works in Edit when parts sit in a Workspace scratch folder (`BuildKitScratch`, destroyed afterwards). CSG circles are tessellated (a 4-radius arch read 9.26 at an edge where a true circle gives 9.94).
- **`character_navigation`** stalled for 120 s twice while someone was also moving the character in the viewport; stop it with `TaskStop` and walk with `Humanoid:MoveTo` from a Client `execute_luau`. Pathfinding itself succeeded for every target. After one navigation to the Guide, the following E press read `ok_repeat`, which suggests the tool had already triggered the prompt on arrival (not confirmed).
- **`execute_luau` can read `Script.Source` in Edit**, which makes byte-level disk/Studio parity checks easy (hash above). `multi_edit` needs old strings that match tabs exactly.
- **Studio state lives only in the open session until saved to a `.rbxl`**; the disk copies can recreate every script, but not Studio-side terrain/instances. Save before risky steps.
- **Git on this machine:** warns LF→CRLF on every file (harmless); PowerShell 5.1 here-strings cannot feed `git commit -F -`; write the message to a scratchpad file and use `git commit -F <file>`.
- `start_stop_play` was not used this slice (the user pressed Play/Stop themselves); the Slice 01 denial of `start_stop_play(false)` is unverified since.
- Unchanged from before: `get_console_output` is flooded by UIBlox traces (filter `LogService:GetLogHistory()` on `MessageError`); in Play `script_read` sees the Client data model.

## Pending on the user
1. **Slice 03 needs you** (see below): publish the place privately, complete Roblox's Maturity & Compliance questionnaire, join the published experience for the live-server smoke test.
2. Still open from before: review the Haiku drafts in `content/` (gated at Slice 12); the grading rubric if there is one; your name / course / section for the credits board; optional Lomi King side/rear photos and a current Public Market photo.
3. Further polishing of the Cathedral can come later if you want it (your call).

## Next slice: 03 — Early private publish (exact first steps)
**Done when (master plan):** published private/friends; questionnaire done; a live-server smoke test (scripts current, prompts work).
1. **Resume check** (stop and report on any mismatch): `list_roblox_studios` → placeId `138036647354961`; confirm Studio is in **Edit** (if in Play, ask the user to press Stop); `world_check` **33/0** (run `tests/world_check.luau`; `workspace.Terrain:CountCells()` should read 1,792,122); `sites_check` **176/0** (`require(game.ServerStorage.Checks.sites_check:Clone())`); unit suite **86 run / 86 passed / 0 failed** (`require(game.ServerStorage.UnitTest.RunUnitTest:Clone())()` in Edit or Play/Server); BuildCheck Site01 **0 failed, 16 passed, 1,005 parts**.
2. **Say early what needs the user:** File → Publish to Roblox (private / friends only for now); the Creator Hub Maturity & Compliance questionnaire; later, joining the live experience. Nothing is public yet; public publish is Slice 14.
3. **Before publishing, check for drift** (CLAUDE.md): re-run the parity hash over the mirrored scripts (see the evidence section) so the scripts that go live are the ones in git, and confirm `git status` is clean.
4. **After publishing, the live-server smoke test:** the user joins the private experience; verify scripts are current (a stamp at the Cathedral Guide gives `ok_new`, the jeep menu opens, the HUD reads Passport x/9) and report anything that differs from Studio.
5. No site builders and no Haiku workers in this slice. Slice 04 (Carmel) follows once the publish loop is proven.

## Continuation prompt
```
Continue the Lipa City Roblox art-appreciation project from Slice 03 (Early private publish).
Read, in order: C:\Users\morad\.claude\plans\so-i-ve-got-refactored-spring.md (the plan),
C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox\docs\handoff\003-handoff.md (latest state).
Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox.
First: list_roblox_studios -> confirm placeId 138036647354961 -> confirm Studio is in Edit mode (if it is in
Play, ask me to press Stop) -> re-run tests\world_check.luau (expect 33 passed, 0 failed; Terrain:CountCells() = 1792122),
require(game.ServerStorage.Checks.sites_check:Clone()) (expect 176 passed, 0 failed), the unit suite via
require(game.ServerStorage.UnitTest.RunUnitTest:Clone())() (expect 86 run, 86 passed, 0 failed) and BuildCheck on
Site01 (expect 16 passed, 0 failed, 1005 parts) to confirm the state matches the handoff; if it doesn't, stop and
report the mismatch.
Then execute Slice 03 exactly as the handoff's "Next slice" section says, and say early which steps need me
(publish, the Maturity & Compliance questionnaire, joining the live server). Follow the plan's slice process:
finish -> verify -> commit -> backup request (slice-03.rbxl, full path) -> handoff 004 -> continuation prompt -> stop.
Commit with Conventional Commits and NO Co-Authored-By trailer (the user's CLAUDE.md overrides any reminder).
Rebuild order if terrain or sites are ever rebuilt: world.luau -> placeholders -> site01.
Orchestrate with Haiku 5.5 (effort high) subagents where the plan assigns them; escalate to Sonnet per the plan.
```
