-- RoadData: the road centre lines, shared by the checks and builders/roads_extra.luau.
-- ROADS is a VERBATIM copy of ROADS in builders/world.luau (that file is never run: it wipes all terrain). tests/roads_match.js
-- (node) fails if the two tables differ, so edit both or neither.
-- NEW_ROADS (Slice 3b, City Hall) are paved by builders/roads_extra.luau with the same method as world.luau buildRoads: an Asphalt
-- FillBlock per segment, extended by w/2 at interior joints and at a start that joins another road (joinStart).
--   SPUR         City Hall curb to Road A. Starts 8 studs east of the front edge of City Hall (x -150) so the jeep stop at (-155,-230) steps onto it.
--   WEST_BYPASS  leaves the spur, passes west of the Cathedral compound (road edge 36 studs from its west edge x -128) and ends on Road F.
--   WEST_LINK / EAST_LINK  (Cathedral south growth) join the bypass ends to Road E at z 260 (see their entries).
--   EAST_BYPASS  joins Road H in the north and Road G in the south, crossing Road C at (165, 0). x 165, not 155: the Cathedral plus its
--                10 percent slack reaches x 153.6, and a 12-wide road with a 4 stud margin needs its edge-minus-margin clear of that.
local RoadData = {}

-- Footprint-aware roads (centre points). Polylines are axis-aligned; ends stop flush at site footprints.
local ROADS = {
	{ name = "A_to_Carmel", w = 12, pts = { { 0, -100 }, { 0, -460 }, { -300, -460 }, { -300, -510 } } },
	{ name = "B_to_Outlets", w = 12, joinStart = true, pts = { { 0, -460 }, { 430, -460 }, { 430, -550 } } },
	{ name = "C_to_Farm", w = 12, pts = { { 120, 0 }, { 450, 0 }, { 450, 240 }, { 570, 240 } } },
	{ name = "D_to_Malarayat", w = 12, joinStart = true, pts = { { 450, 240 }, { 450, 560 } } },
	-- Slice 11: Road E used to stop at (-480, 450), the footprint's NE corner, 127 studs short of the Guide. It now runs on south to
	-- z 526 and west to x -548, the east edge of the Tagbakin Guide plaza (PAVED below). Keep in step with briefs/site09.md.
	{ name = "E_to_Tagbakin", w = 12, pts = { { 0, 225 }, { 0, 350 }, { -480, 350 }, { -480, 526 }, { -548, 526 } } },
	-- Slice 14: the three core shops were pushed out from the Cathedral (Market -330, Lomi 292, Cafe 272). F, G and H are now straight
	-- spurs off Road E (x 0, z 160 and 140) and Road A (x 0, z -160) that end exactly where each shop's paving begins (see PAVED).
	{ name = "F_to_Market", w = 8, joinStart = true, pts = { { -170, 160 }, { -228, 160 } } },
	{ name = "G_to_Lomi", w = 8, joinStart = true, pts = { { 165, 140 }, { 240, 140 } } },
	{ name = "H_to_Cafe", w = 8, joinStart = true, pts = { { 0, -160 }, { 224, -160 } } },
}

RoadData.NEW_ROADS = {
	{ name = "SPUR", w = 12, pts = { { -142, -230 }, { 0, -230 } } },
	{ name = "WEST_BYPASS", w = 12, joinStart = true, pts = { { -120, -230 }, { -120, -150 }, { -170, -150 }, { -170, 160 } } },
	{ name = "EAST_BYPASS", w = 12, pts = { { 165, -160 }, { 165, 140 } } },
	-- Cathedral south growth (Slice 4 B3b): Road E now starts at the compound's south edge (0,225), and F and G start at the bypass ends, so E
	-- no longer touches them. These two links carry the bypass ends south and across to Road E at z 260, clear of the slot's margin zone
	-- (slot z -100..215, zone to z 246.5, road edge 254). They are the only new paving of this step.
	{ name = "WEST_LINK", w = 12, joinStart = true, pts = { { -170, 160 }, { -170, 260 }, { 0, 260 } } },
	{ name = "EAST_LINK", w = 12, joinStart = true, pts = { { 165, 140 }, { 165, 260 }, { 0, 260 } } },
	-- Owner markup, Slice 4 B3c-0b: the entrances line up on z 26 with the Cathedral side stairs (SideStairsW/E centre z 26), so a paved
	-- way runs from each bypass straight to the foot of each stair (the lowest tread's outer edge, |x| 128).
	{ name = "WEST_ENTRY", w = 12, joinStart = true, pts = { { -170, 26 }, { -128, 26 } } },
	{ name = "EAST_ENTRY", w = 12, joinStart = true, pts = { { 165, 26 }, { 128, 26 } } },
}
RoadData.ROADS = ROADS

-- Existing roads first, then the new ones.
function RoadData.all()
	local list = {}
	for _, r in ipairs(RoadData.ROADS) do table.insert(list, r) end
	for _, r in ipairs(RoadData.NEW_ROADS) do table.insert(list, r) end
	return list
end

return RoadData
