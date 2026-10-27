-- site10_forecourt: the terraced steps and the forecourt (loop, flagpole, parking, roads) of Site 10 (New Lipa City Hall). Studio copy: ServerStorage.Builders.site10_forecourt.
-- Owner container: Steps AND Forecourt. Module budget: 650 parts. Check group: shared.site10_only = "forecourt" (tests/site10_check.luau).
-- Design: scratch/site10/layout.md ("Steps", "Forecourt") and model.py; the owner's drawing "Lipa City Hall Blueprint.png" is the truth.
-- PLAN (all local coordinates, lx east, lz south, y up from the ground)
--   Steps.Stair     : StairTread1..8 (tread 3.5, riser 0.5, lz -64..-46), stepped cheek walls, landing and the plateau strips at y 4.
--   Steps.Terrace   : 5 grass strips each side (TerraceS1..5 south, TerraceN1..5 north). Each strip = concrete body + grass top (the part named
--                     TerraceSn / TerraceNn, Grass) + a concrete front wall TerraceSnWall / TerraceNnWall. Strips rise 0.8 per step toward the wing.
--   Forecourt.Loop  : LoopIsland1..2 (grass, R 8), IslandKerb ring, LoopApron ring, LoopRoad ring (asphalt R 10..19), LoopOuterKerb (R 19..20,
--                     open to the parking and to the front road), FlagpoleBase, Flagpole (36 tall), Flag1/Flag2 (blue, red), FlagTriangleA/B (white),
--                     FlagSun (plain yellow disc). The flag is colour blocks only: no text, no emblem.
--   Forecourt.Plaza : WalkPaving (+ inlay joints), PlazaBandPaving, LightPole1..5.
--   Forecourt.Parking: ParkingApron, BayLineA/B/C (3 rows of 5 bays), wheel stops, PalmIsland (the palms and cars are in Landscape), east kerb.
--   Forecourt.Road  : FrontRoad, FrontRoadLink (flat wedge), NorthRoad (+ dashes), NorthVerge, WestServiceRoad, ArezaWalk.
-- Flat paving tops out at y 0.4 (thick enough to hide the grass terrain); kerbs 0.9. Nothing solid (top > 0.6) near the pins: JeepStop (115, 75),
-- Jeepney (115, 89) are 16+ studs from the nearest paving; the spawn pad, Guide and InfoPanel are 12+ studs from the nearest strip.
-- Pure function of env: nothing is read from the DataModel, so it is idempotent (the assembler replaces Steps and Forecourt each run).
return function(env)
	local V, CF, ANG, PI = env.V, env.CF, env.ANG, env.PI
	local box, vcyl = env.box, env.vcyl
	local C3 = Color3.fromRGB
	local sin, cos, tan = math.sin, math.cos, math.tan

	local CONC, SLATE, ASPH, GRASS = C3(190, 192, 190), C3(178, 180, 178), C3(62, 66, 72), C3(96, 140, 70)
	local LINEC, METAL, DARKSLATE = C3(235, 220, 120), C3(210, 212, 214), C3(150, 154, 158)
	local MCONC, MSLATE, MASPH, MGRASS = Enum.Material.Concrete, Enum.Material.Slate, Enum.Material.Asphalt, Enum.Material.Grass
	local MPLAS, MMETAL = Enum.Material.SmoothPlastic, Enum.Material.Metal
	local FLAT = 0.4

	------------------------------------------------------------------ Steps
	local stairF = env.newFolder("Steps", "Stair")
	env.section("Steps", function(ctx)
		for i = 1, 8 do
			local x1 = 74.5 - 3.5 * (i - 1)
			local x0 = x1 - 3.5
			box(ctx, "StairTread" .. i, x0, x1, 0, 0.5 * i, -64, -46, CONC, MCONC)
			box(ctx, "StairCheekL" .. i, x0, x1, 0, 0.5 * i + 0.9, -46.8, -46, CONC, MCONC)
			box(ctx, "StairCheekR" .. i, x0, x1, 0, 0.5 * i + 0.9, -64, -63.2, CONC, MCONC)
		end
		box(ctx, "StairLanding", 41, 46.5, 0, 4, -64, -46, CONC, MCONC)
		box(ctx, "LandingStrip1", 41, 47, 0, 4, -117, -64, CONC, MCONC)
		box(ctx, "LandingStrip2", 41, 47, 0, 4, -46, -4, CONC, MCONC)
	end, stairF)

	local terraceF = env.newFolder("Steps", "Terrace")
	env.section("Steps", function(ctx)
		local zSouthEnd = { 22.6, 16.2, 9.9, 3.6, -2.7 }
		for i = 1, 5 do
			local x1 = 74.5 - 5.5 * (i - 1)
			local x0 = x1 - 5.5
			local h = 0.8 * i
			for _, side in ipairs({ "S", "N" }) do
				local z0, z1 = -46, zSouthEnd[i]
				if side == "N" then z0, z1 = -116, -64 end
				local n = "Terrace" .. side .. i
				box(ctx, n .. "Body", x0, x1, 0, h - 0.4, z0, z1, CONC, MCONC)
				box(ctx, n, x0, x1 - 0.6, h - 0.4, h, z0, z1, GRASS, MGRASS)
				box(ctx, n .. "Wall", x1 - 0.6, x1, 0, h + 0.45, z0, z1, CONC, MCONC)
			end
		end
	end, terraceF)

	------------------------------------------------------------------ Forecourt: loop
	local CX, CZ = 99, -58
	-- A ring of n box segments between radii rin and rout around the island centre. th runs clockwise from north (-z).
	local function ring(ctx, name, rin, rout, n, y0, y1, color, mat, skip)
		local rm, d = (rin + rout) / 2, rout - rin
		local len = 2 * rout * tan(PI / n) + 0.1
		local made = 0
		for k = 0, n - 1 do
			if not (skip and skip[k]) then
				made += 1
				local th = k * 2 * PI / n
				local cf = CF(CX + rm * sin(th), (y0 + y1) / 2, CZ - rm * cos(th)) * ANG(0, PI / 2 - th, 0)
				ctx:part(name .. made, V(d, y1 - y0, len), cf, color, mat)
			end
		end
	end

	local loopF = env.newFolder("Forecourt", "Loop")
	env.section("Forecourt", function(ctx)
		vcyl(ctx, "LoopIsland1", CX, CZ, 0, 0.6, 16, GRASS, MGRASS)
		vcyl(ctx, "LoopIsland2", CX, CZ, 0.6, 0.85, 10, C3(108, 150, 80), MGRASS)
		ring(ctx, "IslandKerb", 8, 9, 16, 0, 0.9, CONC, MCONC)
		ring(ctx, "LoopApron", 9, 10, 16, 0, FLAT, SLATE, MSLATE)
		ring(ctx, "LoopRoad", 10, 19, 24, 0, FLAT, ASPH, MASPH)
		-- the outer kerb is open to the parking apron (north) and to the front road (south)
		ring(ctx, "LoopOuterKerb", 19, 20, 24, 0, 0.9, CONC, MCONC, { [23] = true, [0] = true, [1] = true, [10] = true, [11] = true, [12] = true })
		vcyl(ctx, "FlagpoleBase", CX, CZ, 0.6, 1.4, 3, CONC, MCONC)
		vcyl(ctx, "Flagpole", CX, CZ, 1.4, 36, 0.7, METAL, MMETAL)
		env.ball(ctx, "FlagpoleTop", CX, 36.4, CZ, 1.1, C3(224, 196, 90), MMETAL)
		-- the flag flies to the north (-z) from the pole; plain colour blocks, no emblem
		local zh = CZ - 0.35
		local BLUE, RED, WHITE, YEL = C3(0, 56, 168), C3(200, 24, 40), C3(244, 244, 240), C3(250, 204, 40)
		box(ctx, "Flag1", CX - 0.1, CX + 0.1, 31.25, 33.5, zh - 6.55, zh, BLUE, MPLAS)
		box(ctx, "Flag2", CX - 0.1, CX + 0.1, 29, 31.25, zh - 6.55, zh, RED, MPLAS)
		ctx:wedge("FlagTriangleA", V(0.3, 2.25, 3.9), CF(CX, 31.25 + 1.125, zh - 1.95), WHITE, MPLAS)
		ctx:wedge("FlagTriangleB", V(0.3, 2.25, 3.9), CF(CX, 31.25 - 1.125, zh - 1.95) * ANG(0, 0, PI), WHITE, MPLAS)
		ctx:cyl("FlagSun", V(0.5, 1.0, 1.0), CF(CX, 31.25, zh - 1.3), YEL, MPLAS)
	end, loopF)

	------------------------------------------------------------------ Forecourt: plaza
	local plazaF = env.newFolder("Forecourt", "Plaza")
	env.section("Forecourt", function(ctx)
		box(ctx, "WalkPaving", 75, 97, 0, FLAT, -36, 34, SLATE, MSLATE)
		for i = 1, 3 do -- darker inlay joints across the walk
			local z = -36 + 17.5 * i
			box(ctx, "WalkPavingInlay" .. i, 75, 97, FLAT, FLAT + 0.05, z - 0.3, z + 0.3, DARKSLATE, MSLATE)
		end
		box(ctx, "PlazaBandPaving", 75, 79, 0, FLAT, -118, -36, SLATE, MSLATE)
		-- paved plaza south of the walk (carries the local residents; keeps clear of the spawn pad lx 56..68, lz 39..51)
		box(ctx, "WalkPavingSouth1", 70, 97, 0, FLAT, 34, 84, SLATE, MSLATE)
		box(ctx, "WalkPavingSouth2", 60, 70, 0, FLAT, 56, 84, SLATE, MSLATE)
		for i = 1, 5 do
			local z = 28 - 14 * (i - 1)
			vcyl(ctx, "LightPole" .. i, 90, z, FLAT, 9, 0.6, C3(80, 84, 88), MMETAL)
			box(ctx, "LightHead" .. i, 88.8, 90.4, 8.8, 9.2, z - 0.4, z + 0.4, C3(80, 84, 88), MMETAL)
		end
	end, plazaF)

	------------------------------------------------------------------ Forecourt: parking
	local parkF = env.newFolder("Forecourt", "Parking")
	env.section("Forecourt", function(ctx)
		box(ctx, "ParkingApron", 79, 119.5, 0, FLAT, -118, -76, ASPH, MASPH)
		local rows = { { "A", 80, 80 }, { "B", 97, 97 }, { "C", 109.5, 109.5 } } -- name, bay x0, wheel-stop x0 (the bays are 9 deep)
		for _, r in ipairs(rows) do
			for j = 0, 5 do
				local z = -80 - 6.4 * j
				box(ctx, "BayLine" .. r[1] .. (j + 1), r[2], r[2] + 9, FLAT, FLAT + 0.06, z - 0.15, z + 0.15, LINEC, MPLAS)
			end
			for j = 1, 5 do
				local zc = -80 - 6.4 * (j - 0.5)
				box(ctx, "WheelStop" .. r[1] .. j, r[3], r[3] + 1, FLAT, 0.8, zc - 1.2, zc + 1.2, CONC, MCONC)
			end
		end
		box(ctx, "PalmIsland", 106.3, 109.2, 0, 0.6, -112.4, -80, GRASS, MGRASS)
		box(ctx, "PalmKerbW", 106, 106.3, 0, 0.7, -112.4, -80, CONC, MCONC)
		box(ctx, "PalmKerbE", 109.2, 109.5, 0, 0.7, -112.4, -80, CONC, MCONC)
		box(ctx, "ParkingKerbEast", 118.8, 119.5, 0, 0.6, -118, -76, CONC, MCONC)
	end, parkF)

	------------------------------------------------------------------ Forecourt: roads
	local roadF = env.newFolder("Forecourt", "Road")
	env.section("Forecourt", function(ctx)
		box(ctx, "FrontRoad", 97, 119.5, 0, FLAT, -38, 31, ASPH, MASPH)
		-- diagonal link toward the Areza corner: flat right triangle (97,31) (119.5,59) (119.5,31); right angle at (119.5, 31)
		local c = Vector3.new(119.5 - 22.5 / 2, FLAT / 2, 31 + 28 / 2)
		local wedgeCF = CFrame.fromMatrix(c, Vector3.new(0, 1, 0), Vector3.new(0, 0, 1), Vector3.new(1, 0, 0))
		ctx:wedge("FrontRoadLink", V(FLAT, 28, 22.5), wedgeCF, ASPH, MASPH)

		local nx0, nx1 = -22, 119.5
		local seg = (nx1 - nx0) / 6
		for i = 1, 6 do
			box(ctx, "NorthRoad" .. i, nx0 + seg * (i - 1), nx0 + seg * i, 0, FLAT, -137, -118, ASPH, MASPH)
		end
		for i = 1, 12 do
			local x = nx0 + 4 + 11.5 * (i - 1)
			box(ctx, "RoadDash" .. i, x, x + 5, FLAT, FLAT + 0.06, -127.65, -127.35, LINEC, MPLAS)
		end
		box(ctx, "NorthVerge1", nx0, 49, 0, 0.5, -141, -137, SLATE, MSLATE)
		box(ctx, "NorthVerge2", 49, nx1, 0, 0.5, -141, -137, SLATE, MSLATE)
		for i = 1, 3 do
			local z0 = -141 + 45.7 * (i - 1)
			box(ctx, "WestServiceRoad" .. i, -52, -38, 0, FLAT, z0, z0 + 45.7, ASPH, MASPH)
		end
		for i = 1, 3 do
			local x0 = -52 + 57.34 * (i - 1)
			box(ctx, "ArezaWalk" .. i, x0, x0 + 57.34, 0, 0.5, 113, 117, SLATE, MSLATE)
		end
	end, roadF)
end
