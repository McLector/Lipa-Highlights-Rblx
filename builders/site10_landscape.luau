-- site10_landscape: the trees, pocket gardens and parked cars of Site 10 (New Lipa City Hall). Studio copy:
-- ServerStorage.Builders.site10_landscape. Owner container: Landscape (incl. Landscape.PocketGardens). Checks group:
-- shared.site10_only = "landscape". Brief section: Landscape (briefs/site10.md). Loaded by builders/site10.luau; its
-- MODULE CONTRACT header gives the env table (env.section, env.newFolder, env.newChild, env.box, env.vcyl, env.ball).
-- Coordinates are LOCAL to ORIGIN (world = ORIGIN + local); y = height above ground (ground y 0, forecourt paving top y 0.3).
-- Plain: no text, decals, textures or images. Everything is Anchored by BuildKit.
--   Trees (15: north edge lz -65, south edge lz 65): TreeTrunk (1.6 wide, 7 to 9 tall) and 4 TreeCanopy balls each.
--     Odd-numbered trees are mango style (round, dense crown), even ones acacia style (wide, flatter). Crown z offsets stay
--     within +-0.3, so every crown stays inside lz +-70 and clear of the block field (lz -58.5..58.5).
--   PocketGardens (3 Models in Landscape.PocketGardens): PlanterWall x4 (0.4 thick, 0.8 tall, concrete), GardenSoil,
--     8 GardenShrub balls (LeafyGrass, 1.6 to 2.5 dia) and 8 GardenFlower dots (0.6 dia; pink, yellow, red).
--   ParkedCars (12, in the bays): CarBody, CarCabin, 4 CarWheel, 2 CarLight each. Row A at lx 82 (lz -55.5, -50.5, -45.5,
--     -35.5, -30.5, -25.5), row B at lx 94 (lz -55.5, -50.5, -45.5, -40.5, -35.5, -30.5).
-- DEVIATIONS (reported to the parent):
--   * Garden 3 is at lx 38..48, lz 55..66 (brief: lx 40..50, lz 56..66): the tree trunk at (50, 65) sits inside 40..50. It is 10 by 11.
--   * Garden 1 (lx 27..37, lz 40..52) covers the forecourt WelcomeLawn strip (lx 26..42, lz 44..50, top y 0.4) inside its
--     footprint. Its soil bed starts at y 0.3, so the lawn shows only outside the walls.
--   * Cars are lifted 0.3 because the bays are on the paving (top y 0.3): body y 1.2..2.8, cabin 2.8..4.0, wheels centred y 1.1.
--   * Wheels are 0.7 wide at z +-1.9 (brief: 0.8 wide at +-2.1), so they stay off the painted bay lines (inner edge +-2.35).
--   * Benches are skipped (the brief says "maybe").
-- Part budget: 400 (plans 234: trees 75, gardens 63, cars 96; brief target about 250).
return function(env)
	local CF, ANG, V, PI = env.CF, env.ANG, env.V, env.PI
	local box, vcyl, ball = env.box, env.vcyl, env.ball
	local Wood, Grass, LeafyGrass = Enum.Material.Wood, Enum.Material.Grass, Enum.Material.LeafyGrass
	local Concrete, Ground = Enum.Material.Concrete, Enum.Material.Ground
	local Plastic, SmoothPlastic, Glass = Enum.Material.Plastic, Enum.Material.SmoothPlastic, Enum.Material.Glass

	local TRUNK = Color3.fromRGB(110, 80, 52)
	local CANOPY = {
		Color3.fromRGB(56, 120, 56),
		Color3.fromRGB(70, 132, 62),
		Color3.fromRGB(84, 140, 70),
		Color3.fromRGB(96, 150, 80),
	}
	local CONCRETE = Color3.fromRGB(190, 192, 190)
	local SOIL = Color3.fromRGB(96, 68, 46)
	local SHRUB = {
		Color3.fromRGB(72, 128, 66),
		Color3.fromRGB(84, 140, 72),
		Color3.fromRGB(64, 118, 60),
	}
	local PINK = Color3.fromRGB(236, 120, 168)
	local YELLOW = Color3.fromRGB(246, 214, 84)
	local RED = Color3.fromRGB(206, 48, 60)
	-- car body palette, muted: 1 white, 2 silver, 3 dark grey, 4 dark red, 5 navy, 6 beige
	local BODY = {
		Color3.fromRGB(230, 230, 226),
		Color3.fromRGB(190, 192, 196),
		Color3.fromRGB(70, 72, 78),
		Color3.fromRGB(150, 50, 50),
		Color3.fromRGB(40, 60, 110),
		Color3.fromRGB(200, 185, 150),
	}
	local GLASS = Color3.fromRGB(60, 84, 98)
	local WHEEL = Color3.fromRGB(30, 30, 34)
	local LIGHT = Color3.fromRGB(246, 242, 224)

	------------------------------------------------------------------ trees (Landscape; trunk centres)
	-- Spots from the brief: north edge lz -65 (8 trees), south edge lz 65 (7 trees). Base 0.3 on the paving (lx 25 and up).
	local TREES = {
		{ -45, -65 }, { -30, -65 }, { -15, -65 }, { 0, -65 },
		{ 35, -65 }, { 50, -65 }, { 65, -65 }, { 80, -65 },
		{ -45, 65 }, { -30, 65 }, { -15, 65 },
		{ 35, 65 }, { 50, 65 }, { 65, 65 }, { 80, 65 },
	}

	local function tree(ctx, i, x, z)
		local base = (x >= 25) and 0.3 or 0
		local H = 7 + i % 3 -- trunk height 7, 8 or 9
		local T = base + H -- trunk top
		vcyl(ctx, "TreeTrunk", x, z, base, T, 1.6, TRUNK, Wood)
		local function shade(k)
			return CANOPY[(i + k) % #CANOPY + 1]
		end
		if i % 2 == 1 then
			-- mango: a round, dense crown
			ball(ctx, "TreeCanopy", x, T + 2.6, z, 8.0, shade(0), Grass)
			ball(ctx, "TreeCanopy", x - 2.2, T + 1.8, z + 0.3, 6.4, shade(1), Grass)
			ball(ctx, "TreeCanopy", x + 2.2, T + 2.0, z - 0.3, 6.6, shade(2), Grass)
			ball(ctx, "TreeCanopy", x + 0.2, T + 4.9, z + 0.1, 6.0, shade(3), Grass)
		else
			-- acacia: a wide, flatter umbrella
			ball(ctx, "TreeCanopy", x, T + 2.6, z, 9.0, shade(0), Grass)
			ball(ctx, "TreeCanopy", x - 3.0, T + 2.2, z + 0.2, 6.0, shade(1), Grass)
			ball(ctx, "TreeCanopy", x + 3.0, T + 2.2, z - 0.2, 6.0, shade(2), Grass)
			ball(ctx, "TreeCanopy", x + 0.3, T + 4.0, z, 6.4, shade(3), Grass)
		end
	end

	env.section("Landscape", function(ctx)
		for i, t in ipairs(TREES) do
			tree(ctx, i, t[1], t[2])
		end
	end)

	------------------------------------------------------------------ pocket gardens (Landscape.PocketGardens, one Model each)
	-- Outer footprints. The planter ring is 0.4 thick, from the paving top (y 0.3) to y 1.1. The soil bed fills the ring.
	local GARDENS = {
		{ x0 = 27, x1 = 37, z0 = 40, z1 = 52 },
		{ x0 = 27, x1 = 37, z0 = -52, z1 = -40 },
		{ x0 = 38, x1 = 48, z0 = 55, z1 = 66 },
	}
	-- Plants as fractions of the soil bed (u across x, v across z): shrubs {u, v, dia}, flowers {u, v, colour}.
	local SHRUBS = {
		{ 0.16, 0.17, 2.2 }, { 0.50, 0.16, 1.8 }, { 0.84, 0.19, 2.4 },
		{ 0.30, 0.50, 1.6 }, { 0.74, 0.52, 2.0 },
		{ 0.18, 0.84, 2.5 }, { 0.52, 0.86, 1.7 }, { 0.84, 0.84, 2.1 },
	}
	local FLOWERS = {
		{ 0.32, 0.31, PINK }, { 0.66, 0.33, YELLOW }, { 0.88, 0.44, RED }, { 0.10, 0.44, YELLOW },
		{ 0.46, 0.50, RED }, { 0.60, 0.68, PINK }, { 0.30, 0.68, YELLOW }, { 0.84, 0.66, RED },
	}
	local WALL_T, WALL_Y0, WALL_TOP = 0.4, 0.3, 1.1
	local SOIL_TOP = 0.9

	local function garden(ctx, g)
		local x0, x1, z0, z1 = g.x0, g.x1, g.z0, g.z1
		local t = WALL_T
		box(ctx, "PlanterWall", x0, x1, WALL_Y0, WALL_TOP, z1 - t, z1, CONCRETE, Concrete) -- north
		box(ctx, "PlanterWall", x0, x1, WALL_Y0, WALL_TOP, z0, z0 + t, CONCRETE, Concrete) -- south
		box(ctx, "PlanterWall", x0, x0 + t, WALL_Y0, WALL_TOP, z0 + t, z1 - t, CONCRETE, Concrete) -- west
		box(ctx, "PlanterWall", x1 - t, x1, WALL_Y0, WALL_TOP, z0 + t, z1 - t, CONCRETE, Concrete) -- east
		local bx0, bx1, bz0, bz1 = x0 + t, x1 - t, z0 + t, z1 - t
		box(ctx, "GardenSoil", bx0, bx1, WALL_Y0, SOIL_TOP, bz0, bz1, SOIL, Ground)
		local bw, bd = bx1 - bx0, bz1 - bz0
		for i, s in ipairs(SHRUBS) do
			-- centre sits a little below the soil top so the shrub is planted, not floating
			ball(ctx, "GardenShrub", bx0 + s[1] * bw, SOIL_TOP + s[3] / 2 - 0.3, bz0 + s[2] * bd, s[3], SHRUB[i % #SHRUB + 1], LeafyGrass)
		end
		for _, f in ipairs(FLOWERS) do
			ball(ctx, "GardenFlower", bx0 + f[1] * bw, 1.05, bz0 + f[2] * bd, 0.6, f[3], SmoothPlastic)
		end
	end

	local pg = env.newFolder("Landscape", "PocketGardens")
	for i, g in ipairs(GARDENS) do
		local model = env.newChild(pg, "PocketGarden" .. i)
		env.section("Landscape", function(ctx)
			garden(ctx, g)
		end, model)
	end

	------------------------------------------------------------------ parked cars (Landscape, in the bays)
	-- Bays are on the forecourt paving (top y 0.3), so every car is lifted by CAR_Y. Cars face +X (front = +X).
	local CAR_Y = 0.3
	-- { centre lx, centre lz, body colour index into BODY }. Row A: bays lx 77..87. Lz -40.5 is left empty (brief),
	-- and lz -20.5 is skipped because the loop road clips that bay. Row B: bays lx 89..99.
	local CARS = {
		{ 82, -55.5, 1 }, { 82, -50.5, 2 }, { 82, -45.5, 5 }, { 82, -35.5, 6 }, { 82, -30.5, 3 }, { 82, -25.5, 4 },
		{ 94, -55.5, 4 }, { 94, -50.5, 1 }, { 94, -45.5, 6 }, { 94, -40.5, 2 }, { 94, -35.5, 5 }, { 94, -30.5, 3 },
	}

	local function car(ctx, cx, cz, col)
		local y = CAR_Y
		box(ctx, "CarBody", cx - 4.3, cx + 4.3, y + 0.9, y + 2.5, cz - 2.1, cz + 2.1, col, SmoothPlastic)
		box(ctx, "CarCabin", cx - 2.3, cx + 2.3, y + 2.5, y + 3.7, cz - 1.8, cz + 1.8, GLASS, Glass)
		for _, sx in ipairs({ -2.9, 2.9 }) do
			for _, sz in ipairs({ -1.9, 1.9 }) do
				-- a wheel is a cylinder whose axis runs along z (0.7 wide, 1.6 across)
				ctx:cyl("CarWheel", V(0.7, 1.6, 1.6), CF(cx + sx, y + 0.8, cz + sz) * ANG(0, PI / 2, 0), WHEEL, Plastic)
			end
		end
		for _, sz in ipairs({ -1.4, 1.4 }) do
			box(ctx, "CarLight", cx + 4.3, cx + 4.45, y + 1.3, y + 1.7, cz + sz - 0.25, cz + sz + 0.25, LIGHT, SmoothPlastic)
		end
	end

	env.section("Landscape", function(ctx)
		for _, c in ipairs(CARS) do
			car(ctx, c[1], c[2], BODY[c[3]])
		end
	end)
end
