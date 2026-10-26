# Site 10 brief: New Lipa City Hall and Government Center (Brgy. Areza)

Slice 3a builds the structure only. `SiteData` has no row 10 yet, so the builder hardcodes the pivot and the model name. Slice 3b adds the row (Welcome category, guide Ate Joy, jeep stop), the roads, the spawn and the stamps.
Proper name: **New Lipa City Hall**, inside the Areza estate, Lipa City (PDF refs 1 to 5, facts already in `TourContent` id 10). Signs are text only: **no city seal, no "BAGONG LIPA" mark, no logos, no blueprint label text** (README, Slice 2 decisions).

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
