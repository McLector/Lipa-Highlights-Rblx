# Site 04 brief — Café de Lipa (Tibig/STAR branch)

> **Slice 14 relocation (read first).** The town core was crowded (10-20 studs between this site and the Cathedral compound), so the user had the Cafe de Lipa moved: **(160, -160) -> (272, -160)** (dx +112, z unchanged), a clear gap of about 100+ studs. Every world coordinate in this brief is the ORIGINAL one; add +112 to x to get the current position. The builder follows the site pivot (see the header comment in builders/site04.luau). Terrain: road H now runs along z -160 from Road A (x 0) to x 224, and the paving region moved (x 112..212 -> x 224..324); both live in builders/world.luau and tests/world_check.luau. structure_model_positioning.png is not edited: this is a documented deviation from it.

Site row: id 4, key `Cafe`, pos (160, 0, -160), facing W, footprint 100 x 80 world-aligned (x 110..210, z -200..-120; paved region x 112..212, z -200..-120), massScale 3.5, **no JeepStop**. Required props (direct children of `Site04_Cafe`, each holding at least one part): `CoffeeBar`, `BarakoBeans`, `CoffeePacks`, `BrewingSet`. **The interior is required, walkable and labelled representative** (Café de Lipa and Lomi King are the only interiors).
Proper name: **Café de Lipa** (`[VERIFY]` until sourced); the signage reads lowercase **"cafedelipa"**. **Tibig/STAR branch only. Never merged with the unconfirmed branches.** No photo textures (rights withheld): plain coloured parts; signage is Neon 3-D letters or SurfaceGui text. Brand names appear only as text signage. Generic "BARAKO" packs only; no real packaging.

## Reference photos
Exactly **one** photo is of this branch, so the "3-5 photos" target cannot be met:
- `Lipa_structure_Exterior_References/02_Cafe_de_Lipa/Cafe_de_Lipa_Tibig_STAR_Entrance_and_Outdoor_Seating_Night.jpg` (tripadvisor.com.ph). **The only geometry source.** It is a **night** shot.

**Excluded from geometry** (branch/date unconfirmed; the notes say never combine): `Cafe_de_Lipa_Streetfront_Branch_Unconfirmed.jpg` (mauve block, cafe-1740.menufyy.com) and `Cafe_de_Lipa_Streetfront_Oblique_Branch_Unconfirmed.jpg` (orange gabled front, thepoortraveler.net, 2012). Do not copy their colours, gable, signs or steps.

What the photo shows: a **dark charcoal fascia band** carrying lit **yellow lowercase "cafedelipa"** letters; a **full-height glass storefront** with dark mullions and tall vertical bar door handles; a **white arcade soffit** with round recessed downlights, running on to the right (south) past the unit to a plain dark neighbour bay; **outdoor seating under the arcade** (round and rectangular wood tables, **red** and dark-wood slat chairs); a light square-tile terrace floor; inside, a **checkerboard floor**, a **wood coffee bar** with an espresso machine on the left, **warm globe / cage pendants**, long wood tables.

Because the photo is a night view and the scene is ClockTime 15.5 (the worker may not touch Lighting), recognizability must come from the **Neon yellow letters, warm glowing glass and the dark fascia contrast**: Neon sign letters, a warm PointLight in each interior pendant and a few downlights. **Sign-off compares composition and palette, not exposure.**

## Colours (by eye)
| Element | Colour |
|---|---|
| Fascia band, columns, back wall | charcoal (48, 42, 46) |
| Sign letters | Neon yellow (255, 226, 70) |
| Arcade soffit | white (236, 232, 226); downlights Neon (255, 240, 200) |
| Glass | (170, 200, 210), Glass, 0.6 transparent; mullions / frames (30, 30, 34) |
| Terrace tile | light (226, 224, 216) |
| Interior checkerboard | (222, 218, 208) and (60, 56, 54) |
| Coffee bar | wood (176, 120, 70), top darker (110, 70, 40) |
| Tables | wood top (170, 125, 75), dark legs (50, 38, 32) |
| Chairs | red (200, 48, 36) and dark wood (58, 44, 36) |
| Pendants | warm (255, 220, 150) globes, copper (184, 115, 51) cages |

## Frames (important)
The site pivot is yawed to W (`LookVector` = (-1, 0, 0), measured). The builder does **not** use the pivot as its origin.
- `ORIGIN = CFrame.new(pivot position)`, world-aligned, pivot = (160, 0, -160).
- `CF = ORIGIN * CFrame.fromMatrix(Vector3.zero, Vector3.new(0, 0, 1), Vector3.new(0, 1, 0), Vector3.new(-1, 0, 0))`: local +Z = W = frontage, local +X = S, so world = (160 - lz, y, -160 + lx).
- A SurfaceGui facing the frontage (west) is on the part's local +Z face = `Enum.NormalId.Back`.
- Terrain top is y = 0 (Pavement under the whole region).

## Measured at the start of the slice (2026-10-16)
- Guide: HumanoidRootPart-centred model at (130, ~2.5, -160), facing W; its prompt radius is 12.
- InfoPanel: a single part at (136, 5.0, -148), size 12 x 8 x 0.5, **faces W** (LookVector (-1, 0, 0)), the 12-stud side along z (z -154..-142), SurfaceGui on its Front face. Kept as is.
- Road H asphalt: cells x 96..112, z -164..-156 (the mouth ends at x = 112, not 110). Grass everywhere else near the site.

## Layout (world coordinates; the builder works in `CF`)
- **Arcade / terrace**: x 144..164, z -188..-128. Roof slab `ArcadeRoof` (white soffit underside at y 13, 1 thick) over x 144..164, z -188..-128; slim charcoal columns on its west edge (x 144.5) at z -186, -176, -146, -136 and -130, **none in the lane**. Terrace floor tile x 144..164, z -188..-128, 0.2 thick.
- **Unit**: x 164..204, z -186..-134. Glass front at x 164, y 0..12, **door opening z -165..-155 (10 wide), header at y 10 or higher** (door height >= 8), the rest glass panes with dark mullions and two tall bar handles at the door. Side walls at z -186 and -134, back wall x 202..204 (charcoal), checkerboard floor slab x 164..204, z -186..-134, 0.2 thick, ceiling y 12.
- **`SignFascia`**: ONE charcoal part x 163..165, y 12..18, z -186..-134 (centre (164, 15, -160)), carrying the Neon letters "cafedelipa" on its west face (letters stand out about 0.6 stud).
- **`CafeBody`**: ONE charcoal part, the roof / upper mass over the unit, x 164..204, z -186..-134, y 12..17, **centre (184, 14.5, -160)**. NOT a ground-floor block: the ground floor is separate walls, so the interior stays hollow.
- **Optional neighbour bay**: a plain dark wall bay x 164..204, z -134..-122 (south of the unit, as the photo hints), kept to a handful of parts.
- **Terrace tables**: 8, at x 150 and 158, z -180, -172, -148, -140, each 2.4 x 2.4 (round or square), 2-3 chairs each (red and dark wood alternate). **None in the lane.**
- **Hedge / planters**: optional, only outside the lane and at x >= 144.

## Interior plan (walkable, human scale)
- **The lane (pinned; the guard tests it):** centreline **z = -160**, lane z -164..-156 from the terrace through the door to the coffee bar. The **guard sweeps a 41 x 6 x 4 box (x 144..185, y 2..8, z -162..-158)** (4 wide, so the 10-wide door cannot fail it) and fails on any colliding non-rig part of the site. Nothing hangs lower than y 9 over the lane (x 144..185). Only rigs may stand in it. Tables, chairs and columns stay at least 2 studs outside the lane (z <= -167 or z >= -153).
- **Coffee bar** (`CoffeeBar` folder; anchor part **`BarTop`**, centre x about 193): x 190..196, z -182..-138, **top at y 3.5**, front face at x 190 (the lane ends there). The espresso machine, grinder, register and cups on it.
- **Back shelves** (x 198..202): `CoffeePacks` (rows of generic "BARAKO" packs on shelves, 12-20 packs), `BarakoBeans` (burlap bean sacks and glass jars, 6-10), `BrewingSet` (pour-over stand, French press, kettle, cups, 6+ items).
- **Interior tables** (`Tables` folder, shared with the terrace): 4 wood tables at x 172 and 180, z -178 and -142, 2-3 chairs each; a long communal table along the north wall optional.
- **Pendants** (`Pendants` folder): 8-12 warm globes / cage pendants at y 9.5..12 inside (each with a warm PointLight) plus the downlights in the arcade soffit (Neon discs, 6-8).
- **Staff** (`Staff` folder, direct child): 2 idle R15 rigs (a barista behind the bar at about (199, 0, -160), plus a customer seated on the terrace outside the lane), built **exactly like `builders/site01.luau` `buildPeople`** as in `builders/site03.luau` (HumanoidDescription colours, `Players:CreateHumanoidModelFromDescription`, all parts unanchored first, `HumanoidRootPart` anchored last, `DisplayDistanceType.None`, `WalkSpeed 0`, `ModelStreamingMode.Atomic`, attribute `SiteId = 4`, names `Staff1`..). `CreateHumanoidModelFromDescription` yields, so the people get their own chunk before the swap.
- **`RepresentativeSign`**: ONE part on the back wall, x 201.5..202, centre (201.75, 9.5, -160), size 2.5 x 12 on its face; SurfaceGui text on the `Back` face: "INTERIOR SHOWN IS REPRESENTATIVE". Visible down the lane.

## Anchors (one uniquely named BasePart each; no Model/Folder may share these names)
`CafeBody` (centre (184, 14.5, -160)), `SignFascia` (centre (164, 15, -160), at least 10 west of `CafeBody`), `ArcadeRoof` (centre about (154, 13.5, -158), west of `SignFascia`), `BarTop` (centre x about 193, more than 15 east of `SignFascia`), `RepresentativeSign` (inside the body bounds: x 164..204, z -186..-134). The guards use these exact names.

## Keep clear (existing, kept by the builder; world coordinates)
- **Guide** at (130, 0, -160), facing W. Box **x 118..142, z -172..-148, y 0..14** free of built parts.
- **InfoPanel** at (136, 5, -148): its front (west) side stays open: **x 124..136, z -154..-142** (12 deep, the panel's width). Nothing built through it.
- **Road H walkway**: x 112..124, z -172..-148, free of props. **Nothing is built at x < 143.**
- **The lane** as pinned above. The final step queries exact-size `OverlapParams` boxes (positive controls included) for the Guide volume, the InfoPanel front zone and the lane.

## Ground (decided before the build; the worker does NOT touch Terrain)
Terrain under **x 112..212, z -200..-120** is repainted Pavement (the Café paving probe in `world_check`; road H's asphalt, x <= 112, is untouched). Thin parts do not hide grass, so **every thin ground part (terrace tile, floor slab, ground paint) must lie inside x 112..212, z -200..-120.**

## Approximated
Sides, rear and roof (flat); the neighbour bays; the number and position of tables and chairs (representative); the interior layout (**the Café's interior photos are not of this branch**, so the whole interior is representative and the sign says so); no wires, no neighbouring buildings, no street.

## Art-observation hooks for dialogue (Slice 12 will source them)
A glass front that lets warm interior light spill onto the outdoor seating; the dark fascia band against the glowing yellow letters (contrast and emphasis); the strong horizontal of the fascia and arcade soffit; repeated red chairs as rhythm against the dark wood; inside/outside continuity.
