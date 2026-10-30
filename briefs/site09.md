# Site 09 brief — Tagbakin, Brgy. Halang

Site row: id 9, key `Tagbakin`, pos (-600, 0, 550), facing **NE** (pivot `LookVector` = (0.7071, 0, -0.7071), measured), footprint 240 x 200 world-aligned (x -720..-480, z 450..650), massScale 3.0, **has a JeepStop**, **no interior required**. Required props (direct children of `Site09_Tagbakin`, each a container holding at least one part): `LocationMapPanel`, `FishingActivity`, `Dock`, `Bancas`.
Proper name: **Tagbakin, in Barangay Halang, Lipa City** (`[VERIFY]` until sourced). The city identifies Halang as a tourism area and **records a glamping development at Tagbakin**; that is the only glamping claim allowed anywhere (map text, dialogue). **The building is a generic lakeshore building, never called glamping, a resort or a facility** (`REFERENCE_NOTES.txt`: "the shoreline building is contextual; it is not verified as a glamping facility"). No photo textures (rights withheld; the photos carry a WOW BATANGAS watermark: do not copy it): plain coloured parts; text is SurfaceGui. Ground y is 0 everywhere on land; the lake is flush at y 0.

## One building (do not blend photos)
Geometry comes from exactly these photos (`Lipa_structure_Exterior_References/08_Tagbakin_Halang/`):
- **`Tagbakin_Shoreline_Building_From_Lake.jpg`:** the lake-facing facade. A grey-white rendered concrete two-storey block: two end pavilions with low grey roofs (each with a ground-floor window and a small upper window), a lower centre bay with a double glass door and two flank windows and a plain blank band above, the roof deck behind a parapet. It stands on a concrete seawall (a stepped gap down to the water at the door), a warm paved/sandy yard around it, palms, lamp posts, a small hut at the right, the seawall continuing to the left.
- **`Tagbakin_Shoreline_Building_Oblique.jpg`:** the whole quay from above: the straight seawall, the yard, the shore road behind (NE side), the small hut at the right end, palms.
- **`Tagbakin_Shoreline_Building_From_Above.jpg`:** the plan: a long block with the centre roof deck lower than the pavilion roofs, a narrow strip of paving along the water.
- **Fishing: `Tagbakin_Fishing_Shore_Context.jpg`:** two anglers standing on the bank with long rods, shoes on the rock, calm lake, a distant volcano. Rods are 9 studs or longer; the stance is side-on to the water.
- **Volcano view / palette only (no geometry):** `Tagbakin_Lake_and_Volcano_Perspective`, `Tagbakin_Peninsula_Aerial`, `Tagbakin_Shoreline_and_Mountains`, `Tagbakin_Lakeside_Landscape`: a blue-green lake, forested hills, the volcano's blue-green silhouette, grey overcast light. **Not used:** `Tagbakin_Settlement_Aerial` (the upland village).

## Colours (by eye)
| Element | Colour |
|---|---|
| Building walls (render) | grey-white (203, 206, 204); base band (150, 154, 152) |
| Roofs / roof-deck slab | light grey (172, 176, 178); edge tier (120, 124, 126) |
| Window glass | dark teal (96, 120, 128), Glass, 0.3 transparent; frames white (232, 232, 228) |
| Doors | dark (70, 76, 80) |
| Seawall | weathered concrete (168, 166, 158) |
| Terrace / promenade paving | warm concrete (200, 190, 172) |
| Dock deck / rails | timber (150, 104, 64); posts (96, 70, 48) |
| Banca hull / band / stripe | white (236, 238, 236) / blue (36, 92, 160) / red (190, 50, 44) |
| Banca outriggers (bamboo) | (196, 172, 100) |
| Palm trunk / fronds | (120, 98, 70) / (56, 120, 56) |
| Lamp post / lamp head | (64, 70, 76) / Neon (255, 226, 160) |
| Kiosk thatch / posts / counter | (190, 158, 88) / (96, 70, 48) / (150, 104, 64) |
| Net | (150, 136, 100), Fabric, 0.4 transparent |
| Map board frame / face | brown (110, 80, 52) / cream (240, 236, 224); lake (96, 160, 206), island (96, 150, 92), text (40, 60, 50) |

## Frame (important)
The pivot is yawed NE and the shore runs diagonally. The builder does **not** use the pivot as an origin.
- `ORIGIN = Vector3.new(-650, 0, 588)` (on the site axis, 76 studs from the footprint centre toward the lake), `s = 0.70711`.
- `CFL = CFrame.fromMatrix(ORIGIN, Vector3.new(s, 0, s), Vector3.new(0, 1, 0))`: local **+X = SE**, local **+Z = SW (the lake and the facade)**, +Y up; local -Z = NE (the rear and the Guide).
  So **world = (-650 + s*(lx - lz), ly, 588 + s*(lx + lz))**. `ly` is absolute height above the ground (y 0).
- Viewed from the lake looking NE, local -X (NW) is the **left** and local +X (SE) the **right**. Pavilion L is the NW one, R the SE one (the photo's left and right).
- A SurfaceGui facing local +X (SE) is on the part's `Back` face when the part is rotated `ANG(0, PI/2, 0)` (its local +Z points at ctx +X). **Probe before trusting it.**
- Everything below is local `(lx, lz)` unless marked world.

## Measured at the start of the slice (2026-10-16, live Studio)
- Land: Grass at y 0 across the whole footprint except the lake. The **shore** is the circle centre (-860, 820), r 280 (the `LAKES[1]` cylinder); water cells (surface y 0) start 0..4 studs beyond the circle, in 4-stud cells.
- In the local frame, the circle crosses local Z at `lzc(lx) = 312.543 - sqrt(78400 - (lx - 15.556)^2)`: 42.93 (lx -60), 38.11 (-40), 34.81 (-20), 33.30 (-5), 32.98 (0), 32.74 (5), 32.58 (20), 33.61 (40), 35.48 (56). The lake lies at larger lz.
- **Usable box (BuildCheck bounds, footprint +10%):** world x -732..-468, z 440..660. In local terms the quay can run only from lx -60 to lx 56 (z limit on the SE end, x limit on the NW end); at lx 0 the dock tip may reach lz 84; nothing may stand at lx + lz > 100 or lz - lx > 114. The point (33, 80) is OUT of bounds.
- **Kept children** (all rotated 45°, left as is): **Guide** (-578.8, 2.55, 528.8) facing NE, prompt radius 12; **InfoPanel** (-591.5, 5.0, 524.5), 12 x 8 x 0.5, front faces NE; **JeepStop** (-564.6, 0.2, 542.9) 10 x 0.4 x 10 with `JeepSignPole`/`JeepSign`; **Jeepney** (-554.7, 3.3, 552.8) 10 x 6.6 x 16.4 facing NW. In local terms the Guide is at (8.5, -92.2).
- **Backdrop:** `Workspace.World.Backdrops.Taal_Volcano` is a Ball at (-1130, -110, 1130), diameter 560 (top y 170), `CanQuery = false` (rays never hit it), straight down the SW axis, about 690 studs from the dock. `Taal_Ridge` is a Ball at (-1030, -90, 1210), diameter 360. The boundary walls are at +-1004 and `CanQuery = false`.

## Terrain (decided and applied by Sonnet; the worker does NOT touch Terrain; a `world_check` probe guards it)
| What | Region (world x, z) | Result |
|---|---|---|
| Road E extension | asphalt x -486..-474, z 450..532 (leg 1) and x -548..-474, z 520..532 (leg 2) | the road now reaches the Guide plaza (terrain Asphalt, **no parts**); ground stays y 0 |
| Guide plaza | x -604..-548, z 508..564 | Pavement under the Guide, InfoPanel, JeepStop and Jeepney (the JeepStop pad is 0.4 thick: on grass it would vanish) |
Nothing else is repainted: the terrace, quay, dock and promenade are thick parts (tops at y 1.2 or more; the plan allows no thin part on Grass). The shore, the lake and the water are untouched.
**Thin-parts rule:** a part whose top is within 0.8 stud of the terrain under it (and whose footprint is over 2.5) may stand **only inside the Pavement or Asphalt regions above**. Everything the worker builds is at least 1.2 above the ground, so the rule is satisfied by thickness, not by paint.

## Layout (all local; ly absolute)
**Terrace** (in `Structure`): ONE slab `Terrace`, lx -44..44, lz -24..28, y -0.8..1.2 (top **1.2**: a riser of 1.2 from the lawn, the largest riser anywhere).
**Quay** (in `Structure`, follows the shore; segments in the table below, `ANG(0, rad(yaw), 0)` about local Y):
- **`SeawallSegment`** (repeated name, six parts): size `(len + 0.6, 6.4, 6.0)`, centre `(cx, -0.8, cz)`, spans y -4.0..2.4. They straddle the water edge.
- **`PromenadeStrip`** (seven parts): size `(len + 0.6, 2.0, 9.0)`, centre `(px, 0.2, pz)`, top 1.2. The seventh is the bridge across the dock gap: lx -5..5, centre `(0, 0.2, 25.98)`, size `(10.6, 2.0, 9.0)`, yaw 0.
- **The dock gap:** the wall stops at lx -5 and 5 (a 10-wide opening for the dock; the promenade bridges it).

| Segment (lx range) | wall centre (cx, cz) | len | yaw (deg) | promenade centre (px, pz) |
|---|---|---|---|---|
| -60..-40 | (-50.00, 41.52) | 20.57 | 13.55 | (-51.87, 33.74) |
| -40..-20 | (-30.00, 37.46) | 20.27 | 9.37 | (-31.30, 29.57) |
| -20..-5 | (-12.50, 35.05) | 15.08 | 5.75 | (-13.30, 27.09) |
| 5..20 | (12.50, 33.66) | 15.00 | 0.63 | (12.41, 25.66) |
| 20..40 | (30.00, 34.09) | 20.03 | -2.96 | (30.41, 26.11) |
| 40..56 | (48.00, 35.55) | 16.11 | -6.66 | (48.93, 27.60) |

**ShoreBuilding** (Model in `Structure`; ly from the terrace top 1.2):
- **`ShoreBody`** (ONE part, the centre bay): lx -14..14, lz -15..11, ly 1.2..23.2. Pavilions `PavilionL` lx -36..-14 and `PavilionR` lx 14..36, each lz -15..15, ly 1.2..25.2. A base band (150, 154, 152) ly 1.2..3.2, proud 0.3, on the SW and NE faces.
- **`ShoreRoofDeck`** (ONE part): lx -14..14, lz -15..11, ly 23.2..24.0, with a parapet 1.4 high around its four edges (4 parts, `Parapet`). A recessed roof terrace, as in the photos.
- **Pavilion roofs**, three stacked tiers each (low hip): tier 1 lx -38..-12 (L) / 12..38 (R), lz -17..17, ly 25.2..26.4; tier 2 inset 4 on every side, ly 26.4..27.6; **tier 3 is the single part `PavilionRoofL` / `PavilionRoofR`**, inset 4 more, ly 27.6..28.6. Grey.
- **`ShoreWindow`** (repeated name, **12 glass panes, 0.4 thick, on the SW face**, centre lz = face + 0.25: 15.25 for pavilions, 11.25 for the centre bay): per pavilion 2 ground panes (5 wide, ly 5.2..10.2, lx -29 and -21 for L; 21 and 29 for R) and 2 upper panes (ly 16.2..21.2, same lx); centre bay 2 door-glass panes (4.2 wide, ly 1.8..9.2, lx -2.4 and 2.4) and 2 flank panes (4 wide, ly 4.2..9.2, lx -9 and 9). White frames and a dark double door behind the door glass. A shallow flat `EntryCanopy` (lx -14..14, lz 11..15, ly 10.4..11.0) over the door.
- **Rear (NE face, lz -15):** **`RearDoor`** (ONE part, 4.4 x 8 x 0.4, lx 0, ly 1.2..9.2, lz -15.2), a canopy over it (10 x 0.6 x 6, ly 10..10.6, lz -15..-21) and 6 `RearWindow` panes (not `ShoreWindow`) at ly 16..21. The rear is plainer than the lake facade.
- No interior. Nothing may hang below ly 9.2 over the doors.

**Dock** (container `Dock`, a direct child): deck lx -4..4, lz 24..84, y 0.4..1.2 (top **1.2**, level with the promenade), planks every 4 studs along its length (15 parts, thin gaps are fine); posts (round, 1.0 diameter, y -6..3.2) in pairs every 8 studs at lx -4.5 and 4.5 (8 pairs); rails 3 high along both sides (y 1.2..4.2), **none across the landing end or at the promenade end**; **`DockEnd`** (ONE part, the last plank, lx -4..4, lz 82..84), 2 bollards, a ladder at the NW side of the tip, a bench each side near the tip (2 x 1, backs to the rails, facing SW; the volcano). The dock axis is lx 0; its tip is world (-708.7, 1.2, 646.7).
**Bancas** (container `Bancas`, a direct child; 4 outrigger boats, each a Model, 18..24 parts): a slim hull 14 x 2.4 x 1.6 (white, a blue band along the waterline, a red stripe), tapered ends from wedges, a small thwart seat, two bamboo outriggers (cylinders 12 long, diameter 0.6, lx +-5.5 from the hull) joined by 2 cross poles each, floating with the hull centre at y 0.4. The main hull is **`BancaMain`** (ONE part, in the first boat).
- B1 (`BancaMain`): centre (-14, 56), heading along lz. B2: centre (14, 66), heading rotated 15°. B3: centre (30, 44), heading along lz. B4: centre (-24, 68), heading along lz.
- Boats stay over water and off the dock lane (|lx| > 8 for lz > 28) and inside the usable box (corners checked: B4's outrigger float reaches (-29.5, 75), inside).
**FishingActivity** (container `FishingActivity`, a direct child, a Model): 2 anglers (R15 rigs, **copy `buildVendors` in `builders/site02.luau`** exactly: `CreateHumanoidModelFromDescription`, colours from `HumanoidDescription`, only the `HumanoidRootPart` anchored, `ModelStreamingMode = Atomic`, `SiteId` attribute, `WalkSpeed 0`, `DisplayDistanceType.None`, as its own step before the swap). Angler 1 at (2.5, 78) on the dock tip, angler 2 at (-30, 29) on the promenade by the wall, both facing the lake (yaw so they look along local +Z); place rig HRP at deck top 1.2 + 3. Each has a rod (a thin cylinder, 9 long, 0.15 across, raised 40° toward the water, from the right hand, anchored parts in the container), a bucket (cylinder 1.6 across, 1.6 high), shoes. Plus a drying rack and nets on the SE lawn: 2 net poles (8 high) with a draped net (Fabric, 8 x 5 x 0.1, transparency 0.4) at (46, -4), a fish rack (2 posts, a bar, 6 small flat fish) at (50, 8), a cooler box at (-26, 29). **Rigs are exempt from the anchoring check**; every other part is anchored.
**LocationMapPanel** (container `LocationMapPanel`, a direct child): a board on two posts, **`MapBoard`** (ONE part, 14 wide x 9 tall x 0.5, y 5..14), centre (-7.5, -70) in plan (world (-605.8, 533.2)), its text face toward **local +X (SE)**, i.e. toward the walking lane (probe the NormalId). One SurfaceGui: a title "LOCATION MAP", a cream face with a blue rounded Frame for Taal Lake, a green circle for Volcano Island, a red pin on the north-east shore labelled "Tagbakin, Brgy. Halang", the caption "Tagbakin sits on the shore of Taal Lake in Barangay Halang, Lipa City." and "Schematic map, not to scale." The city's glamping development may be mentioned once: "The city records a glamping development at Tagbakin." No distances, no invented facts.
**Dressing** (all in `Structure`): **palms** (stacked cylinder trunks 14..18 high with non-colliding fronds) at (-56,-8), (-52, 8), (-48,-22), (-62, 4), (50,-6), (54, 8), (48,-22), (58, 18), (-44,-34), (-24,-34), (18,-34), (34,-34); **lamp posts** (9 high, a neon head) at lx -56, -44, -26, 26, 44, 56, at `lz = lzc(lx) - 4.5` on the promenade; the **kiosk** (a small hut, 8 x 8, four posts, a stepped thatch roof, a counter; floor part **`KioskFloor`**, ONE part) at (52, 6); a few benches on the terrace. Palm trunks and lamp posts collide and must stay out of every lane, keep-clear box and sight corridor.

## Keep clear (existing, kept; checked on built children only; world coordinates)
- **Guide:** box x -590.8..-566.8, z 516.8..540.8, **y 1..13** free of built parts.
- **InfoPanel front zone:** x -593.9..-577.9, z 510.9..526.9, y 1..11.
- **JeepStop, jeepney and the ride landing:** x -575.6..-541.6, z 532..566, y 1..14.
- The Road E extension and the Guide plaza (terrain) stay free of built parts.

## Walking lanes (pinned; the guards test them)
Each lane is 4 wide and fails on any colliding non-rig part of the site (box y 2..9 above the walking surface). Lane coordinates are local `(lx, lz)`:
- **(b)** Guide to the rear door: (8.5, -80) -> (2, -26).
- **(c)** SE flank: (2, -26) -> (40, -27) -> (40, 24). **(c')** NW flank: (2, -26) -> (-40, -27) -> (-40, 24).
- **(d)** promenade: (-40, 24) -> (0, 24) -> (40, 24).
- **(e)** the dock: (0, 24) -> (0, 80).
Lanes (c), (c'), (d), (e) are also **walkable**: the walking surface (terrain, terrace, promenade, deck) sampled every 2 studs must never step by more than 1.3 (the terrace edge is 1.2). The seawall lip (2.4) must not intrude into a lane: the dock gap is open.

## Sight-lines (pinned; the visibility guards ray-cast them)
- From the **dock-end eye (local (0, 76), world (-703.7, 6.2, 641.7))**: at least 80% of the `ShoreWindow` centres must be reached first by a ray (built parts only), and **no built part blocks rays to three volcano targets**: (-1130, 150, 1130), (-1018.2, 120, 1230) and (-1241.8, 120, 1030) (the ball is `CanQuery = false`, so the guard asserts that a built-parts-only ray reaches the target unobstructed).
- From the **Guide-side eye (-583.0, 5.5, 533.0)** (6 studs SW of the Guide): `PavilionL`, `PavilionR` and `RearDoor` must each be reached first (the roof caps are hidden from a low eye by the rear wall, so they are not tested; keep palms, lamps and the kiosk out of this corridor).
- The Guide, InfoPanel and JeepStop/jeepney parts are ignored by the rays.

## Anchors (one uniquely named BasePart each; no Model/Folder may share these names; searched recursively)
`ShoreBody`, `PavilionL`, `PavilionR`, `ShoreRoofDeck`, `PavilionRoofL`, `PavilionRoofR`, `RearDoor`, `DockEnd`, `BancaMain`, `MapBoard`, `KioskFloor`. Repeated part names (guard targets, not anchors): `ShoreWindow`, `SeawallSegment`. Required props are direct children **containers** named exactly `LocationMapPanel`, `FishingActivity`, `Dock`, `Bancas`; everything else goes in a `Structure` Folder (also a direct child).

## Approximated
The building as boxes with stacked-tier roofs (real: pitched sheet roofs); the shore as six straight wall segments on the real arc; the volcano as the existing backdrop ball; no interior; no shore road, cars or houses; the yard as one slab; bancas as simple hulls; anglers as stock R15 rigs; palms as stacked primitives.

## Art-observation hooks for dialogue (Slice 12 will source them)
The long horizontal band of lake, quay and building against the tall volcano (horizon and scale); the dock as a leading line to the volcano (linear perspective); the grey geometric building against the organic shoreline and palms (geometric against organic form); cool blue-green water and grey render with warm timber accents (colour harmony); the repeated dock posts and windows as rhythm; the volcano's blue-green haze as atmospheric depth.

**Budget:** <= 2,500 parts (target 700..1,300).

## Revision 1 (Slice 22): fidelity rework from `Tagbakin_Shoreline_Building_From_Lake.jpg`
**References:** the photo the brief already names; no new photo, no credit change. The building stays a generic lakeshore building (never called glamping). `tests/site09_check.luau` encodes the table.

| # | Real | Before | Now |
|---|---|---|---|
| 1 | One small ground window and one small upper window per pavilion | two large 5 x 5 panes per floor per pavilion (12 windows on the face) | one 3.4-wide pane per floor per pavilion; 8 windows on the lake face with the centre bay |
| 2 | Plain grey-white roofs | Metal roofs and canopies that reflected the sky blue | Concrete, neutral grey |
| 3 | Warm sandy yard | cool near-white `PAVE` (200,190,172) | (214,188,148) |
| 4 | (model bug) | map description at 34% of the board width, tiny type | lake 44%, description column 46% |

**Guards changed on purpose (sites_check, Site 9):** "the windows are on the SW (lake) face" and "shore windows are visible from the dock end" required at least 10 windows (the old model had 12). The photo has 8 on the lake face, so both now require at least 8; the average-offset and 80%-visibility conditions are unchanged.

## Revision 2 (2026-10-31): Taal Volcano in front of the building
**Owner:** "there's supposed to be the Taal in front of the building." **References:** `2nd Reference/tagbakin_halang/taal volcano-in-front-of-tagbakin-halang-structure/`: `caption.jpg` (from a boat; the shape and colours), `images (2).jpg` (aerial; the crater lake and the flat coastal plain), `tagaytay-volcano.webp` (a view from Tagaytay, colour only, its angle not used). Builder: `builders/site09_taal.luau`, called at the end of `builders/site09.luau`. Checks: the "Taal" group in `tests/site09_check.luau` (added; no existing assertion changed).

| # | Brief before | Now |
|---|---|---|
| 1 | Backdrop: `World.Backdrops.Taal_Volcano`, a Ball at (-1130, -110, 1130), diameter 560, plus `Taal_Ridge`, a Ball at (-1030, -90, 1210), diameter 360 (both from `builders/world.luau`) | Both balls replaced by an island of parts: root `World.Backdrops.Taal_Volcano` (invisible 4-stud anchor, the name sites_check reads) with `Island/Cone` (528 wedges: a radial triangle mesh, 24 sectors), `Island/TaalCraterLake` (disc) and `FarShore` (40 wedges). 570 parts, all anchored, CanCollide/CanQuery/CastShadow false. Outside the site model because BuildCheck's footprint+10% bounds forbid a far backdrop there; it counts in the world budget. Rerunning `world.luau` brings the balls back until site09 runs again. |
| 2 | Approximated: "the volcano as the existing backdrop ball" | A faceted cone: crater centre (-1203.7, 1141.7), 700 studs from the dock tip straight along the dock axis (local +Z, SW), so the dock leads the eye to it (first built at 830; pulled in so it reads through the Atmosphere haze, Density 0.42 / Haze 1.6). The near shore is about 365 studs out from the dock tip, just inside the west and south walls; the parts do not collide (as the old ball, whose waterline reached about (-948, 948)). Cone foot radius 300, flat coastal plain to radius 380 (dips under the water there), summit 175. Crater rim with two peaks as in caption.jpg: the viewer's left peak 0.88 H, the far rim seen as the dip 0.80 H (photo ~0.82), the right peak 1.0 H, the bare brown breach toward the viewer 0.48 H. Olive flanks (70..92, 94..100, 56..62), brown breach/crater (152, 114, 82)/(140, 108, 78), lighter plain (108, 124, 72), crater lake (52, 96, 104). Summit/width: 0.21 over the parts' bounding corners (what the check measures, W 850), about 0.24 at the real waterline (W ~720); photo ~0.23. |
| 3 | (none) | Far western shore: a low skyline (44..90 high) on an arc 1500 studs from the dock tip, bearings -50..+50 degrees; it also hides where the lake water ends at the map edge. No terrain change: the lake water already reaches past the island. |

**Where it reads:** from the dock end and the promenade (eye y 6.2) the summit stands 13.4 degrees above the horizon and the island spans about 58 degrees across open water. Silhouette from the dock-end eye (max elevation per 2-degree bearing, left to right): left peak 11.9, dip 9.6, right peak 13.1; perspective makes the far-rim dip read a little deeper than in the photo. From the Guide (NE of the building) the building itself hides it (the ray to the summit hits `ShoreBody`); the peak was not raised to clear the roof.
**sites_check aim points (not edited; proposal for the owner):** "the volcano view from the dock end is clear" still aims at (-1130, 150, 1130), (-1018.2, 120, 1230), (-1241.8, 120, 1030), now open air in front of the island. Suggested new aim points, taken from built vertices: summit (-1267.1, 177.8, 1090.8), left flank (-1068.2, 87.0, 1258.3), right flank (-1304.6, 87.9, 993.8).

**Assertion revision (Taal group; added and shown red this revision, then replaced after the first build, which passed the old rule only with a dip deeper than the photo's):**
| Check | Old | New | Why |
|---|---|---|---|
| Taal: crater notch | silhouette middle at least 8% of H below both side peaks | at least 4% of H below both side peaks | measured off caption.jpg the far rim dips only ~6% of H below the left peak, so the photo itself failed the 8% rule; 4% keeps margin under the photo |
