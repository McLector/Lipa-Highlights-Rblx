# Site 07 brief — The Farm at San Benito

Site row: id 7, key `Farm`, pos (700, 0, 240), facing **W**, footprint 260 x 260 world-aligned (x 570..830, z 110..370), massScale 3.0, **has a JeepStop**, **no interior required**. Required props (direct children of `Site07_Farm`, each holding at least one part): `GardenPavilion`, `LandscapedPath`, `WellnessPanel`.
Proper name: **The Farm at San Benito** (`[VERIFY]` until sourced), Barangay Tipakan per the details md. An operating resort; visits involve bookings or paid services. No photo textures (rights withheld): plain coloured parts; text is SurfaceGui. No brand logos.

## One villa, one pavilion (do not blend photos)
The notes say the villas are different buildings: **select one, never combine rooflines**. Geometry comes from exactly these photos (`Lipa_structure_Exterior_References/06_The_Farm_San_Benito/`):
- **Villa + pool: `Farm_Villa_Pool_Front.jpg` only.** A single villa seen square-on across a long dark-stone pool. A low hipped dark-grey roof with deep eaves over a taller central bay; cream piers; a full-height timber-framed glass front with an open centre showing a dining table and chairs; lower slatted-timber wing screens either side under their own lower roofs; rattan loungers with teal cushions and two blue pots on the terrace; a stone coping, then the pool.
- **Pavilion + lagoon: `Farm_Big_Lagoon_and_Pavilion.jpg` only.** A small round thatched cone on dark posts, on a timber deck that reaches out into a still lagoon from the bank; grass banks, palms behind.
- **Path: `Farm_Landscaped_Pathway.jpg`.** A winding dark pebble path with white fish-scale arc inlays, mossy curbs, lush planting each side.
- **Palette only (no geometry): `Farm_Meditation_Pavilion.jpg`** (a different, larger thatched pavilion beside a narrow pond) and `Farm_Pavilion_Exterior.jpg`.
- **Not used:** `Farm_Villa_Pool_Overhead.jpg` (a kidney pool and terracotta roof) and `Farm_Villa_and_Pool_Vertical_Overhead.jpg` (brown shingle roof, L-shaped pool, timber deck). They show **other villas**; copying their pool shape or roof colour would merge buildings.

## Colours (by eye)
| Element | Colour |
|---|---|
| Villa roofs (central and wings) | slate grey (62, 66, 64) |
| Piers, wall faces | cream (222, 214, 196) |
| Window frames, timber, doors, ceiling | warm brown (140, 84, 50) |
| Glass panes | (150, 190, 190), Glass, 0.55 transparent |
| Wing slat screens | (150, 98, 58) |
| Terrace / villa slab | light stone (200, 194, 182) |
| Pool basin and coping | dark green-grey (58, 78, 74); coping (86, 104, 98) |
| Pool water | teal (46, 150, 142), 0.35 transparent |
| Loungers / cushions / blue pots | rattan (190, 150, 100) / teal (60, 170, 170) / (30, 110, 220) |
| Path base / inlays / curbs | dark pebble (62, 62, 66) / white (200, 196, 188) / mossy (70, 96, 54) |
| Pavilion thatch / posts / deck | straw (128, 104, 62) / dark wood (70, 48, 34) / (96, 64, 44) |
| Palm trunks / fronds / shrubs | (120, 98, 70) / (50, 110, 50) / (36, 84, 44) |

## Frames (important)
The site pivot is yawed to W (`LookVector` = (-1, 0, 0), measured). The builder does **not** use the pivot as its origin.
- `ORIGIN = CFrame.new(700, 0, 240)`, world-aligned.
- `CF = ORIGIN * CFrame.fromMatrix(Vector3.zero, Vector3.new(0, 0, 1), Vector3.new(0, 1, 0), Vector3.new(-1, 0, 0))`: local +Z = W = frontage, local +X = S, so **world = (700 - lz, y, 240 + lx)**.
- A SurfaceGui facing west (the frontage) is on the part's local +Z face = `Enum.NormalId.Back`.
- Terrain top is y = 0. Everything below is given in **world coordinates**; the builder converts.

## Measured at the start of the slice (2026-10-16)
- Guide at (670, ~2.55, 240) facing W (prompt radius 12). InfoPanel (676, 5, 252), 12 x 8 x 0.5, faces W (front = west, zone x 664..676, z 246..258). JeepStop pad (670, 0.2, 220) 10 x 0.4 x 10, JeepSignPole/JeepSign above it, parked Jeepney (670, 3.3, 206), long axis along z (z ~198..214). All are kept as is. **The Jeep ride lands the player at the JeepStop + 5 up, facing W.**
- Road C asphalt: cells z 232..248, ending at **x = 572** (cells 568..572 asphalt; 572..576 grass). The path starts at x 572.

## Ground: paved regions (decided before the build; the worker does NOT touch Terrain)
Terrain under these 4-stud-aligned regions is repainted **Pavement** (a `world_check` probe guards them). Thin parts do not hide grass, so **every thin ground part must lie inside these regions, and every paved cell must be covered by a path, tile or deck part** (bare grey terrain showing is a defect too).

| Region | x | z | Holds |
|---|---|---|---|
| P1 | 572..652 | 232..248 | the entry path from the road |
| P2 | 652..700 | 192..260 | arrival plaza: Guide, InfoPanel, JeepStop, jeepney |
| P3 | 700..796 | 204..276 | east walk, pool, coping, terrace, villa slab |
| P4 | 692..708 | 260..300 | path south to the lagoon |
| P5 | 708..752 | 284..300 | shore apron and the land end of the deck |

**Lagoon:** terrain **Water**, x 700..800, z 300..352, surface flush at y 0 (carved by Sonnet, like the lake). The worker adds **no** terrain, but must not leave any part standing in the water except the deck, its posts and the lagoon-edge stones/reeds.
**Lawns** stay terrain Grass. Do not lay turf parts.

## Layout (world coordinates)
- **LandscapedPath** (container, direct child): P1 x 572..652 and the connections through P2 to P3 and P4/P5. Slab y 0..0.3 dark pebble; white staggered arc/scale inlays (thin bars or flat discs, an approximation of the fish-scale), mossy curbs 1 wide, 1 high, **outside** the lanes. The first slab, x 572..584, is the **`PathStart`** anchor.
- **Arrival plaza** (P2): the Guide / InfoPanel / JeepStop / jeepney **stay**. Pave with the same pebble slab (y 0..0.3) up to but not under them; benches or planters only outside the keep-clear boxes.
- **WellnessPanel** (container, direct child): a free-standing signboard on two posts at x ~704, z 224..236 (12 wide) (**as built: z 204..216**, because at z 224..236 it blocked about half the villa panes from the plaza and road eyes), y 3..9, text face to the **west**, one SurfaceGui TextLabel; the board part is the **`WellnessBoard`** anchor. Text (short, sourced to the details md): "WELLNESS TOURISM. The Farm at San Benito is an operating resort representing Lipa's contemporary wellness tourism: gardens, accommodation, dining and organized activities. Visits involve bookings or paid services."
- **Pool:** water **x 714..744, z 208..272** (30 x 64), a **raised basin**: floor y 0..0.4, rim walls on the north, south and east sides (2 thick, 1.2 high), the **west edge low** (an infinity edge, 0.5 high coping). Water part **`PoolWater`** (one part, y top 1.0, CanCollide false), centre (729, 0.9, 240).
- **Villa** (one building), facing W, on `VillaSlab` x 748..794, z 212..268 (y 0..0.4):
  - Coping strip x 744..748. Terrace x 748..764 with 4 rattan loungers and 2 blue pots (at z ~224 and ~256). Everything on the terrace at least 2 studs outside the sight corridor z 230..250 in height > 3 (loungers sit at z 222..228 and 252..258).
  - **Central bay** x 764..790, z 228..252, walls y 0..12. **Glass front at x 764**: at least 6 panes (each a separate part named **`VillaGlassPane`**, y 1..11), two large panes either side of an open centre (z 236..244) with a timber frame; a dining table and 4 chairs visible behind it. **`VillaBody`** is the back wall: ONE cream part x 786..790, centre (788, 6, 240). Side walls cream, ceiling timber.
  - **Central roof:** a hipped roof, eave y 12.5, deep overhang (eave edge from x 758), peak y <= 18, slate. **`VillaRoof`** is ONE part, the slab or ridge cap of the central roof (centre x 770..785, y >= 13).
  - **Wings** (own lower roofs, **never merged** with the central roof): north z 212..228 and south z 252..268, x 764..786, walls y 0..10, slatted timber screens on the west face, eave y 10.5, slate.
  - Roof overhangs stay inside x 758..796, z 206..274.
- **GardenPavilion** (container, direct child): a **round thatched cone** on 8 dark posts, on a timber deck. Deck **x 728..752, z 292..322** (planks y 0.7..1.0; the part over land is z 292..300, inside P5). Pavilion centre **(740, ., 312)**, diameter ~18, posts 8 tall (eave y 8, human clearance), cone to peak y ~15 built from at least 4 stacked tiers named **`PavilionThatch`**. The deck's main slab is the **`PavilionDeck`** anchor (one part, centre (740, 0.85, 307) or similar). Posts in the water are fine; add a rail of 3 studs.
- **Lagoon edge** (Structure): a few rim stones, reeds (thin cylinders, y <= 4), and a lily-pad or two. Keep >= 8 studs of open water in front of the deck.
- **Planting** (Structure): palms and shrubs. **Palm trunks collide and must stay out of every lane and sight-line.** Palms are allowed only in: z 120..200 (north lawn, any x 580..826); x 800..826 (any z); z 340..368 (any x); x 580..640 with z 255..335; and the villa's rear x 796..826. Shrubs and hedges everywhere else must be <= 3 high. Trunks CanCollide, fronds not.
- **Maximum**: <= 2,500 parts (target 600..900).

## Interior
Not required. Optional: through the glass, a table and chairs and a ceiling fan so the front reads as in the photo.

## Keep clear (existing, kept by the builder; world coordinates)
- **Guide** at (670, ., 240): box **x 658..682, z 228..252, y 0..14** free of built parts.
- **InfoPanel** front zone: **x 664..676, z 246..258, y 0..9** free.
- **JeepStop, jeepney and the ride landing:** **x 658..682, z 190..232, y 0..14** free (the existing JeepStop pad, sign and jeepney are the only things there).
- **Road mouth:** x 572..584 is the path start only; nothing standing within z 228..252 at x < 650.

## Walking lanes (pinned; the guards test them)
Each lane is 4 wide (a 16-wide path cannot fail it on curbs), y 2..9, and fails on any colliding non-rig part of the site. Nothing hangs lower than y 9 over a lane.
- **(a)** x 574..656, z 238..242 (the entry path).
- **(b)** x 684..712, z 238..242 (from the plaza to the pool).
- **(c)** x 698..702, z 262..300 (south to the lagoon).
- **(d)** x 708..728, z 290..294 (to the deck).

## Sight-lines (pinned; the visibility guards ray-cast them)
- From the **Guide-side eye (664, 6, 234)** (offset 6 south of the Guide, which stands at z 238..242): the villa glass (>= 80% of `VillaGlassPane` centres) and the pavilion thatch (>= 80% of `PavilionThatch` centres) must be reached first by a ray. Nothing but low shrubs (<= 3 high) between.
- From the **road-mouth eye (576, 6, 236)**: >= 80% of `VillaGlassPane` centres.
- The Guide, InfoPanel and JeepStop/jeepney parts are ignored by the rays.

## Anchors (one uniquely named BasePart each; no Model/Folder may share these names; searched recursively)
`VillaBody` (centre (788, 6, 240)), `VillaRoof`, `PoolWater` (centre (729, 0.9, 240)), `PavilionDeck`, `PathStart` (x 572..584), `WellnessBoard` (inside `WellnessPanel`). `VillaGlassPane` and `PavilionThatch` are **repeated part names** (the visibility targets), not anchors. Required props are direct children **containers** named exactly `GardenPavilion`, `LandscapedPath`, `WellnessPanel`; everything else goes in a `Structure` Folder (also direct child).

## Approximated
The fish-scale inlay (bars/discs, not arcs); the thatch as stacked cone tiers; the villa's sides and rear; palms as stacked cylinders; the interior; the lagoon's shape (a rectangle); the pool (a rectangle, from the Pool_Front photo, not an overhead); no other villas, no Aqua Sanctuary, no wires or fences.

## Art-observation hooks for dialogue (Slice 12 will source them)
Horizontal layering across the pool: water, coping, terrace, glass, roof; the low hipped roof's deep eaves as shade and shelter; the repeating slat screens as rhythm; the round thatched cone against the rectilinear villa (contrast of form); the path's scale pattern leading the eye (line and pattern); reflection and stillness in the lagoon (balance, calm).
