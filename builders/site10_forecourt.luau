-- site10_forecourt: the grand terraced entrance steps and the forecourt of Site 10 (New Lipa City Hall). Studio copy:
-- ServerStorage.Builders.site10_forecourt. Owner containers: Steps AND Forecourt. Checks group: shared.site10_only = "forecourt".
-- Brief section: Steps and forecourt (briefs/site10.md). Loaded by builders/site10.luau; its MODULE CONTRACT gives env.
-- Coordinates are LOCAL to ORIGIN (world = ORIGIN + local); y = height above ground. Plain: no text, decals, textures or images.
-- Built in two env.section calls:
--   Steps (lx 5..25). Central stair 24 wide (lz -12..12): up-steps at lx 22.85..24.85 (top 0.9), 20.85..22.85 (1.8) and
--     18.85..20.85 (2.7), a landing at lx 11.15..18.85 (2.7), then the same steps mirrored about lx 15 down to lx 5.
--     Each step is a solid StepTread block from the ground to its top. Each StepRiser is 0.9 tall, stands on the tread below
--     and sits 0.15 proud of the face (a shade darker). StairRail: one per step and side, 3.0 tall, 0.3 thick, standing on the
--     step top at lz 11.7..12 (and -12..-11.7).
--     Planted terraces at lz 12..58 and -58..-12: three stepped levels (lx 19..25 at 0.9, 13..19 at 1.8, 7..13 at 2.7). Each is
--     a TerraceLawn with a TerraceWall lip (0.5 thick, 0.6 tall) on its +x edge and three TerraceShrub balls (1.5 dia) per side.
--   Forecourt (lx 25..100). ForecourtPaving: one slab, y 0..0.3. Vehicle loop centred at (68, 0): 48 LoopRoad segments between
--     radius 14 and 24, plus connector strips (west at lz 14..16, east at lz -1..1). LoopIsland: 8 spokes forming a regular
--     16-gon of apothem 12 (y 0.3..0.8), ringed by 16 Kerb boxes. Flagpole: one block 0.6 x 32 x 0.6 at (68, 0), y 0.8..32.8,
--     with a FlagFinial ball on top. FlagPanel x4: blue and red boxes plus a white triangle (two wedges) on the hoist, z 0.3..8.3.
--     Parking: two rows of 8 bays (row A lx 77..87, row B lx 89..99; bay k spans lz -58+5k .. -53+5k) with white BayLine strips
--     (0.1 tall). Bollard x6 (0.8 x 3 x 0.8) on the north and south plaza edges; WelcomeLawn strip at lz 44..50.
-- DEVIATIONS (forced by the checks or by the loop and bay geometry; reported to the parent):
--   * The checks read UNROTATED Size, so a rotated cylinder reads as its diameter. The Flagpole is therefore a block (Size.Y 32)
--     and the island is spokes, not a cylinder (an unrotated 24-wide disc would put its AABB below the ground).
--   * Row A has 8 lines, not 9. The loop's outer edge reaches lz -18 at lx 83.9, so the lz -18 line would show a fragment.
--     Bay A7 (lz -23..-18) is clipped by the road: at lz -20.5 the road edge is at lx 80.5, so a car at (82, -20.5) overlaps it.
-- Part budget: 500 (brief target about 350; this module plans 162).
return function(env)
	local CF, ANG, V, PI = env.CF, env.ANG, env.V, env.PI
	local box, ball = env.box, env.ball
	local Concrete, LeafyGrass = Enum.Material.Concrete, Enum.Material.LeafyGrass
	local Asphalt, Metal, Fabric = Enum.Material.Asphalt, Enum.Material.Metal, Enum.Material.Fabric
	local STONE = Color3.fromRGB(205, 200, 190)
	local RISER = Color3.fromRGB(188, 183, 174)
	local CONCRETE = Color3.fromRGB(190, 192, 190)
	local RAIL = Color3.fromRGB(60, 64, 68)
	local LAWN = Color3.fromRGB(96, 150, 80)
	local SHRUB = Color3.fromRGB(80, 130, 70)
	local PAVING = Color3.fromRGB(200, 195, 185)
	local ROAD = Color3.fromRGB(60, 62, 66)
	local POLE = Color3.fromRGB(225, 225, 225)
	local BLUE = Color3.fromRGB(0, 56, 168)
	local RED = Color3.fromRGB(206, 17, 38)
	local WHITE = Color3.fromRGB(255, 255, 255)
	local LINE = Color3.fromRGB(235, 235, 225)
	local BOLLARD = Color3.fromRGB(120, 126, 132)

	------------------------------------------------------------------ Steps (lx 5..25)
	env.section("Steps", function(ctx)
		local Z0, Z1 = -12, 12 -- stair width 24
		local RAIL_IN, RAIL_OUT = 11.7, 12 -- rails stand just inside the stair edges
		local MIRROR = 30 -- down-steps mirror the up-steps about lx 15 (x -> 30 - x)
		local RISE, NOSE = 0.9, 0.15

		-- up-steps from the outside in: x0 (back), x1 (front face), tread top
		local UP = {
			{ x0 = 22.85, x1 = 24.85, top = 0.9 },
			{ x0 = 20.85, x1 = 22.85, top = 1.8 },
			{ x0 = 18.85, x1 = 20.85, top = 2.7 },
		}
		local LANDING = { x0 = 11.15, x1 = 18.85, top = 2.7 }

		local function rails(b)
			box(ctx, "StairRail", b.x0, b.x1, b.top, b.top + 3, RAIL_IN, RAIL_OUT, RAIL, Metal)
			box(ctx, "StairRail", b.x0, b.x1, b.top, b.top + 3, -RAIL_OUT, -RAIL_IN, RAIL, Metal)
		end
		local function block(b)
			box(ctx, "StepTread", b.x0, b.x1, 0, b.top, Z0, Z1, STONE, Concrete)
			rails(b)
		end

		for _, u in ipairs(UP) do
			block(u)
			box(ctx, "StepRiser", u.x1, u.x1 + NOSE, u.top - RISE, u.top, Z0, Z1, RISER, Concrete)
		end
		block(LANDING)
		for _, u in ipairs(UP) do
			local d = { x0 = MIRROR - u.x1, x1 = MIRROR - u.x0, top = u.top }
			block(d)
			box(ctx, "StepRiser", d.x0 - NOSE, d.x0, d.top - RISE, d.top, Z0, Z1, RISER, Concrete)
		end

		-- planted terraces, stepping up toward the plaza middle; north (+lz) and south (-lz), mirrored
		local LEVELS = {
			{ x0 = 19, x1 = 25, h = 0.9 },
			{ x0 = 13, x1 = 19, h = 1.8 },
			{ x0 = 7, x1 = 13, h = 2.7 },
		}
		for _, s in ipairs({ 1, -1 }) do
			local za, zb = 12, 58
			if s < 0 then
				za, zb = -58, -12
			end
			for _, lv in ipairs(LEVELS) do
				box(ctx, "TerraceLawn", lv.x0, lv.x1, 0, lv.h, za, zb, LAWN, LeafyGrass)
				box(ctx, "TerraceWall", lv.x1 - 0.5, lv.x1, lv.h, lv.h + 0.6, za, zb, CONCRETE, Concrete)
				for _, d in ipairs({ 20, 34, 48 }) do
					ball(ctx, "TerraceShrub", (lv.x0 + lv.x1) / 2, lv.h + 0.75, s * d, 1.5, SHRUB, LeafyGrass)
				end
			end
		end
	end)

	------------------------------------------------------------------ Forecourt (lx 25..100)
	env.section("Forecourt", function(ctx)
		box(ctx, "ForecourtPaving", 25, 100, 0, 0.3, -70, 70, PAVING, Concrete)

		local CX, CZ = 68, 0 -- loop and island centre
		-- Vehicle loop: radius 14 (inner) to 24 (outer). Each segment's local Z points out along its radius.
		local N = 48
		local STEP = 2 * PI / N
		local SEG = 2 * 24 * math.sin(STEP / 2) * 1.05 -- outer-edge chord plus 5 percent, so no gap shows at the outer edge
		for i = 0, N - 1 do
			local t = i * STEP
			local rad = V(math.cos(t), 0, math.sin(t))
			local top = (i % 2 == 0) and 0.5 or 0.51 -- alternate tops so neighbours do not z-fight
			local mid = V(CX, (0.3 + top) / 2, CZ) + rad * 19
			ctx:part("LoopRoad", V(SEG, top - 0.3, 10), CFrame.lookAt(mid, mid + rad), ROAD, Asphalt)
		end
		box(ctx, "LoopRoad", 25, 50, 0.3, 0.5, 14, 16, ROAD, Asphalt) -- west connector, clear of the spawn pad (lz -10..10)
		box(ctx, "LoopRoad", 91.5, 100, 0.3, 0.5, -1, 1, ROAD, Asphalt) -- east connector to the forecourt edge

		-- Grass island: 8 spokes (24 long, 24 * tan(pi/16) wide, 22.5 deg apart) form a regular 16-gon of apothem 12.
		local SPOKE_W = 24 * math.tan(PI / 16)
		for k = 0, 7 do
			local top = 0.8 + 0.005 * k -- staggered tops so the overlaps do not flicker
			ctx:part("LoopIsland", V(24, top - 0.3, SPOKE_W), CF(CX, (0.3 + top) / 2, CZ) * ANG(0, k * PI / 8, 0), LAWN, LeafyGrass)
		end
		-- Kerb: 16 boxes on the island's edges (edge length SPOKE_W, outer face 0.25 beyond the apothem).
		for k = 0, 15 do
			local th = k * PI / 8
			local rad = V(math.cos(th), 0, math.sin(th))
			local tg = V(-math.sin(th), 0, math.cos(th))
			local p = V(CX, 0.5, CZ) + rad * 12.25
			ctx:part("Kerb", V(0.5, 0.4, SPOKE_W), CFrame.lookAt(p, p + tg), CONCRETE, Concrete)
		end

		-- Flagpole: one block (Size.Y 32, so the height reads), a finial, and the flag on its +z side (hoist at z 0.3).
		box(ctx, "Flagpole", CX - 0.3, CX + 0.3, 0.8, 32.8, -0.3, 0.3, POLE, Metal)
		ball(ctx, "FlagFinial", CX, 33.1, 0, 0.8, POLE, Metal)
		box(ctx, "FlagPanel", CX - 0.05, CX + 0.05, 29.5, 31.5, 0.3, 8.3, BLUE, Fabric)
		box(ctx, "FlagPanel", CX - 0.05, CX + 0.05, 27.5, 29.5, 0.3, 8.3, RED, Fabric)
		-- White triangle at the hoist: two right-triangle wedges meeting on the centre line (apex at z 3.8).
		ctx:wedge("FlagPanel", V(0.2, 2, 3.5), CF(CX, 30.5, 2.05) * ANG(0, PI, 0), WHITE, Fabric)
		ctx:wedge("FlagPanel", V(0.2, 2, 3.5), CF(CX, 28.5, 2.05) * ANG(PI, 0, 0), WHITE, Fabric)

		-- Parking: two rows of 8 bays; lines at lz -58+5k. Row A's last line (lz -18) is left out (see the header).
		for _, x0 in ipairs({ 77, 89 }) do
			for k = 0, 8 do
				if x0 == 89 or k < 8 then
					local lz = -58 + 5 * k
					box(ctx, "BayLine", x0, x0 + 10, 0.3, 0.4, lz - 0.15, lz + 0.15, LINE, Concrete)
				end
			end
		end

		-- Ground details: bollards on the north and south plaza edges, and a welcome lawn strip.
		for _, lx in ipairs({ 35, 55, 75 }) do
			for _, lz in ipairs({ -67.6, 67.6 }) do
				box(ctx, "Bollard", lx - 0.4, lx + 0.4, 0.3, 3.3, lz - 0.4, lz + 0.4, BOLLARD, Metal)
			end
		end
		box(ctx, "WelcomeLawn", 26, 42, 0.3, 0.4, 44, 50, LAWN, LeafyGrass)
	end)
end
