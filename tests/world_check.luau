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

-- Baseplate removal is only required once the terrain checks above are green.
if REQUIRE_BASEPLATE_REMOVED then
	check("Baseplate removed", workspace:FindFirstChild("Baseplate") == nil)
end

return results
