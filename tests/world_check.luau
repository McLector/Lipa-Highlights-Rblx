-- world_check: verifies the Slice 00 world. Run in Edit mode via execute_luau; returns {passed, failed, failures}.
-- Terrain is probed by raycast (Baseplate excluded) so the result reflects the terrain only.
local REQUIRE_BASEPLATE_REMOVED = false -- set true for the final check, after the raycast checks pass

local results = { passed = 0, failed = 0, failures = {} }
local function check(name, cond, detail)
	if cond then
		results.passed += 1
	else
		results.failed += 1
		table.insert(results.failures, name .. (detail and (" | " .. detail) or ""))
	end
end

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
local excluded = {}
if workspace:FindFirstChild("Baseplate") then table.insert(excluded, workspace.Baseplate) end
if workspace:FindFirstChild("SpawnLocation") then table.insert(excluded, workspace.SpawnLocation) end
if workspace:FindFirstChild("World") then table.insert(excluded, workspace.World) end
-- Sites are built on the terrain (the placeholder blocks, later the real structures), so rays that probe the
-- terrain itself must ignore them. Without this the Malarayat slope probe at (560,720) hits Site08's block.
if workspace:FindFirstChild("Sites") then table.insert(excluded, workspace.Sites) end
params.FilterDescendantsInstances = excluded

local function ground(x, z)
	local r = workspace:Raycast(Vector3.new(x, 400, z), Vector3.new(0, -800, 0), params)
	if r and r.Instance == workspace.Terrain then return r.Position.Y, r.Material end
	return nil, nil
end

local function floorAt(name, x, z)
	local y, m = ground(x, z)
	check("floor " .. name, y ~= nil and math.abs(y) <= 0.5 and m == Enum.Material.Grass,
		"y=" .. tostring(y) .. " mat=" .. tostring(m))
end

-- Grass floor across the world, including the corners.
floorAt("beside north road", 150, -300) -- (0,-300) is on road A, so sample off the road
floorAt("NW corner", -950, -950)
floorAt("NE corner", 950, -950)
floorAt("SE corner", 950, 950)
floorAt("dry shore near Tagbakin NE corner", -440, 470) -- (-480,450) is the end of road E
floorAt("west of Market", -500, 160)

-- Roads are asphalt at the terrain surface.
local function roadAt(name, x, z)
	local y, m = ground(x, z)
	check("road " .. name, y ~= nil and math.abs(y) <= 0.5 and m == Enum.Material.Asphalt,
		"y=" .. tostring(y) .. " mat=" .. tostring(m))
end
roadAt("north to Carmel", 0, -300)
roadAt("east to Farm", 300, 0)
roadAt("to Malarayat", 450, 400)
roadAt("to Tagbakin", -240, 350)

-- Lake in the SW, reaching inside Tagbakin's footprint. Terrain water snaps to multiples of 4 studs
-- (-4 or 0), so the lake is flush with the bank at y=0 (measured 2026-10-15; the plan's -2 isn't possible).
local function waterAt(name, x, z)
	local y, m = ground(x, z)
	check("water " .. name, m == Enum.Material.Water and y ~= nil and math.abs(y) <= 0.6,
		"y=" .. tostring(y) .. " mat=" .. tostring(m))
end
waterAt("lake centre", -860, 820)
waterAt("inside Tagbakin footprint SW", -700, 640)

-- Malarayat slope rises toward the east.
local yWest = ground(370, 720)
local yMid = ground(560, 720)
local yEast = ground(750, 720)
check("slope west end is low", yWest ~= nil and yWest <= 6, "y=" .. tostring(yWest))
check("slope rises monotonically", yWest ~= nil and yMid ~= nil and yEast ~= nil and yWest < yMid and yMid < yEast,
	string.format("%s / %s / %s", tostring(yWest), tostring(yMid), tostring(yEast)))
check("slope east end is about 40", yEast ~= nil and yEast >= 32 and yEast <= 48, "y=" .. tostring(yEast))

-- World container, boundary and backdrops.
local world = workspace:FindFirstChild("World")
check("Workspace.World exists", world ~= nil)
if world then
	local boundary = world:FindFirstChild("Boundary")
	check("Boundary exists with 4 walls", boundary ~= nil and #boundary:GetChildren() == 4)
	if boundary then
		for _, w in ipairs(boundary:GetChildren()) do
			check("wall " .. w.Name .. " collides, invisible, anchored",
				w:IsA("BasePart") and w.CanCollide and w.Transparency == 1 and w.Anchored)
		end
	end
	local back = world:FindFirstChild("Backdrops")
	check("Backdrops exists and is Persistent",
		back ~= nil and back:IsA("Model") and back.ModelStreamingMode == Enum.ModelStreamingMode.Persistent)
	if back then
		check("Backdrops has 4+ parts", #back:GetChildren() >= 4)
		for _, p in ipairs(back:GetChildren()) do
			check("backdrop " .. p.Name .. " anchored, no collision",
				p:IsA("BasePart") and p.Anchored and not p.CanCollide)
		end
	end
end

-- Spawn: at (0, ?, 70), facing north (-Z).
local spawn = workspace:FindFirstChild("SpawnLocation")
check("SpawnLocation exists", spawn ~= nil)
if spawn then
	check("spawn at x=0 z=70", math.abs(spawn.Position.X) < 1 and math.abs(spawn.Position.Z - 70) < 1,
		tostring(spawn.Position))
	check("spawn faces -Z", spawn.CFrame.LookVector.Z < -0.99, tostring(spawn.CFrame.LookVector))
end

-- Plaza ground: world.luau repaints the Grass under Plaza Independencia (x -100..100, z 0..100) as Pavement, so the
-- terrain's grass blades do not poke through the thin plaza paving. This reads the surface voxel of the 4-stud cell
-- containing each point (ReadVoxels, exact). Raycasts are NOT used here: within about 2 studs of a material boundary
-- a ray reports a blended material (measured 2026-10-16), which made edge samples unreliable. Controls in the cells
-- just outside prove that the paint does not spill, including onto the asphalt road mouth (x 0..4, z 100..104).
do
	local function cellMaterial(x, z)
		local fx, fz = math.floor(x / 4) * 4, math.floor(z / 4) * 4
		local mats = workspace.Terrain:ReadVoxels(Region3.new(Vector3.new(fx, -4, fz), Vector3.new(fx + 4, 0, fz + 4)), 4)
		return mats[1][1][1]
	end
	local problems = {}
	-- cells inside the plaza, including the four corner-most cells
	for _, p in ipairs({ { 2, 50 }, { 62, 82 }, { -58, 22 }, { -98, 2 }, { 98, 98 }, { 98, 2 }, { -98, 98 } }) do
		local m = cellMaterial(p[1], p[2])
		if m ~= Enum.Material.Pavement then
			table.insert(problems, string.format("cell (%d,%d) is %s, expected Pavement", p[1], p[2], tostring(m)))
		end
	end
	-- cells just outside
	for _, c in ipairs({
		{ -102, 50, Enum.Material.Grass }, { 102, 50, Enum.Material.Grass }, { 50, -2, Enum.Material.Grass },
		{ 50, 102, Enum.Material.Grass }, { 2, 102, Enum.Material.Asphalt },
	}) do
		local m = cellMaterial(c[1], c[2])
		if m ~= c[3] then
			table.insert(problems, string.format("control cell (%d,%d) is %s, expected %s", c[1], c[2], tostring(m), tostring(c[3])))
		end
	end
	check("plaza ground is paved and the paint stays inside the plaza", #problems == 0, table.concat(problems, "; "))
end

-- Carmel forecourt (Slice 04): world.luau repaints the Grass under the monastery forecourt (x -352..-248, z -600..-508) as
-- Pavement, for the same reason as the plaza. Same exact voxel read; the controls prove the paint stays inside the region
-- and leaves the end of road A (x -300, z -508..-512 is asphalt) alone.
do
	local function cellMaterial(x, z)
		local fx, fz = math.floor(x / 4) * 4, math.floor(z / 4) * 4
		local mats = workspace.Terrain:ReadVoxels(Region3.new(Vector3.new(fx, -4, fz), Vector3.new(fx + 4, 0, fz + 4)), 4)
		return mats[1][1][1]
	end
	local problems = {}
	for _, p in ipairs({ { -350, -598 }, { -250, -510 }, { -350, -510 }, { -250, -598 }, { -300, -550 } }) do
		local m = cellMaterial(p[1], p[2])
		if m ~= Enum.Material.Pavement then
			table.insert(problems, string.format("cell (%d,%d) is %s, expected Pavement", p[1], p[2], tostring(m)))
		end
	end
	for _, c in ipairs({
		{ -356, -550, Enum.Material.Grass }, { -244, -550, Enum.Material.Grass }, { -300, -604, Enum.Material.Grass },
		{ -348, -504, Enum.Material.Grass }, { -300, -508, Enum.Material.Asphalt },
	}) do
		local m = cellMaterial(c[1], c[2])
		if m ~= c[3] then
			table.insert(problems, string.format("control cell (%d,%d) is %s, expected %s", c[1], c[2], tostring(m), tostring(c[3])))
		end
	end
	check("Carmel forecourt is paved and the paint stays inside the region", #problems == 0, table.concat(problems, "; "))
end

-- Outlets paving (Slice 05): world.luau repaints the Grass under the Outlets' paved areas as Pavement, because the terrain's
-- tall grass blades otherwise bury the thin paving and poke through the pitch turf. Three regions (4-stud aligned):
-- arrival plaza + forecourt (x 472..592, z -724..-604), entry path / spur / sign apron / car park (x 424..612, z -632..-548),
-- pitch + stand (x 636..708, z -752..-612). Same exact voxel read as the plaza check; the controls prove the paint stays
-- inside the regions (and does not touch the asphalt of road B at x 424..436).
do
	local function cellMaterial(x, z)
		local fx, fz = math.floor(x / 4) * 4, math.floor(z / 4) * 4
		local mats = workspace.Terrain:ReadVoxels(Region3.new(Vector3.new(fx, -4, fz), Vector3.new(fx + 4, 0, fz + 4)), 4)
		return mats[1][1][1]
	end
	local problems = {}
	for _, p in ipairs({
		{ 474, -722 }, { 590, -606 }, { 530, -660 }, { 590, -722 }, { 474, -606 }, -- plaza + forecourt, corners and middle
		{ 426, -630 }, { 610, -550 }, { 510, -626 }, { 560, -560 }, -- entry, car park
		{ 638, -750 }, { 706, -614 }, { 672, -690 }, { 706, -750 }, -- pitch + stand
	}) do
		local m = cellMaterial(p[1], p[2])
		if m ~= Enum.Material.Pavement then
			table.insert(problems, string.format("cell (%d,%d) is %s, expected Pavement", p[1], p[2], tostring(m)))
		end
	end
	for _, c in ipairs({
		{ 466, -700, Enum.Material.Grass }, { 598, -700, Enum.Material.Grass }, { 672, -606, Enum.Material.Grass },
		{ 712, -690, Enum.Material.Grass }, { 420, -600, Enum.Material.Grass }, { 630, -690, Enum.Material.Grass },
		{ 430, -552, Enum.Material.Asphalt },
	}) do
		local m = cellMaterial(c[1], c[2])
		if m ~= c[3] then
			table.insert(problems, string.format("control cell (%d,%d) is %s, expected %s", c[1], c[2], tostring(m), tostring(c[3])))
		end
	end
	check("Outlets paving is Pavement and the paint stays inside the regions", #problems == 0, table.concat(problems, "; "))
end

-- Market paving (Slice 06): world.luau repaints the Grass under the Market hall, stall yard and aisle (x -276..-128,
-- z 80..240) as Pavement, for the same reason as the plaza. The controls prove the paint stays inside the region and
-- leaves the asphalt of road F (x -128..-120) alone.
do
	local function cellMaterial(x, z)
		local fx, fz = math.floor(x / 4) * 4, math.floor(z / 4) * 4
		local mats = workspace.Terrain:ReadVoxels(Region3.new(Vector3.new(fx, -4, fz), Vector3.new(fx + 4, 0, fz + 4)), 4)
		return mats[1][1][1]
	end
	local problems = {}
	for _, p in ipairs({
		{ -274, 82 }, { -130, 238 }, { -274, 238 }, { -130, 82 }, -- corners
		{ -200, 160 }, { -250, 120 }, { -170, 200 }, -- middle, hall, yard
	}) do
		local m = cellMaterial(p[1], p[2])
		if m ~= Enum.Material.Pavement then
			table.insert(problems, string.format("cell (%d,%d) is %s, expected Pavement", p[1], p[2], tostring(m)))
		end
	end
	for _, c in ipairs({
		{ -280, 160, Enum.Material.Grass }, { -200, 78, Enum.Material.Grass }, { -200, 242, Enum.Material.Grass },
		{ -124, 164, Enum.Material.Grass }, { -126, 120, Enum.Material.Asphalt },
	}) do
		local m = cellMaterial(c[1], c[2])
		if m ~= c[3] then
			table.insert(problems, string.format("control cell (%d,%d) is %s, expected %s", c[1], c[2], tostring(m), tostring(c[3])))
		end
	end
	check("Market paving is Pavement and the paint stays inside the region", #problems == 0, table.concat(problems, "; "))
end

-- Lomi paving (Slice 07): world.luau repaints the Grass under the Lomi King shophouse, forecourt and driveway (x 128..228,
-- z 100..180) as Pavement, for the same reason as the plaza. The controls prove the paint stays inside the region and leaves
-- the asphalt of road G (x 120..128, z 100..140) alone.
do
	local function cellMaterial(x, z)
		local fx, fz = math.floor(x / 4) * 4, math.floor(z / 4) * 4
		local mats = workspace.Terrain:ReadVoxels(Region3.new(Vector3.new(fx, -4, fz), Vector3.new(fx + 4, 0, fz + 4)), 4)
		return mats[1][1][1]
	end
	local problems = {}
	for _, p in ipairs({
		{ 130, 102 }, { 226, 178 }, { 130, 178 }, { 226, 102 }, -- corners
		{ 150, 140 }, { 194, 140 }, -- Guide, shop floor
	}) do
		local m = cellMaterial(p[1], p[2])
		if m ~= Enum.Material.Pavement then
			table.insert(problems, string.format("cell (%d,%d) is %s, expected Pavement", p[1], p[2], tostring(m)))
		end
	end
	for _, c in ipairs({
		{ 126, 120, Enum.Material.Asphalt }, { 126, 150, Enum.Material.Grass }, { 232, 140, Enum.Material.Grass },
		{ 180, 98, Enum.Material.Grass }, { 180, 182, Enum.Material.Grass },
	}) do
		local m = cellMaterial(c[1], c[2])
		if m ~= c[3] then
			table.insert(problems, string.format("control cell (%d,%d) is %s, expected %s", c[1], c[2], tostring(m), tostring(c[3])))
		end
	end
	check("Lomi paving is Pavement and the paint stays inside the region", #problems == 0, table.concat(problems, "; "))
end

-- Café paving (Slice 08): world.luau repaints the Grass under the Café terrace, unit floor and forecourt (x 112..212,
-- z -200..-120) as Pavement, for the same reason as the plaza. The controls prove the paint stays inside the region and
-- leaves the asphalt of road H's mouth (x 96..112, z -164..-156) alone, including the grass verge beside the mouth.
do
	local function cellMaterial(x, z)
		local fx, fz = math.floor(x / 4) * 4, math.floor(z / 4) * 4
		local mats = workspace.Terrain:ReadVoxels(Region3.new(Vector3.new(fx, -4, fz), Vector3.new(fx + 4, 0, fz + 4)), 4)
		return mats[1][1][1]
	end
	local problems = {}
	for _, p in ipairs({
		{ 114, -198 }, { 210, -198 }, { 114, -122 }, { 210, -122 }, -- corners
		{ 114, -160 }, -- first paved cell east of the road mouth
		{ 130, -160 }, { 184, -160 }, -- Guide, shop floor
	}) do
		local m = cellMaterial(p[1], p[2])
		if m ~= Enum.Material.Pavement then
			table.insert(problems, string.format("cell (%d,%d) is %s, expected Pavement", p[1], p[2], tostring(m)))
		end
	end
	for _, c in ipairs({
		{ 110, -160, Enum.Material.Asphalt }, { 106, -160, Enum.Material.Asphalt }, { 110, -180, Enum.Material.Grass },
		{ 110, -140, Enum.Material.Grass }, { 214, -160, Enum.Material.Grass }, { 160, -204, Enum.Material.Grass },
		{ 160, -116, Enum.Material.Grass },
	}) do
		local m = cellMaterial(c[1], c[2])
		if m ~= c[3] then
			table.insert(problems, string.format("control cell (%d,%d) is %s, expected %s", c[1], c[2], tostring(m), tostring(c[3])))
		end
	end
	check("Café paving is Pavement and the paint stays inside the region", #problems == 0, table.concat(problems, "; "))
end

-- Farm paving and lagoon (Slice 09): world.luau repaints the Grass under the Farm's path, plaza, pool terrace / villa slab, the
-- path south and the deck apron as Pavement (regions P1..P5, see briefs/site07.md) and carves a rectangular lagoon of Water
-- (x 700..800, z 300..352). Same exact voxel read as the plaza check. The controls prove the paint and the water stay inside
-- their regions and leave road C's asphalt (cells ..572 at z 232..248) alone.
do
	local function cellMaterial(x, z)
		local fx, fz = math.floor(x / 4) * 4, math.floor(z / 4) * 4
		local mats = workspace.Terrain:ReadVoxels(Region3.new(Vector3.new(fx, -4, fz), Vector3.new(fx + 4, 0, fz + 4)), 4)
		return mats[1][1][1]
	end
	local problems = {}
	for _, p in ipairs({
		{ 574, 234 }, { 650, 246 }, { 574, 246 }, { 650, 234 }, { 612, 240 }, -- P1 corners and middle
		{ 654, 194 }, { 698, 258 }, { 654, 258 }, { 698, 194 }, { 670, 220 }, { 670, 240 }, -- P2 corners, JeepStop, Guide
		{ 702, 206 }, { 794, 274 }, { 702, 274 }, { 794, 206 }, { 729, 240 }, { 780, 240 }, -- P3 corners, pool, villa
		{ 694, 262 }, { 706, 298 }, { 694, 298 }, { 700, 280 }, -- P4 corners and middle
		{ 710, 286 }, { 750, 298 }, { 710, 298 }, { 750, 286 }, { 730, 294 }, -- P5 corners and deck apron
	}) do
		local m = cellMaterial(p[1], p[2])
		if m ~= Enum.Material.Pavement then
			table.insert(problems, string.format("cell (%d,%d) is %s, expected Pavement", p[1], p[2], tostring(m)))
		end
	end
	for _, p in ipairs({ { 702, 302 }, { 798, 350 }, { 702, 350 }, { 798, 302 }, { 750, 326 } }) do
		local m = cellMaterial(p[1], p[2])
		if m ~= Enum.Material.Water then
			table.insert(problems, string.format("lagoon cell (%d,%d) is %s, expected Water", p[1], p[2], tostring(m)))
		end
	end
	for _, c in ipairs({
		{ 568, 240, Enum.Material.Asphalt }, { 570, 236, Enum.Material.Asphalt }, { 574, 228, Enum.Material.Grass },
		{ 574, 252, Enum.Material.Grass }, { 612, 228, Enum.Material.Grass }, { 612, 252, Enum.Material.Grass },
		{ 650, 190, Enum.Material.Grass }, { 698, 190, Enum.Material.Grass }, { 662, 262, Enum.Material.Grass },
		{ 714, 202, Enum.Material.Grass }, { 798, 240, Enum.Material.Grass }, { 750, 278, Enum.Material.Grass },
		{ 688, 280, Enum.Material.Grass }, { 712, 292, Enum.Material.Pavement }, { 754, 292, Enum.Material.Grass },
		{ 750, 296, Enum.Material.Pavement }, { 760, 296, Enum.Material.Grass }, { 696, 326, Enum.Material.Grass },
		{ 802, 326, Enum.Material.Grass }, { 750, 356, Enum.Material.Grass },
	}) do
		local m = cellMaterial(c[1], c[2])
		if m ~= c[3] then
			table.insert(problems, string.format("control cell (%d,%d) is %s, expected %s", c[1], c[2], tostring(m), tostring(c[3])))
		end
	end
	check("Farm paving is Pavement, the lagoon is Water, and neither spills", #problems == 0, table.concat(problems, "; "))
end

-- Mount Malarayat ground (Slice 10): world.luau cuts a flat clubhouse pad (surface 20.0), grades a ramp from Road D up
-- the slope's north wall, carves a pond (water surface 5.5) with an island green, and repaints plaza / pad / drive / tees /
-- greens / bunkers. The slope is sloped, so a cell's material is the TOP occupied voxel of its column (ReadVoxels, exact), not
-- the y -4..0 cell the flat sites use. Controls prove the paint, the cut and the water stay inside their regions and leave the
-- untouched slope an exact plane (y = 0.1 * (x - 360) - 0.2).
do
	local function topCell(x, z)
		local fx, fz = math.floor(x / 4) * 4, math.floor(z / 4) * 4
		-- ReadVoxels arrays are indexed [x][y][z]; this column is one cell wide, so x and z are always 1
		local mats, occ = workspace.Terrain:ReadVoxels(Region3.new(Vector3.new(fx, -4, fz), Vector3.new(fx + 4, 48, fz + 4)), 4)
		for yi = #mats[1], 1, -1 do
			if occ[1][yi][1] > 0.01 and mats[1][yi][1] ~= Enum.Material.Air then return mats[1][yi][1] end
		end
		return Enum.Material.Air
	end
	local function plane(x) return 0.1 * (x - 360) - 0.2 end
	local M = Enum.Material
	local problems = {}
	local function expect(list, mat, label)
		for _, p in ipairs(list) do
			local m = topCell(p[1], p[2])
			if m ~= mat then table.insert(problems, string.format("%s cell (%d,%d) is %s, expected %s", label, p[1], p[2], tostring(m), tostring(mat))) end
		end
	end
	expect({ { 518, 670 }, { 578, 722 }, { 548, 696 }, { 518, 722 }, { 578, 670 }, -- plaza corners and middle
		{ 558, 706 }, { 670, 842 }, { 558, 842 }, { 670, 706 }, { 614, 774 }, { 600, 740 } }, M.Pavement, "paved")
	expect({ { 450, 504 }, { 450, 520 }, { 450, 544 }, { 450, 552 }, { 450, 620 }, { 450, 700 }, { 446, 700 }, { 470, 698 }, { 514, 698 } }, M.Asphalt, "asphalt")
	expect({ { 444, 776 }, { 484, 776 }, { 482, 806 }, { 456, 812 }, { 492, 844 }, { 474, 830 }, { 462, 776 } }, M.Water, "pond")
	expect({ { 466, 792 }, { 458, 786 }, { 474, 798 }, { 422, 786 }, { 430, 798 }, { 574, 634 }, { 586, 646 }, { 714, 610 }, { 734, 630 },
		{ 382, 582 }, { 394, 594 }, { 390, 706 }, { 410, 726 } }, M.LeafyGrass, "island / tee / green")
	expect({ { 702, 638 }, { 710, 646 }, { 738, 606 }, { 746, 614 }, { 378, 698 }, { 386, 706 }, { 414, 718 }, { 422, 726 } }, M.Sand, "bunker")
	-- controls: Grass just outside each region (and Road D's untouched asphalt south of the ramp start)
	expect({ { 442, 520 }, { 458, 520 }, { 462, 520 }, { 438, 560 }, { 460, 620 }, { 470, 688 }, { 470, 708 }, { 440, 704 },
		{ 512, 684 }, { 584, 700 }, { 548, 664 }, { 548, 728 }, { 552, 740 }, { 676, 740 }, { 614, 700 }, { 614, 848 },
		{ 436, 792 }, { 500, 828 }, { 466, 768 }, { 474, 852 }, { 448, 820 }, { 492, 792 }, { 416, 792 }, { 570, 640 },
		{ 592, 640 }, { 708, 620 }, { 740, 620 }, { 372, 588 }, { 400, 600 }, { 400, 700 }, { 400, 732 }, { 698, 640 },
		{ 750, 610 }, { 374, 702 }, { 426, 722 } }, M.Grass, "control")
	expect({ { 450, 496 } }, M.Asphalt, "control")
	check("Malarayat paint is in place and stays inside its regions", #problems == 0, #problems .. " wrong: " .. table.concat(problems, "; ", 1, math.min(#problems, 6)))

	-- heights by raycast (the Sites folder is excluded by ground())
	local hp = {}
	local function nearly(label, x, z, want, tol)
		local y = ground(x, z)
		if y == nil or math.abs(y - want) > tol then table.insert(hp, string.format("%s (%d,%d) y=%s want %.1f+-%.1f", label, x, z, tostring(y), want, tol)) end
	end
	-- interior samples only: within about 2 studs of the cut wall the terrain mesh is smoothed into the wall
	for _, p in ipairs({ { 584, 712 }, { 614, 774 }, { 662, 836 }, { 584, 836 }, { 662, 712 }, { 640, 760 } }) do nearly("pad", p[1], p[2], 20.0, 0.5) end
	for _, p in ipairs({ { 562, 720 }, { 562, 800 }, { 566, 760 } }) do nearly("natural strip west of the cut", p[1], p[2], 20.0, 1.2) end
	nearly("pond water", 470, 776, 5.5, 0.4)
	nearly("pond water B", 474, 830, 5.5, 0.4)
	nearly("island", 466, 792, 9.0, 0.5) -- fill top 7 measures 9.0 (4-stud cells): a mound 3.5 above the water
	for _, p in ipairs({ { 436, 792 }, { 436, 776 }, { 466, 768 }, { 474, 852 }, { 500, 828 }, { 492, 792 } }) do
		local y = ground(p[1], p[2])
		if y == nil or y < 7.0 then table.insert(hp, string.format("rim (%d,%d) y=%s is under 1.5 above the water", p[1], p[2], tostring(y))) end
	end
	for _, p in ipairs({ { 600, 600 }, { 700, 800 }, { 400, 650 }, { 740, 700 }, { 680, 780 }, { 500, 880 } }) do
		nearly("untouched slope", p[1], p[2], p[1] < 756 and plane(p[1]) or 38.5, 0.6)
	end
	-- the ramp climbs from the floor to the slope, never a step over 2.5 between 4-stud samples, and meets the ground at z 552
	local prev, worst = nil, 0
	for z = 504, 552, 4 do
		local y = ground(450, z)
		if y == nil then table.insert(hp, "ramp (450," .. z .. ") has no terrain") else
			if prev then worst = math.max(worst, math.abs(y - prev)) end
			prev = y
		end
	end
	local yTop = ground(450, 552)
	if worst > 2.5 then table.insert(hp, "ramp has a step of " .. worst) end
	if yTop == nil or math.abs(yTop - plane(450)) > 1.0 then table.insert(hp, "ramp does not meet the slope at z 552: " .. tostring(yTop)) end
	check("Malarayat surfaces: pad flat, pond water level and rim, island, ramp, untouched slope", #hp == 0, table.concat(hp, "; ", 1, math.min(#hp, 6)))
end

-- Tagbakin ground (Slice 11): world.luau extends Road E's asphalt from its old end (-480, 450) south to z 532 and west along
-- z 520..532 to x -548 (the Guide plaza), and repaints the Grass under the Guide plaza (x -604..-548, z 508..564) as Pavement,
-- so the thin JeepStop pad shows. Same exact voxel read as the plaza check (cell = the y -4..0 voxel). The shore, the lake and
-- the water are not touched: the water controls prove the lake edge did not move. Controls sit at least 2 cells away from the
-- road's non-aligned x edges (-486 / -474), whose cells are partly filled.
do
	local function cellMaterial(x, z)
		local fx, fz = math.floor(x / 4) * 4, math.floor(z / 4) * 4
		local mats = workspace.Terrain:ReadVoxels(Region3.new(Vector3.new(fx, -4, fz), Vector3.new(fx + 4, 0, fz + 4)), 4)
		return mats[1][1][1]
	end
	local M = Enum.Material
	local problems = {}
	local function expect(list, mat, label)
		for _, p in ipairs(list) do
			local m = cellMaterial(p[1], p[2])
			if m ~= mat then table.insert(problems, string.format("%s cell (%d,%d) is %s, expected %s", label, p[1], p[2], tostring(m), tostring(mat))) end
		end
	end
	expect({ { -602, 510 }, { -550, 510 }, { -602, 562 }, { -550, 562 }, { -578, 536 }, { -580, 530 }, { -566, 542 }, { -556, 554 },
		{ -592, 526 }, { -550, 526 } }, M.Pavement, "plaza")
	expect({ { -480, 446 }, { -480, 454 }, { -480, 480 }, { -480, 510 }, { -480, 528 }, { -500, 526 }, { -520, 526 }, { -546, 526 } }, M.Asphalt, "road")
	expect({ { -492, 480 }, { -466, 480 }, { -500, 512 }, { -500, 540 }, { -480, 538 }, { -470, 526 }, { -608, 536 }, { -578, 504 },
		{ -578, 568 }, { -544, 546 }, { -544, 510 } }, M.Grass, "control")
	expect({ { -706, 610 }, { -700, 640 }, { -716, 590 } }, M.Water, "lake")
	check("Tagbakin plaza is paved, Road E reaches it, and nothing spills", #problems == 0,
		#problems .. " wrong: " .. table.concat(problems, "; ", 1, math.min(#problems, 6)))
end

-- Tagbakin quay paving (Slice 11, second terrain pass): the terrace and the promenade strips are parts with a top at y 1.2, but
-- the terrain's grass blades still poke through them, so world.luau repaints the Grass under them as Pavement (QUAY, 30
-- stair-stepped 4-aligned rectangles covering the rotated slabs). Interior cells are well inside the slabs; the controls are
-- Grass cells just outside (9..16 studs from the slab edge) and the lake water must be untouched.
do
	local function cellMaterial(x, z)
		local fx, fz = math.floor(x / 4) * 4, math.floor(z / 4) * 4
		local mats = workspace.Terrain:ReadVoxels(Region3.new(Vector3.new(fx, -4, fz), Vector3.new(fx + 4, 0, fz + 4)), 4)
		return mats[1][1][1]
	end
	local M = Enum.Material
	local problems = {}
	local function expect(list, mat, label)
		for _, p in ipairs(list) do
			local m = cellMaterial(p[1], p[2])
			if m ~= mat then table.insert(problems, string.format("%s cell (%d,%d) is %s, expected %s", label, p[1], p[2], tostring(m), tostring(mat))) end
		end
	end
	expect({ { -666, 554 }, { -674, 566 }, { -658, 570 }, { -650, 574 }, { -650, 582 }, { -650, 590 }, { -650, 598 }, { -650, 606 },
		{ -642, 610 }, { -626, 614 }, { -706, 578 }, { -638, 628 }, { -630, 646 }, { -690, 582 } }, M.Pavement, "quay")
	expect({ { -666, 522 }, { -670, 530 }, { -678, 538 }, { -690, 546 }, { -638, 550 }, { -634, 554 }, { -626, 558 }, { -614, 570 },
		{ -602, 586 }, { -702, 548 } }, M.Grass, "control")
	expect({ { -706, 610 }, { -716, 590 }, { -700, 640 } }, M.Water, "lake")
	check("Tagbakin terrace and promenade are paved underneath and the paint stays near them", #problems == 0,
		#problems .. " wrong: " .. table.concat(problems, "; ", 1, math.min(#problems, 6)))
end

-- Baseplate removal is only required once the terrain checks above are green.
if REQUIRE_BASEPLATE_REMOVED then
	check("Baseplate removed", workspace:FindFirstChild("Baseplate") == nil)
end

return results
