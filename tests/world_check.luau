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

-- Baseplate removal is only required once the terrain checks above are green.
if REQUIRE_BASEPLATE_REMOVED then
	check("Baseplate removed", workspace:FindFirstChild("Baseplate") == nil)
end

return results
