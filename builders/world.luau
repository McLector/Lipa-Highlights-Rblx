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

-- The Farm's lagoon (Slice 09): a rectangular pool of water flush at y 0 (same carve / bed / fill pattern as the lakes, but
-- shallow: y -12..0). Edges are multiples of 4. Keep in step with briefs/site07.md.
local LAGOONS = {
	{ x0 = 700, x1 = 800, z0 = 300, z1 = 352 },
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

local function buildLagoons()
	for _, l in ipairs(LAGOONS) do
		local cx, cz = (l.x0 + l.x1) / 2, (l.z0 + l.z1) / 2
		local sx, sz = l.x1 - l.x0, l.z1 - l.z0
		T:FillBlock(CFrame.new(cx, -6, cz), Vector3.new(sx, 12, sz), Enum.Material.Air) -- carve pit (y -12..0)
		T:FillBlock(CFrame.new(cx, -10, cz), Vector3.new(sx, 4, sz), Enum.Material.Sand) -- bed (y -12..-8)
		T:FillBlock(CFrame.new(cx, -4, cz), Vector3.new(sx, 8, sz), Enum.Material.Water) -- water (y -8..0)
	end
	task.wait()
end

-- Plaza Independencia ground. The plaza paving built by builders/site01.luau (PlazaPaving, x -100..100, z 6..100, plus
-- the wing apron in front of it) is only 0.1 stud thick, so the terrain's grass blades would poke through it. Repaint the
-- Grass under the plaza as Pavement. Keep this region in step with PlazaPaving in site01.luau.
-- ReplaceMaterial takes a Region3 in studs, aligned to the 4-stud grid, with resolution exactly 4 (docs). Only Grass is
-- converted, so the asphalt road mouth at (0,100..) is untouched; the terrain surface height does not change.
-- Carmel forecourt (Slice 04): same treatment under the monastery's paved forecourt. Keep this region in step with the
-- forecourt paving in builders/site05.luau. Edges are multiples of 4, as ReplaceMaterial requires.
local PAVED = {
	{ x0 = -100, x1 = 100, z0 = 0, z1 = 100 }, -- Plaza Independencia
	{ x0 = -352, x1 = -248, z0 = -600, z1 = -508 }, -- Carmel forecourt
	-- The Outlets (Slice 05): the tall grass blades bury thin paving and poke through the pitch turf. Keep these in step with
	-- builders/site06.luau (arrival plaza + forecourt, entry path / spur / sign apron / car park, pitch + stand).
	{ x0 = 472, x1 = 592, z0 = -724, z1 = -604 },
	{ x0 = 424, x1 = 612, z0 = -632, z1 = -548 },
	{ x0 = 636, x1 = 708, z0 = -752, z1 = -612 },
	-- The Market (Slice 06): hall, stall yard and aisle (x -276..-128, z 80..240, the footprint's z edges). x1 -128 stops at the
	-- west edge of road F's asphalt cells (x -128..-120). Keep in step with builders/site02.luau.
	{ x0 = -276, x1 = -128, z0 = 80, z1 = 240 },
	-- Lomi King (Slice 07): shophouse floor, front step, forecourt and driveway (x 128..228, z 100..180, the footprint). x0 128
	-- stops at the east edge of road G's asphalt cells (x 120..128). Keep in step with builders/site03.luau.
	{ x0 = 128, x1 = 228, z0 = 100, z1 = 180 },
	-- Café de Lipa (Slice 08): terrace, unit floor and forecourt (x 112..212, z -200..-120, the footprint). x0 112 stops at the
	-- east edge of road H's asphalt cells (x 96..112). Keep in step with builders/site04.luau.
	{ x0 = 112, x1 = 212, z0 = -200, z1 = -120 },
	-- The Farm at San Benito (Slice 09): entry path, arrival plaza, pool terrace and villa slab, the path south and the shore apron
	-- of the lagoon deck. x0 572 of P1 stops at the east edge of road C's asphalt cells (x ..572). Regions overlap on purpose
	-- (P3 and P4); ReplaceMaterial is idempotent. Keep in step with builders/site07.luau and briefs/site07.md.
	{ x0 = 572, x1 = 652, z0 = 232, z1 = 248 }, -- P1 entry path
	{ x0 = 652, x1 = 700, z0 = 192, z1 = 260 }, -- P2 arrival plaza
	{ x0 = 700, x1 = 796, z0 = 204, z1 = 276 }, -- P3 east walk, pool, terrace, villa slab
	{ x0 = 692, x1 = 708, z0 = 260, z1 = 300 }, -- P4 path south to the lagoon
	{ x0 = 708, x1 = 752, z0 = 284, z1 = 300 }, -- P5 shore apron and the land end of the deck
}
local function buildPlazaGround()
	for _, r in ipairs(PAVED) do
		T:ReplaceMaterial(
			Region3.new(Vector3.new(r.x0, -4, r.z0), Vector3.new(r.x1, 4, r.z1)),
			4,
			Enum.Material.Grass,
			Enum.Material.Pavement
		)
	end
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

-- Mount Malarayat Golf & Country Club (Slice 10). Runs AFTER buildSlope(): it reshapes and repaints the slope. Keep in step with
-- briefs/site08.md and tests/world_check.luau. The slope is an exact plane, surface y = 0.1 * (x - 360) - 0.2 for x 380..756.
-- Measured 2026-10-16: an Air cut whose bottom is at y=18 leaves a surface of 20.0 (about 20.1 in the sky scratch test); a Water fill
-- topping at T has its surface at exactly T; a wedge ramp reaches its top height within about 0.5 stud.
local MALARAYAT = {
	-- Road D's asphalt stops at z 536 but the slope wedge starts at z 540 with a vertical wall 6..9 high, so the road never
	-- reached the site. A Grass wedge ramp (x 440..460, rising toward +z from the floor at z 500 to about 9 at z 548) joins them.
	ramp = { x0 = 440, x1 = 460, z0 = 500, z1 = 548, bottom = -2, top = 8 },
	-- Clubhouse + forecourt pad: CUT ONLY (no fill), flat at 20.0 for x >= 572. An Air cut only leaves a flat 20.0 where the original
	-- ground is at least about 21 (measured: a cut from x 556 left 18.0 and 19.3 in the first two columns, a trench), so the cut
	-- starts at x 572 and the natural slope (19.4..20.8) meets it. The paint below still starts at 556.
	pad = { x0 = 572, x1 = 672, z0 = 704, z1 = 844, cutBottom = 18, cutTop = 44 },
	-- Pond (two overlapping rectangles, a kidney shape): bed cut to y 0, sand bed, water surface y 5.5. The rim is the original
	-- ground (7.4 at the west bank, rising east), so the freeboard is at least 1.9 everywhere.
	ponds = { { x0 = 440, x1 = 488, z0 = 772, z1 = 812 }, { x0 = 452, x1 = 496, z0 = 808, z1 = 848 } },
	waterTop = 5.5,
	island = { x0 = 456, x1 = 476, z0 = 784, z1 = 800, top = 7 }, -- Grass fill from y 0: top 5 -> surface 6.0 (the water's cell wins), top 7 -> 9.0 (measured), a mound 3.5 above the water (5.5)
	paint = {
		-- { material, x0, x1, z0, z1 }, 4-aligned; the y range is derived from the slope (see paintSlope)
		{ Enum.Material.Pavement, 516, 580, 668, 724 }, -- Guide plaza
		{ Enum.Material.Pavement, 556, 672, 704, 844 }, -- clubhouse pad, forecourt, drive-through
		{ Enum.Material.Asphalt, 444, 456, 548, 704 }, -- drive south from the ramp
		{ Enum.Material.Asphalt, 456, 520, 692, 704 }, -- drive east to the plaza
		{ Enum.Material.LeafyGrass, 420, 432, 784, 800 }, -- hole 1 tee (west bank)
		{ Enum.Material.LeafyGrass, 572, 588, 632, 648 }, -- hole 2 tee
		{ Enum.Material.LeafyGrass, 712, 736, 608, 632 }, -- hole 2 green
		{ Enum.Material.LeafyGrass, 380, 396, 580, 596 }, -- hole 3 tee
		{ Enum.Material.LeafyGrass, 388, 412, 704, 728 }, -- hole 3 green
		{ Enum.Material.Sand, 700, 712, 636, 648 }, -- hole 2 bunkers
		{ Enum.Material.Sand, 736, 748, 604, 616 },
		{ Enum.Material.Sand, 376, 388, 696, 708 }, -- hole 3 bunkers
		{ Enum.Material.Sand, 412, 424, 716, 728 },
	},
}

local function slopeSurface(x)
	return math.max(0, 0.1 * (x - 360) - 0.2)
end

-- ReplaceMaterial takes a 4-aligned Region3; the y range spans the slope under the region plus one cell each way.
local function paintSlope(material, x0, x1, z0, z1)
	local gLo, gHi = slopeSurface(math.min(x0, x1)), slopeSurface(math.max(x0, x1))
	local lo = math.floor(gLo / 4) * 4 - 4
	local hi = math.ceil(gHi / 4) * 4 + 4
	T:ReplaceMaterial(Region3.new(Vector3.new(x0, lo, z0), Vector3.new(x1, hi, z1)), 4, Enum.Material.Grass, material)
end

local function buildMalarayatGround()
	local r = MALARAYAT.ramp
	T:FillWedge(
		CFrame.new((r.x0 + r.x1) / 2, (r.bottom + r.top) / 2, (r.z0 + r.z1) / 2),
		Vector3.new(r.x1 - r.x0, r.top - r.bottom, r.z1 - r.z0),
		Enum.Material.Grass
	)
	-- the ramp covers Road D's last asphalt cells (z 500..536): lay asphalt back over its whole length (surface 0..9)
	T:ReplaceMaterial(Region3.new(Vector3.new(444, -4, 500), Vector3.new(456, 16, 548)), 4, Enum.Material.Grass, Enum.Material.Asphalt)
	task.wait()

	local p = MALARAYAT.pad
	T:FillBlock(
		CFrame.new((p.x0 + p.x1) / 2, (p.cutBottom + p.cutTop) / 2, (p.z0 + p.z1) / 2),
		Vector3.new(p.x1 - p.x0, p.cutTop - p.cutBottom, p.z1 - p.z0),
		Enum.Material.Air
	)
	task.wait()

	-- pond: all cuts first, then the sand bed, then the water, so an overlap is never wiped by a later cut
	for _, b in ipairs(MALARAYAT.ponds) do
		T:FillBlock(CFrame.new((b.x0 + b.x1) / 2, 12, (b.z0 + b.z1) / 2), Vector3.new(b.x1 - b.x0, 24, b.z1 - b.z0), Enum.Material.Air)
	end
	for _, b in ipairs(MALARAYAT.ponds) do
		T:FillBlock(CFrame.new((b.x0 + b.x1) / 2, -2, (b.z0 + b.z1) / 2), Vector3.new(b.x1 - b.x0, 4, b.z1 - b.z0), Enum.Material.Sand)
	end
	local wt = MALARAYAT.waterTop
	for _, b in ipairs(MALARAYAT.ponds) do
		T:FillBlock(CFrame.new((b.x0 + b.x1) / 2, (2 + wt) / 2, (b.z0 + b.z1) / 2), Vector3.new(b.x1 - b.x0, wt - 2, b.z1 - b.z0), Enum.Material.Water)
	end
	local i = MALARAYAT.island
	T:FillBlock(CFrame.new((i.x0 + i.x1) / 2, (0 + i.top) / 2, (i.z0 + i.z1) / 2), Vector3.new(i.x1 - i.x0, i.top, i.z1 - i.z0), Enum.Material.Grass)
	T:ReplaceMaterial(Region3.new(Vector3.new(i.x0, 0, i.z0), Vector3.new(i.x1, 12, i.z1)), 4, Enum.Material.Grass, Enum.Material.LeafyGrass)
	task.wait()

	for _, q in ipairs(MALARAYAT.paint) do
		paintSlope(q[1], q[2], q[3], q[4], q[5])
	end
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
buildLagoons()
buildRoads()
buildPlazaGround()
buildSlope()
buildMalarayatGround()
buildWorldModels()
placeSpawn()
game.Lighting.ClockTime = 15.5
task.wait(0.5)
return { cells = T:CountCells(), world = workspace:FindFirstChild("World") ~= nil }
