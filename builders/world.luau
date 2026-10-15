-- world.luau: builds the Lipa world (terrain floor, roads, lake, Malarayat slope, boundary, backdrops, spawn).
-- IDEMPOTENT: clears all terrain and Workspace.World first. Run in Edit mode via execute_luau.
-- Calibrated 2026-10-15: a terrain fill topping out at y=T gives a surface at T+2, so the floor tops out at y=-2.
-- Terrain only becomes raycast-queryable after a task.wait(), so wait before verifying.
-- Does NOT delete the Baseplate: that happens only after tests/world_check.luau passes.
local T = workspace.Terrain
local FLOOR_TOP = -2 -- fill top; surface lands at y=0
local FLOOR_DEPTH = 14
local EXTENT = 1400 -- floor spans +/-1400 so backdrops have ground to sit on

-- Footprint-aware roads (centre points). Polylines are axis-aligned; ends stop flush at site footprints.
local ROADS = {
	{ name = "A_to_Carmel", w = 12, pts = { { 0, -100 }, { 0, -460 }, { -300, -460 }, { -300, -510 } } },
	{ name = "B_to_Outlets", w = 12, joinStart = true, pts = { { 0, -460 }, { 430, -460 }, { 430, -550 } } },
	{ name = "C_to_Farm", w = 12, pts = { { 120, 0 }, { 450, 0 }, { 450, 240 }, { 570, 240 } } },
	{ name = "D_to_Malarayat", w = 12, joinStart = true, pts = { { 450, 240 }, { 450, 560 } } },
	{ name = "E_to_Tagbakin", w = 12, pts = { { 0, 100 }, { 0, 350 }, { -480, 350 }, { -480, 450 } } },
	{ name = "F_to_Market", w = 8, pts = { { -125, 70 }, { -125, 160 } } },
	{ name = "G_to_Lomi", w = 8, pts = { { 125, 100 }, { 125, 140 } } },
	{ name = "H_to_Cafe", w = 8, pts = { { 0, -100 }, { 0, -160 }, { 110, -160 } } },
}

-- Lake in the SW (Tagbakin shore). Pit is carved, sand bed laid, then water filled flush to y=0.
-- Terrain water snaps to multiples of 4, so -2 is not reachable (measured 2026-10-15); 0 gives no cliff at the bank.
local LAKES = {
	{ x = -860, z = 820, r = 280 },
	{ x = -1130, z = 1130, r = 420 }, -- far water so the volcano island sits in the lake
}

local function clearAll()
	T:Clear()
	local old = workspace:FindFirstChild("World")
	if old then old:Destroy() end
end

local function buildFloor()
	local step = 280
	for x = -EXTENT, EXTENT - step, step do
		for z = -EXTENT, EXTENT - step, step do
			T:FillBlock(
				CFrame.new(x + step / 2, FLOOR_TOP - FLOOR_DEPTH / 2, z + step / 2),
				Vector3.new(step, FLOOR_DEPTH, step),
				Enum.Material.Grass
			)
		end
		task.wait()
	end
end

local function buildRoads()
	for _, road in ipairs(ROADS) do
		local w = road.w
		local n = #road.pts
		for i = 1, n - 1 do
			local x1, z1 = road.pts[i][1], road.pts[i][2]
			local x2, z2 = road.pts[i + 1][1], road.pts[i + 1][2]
			-- extend by w/2 only at interior joints (and at a start that joins another road)
			local capA = (i > 1 or road.joinStart) and w / 2 or 0
			local capB = (i < n - 1) and w / 2 or 0
			local cx, cz, sx, sz
			if x1 == x2 then
				local dir = z2 >= z1 and 1 or -1
				local a, b = z1 - dir * capA, z2 + dir * capB
				cx, cz = x1, (a + b) / 2
				sx, sz = w, math.abs(b - a)
			else
				local dir = x2 >= x1 and 1 or -1
				local a, b = x1 - dir * capA, x2 + dir * capB
				cx, cz = (a + b) / 2, z1
				sx, sz = math.abs(b - a), w
			end
			T:FillBlock(CFrame.new(cx, FLOOR_TOP - 2, cz), Vector3.new(sx, 4, sz), Enum.Material.Asphalt)
		end
		task.wait()
	end
end

local function buildLakes()
	for _, lake in ipairs(LAKES) do
		T:FillCylinder(CFrame.new(lake.x, -8, lake.z), 16, lake.r, Enum.Material.Air) -- carve pit (y -16..0)
		T:FillCylinder(CFrame.new(lake.x, -14, lake.z), 8, lake.r, Enum.Material.Sand) -- bed (y -18..-10)
		T:FillCylinder(CFrame.new(lake.x, -7, lake.z), 14, lake.r, Enum.Material.Water) -- water (y -14..0)
		task.wait()
	end
end

-- Plaza Independencia ground. The plaza paving built by builders/site01.luau (PlazaPaving, x -100..100, z 6..100, plus
-- the wing apron in front of it) is only 0.1 stud thick, so the terrain's grass blades would poke through it. Repaint the
-- Grass under the plaza as Pavement. Keep this region in step with PlazaPaving in site01.luau.
-- ReplaceMaterial takes a Region3 in studs, aligned to the 4-stud grid, with resolution exactly 4 (docs). Only Grass is
-- converted, so the asphalt road mouth at (0,100..) is untouched; the terrain surface height does not change.
local PLAZA = { x0 = -100, x1 = 100, z0 = 0, z1 = 100 }
local function buildPlazaGround()
	T:ReplaceMaterial(
		Region3.new(Vector3.new(PLAZA.x0, -4, PLAZA.z0), Vector3.new(PLAZA.x1, 4, PLAZA.z1)),
		4,
		Enum.Material.Grass,
		Enum.Material.Pavement
	)
	task.wait()
end

-- Malarayat slope: a wedge rising toward +X. Wedge ramps toward local +Z, so rotate 90 degrees about Y.
local function buildSlope()
	local x0, x1 = 320, 760 -- starts west of the footprint so the ground reads ~0 at x=360
	local z0, z1 = 540, 900
	local bottom, top = -6, 38
	local cx, cz = (x0 + x1) / 2, (z0 + z1) / 2
	T:FillWedge(
		CFrame.new(cx, (bottom + top) / 2, cz) * CFrame.Angles(0, math.rad(90), 0),
		Vector3.new(z1 - z0, top - bottom, x1 - x0), -- local X = world Z span, local Z = world X (ramp) span
		Enum.Material.Grass
	)
	-- plateau east of the ramp so the clubhouse terrace has a flat top
	T:FillBlock(CFrame.new((x1 + 1000) / 2, (bottom + top) / 2 - 1, cz), Vector3.new(1000 - x1, top - bottom - 2, z1 - z0), Enum.Material.Grass)
	task.wait()
end

local function part(parent, name, size, cframe, props)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Anchored = true
	for k, v in pairs(props or {}) do p[k] = v end
	p.Parent = parent
	return p
end

local function buildWorldModels()
	local world = Instance.new("Folder")
	world.Name = "World"

	-- Invisible boundary walls at +/-1000 (inner faces on the boundary).
	local boundary = Instance.new("Folder")
	boundary.Name = "Boundary"
	boundary.Parent = world
	local wallProps = { Transparency = 1, CanCollide = true, CanQuery = false, CanTouch = false, CastShadow = false }
	part(boundary, "WallNorth", Vector3.new(2016, 300, 8), CFrame.new(0, 150, -1004), wallProps)
	part(boundary, "WallSouth", Vector3.new(2016, 300, 8), CFrame.new(0, 150, 1004), wallProps)
	part(boundary, "WallWest", Vector3.new(8, 300, 2016), CFrame.new(-1004, 150, 0), wallProps)
	part(boundary, "WallEast", Vector3.new(8, 300, 2016), CFrame.new(1004, 150, 0), wallProps)

	-- Persistent far backdrops: Mount Malarayat range (E/SE) and the Taal volcano island (SW, in the lake).
	local back = Instance.new("Model")
	back.Name = "Backdrops"
	back.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	back.Parent = world
	local ballProps = { Shape = Enum.PartType.Ball, CanCollide = false, CanQuery = false, CanTouch = false, CastShadow = false, Material = Enum.Material.Grass }
	local function ball(name, x, y, z, d, color)
		local p = part(back, name, Vector3.new(d, d, d), CFrame.new(x, y, z), ballProps)
		p.Color = color
	end
	local green, dark = Color3.fromRGB(86, 118, 74), Color3.fromRGB(64, 92, 62)
	ball("Malarayat_A", 1320, -140, 120, 760, dark)
	ball("Malarayat_B", 1360, -180, 560, 900, green)
	ball("Malarayat_C", 1280, -120, 980, 700, dark)
	ball("Malarayat_D", 1380, -160, -330, 640, green)
	ball("Taal_Volcano", -1130, -110, 1130, 560, Color3.fromRGB(104, 118, 82))
	ball("Taal_Ridge", -1030, -90, 1210, 360, Color3.fromRGB(94, 108, 74))

	-- World-level folder for later builders (plaza signage, credits board etc.).
	world.Parent = workspace
end

local function placeSpawn()
	local spawn = workspace:FindFirstChild("SpawnLocation")
	if spawn then
		spawn.CFrame = CFrame.lookAt(Vector3.new(0, 0.5, 70), Vector3.new(0, 0.5, 0)) -- faces north (-Z)
	end
end

-- run
clearAll()
buildFloor()
buildLakes()
buildRoads()
buildPlazaGround()
buildSlope()
buildWorldModels()
placeSpawn()
game.Lighting.ClockTime = 15.5
task.wait(0.5)
return { cells = T:CountCells(), world = workspace:FindFirstChild("World") ~= nil }
