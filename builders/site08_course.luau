-- site08_course: Revision 3 (owner look, 2026-10-31): the board's golf course and its dense tropical planting.
-- Studio copy: ServerStorage.Builders.site08_course (run through builders/site08.luau only). World frame throughout.
-- Source: "Mount Malarayat Golf Resort Blueprint.png" (the board and its top-down inset) with PHOTOS/02_Aerial_and_Site_Layout 04 and 11 for
-- the colours (pale mown fairways, paler greens, white-sand bunkers, dark ponds, broadleaf woods and palms between the holes).
-- Gate axis +Z from the road mouth, so the board's left half is world +X (holes 2, 4 and 5, ponds E1 and E2) and its right is -X (holes 3 and
-- 6, the hotel's pond W1, pond W3 beside the drive). The terrain tees, greens and bunkers of the brief (holes 1-3) are kept and covered.
-- PLATES lie on the slope (env.slab / env.disc): their tops follow the terrain at fixed lifts, each layer its own (fairway 1.0, tee and
-- bunker 1.15, green 1.3, pond water 0.95..1.04), so nothing z-fights and the terrain's grass never shows through (thin-plate rule: >= 0.8).
-- Fairways, greens, bunkers and tees collide (walkable, 1-stud lips) and stay at least 3 studs from every pinned lane; pond water does not.
-- PLANTING: palms line the drive (both sides) and the perimeter; broadleaf woods fill the rest (Structure/Woods, then Structure/Grove),
-- each tree tested with env.sightClear (lanes, keep-clear boxes, the road-eye and Guide-eye window sight-lines) and kept off the course,
-- the ponds, the buildings, the plaza, the entrance (site08_entrance plants it) and the mountain (site08_context).
-- Pinned by tests/site08_check.luau groups "course" and "planting".
return function(env)
	local V = env.V
	local C, M = env.C, env.M
	local vcyl, box, ball, gnd = env.vcyl, env.box, env.ball, env.gnd
	local slab, disc = env.slab, env.disc
	local S = env.S

	local K = {
		FAIR = Color3.fromRGB(128, 186, 92), PUTT = Color3.fromRGB(150, 206, 112), TEE = Color3.fromRGB(140, 196, 100),
		SAND = Color3.fromRGB(228, 214, 168), POND = Color3.fromRGB(46, 112, 168),
	}
	local GRASS = Enum.Material.Grass

	------------------------------------------------------------------ layout (world x, z)
	-- Fairways: centre line A -> B and half-width; a slab between two end discs.
	local FAIRWAYS = {
		{ 598, 638, 704, 624, 12 }, -- hole 2: terrain tee (580, 640) -> terrain green (724, 620)
		{ 394, 610, 398, 696, 12 }, -- hole 3: terrain tee (388, 588) -> terrain green (400, 716)
		{ 616, 688, 698, 690, 10 }, -- hole 4 (new): tee (604, 690) -> green (712, 694)
		{ 484, 626, 496, 676, 9 }, -- hole 5 (new, beside the drive): tee (482, 614) -> green (498, 684)
		{ 424, 746, 380, 750, 9 }, -- hole 6 (new, below the hotel): tee (434, 742) -> green (374, 752)
	}
	local GREENS = { -- x, z, diameter, new flag (holes 2 and 3 keep site08_context's GreenFlag)
		{ 724, 620, 22, false }, { 400, 716, 22, false }, { 712, 694, 20, true }, { 498, 684, 14, true }, { 374, 752, 16, true },
	}
	local BUNKERS = { -- x, z, diameter; the first four cover the brief's terrain sand
		{ 706, 642, 12 }, { 742, 610, 12 }, { 382, 702, 12 }, { 418, 722, 12 },
		{ 690, 612, 10 }, { 656, 617, 9 }, { 726, 706, 9 }, { 700, 706, 9 }, { 510, 690, 8 }, { 388, 760, 8 }, { 412, 700, 8 }, { 366, 744, 7 },
	}
	local TEES = { { 580, 640, 12, 10 }, { 388, 590, 12, 8 }, { 604, 690, 8, 10 }, { 482, 614, 8, 8 }, { 434, 742, 8, 8 } }
	local PONDS = { -- each a list of overlapping discs { x, z, diameter }
		{ { 636, 661, 18 }, { 652, 659, 22 }, { 668, 663, 18 } }, -- E1 between holes 2 and 4 (the board's left pond)
		{ { 526, 632, 18 }, { 540, 640, 20 } }, -- E2 below the plaza, in the road-mouth view (flat, so it never cuts a sight-line)
		{ { 380, 796, 20 }, { 394, 806, 22 }, { 382, 816, 16 } }, -- W1 in front of the hotel
		{ { 418, 640, 14 }, { 420, 655, 16 } }, -- W3 west of the drive, beside hole 3 (off the drive's terrain shoulder, x > 426)
	}

	------------------------------------------------------------------ course plates (Structure/Fairways)
	local function flag(ctx, x, z)
		local base = gnd(x, z)
		assert(env.sightClear(x, z, 0.5, base + 11), string.format("site08_course: the flag at (%d, %d) cuts a sight-line", x, z))
		vcyl(ctx, "GreenFlag", x, z, base, base + 11, 0.35, C.WHITE, M.SMOOTH)
		box(ctx, "GreenFlagCloth", x + 0.2, x + 2.4, base + 9, base + 10.8, z - 0.1, z + 0.1, C.RED, M.SMOOTH)
	end
	env.section("Structure/Fairways", function(ctx)
		for _, f in ipairs(FAIRWAYS) do
			local ax, az, bx, bz, w = f[1], f[2], f[3], f[4], f[5]
			local d = V(bx - ax, 0, bz - az)
			slab(ctx, "Fairway", (ax + bx) / 2, (az + bz) / 2, d.Unit.X, d.Unit.Z, d.Magnitude, 2 * w, 1.0, 2.5, K.FAIR, GRASS)
			disc(ctx, "Fairway", ax, az, 2 * w, 0.97, 2.5, K.FAIR, GRASS)
			disc(ctx, "Fairway", bx, bz, 2 * w, 0.97, 2.5, K.FAIR, GRASS)
		end
		for _, t in ipairs(TEES) do
			slab(ctx, "TeeBox", t[1], t[2], 1, 0, t[3], t[4], 1.15, 2.5, K.TEE, GRASS)
		end
		for _, b in ipairs(BUNKERS) do
			disc(ctx, "Bunker", b[1], b[2], b[3], 1.15, 2.5, K.SAND, Enum.Material.Sand)
		end
		for _, g in ipairs(GREENS) do
			disc(ctx, "PuttingGreen", g[1], g[2], g[3], 1.3, 2.5, K.PUTT, M.SMOOTH)
			if g[4] then flag(ctx, g[1], g[2]) end
		end
	end)

	------------------------------------------------------------------ ponds (Structure/Ponds): translucent water discs, a ring of stones
	for _, pond in ipairs(PONDS) do
		local model = env.newFolder("Structure/Ponds", "CoursePond", "Model")
		env.section("Structure/Ponds", function(ctx)
			for i, c in ipairs(pond) do
				local w = disc(ctx, "PondWater", c[1], c[2], c[3], 0.92 + 0.04 * i, 2.5, K.POND, M.GLASS)
				w.Transparency = 0.2
				w.Reflectance = 0.1
				w.CanCollide = false
			end
			local k = 0
			for i, c in ipairs(pond) do
				local r = c[3] / 2
				for a = 0, 330, 36 do
					local x, z = c[1] + math.cos(math.rad(a + 10 * i)) * (r + 0.6), c[2] + math.sin(math.rad(a + 10 * i)) * (r + 0.6)
					local inside = false
					for j, o in ipairs(pond) do
						if j ~= i and (x - o[1]) ^ 2 + (z - o[2]) ^ 2 < (o[3] / 2 + 0.4) ^ 2 then inside = true end
					end
					local d = 2.2 + (k % 3) * 0.6
					local g = gnd(x, z)
					if not inside and env.sightClear(x, z, d / 2, g + d * 0.65) then
						ball(ctx, "PondStone", x, g + d * 0.15, z, d, (k % 2 == 0) and C.ROCK or C.ROCK_D, M.ROCK)
						k += 1
					end
				end
			end
			assert(k >= 4, "site08_course: a pond has only " .. k .. " stones")
		end, model)
	end

	------------------------------------------------------------------ where a tree may stand
	local function capsuleDist(x, z, f)
		local ax, az, bx, bz = f[1], f[2], f[3], f[4]
		local dx, dz = bx - ax, bz - az
		local t = math.clamp(((x - ax) * dx + (z - az) * dz) / (dx * dx + dz * dz), 0, 1)
		return math.sqrt((x - ax - t * dx) ^ 2 + (z - az - t * dz) ^ 2)
	end
	local function near(x, z, cx, cz, r) return (x - cx) ^ 2 + (z - cz) ^ 2 < r * r end
	local function onCourse(x, z, m)
		for _, f in ipairs(FAIRWAYS) do
			if capsuleDist(x, z, f) < f[5] + m then return true end
		end
		for _, list in ipairs({ GREENS, BUNKERS }) do
			for _, g in ipairs(list) do
				if near(x, z, g[1], g[2], g[3] / 2 + m) then return true end
			end
		end
		for _, t in ipairs(TEES) do
			if math.abs(x - t[1]) < t[3] / 2 + m and math.abs(z - t[2]) < t[4] / 2 + m then return true end
		end
		for _, pond in ipairs(PONDS) do
			for _, c in ipairs(pond) do
				if near(x, z, c[1], c[2], c[3] / 2 + m) then return true end
			end
		end
		return false
	end
	local function localOf(x, z) -- world -> clubhouse local (lx, lz)
		local a, b = (620 - x) / S, (z - 780) / S
		return (a + b) / 2, (a - b) / 2
	end
	local BOXES = {
		{ 356, 466, 818, 884 }, -- the hotel and its pool terrace
		{ 432, 504, 764, 856 }, -- terrain ponds A and B, the island green and its bridge
		{ 412, 440, 776, 808 }, -- hole 1 tee
		{ 508, 588, 656, 732 }, -- Guide plaza, panel, jeep stop
	}
	local function treeOK(x, z, m)
		if x < 366 or x > 754 or z > 874 then return false end
		if z < 620 and not (x >= 566 and z >= 566) then return false end -- the entrance (site08_entrance plants it)
		if x + z > 1470 then return false end -- the mountain
		if x > 540 and x < 608 and z > 858 then return false end -- its north-west arm
		if x > (z < 650 and 738 or 724) then return false end -- its east arm
		for _, b in ipairs(BOXES) do
			if x > b[1] - m and x < b[2] + m and z > b[3] - m and z < b[4] + m then return false end
		end
		local lx, lz = localOf(x, z)
		if lx > -80 and lx < 140 and lz > -34 and lz < 66 then return false end -- clubhouse, forecourt, pool
		return not onCourse(x, z, m)
	end
	-- Trees already standing (site08_context pines and palms, site08_entrance planting): spacing only.
	local chosen = {
		{ 600, 606 }, { 628, 604 }, { 656, 606 }, { 684, 604 }, { 604, 664 }, { 690, 660 }, { 700, 752 }, { 716, 738 }, { 600, 860 }, { 472, 622 },
		{ 515, 822 }, { 508, 846 }, { 520, 872 }, { 490, 872 }, { 505, 806 }, { 377, 836 }, { 438, 840 }, { 470, 862 },
		{ 509, 612 }, { 560, 612 }, { 534, 613 }, { 409, 613 }, { 362, 596 }, { 548, 610 }, { 520, 612 }, { 380, 608 },
	}
	local function spaced(x, z, m)
		for _, q in ipairs(chosen) do
			if near(x, z, q[1], q[2], m) then return false end
		end
		return true
	end

	------------------------------------------------------------------ palms (Structure/Palms): the drive, its east leg, the perimeter
	local PALMS = {}
	for z = 620, 690, 14 do
		table.insert(PALMS, { 457, z })
		table.insert(PALMS, { 443, z })
	end
	for _, p in ipairs({
		{ 466, 712 }, { 480, 712 }, { 494, 712 }, { 508, 712 }, -- the drive's east leg to the plaza
		{ 614, 610 }, { 642, 610 }, { 670, 610 }, { 726, 590 }, -- the south edge, between the pines
		{ 367, 624 }, { 367, 646 }, { 367, 668 }, { 367, 690 }, -- the west edge beside hole 3
	}) do
		table.insert(PALMS, p)
	end
	local palmsBuilt = 0
	env.section("Structure/Palms", function(ctx)
		for _, p in ipairs(PALMS) do
			local x, z = p[1], p[2]
			if not onCourse(x, z, 1) and spaced(x, z, 7) and env.sightClear(x, z, 2, gnd(x, z) + 18) then
				env.palm(ctx, x, z)
				table.insert(chosen, { x, z })
				palmsBuilt += 1
			end
		end
	end)
	assert(palmsBuilt >= 20, "site08_course: only " .. palmsBuilt .. " palms clear the lanes and sight-lines")

	------------------------------------------------------------------ broadleaf woods (Structure/Woods, then Structure/Grove)
	local cands = {}
	for x = 366, 754, 8 do
		for z = 566, 874, 8 do
			table.insert(cands, { x + env.rng:NextNumber(-3, 3), z + env.rng:NextNumber(-3, 3), 0.9 + env.rng:NextNumber(0, 0.25) })
		end
	end
	for i = #cands, 2, -1 do
		local j = env.rng:NextInteger(1, i)
		cands[i], cands[j] = cands[j], cands[i]
	end
	local trees = {}
	for _, p in ipairs(cands) do
		if #trees >= 215 then break end
		local x, z, s = p[1], p[2], p[3]
		if treeOK(x, z, 3) and spaced(x, z, 8.5) and env.sightClear(x, z, 7, gnd(x, z) + 17.75 * s + 0.5) then
			table.insert(trees, p)
			table.insert(chosen, { x, z })
		end
	end
	assert(#trees >= 180, "site08_course: only " .. #trees .. " broadleaf trees fit")
	env.section("Structure/Woods", function(ctx)
		for i = 1, math.min(130, #trees) do
			env.broadleaf(ctx, trees[i][1], trees[i][2], trees[i][3])
		end
	end)
	env.section("Structure/Grove", function(ctx)
		for i = 131, #trees do
			env.broadleaf(ctx, trees[i][1], trees[i][2], trees[i][3])
		end
	end)
end
