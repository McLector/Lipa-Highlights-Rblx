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

## Revision 1 (Slice 20): fidelity rework from `Farm_Villa_Pool_Front.jpg` and `Farm_Big_Lagoon_and_Pavilion.jpg`
**References:** the same two photos the brief already names; no new photo, no credit change. The builder uses world coordinates (no Slice 14 shift). `tests/site07_check.luau` encodes the table below.

| # | Real | Before | Now |
|---|---|---|---|
| 1 | Dark teal-green pool | bright cyan water (46,150,142), 0.35 transparent | (24,98,94), 0.2 transparent |
| 2 | Pool wall of laid stone blocks | plain wall | 12 `CopingJoint` strips on the east wall |
| 3 | Round shaggy thatched hat on posts | six coarse tiers | 12 fine tiers on a convex profile (18 down to about 1.9) + `PavilionFinial` |
| 4 | Tall palms, large drooping fronds | 12 high, 6 fronds of 6.5 | 16/18/20 high, 8 fronds of 9.5 |
| 5 | Wings sit between timber posts under the eave | bare slats | 6 `WingPost` (3 per wing) |
| 6 | (model bug) | `WellnessBoard` 213 characters TextScaled (tiny type) | fixed 18 px wrapped text |

**Guard changed on purpose (sites_check, Site 7):** the thatch sight-line ray was aimed at each tier's axis centre, which cannot see the upper tiers of a fine cone from a low eye (9 of 12). It now aims at each tier's near-side edge, the surface a player sees. The guard still needs 80% of the tiers visible; 12 of 12 pass.

# Revision 2 (Standard tier, 2026-10-31): rebuilt from the San Benito board - supersedes the layout above where they differ

Source: `..\2nd Reference\the_farm_san_benito\San_benito_blueprint.png` (main 3-D view, insets A site plan, B Narra pool villas, C Acqua Hydrotherapy, D Big Lagoon and pavilion, E Temple of Five Elements and garden), plan `scratch/standard_tier_plan.md` "07 Farm". Owner decisions: slot about 400 x 320 at (770,240); not to scale, the board's relative layout kept, buildings at human scale; PARTS ONLY (no terrain writes; rivers and lagoons are parts flush with the ground); split into modules. The board's north is world north (-Z).

## Slot and data
`SiteData` row 7: pos (770, 0, 240), facing W, size 400 x 320 (x 570..970, z 80..400; the west edge stays at Road C's end), `guideLocal` (100, 0) and `panelLocal` (94, -12): the Guide (670,240), InfoPanel (676,252) and JeepStop (670,220) keep their world positions (measured before the edit). No `jeepLocal`: the default (Guide + 20 to the right) already gives (670,220), and a `jeepLocal` would switch sites_check to its "own curb, 40-90 studs" branch. The site pivot was written to (770,0,240) facing W in the same step as the data edit (a property write). `docs/footprints.md` row 7 updated. NPCs (`builders/npcs.luau` [7]): YogaGuest (736,300) -> (756,206) on the round pavilion's floor (seat 1.15 unchanged), FarmStaff (726,293) -> (745,214) on the plaza beside it; `npcs({only={7}})` run.

## Model (coordinator `builders/site07.luau`, site05 pattern; world coordinates; KEEP Guide, InfoPanel, JeepStop, JeepSignPole, JeepSign, Jeepney, LocalNPCs)
| Module | Containers | Board zone, as built (world) |
|---|---|---|
| `site07_entrance` (257) | Structure/River, Entrance, Banaba, Parking | river ring: 60 chords, water 14 wide on the ellipse a 189, b 147 (water a 182..196, b 140..154), y -0.38..0.12, mud bank 18 wide; bridge x 571..595, z 232..248 (deck top 0.7, parapets 3 high); gate piers x 610..614 at z 225..230 / 250..255, beam y 10..11.5, hip roof; guard post x 618..628, z 214..224 (door 8.2); Banaba court x 694..806, z 292..360 (y -0.5..0.35, covers the old terrain lagoon and its smoothed edge), hall x 714..790, z 314..344, 19 high, 3 brown hip roofs + entrance canopy; parking x 652..698, z 300..340, drive x 648..656, z 260..300, 18 bay lines, 6 cars |
| `site07_water` (109) | Structure/BigLagoon, Acqua, FrontOffice | Big Lagoon: 5 water discs x 720..799, z 130..195, sand rim, rocks; hip-roofed two-tier pavilion on a deck x 776..794, z 168..186, rails 3 high, boardwalk to the plaza; Acqua deck x 606..648, z 254..296, 5 pools (PoolWater x 614..630, z 262..278), 2 cabanas, loungers; Front Office x 848..882, z 236..262 with porch; its lagoon (906,246)+(922,258) |
| `site07_villas` (150) | GardenPavilion, Structure/GlassVilla, NarraVillas, Amphitheater | round thatched pavilion (756,206): floor dia 16 top 1.0, 8 posts, 12 thatch tiers (Slice 20 profile), finial; glass villa x 780..808, z 220..252, 8 VillaGlassPane on x 780, VillaBody = back wall x 806..808, brown hip roof eave 12; Narra villas at (821,124), (851,134), (880,150) with pools south; amphitheater (744,248): stage dia 12, 4 octagonal tiers r 9..21, top 3.45, aisle WSW |
| `site07_halls` (90) | Structure/Temple, Sanctuary | temple plinth x 682..698, z 128..144, two-tier hip roof; labyrinth (690,166): 8 rings dia 34..6, fountain, hedge ring open south; Sanctuary x 830..910, z 288..308, 19 high, 3 brown hip roofs, veranda on 8 columns |
| `site07_grounds` (1379) | LandscapedPath/Entry, Plaza, Walks; WellnessPanel; Structure/PalmsA, PalmsB, PalmsC, Trees | PathStart x 595..607, entry path to x 652 (pebble, white chevrons, mossy curbs), arrival plaza x 652..700, z 192..260 (bare only under the Guide and the jeep pad), central plaza x 700..800, z 200..280, south walk, 9 winding walks; Wellness board x 702..704, z 194..206 (text unchanged, fixed 18 px, west face); 120 palms (8 parts), 72 trees, 90 shrubs on a hashed grid, kept out of zones, walks, the river band and the sight-line corridors |

## Tests first
Red (old 723-part model, before the data edit): site07_check 38/52; sites_check 276/1 (the replaced deck pin); unit suite 282 run, 3 failed (2 Farm cases + the Outlets agent's row 6 case). Green: site07_check 91/0 (91 checks: the bridge group has one check more once the bridge exists), sites_check 277/0, unit 282/0.

| Old pin | Replaced by (board) |
|---|---|
| site07_check: pivot at (700,0,240) facing W | (770,0,240) facing W |
| site07_check: pool water dark teal (r <= 40, g <= 115, b <= 112) | PoolWater is the board's pool blue (b >= 140, b > r + 60, g >= 100); transparency 0.05..0.3 (was <= 0.3) |
| site07_check: >= 10 CopingJoint | >= 4 AcquaCoping |
| site07_check: 19 palms | >= 60 palms |
| site07_check: 8 fronds per palm (152) | 6 fronds per palm |
| site07_check: 6 WingPost; posts ground to eave on the screen line | VillaRoof is brown; its eave >= 11 |
| site07_check: part count 600..1500 | 1700..2400 built, whole site <= 2500 |
| sites_check: pavilion deck south of the pool (deck.Z > pool.Z + 30) | pavilion deck north-west of VillaBody (Z < body.Z - 15, X < body.X), within 70 |
| SiteData_Test: [7] = (700, 240, W) | (770, 240, W); the "rows 3 to 9" loop skips row 7 (its literal guidePos(7) = (670,0,240) pin kept) |

Kept and still passing: kept objects, required props, the six anchors, the 12-tier cone (5 checks) and finial, palms >= 15.5 tall, fronds >= 8.5 and not colliding, label legibility; in sites_check the glass-on-west, roof-above-glass, pool-west-of-villa, path-start and Wellness-board pins, the four lanes, the three keep-clear boxes and the three sight-lines. New: board pins in groups general, entrance, south, centre, north, east, planting, ground (river ring and flushness, bridge, gate, guard post, Banaba, parking, Acqua, the look-at group, amphitheater, lagoon and pavilion, temple and labyrinth, Narra row, Front Office and lagoon, Sanctuary, planting, every old Pavement and Water cell covered). SiteData_Test: one new case (row 7 slot and the three world positions).

## Board vs model
| Item | Result |
|---|---|
| Oval ringed by the North and South rivers | MATCH (a ring of parts; the oval is 1.3:1, the board's about 2.2:1: the slot's proportion) |
| Main entrance, guard post and bridge | DIFF: at the west tip, where Road C arrives; the board draws them mid-south |
| Banaba hall and parking beside the entrance on the South river | MATCH in the south-west; DIFF: the parking lies west of the hall (between the hall and the Acqua pools), not between the hall and the gate |
| Front Office and lagoon (E), Holistic Medical Sanctuary (SE) | MATCH |
| Big Lagoon (N centre) with its hip-roofed pavilion | MATCH |
| Amphitheater (centre); round thatched hut beside a villa just north of it | MATCH |
| Temple of Five Elements with the labyrinth garden (NW) | MATCH; temple north of the rings as in inset E |
| Narra pool villas | MATCH: a row of 3 along the North river, NE |
| Acqua Hydrotherapy pools and cabanas | MATCH (W) |
| Dense palms | MATCH at the edges; DIFF: the centre is paved plaza and lawn, sparser than the board |
| Other zones (Garden Glass, Acacia, Mahogany, Isla Royale, restaurants, gym, South Pool and others) | not built (plan) |
| River surface | DIFF: terrain grass blades poke through the flush river parts in places (terrain decoration; no terrain or setting change allowed) |

## Text
No line changed. "Look at the round thatched pavilion beside the straight-edged villa ... Then follow the patterned path." stays true: the GardenPavilion stands beside the glass villa, both east of the Guide, with the chevron path at the Guide's feet (`scratch/site07/shots/guide_lookat.jpg`). The Wellness board words are unchanged. No entrance lettering or zone labels were built (pinned: the only built text is the Wellness board).

## Verification
Coordinator run twice: 2052 and 2052 parts (built 1985, kept 67; entrance 257, water 109, villas 150, halls 90, grounds 1379; largest containers PalmsA and PalmsB 360). BuildCheck 07 14/0 (2052). site07_check 91/0, sites_check 277/0, npcs_check 237/0, guides_check 123/0, routes_check 16/0, roads_check 281/0, qa_check 116/0, placeholders_check 32/0, unit 282/0. checkWorld FAILS: 21275 parts against the 20,000 cap (all sites together; the Farm adds 1329).
Shots: `scratch/site07/shots/front_oblique.jpg`, `board_view.jpg`, `top_down.jpg`, `guide_lookat.jpg`, `wellness_board.jpg`.

## Tidy pass (owner's look, 2026-10-31)
Rivers, lagoons and pools raised so every water top is at y 1.05..1.45 (grass blades render to about y 0.9); the river and lagoons are one opaque SmoothPlastic deep blue-teal (28,104,142), no Glass seams; grassy banks; bridge deck top 1.7 with ramps; pavilion deck, boardwalk, Acqua and Narra decks raised to match. The central plaza and the Banaba court became lawn (Grass parts, terrain colour) with 5-wide walks, a small forecourt and a walk at the hall; the arrival area is a patterned band plus a jeep apron. 9 small brown hip-roof villas (3 north, 4 west, 2 south-west with pools). Planting 100 palms (wider fronds) and 256 broadleaf trees (crowns 17..23, not colliding), no shrubs.
Pins first, red 88/8: REPLACED river top 0..0.3 -> 0.95..1.4; lagoon top 0..0.3 -> 0.95..1.4; bridge deck top <= 1.2 -> 1.3..2.0 with 2 ramps. NEW: opaque one-colour river; 8+ small villas; canopy >= 30% of the land from above (was 9.3%); paved ground <= 15% (was 29.3%); every water top >= 0.95. Green: site07_check 96/0, sites_check 277/0, npcs_check 237/0, guides_check 123/0, routes_check 16/0, BuildCheck 07 14/0; builder twice 2430 / 2430 (built 2363, kept 67). Shot scratch/site07/shots/board_view_tidy.jpg.

# Revision 3 (session 062, owner: "the west half is still open; make it denser so it matches the board")
Parts are redistributed, not added. The 49 palms outside the river ring are now broadleaf trees (3 parts each instead of 8), and the palm total went from 100 to 62 (the pin is >= 60). Planting fills tiers in order: the west land (x < 770) first (trees, then palms in the gaps; a palm may stand 9 x 8 from a villa that has no pool), then the east land, then the forest beyond the river. West crowns are 22..24 across. Each trunk stays a crown radius plus one away from the sites_check keep-clear boxes (`LAYOUT.keepClear`). The occupied boxes for the entry and the temple were cut down to the real footprints.
New in the west:
- 8 small villas: Garden Glass at (708,122) and (727,114); Acacia at (664,158); Mahogany Luxury at (600,222) and (648,216); Sulu Terraces at (714,281), (731,281) and (748,281).
- The Pure Energy Gym (`Structure/Gym`, x 664..688, z 272..288, brown hip roof, door 8.4).
- Walks: A (the north-west loop to the temple), F (along the Sulu row) and G (to the gym).
- 14 low hedges (2.4 high) in the corridor lawns.

Pins: one new group, `west`, with 11 checks. It ran red at 100/9. The canopy threshold was set to 13% (written as 14% at first) from a feasibility sim before the build, not after. Green: 109/0. Every old pin is unchanged.
Measured: west canopy 11.0 -> 13.2%; anything above y 1.6 in the west 25.1 -> 32.4%; west trunks 26 -> 34; east canopy 49.2 -> 49.1%; whole-land canopy 31.6%; paved 14.0% (pin <= 15). Builder ran twice: 2372 / 2372 (built 2305, kept 67; it was 2430). Ground step: 184 columns repainted on the first run, 0 on the second.
DIFF against the board: the west is still sparser than the east. The binding limit is space, not parts. The pinned sight-line corridors (Guide eye and road-mouth eye to the villa glass and the thatch, plus a 12-stud crown margin), the keep-clear boxes, the arrival plaza, the parking and Acqua cover most of the west land, so tall planting has almost nowhere left to go. Getting closer to the board needs an owner call, for example: allow palms inside the corridor margins (their fronds sit above the y-6 rays), move the entrance mid-south as the board draws it, or shrink the arrival plaza.
Shots: `scratch/site07/shots/board_view_062.jpg` (camera (770,300,540) looking at (770,0,225)), `top_down_062.jpg` (camera (770,330,241) looking at (770,0,240)).
