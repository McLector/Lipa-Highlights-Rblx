-- site10_landscape: the trees, palms, shrubs, pocket gardens and parked cars of Site 10 (New Lipa City Hall). Studio copy: ServerStorage.Builders.site10_landscape.
-- Owner container: Landscape (incl. Landscape.PocketGardens). Module budget: 450 parts. Check group: shared.site10_only = "landscape" (tests/site10_check.luau).
-- Design: scratch/site10/layout.md ("Landscape") and model.py; the owner's drawing "Lipa City Hall Blueprint.png" is the truth.
-- PLAN
--   Landscape.Trees         : Models WalkTree1..10 (the row in the planter strip of the walk) and Tree1..4 (two on the palm median, two at the corners of the
--                             parking apron). Each = Trunk + 3 canopy balls. WalkPlanter (grass strip with a brick edge) is the planter of the row.
--   Landscape.Palms         : Models Palm1, Palm2 on the median (PalmTrunk + 6 fronds).
--   Landscape.Shrubs        : ShrubS1..5 on the south terrace strips, ShrubN1..8 on the north ones (two balls each, standing on the strip top).
--   Landscape.PocketGardens : Models PocketGarden1..3, low planters on the landing in front of the wing (4 walls, soil, 3 shrubs).
--   Landscape.Cars          : Models Car_A1..5, Car_B1..4, Car_C1..3, Car_Loop1, Car_North1..2 (15). Each = CarSill, CarBody, CarCabin, 2 glass parts and 4
--                             Wheel parts, in muted colours: no brand marks, no text, no decals.
-- Pure function of env: nothing is read from the DataModel, so it is idempotent (the assembler replaces Landscape each run).
return function(env)
	local V, CF, ANG, PI = env.V, env.CF, env.ANG, env.PI
	local box, vcyl, ball = env.box, env.vcyl, env.ball
	local C3 = Color3.fromRGB
	local rad = math.rad

	local LEAF, LEAF2, TRUNK = C3(82, 130, 70), C3(70, 118, 60), C3(104, 78, 54)
	local GRASS, BRICK, CONC = C3(96, 140, 70), C3(150, 100, 85), C3(190, 192, 190)
	local MGRASS, MBRICK, MCONC, MWOOD = Enum.Material.Grass, Enum.Material.Brick, Enum.Material.Concrete, Enum.Material.Wood
	local MPLAS, MGLASS, MMETAL = Enum.Material.SmoothPlastic, Enum.Material.Glass, Enum.Material.Metal

	------------------------------------------------------------------ trees
	local treesF = env.newFolder("Landscape", "Trees")
	-- one tree: Trunk + 3 canopy balls (s scales the size), base on y0
	local function tree(name, x, z, y0, s)
		local m = env.newChild(treesF, name)
		env.section("Landscape", function(ctx)
			vcyl(ctx, "Trunk", x, z, y0, y0 + 6.5 * s, 1.2 * s, TRUNK, MWOOD)
			ball(ctx, "Crown1", x, y0 + 9.2 * s, z, 8.5 * s, LEAF, MGRASS)
			ball(ctx, "Crown2", x + 1.8 * s, y0 + 8 * s, z + 1.2 * s, 6.5 * s, LEAF2, MGRASS)
			ball(ctx, "Crown3", x - 1.6 * s, y0 + 11.2 * s, z - 1, 6 * s, LEAF, MGRASS)
		end, m)
	end
	for i = 1, 10 do
		tree("WalkTree" .. i, 88, 30 - 6 * (i - 1), 0.8, 1)
	end
	tree("Tree1", 107.75, -96, 0.6, 0.75)
	tree("Tree2", 107.75, -106, 0.6, 0.75)
	tree("Tree3", 83, -115.5, 0.4, 0.9)
	tree("Tree4", 115, -115.5, 0.4, 0.9)
	env.section("Landscape", function(ctx)
		box(ctx, "WalkPlanterGrass", 85.4, 90.6, 0.4, 0.8, -27, 33, GRASS, MGRASS)
		box(ctx, "WalkPlanterEdgeW", 85, 85.4, 0.4, 0.95, -27, 33, BRICK, MBRICK)
		box(ctx, "WalkPlanterEdgeE", 90.6, 91, 0.4, 0.95, -27, 33, BRICK, MBRICK)
		box(ctx, "WalkPlanterEdgeN", 85.4, 90.6, 0.4, 0.95, -27.4, -27, BRICK, MBRICK)
		box(ctx, "WalkPlanterEdgeS", 85.4, 90.6, 0.4, 0.95, 33, 33.4, BRICK, MBRICK)
	end, treesF)

	------------------------------------------------------------------ palms
	local palmsF = env.newFolder("Landscape", "Palms")
	for i, z in ipairs({ -82, -86 }) do
		local m = env.newChild(palmsF, "Palm" .. i)
		env.section("Landscape", function(ctx)
			local x = 107.75
			vcyl(ctx, "PalmTrunk", x, z, 0.6, 14, 1.4, C3(120, 96, 70), MWOOD)
			for k = 0, 5 do
				local phi = rad(60 * k + 25 * i)
				ctx:part("PalmFrond" .. (k + 1), V(5.6, 0.25, 1.6),
					CF(x, 14, z) * ANG(0, phi, 0) * ANG(0, 0, -0.4) * CF(2.8, 0, 0), C3(70, 120, 60), MGRASS)
			end
		end, m)
	end

	------------------------------------------------------------------ shrubs on the terrace strips
	local shrubsF = env.newFolder("Landscape", "Shrubs")
	local function stripTop(x) -- terrace strip top height at lx x (strips are 5.5 wide from lx 47)
		local i = math.clamp(math.floor((x - 47) / 5.5) + 1, 1, 5)
		return 0.8 * (6 - i)
	end
	env.section("Landscape", function(ctx)
		local S = { { 69.2, -40 }, { 63.8, -40 }, { 58.2, -40 }, { 52.8, -40 }, { 47.2, -40 } }
		local N = { { 69.2, -70 }, { 63.8, -78 }, { 58.2, -86 }, { 52.8, -94 }, { 47.2, -102 }, { 69.2, -76 }, { 63.8, -84 }, { 58.2, -92 } }
		for i, p in ipairs(S) do
			local y = stripTop(p[1])
			ball(ctx, "ShrubS" .. i, p[1], y + 0.9, p[2], 2.6, C3(70, 115, 60), MGRASS)
			ball(ctx, "ShrubS" .. i .. "b", p[1] + 0.8, y + 0.6, p[2] + 0.6, 1.8, C3(86, 128, 66), MGRASS)
		end
		for i, p in ipairs(N) do
			local y = stripTop(p[1])
			ball(ctx, "ShrubN" .. i, p[1], y + 0.9, p[2], 2.6, C3(70, 115, 60), MGRASS)
			ball(ctx, "ShrubN" .. i .. "b", p[1] + 0.8, y + 0.6, p[2] + 0.6, 1.8, C3(86, 128, 66), MGRASS)
		end
	end, shrubsF)

	------------------------------------------------------------------ pocket gardens on the landing (y 4)
	local pgF = env.newFolder("Landscape", "PocketGardens")
	for i, zc in ipairs({ -30, -80, -100 }) do
		local m = env.newChild(pgF, "PocketGarden" .. i)
		env.section("Landscape", function(ctx)
			local x0, x1, z0, z1, t = 41.8, 45, zc - 3, zc + 3, 0.3
			box(ctx, "PlanterWallW", x0, x0 + t, 4, 4.9, z0, z1, CONC, MCONC)
			box(ctx, "PlanterWallE", x1 - t, x1, 4, 4.9, z0, z1, CONC, MCONC)
			box(ctx, "PlanterWallN", x0 + t, x1 - t, 4, 4.9, z0, z0 + t, CONC, MCONC)
			box(ctx, "PlanterWallS", x0 + t, x1 - t, 4, 4.9, z1 - t, z1, CONC, MCONC)
			box(ctx, "PlanterSoil", x0 + t, x1 - t, 4, 4.6, z0 + t, z1 - t, GRASS, MGRASS)
			for k = 1, 3 do
				ball(ctx, "PocketShrub" .. k, 43.4 + ((k == 2) and 0.5 or -0.4), 4.6, zc - 2 + 2 * (k - 1), 1.8, C3(70, 115, 60), MGRASS)
			end
		end, m)
	end

	------------------------------------------------------------------ parked cars
	local carsF = env.newFolder("Landscape", "Cars")
	local PAL = {
		C3(168, 170, 174), C3(58, 62, 68), C3(222, 222, 218), C3(42, 54, 82), C3(112, 44, 50),
		C3(172, 162, 142), C3(92, 106, 96), C3(130, 134, 140),
	}
	local carN = 0
	-- a car of 9 parts: sill, body, cabin, 2 glass, 4 wheels. Centre (cx, cz), yaw in degrees (Roblox yaw), on pavement top y0.
	local function car(name, cx, cz, yaw, y0)
		carN += 1
		local color = PAL[(carN - 1) % #PAL + 1]
		local m = env.newChild(carsF, name)
		env.section("Landscape", function(ctx)
			local base = CF(cx, 0, cz) * ANG(0, rad(yaw), 0)
			local function at(x, y, z) return base * CF(x, y0 + y, z) end
			ctx:part("CarSill", V(7.7, 0.3, 3.7), at(0, 0.5, 0), C3(40, 42, 46), MPLAS)
			ctx:part("CarBody", V(7.6, 1.2, 3.6), at(0, 1.25, 0), color, MMETAL)
			ctx:part("CarCabin", V(4.0, 1.1, 3.1), at(-0.4, 2.4, 0), color, MMETAL)
			ctx:part("CarGlassSide", V(3.4, 0.7, 3.25), at(-0.4, 2.4, 0), C3(60, 74, 88), MGLASS)
			ctx:part("CarGlassEnds", V(4.15, 0.7, 2.8), at(-0.4, 2.4, 0), C3(60, 74, 88), MGLASS)
			local w = 0
			for _, sx in ipairs({ -2.5, 2.5 }) do
				for _, sz in ipairs({ -1.6, 1.6 }) do
					w += 1
					ctx:cyl("Wheel" .. w, V(0.6, 1.6, 1.6), at(sx, 0.8, sz) * ANG(0, PI / 2, 0), C3(26, 28, 30), MPLAS)
				end
			end
		end, m)
	end
	local rowX = { A = 85, B = 102, C = 114.5 }
	for j, z in ipairs({ -83.2, -89.6, -96, -102.4, -108.8 }) do car("Car_A" .. j, rowX.A, z, 0, 0.4) end
	for j, z in ipairs({ -83.2, -89.6, -96, -108.8 }) do car("Car_B" .. j, rowX.B, z, 0, 0.4) end
	for j, z in ipairs({ -83.2, -96, -102.4 }) do car("Car_C" .. j, rowX.C, z, 0, 0.4) end
	car("Car_Loop1", 86.7, -50.3, -58, 0.4)
	car("Car_North1", 44, -124, 0, 0.4)
	car("Car_North2", 54, -124, 0, 0.4)
end
