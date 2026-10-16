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
