# Site 10 brief: New Lipa City Hall and Government Center (Brgy. Areza)

Slice 3a builds the structure only. `SiteData` has no row 10 yet, so the builder hardcodes the pivot and the model name. Slice 3b adds the row (Welcome category, guide Ate Joy, jeep stop), the roads, the spawn and the stamps.
Proper name: **New Lipa City Hall**, inside the Areza estate, Lipa City (PDF refs 1 to 5, facts already in `TourContent` id 10). Signs are text only: **no city seal, no "BAGONG LIPA" mark, no logos, no blueprint label text** (README, Slice 2 decisions). **Exception, owner 2026-10-28: the seal and the "BAGONG LIPA" wordmark on the seal slab (WB07) are wanted, built from parts and text, see "Logo (owner, 2026-10-28)" at the end. Every other seal, logo and brand rule stands.**

## Sources and precedence
- Massing, layout, proportion: `2nd Reference/new_town_hall/3d Blue print/Lipa City Hall Blueprint.png` (AI-style drawing, about 180 m by 120 m; its labels are not facts).
- Visible detail: the photos in `2nd Reference/new_town_hall/` (`city-hall-300x113.jpg`, five `.avif`). Photos win over the blueprint where they conflict. **Source or credit for these photos is pending with the owner** (handoff 027); until then no text in the game cites them.
- Words: the PDF text in `TourContent` id 10 (`displayProps`: raised walk-under blocks, pocket gardens, open lobby, front plaza with welcome billboard and tour map, jeepney stop).
- Blueprint callouts we model: 4-storey government and office wing, multi-level lobbies and balconies, cantilevered atrium canopy, grand open-air atrium, grand terraced entrance steps, main forecourt and vehicular loop, surrounding parking.

## Frame
- Slot (world): x -350..-150, z -330..-190 (200 by 140). Pivot (-250, 0, -260). The building faces **East (+X)**: the wing is on the west, the forecourt and loop on the east, Road A beyond.
- Build in a **world-aligned local frame**: `ORIGIN = (-250, 0, -260)`, local axes equal world axes, so `world = ORIGIN + (lx, ly, lz)`, local x -100..100 and z -70..70. After building, set the model's `WorldPivot = CFrame.lookAt(ORIGIN, ORIGIN + (1, 0, 0))` (a property write, so no part moves) so `GetPivot().LookVector` is +X.
- Ground: probe by raycast and record the height (other sites sit at y 0). No terrain writes. Everything Anchored.
- The model is named `Site10_CityHall`. Replaced set (rebuilt on every run): `Wing`, `Blocks`, `Steps`, `Forecourt`, `Landscape`. Never touched or created by the builder: `Guide`, `InfoPanel`, `JeepStop`, `JeepSignPole`, `JeepSign`, `Jeepney` (Slice 3b placeholders add them).

## Layout along local x (200 deep)
| Zone | lx | Size | Notes |
|---|---|---|---|
| Wing | -100..-60 | 40 deep, z -70..30 (100 long) | 4 storeys on pilotis, atrium bay to its south |
| Gap | -60..-55 | 5 | |
| Block field | -55..5 | 60 deep, z -60..60 (120 wide) | the 72 blocks |
| Terraced steps | 5..25 | 20 | planted terraces either side of a central stair |
| Forecourt and loop | 25..100 | 75 | loop, flagpole, parking, trees |

This is 200 of 200 studs: if a human-scale clearance would have to shrink, the agent stops and reports. Never shrink doors (8 tall), railings (3) or clearances.

## The 72 blocks (owner choice, 2026-10-26)
- Named `ElevatedBlock`, exactly 72, in a **6 by 12 grid**: rows along x at lx -50, -40, ..., 0; columns along z at lz -55, -45, ..., 55 (pitch 10, 9 to 11 allowed).
- Each is about 7 x 6 x 7 (x, y, z), brick-clad (warm cream-white brick, Brick material), **underside at least 9 studs above the ground**, so players walk under every one. Four slim `BlockPilotis` (about 0.8 square) per block, inset at the corners, leave the middle clear: a 4-wide, 6-tall box on the ground under each block's centre overlaps no part.
- Blocks are real volumes, not flat panels. Plain text or none on them; no numbers that read as signs.

## Wing, atrium and canopy
- Wing: 4 storeys. Ground level open on pilotis (clearance 9 or more), then 4 floors of 13 to 15 studs. The outside is a mix of glazed bays (dark glass, at least 6 `GlazedBay`) and brick-clad projecting volumes, with balconies on the multi-level lobby bay. Railings 3 studs. Roof parapet and 2 or 3 small roof boxes (as in the blueprint). Colours: brick cream (214, 206, 190), glass dark teal (60, 84, 98), concrete (190, 192, 190), roof grey (120, 126, 132).
- Atrium (`OpenLobby`): south of the wing, open to the sky; a terraced stack of balconies on its sides, pilotis in a row. The `AtriumCanopy` is a big low-pitched roof (wedges and slabs) cantilevered at least 10 studs past its supports toward +x, and covers part of the atrium only.
- Entrance doors at least 8 tall, on the wing front, on the central axis of the steps.

## Steps and forecourt
- `TerracedSteps`: a central stair, riser 1.2 or less, tread 2 or more, flanked by 3 to 4 grassy planted terraces with low walls and small shrubs.
- `Forecourt`: paved plaza, a vehicle loop (asphalt ring around a grass island) with a plain `Flagpole` at least 30 tall (flag colours only, no seal), parking bays with painted lines, kerbs.
- **Reserved empty zones** (nothing built there, for Slices 3b, 8, 9): the spawn pad (lx 30..50, lz -10..10), the jeep stop curb (lx 90..100, lz 20..40), the welcome billboard and tour-map spot (lx 28..38, lz -30..-15).

## Landscape
`Tree` at least 12 (mango and acacia style, trunk plus canopy balls), `PocketGarden` at least 3 (low planters and shrubs near the wing and the steps), `ParkedCar` at least 8 (simple cars, muted colours, no brand marks) in the bays.

## Budget
At most 2,500 parts, about 1,500 targeted: wing about 550, blocks about 400, steps and forecourt about 350, landscape about 250. Built in plan-then-parent batches of 400 or fewer with `task.wait()` (README rule 7).

## Checks
`tests/site10_check.luau` (written first, red) covers: pivot and facing, real bounds inside the slot, 72 blocks in a 6 by 12 grid and walk-under clearance, 4 floors, canopy cantilever, open atrium, glazed bays, steps, flagpole, trees, gardens, cars, door and railing heights, zero image instances, no long TextScaled labels, reserved zones empty, all parts anchored, part count.

## Step C (blueprint rebuild)

The model is rebuilt from the blueprint drawing; `scratch/site10/layout.md` and `scratch/site10/model.py` are the design. The sections above describe the OLD design (72 raised blocks) and are kept as history. `tests/site10_check.luau` was rewritten tests-first for the new design. Nothing below was loosened silently: every retired assertion is listed with its replacement.

New frame: slot centre (-270, 0, -305), 240 x 286, faces E, model pivot at (-270, 0, -305), `world = ORIGIN + (lx, ly, lz)`. Real model bounds about x -322..-150, z -446..-188; the check requires x -323..-149, z -447..-187 (keeps `roads_check` green). SiteData row 10 local offsets: guideLocal (47, 45), jeepLocal (115, 75), panelLocal (53, 23); the world positions did not move (Guide -223/-260, JeepStop -155/-230, InfoPanel -217/-282, spawn pad x -214..-202, z -266..-254).

Spawn clash (owner decision): the faceted canopy stays as drawn and may overhang the spawn pad at height (underside about y 45). Nothing solid below the canopy may come within 2 studs (2D) of the pad, the Guide or the InfoPanel; nothing solid below y 20 within 4 studs of JeepStop or Jeepney. Canopy parts whose lowest point is 30 or more studs up are exempt.

### Retired assertions (old text -> why -> replacement)

Retired by the owner's list:

| Old assertion | Why retired | Replaced by |
|---|---|---|
| `exactly 72 ElevatedBlock` | the 72 blocks are gone; the drawing has staggered white-brick boxes | `at least 14 WhiteBrickBox, class Part, Brick, cream-white`; negative control `no ElevatedBlock or BlockPilotis from the old design remain` |
| `blocks form 6 rows (along x)` and `blocks form 12 columns (along z)` (the 6 x 12 grid) | no grid in the drawing | `boxes on the long wing are staggered: at least 3 distinct front-face x offsets`; `... at least 2 distinct heights` |
| `every block underside is at least 9 studs up`; `every block is about 7 x 6 x 7`; `blocks are brick clad` | belonged to the identical 72 blocks | cream brick check on every WhiteBrickBox; `clearance under the raised brick boxes is at least 10 studs` |
| `a 4 x 6 stud clearance under every block centre is empty` (walk-under box at each block centre) | the boxes are not walk-under blocks any more | `a 4 x 8 stud box on the base of every Pilotis overlaps no non-pilotis part`; the 10-stud clearance rule above |
| `each block stands on 4 pilotis (288)` (BlockPilotis) | BlockPilotis do not exist in the new design | `at least 20 Pilotis exist` plus the pilotis clearance rule |
| `pivot is at (-250, 0, -260), facing East (+X)` (old pivot) | slot moved | `pivot is at (-270, 0, -305), facing East (+X)` (tolerance 0.5) and `WorldPivot is at (-270, 0, -305) with LookVector +X` |
| `real bounds stay inside the slot x -350..-150, z -330..-190` (old slot bounds) | slot moved and grew | `real model bounds are inside x -323..-149, z -447..-187`, `structure containers stay inside ...`, `structure spans at least 150 studs in x and 220 in z` |
| layout-zone assertions in the old lx frame: `reserved zone SpawnPad / JeepCurb / BillboardSpot is clear` (lx 30..50, 90..100, 28..38) | encoded the old local frame; the pins did not move in the world | five world-space pin rules: pad, Guide, InfoPanel (2 studs) and JeepStop, Jeepney (4 studs below y 20) |
| reserved zones expressed in the old local frame in `tests/placeholders_check.luau` (ORIGIN (-250, 0, -260), JeepStop lx 88..102 / lz 18..42, InfoPanel lx 28..38 / lz -30..-15) | same | ORIGIN (-270, 0, -305); the same world boxes re-expressed (JeepStop lx 108..122 / lz 63..87, InfoPanel lx 48..58 / lz 15..30) plus literal world pins (-155, -230) and (-217, -282) within 2 studs. The Guide-to-pad distance of at least 6 is unchanged (it is 9). |

Retired because the old part names or numbers belong to the old wing, atrium and landscape (NOT on the owner's list: please confirm):

| Old assertion | Replaced by |
|---|---|
| `wing has 4 floor slabs` (WingFloor), `floor-to-floor is 13..15 studs`, `ground level of the wing is open on pilotis (first floor at least 9 up)`, `wing has pilotis` (WingPilotis >= 6) | `long wing has 4 storey lines (at least 6 apart) from y 10 to y 40 or more`, `long wing roof top is between 38 and 50`, `at least 20 Pilotis exist`, pilotis clearance box (layout storey pitch is 7.2, not 13..15) |
| `at least 6 glazed bays, all Glass` (GlazedBay) | `at least 8 GlassBand parts ... spanning at least 15 studs` |
| `brick-clad projecting volumes (at least 6 WingBrick)` | `at least 14 WhiteBrickBox` |
| `wing balconies with railings (at least 6 WingRailing, 3 tall)` | `balconies carry railings (at least 6 parts named *Rail*, each 3 tall)` (name widened) |
| `open-air atrium floor exists (OpenLobby)`, `AtriumCanopy exists`, `canopy has supports` (CanopySupport), `canopy overhangs its supports by at least 10 studs`, `atrium is open to the sky apart from the canopy` | `Wing contains a model named Atrium / Canopy`, `Atrium is angled`, 5 facet planes in 3 directions, canopy 30 up, `canopy cantilevers at least 10 studs past the Columns`, 3 RoofBox on the canopy, 6 round Columns. The old "open to the sky" rule has NO replacement: the drawn atrium sits under the canopy. |
| `planted terraces (at least 6 TerraceLawn)` | `at least 4 grass TerraceStrip, each at least 20 studs long` and `at least 4 TerraceWall` |
| `trees` by TreeCanopy and TreeTrunk >= 12 | Tree units >= 12 (Tree, WalkTree) and Trunk parts >= 12; plus Palm >= 2 |
| `at least 8 parked cars (CarBody)` | `at least 12 parked cars` (ParkedCar or Car_*) |
| `own part count is 1000..2500` | `800..2500` (the layout estimates 953 parts; the cap 2500 is unchanged) |

Kept with a wider name or a re-anchored number (not retired): steps (6 treads, riser at most 1.2, tread at least 2: StepTread or StairTread, risers read from tread tops when solid), doors at least 8 tall (EntranceDoor or Door1..3), Flagpole at least 30 tall, loop of at least 8 asphalt ring segments, forecourt paving (any `*Paving`), 12 BayLine, wheels 4 per car, no car on the flag island, pocket gardens >= 3 (`Landscape.PocketGardens`), anchored, zero image instances, no long TextScaled labels, no seal or brand text (now also LIPA), nothing below the ground. New: no direct child `Block`, the builder never creates the six placeholders inside its containers.

### Names the new check expects (owner names, plus the layout's item names where they differ)

WhiteBrickBox (or WB01..WB11, AB1..AB5), GlassBand (no alias), BalconySlab (or CoreBalcony1..3), TerraceStrip (or TerraceS1..5, TerraceN1..5), TerraceWall (no alias), LoopRing (or LoopRoad), LoopIsland, Flagpole, Flag, BayLine, ParkedCar (or Car_A1 ...), Tree (or WalkTree1..), Palm, Column1.., RoofBox1.. (wing) and *RoofBox* (canopy), Pilotis (or PilotiA1.., Pilotis_WB03), CanopyFacet* (any name containing Facet), Wing.Atrium, Wing.Canopy, Landscape.PocketGardens.

## Facade round (after Step C)

Everything above "Step C" describes the old 72-block design and is history. The facade was redone from the drawing: nine thin long-wing slabs (WB01..WB09, five reaching the roof line at y 43.8) and five atrium slabs (AB1..AB5, two tiers on the pentagon faces) replace the 16 pods; the GlassBand colour moves from (40,50,60) to (62,76,94), still Glass. Blocks went from 401 to 348 parts (build 10 is 1216, world 9183).

No assertion was loosened or retired. Four were added to the `blocks` group of `tests/site10_check.luau` (73 in all): long-wing main slabs are flat (depth at most 6.5 and at most 0.6 of width, width at least 8), at least 4 slabs reach the roof line (one-sided: top at least the roof slab top minus 0.5), every GlassBand is Glass and blue-grey (max channel 80..160, blue largest, blue at least red + 15), and the seal-box guard (no decal, texture or text on the right-end boxes).

Decisions and findings:
- The glass floor is 80, not 90: sampled panes in the drawing have a median of about (50,64,86), so 90 would fail the drawing itself. The photo's glass is greyer and greenish; the drawing wins.
- A rule that the north half of the long wing shows more glass was dropped: the drawing shows the opposite (white brick covers about 0.69 of the north half at the upper storeys against 0.28 in the south half, crude and perspective-distorted).
- The existing "at least 14 WhiteBrickBox" counts parts (every WhiteBrickBox* part), not slabs, so fewer slabs never threatened it.
- The south corner strip of the atrium (edge 4, u 52..59) stays bare dark glass because a slab there sits over `RailSW2` and breaks the 10-stud clearance rule; the slabs were moved instead of the rule.
- Still different from the drawing: finer, more visible brick tiling in the drawing (darker joints would break the cream-brick check), a little more curvature on the drawing's atrium slabs, a little more glass on the wing than drawn.

## Logo (owner, 2026-10-28)

After the facade round the owner said it looks good, to keep following the blueprint, and not to forget the logo attached to the building. The drawing and the 300x113 photo show a round city seal with a "BAGONG LIPA" wordmark on the upper-right brick slab of the long wing (the seal slab, WB07). The earlier rule (no seal, no wordmark, no logo) is reversed for this one slab; the owner chose to build it from parts and text (no image, no upload), and also to cover the bare atrium corner strip (edge 4, u 52..59).

Build: Model `SealLogo` in the Blocks container on the +X face of WB07 (concentric thin cylinder discs in white, gold, blue, red and green, a plain rim with no ring text), and a thin `LogoText` part carrying one SurfaceGui with two TextLabels (RichText stays off): `LogoBagong` "BAGONG" in red and `LogoLipa` "LIPA" in blue. ASCII, fixed TextSize, never TextScaled. The seal reproduces the one in the drawing and the photo already credited as Ayala Land (n.d.-c); no new credit source.

Assertions in `tests/site10_check.luau` that conflict and are replaced (old text, reason: owner's instruction above, replacement):
| Old assertion | Replaced by |
|---|---|
| `no seal or brand text (no BAGONG, LIPA, SEAL, KOPI, ABOITIZ on any label)` | SEAL, KOPI and ABOITIZ stay forbidden on every label; BAGONG only on `LogoBagong` and LIPA only on `LogoLipa`, both on WB07 |
| `no seal or logo text on the forecourt (no BAGONG or LIPA on any TextLabel or SurfaceGui)` | the same rule scoped to the Forecourt, Steps and Landscape containers (only if its loop is site-wide today) |
Not replaced, still true: `zero image instances`, `no long TextScaled line sits directly on a board`, and the plain-end-box guard (the lowest-lz long-wing box is WB09, the end cap, while the seal goes on WB07; the tests agent confirms which box the guard selects and leaves it alone if it is WB09).
New assertions: SealLogo on WB07 (at least 5 concentric Cylinder discs with Size.Y equal to Size.Z and a common centre, outer diameter 6..9, white, blue, red and green or gold present, on the slab's front face and below the roof line), one `LogoBagong` and one `LogoLipa` label, and a corner-strip rule.

Result (logo round): `SealLogo` is ten parts on the +X face of WB07 (white rim, gold ring, cream band, gold line, blue field with a green hill, a red shield and two gold dots; outer diameter 7.2, centre y 38, lz -96, back at lx 29.36). `LogoText` is a 0.5 x 2.0 x 11.0 cream plate under it with one SurfaceGui (Face Right, 50 pixels per stud) and two labels (`LogoBagong` red, `LogoLipa` blue, GothamBlack, TextSize 85, TextScaled and RichText off). The WB07 bed lines hidden behind the logo are omitted by a builder rule (no assertion changed). The corner is covered on the upper tier by a new slab AB6 (edge 4, u 52.3..58.9, y 29.4..42.8); the lower tier of the corner stays dark glass because a lower twin (AB7) failed the 10-stud clearance rule over `AtriumUnderSW` (0.40) and was removed. site10_check is 88, Blocks 368 parts, build 10 1236, world 9203. Still different from the drawing: the cream plate shows on the brick where the drawing has none, the drawing's seal has finer detail and ring text (the rim stays plain on purpose), and the drawing's wordmark is a condensed face.

## Ground (owner, 2026-10-29)

The owner asked to replace the grass around City Hall with concrete: the terrain grass blades (which sway) poked through the steps, plaza and terraces and looked bad where they should not be. Cause: only the old forecourt strip x -228..-148, z -332..-188 had ever been repainted (Pavement); the rest of the footprint was Grass terrain. Owner choices: City Hall site only, light concrete (terrain Concrete is (152,152,152), a neutral light grey like the drawing's plaza; Pavement is the darker (143,144,135)). `builders/roads_extra.luau` now repaints x -324..-148, z -448..-188 (the model's real bounds widened to the 4-stud grid) from Grass and from the old Pavement to Concrete; Asphalt and everything else is untouched, terrain is never cleared, a second run adds 0 cells. Cells 1794362 to 1794962 (+600, cause not established, as for the earlier repaints).

Assertions in `tests/roads_check.luau` section 5 replaced (reason: the owner's decision above):
| Old assertion | Replaced by |
|---|---|
| `City Hall forecourt ground (x -228..-148, z -332..-188) is Pavement` (4 x 5 points) | `City Hall ground (x -324..-148, z -448..-188) is Concrete at 25 sample points` (north wing, long wing front and rear, atrium and canopy, steps and terraces, loop and island, old forecourt, parking, tree row) |
| `control: the cells just outside the repainted ground are not Pavement` ((-236,-260), (-188,-340), (-188,-184), (-140,-300)) | `control: the cells just outside the repainted ground are still Grass` ((-332,-300), (-300,-452), (-300,-184), (-146,-300)) |
Cathedral (6b) and Credits (6c) rules are unchanged. roads_check stays 267.

## Atrium round (drawing as source of truth, 2026-10-30)

The owner compared the atrium with the blueprint and left it to me to find the differences; on assertions the owner said replacements are fine as long as they mirror the blueprint as the source of truth (this closes the open "confirm the retired assertion list" item). The tests agent measured the drawing and cross-checked screenshots: confirmed were the outer-end slab proportions (the drawing has two tall slabs, about 1.3 and 1.4 height over width on screen, and one low wide slab), the column layout (about 8 columns, but 4 thick ones in the front plane with uneven gaps and 3 to 4 slimmer ones standing 15 to 20 studs further in; the model had 8 identical columns on one line) and the glazing (the drawing's dark glass is a pane grid of about 2.4 x 2.2 studs; the model had only vertical mullions about 5.4 apart). Roof and plinth were dropped: the model already has a ridge, fold lines, an edge band, a thick white base and a balcony stack, and the ridge rise cannot be measured from the drawing's perspective.

Eight assertions were ADDED (nothing replaced, nothing loosened; the existing "at least 6 round Columns" agrees with the drawing's 8): at least 2 atrium slabs (AB main part, width at least 12) are tall (height at least 0.9 x width, at most 28.8; AB6 is excluded on purpose, it is a 6.6-wide strip); at least 1 atrium slab stays low and wide (height at most 0.7 x width); the front column row (within 3 studs of the front depth) has 4 to 6 round Columns; at least 2 Columns stand 6 or more studs behind the front row and there are at most 10; per glass wall (SE and SW) mullions at most 4.0 studs apart and at least 2 `AtriumTransom<SE|SW><N>` bars.

Build: AB1 15 x 18 and AB2 15 x 22 (tall), AB3 a small 7.5 x 8 low slab (a longer AB3 broke the 10-stud clearance rule over BalconySW1 at 0.40), AB5 the low wide slab, AB4 and AB6 unchanged; Column1..4 thick (d 3.0, cap 4.2) in the front plane with gaps of about 8.5, 11 and 4.3 studs, Column5..8 slim (d 1.5, cap 2.3) about 16 studs further in; SE 15 mullions, SW 11, back 22, 8 transoms and 3 grey spandrel strips per wall (mullions and transoms light grey Metal, spandrels Concrete, the glass colour (62,76,94) unchanged). Wing 282 to 332 parts, Blocks 368 to 355, build 10 1273, world 9240, site10_check 96.

Still different from the drawing: the slabs sit on the SE and SW faces and read slightly barrel-shaped (the inherited centre-facet push-out) where the drawing's are flat; the SE wall seen end-on from under the canopy shows as a plain dark panel; the roof was left alone on purpose.
