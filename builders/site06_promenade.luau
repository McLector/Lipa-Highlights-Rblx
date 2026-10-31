-- site06_promenade: the cluster deck, the board's central pedestrian promenade ("landscaped spine with plazas, dining and outdoor
-- spaces"), the oval plaza, the covered walkways, the arrival plaza fittings round the kept Guide cluster, the north-west landscaped garden
-- and the estate's trees and palms. Module of builders/site06.luau (see its MODULE CONTRACT and DECK). Containers: ShopStreet, Landscape.
-- Local frame: +X east, +Z south, origin (550, 0, -700). The cluster deck (ClusterPaving, world y 0..1.3) carries every block; the inlays
-- (spine, walks, oval) are 0.4 thick but sunk so they stand at most 0.1 above it. The arrival plaza (x -64..4, z 30..100) is the old
-- terrain Pavement left bare: nothing is laid under the JeepStop pad, the Guide or the Jeepney; only edge fittings stand there (not
-- lifted), clear of the landing box, the pad-to-Guide path, the InfoPanel front zone and the walk from Road B's mouth
-- (-108,140) -> (-108,104) -> (-62,104) -> (-30,78).
return function(env)
	local V, CF, ANG, PI, C, M, DECK = env.V, env.CF, env.ANG, env.PI, env.C, env.M, env.DECK
	local box, vcyl, tree, palm, bench, lamp = env.box, env.vcyl, env.tree, env.palm, env.bench, env.lamp

	-- A stadium (rectangle plus two half-circles) along z, centre (x, z): total length len, width wid, slab y0..y1, 3 parts.
	local function stadium(ctx, name, x, z, wid, len, y0, y1, color, material)
		local straight = len - wid
		box(ctx, name, x - wid / 2, x + wid / 2, y0, y1, z - straight / 2, z + straight / 2, color, material)
		vcyl(ctx, name, x, z - straight / 2, y0, y1, wid, color, material)
		vcyl(ctx, name, x, z + straight / 2, y0, y1, wid, color, material)
	end

	------------------------------------------------------------------ ShopStreet on the deck (lifted)
	env.section("ShopStreet", function(ctx)
		-- the cluster deck: light paving round the blocks (board: the clusters stand on paved courts), world y 0..1.3
		for _, r in ipairs({ { -180, -64, -78, 30 }, { -172, -64, 30, 100 }, { -172, -64, 100, 134 }, { -64, 44, -106, 30 }, { 44, 58, -40, -2 },
			{ 4, 44, 30, 100 }, { -64, -2, 100, 134 } }) do
			box(ctx, "ClusterPaving", r[1], r[2], -DECK, 0, r[3], r[4], C.PAVING, M.PAVE)
		end
		-- the spine from the oval to the arrival plaza, warm pavers with a darker centre inlay
		-- tidy round (owner, 2026-10-31): a green landscaped spine, a central path between two planted lawn beds
		box(ctx, "PromenadeSpine", -40, -28, -0.3, 0.1, -20, 30, C.PAVING2, M.PAVE)
		box(ctx, "SpineBed", -46, -40, -0.3, 0.6, -14, 28, C.LAWN, M.GRASS)
		box(ctx, "SpineBed", -28, -23, -0.3, 0.6, -14, 28, C.LAWN, M.GRASS)
		for _, z in ipairs({ -7, 3, 13 }) do
			ctx:ball("SpineShrub", 2, CF(-43, 1.3, z), C.HEDGE, M.GRASS)
			ctx:ball("SpineShrub", 2, CF(-25.5, 1.3, z), C.HEDGE, M.GRASS)
		end
		tree(ctx, -43, 24, 10, 7)
		tree(ctx, -25.5, 22, 10, 6)
		bench(ctx, CF(-38.5, 0, 0) * ANG(0, PI / 2, 0))
		bench(ctx, CF(-29.5, 0, 12) * ANG(0, -PI / 2, 0))
		box(ctx, "PromenadeInlay", -36, -32, 0.1, 0.14, -16, 30, C.CONCRETE, M.PAVE)
		-- the oval plaza (board: concentric rings round a centre feature), long axis north-south, centre (-34, -40)
		stadium(ctx, "OvalPaving", -34, -40, 30, 48, -0.3, 0.12, C.PAVING, M.PAVE)
		stadium(ctx, "OvalLawn", -34, -40, 22, 40, 0.12, 0.22, C.LAWN, M.GRASS)
		stadium(ctx, "OvalRing", -34, -40, 14, 32, 0.22, 0.28, C.PAVING, M.PAVE)
		stadium(ctx, "OvalLawnInner", -34, -40, 8, 26, 0.28, 0.34, C.LAWN, M.GRASS)
		vcyl(ctx, "OvalCentre", -34, -40, 0.34, 1.5, 5, C.CONCRETE, M.CONC)
		tree(ctx, -34, -40, 11, 7)
		for _, p in ipairs({ { -34, -58.5, 2, 5 }, { -34, -21.5, 2, 5 }, { -43.5, -40, 5, 2 }, { -24.5, -40, 5, 2 } }) do
			box(ctx, "OvalPath", p[1] - p[3] / 2, p[1] + p[3] / 2, 0.12, 0.25, p[2] - p[4] / 2, p[2] + p[4] / 2, C.PAVING, M.PAVE)
		end
		bench(ctx, CF(-46.5, 0, -40) * ANG(0, PI / 2, 0))
		bench(ctx, CF(-21.5, 0, -40) * ANG(0, -PI / 2, 0))
		-- ring planting round the oval (board: the planted rings) and four trees on its rim
		for z = -52, -28, 6 do
			ctx:ball("OvalShrub", 2.2, CF(-43, 0.9, z), C.HEDGE, M.GRASS)
			ctx:ball("OvalShrub", 2.2, CF(-25, 0.9, z), C.HEDGE, M.GRASS)
		end
		for _, p in ipairs({ { -39, -57 }, { -29, -57 }, { -39, -23 }, { -29, -23 } }) do
			ctx:ball("OvalShrub", 2.2, CF(p[1], 0.9, p[2]), C.HEDGE, M.GRASS)
		end
		for _, p in ipairs({ { -47, -30 }, { -47, -50 }, { -21, -30 }, { -21, -50 } }) do tree(ctx, p[1], p[2], 10, 7) end
		-- spine planting and lamps (the walking lane x -38..-32 stays open)
		for _, z in ipairs({ -12, 8 }) do
			tree(ctx, -43, z, 10, 7)
			tree(ctx, -27, z, 10, 7)
		end
		for _, z in ipairs({ -2, 18 }) do
			lamp(ctx, -43, z)
			lamp(ctx, -27, z)
		end
		-- outdoor dining under the spine canopies (board: "dining and outdoor spaces"): table 2.8 high, chair seats 2.0
		for _, p in ipairs({ { -49, -6 }, { -49, 6 }, { -49, 18 }, { -20.5, 18 } }) do
			vcyl(ctx, "CafeTable", p[1], p[2], 0, 2.6, 0.5, C.DARK, M.METAL)
			vcyl(ctx, "CafeTableTop", p[1], p[2], 2.6, 2.8, 3, C.WHITE, M.PLAS)
			for _, dz in ipairs({ -2.3, 2.3 }) do
				box(ctx, "CafeChair", p[1] - 0.8, p[1] + 0.8, 1.7, 2.0, p[2] + dz - 0.8, p[2] + dz + 0.8, C.ORANGE, M.PLAS)
				local bz = p[2] + dz + (dz > 0 and 0.8 or -0.8)
				box(ctx, "CafeChairBack", p[1] - 0.8, p[1] + 0.8, 2.0, 3.8, bz - 0.125, bz + 0.125, C.ORANGE, M.PLAS)
			end
		end
		-- string lights across the spine between the lamp pairs
		for _, z in ipairs({ -2, 18 }) do
			local a, mid, b = V(-43, 11.6, z), V(-35, 10.6, z), V(-27, 11.6, z)
			for _, seg in ipairs({ { a, mid }, { mid, b } }) do
				ctx:part("LightWire", V(0.12, 0.12, (seg[2] - seg[1]).Magnitude), CFrame.lookAt((seg[1] + seg[2]) / 2, seg[2]), C.BLACK, M.PLAS)
			end
			for i = 1, 5 do
				local x = -43 + 16 * i / 6
				local y = 11.6 - (1 - math.abs(x + 35) / 8) - 0.35
				ctx:ball("LightBulb", 0.45, CF(x, y, z), C.BULB, M.NEON)
			end
		end
		-- trees along the entry walk's east leg, a bench by the SouthEastL block
		for _, x in ipairs({ -90, -78 }) do tree(ctx, x, 96, 10, 7) end
		bench(ctx, CF(12, 0, 64) * ANG(0, PI, 0))
		-- tidy round: more trees and palms along the walks and round the blocks
		for _, p in ipairs({ { -102, 96 }, { 40, 80 }, { 40, 92 }, { -52, -67 }, { -124, 104 }, { -152, 103 }, { 2, 104 }, { 40, 104 }, { -44, 103 },
			{ -20, 103 }, { 26, -70 }, { 40, 0 }, { 52, -8 } }) do
			tree(ctx, p[1], p[2], 11, 8)
		end
		for _, p in ipairs({ { -115, 104 }, { -150, 131 }, { -140, 131 } }) do palm(ctx, p[1], p[2], 15) end
		-- covered walkways (look-at line: "the long canopy along the covered walkway"): brown roofs 11.4..12 above the deck on steel posts
		box(ctx, "WalkwayCanopy", -71, -64, 11.4, 12, 36, 74, C.BROWN, M.PLAS) -- along CentralBig's storefronts
		for _, z in ipairs({ 38, 50, 62, 73 }) do vcyl(ctx, "WalkwayPost", -64.5, z, 0, 11.4, 0.5, C.STEEL, M.METAL) end
		box(ctx, "WalkwayCanopy", -51, -46, 11.4, 12, -14, 25, C.BROWN, M.PLAS) -- along SpineWest, the spine's west side
		for _, z in ipairs({ -12, 0, 12, 24 }) do vcyl(ctx, "WalkwayPost", -46.5, z, 0, 11.4, 0.5, C.STEEL, M.METAL) end
		box(ctx, "WalkwayCanopy", -73, -7, 11.4, 12, 107, 112, C.BROWN, M.PLAS) -- along the south row's storefronts
		for _, x in ipairs({ -71, -55, -40, -25, -9 }) do vcyl(ctx, "WalkwayPost", x, 107.4, 0, 11.4, 0.5, C.STEEL, M.METAL) end
		box(ctx, "WalkwayCanopy", -23, -18, 11.4, 12, 10, 25, C.BROWN, M.PLAS) -- along SpineEast
		for _, z in ipairs({ 12, 24 }) do vcyl(ctx, "WalkwayPost", -22.5, z, 0, 11.4, 0.5, C.STEEL, M.METAL) end
		-- walks (inlays): Road B's mouth to the plaza, the walkway in front of the ShopBlock, the plaza to the pitch gate
		box(ctx, "EntryWalk", -112, -104, -0.3, 0.1, 100, 134, C.PAVING2, M.PAVE)
		box(ctx, "EntryWalk", -104, -64, -0.3, 0.1, 100, 107, C.PAVING2, M.PAVE)
		box(ctx, "WalkwayPaving", 4, 38, -0.3, 0.1, 37, 50, C.PAVING2, M.PAVE)
		box(ctx, "PitchWalk", 38, 50, -0.3, 0.1, 38, 50, C.PAVING2, M.PAVE)
	end, nil, DECK)

	------------------------------------------------------------------ ShopStreet fittings on the bare plaza (not lifted)
	env.section("ShopStreet", function(ctx)
		-- tidy round: two raised planted beds on the arrival court (1.4 high, above the rendered terrain), clear of the kept cluster's zones
		box(ctx, "PlazaBed", -14, -2, 0, 1.4, 34, 62, C.LAWN, M.GRASS)
		box(ctx, "PlazaBed", -38, -24, 0, 1.4, 90, 98, C.LAWN, M.GRASS)
		for _, p in ipairs({ { -8, 40 }, { -8, 50 }, { -8, 58 }, { -34, 94 }, { -28, 94 } }) do tree(ctx, p[1], p[2], 11, 7) end
		bench(ctx, CF(-16, 0, 40) * ANG(0, -PI / 2, 0))
		bench(ctx, CF(-16, 0, 56) * ANG(0, -PI / 2, 0))
		for _, p in ipairs({ { -58, 33 }, { 0, 33 }, { 0, 97 } }) do
			box(ctx, "Planter", p[1] - 1.6, p[1] + 1.6, 0, 1.5, p[2] - 1.6, p[2] + 1.6, C.CONCRETE, M.CONC)
			tree(ctx, p[1], p[2], 10, 7)
		end
		for _, p in ipairs({ { -61, 42 }, { 0, 44 }, { -62, 96 }, { -30, 96 } }) do
			lamp(ctx, p[1], p[2])
		end
		bench(ctx, CF(0, 0, 62) * ANG(0, -PI / 2, 0))
		bench(ctx, CF(-61, 0, 95) * ANG(0, PI / 2, 0))
	end)

	------------------------------------------------------------------ Landscape on decks (lifted): the NW garden, trees between the blocks
	env.section("Landscape", function(ctx)
		-- the landscaped garden in the north-west (board: lawns with winding paths and a round node), a lawn-coloured deck
		box(ctx, "GardenLawn", -205, -64, -DECK, 0, -106, -78, C.LAWN, M.GRASS)
		local pts = { { -200, -84 }, { -182, -98 }, { -160, -86 }, { -140, -100 }, { -104, -101 }, { -86, -86 }, { -70, -96 } }
		for i = 1, #pts - 1 do
			local a, b = V(pts[i][1], 0.05, pts[i][2]), V(pts[i + 1][1], 0.05, pts[i + 1][2])
			ctx:part("GardenPath", V(3, 0.1, (b - a).Magnitude + 3), CFrame.lookAt((a + b) / 2, b), C.PAVING, M.PAVE)
		end
		vcyl(ctx, "GardenCircle", -182, -98, 0, 0.12, 10, C.PAVING, M.PAVE)
		for _, p in ipairs({ { -195, -94 }, { -170, -91 }, { -150, -95 }, { -133, -86 }, { -95, -92 }, { -78, -84 }, { -72, -101 } }) do
			tree(ctx, p[1], p[2], 11, 8)
		end
		for _, p in ipairs({ { -188, -88 }, { -176, -102 }, { -164, -96 }, { -146, -88 }, { -112, -82 }, { -98, -84 }, { -84, -98 }, { -68, -86 } }) do
			ctx:ball("GardenShrub", 3, CF(p[1], 1.1, p[2]), C.HEDGE, M.GRASS)
		end
		for _, p in ipairs({ { -120, -12 }, { -116, 98 }, { -62, -66 }, { 28, -95 }, { 30, -50 }, { 30, -2 }, { 40, 20 }, { -140, 102 }, { -165, -102 },
			{ -88, -102 } }) do
			tree(ctx, p[1], p[2], 11, 8)
		end
	end, nil, DECK)

	------------------------------------------------------------------ Landscape on the grass verges (not lifted)
	env.section("Landscape", function(ctx)
		-- west lawn strip between the west road and the blocks
		for _, z in ipairs({ -70, -45, -20, 5 }) do tree(ctx, -195, z, 11, 8) end
		for _, z in ipairs({ -55, -25, 5 }) do palm(ctx, -206, z, 15) end
		-- the perimeter tree belt north of the estate (z -150..-118)
		for i = 0, 15 do tree(ctx, -210 + 28 * i, -134, 13, 10) end
		for i = 0, 7 do tree(ctx, -196 + 56 * i, -144, 12, 9) end
		for i = 0, 6 do tree(ctx, -168 + 56 * i, -144, 12, 9) end
		for _, z in ipairs({ -90, -70, -50, -30, -10, 40, 80 }) do tree(ctx, 193, z, 12, 8) end
		for _, z in ipairs({ 20, 60 }) do palm(ctx, 195, z, 15) end
		-- palms: the east verge, the south verge west of the entrance, beside the grandstand
		for i = 0, 8 do palm(ctx, 218, -100 + 30 * i, 16) end
		for _, x in ipairs({ -205, -190, -175 }) do palm(ctx, x, 127, 15) end
		for _, z in ipairs({ 105, 125 }) do palm(ctx, 195, z, 15) end
	end)
end
