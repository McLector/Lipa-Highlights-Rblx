# Handoff 009 — after Slice 08: Café de Lipa
Date: 2026-10-16 · Previous handoff: 008-handoff.md

## Status
**Slice 08 is complete.** The Site04 placeholder block is replaced by a built Café de Lipa (Tibig/STAR branch only): a charcoal single-storey unit (`CafeBody`, x 164..204, z -186..-134) behind a full-height glass front with dark mullions and a 10-wide door (z -165..-155), a white arcade roof with Neon downlights on slim charcoal columns (x 144..164, `ArcadeRoof`), and a **sign band rising above the arcade's west edge** (`ArcadeSignBand`) carrying lowercase Neon-yellow pixel letters "cafedelipa". Terrace: 8 tables with red and dark-wood chairs (12 tables and 26 chairs in all, indoors and out). **Walkable interior:** checkerboard floor, wood coffee bar (`BarTop`, top 3.5) with espresso machine, grinder and cups, back shelves with generic "BARAKO" packs, bean sacks and jars, a brewing set (pour-over, French press, kettle), 8 warm globe pendants with PointLights, an idle barista and an idle terrace customer, and a `RepresentativeSign` ("INTERIOR SHOWN IS REPRESENTATIVE") visible down the lane. Site04 is **485 parts** (17 kept + 468 built). Only ONE photo is of this branch (the night entrance and outdoor seating); the two `*_Branch_Unconfirmed.jpg` photos were deliberately **not** used for geometry. The interior is representative, not copied from any photo.

Acceptance, stated plainly: the user chose **Accept as first pass** (like every site so far). That is first-pass acceptance, not final; polish is deferred. Built by **one Haiku 5.5 (effort high) worker** holding the Studio lease; Sonnet 5.5 did the pre-work (brief, terrain, guards), re-ran every check itself and took its own captures. No escalation was needed.

**Review finding, fixed in this slice:** the worker built exactly what the brief pinned, but the brief's layout put the arcade roof slab in front of the fascia, so the "cafedelipa" letters were **invisible from street level** (only yellow tips showed). Sonnet added a ray-cast guard first (red: 0 of 47 letters seen), then moved the sign onto the band above the arcade's outer edge with larger letters (green: 194/0). This is a brief error, not a worker error.

**Next slice: 09 — The Farm at San Benito.** Read "Next slice" below.

## Environment
- **studio_id:** `e5a12725-5636-4fe8-9a22-bc3e90055153` (re-run `list_roblox_studios`; ids change per instance). The open document is still named `slice-03.rbxl` in the studio list.
- **placeId reads 0** on this instance (a local file opened from `backups/`); the live place 138036647354961 still holds the Slice 03 state (Carmel, Outlets, Market, Lomi and Café are not published).
- Studio in **Edit**. Team Create off. `LightingStyle` Realistic, `ClockTime` 15.5.
- **Backups (gitignored):** **`backups/slice-08.rbxl`** (274,142 B, saved 2026-10-16 12:12:30, verified on disk with `ls`), plus `slice-07` (264,581 B), `slice-06`, `slice-05`, `slice-04`, `slice-03`, `slice-02`, `slice-02-pre-polish`, `slice-01` and the blank baseline. A `.lock` file sits beside the newest. Do not press Ctrl+S; use File → Save to File with a full path.

## What exists now
**Studio**
- Unchanged from handoff 008 except: `ServerStorage.Builders.site04` (new ModuleScript), `ServerStorage.Checks.sites_check` (edited), terrain (repainted), and `Workspace.Sites.Site04_Cafe`.
- `Site04_Cafe` direct children: `Guide`, `InfoPanel` (kept), plus `Structure` (shell, glass, fascia, arcade, columns, floors, sign band and Neon letters, downlights, neighbour bay), `CoffeeBar`, `BarakoBeans`, `CoffeePacks`, `BrewingSet`, `Tables`, `Pendants`, `Staff` (2 rigs, `Staff1`/`Staff2`). Sites 7, 8, 9 are still placeholders.
- Anchor parts the guards use (each a single uniquely named BasePart): `CafeBody` (centre (184, 14.5, -160)), `SignFascia` (x 163..165), `ArcadeRoof`, `BarTop`, `RepresentativeSign`. The Neon letters are parts named `NeonLetter` (47 of them).
- World total **3,762** parts (budget 20,000).
- Terrain: Grass → Pavement in a new region (world coordinates, 4-stud aligned): **x 112..212, z -200..-120** (road H's asphalt at x 96..112, z -164..-156 is untouched; the mouth ends at x = 112, not 110). Cell count **1,793,680** (was 1,793,530).

**Disk** (`roblox/`, local git, no remote, nothing pushed)
- New: `briefs/site04.md`, `builders/site04.luau`.
- Changed: `builders/world.luau` (`PAVED` +1 region), `tests/sites_check.luau` (`BUILT` +[4], six Site04 guards), `tests/world_check.luau` (Café paving probe).
- **Git:** `e797cee` `feat(slice-08): build Cafe de Lipa storefront` (no trailer). This handoff is committed afterwards as `docs(handoff): add 009 after slice-08`.
- Rebuild order if terrain or sites are ever rebuilt: `world.luau` → `placeholders` → `site01` → `site05` → `site06` → `site02` → `site03` → `site04`.

## Verification evidence (real output)
Resume check at the start (matched handoff 008): `sites_check` `{"failures":[],"passed":188,"failed":0}`; unit `{"run":86,"passed":86,"failed":0}`; BuildCheck Site01 16/0 1005 parts, Site02 15/0 976, Site03 15/0 300, Site05 15/0 391, Site06 15/0 512; `checkWorld` 1/0 3295 parts; `Terrain:CountCells()` 1,793,530; Edit mode; placeId 0. `world_check` **37 passed, 0 failed** with cells 1,793,530 (run from a restructured copy of the file's checks that used a `region()` helper; same checks and count, not the file's verbatim text).

Red first:
```
Cafe paving probe (file text, unpatched terrain): all 7 inside cells Grass ("cell (114,-198) is Grass, expected Pavement" ... (184,-160)); 7 of 7 control cells already correct. world_check {"passed":37,"failed":1}
sites_check with BUILT[4] + guards on the placeholder: {"passed":187,"failed":6}: Structure present and Block absent; sign fascia, coffee bar, arcade roof ("parts missing"); representative sign ("part missing"); walking lane into the cafe is free ("1 blocking: Workspace.Sites.Site04_Cafe.Block")
BuildCheck Site04 on the placeholder: passed 10, failed 4 (required prop CoffeeBar, BarakoBeans, CoffeePacks, BrewingSet | missing), parts 18
Sign-visibility guard on the worker's first build: {"passed":193,"failed":1}: "sign letters are visible from the street | 0 of 47 letters seen from the street"
```
Green, re-run by Sonnet on the final state (not copied from the worker):
```
terrain patch:       ReplaceMaterial Grass->Pavement x 112..212, z -200..-120: cells 1,793,530 -> 1,793,680; all 7 inside cells Pavement, 7 controls unchanged
world_check:         {"failures":[],"passed":38,"failed":0} cells=1793680 (a restructured copy again: paving() helper replaces the six repeated blocks; same checks)
sites_check:         {"failures":[],"passed":194,"failed":0}
unit suite:          {"run":86,"passed":86,"failed":0}
BuildCheck Site04:   passed 14, failed 0, parts 485
BuildCheck Site01:   passed 16, failed 0, parts 1005
BuildCheck Site02:   passed 15, failed 0, parts 976
BuildCheck Site03:   passed 15, failed 0, parts 300
BuildCheck Site05:   passed 15, failed 0, parts 391
BuildCheck Site06:   passed 15, failed 0, parts 512
checkWorld:          passed 1, failed 0, parts 3762 (3295 - 18 placeholder + 485)
builder idempotency: after the sign fix, two site04 runs gave 485 parts, 10 children each (the worker reported identical counts across 5 runs before it)
```
Drift check (djb2 over LF-normalised text, seed 5381, `chars/newlines/hash`), Studio `.Source` vs disk, **identical** (formula calibrated first: disk `site03` gave the handoff-008 value 17691/374/3746978984):
```
site04      20151/435/318532193
sites_check 15970/264/2507609577
```
Keep-clear (Sonnet, exact-size `OverlapParams`, Guide and InfoPanel excluded, each box with a positive control that was detected): Guide box (x 118..142, z -172..-148, y 0..14) 0 hits; InfoPanel front zone (x 124..136, z -154..-142) 0 hits; strip x 112..143 0 hits; lane (x 144..185, y 0.5..9, z -164..-156) 0 hits; guard box (z -162..-158, y 2..8) 0 hits.
Bounds (corner-transformed): 468 built parts span x 143.40..204.00, z -188.00..-122.00, maxY 21.60, inside the footprint x 110..210, z -200..-120; 0 unanchored non-rig parts; 0 thin ground corners outside x 112..212, z -200..-120; no stray probes.

Screenshots (`screen_capture`, one at a time, none blank): Sonnet's `s08_oblique` and `s08_facade` (before the sign fix: letters hidden), then `s08_oblique_fixed` (camera (118,10,-198) → (160,8,-150): the arcade, sign band with readable "cafedelipa", glass front, red and dark chairs, the Guide's InfoPanel at the right), `s08_facade_fixed` (camera (120,9,-160) → (170,12,-160): square-on, letters read lowercase and not mirrored, the representative sign visible through the door) and `s08_interior` (camera (150,6,-160) → (200,5,-160): clear lane to the bar, checkerboard, pendants glowing, barista, the representative sign legible). The worker's own captures were `Site04_Facade_1`, `_2_High`, `_3_High_Fixed`, `Site04_Lane_Interior` and `Site04_Street_Oblique`. **Not taken:** the rear, the neighbour bay, a close-up of the coffee bar or shelves.

## Decisions & deviations from the plan
1. **Frames:** pivot yawed to W, so `ORIGIN = CFrame.new(pivot position)` and `CF = ORIGIN * CFrame.fromMatrix(0, (0,0,1), up, (-1,0,0))`; world = (160 − lz, y, −160 + lx). A SurfaceGui facing the frontage is on `Enum.NormalId.Back`.
2. **Photos:** the plan's "3–5 photos" could not be met. Only `Cafe_de_Lipa_Tibig_STAR_Entrance_and_Outdoor_Seating_Night.jpg` is of this branch; the other two are excluded per the notes ("do not combine"). Recognizability comes from composition and palette: dark fascia, yellow letters, glass, white arcade, red chairs. **The photo is a night shot and the scene is daytime** (Lighting is off limits), so sign-off compares composition, not exposure.
3. **Terrain region** x 112..212 (not 110 or 108): x 112 is the east edge of road H's asphalt cells, following the Lomi precedent. Applied as a live `ReplaceMaterial` patch after the user's separate OK. The user did not ask for the optional full `world.luau` re-run, so the disk file's reproduction of the new count (and of the Market, Lomi and Café regions) is **still unproven**; do it at a convenient point with the user's OK.
4. **Guards (after the advisor's review):** the lane guard sweeps a 41 x 6 x 4 box (x 144..185, y 2..8, z -162..-158), 4 wide inside a 10-wide door so the jambs cannot fail it; the guard fails on any colliding non-rig part. Anchors are part-only and unique. **New this slice: a ray-cast sign-visibility guard** (eye (124, 8, -160), ray to each `NeonLetter` centre must hit that letter first; at least 80% and at least 20 letters). `sites_check` went 188 → **194**.
5. **Sign band (fix):** `ArcadeSignBand`, x 144..145.2, y 14..21.6, z -188..-128, with letters on its west face (x 143.4..144, pixel 0.9 high, pitch 1.3). The old letters on `SignFascia` were removed. `SignFascia` stays as an anchor (x 163..165, y 12..18). Nothing is built at x < 143.
6. **Worker deviations (accepted):** letters are blocky 6-row pixel Neon blocks, not a typeface; `RepresentativeSign` is 12 wide by 2.5 tall (a 12-tall sign would pierce the ceiling); back shelves only north and south of the barista; the customer is standing (no Seat), outside the lane; 12 tables, 26 chairs; the floor checkerboard is 65 dark 4-stud tiles on a light slab; the neighbour bay is one solid block.
7. **Acceptance is first-pass only.** Known weak points for a later polish pass: pixel-font letters with uneven spacing ("l" gap); daytime lighting against the night photo; standing customer; plain neighbour bay; no wires, no street furniture; the interior is representative and reads dark; no close-up capture of the coffee bar and shelves; sides and rear are plain.
8. The commit carries no Co-Authored-By trailer (the user's CLAUDE.md overrides the system reminder).

## Known issues / gotchas discovered
- **An arcade roof in front of a sign hides it from the street.** Pin sight-lines in the brief, not just coordinates, and guard them with a ray-cast (see Decision 4).
- **Rigs carry their own `Animate` script** (Guide, Staff, Diners): scripts inside a site are expected, not leaks.
- **`world_check` is not stored in Studio**: it has to be pasted into `execute_luau`. The long file text was condensed into a helper copy for the resume and final runs; only the red Café run used the file's verbatim structure.
- **`sites_check.luau` indentation:** the Site guards sit one tab shallower than they look; a scripted insert (Python, exact marker) worked first time after a failed `Edit`.
- **`screen_capture` needs `capture_id` and array positions** (`[x, y, z]`), not objects.
- **BuildKit materials are not colours** (a Slice 07 gotcha, passed on to this worker; it did not recur).
- Unchanged from before: `GetPartBoundsInBox` takes `OverlapParams` and exact sizes; `BuildCheck.checkSite(model, SiteData.byId(id))`; a rotated part's `Size` is in local axes; `screen_capture` returns a blank viewport until Studio is in the foreground; `BuildKit:arch` always tries CSG first; `world.luau` is not stored in Studio and clears all terrain (ask first); `multi_edit` needs hash verification; tab indentation and LF on disk; `get_console_output` is flooded by UIBlox traces; PowerShell 5.1 here-strings can't feed `git commit -F -` (use a message file); git warns LF→CRLF (harmless).

## Pending on the user
1. Still open: review the Haiku drafts in `content/` (gated at Slice 12); the grading rubric if there is one; name / course / section for the credits board; optional Lomi King side/rear photos and a current Public Market photo.
2. Carmel, the Outlets, the Market, Lomi King and the Café are **not published**; the live private place still has the Slice 03 state. A re-publish is only needed at Slice 14 unless the user wants it earlier.
3. A polish pass on the Cathedral, Carmel, the Outlets, the Market, Lomi King and the Café is wanted later (Decision 7 here and in handoffs 005–008); it is not scheduled.
4. In Slice 09 Sonnet will ask for the user's OK before the Farm terrain repaint (a live `ReplaceMaterial` patch) and may later ask for a `world.luau` re-run (which would also prove the Market, Lomi and Café regions).

## Next slice: 09 — The Farm at San Benito (exact first steps)
**Done when (master plan):** brief written; the placeholder is replaced; BuildCheck passes; screenshots vs. photos; Sonnet sign-off. **Builder tier: Haiku 5.5 (effort high), escalating to Sonnet after 2 failed BuildChecks or a weak photo comparison.** Site 7: `Site07_Farm`, pos (700, 0, 240), facing **W**, footprint 260 x 260 (world x 570..830, z 110..370), massScale 3.0, **has a JeepStop** (confirm in `SiteData`). Required props (SiteData): `GardenPavilion`, `LandscapedPath`, `WellnessPanel`. From the plan: **ONE villa with a pool + the meditation pavilion + a landscaped path/lagoon (no merged rooflines)**, and a wellness-tourism panel; **no interior is required**. Photo folder: the Farm's folder under `Lipa_structure_Exterior_References\` (verify its exact name with `ls` and read its `REFERENCE_NOTES.txt` first; folder numbering is not assumed). Check the terrain and any road leading to the site in `world.luau` and by measurement before laying out (the footprint is large, so measure the paved and turf areas and the JeepStop position).

**Sonnet pre-work, before any Haiku worker is spawned** (workers never touch the World; every paved or turf surface needs its terrain repainted):
1. **Resume check** (stop and report on any mismatch): `list_roblox_studios` → Edit mode (placeId 0 is fine for a local file); `world_check` **38 passed, 0 failed** with `Terrain:CountCells()` = **1,793,680** (paste the file text into `execute_luau`; it is not stored in Studio); `sites_check` **194/0**; unit suite **86/86/0**; BuildCheck (call `BC.checkSite(model, SiteData.byId(id))`) Site01 **16/0, 1005 parts**, Site02 **15/0, 976**, Site03 **15/0, 300**, Site04 **14/0, 485**, Site05 **15/0, 391**, Site06 **15/0, 512**; `checkWorld` **3762 parts**.
2. Read the Farm folder's `REFERENCE_NOTES.txt`, view the photos, read the Farm row of `modern_lipa_highlights_wt_details.md`, then write `briefs/site07.md` (3–5 photos by filename, palette, approximations, required props, **frame**, **keep-clear list** including the Guide at pos + 30·W, the InfoPanel, the JeepStop and its jeepney, and the road mouth, a **pinned walking lane and anchor positions** as in `briefs/site04.md`). Check `site:GetPivot().LookVector` first (yawed to W) and use a world-aligned origin plus `CFrame.fromMatrix`. Use part-only unique anchor names. **Pin sight-lines as well as coordinates:** anything the photos make recognizable (the villa facade, the pavilion) must be visible from the Guide and the road, and **guard it with a ray-cast like Site04's sign guard**.
3. **Terrain:** decide the paved and turf regions, add them to `PAVED` in `builders/world.luau` (4-stud aligned), write the `world_check` probe with controls **red first**, ask the user's OK (a separate question, with the red output, region edges and control cells), apply the live `ReplaceMaterial` patch, record the new cell count. Optionally, with a second OK, re-run `world.luau` in full to prove it reproduces the count (also proves the Market, Lomi and Café regions).
4. **Tests first:** `BUILT[7] = true` plus orientation guards for the W-facing frame on unique single-part anchors **and a walking-lane or path guard** and a visibility guard; watch them fail on the placeholder; push to Studio and hash-verify.
5. **Spawn one Haiku 5.5 (effort high) `general-purpose` worker** with `Agent(subagent_type: general-purpose, model: haiku, effort: high)`, giving it the studio lease. Its prompt follows the Slice 08 prompt (point it at the brief, `builders/site04.luau` / `site03.luau` / `site06.luau` as templates, `BuildKit.luau`, `BuildCheck.luau`, `sites_check.luau`; allowed paths **only** `Workspace.Sites.Site07_Farm`, `ServerStorage.Builders.site07`, `roblox/builders/site07.luau`; no git, no Terrain/world.luau, no Lighting/World/kit/test edits, no `start_stop_play`, do not touch Guide/InfoPanel/JeepStop/Jeepney; chunks ≤ ~400 parts; hash-verify after every `multi_edit`; blank captures twice → stop and report; materials are not colours).
6. BuildCheck on Site07 plus `sites_check`; Sonnet re-runs everything itself; captures one at a time (`capture_id`, array positions) next to the brief's photos; Sonnet sign-off; the user accepts recognizability.
7. Finish → verify → commit (`feat(slice-09): …`, no trailer, message from a file) → backup request (`slice-09.rbxl`, full path, then `ls` to confirm it exists) → handoff 010 → continuation prompt → stop.

**Lessons to hand the worker:** (a) the site pivot is yawed, so never use it as the origin; (b) orientation, lane and visibility guards first, on uniquely named single parts that no container shares; (c) thin parts do **not** hide terrain grass, so every paved or turf surface needs its terrain region repainted (done by Sonnet, not the worker); (d) `multi_edit` `replace_all` can silently fail, so hash-check; (e) text on a face toward the viewer is `Enum.NormalId.Back` for a +Z-facing frame; (f) keep the Guide's 12-stud prompt radius and the InfoPanel front clear; (g) use `OverlapParams` and exact sizes for keep-clear queries; (h) a part's `Size` is in local axes when it is rotated; (i) BuildKit material arguments are not colours; (j) keep the walking lane free of colliding parts and nothing lower than y 9 over it; (k) **nothing may stand between the street and the key landmark features: a roof or canopy in front of a sign hides it.**

## Continuation prompt
```
Continue the Lipa City Roblox art-appreciation project from Slice 09 (The Farm at San Benito).
Read, in order: C:\Users\morad\.claude\plans\so-i-ve-got-refactored-spring.md (the plan),
C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox\docs\handoff\009-handoff.md (latest state),
and the Farm reference notes it names (find the Farm folder under Lipa_structure_Exterior_References\ with ls and read its REFERENCE_NOTES.txt).
Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox.
First: list_roblox_studios -> confirm Studio is in Edit mode (if in Play, ask me to press Stop; placeId may read 0 if the
file was opened from backups\, which is fine when everything else matches) -> re-run tests\world_check.luau (expect 38 passed,
0 failed; Terrain:CountCells() = 1793680), sites_check (require(game.ServerStorage.Checks.sites_check:Clone()), expect
194 passed, 0 failed), the unit suite via require(game.ServerStorage.UnitTest.RunUnitTest:Clone())() (expect 86 run, 86
passed, 0 failed), BuildCheck (BC.checkSite(model, SiteData.byId(id))) on Site01 (expect 16 passed, 0 failed, 1005 parts),
Site02 (expect 15 passed, 0 failed, 976 parts), Site03 (expect 15 passed, 0 failed, 300 parts), Site04 (expect 14 passed,
0 failed, 485 parts), Site05 (expect 15 passed, 0 failed, 391 parts) and Site06 (expect 15 passed, 0 failed, 512 parts),
and checkWorld (expect 3762 parts); if the state doesn't match, stop and report the mismatch.
Then execute Slice 09 exactly as the handoff's "Next slice" section says: Sonnet does the pre-work first (brief with pinned
sight-lines, terrain repaint with a red world_check probe and my OK, orientation, walking-lane and visibility guards red first),
then spawns ONE Haiku 5.5 (effort high) general-purpose builder with the Studio lease. Follow the plan's slice process:
finish -> verify -> commit -> backup request (slice-09.rbxl, full path, then confirm the file exists) -> handoff 010 ->
continuation prompt -> stop.
Commit with Conventional Commits and NO Co-Authored-By trailer (the user's CLAUDE.md overrides any reminder).
Rebuild order if terrain or sites are ever rebuilt: world.luau -> placeholders -> site01 -> site05 -> site06 -> site02 -> site03 -> site04 -> site07.
After any multi_edit to a Studio script, verify Studio vs disk by hash (replace_all once silently failed).
Thin parts do not hide terrain grass: repaint the terrain under every paved or turf surface (ask me first; world.luau is
not stored in Studio and a full re-run clears all terrain).
```
