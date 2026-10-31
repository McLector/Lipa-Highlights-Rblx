# Site 08 brief — Mount Malarayat Golf & Country Club

Site row: id 8, key `Malarayat`, pos (560, 19.8, 720), facing **NW** (pivot `LookVector` = (-0.7071, 0, -0.7071), measured), footprint 400 x 320 world-aligned (x 360..760, z 560..880), massScale 2.0, **has a JeepStop**, **no interior required**. Required props (direct children of `Site08_Malarayat`, each a container holding at least one part): `Clubhouse`, `MountainBackdrop`, `LeisureSpacesPanel`.
Proper name: **Mount Malarayat Golf & Country Club** (`[VERIFY]` until sourced), Barangay Dagatan per the details md. A present-day recreation and hospitality destination: golf, accommodation and other leisure facilities; access depends on the service or booking. No photo textures (rights withheld): plain coloured parts; text is SurfaceGui. No brand logos (the cart-side photo shows a cart badge: do not copy it).

## One clubhouse (do not blend photos)
`REFERENCE_NOTES.txt` says the country-club buildings and the golf clubhouse are **distinct structures**: locate each before combining views. The user chose the **golf clubhouse**. Geometry comes from exactly these photos (`Lipa_structure_Exterior_References/07_Mount_Malarayat/`):
- **`Malarayat_Clubhouse_Aerial.jpg`:** a long two-storey block under a big terracotta **hipped** roof, a lower gabled wing at the left front, a covered ground-floor arcade, an upper balcony with white rails, palms and tall Norfolk pines around, golf carts in tidy rows along a curving drive.
- **`Malarayat_Clubhouse_Across_Lake.jpg`:** the same long low building seen across the pond: dark red hipped roof, white ground-floor columns, palms behind, sand and boulders along the water.
- **`Malarayat_Club_Building_Exterior_Golf_Cart_Side.jpg`:** **stone-clad** lower walls (tan cut stone) with mint-green trim and brackets, white upper walls, brown timber soffit under the eaves, large ground-floor windows, cream and green golf carts with canopies on a concrete forecourt.
- **Pool: `Malarayat_Pool_and_Club_Buildings_Elevated.jpg` only:** a free-form "guitar" pool, bright aqua, with red-brick deck bands and cream coping, palms, loungers, one umbrella. (An approximation: two joined rectangles.)
- **Course: `Malarayat_Green_Overhead.jpg`, `Malarayat_Mountain_Backdrop_01.jpg`, `Malarayat_Fairway_and_Mountains_02.jpg`:** a dark olive pond, a peanut-shaped island green with a small bridge, boulders and rocks at the edge, a blue-green mountain ridge behind.
- **Palette/landscape only (no geometry):** `Malarayat_Fairway_Perspective`, `_Ground_Landscape_03`, `_Lake_and_Grounds`, `_Landscape_and_Lake`.
- **Not used:** `Malarayat_Pool_and_Roof_Cluster_Overhead`, `_Poolside_and_Building_Elevated`, `_Club_Buildings_Roofs_Elevated`, `_Fairway_and_Club_Buildings_Overhead`: they show other country-club buildings (different roofs and footprints); copying them would merge structures.

## Colours (by eye)
| Element | Colour |
|---|---|
| Roof tiles | terracotta (170, 70, 45); ridge/hip caps (140, 54, 36) |
| Upper walls, columns, balcony rails | off-white (232, 228, 214) |
| Stone cladding (plinth, ground-floor walls) | tan (176, 160, 130) |
| Trim, brackets, window frames | mint (150, 196, 170) |
| Soffit / timber / doors | brown (130, 90, 60) |
| Window glass | (150, 190, 200), Glass, 0.5 transparent |
| Forecourt, drive plates | concrete (186, 178, 166) |
| Pool deck bands / coping | brick (160, 70, 50) / cream (226, 214, 190) |
| Pool water | aqua (60, 180, 215), 0.3 transparent |
| Carts: body / canopy / seat | cream (236, 226, 190) or green (60, 120, 80) / cream / tan |
| Boulders | dark (74, 70, 66) |
| Norfolk pine / palm trunk / fronds | foliage (40, 92, 52) / (120, 98, 70) / (50, 110, 50) |
| Mountain ridge | blue-green (70, 104, 96) with darker (52, 82, 76) |
| Bridge deck / rails | timber (150, 104, 64) |

## Frames (important)
The pivot is yawed NW. The builder does **not** use it as an origin.
- `PADY = 20.0` (measured: the clubhouse pad surface; see Terrain).
- `ORIGIN = Vector3.new(620, PADY, 780)` (the clubhouse centre `C`), world-aligned.
- `CF = CFrame.fromMatrix(ORIGIN, Vector3.new(-s, 0, s), Vector3.new(0, 1, 0))` with `s = 0.70711` (the Z axis is derived = (-s, 0, -s)). Local **+X = SW** (the right hand of a viewer facing the building from the front), local **+Z = NW = the frontage**, +Y up.
  So **world = (620 - s*(lx + lz), PADY + ly, 780 + s*(lx - lz))**.
- A SurfaceGui facing NW is on the part's local +Z face = `Enum.NormalId.Back`; probe each board (the same lesson as Site07). **Probe before trusting it.**
- Everything below is given in world coordinates unless marked local.

## Measured at the start of the slice (2026-10-16, live Studio)
- The slope is an exact plane: surface **y = 0.1 * (x - 360) - 0.2** for x 380..756 (0 at x 360, 19.8 at 560, 33.8 at 700), flat 38..39 east of x 756, identical for every z 548..896.
- Kept children (all rotated 45°, left as is):
  - **Guide** (538.8, 20.2, 698.8) facing NW (prompt radius 12); ground 17.7.
  - **InfoPanel** (534.5, 22.3, 711.5), 12 x 8 x 0.5, **front faces NW**.
  - **JeepStop** pad (552.9, 19.3, 684.6) 10 x 0.4 x 10 with `JeepSignPole` and `JeepSign` above it.
  - **Jeepney** (562.8, 23.4, 674.7), 10 x 6.6 x 16.4, its long axis along (-1, 0, 1)/√2.
  - The jeep ride lands the player at the JeepStop + 5 up.
- **Road D** (asphalt, 12 wide) ended at z 536 against the slope's vertical north wall (6..9 high at z 540). Sonnet added a ramp (terrain) so the road now climbs to the slope: ground at (450, 556) = 8.8.

## Terrain (decided and applied by Sonnet; the worker does NOT touch Terrain; a `world_check` probe guards it)
Cell count after the full `world.luau` re-run: **1,792,978**.
| What | Region (x, z) | Result |
|---|---|---|
| Road D ramp + asphalt | ramp x 440..460, z 500..548; asphalt x 444..456 z 500..704, then x 456..520 z 692..704 | the drive: **terrain Asphalt, no parts needed**; ground 0 → 8.8 → 8.8 (x 450) |
| Guide plaza | x 516..580, z 668..724 | Pavement (surface unchanged, 15..22) |
| Clubhouse pad + forecourt | **cut** x 572..672, z 704..844; **paint** Pavement x 556..672, z 704..844 | flat **y 20.0** for x 572..668; x 556..572 is the natural slope 19.4..20.8 (a bump to 21.0 at x 568) |
| Pond (two rectangles) | A x 440..488 z 772..812; B x 452..496 z 808..848 | water surface **5.5**, sand bed about 2; rims are the original ground: 7.4 at the west bank rising east (at least 1.9 above the water) |
| Island green | x 456..476, z 784..800 | LeafyGrass mound, centre y **9.0**, edges 7.4 |
| Tees / greens (LeafyGrass) | hole 1 tee x 420..432 z 784..800 (green = the island); hole 2 tee x 572..588 z 632..648, green x 712..736 z 608..632; hole 3 tee x 380..396 z 580..596, green x 388..412 z 704..728 | the surface IS the terrain: **no turf parts** |
| Bunkers (Sand) | x 700..712 z 636..648; x 736..748 z 604..616; x 376..388 z 696..708; x 412..424 z 716..728 | terrain, no parts |
Everything else stays Grass (the fairways are natural terrain).
**Thin-parts rule:** thin parts do not hide terrain grass. A part whose top is within 0.8 stud of the terrain under it (and whose footprint is over 2.5) may stand **only inside a Pavement or Asphalt region above**: the plaza, the pad/forecourt (x 556..672, z 704..844) or the drive. Do not lay thin plates on Grass, LeafyGrass or Sand. Thick things (plinths whose top is at least 1.5 above the highest ground under them, rocks, bridges, trees) may stand anywhere.
**Seat everything by raycast against `workspace.Terrain`** (`RaycastParams` with `FilterType = Include`, `FilterDescendantsInstances = { workspace.Terrain }`, ray from y 200 down). The terrain mesh is smoothed within about 2 studs of a cut wall, so read ground at least 3 studs from a wall.

## Layout
**Clubhouse** (container `Clubhouse`, a direct child). Local coordinates (lx right/SW, lz front/NW, ly up from PADY):
- **Podium and ground floor:** lx -50..50, lz -20..16. A stone-clad plinth ly 0..4 (tan, proud by 0.4), then the ground floor to ly 12 with pilasters every 10 studs (mint trim), large window bays (**`ClubhouseWindow`**: separate glass-pane parts, at least 10 on the NW face, ly 5..11), two glazed doors. At the rear and sides: plain white walls.
- **Upper floor:** ly 12..24, white, on the NW face a second row of at least 10 **`ClubhouseWindow`** panes (ly 15..22).
- **Balcony:** a slab lz 16..21, ly 12..12.8 along the whole front except the entry gable, on slim white columns at lz 20..21 every 12.5 studs (ly 0..12; the ground floor reads as an arcade). Rails 3 high (ly 12.8..15.8) along the front edge in at least 8 separate segments named **`ClubhouseBalconyRail`**.
- **Main roof:** a hipped terracotta roof, eave ly 24 (overhang 4 on every side), ridge ly 34..36 along lx -34..34. The ridge cap is the single part **`ClubhouseRoofMain`** (centre within 15 studs of C in plan, y >= 44).
- **Entry gable pavilion:** lx -14..14, lz 16..30, walls ly 0..20, a gabled terracotta roof peaking at ly 30. Its ridge cap is **`ClubhouseEntryGable`** (one part).
- **Porte-cochère:** a canopy slab lx -12..12, lz 30..44 at ly 12..13.2 (clear height 12 beneath), on four posts at its corners (lx ±11, lz 31 and 43). The slab is **`PorteCochere`** (one part). The centre line lx -2..2 stays free (lane b ends in it).
- **Left wing (SW):** lx 50..74, lz -10..14, one storey ly 0..12 with its own lower hipped roof (eave 12, ridge 17). Never merged with the main roof.
- Roof overhangs stay inside the pad region (x 556..672, z 704..844).
- Stairs: two shallow steps (risers 1) at the entry gable's front; nothing taller than 2 in any lane.

**Forecourt** (in `Structure`): a concrete plate and kerb lz 40..56, lx -32..32 (corner points world (557.8, ., 757.4) and (603, ., 717.8), inside the Pavement region). Carts in **two rows** at lz 50..56, lx 18..40 and lx -40..-18, plus a few at the plaza edge: about 12 carts, each a small group (body, seat, canopy on four poles, 4 wheels), 6 x 3.5 in plan, canopy top y <= PADY + 6.5. **Carts stand outside all lanes and out of the sight corridors.** Two lamp posts and a flagpole are allowed outside the lanes.

**Pool** (in `Structure`), SW of the clubhouse, on a raised terrace whose top is **y 21.0** (a 1-stud step up from the forecourt, so the plinth is never thin). Local deck lx 78..134, lz -4..28, a stone plinth from the ground up to y 21.0 (seat each column by raycast; the west end is up to 6.5 high). Pool basin lx 86..122, lz 4..22 plus a second lobe lx 112..130, lz 10..24 (a guitar shape from two rectangles), a rim 1.0 high, brick deck bands and cream coping. **`PoolWater`** is ONE part, the main basin water (centre near world (538, 21.4, 845), top y 21.8, CanCollide false). 6 loungers, one umbrella, palms around the outside.

**Pond props** (in `Structure`): boulders (dark spheres/blocks, 30 or more) along the rims and in the water; a flagstick on the island: **`IslandFlag`** (ONE part, a pole 12..16 high, base on the island at about (466, ., 792)); a footbridge **`IslandBridge`** (deck top about y 8.0, 4 wide, from the west bank at (438, ., 792) to the island at (456, ., 792)).

**The three holes** (in `Structure`): the **fairways are natural terrain**; add a `TeeMarker` pair (two small spheres) at each tee, a flag (named **`GreenFlag`**, a pole 10..12 high plus a triangular flag) at each of the greens at (724, ., 620) (hole 2) and (400, ., 716) (hole 3), `IslandFlag` for hole 1, a bench and a ball washer at the tee of holes 2 and 3, distance signs, and a few boulders at the bunkers. No turf parts, no bunker parts.

**Trees and planting** (in `Structure`): Norfolk pines (a trunk and 5 tiers of narrowing cones, 24..32 high) in loose rows along the drive and the forecourt sides; palms (stacked cylinder trunks, non-colliding fronds; 14..18 high) around the pool and the pond; shrubs <= 3 high. **Trunks collide and must stay out of every lane, every keep-clear box and the sight corridors** (below). Pines and palms are allowed only: x 460..520 at z 600..690 (drive east side), x 600..672 at z 600..700, around the pool and the pond (outside lane d), x 680..758 (any z), z 560..600 (any x), z 850..880 (any x). Nothing taller than 4 within 14 studs of the line x - z = -160 between x 540 and 600 (the Guide to the porte-cochère view).

**MountainBackdrop** (container, direct child): a jagged ridge of overlapping wedges, cones and large flattened blocks along the east edge, **x 700..758** (inside the footprint, at least 2 studs inside the x 758 limit), z 570..870, from the plateau (y 38) up to a highest summit about y 90, blue-green with darker shadowed faces, at least 20 parts. **`BackdropPeak`** is ONE part: the tallest summit, centre about (742, 80, 720) (x >= 690, y >= 60). All parts CanCollide false, anchored. It reads as the mountain behind the clubhouse and the course.

**LeisureSpacesPanel** (container, direct child): a free-standing signboard on two posts, 12 wide, 7 tall (y PADY+3..PADY+10), centre about **(574, ., 706)**, its text face to the **SW** (toward lane b; probe the NormalId), one SurfaceGui TextLabel; the board part is **`LeisureBoard`**. Text: "LEISURE SPACES. Mount Malarayat Golf & Country Club is a recreation and hospitality destination in Lipa's mountain setting. It offers golf, accommodation and other leisure facilities; access depends on the service or booking."

**Maximum:** <= 2,500 parts (target 900..1,500).

## Keep clear (existing, kept; checked on built children only; world coordinates)
- **Guide:** box x 526.8..550.8, z 686.8..710.8, **y 21..33** free of built parts (plaza paving below y 21 is fine).
- **InfoPanel front zone:** x 523..539, z 700..716, y 21..31.
- **JeepStop, jeepney and the ride landing:** x 546..580, z 662..692, y 21..34.
- **Road mouth / drive:** lane a below.

## Walking lanes (pinned; the guards test them)
Each lane is 4 wide and fails on any colliding non-rig part of the site. Lane a, d and the ramp follow the ground (box y from the highest ground under 16-stud segments + 2 to + 9); lanes b and c use the fixed y 22..29. Nothing hangs lower than y 29 over lanes b and c.
- **(a)** the drive: (450, 552) → (450, 700) → (524, 700).
- **(b)** Guide to porte-cochère: (548, 708) → (592, 752), on the diagonal x - z = -160.
- **(c)** forecourt to pool: (585, 753) → (537, 815).
- **(d)** plaza to the hole 1 tee: (520, 722) → (436, 758) → (426, 788).

## Sight-lines (pinned; the visibility guards ray-cast them)
- From the **Guide-side eye (534.6, 23.2, 694.6)** (6 studs NW of the Guide): at least 80% of the `ClubhouseWindow` centres and at least 80% of the `ClubhouseBalconyRail` centres must be reached first by a ray (built parts only).
- From the **road eye (450, 14.5, 556)** (the foot of the drive): at least 80% of the `ClubhouseWindow` centres.
- The Guide, InfoPanel and JeepStop/jeepney parts are ignored by the rays.

## Anchors (one uniquely named BasePart each; no Model/Folder may share these names; searched recursively)
`ClubhouseRoofMain`, `ClubhouseEntryGable`, `PorteCochere`, `PoolWater`, `IslandFlag`, `BackdropPeak`, `LeisureBoard`. Repeated part names (visibility targets, not anchors): `ClubhouseWindow`, `ClubhouseBalconyRail`, `GreenFlag`. Required props are direct children **containers** named exactly `Clubhouse`, `MountainBackdrop`, `LeisureSpacesPanel`; everything else goes in a `Structure` Folder (also a direct child).

## Approximated
The clubhouse as a box with a hipped roof (real: a longer, more complex roof mass); the pool (two rectangles, not a free-form shape); the pond (two rectangles); fairways as natural terrain; pines and palms as stacked primitives; the mountains as a ridge of wedges; no interior; no other country-club buildings; no real course layout (three holes compressed to teaching size).

## Art-observation hooks for dialogue (Slice 12 will source them)
The big hipped roof as the dominant mass (emphasis and unity); the horizontal layering of lawn, arcade, balcony and roof; the repeated windows and columns as rhythm; red-brown roof against green lawn and blue-green mountains (colour harmony and contrast); the curved pool and pond against the straight building (organic against geometric form); the mountain backdrop as depth and scale.

## Revision 1 (Slice 21): fidelity rework from the clubhouse aerial and the cart-side exterior
**References:** the photos the brief already names (`Malarayat_Clubhouse_Aerial.jpg`, `Malarayat_Club_Building_Exterior_Golf_Cart_Side.jpg`, `Malarayat_Clubhouse_Across_Lake.jpg`); no new photo, no credit change. `tests/site08_check.luau` encodes the table.

| # | Real | Before | Now |
|---|---|---|---|
| 1 | Bright orange-red terracotta roof | dull pink (170,70,45) | (200,84,52); cap (168,64,40) |
| 2 | Mint surrounds on the ground windows | mint pilasters and band only | 24 `WindowTrim` strips (4 per window) |
| 3 | Cut-stone courses on the cladding | flat tan | 4 `StoneCourse` lines |
| 4 | Rows of carts along the drive | 9 carts | 12 (third row on the left; the right side is walking lane c) |
| 5 | Tall slender Norfolk pines | 28 high, 5 tiers | 34 high, 8 tiers (9.5 down to 2.9) |
| 6 | Tall palms | 15 high, 6 fronds of 6.5 | 18 high, 8 fronds of 9.5 |
| 7 | (model bug) | `LeisureBoard` 225 characters TextScaled | fixed 16 px wrapped text |

## Revision 2 (Standard tier, 2026-10-31): rebuilt from the Mount Malarayat Golf Resort Blueprint board
**Source:** `..\2nd Reference\mt_malarayat\3d blue print\Mount Malarayat Golf Resort Blueprint.png` (the board wins; photos 01-03 of `PHOTOS\01_Entrance_and_Approach` fill gaps only: stone colour, metal letters). Plan: `scratch/standard_tier_plan.md` "08 Malarayat". Slot, pivot, terrain and the sites_check guards are unchanged.
**Builder:** `builders/site08.luau` is now a coordinator (site03 pattern: KEEP list incl. `LocalNPCs`, MODULES, containers of at most 400 parts, PART_BUDGET 2500, WorldPivot written explicitly) with `site08_clubhouse` (Clubhouse, Structure/Forecourt, Structure/Pool), `site08_hotel` (Hotel), `site08_context` (MountainBackdrop, LeisureSpacesPanel, Structure/Pond, Course, Trees, Woods) and `site08_entrance` (Entrance). Hip roofs are 2 WedgeParts + 4 CornerWedgeParts (probed: the corner wedge's peak edge is its local (+X, -Z) corner). Arcade and gatehouse arches are BuildKit CSG arches. Every tall thing near the road-eye and Guide-eye sight wedges, the lanes and the keep-clear boxes goes through `env.sightClear` and is skipped if it would cut them.
**Layout (world):** gate axis +Z from the road mouth, so board-left = +X. Gatehouse astride the drive (pavilion island x 431..443, z 591..605; lane canopies over the drive and the exit apron, beam underside y 19); flag island x 432..442, z 568..578; paved forecourt x 414..462, z 560..612 in level x-strips; rock monument with "MOUNT MALARAYAT / GOLF AND COUNTRY CLUB" at x 512..552, z 590, facing the road; lagoons z 561..584 at x 458..560 (east, two terraces 13.4 / 19.0) and x 364..414 (west, 3.0 / 5.6). Clubhouse unchanged in place (C = (620, 780), facing NW), rebuilt to the elevation inset: left pavilion with cupola, main block with a six-bay arched loggia and balcony, entry pavilion with three arches and a pediment, higher central belvedere, right block, right-end pavilion, porte-cochere with its own hip roof. Hotel & Suites x 361..459, z 849..879 (four-storey wing, five-storey east block, two-storey west wing, pool terrace z 828..849).

| # | Old pin (Revision 1, photos) | New pin (Revision 2, board) | Why |
|---|---|---|---|
| 1 | exactly 5 `RoofTier` stacked tiers, terracotta | at least 5 `RoofHip` models on the clubhouse (4 CornerWedge hips each), every `RoofTile` in the same terracotta range | the board draws true hip roofs on every block |
| 2 | 24 mint `WindowTrim` strips | at least 4 `ClubWall` parts, all cream | board walls are cream; no mint trim drawn |
| 3 | 4 `StoneCourse` lines | at least 5 `LoggiaArch` on the front (9 built) | board/elevation: arched loggia, no stone cladding |
| 4 | 12 `CartBody` | `RoundPlanter` at least 40 in front (NW) of the roof cap | board: round planter and drive at the front, no carts. Planter at lx -12 (off the lane-b line: the LocalNPCs Golfer and Caddie stand at lx 1..7, lz 52) |
| 5 | 16 pines, 128 tiers | 6..16 pines (10 built), 8 tiers each; at least 30 `BroadleafTrunk` (70 built) | board woods are broadleaf and dense; trunk height and slenderness pins kept |
| 6 | part count 560..1800 | 900..2450 | entrance and hotel added; the floor was first written as 1400 before the build and corrected to 900 after it (the CSG arcades are one part per bay; 1098 built) |
| 7 | `ClubhouseRoofMain` = main ridge (y 56) | `ClubhouseRoofMain` = the central pavilion finial (y 67.6), the highest part of the clubhouse, plus at least 2 `PavilionWall` | board: higher central pavilion. The sites_check pin (y >= 44, within 15 of C) still holds |
| 8 | (none) | new groups: `entrance` (18 checks), `hotel` (7), porte-cochere hip roof | the board's new features |
Unchanged and passing: kept objects, anchors, palms (17.5+ tall, 8 fronds of 8.5+), label legibility, every sites_check site-8 guard (lanes a-d, keep-clear boxes, window/rail sight-lines). `KEPT` in the check now also lists `LocalNPCs` (rigs, excluded anyway).
**Props moved or dropped:** hole-3 bench (386, 572) -> (404, 600) (out of the west lagoon); pond-B rim boulders (446, 850) and (456, 853), palms (455, 862) and (430, 830) dropped for the hotel and its pool; the carts are gone (row 4).
**Red then green:** before the build site08_check was 25 passed / 31 failed (general 16/1, entrance 2/16, clubhouse 3/6, hotel 2/7, context 10/1); after it, 56/0. sites_check 277/0, BuildCheck site 8 14/0 (1170 parts). Coordinator run twice: 1170 / 1170.
**Known differences from the board:** the clubhouse and the mountain stand left of the gate axis rather than straight ahead (sites_check pins the clubhouse at C facing NW and the peak at x >= 690); Road D arrives end-on, so there is no public road across the front; the drive is the straight terrain asphalt, not the board's curve; the lagoons are rectangular terraces; over the drive the portal is a flat beam with two corner spandrels (the lane guard tests bounding boxes, so no arch part may span the lane); the mountain stays a tiered ridge.

## Revision 3 (owner look, 2026-10-31): mountain, course, planting, lagoons
**Source:** the same board (`Mount Malarayat Golf Resort Blueprint.png`, its 3D view and top-down inset) with `PHOTOS/02_Aerial_and_Site_Layout/04_01` and `11_08` for the course colours. The approved gatehouse, rock sign, clubhouse and hotel are untouched. No terrain writes; slot, pivot and every sites_check guard unchanged.
**Builder:** new module `builders/site08_course.luau` (Structure/Fairways, Ponds, Woods, Grove, Palms; budget 1150), registered in the coordinator with the new containers and two plate helpers, `env.slab` and `env.disc`. A plate's top follows the terrain at a fixed lift: fairway 1.0, tee and bunker 1.15, green 1.3, water 0.95..1.04. That keeps every layer at least 0.8 up (the thin-plate rule) and stops coplanar z-fighting. `site08_context` loses the Woods (moved) and rebuilds the MountainBackdrop. `site08_entrance` rebuilds the lagoons only.

| # | Board | Before (Revision 2) | Now (Revision 3) |
|---|---|---|---|
| 1 | Mount Malarayat: a broad ridge with a main peak behind the clubhouse | 7 stacked green cylinder tiers + 4 blocks along x 728 (32 parts; read as tanks); the tiers buried hole 2's green | 196 WedgeParts (the site09_taal triangle method), a heightfield in the corner behind the clubhouse: foot x + z = 1480, back row on the slot edges, summit about y 124 at (706, 852): straight behind the clubhouse seen from the gate, as far right as the sites_check pin (BackdropPeak x >= 690; its centre is (718, 115.5, 851)) allows, shoulders rising from the left, an east arm (x 734..757, z 566..734) and a north-west arm (z 866..878, x 548..604). Non-colliding, no query, no shadow. `BackdropPeak` = the summit wedge |
| 2 | Fairways and greens on the left half and round the hotel | 3 holes as bare terrain patches, 2 flags | 5 fairways (holes 2-6; slab + 2 end discs each, pale green), 5 putting greens each with a flag (3 new `GreenFlag`), 12 sand bunkers (4 cover the brief's terrain sand), 5 tee boxes |
| 3 | Ponds between the fairways and in front of the hotel | terrain ponds A/B only | 4 `CoursePond` models (E1 between holes 2 and 4, E2 below the plaza, W1 in front of the hotel, W3 beside hole 3), translucent blue water discs lying on the slope, ringed with `PondStone` |
| 4 | Dense tropical planting | 70 broadleaf, 14 palms, 10 pines | 185 broadleaf (183 course + 2 entrance), 36 palms (12 line the drive, 4 its east leg, perimeter rows), 10 pines; every tree through `env.sightClear` and off the course, ponds, buildings, plaza and mountain |
| 5 | Entrance lagoons: water in a rocky edge | 4 level terraces up to 5 above the low ground, 2 falls, weir boulders | per side a capsule of translucent blue water lying 1.0 above the terrain inside a stone kerb ring (14 `LagoonEdge` each), rim boulders and stones in the water; no falls |

**Pins (tests/site08_check.luau):** new groups `mountain` (11), `course` (11), `planting` (6), 3 lagoon pins in `entrance`, and a whole-site 1900..2500 count in `general` (32 new, 56 -> 88). No existing pin was replaced or loosened.
**Pin measurement corrected after the build (logged):** "mountain: every corner inside the slot" first counted all 8 bounding-box corners of each wedge. The two top -Z box corners of a WedgePart are empty space: the big back triangles' empty corners reached z 892 while the solid stays inside x 758.98 / z 878.98. `corners()` now returns a wedge's 6 solid corners. The slack (2 studs) and the slot are unchanged. BuildCheck's own box-corner bounds (+10%) pass.
**Props moved or dropped:**
- Pines: (612,612) (640,606) (664,636) (628,664) (664,684) (688,640) (690,820) (692,870) (600,866) (648,870) became a south-edge row and pairs at the mountain foot: (600,606) (628,604) (656,606) (684,604) (604,664) (690,660) (700,752) (716,738) (600,860) (472,622). They stood on the new fairways and pond, or in the mountain.
- Palms (560,878) and (590,872) are dropped (north-west arm).
- Clumps (612,626) (650,650) (680,620) (690,660) moved to (586,614) (642,598) (712,600) (696,668).
- Bunker boulders moved off the bunker plates: (706,642) (742,610) (382,702) (418,722) (701,606) to (714,650) (732,600) (372,694) (426,728) (698,604).
- The `LagoonFall` parts are gone.

**Red then green:** before the build site08_check was 59 passed / 29 failed (mountain 3/10, course 3/10, planting 2/6, entrance 19/2, general 17/1); after it, 88/0 (general 18, entrance 21, clubhouse 9, hotel 9, context 11, mountain 13, course 13, planting 8, each including the 2 site checks). Coordinator run twice: 2069 / 2069 parts (built 1997, kept 72; MountainBackdrop 196, Fairways 43, Ponds 86, Woods 390, Grove 159, Palms 264, Entrance 269). BuildCheck site 8 14/0. sites_check site-8 guards, npcs_check, guides_check and routes_check all pass.
**Known differences from the board:** the ridge is clipped by the slot (it cannot run on behind the hotel); the summit is a sharper pyramid than the board's massif and stands over the clubhouse's centre-left, not its right half (BackdropPeak x >= 690); fairways are straight capsules with no mowing stripes; ponds and lagoons are discs and capsules, not free-form; the grass under the plates is the terrain's.
