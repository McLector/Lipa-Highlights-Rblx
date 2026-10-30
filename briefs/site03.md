# Site 03 brief — Lomi King

> **Slice 14 relocation (read first).** The town core was crowded (10-20 studs between this site and the Cathedral compound), so the user had the Lomi King moved: **(180, 140) -> (292, 140)** (dx +112, z unchanged), a clear gap of about 100+ studs. Every world coordinate in this brief is the ORIGINAL one; add +112 to x to get the current position. The builder follows the site pivot (see the header comment in builders/site03.luau). Terrain: road G now runs along z 140 from Road E (x 0) to x 240, and the paving region moved (x 128..228 -> x 240..340); both live in builders/world.luau and tests/world_check.luau. structure_model_positioning.png is not edited: this is a documented deviation from it.

Site row: id 3, key `Lomi`, pos (180, 0, 140), facing W, footprint 100 x 80 world-aligned (x 130..230, z 100..180; paved region x 128..228, z 100..180), massScale 3.5, **no JeepStop**. Required props (direct children of `Site03_Lomi`, each holding at least one part): `Counter`, `Tables`, `LomiBowls`, `Menu`, `Utensils`. **The interior is required and must be walkable** (Lomi King and the Café de Lipa are the only interiors).
Proper name: **Lomi King** (`[VERIFY]` until sourced). **The only photo is from 2015** (`Lomi_King_Front_Oblique_2015.jpg`, source primer.com.ph); it is a dated reference, not confirmation of today's facade. The dialogue must say so (Slice 12). Side, rear and aerial views do not exist, so sides, rear and the upper storeys' interiors are approximated. No photo textures (rights withheld): plain coloured parts, signage is SurfaceGui text. Brand names appear only as text signage ("LOMI KING"); the phone number, the "KOPI VINZ" sub-brand, wires and the neighbour building are NOT reproduced.

## Requirement source (`modern_lipa_highlights_wt_details.md`)
"A lomihan counter, bowl of lomi, menu, utensils, and dining scene." Mapped to `Counter`, `LomiBowls`, `Menu`, `Utensils` and `Tables` (+ a `Diners` folder for the dining scene). Message: lomi is part of Lipa's food culture; eating together is social.

## Frames (important)
The site pivot is yawed to W (LookVector = (-1, 0, 0)). The builder does **not** use the pivot as its origin.
- `ORIGIN = CFrame.new(pivot position)`: world-aligned, +X east, +Z south. Pivot = (180, 0, 140).
- `LK = ORIGIN * CFrame.fromMatrix(Vector3.zero, Vector3.new(0, 0, 1), Vector3.new(0, 1, 0), Vector3.new(-1, 0, 0))`: the Lomi frame. **Local +Z = W = frontage / outward, local +X = S (+Z world) = the viewer's right facing the shop**, local +Y up. World = (180 - lz, y, 140 + lx).
- A SurfaceGui facing the frontage (west) is on the part's local +Z face = `Enum.NormalId.Back`.
- Terrain top is y = 0 (Pavement under the whole region); everything sits on y = 0.

## Reference photo (the only one)
`Lipa_structure_Exterior_References/01_Lomi_Houses/Lomi_King_Front_Oblique_2015.jpg`: a salmon/coral-pink **3-storey block** seen obliquely from the street; a deep **orange box awning** across the ground floor with 3-D "LOMI KING" letters standing on top; a **full-width menu banner** under the awning (dishes, specials); an **open dining front** (no wall) with dark wood tables and chairs and **globe pendant lamps**; two **topiary shrubs in terracotta pots** flanking it; a **round red "LOMI KING" bowl-logo sign** on a bracket high on the wall; on the right (south) a **closed bay** with a bamboo-screen panel, a small ramen poster and a white "Parking for LOMI KING CUSTOMERS Only" sign; a rounded (bay-window) element on the second floor; a tiled front step.

## Colours (by eye)
| Element | Colour |
|---|---|
| Wall pink/salmon | (232, 130, 112); darker side wall (214, 112, 96) |
| Awning / fascia orange | (226, 120, 30) |
| Letters | cream-grey (200, 196, 184) with blue-grey accents (110, 140, 170) |
| Menu banner | warm yellow-orange (240, 170, 50) with red and white blocks; text via SurfaceGui |
| Logo sign | red (200, 30, 40), cream bowl |
| Bamboo panel | tan (200, 170, 120) |
| Parking sign | white (240, 240, 236), red text (200, 30, 40) |
| Window glass | (60, 76, 88), Glass, 0.3 transparent; dark frames (40, 42, 48) |
| Furniture wood | dark (84, 56, 40) |
| Floor tile | grey-beige (170, 164, 150) |
| Pots | terracotta (190, 100, 60); foliage green (60, 130, 50) |
| Globe lamps | warm white (255, 236, 190), Neon or SmoothPlastic |

## Layout (world coordinates; the builder works in `LK`)
- Building footprint **x 172..216, z 114..166**. Ground storey height **14** (human scale never shrinks), upper storeys to a parapet at about y 44.
- **Open dining front**: the west face (x = 172) between z 116 and z 150 has NO wall; only slim columns at z 116, 126 and 150 (and the corners). The south **closed bay** is z 150..166 (pink wall with the bamboo panel, ramen poster and parking sign on its west face).
- **Awning**: x 162..172, y 12..16, the `AwningFascia` part (orange, with the 3-D letters on top and a SurfaceGui "LOMI KING"), spanning z 114..166. Menu banner hangs below it to **y 9** (nothing lower than y 9 above the walking lane).
- **Front step**: x 162..172, top at y = 1 (a 1-high tiled step; ramp/stair parts not needed).
- **Driveway strip**: x 172..216, z 168..178 south of the building (painted lines / a parked tricycle are optional).
- **Pots + topiary**: at (166, z 122) and (166, z 148). They must stay out of the aisle.
- **Upper storeys**: `LomiBody`, ONE pink part, **x 172..216, z 114..166, y 14..44, centre (194, 29, 140)**: the upper mass sitting on the ground-floor columns and walls. It is NOT the ground-floor block: the ground floor is built from separate walls (rear x 214..216, north z 114..116, the closed bay) so the open front and the interior stay hollow. Upper storeys get window cut-outs as dark glass plates, one rounded bay element on the second floor (a cylinder), and the round red logo sign on a bracket at about y 30 on the west face. No interior is built above y 14.

## Interior plan (walkable, human scale)
- Floor: a tile slab 0.2 thick, x 172..216, z 116..150 (inside the paved region).
- **The aisle (pinned; the guard tests it):** the centreline is **z = 140**; the lane z 136..144 (8 wide) from the forecourt through the open front to the counter is **free of every colliding part** between x 160 and x 202, from y 2 to y 8. Nothing may hang lower than y 9 over it. Only rigs (a diner) may stand in it. Tables, chairs, columns, pots and the step (top y 1) stay outside it.
- **Counter** (`Counter` folder; anchor part `CounterTop`): the back counter at x 203..208, spanning z 120..160 (the aisle ends at its front face, x 203), **top at y 3.5**, with a pot, bowl stacks (`LomiBowls` may hold the stacks), a register and a menu board on the back wall (`Menu`: also the menu banner and a framed menu on a table). A small kitchen pass-through at z 150..160 into the closed bay.
- **Tables** (`Tables`): 6 tables, tops at y 3 (2.6 x 2.6 or 2.4 x 4), each with 2–4 chairs (seat y 2, back to 4). Two rows, north of the aisle (z 118..132) and south of it (z 146..150 only, between aisle and the closed bay) are tight, so use: **north block z 118..132: 4 tables** at x 178, 186, 194, 200; **south block z 146..150: 2 two-seat tables** against the bay wall at x 180, 192. Tables clear the aisle by at least 2.
- **LomiBowls**: bowls (cylinders, cream/orange with a darker soup disk and noodle/egg/meat bits) on tables and the counter, 8–12 bowls.
- **Utensils**: spoons, forks, chopsticks (thin parts) beside bowls and in condiment caddies (soy, vinegar, chilli).
- **Globe pendants** at y 10..13 inside (outside the aisle's y 2..8 box is fine; keep y ≥ 9 anyway) and a row under the awning.
- **Diners** (folder, direct child of the site): 3 idle R15 rigs (a cook behind the counter, two diners seated or standing at the north tables), built **exactly like `builders/site01.luau` `buildPeople`** (HumanoidDescription colours, `Players:CreateHumanoidModelFromDescription`, all parts unanchored first, `HumanoidRootPart` anchored last, `DisplayDistanceType.None`, `WalkSpeed 0`, `ModelStreamingMode.Atomic`, attribute `SiteId = 3`, names `Diner1`..). `CreateHumanoidModelFromDescription` yields, so build the people in their own chunk before the swap, as site01 does. `NpcIdle` plays the idle animation at runtime. No rig may stand in the lane at rest (a seated rig at x ≥ 178 outside z 136..144 is fine).
- Signage on the awning/fascia and menu banner uses SurfaceGui text on Back faces; the menu text is generic ("LOMI", "PANCIT", "RICE MEALS", "SANDWICHES", "COFFEE"); prices are not shown.

## Anchors (one uniquely named BasePart each; no Model/Folder may share these names)
`LomiBody` (centre (194, 29, 140)), `AwningFascia` (west of the body by at least 10; centre x about 166), `CounterTop` (x about 205, east of the awning by more than 15), `ParkingSign` (on the south bay's west face, z about 158, at least 10 south of LomiBody's centre z 140). The guards use these exact names.

## Keep clear (existing, kept by the builder; world coordinates)
- **Guide** at (150, 0, 140), facing W. Keep a box **x 138..162, z 128..152, y 0..14** free of built parts. (Its prompt radius is 12.) The step (x 162..172) is just outside it.
- **InfoPanel** at about (156, 5, 152), a 12 x 8 board facing W: keep its front (west) side open, 12 studs deep (x 144..156, z 146..158); nothing built through it.
- **Road G walkway**: x 128..138, z 100..152, kept free of props so players can walk from the road mouth to the Guide and the front step.
- **The aisle** as pinned above.
- Nothing may overlap `Guide` or `InfoPanel`. The final step queries exact-size `OverlapParams` boxes (positive controls included) for the Guide volume, the InfoPanel front zone and the aisle.

## Ground (decided before the build; the worker does NOT touch Terrain)
Terrain under **x 128..228, z 100..180** is repainted Pavement (the Lomi paving probe in `world_check`; road G's asphalt at x 120..128 is untouched). Thin parts do not hide grass, and anything thin at ground level OUTSIDE that region would be buried by tall grass blades. **Every thin ground part (floor tile, step, driveway paint, ground signs, shadow plates) must lie inside x 128..228, z 100..180.** The building is x 172..216; the awning reaches x 162.

## Approximated
Sides and rear walls (plain pink); the roof (flat parapet); the upper storeys' interiors (none); the number and position of tables and chairs (representative); the kitchen (a suggestion behind the counter); the second-floor bay; the street, wires and neighbours (not built).

## Art-observation hooks for dialogue (Slice 12 will source them)
The warm pink-and-orange palette against a plain street; the strong horizontal of the awning and banner band that frames the open dining front; an open front that invites people in (inside/outside continuity); rhythm of tables, chairs and globe lamps; eating together as a social scene.

## Revision 1 (Slice 18): fidelity rework from the 2015 photo
**Reference:** still only `Lomi_King_Front_Oblique_2015.jpg`. Wikimedia Commons has no Lomi King file (full-text search 0 hits, 2026-10-22). Twelve street files from the De La Salle Lipa / JP Laurel Highway area (2013-2025, CC BY-SA) were downloaded and looked at; none shows the shop or its sign, so none is used or credited. The era stays 2015 and the approved dialogue is unchanged.

**Coordinates.** The sections above are in the original Slice 07 coordinates (centre 180, 140). The site is now at (292, 140): add +112 to every x. `tests/site03_check.luau` uses the world values (guide box x 250..274, z 128..152; InfoPanel front zone x 256..268, z 146..158; aisle x 272..313, z 138..142; paved region x 240..340, z 100..180). The builder still works in the original coordinates.

### Real vs model (what changed)
| # | Real (2015 photo) | Before | Now |
|---|---|---|---|
| 1 | "LOMI KING" is free-standing 3-D letters on the awning top, no backing board | grey `LetterBoard` slab with scaled text | 8 `Letter_*` blocks (x 165..167.6, y 16..19): LOMI cream-grey, KING blue-grey, 50 px glyph labels; board removed |
| 2 | Fascia is plain orange | "LOMI KING" text on the fascia | no text on `AwningFascia` |
| 3 | Tall full-width banner of blocks: red logo block, dish panels, red cup block | one thin yellow strip, one scaled text line | 6 `BannerBlock*` (y 8.5..12, z 116..150): SPECIALS, LOMI, PANCIT, RICE MEALS, SANDWICHES, a red cup block; 8 `BannerDish*` squares; 32 px labels. The KOPI VINZ name and the phone number are not reproduced |
| 4 | Black steel posts and rail frame the opening | pink columns | 3 `SteelPost` (z 115.6, 126, 150.4) + `SteelRail`; none in the aisle |
| 5 | Row of about 7 globe lamps behind the banner | 3 under the awning | 7 `PendantGlobe` at y 9.4 (z 119..149), cords to the rail; the 4 interior globes stay |
| 6 | Large curved bay on the second floor | 6-stud cylinder | 7 dark glass panels (about 18 wide, 4 deep, z 120..138) between a pink sill and head band: `CurvedBay*` |
| 7 | Iron grille on the upper right window; darker pier at the right edge | plain glass | 10 `GrilleBar*` over the southern upper window; `CornerPier` (x 170..172, z 164..166.6, y 0..44) |
| 8 | Round red logo at the upper-left corner on a steel bracket | small, centred | `LogoDisk` 9 across at z 118.5, white `LogoRing`, red `LogoCore`, cream `LogoBowl`, `LogoBracket` from the awning top (y 16..33) + `LogoArm` |
| 9 | Big pots, tall bushy shrubs | 2.4 pots, 3-stud ball | 3.2 `Pot`s, 3 stacked `Topiary*` balls each (top about y 10.8, 5 wide), x >= 163.5 (clear of the Guide box) |
| 10 | Large parking board; ramen poster; bamboo screen with a cap | 12 x 5 sign, scaled text | `ParkingSign` 12 x 7 (y 1.5..8.5, 40 px wrapped text), `RamenPoster`, 8 `BambooSlat*`, `BambooCap` |
| 11 | Saturated coral, darker pier | pale pink (232,130,112) | wall (242,129,108), pier (216,104,88) |
| 12 | (model bug) back `MenuBoard` text clipped | one scaled line | six fixed-size lines (24 px) on a taller board |

Guards kept: awning > 10 west of `LomiBody`; `CounterTop` > 15 east of the awning; `ParkingSign` z > body z + 10; lane, Guide and InfoPanel zones; thin ground parts inside the paved region.
Still approximated: sides, rear, roof, upper-floor interiors, neighbours and wires.

## Revision 2 (Lomi King L1b, 2026-10-31): tests written first for the board rebuild
Source: Lomi King Architectural Blueprint Board plus the Jan 2026 Street View photo, plan in docs/handoff/053-handoff.md. `tests/site03_check.luau` is now group-filtered (`shared.site03_only` = general, tower, front, dining, context, clear). Against the 436-part model of Revision 1: general 16/1, tower 4/20, front 40/3, dining 15/0, context 1/1, clear 10/0, all 81/25.

**Replaced by the orchestrator (decided, owner-approved plan):** non-rig parts 300..900 becomes 700..1500 (the count now includes the kept Guide parts; today 311); thin ground z 100..180 becomes z 85..195 and the x bound 340 becomes 344; the LomiBody y 14..44 and CurvedBay y 19..28 rules go, the tower rules replace them; wall colour 240,128,108 becomes salmon about 238,150,125 (+-8 per channel); CurvedBay becomes 12 +-1 wide, centre z 141 +-1.5, front face x 280..281.5; "7 pendant globes in x 275..282" becomes at least 4 PendantGlobe, none in the aisle; LogoBracket becomes SignMast (z within 3 of LogoDisk, bottom y 3 or lower); bamboo slats must be at z 158 or more.
**Restored after the first draft dropped it:** CornerPier (z 160 or more, grounded, top y 16 or more, darker than LomiBody).
**Names and thresholds the test fixes (L3 builders must follow):** ChairSeat at least 8 with top 1.95 or higher; CounterTop top 3.5; any Door at least 8 tall and any RailPost 2.9..3.4 tall (neither is required, since the board shows neither); GrilleBar is a Model or Folder with at least 3 parts, centred in y 16..28, 28..40 or 40..52, at least 2 per floor on floors 2 to 4; Car* and Motorbike* Models in Context; Window* or Shutter* parts, 3 per neighbour floor (floors y 0..12, 12..24, 24..36); storey slabs at most 2.5 thick and at least 20 long, centred inside the tower; hip eave bottom 61.5 or more, top 64.5 or less, 34 or more long; ParkingSign text exact, TextScaled false, TextSize 20 or more. The full list is in the header of the test file.
**Dropped, contradicting the new design:** CornerPier z 163.5 and CurvedBay 14..26 wide with front x 280.5 or less (replaced as above), the old 7-globe count, LogoBracket.
**No red test is possible for `dining` and `clear`:** they only constrain things, and today's model already meets them (15/0, 10/0). Negative controls instead, then restored to 436 parts and green: an anchored 4x4x4 part in the Guide box made `clear` 9/1 ("Guide keep-clear box ... is free | 1: NegControl"); lowering all 12 ChairSeat parts by 1.2 made `dining` 14/1 ("chairs are at least 2 high ... 12 seats, 12 low"). A first control that shrank one chair around its centre stayed green and proved nothing.

## Revision 3 (Lomi King L3 step 0, 2026-10-31): the parking sign faces south
**Owner decision (asked as a plain choice, answer "Face south, as on board"):** the board draws the red "Parking for LOMI KING CUSTOMERS Only" sign, the slat panel and the poster on the canopy's south return, facing the driveway. Revision 2 had assumed the sign faced west (width along z), as the 2015-photo model did.
**Changed in `tests/site03_check.luau` (front group only; orchestrator edit, never a builder's):** "ParkingSign is large" now measures the width along x (`extent(sign, "X") >= 11`, height 5.5 or more, unchanged); one new check, "ParkingSign label faces south" (the label's SurfaceGui face, turned to world space, has normal z of 0.99 or more). Kept unchanged: exact text "PARKING FOR LOMI KING CUSTOMERS ONLY", TextScaled false, TextSize 20 or more, bottom y 3.5 or lower, top y 8 or more, at least 10 south of LomiBody's centre z, slats at z 158 or more.
**Red against the 436-part model (run by the orchestrator):** `front` went from 40/3 to 39/5; the two new reds are "ParkingSign is large (...) | 0.4 x 7.0" and "ParkingSign label faces south | normal -1.00, 0.00, 0.00" (it faces west today). The other three reds (round sign north of the tower, SignMast, slats at z 158 or more) are unchanged. Positive control: an axis-aligned part with its SurfaceGui on `Back` has world normal (0, 0, 1) and passes; `Front` gives (0, 0, -1) and fails.
**For builders:** the sign is an axis-aligned part about 12 x 6 x 0.4 (x 12, y 6, z 0.4) on the south return (z 166..167) with its SurfaceGui on `NormalId.Back`. Still the owner's: no new on-screen text.
**Hashes (disk equals Studio):** `tests/site03_check.luau` 32961 bytes / 569 newlines / djb2 1453639466.

## Revision 4 (Lomi King L3d, 2026-10-31): the site-3 structure root in sites_check is Tower
**Why:** `tests/sites_check.luau` requires every built site to keep a child named `Structure` ("Structure present and Block absent"); City Hall (site 10) already uses `Wing` instead. The modular rebuild (coordinator plus dining, tower, front and context modules) has no `Structure` model, so the row has read red since L3a (276/1). Handoff 055 predicted it would turn green once the Lomi anchors existed; that prediction was wrong, because the check looks for the container name, not the anchors.
**Checked first:** no runtime code reads `Structure` (grep of `src/`, `tests/`, `builders/` and every script in Studio): only `sites_check`, other sites' checks and builders, and comments.
**Changed in `tests/sites_check.luau` (orchestrator edit, never a builder's):** the root is `(s.id == 10 and "Wing") or (s.id == 3 and "Tower") or "Structure"`, with a comment. Not added: an empty `Structure` container in the coordinator (that would patch around the test). Not renamed: `Tower` (three verified files would change).
**Red then green (negative control, because the new assertion is green on today's model):** with `Tower` renamed to `TowerProbe`, `sites_check` read 276/1 ("Site03_Lomi Tower present and Block absent"); renamed back, 277/0, and the 774-part snapshot of everything outside `Context` matched 774 of 774. The pass count stays 277, so EXPECTED does not change for this.
**Hashes (disk equals Studio):** `tests/sites_check.luau` 48154 bytes / 780 newlines / djb2 2842750375.
