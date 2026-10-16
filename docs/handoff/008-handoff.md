# Handoff 008 — after Slice 07: Lomi King
Date: 2026-10-16 · Previous handoff: 007-handoff.md

## Status
**Slice 07 is complete.** The Site03 placeholder block is replaced by a built Lomi King shophouse: a salmon-pink 3-storey block (`LomiBody`, x 172..216, z 114..166) with an orange box awning carrying the 3-D "LOMI KING" letters, a yellow menu banner (LOMI / PANCIT / RICE MEALS / SANDWICHES / COFFEE), a round red logo sign, 7 dark window plates, a rounded second-floor bay, two topiary pots, a tiled front step, a closed south bay with a bamboo screen and a "PARKING FOR LOMI KING CUSTOMERS ONLY" sign, and a driveway strip. The ground floor front is open, with a **walkable interior**: a back counter (top 3.5), 6 tables with 12 chairs, 12 lomi bowls, utensils, a menu board and framed menu, globe pendants, and 3 idle R15 diners. Site03 is **300 parts** (17 kept + 283 built). The only photo is from **2015**; the brief says so and the Slice 12 dialogue must too. Sides, rear and the upper storeys' interiors are approximated.

Acceptance, stated plainly: the user chose **Accept as first pass** (like the Cathedral, Carmel, the Outlets and the Market). That is first-pass acceptance, not final; polish is deferred. Built by **one Haiku 5.5 (effort high) worker** holding the Studio lease; Sonnet 5.5 did the pre-work (brief, terrain, guards), re-ran every check itself and took its own captures. No escalation was needed. The worker's first builder run failed inside the build (a material passed as a colour); the fail-safe order destroyed the partial build and left the Block untouched, and the worker fixed it.

**Next slice: 08 — Café de Lipa.** Read "Next slice" below.

## Environment
- **studio_id:** `e5a12725-5636-4fe8-9a22-bc3e90055153` (re-run `list_roblox_studios`; ids change per instance). The open document is still named `slice-03.rbxl` in the studio list.
- **placeId reads 0** on this instance (a local file opened from `backups/`); the live place 138036647354961 still holds the Slice 03 state (Carmel, Outlets, Market and Lomi are not published).
- Studio in **Edit**. Team Create off. `LightingStyle` Realistic, `ClockTime` 15.5.
- **Backups (gitignored):** **`backups/slice-07.rbxl`** (264,581 B, saved 2026-10-16 11:44:32, verified on disk with `ls`), plus `slice-06` (256,367 B), `slice-05`, `slice-04`, `slice-03`, `slice-02`, `slice-02-pre-polish`, `slice-01`, and the blank baseline. A `.lock` file sits beside the newest. Do not press Ctrl+S; use File → Save to File with a full path.

## What exists now
**Studio**
- Unchanged from handoff 007 except: `ServerStorage.Builders.site03` (new ModuleScript), `ServerStorage.Checks.sites_check` (edited), terrain (repainted), and `Workspace.Sites.Site03_Lomi`.
- `Site03_Lomi` direct children: `Guide`, `InfoPanel` (kept), plus `Structure` (50 parts: floor tile, step, driveway, walls, columns, `AwningFascia`, `LomiBody`, roof, windows, bay, logo, bamboo screen, `ParkingSign`, pots, pendants, stove/hood), `Counter` (4, holds `CounterTop`), `Tables` (102), `LomiBowls` (26), `Menu` (4), `Utensils` (49), `Diners` (folder, 3 rigs). Sites 4, 7, 8, 9 are still placeholders.
- Anchor parts the guards use (each a single uniquely named BasePart): `LomiBody` (centre (194, 29, 140)), `AwningFascia`, `CounterTop`, `ParkingSign`.
- World total **3,295** parts (budget 20,000).
- Terrain: Grass → Pavement in a new region (world coordinates, 4-stud aligned): x 128..228, z 100..180 (road G's asphalt at x 120..128 is untouched). Cell count **1,793,530** (was 1,793,380).

**Disk** (`roblox/`, local git, no remote, nothing pushed)
- New: `briefs/site03.md`, `builders/site03.luau`.
- Changed: `builders/world.luau` (`PAVED` +1 region), `tests/sites_check.luau` (`BUILT` +[3], four Site03 guards), `tests/world_check.luau` (Lomi paving probe).
- **Git:** `6282bcf` `feat(slice-07): build Lomi King shophouse` (no trailer). This handoff is committed afterwards as `docs(handoff): add 008 after slice-07`.
- Rebuild order if terrain or sites are ever rebuilt: `world.luau` → `placeholders` → `site01` → `site05` → `site06` → `site02` → `site03`.

## Verification evidence (real output)
Resume check at the start (matched handoff 007): `world_check` 36 passed, 0 failed with cells 1,793,380; `sites_check` `{"failures":[],"passed":184,"failed":0}`; unit `{"run":86,"passed":86,"failed":0}`; BuildCheck Site01 16/0 1005 parts, Site02 15/0 976, Site05 15/0 391, Site06 15/0 512; `checkWorld` 1/0 3013 parts; Edit mode; placeId 0.

Red first:
```
Lomi paving probe on unpatched terrain: all 6 inside cells Grass ("cell (130,102) is Enum.Material.Grass, expected Pavement" ...); 5 of 5 control cells already correct (road G Asphalt at (126,120); Grass at (126,150), (232,140), (180,98), (180,182))
sites_check with BUILT[3] + guards on the placeholder: {"passed":183,"failed":5}: Structure present and Block absent; awning on the west frontage, counter inside, parking sign at the south end (all three "parts missing"); walking lane into the shop is free ("1 blocking: Workspace.Sites.Site03_Lomi.Block")
BuildCheck Site03 on the placeholder: passed 10, failed 5 (required prop Counter, Tables, LomiBowls, Menu, Utensils | missing), parts 18
```
Green, re-run by Sonnet after the build (not copied from the worker):
```
terrain patch:       ReplaceMaterial Grass->Pavement x 128..228, z 100..180: cells 1,793,530 (was 1,793,380); all 6 inside cells Pavement, 5 controls unchanged
sites_check:         {"failures":[],"passed":188,"failed":0}
unit suite:          {"run":86,"passed":86,"failed":0}
BuildCheck Site03:   passed 15, failed 0, parts 300
BuildCheck Site01:   passed 16, failed 0, parts 1005
BuildCheck Site02:   passed 15, failed 0, parts 976
BuildCheck Site05:   passed 15, failed 0, parts 391
BuildCheck Site06:   passed 15, failed 0, parts 512
checkWorld:          passed 1, failed 0, parts 3295 (3013 - 18 placeholder + 300)
builder idempotency: three site03 runs gave 300 parts each (kept 17, built 283), per the worker's run
```
`world_check` as a whole was **not** re-run after the patch; the Lomi probe's 6 inside cells and 5 controls were read directly after the patch (all as expected), and the other regions' cells were unchanged (cell count moved only by the patched region). Re-run `world_check` at the start of Slice 08 and expect **37 passed, 0 failed, cells 1,793,530**.

Drift check (djb2 over LF-normalised text, seed 5381, `chars/newlines/hash`), Studio `.Source` vs disk, **identical** (re-checked by Sonnet):
```
site03      17691/374/3746978984
sites_check 12068/206/2218139563
```
Keep-clear (worker, exact-size `OverlapParams`, Guide and InfoPanel excluded, with positive controls): Guide box (x 138..162, z 128..152, y 0..14) 0 hits; InfoPanel front zone (x 144..156, z 146..158) 0 hits; aisle lane (x 160..201, z 136..144, y 2..8) 0 hits; control detected in each. The lane is also enforced by the `sites_check` guard (z 138..142, rigs excluded).
Bounds (corner-transformed): built parts x 162.40..216.00, z 114.00..178.00, inside the footprint x 130..230, z 100..180; thin ground parts (floor tile, step, driveway, driveway line) inside x 128..228, z 100..180. My own naive check flagged the two rotated driveway parts because `Size` is in local axes; a corner transform clears them.

Screenshots (`screen_capture`, one at a time, none blank): Sonnet's `s07_oblique` (camera (140,8,108) → (172,10,145): pink block, awning, banner, logo, pots, tables visible through the open front, Guide's InfoPanel at the right), `s07_facade` (camera (132,9,148) → (172,12,136): square-on facade, letters and banner read correctly, not mirrored, InfoPanel text legible) and `s07_interior` (camera (160,6,140) → (205,4,138): clear aisle to the counter, menu board, pendants, tables and diners). The worker's own captures were `ScreenCapture_S03_1_StreetOblique`, `_2_FacadeWest` and `_3_AisleEast`. **Not taken:** a capture of the side or rear, or the closed south bay close-up.

## Decisions & deviations from the plan
1. **Frames:** pivot yawed to W, so `ORIGIN = CFrame.new(pivot position)` and `LK = ORIGIN * CFrame.fromMatrix(0, (0,0,1), up, (-1,0,0))` (local +Z = W = frontage, local +X = S). World = (180 − lz, y, 140 + lx). A SurfaceGui facing the frontage is on `Enum.NormalId.Back`.
2. **Guards (after the advisor's review):** the walking-lane guard replaced a one-cell doorway test. It sweeps a 41 x 6 x 4 box (x 160..201, y 2..8, z 138..142) and fails on any colliding non-rig part of the site, so the interior cannot be a stage set; the placeholder Block makes it red by itself (positive control). The brief pins the aisle (centreline z 140, lane z 136..144, nothing lower than y 9 over it) and the anchor positions. `LomiBody` is the upper-storey mass (y 14..44), not a solid ground-floor box. `sites_check` went 184 → **188**.
3. **Anchor names are part-only and unique** (`LomiBody`, `AwningFascia`, `CounterTop`, `ParkingSign`).
4. **Required props are direct children of the site model**, not inside `Structure`.
5. **Terrain region is the footprint** (x 128..228, z 100..180); `x0 128` stops at the east edge of road G's asphalt (x 120..128). Applied as a live `ReplaceMaterial` patch after the user's separate OK. The user declined the optional full `world.luau` re-run for now, so the disk file's reproduction of the new count (and of the Market region) is **still unproven**; do it at a convenient point with the user's OK.
6. **Worker deviations (accepted):** awning fascia and front step start at x 162.4 / 162.5 (brief: 162) so they do not touch the Guide box face; menu banner at x 162.6..163.0, y 9..11.3 with a red stripe to y 12; pots at z 122 and 147 (brief: 148) to clear the column at z 150; north-row chairs placed north/south so they do not hit the counter; diners standing, not seated. **Omitted:** the kitchen pass-through (the closed bay is solid), the ramen poster, upper-storey interiors. Part count is 300 against an aim of 900; nothing was added to fill budget.
7. **Acceptance is first-pass only.** Known weak points for a later polish pass: the interior reads dark; the back menu board's text is partly clipped by a pendant; the awning letters and board text are not legible from the grazing street angle; windows are flat plates; there is no kitchen, no ramen poster, no wires, no neighbour building; the sides and rear are plain pink; no comparison against the photo's low-angle street view was captured beyond the oblique.
8. The commit carries no Co-Authored-By trailer (the user's CLAUDE.md overrides the system reminder).

## Known issues / gotchas discovered
- **`screen_capture` needs `capture_id` and array positions** (`[x, y, z]`), not objects; the tool errors otherwise.
- **`BuildKit` materials are not colours:** passing `METAL` where a `Color3` is expected failed the first builder run ("Unable to assign property Color. Color3 expected, got EnumItem"); the fail-safe order recovered cleanly.
- **Edit tool indentation:** `tests/sites_check.luau`'s Site guards sit one tab shallower than they look; copy the exact tab depth from a Grep with context.
- **A failed "Save to File" can look like success;** always `ls` the backups folder (it worked first time this slice).
- Unchanged from before: `GetPartBoundsInBox` takes `OverlapParams` and exact sizes; `BuildCheck.checkSite(model, SiteData.byId(id))`; a rotated part's `Size` is in local axes; `screen_capture` returns a blank viewport until Studio is in the foreground; `BuildKit:arch` always tries CSG first; `world.luau` is not stored in Studio and clears all terrain (ask first); `multi_edit` needs hash verification; tab indentation and LF on disk; `get_console_output` is flooded by UIBlox traces; PowerShell 5.1 here-strings can't feed `git commit -F -` (use a message file); git warns LF→CRLF (harmless).

## Pending on the user
1. Still open: review the Haiku drafts in `content/` (gated at Slice 12); the grading rubric if there is one; name / course / section for the credits board; optional Lomi King side/rear photos and a current Public Market photo.
2. Carmel, the Outlets, the Market and Lomi King are **not published**; the live private place still has the Slice 03 state. A re-publish is only needed at Slice 14 unless the user wants it earlier.
3. A polish pass on the Cathedral, Carmel, the Outlets, the Market and Lomi King is wanted later (Decision 7 here and in handoffs 005–007); it is not scheduled.
4. In Slice 08 Sonnet will ask for the user's OK before the Café terrain repaint (a live `ReplaceMaterial` patch) and may later ask for a `world.luau` re-run (which would also prove the Market and Lomi regions).

## Next slice: 08 — Café de Lipa (exact first steps)
**Done when (master plan):** brief written; the placeholder is replaced; BuildCheck passes; screenshots vs. photos; Sonnet sign-off. **Builder tier: Haiku 5.5 (effort high), escalating to Sonnet after 2 failed BuildChecks or a weak photo comparison.** Site 4: `Site04_Cafe`, pos (160, 0, −160), facing **W**, footprint 100 x 80 (world x 110..210, z −200..−120), massScale 3.5, no JeepStop (confirm in `SiteData`). Required props: `CoffeeBar`, `BarakoBeans`, `CoffeePacks`, `BrewingSet`. **Interior is required**, **labelled representative** (the Café's interior photos are not of this branch, so the guide's dialogue and a sign must say the interior is representative). **Tibig/STAR branch only; never merged with the unconfirmed branches.** Road H (8 wide) runs (0,−100) → (0,−160) → (110,−160), so its asphalt mouth enters the footprint's west edge at x 110 along z −164..−156; check `world.luau` and measure the terrain before laying out. Photo folder: **`Lipa_structure_Exterior_References\02_Cafe_de_Lipa`** (the Glob for it returned nothing under that exact name at the end of Slice 07: verify the folder name with `ls` first). From the plan: dark storefront unit under an arcade roof, lowercase "cafedelipa" sign, pendant lamps, outdoor seating; brand names only as text signage.

**Sonnet pre-work, before any Haiku worker is spawned** (workers never touch the World; every paved surface needs its terrain repainted):
1. **Resume check** (stop and report on any mismatch): `list_roblox_studios` → Edit mode (placeId 0 is fine for a local file); `world_check` **37 passed, 0 failed** with `Terrain:CountCells()` = **1,793,530** (paste the file text into `execute_luau`; it is not stored in Studio); `sites_check` **188/0**; unit suite **86/86/0**; BuildCheck (call `BC.checkSite(model, SiteData.byId(id))`) Site01 **16/0, 1005 parts**, Site02 **15/0, 976**, Site03 **15/0, 300**, Site05 **15/0, 391**, Site06 **15/0, 512**; `checkWorld` **3295 parts**.
2. Read the Café folder's `REFERENCE_NOTES.txt`, view the photos, read the Café row of `modern_lipa_highlights_wt_details.md`, then write `briefs/site04.md` (3–5 photos by filename, palette, approximations, required props, **frame**, **keep-clear list** including the Guide at pos + 30·W, the InfoPanel and the road H mouth, **interior plan** with the door/ceiling/furniture sizes at human scale, and a **pinned walking lane and anchor positions** as in `briefs/site03.md`). Check `site:GetPivot().LookVector` first (yawed to W) and use a world-aligned origin plus `CFrame.fromMatrix`, as in `briefs/site03.md`. Use part-only unique anchor names.
3. **Terrain:** decide the paved regions, add them to `PAVED` in `builders/world.luau` (4-stud aligned), write the `world_check` probe with controls **red first**, ask the user's OK (a separate question, with the red output, region edges and control cells), apply the live `ReplaceMaterial` patch, record the new cell count. Optionally, with a second OK, re-run `world.luau` in full to prove it reproduces the count (also proves the Market and Lomi regions).
4. **Tests first:** `BUILT[4] = true` plus orientation guards for the W-facing frame on unique single-part anchors **and a walking-lane guard** like Site03's; watch them fail on the placeholder; push to Studio and hash-verify.
5. **Spawn one Haiku 5.5 (effort high) `general-purpose` worker** with `Agent(model: "haiku", effort: "high")`, giving it the studio lease. Its prompt follows the Slice 07 prompt (point it at the brief, `builders/site03.luau` / `site02.luau` / `site06.luau` as templates, `BuildKit.luau`, `BuildCheck.luau`, `sites_check.luau`; allowed paths **only** `Workspace.Sites.Site04_Cafe`, `ServerStorage.Builders.site04`, `roblox/builders/site04.luau`; no git, no Terrain/world.luau, no Lighting/World/kit/test edits, no `start_stop_play`, do not touch Guide/InfoPanel; chunks ≤ ~400 parts; hash-verify after every `multi_edit`; blank captures twice → stop and report; materials are not colours).
6. BuildCheck on Site04 plus `sites_check`; Sonnet re-runs everything itself; captures one at a time (`capture_id`, array positions) next to the brief's photos (including an interior view); Sonnet sign-off; the user accepts recognizability.
7. Finish → verify → commit (`feat(slice-08): …`, no trailer, message from a file) → backup request (`slice-08.rbxl`, full path, then `ls` to confirm it exists) → handoff 009 → continuation prompt → stop.

**Lessons to hand the worker:** (a) the site pivot is yawed, so never use it as the origin; (b) orientation and lane guards first, on uniquely named single parts that no container shares; (c) thin parts do **not** hide terrain grass, so every paved or turf surface needs its terrain region repainted (done by Sonnet, not the worker); (d) `multi_edit` `replace_all` can silently fail, so hash-check; (e) text on a face toward the viewer is `Enum.NormalId.Back` for a +Z-facing frame; (f) keep the Guide's 12-stud prompt radius and the InfoPanel front clear; (g) use `OverlapParams` and exact sizes for keep-clear queries; (h) a part's `Size` is in local axes when it is rotated; (i) BuildKit material arguments are not colours; (j) keep the walking lane free of colliding parts and nothing lower than y 9 over it.

## Continuation prompt
```
Continue the Lipa City Roblox art-appreciation project from Slice 08 (Café de Lipa).
Read, in order: C:\Users\morad\.claude\plans\so-i-ve-got-refactored-spring.md (the plan),
C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox\docs\handoff\008-handoff.md (latest state),
and the Café reference notes it names (Lipa_structure_Exterior_References\02_Cafe_de_Lipa\REFERENCE_NOTES.txt; verify the folder name with ls).
Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox.
First: list_roblox_studios -> confirm Studio is in Edit mode (if in Play, ask me to press Stop; placeId may read 0 if the
file was opened from backups\, which is fine when everything else matches) -> re-run tests\world_check.luau (expect 37 passed,
0 failed; Terrain:CountCells() = 1793530), sites_check (require(game.ServerStorage.Checks.sites_check:Clone()), expect
188 passed, 0 failed), the unit suite via require(game.ServerStorage.UnitTest.RunUnitTest:Clone())() (expect 86 run, 86
passed, 0 failed), BuildCheck (BC.checkSite(model, SiteData.byId(id))) on Site01 (expect 16 passed, 0 failed, 1005 parts),
Site02 (expect 15 passed, 0 failed, 976 parts), Site03 (expect 15 passed, 0 failed, 300 parts), Site05 (expect 15 passed,
0 failed, 391 parts) and Site06 (expect 15 passed, 0 failed, 512 parts), and checkWorld (expect 3295 parts); if the state
doesn't match, stop and report the mismatch.
Then execute Slice 08 exactly as the handoff's "Next slice" section says: Sonnet does the pre-work first (brief, terrain
repaint with a red world_check probe and my OK, orientation and walking-lane guards red first), then spawns ONE Haiku 5.5
(effort high) general-purpose builder with the Studio lease. Follow the plan's slice process: finish -> verify -> commit ->
backup request (slice-08.rbxl, full path, then confirm the file exists) -> handoff 009 -> continuation prompt -> stop.
Commit with Conventional Commits and NO Co-Authored-By trailer (the user's CLAUDE.md overrides any reminder).
Rebuild order if terrain or sites are ever rebuilt: world.luau -> placeholders -> site01 -> site05 -> site06 -> site02 -> site03 -> site04.
After any multi_edit to a Studio script, verify Studio vs disk by hash (replace_all once silently failed).
Thin parts do not hide terrain grass: repaint the terrain under every paved or turf surface (ask me first; world.luau is
not stored in Studio and a full re-run clears all terrain).
```
