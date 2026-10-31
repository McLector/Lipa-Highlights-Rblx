-- site08_entrance: the board's main entrance at the road mouth (Revision 2). Studio copy: ServerStorage.Builders.site08_entrance
-- (run through builders/site08.luau only). World frame. Road D arrives from the south along x 450 (terrain asphalt x 444..456) and the gate axis is +Z,
-- so the board's left (rock sign and its lagoon) is world +X and its right (the second lagoon) is world -X.
--   Paved forecourt (x 414..462, z 560..612) in level x-strips seated by raycast (the ground rises 0.1 per stud along x).
--   Gatehouse astride the drive: a cream central pavilion with arched openings, a front pediment and a red-tile hip roof on an island west of the
--   drive axis (x 431..443), and two lane canopies with arched portals and lower hip roofs (east over the drive, west over the exit apron); iron gate
--   leaves drawn open, stone gate pillars, a yellow-rimmed round planter at the pavilion front.
--   Flag poles (4) on a raised planter island in front of the pavilion, west of the drive axis.
--   Rock monument with the lettering MOUNT MALARAYAT / GOLF AND COUNTRY CLUB (ASCII, fixed TextSize; the real sign, photo 03; owner-approved text),
--   east of the drive, facing the road; the entrance lagoon at its foot and a second lagoon west of the forecourt (Revision 3: each a translucent
--   water capsule lying on the slope 1.0 above the terrain inside a stone kerb ring, with rim boulders and stones in the water). No terrain writes.
-- Pinned (site08_check entrance group; sites_check lane a and the road-eye sight-line): every tall or wide thing is tested with env.sightClear and
-- skipped if it would cut a window sight-line; the drive lane (x 448..452, ground + 2 .. + 9) stays open under the east canopy (underside y 19).
return function(env)
	local V, CF, ANG, PI = env.V, env.CF, env.ANG, env.PI
	local C, M = env.C, env.M
	local box, vcyl, ball, gnd = env.box, env.vcyl, env.ball, env.gnd
	local ent = env.container("Entrance")
	local gh = env.newFolder("Entrance", "Gatehouse", "Model")
	local mon = env.newFolder("Entrance", "RockMonument", "Model")
	local lag = env.newFolder("Entrance", "Lagoons", "Model")

	local P = 9.6 -- gatehouse floor level (top of its island plinth)

	------------------------------------------------------------------ forecourt paving (level strips) and the flag island
	env.section("Entrance", function(ctx)
		local function strip(x0, x1, z0, z1, asphalt)
			local g0, g1 = gnd(x0, (z0 + z1) / 2), gnd(x1, (z0 + z1) / 2)
			local top = asphalt and (g1 + 1.0) or (math.max(g0, g1) + 1.6)
			box(ctx, "EntrancePaving", x0, x1, math.min(g0, g1) - 1.5, top, z0, z1, C.PAVE, M.PAVE)
		end
		for x = 414, 438, 6 do strip(x, x + 6, 560, 612, false) end
		strip(444, 448, 560, 592, true)
		strip(448, 452, 560, 592, true)
		strip(452, 456, 560, 592, true)
		strip(456, 462, 560, 592, false)
		-- Light kerbs along the forecourt sides.
		box(ctx, "ForecourtKerb", 413, 414, gnd(413, 586) - 1, gnd(414, 586) + 2, 560, 612, C.PAVE_L, M.CONC)
		box(ctx, "ForecourtKerb", 462, 463, gnd(462, 576) - 1, gnd(463, 576) + 2, 560, 592, C.PAVE_L, M.CONC)
		-- Flag island: raised planter, shrubs and flowers, four poles with plain cloths.
		local top = gnd(442, 573) + 2.6
		box(ctx, "FlagPlanter", 432, 442, gnd(432, 573) - 1, top, 568, 578, C.PAVE_L, M.CONC)
		box(ctx, "FlagPlanterSoil", 432.6, 441.4, top, top + 0.2, 568.6, 577.4, C.SHRUB, M.GRASS)
		for k = 0, 7 do
			local x, z = 433.5 + (k % 4) * 2.4, 569.8 + math.floor(k / 4) * 6.4
			ball(ctx, "IslandShrub", x, top + 0.9, z, 1.8, (k % 3 == 0) and C.FLOWER_R or ((k % 3 == 1) and C.FLOWER_Y or C.SHRUB), M.GRASS).CanCollide = false
		end
		local cloths = { C.RED, C.WHITE, C.YELLOW, C.BLUE }
		for i, x in ipairs({ 434, 436.67, 439.33, 442 - 0.6 }) do
			vcyl(ctx, "FlagPole", x, 573, top, top + 16, 0.35, C.WHITE, M.METAL)
			box(ctx, "FlagCloth", x + 0.2, x + 3.4, top + 13.2, top + 15.4, 572.95, 573.05, cloths[i], M.SMOOTH)
		end
	end)

	------------------------------------------------------------------ gatehouse
	local function portal(ctx, name, cx, z, wallW, openW, y0, y1)
		local res = ctx:arch(name, {
			width = openW, height = (y1 - y0) - 0.4, depth = 1.0, wallWidth = wallW, wallHeight = y1 - y0,
			cframe = CF(cx, (y0 + y1) / 2, z), color = C.CREAM, material = M.PLASTER,
		})
		for _, p in ipairs(res.parts) do p.Name = name end
	end
	env.section("Entrance", function(ctx)
		box(ctx, "GatehousePlinth", 430, 444, gnd(430, 598) - 1, P, 591, 605, C.STONE, M.LIME)
		-- Four arched walls (CSG; the doors are 9 high) and four cream corner pilasters.
		local function wall(cf, w, openW, openH)
			local res = ctx:arch("GatehouseArch", {
				width = openW, height = openH, depth = 1.0, wallWidth = w, wallHeight = 12, cframe = cf * CF(0, P + 6, 0), color = C.CREAM, material = M.PLASTER,
			})
			for _, p in ipairs(res.parts) do p.Name = "GatehouseArch" end
		end
		wall(CF(437, 0, 592.5), 10, 4.5, 9)
		wall(CF(437, 0, 603.5), 10, 4.5, 9)
		wall(CF(442.5, 0, 598) * ANG(0, PI / 2, 0), 10, 4, 8.5)
		wall(CF(431.5, 0, 598) * ANG(0, PI / 2, 0), 10, 4, 8.5)
		for _, c in ipairs({ { 431, 592 }, { 443, 592 }, { 431, 604 }, { 443, 604 } }) do
			box(ctx, "GatehouseWall", c[1] - 1, c[1] + 1, P, P + 12, c[2] - 1, c[2] + 1, C.CREAM, M.PLASTER)
		end
		box(ctx, "GatehouseCornice", 429.6, 444.4, P + 12, P + 13, 590.6, 605.4, C.TRIM, M.SMOOTH)
		box(ctx, "GuardCounter", 433, 441, P, P + 3.5, 598, 600, C.TIMBER, M.WOOD)
		for _, w in ipairs(ctx:gable("GatehousePediment", 12, 4, 0.8, CF(437, P + 13, 590.2))) do w.Color = C.CREAM end
		box(ctx, "PedimentTrim", 430.6, 443.4, P + 12.6, P + 13.2, 589.6, 590.8, C.TRIM, M.SMOOTH)
		-- Lane canopies: beams (underside y 19, above the drive lane), outer columns, arched portals on the road side.
		box(ctx, "GatehouseBeam", 443, 457, 19, 20.4, 593, 603, C.TRIM, M.SMOOTH)
		box(ctx, "GatehouseBeam", 417, 431, 19, 20.4, 593, 603, C.TRIM, M.SMOOTH)
		for _, c in ipairs({ { 456.3, 593.8 }, { 456.3, 602.2 }, { 417.7, 593.8 }, { 417.7, 602.2 } }) do
			vcyl(ctx, "GatehouseColumn", c[1], c[2], gnd(c[1], c[2]) - 0.5, 19, 1.3, C.CREAM, M.PLASTER)
		end
		-- Over the drive the opening is the flat beam with two corner spandrels only: the lane guard tests bounding boxes, so no single part may
		-- span x 448..452 below y 17.8 (a CSG arch would, even with its hole). The exit apron gets a full arched portal.
		for _, s in ipairs({ { 445.5, 1 }, { 454.5, -1 } }) do
			local wdg = ctx:wedge("GatehouseArchSpandrel", V(1.0, 2.4, 3), CF(s[1], 17.8, 592.6) * ANG(0, s[2] == 1 and -PI / 2 or PI / 2, PI), C.CREAM, M.PLASTER)
			wdg.Name = "GatehouseArchSpandrel"
			box(ctx, "GatehousePier", s[1] - s[2] * 2.3 - 0.8, s[1] - s[2] * 2.3 + 0.8, gnd(s[1], 592) - 0.5, 19, 592.1, 593.1, C.CREAM, M.PLASTER)
		end
		portal(ctx, "GatehouseArch", 424, 592.6, 14, 12, gnd(424, 592) - 0.4, 20.4)
		-- Round planter with a yellow rim at the pavilion front.
		local pt = gnd(440, 588) + 1.6
		vcyl(ctx, "GatePlanterRim", 437, 588, pt - 0.4, pt + 1.0, 5, C.YELLOW, M.CONC)
		for k = 0, 2 do
			ball(ctx, "GatePlanterFlower", 436 + k, pt + 1.6, 588 + (k - 1) * 0.8, 1.8, k == 1 and C.FLOWER_R or C.FLOWER_Y, M.GRASS).CanCollide = false
		end
		-- Iron gate leaves, drawn open along the drive edges (outside every lane).
		for _, x in ipairs({ 457.8, 416.2 }) do
			local g = gnd(x, 608)
			local leaf = box(ctx, "GateLeaf", x - 0.2, x + 0.2, g, g + 5, 604, 612, C.IRON, M.METAL)
			leaf.Transparency = 0.35
		end
	end, gh)
	env.roof("Entrance", gh, env.ID, CF(437, P + 13, 598), 15, 15, 6.5)
	env.roof("Entrance", gh, env.ID, CF(450, 20.4, 598), 14, 12, 4.2)
	env.roof("Entrance", gh, env.ID, CF(424, 20.4, 598), 14, 12, 4.2)

	------------------------------------------------------------------ gate pillars and low balustrade fences (sight-line tested)
	env.section("Entrance", function(ctx)
		for _, p in ipairs({ { 460.5, 590 }, { 413.5, 590 }, { 506, 588 }, { 366, 588 } }) do
			local g = gnd(p[1], p[2])
			if env.sightClear(p[1], p[2], 1.4, g + 5.4) then
				box(ctx, "GatePillar", p[1] - 1, p[1] + 1, g - 0.5, g + 4.6, p[2] - 1, p[2] + 1, C.PAVE_L, M.LIME)
				box(ctx, "GatePillarCap", p[1] - 1.3, p[1] + 1.3, g + 4.6, g + 5.4, p[2] - 1.3, p[2] + 1.3, C.TRIM, M.SMOOTH)
			else
				-- inside the road-eye sight wedge: a low pillar (no cap) keeps the view to the clubhouse windows
				box(ctx, "GatePillar", p[1] - 1, p[1] + 1, g - 0.5, g + 2.6, p[2] - 1, p[2] + 1, C.PAVE_L, M.LIME)
			end
		end
		for _, run in ipairs({ { 462, 504, 588 }, { 368, 412, 588 } }) do
			for x = run[1], run[2] - 6, 6 do
				local g = math.max(gnd(x, run[3]), gnd(x + 6, run[3]))
				if env.sightClear(x + 3, run[3], 0.5, g + 2.6) then
					box(ctx, "Balustrade", x, x + 6, g - 0.6, g + 2.6, run[3] - 0.4, run[3] + 0.4, C.TRIM, M.SMOOTH)
				end
			end
		end
	end)

	------------------------------------------------------------------ rock monument with the lettering
	env.section("Entrance", function(ctx)
		box(ctx, "MonumentBase", 512.5, 551.5, gnd(512, 590) - 1, 19.4, 588.8, 593, C.ROCK_D, M.ROCK)
		local sign = box(ctx, "MonumentSign", 512, 552, 19.2, 28.2, 588.5, 591.5, C.ROCK_L, M.SLATE)
		local gui = Instance.new("SurfaceGui")
		gui.Face = Enum.NormalId.Front -- -Z, toward the road
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 20
		gui.LightInfluence = 0.6
		gui.Parent = sign
		local function label(text, size, y, h)
			local l = Instance.new("TextLabel")
			l.BackgroundTransparency = 1
			l.Size = UDim2.fromScale(0.96, h)
			l.Position = UDim2.fromScale(0.02, y)
			l.Font = Enum.Font.Garamond
			l.TextScaled = false
			l.TextSize = size
			l.TextColor3 = Color3.fromRGB(226, 226, 220)
			l.TextStrokeColor3 = Color3.fromRGB(40, 36, 32)
			l.TextStrokeTransparency = 0.35
			l.Text = text
			l.Parent = gui
		end
		label("MOUNT MALARAYAT", 70, 0.06, 0.55)
		label("GOLF AND COUNTRY CLUB", 40, 0.6, 0.34)
		-- Rock mass: a base under the slab, big boulders behind and at both ends (deterministic sizes).
		local placed = 0
		local function rock(x, z, d, yOff)
			local g = gnd(x, z)
			local top = g + d * 0.8 + (yOff or 0)
			if env.sightClear(x, z, d / 2, top) then
				local col = (placed % 3 == 0) and C.ROCK_D or ((placed % 3 == 1) and C.ROCK or C.ROCK_L)
				ball(ctx, "MonumentRock", x, top - d / 2, z, d, col, M.ROCK)
				placed += 1
			end
		end
		-- Session 062 (owner: the front rocks hid most of GOLF AND COUNTRY CLUB): the five big front rocks (x 514..549, tops 22.3..25.8) are
		-- gone from in front of the lettering (x 519.7..544.3; line 2 spans y 20.3..22.3). Two flank the slab ends instead, and low foot stones
		-- below the sign's bottom edge (tops capped at y 18.8, the slab starts at 19.2) sit in front of the text. site08_check group "sign".
		for _, r in ipairs({ { 520, 586.5, 3.5 }, { 527, 586, 3 }, { 535, 586.5, 3.5 }, { 542, 586, 3 } }) do
			local x, z, d = r[1], r[2], r[3]
			local g = gnd(x, z)
			local top = math.min(g + d * 0.5, 18.8)
			if top - g >= 0.8 then
				ball(ctx, "MonumentRock", x, top - d / 2, z, d, (placed % 2 == 0) and C.ROCK_D or C.ROCK, M.ROCK)
				placed += 1
			end
		end
		for _, r in ipairs({
			{ 508, 586.5, 6.5 }, { 553, 586.5, 7 },
			{ 511, 594, 12 }, { 521, 596, 14 }, { 532, 597, 15 }, { 543, 596, 14 }, { 553, 594, 12 },
			{ 526, 603, 12 }, { 538, 604, 13 }, { 549, 602, 11 }, { 516, 602, 10 },
			{ 506, 589, 8 }, { 558, 588, 9 }, { 560, 598, 10 }, { 504, 597, 9 },
		}) do
			rock(r[1], r[2], r[3], 1.5)
		end
		assert(placed >= 12, "site08_entrance: only " .. placed .. " monument rocks clear the sight-lines")
	end, mon)

	------------------------------------------------------------------ lagoons (Revision 3): water lying on the slope in a stone edge, boulders
	-- Revision 2's level terraces stood up to 5 studs above the low ground (owner: "flat raised blue slabs"). Each lagoon is now a capsule
	-- (a slab between two end discs) whose top follows the terrain 1.0 above it (the brief's thin-plate rule), translucent blue, inside a stone
	-- kerb ring 0.5 higher (LagoonEdge: the two long sides and 6 segments round each end), with rim boulders and the board's stones in the water.
	-- East: centres x 474..548 (the rock sign's foot); west: x 375..403. Both z 562..583 (radius 10.5), clear of the paved forecourt x 414..463.
	local LAGOONS = { { x0 = 474, x1 = 548 }, { x0 = 375, x1 = 403 } }
	local LZ, LR = 572.5, 10.5
	env.section("Entrance", function(ctx)
		for _, L in ipairs(LAGOONS) do
			local cx = (L.x0 + L.x1) / 2
			local parts = {
				env.slab(ctx, "LagoonWater", cx, LZ, 1, 0, L.x1 - L.x0, LR * 2, 1.0, 2.5, C.LAGOON, M.GLASS),
				env.disc(ctx, "LagoonWater", L.x0, LZ, LR * 2, 0.95, 2.5, C.LAGOON, M.GLASS),
				env.disc(ctx, "LagoonWater", L.x1, LZ, LR * 2, 0.95, 2.5, C.LAGOON, M.GLASS),
			}
			for _, w in ipairs(parts) do
				w.Transparency = 0.2
				w.Reflectance = 0.1
				w.CanCollide = false
			end
			-- Stone kerb: the two long sides, then 6 tangential segments round each end.
			for _, s in ipairs({ -1, 1 }) do
				env.slab(ctx, "LagoonEdge", cx, LZ + s * (LR + 0.8), 1, 0, L.x1 - L.x0, 1.6, 1.5, 3, C.STONE, M.LIME)
			end
			local rr = LR + 0.8
			for _, e in ipairs({ { L.x0, -1 }, { L.x1, 1 } }) do
				for k = 0, 5 do
					local a = math.rad(-75 + k * 30)
					local ux, uz = e[2] * math.cos(a), math.sin(a)
					env.slab(ctx, "LagoonEdge", e[1] + ux * rr, LZ + uz * rr, -uz, ux, 2 * math.pi * rr / 12 + 0.6, 1.6, 1.5, 3, C.STONE, M.LIME)
				end
			end
		end
		local n = 0
		local function boulder(x, z, d, inWater)
			local base = gnd(x, z) + (inWater and 0.7 or 0.6)
			local top = base + d * 0.45
			-- Session 062: rim boulders at the sign's foot stay below its bottom edge (y 19.2) in front of the lettering.
			if z > 580 and x > 514 and x < 550 then top = math.min(top, 18.8) end
			if env.sightClear(x, z, d / 2, top) then
				ball(ctx, "LagoonBoulder", x, top - d / 2, z, d, (n % 2 == 0) and C.ROCK or C.ROCK_D, M.ROCK)
				n += 1
			end
		end
		-- Rim boulders on the kerb: north side (under the rock sign), south side, the ends.
		for x = 466, 556, 9 do boulder(x, 585, 3.4 + (x % 3) * 0.5) end
		for x = 470, 550, 10 do boulder(x, 561.5, 3.0 + (x % 3) * 0.4) end
		for _, p in ipairs({ { 462, 569 }, { 462, 577 }, { 560, 567 }, { 560, 578 } }) do boulder(p[1], p[2], 3.8) end
		for x = 368, 410, 7 do boulder(x, 585, 3.2 + (x % 3) * 0.4) end
		for x = 372, 406, 8.5 do boulder(x, 561.5, 3.0 + (x % 3) * 0.4) end
		for _, p in ipairs({ { 362.5, 568 }, { 362.5, 577 } }) do boulder(p[1], p[2], 3.4) end
		-- Stones standing in the water (the board's round stones).
		for _, p in ipairs({ { 488, 576 }, { 500, 567 }, { 514, 578 }, { 526, 566 }, { 538, 575 }, { 549, 569 }, { 479, 566 },
			{ 380, 575 }, { 392, 567 }, { 402, 577 } }) do
			boulder(p[1], p[2], 3.6, true)
		end
		assert(n >= 20, "site08_entrance: only " .. n .. " lagoon boulders clear the sight-lines")
	end, lag)

	------------------------------------------------------------------ planting around the entrance (palms, a few broadleaf trees, flowering shrubs)
	env.section("Entrance", function(ctx)
		for _, p in ipairs({ { 509, 612 }, { 560, 612 }, { 534, 613 }, { 409, 613 }, { 362, 596 } }) do
			if env.sightClear(p[1], p[2], 2, gnd(p[1], p[2]) + 18) then env.palm(ctx, p[1], p[2]) end
		end
		for _, p in ipairs({ { 548, 610 }, { 520, 612 }, { 380, 608 } }) do
			if env.sightClear(p[1], p[2], 7, gnd(p[1], p[2]) + 17) then env.broadleaf(ctx, p[1], p[2], 0.9) end
		end
		for _, p in ipairs({ { 464, 586 }, { 476, 586 }, { 490, 586 }, { 504, 584 }, { 370, 586 }, { 384, 586 }, { 398, 586 }, { 410, 586 },
			{ 557, 584 }, { 362, 584 } }) do
			env.clump(ctx, p[1], p[2], (p[1] % 3 < 1) and C.FLOWER_R or C.FLOWER_Y)
		end
	end)
end
