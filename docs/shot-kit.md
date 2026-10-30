# Shot kit: fixed camera positions

Use the same camera for every before and after screenshot so changes can be compared. Values are provisional starting points (front oblique, about 0.6 of the site's longest side away, slightly raised) and are tuned the first time each site is rebuilt. World axes: North is -Z, East is +X.

Capture rules: one `screen_capture` at a time, twice with a wait between, look at every image, stop after two blanks in a row. Call with `camera_position` and `look_at_position`.

| Site | Camera position (x, y, z) | Look at (x, y, z) |
|---|---|---|
| Overview (whole world) | 0, 260, 520 | 0, 0, 0 |
| 1 Cathedral and plaza | -72, 31, 144 | 0, 15, 0 |
| 2 Market | -210, 28, 220 | -330, 12, 160 |
| 3 Lomi King | 232, 19, 110 | 292, 15, 140 |
| 4 Cafe de Lipa | 212, 19, -190 | 272, 10, -160 |
| 5 Carmel monastery | -366, 30, -468 | -300, 15, -600 |
| 6 The Outlets | 359, 37, -587 | 550, 10, -650 |
| 7 The Farm | 544, 34, 162 | 700, 10, 240 |
| 8 Mount Malarayat | 475, 66, 465 | 560, 30, 720 |
| 9 Tagbakin | -447, 31, 499 | -600, 10, 550 |
| 10 City Hall, blueprint view (beside the drawing; captured after the facade round) | -95, 85, -285 | -275, 22, -300 |
| 10 City Hall, long wing from the north-east (slabs, pilotis, central stair) | -150, 45, -330 | -250, 25, -380 |
| 10 City Hall, atrium from the south-east | -150, 70, -190 | -250, 30, -225 |
| 10 City Hall, top-down (fits the whole slot; compare with the drawing's inset plan) | -236, 235, -317 | -236, 0, -318 |
| 10 City Hall, forecourt from the north-east (loop, flag, steps, wing) | -110, 60, -390 | -190, 5, -300 |
| 10 City Hall, steps close-up | -170, 25, -335 | -215, 5, -345 |
| 10 City Hall, under the canopy at spawn height (Ate Joy, panel, columns) | -190, 6, -262 | -240, 30, -250 |

Slice 4 rows (provisional, tuned by each builder the first time it captures; the front oblique rows above were captured twice before the rebuild and are the "before" shots):

| Site | Shot | Camera position (x, y, z) | Look at (x, y, z) |
|---|---|---|---|
| 1 Cathedral | straight-on front (faces S) | 0, 20, 230 | 0, 15, 0 |
| 1 Cathedral | tower and dome close-up | -60, 40, 90 | 0, 35, 10 |
| 1 Cathedral | blueprint view (isometric from the south-west, church at left; found by trial, step B) | -150, 100, 155 | 10, 0, 5 |
| 1 Cathedral | plaza from the south-west (wing, forecourt cars, brick steps, mound, stage pavilion) | -120, 95, 140 | 40, 0, 50 |
| 1 Cathedral | plaza from the east (Cultural Center along the west edge across the plaza, statue in the middle of the stairs, east gateway) | 175, 65, 140 | 50, 0, 55 |
| 1 Cathedral | top-down | 0, 420, 1 | 0, 0, 0 |
| 1 Cathedral | wing entrance sign close-up | 106, 20, 26 | 106.5, 16.6, 2.3 |
| 1 Cathedral | close top-down of lot and plaza (step B round 2) | 0, 230, 60 | 0, 0, 45 |
| 2 Market | straight-on front (faces E) | -150, 15, 160 | -330, 12, 160 |
| 2 Market | name banner close-up | -230, 14, 160 | -330, 20, 160 |
| 3 Lomi King | straight-on front (faces W) | 205, 12, 140 | 292, 15, 140 |
| 3 Lomi King | sign and canopy close-up | 255, 16, 128 | 285, 20, 140 |
| 2 Market | corner block east face straight-on (checkerboard hoarding, louvres, doors) | -470, 22, 290 | -545, 14, 284 |
| 2 Market | corner block isometric from the north-east (BP2 style; Bagsakan roof stays below the camera) | -478, 80, 200 | -558, 15, 286 |
| 2 Market | service block and annex from the north-east | -470, 40, 5 | -525, 6, 58 |
| 2 Market | street front north: lean-tos on the north strip and a vendor cluster (beside bp2_iso_leantos_left.png) | -205, 32, 20 | -262, 8, 66 |
| 2 Market | lean-to in front of the north wing, lamp post and stalls (close-up) | -226, 20, 108 | -258, 8, 76 |
| 2 Market | street front south: vendor cluster and the south end of the hall | -205, 30, 305 | -252, 6, 258 |
| 2 Market | north side yard iso from the kerb (beside iso_northyard.png: booth row, awning, vendors) | -290, 40, 10 | -400, 4, 55 (too wide to judge booths: use the close row) |
| 2 Market | south side yard iso from the kerb (beside iso_shedsA.png: booth rows, shoppers' aisle) | -300, 40, 310 | -400, 4, 255 |
| 2 Market | north side yard top-down (beside plan_sheds1.png and plan_sheds2.png) | -385, 140, 53 | -385, 0, 52 |
| 2 Market | north booths close (beside iso_northyard.png: pyramid roofs, counter, vendor) | -418, 15, 34 | -445, 6, 54 |
| 2 Market | north yard crowd: two shoppers (Shopper8 at -411,46 and Shopper9 at -370,46) among the umbrella booths (beside iso_northyard.png; the close row above frames neither figure, use this one) | -390, 20, 18 | -390, 3, 52 |
| 2 Market | south booth row (beside iso_shedsA.png: booth rows, aisle) | -300, 26, 296 | -362, 6, 258 |
| 2 Market | north booth row top-down (four quarters meet on one centre) | -385, 70, 53 | -385, 0, 52 |
| 2 Market | south side yard top-down (beside plan_sheds1.png) | -390, 140, 256 | -390, 0, 255 |
| 2 Market | sample board close-up and the south stair foot (beside iso_stairN.png) | -212, 12, 178 | -231, 6, 190 |
| 2 Market | vehicles and tricycle queue at the north stair foot (beside bp2_iso_vendors_tricycles.png) | -205, 28, 70 | -236, 3, 105 |
| 2 Market | south stair foot: tricycle queue and jeepneys on the apron (beside iso_stairN.png) | -205, 28, 262 | -236, 3, 215 |
| 2 Market | street traffic: second apron jeepney in front of hall door 8 | -215, 22, 250 | -250, 3, 236 |
| 2 Market | apron top-down: kerb traffic either side of the clear Guide band | -238, 90, 160 | -238, 0, 159 |
| 2 Market | south yard top-down: vans, tricycles, motorbikes (beside plan_sheds1.png) | -420, 70, 258 | -420, 0, 257 |
| 2 Market | front street from the east: the Asphalt street along the paving edge, Road F meeting it as a T (compared with iso_stairN.png and bp2_iso_vendors_tricycles.png, the crops that draw the street) | -160, 26, 175 | -232, 3, 150 |
| 2 Market | front street, north stair foot and zebra crossing at z 88..96 (beside bp2_iso_vendors_tricycles.png) | -205, 28, 70 | -236, 3, 105 |
| 2 Market | front street, south zebra crossing at z 224..232 (beside iso_stairN.png; the east bar shows, the west bar merges with the paving) | -205, 28, 262 | -236, 3, 226 |
| 2 Market | front street top-down: street, Road F and both crossings | -222, 120, 160 | -222, 0, 159 |
| 2 Market | north side street and the north-east corner (beside iso_northyard.png; the street reads about like the concrete from far) | -180, 38, -48 | -240, 0, -8 |
| 2 Market | south corner: the front street T into the existing road at z 344, Concrete verge flush with the road (beside bp2_iso_whole.png) | -180, 38, 376 | -240, 0, 336 |
| 2 Market | south zebra crossing along the street (Salt bars; the west one blends in the hall's shadow, grass blades half-hide the east one) | -222, 14, 196 | -222, 0, 230 |
| 2 Market | north band traffic: kerb jeepneys, tricycles, motorbikes, poles and wires along the north side street (beside iso_northyard.png, about six kerb jeepneys along the kerb; the blueprints draw no utility poles or wires, those are the owner's request) | -190, 40, -45 | -340, 4, 6 |
| 2 Market | south band traffic: the same along the south verge and road (beside iso_shedsA.png, which draws only two kerb jeepneys along the street, so ours is denser: an honest DIFF; and bp2_iso_whole.png) | -190, 40, 372 | -340, 4, 312 |
| 2 Market | crowd close-up at the north stair foot: two facing pairs of shoppers between the hall wall and the tricycle queue (beside iso_stairN.png and bp2_iso_vendors_tricycles.png; the figures read small from far away, so use this view) | -228, 10, 112 | -246, 3.5, 90 |
| 2 Market | crowd in context: use the stair-foot rows above ((-205,28,70) to (-236,3,105) and (-205,28,262) to (-236,3,215)) and the south side yard iso ((-300,40,310) to (-400,4,255), beside iso_shedsA.png): 11 shoppers, 4 at the north foot, 3 at the south foot, 4 in the yards | see rows above | see rows above |

Per site, take at least: the front oblique above, a straight-on front, and one close-up of any signage or text.
