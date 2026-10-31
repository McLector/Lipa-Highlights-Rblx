-- site06_pitch: the Aboitiz Pitch (board: "FIFA-sized artificial turf with field markings"), the curved grandstand and support building
-- with its solar roof (board: "curved grandstand with solar panels, locker rooms and support facilities"), and the brown-roofed support
-- pavilion at the pitch's north-west corner. Module of builders/site06.luau (see its MODULE CONTRACT and DECK).
-- Containers: SportsField, Structure/Stand, Structure/PitchHouse. Local frame: +X east, +Z south, origin (550, 0, -700).
-- Field at 1.05 studs/m: 105 x 68 m -> lines x 63..173, z 12.3..83.7 (centre (118, 48)). The turf is a deck (world y 0..1.3) over
-- x 49..187, z -1..96 with a concrete apron west of it (x 44..49) and under the stand (x 44..190, z 96..134); every section is lifted by
-- DECK, so local y 0 is the turf top. Goals, dugouts and doors are human scale (goal 12 x 6). The stand is an arc of 9 straight segments
-- round (118, -128), front radius 236: the middle bulges 7 studs further south than the ends, as on the board. PitchTurf and StandTiers
-- are unique names.
return function(env)
	local V, CF, ANG, PI, C, M, DECK = env.V, env.CF, env.ANG, env.PI, env.C, env.M, env.DECK
	local box, obox, vcyl, gui = env.box, env.obox, env.vcyl, env.gui
	local rad = math.rad
	local CX, CZ = 118, 48
	local GX0, GX1, TZ0, TZ1 = 63, 173, 12.3, 83.7

	local function net(p)
		p.Transparency = 0.6
		return p
	end

	env.section("SportsField", function(ctx)
		box(ctx, "PitchTurf", 49, 187, -DECK, 0, -1, 96, C.TURF, M.PLAS)
		box(ctx, "PitchApronW", 44, 49, -DECK, 0, -1, 96, C.CONCRETE, M.CONC)
		local sw = (GX1 - GX0) / 12
		for k = 1, 11, 2 do
			box(ctx, "TurfStripe", GX0 + k * sw, GX0 + (k + 1) * sw, 0, 0.04, TZ0, TZ1, C.TURF2, M.PLAS)
		end
		local function line(name, x0, x1, z0, z1, top)
			return box(ctx, name, x0, x1, 0, top or 0.07, z0, z1, C.LINE, M.PLAS)
		end
		local t = 0.175
		line("TouchLine", GX0 - t, GX1 + t, TZ0 - t, TZ0 + t)
		line("TouchLine", GX0 - t, GX1 + t, TZ1 - t, TZ1 + t)
		line("GoalLine", GX0 - t, GX0 + t, TZ0, TZ1)
		line("GoalLine", GX1 - t, GX1 + t, TZ0, TZ1)
		line("HalfwayLine", CX - t, CX + t, TZ0, TZ1)
		vcyl(ctx, "CentreCircle", CX, CZ, 0, 0.06, 19.2, C.LINE, M.PLAS)
		vcyl(ctx, "CentreCircleFill", CX, CZ, 0, 0.065, 18.5, C.TURF, M.PLAS)
		vcyl(ctx, "CentreSpot", CX, CZ, 0, 0.075, 0.8, C.LINE, M.PLAS)
		for _, e in ipairs({ { GX0, 1 }, { GX1, -1 } }) do
			local x0, dir = e[1], e[2]
			local function span(a, b) return math.min(a, b), math.max(a, b) end
			local px0, px1 = span(x0, x0 + dir * 17.3)
			local gx0, gx1 = span(x0, x0 + dir * 5.8)
			local pf, gf = x0 + dir * 17.3, x0 + dir * 5.8
			line("PenaltyLine", pf - t, pf + t, CZ - 21.15, CZ + 21.15)
			line("PenaltyLine", px0, px1, CZ - 21.15 - t, CZ - 21.15 + t)
			line("PenaltyLine", px0, px1, CZ + 21.15 - t, CZ + 21.15 + t)
			line("PenaltyLine", gf - t, gf + t, CZ - 10, CZ + 10)
			line("PenaltyLine", gx0, gx1, CZ - 10 - t, CZ - 10 + t)
			line("PenaltyLine", gx0, gx1, CZ + 10 - t, CZ + 10 + t)
			vcyl(ctx, "PenaltySpot", x0 + dir * 11.5, CZ, 0, 0.075, 0.8, C.LINE, M.PLAS)
			-- goal (12 wide, 6 high, 3 deep), net behind the line
			for _, sz in ipairs({ -6, 6 }) do
				box(ctx, "GoalPost", x0 - 0.25, x0 + 0.25, 0, 6, CZ + sz - 0.25, CZ + sz + 0.25, C.LINE, M.METAL)
			end
			box(ctx, "GoalBar", x0 - 0.25, x0 + 0.25, 6, 6.5, CZ - 6.25, CZ + 6.25, C.LINE, M.METAL)
			local bx = x0 - dir * 3
			net(box(ctx, "GoalNet", bx - 0.05, bx + 0.05, 0, 6, CZ - 6, CZ + 6, C.LINE, M.PLAS))
			local nx0, nx1 = span(x0, bx)
			net(box(ctx, "GoalNet", nx0, nx1, 5.95, 6.05, CZ - 6, CZ + 6, C.LINE, M.PLAS))
		end
		-- training goals lined up along the stand side (board's pitch perspective)
		for _, x in ipairs({ 95, 118, 141 }) do
			for _, dx in ipairs({ -3, 3 }) do
				box(ctx, "TrainGoalPost", x + dx - 0.15, x + dx + 0.15, 0, 3, 89 - 0.15, 89 + 0.15, C.LINE, M.METAL)
			end
			box(ctx, "TrainGoalBar", x - 3.15, x + 3.15, 3, 3.3, 89 - 0.15, 89 + 0.15, C.LINE, M.METAL)
		end
		-- dugouts on the north side (bench seat top 2.0)
		for _, x in ipairs({ 106, 130 }) do
			box(ctx, "DugoutRoof", x - 5, x + 5, 5.8, 6.2, 3.5, 7.5, C.BROWN, M.PLAS)
			box(ctx, "DugoutBack", x - 5, x + 5, 0, 5.8, 3.5, 3.8, C.WHITE, M.CONC)
			box(ctx, "DugoutSeat", x - 4.5, x + 4.5, 1.6, 2.0, 4, 5.2, C.BROWN, M.WOOD)
		end
		-- fence (north, west with a gate gap at the pitch walk z 36..52, east; the stand closes the south)
		net(box(ctx, "PitchFence", 50, 186, 0, 10, -0.075, 0.075, C.STEEL, M.PLAS))
		net(box(ctx, "PitchFence", 49.925, 50.075, 0, 10, 0, 36, C.STEEL, M.PLAS))
		net(box(ctx, "PitchFence", 49.925, 50.075, 0, 10, 52, 96, C.STEEL, M.PLAS))
		net(box(ctx, "PitchFence", 185.925, 186.075, 0, 10, 0, 96, C.STEEL, M.PLAS))
		for i = 0, 8 do vcyl(ctx, "FencePost", 50 + 17 * i, 0, 0, 10, 0.4, C.STEEL, M.METAL) end
		for _, z in ipairs({ 17, 34, 52, 68, 85 }) do vcyl(ctx, "FencePost", 50, z, 0, 10, 0.4, C.STEEL, M.METAL) end
		for _, z in ipairs({ 17, 34, 51, 68, 85 }) do vcyl(ctx, "FencePost", 186, z, 0, 10, 0.4, C.STEEL, M.METAL) end
		-- floodlights at the turf corners
		for _, p in ipairs({ { 51, 0 }, { 185, 0 }, { 51, 95 }, { 185, 95 } }) do
			vcyl(ctx, "FloodMast", p[1], p[2], 0, 30, 1.2, C.STEEL, M.METAL)
			ctx:part("FloodHead", V(6, 3, 1), CFrame.lookAt(V(p[1], 30.5, p[2]), V(CX, 0, CZ)), C.DARK, M.PLAS)
		end
		-- the pitch sign on the west apron at the gate, facing the promenade (west)
		for _, z in ipairs({ 19, 33 }) do vcyl(ctx, "PitchSignPost", 47, z, 0, 8.5, 0.5, C.STEEL, M.METAL) end
		local sign = box(ctx, "PitchSign", 46.7, 47.3, 5, 8.5, 18, 34, Color3.fromRGB(30, 90, 50), M.PLAS)
		gui(sign, Enum.NormalId.Left, "ABOITIZ PITCH", nil, Color3.new(1, 1, 1), 30, 48)
	end, nil, DECK)

	env.section("Structure/Stand", function(ctx)
		box(ctx, "StandApron", 44, 190, -DECK, 0, 96, 134, C.CONCRETE, M.CONC)
		local OX, OZ, RF = 118, -128, 236
		local segLen = 16
		for i = 0, 8 do
			local a = rad(-14 + 3.5 * i)
			local s, c = math.sin(a), math.cos(a)
			local F = CFrame.fromMatrix(V(OX + RF * s, 0, OZ + RF * c), V(c, 0, -s), V(0, 1, 0), V(s, 0, c))
			obox(ctx, "StandFront", F * CF(0, 0.6, 0.3), V(segLen, 1.2, 0.6), C.CONCRETE, M.CONC)
			for k = 0, 3 do
				local hgt = 2 + 2 * k
				local name = (i == 4 and k == 0) and "StandTiers" or "StandTier"
				obox(ctx, name, F * CF(0, hgt / 2, 0.6 + 3.5 * k + 1.75), V(segLen, hgt, 3.5), C.CONCRETE, M.CONC)
			end
			obox(ctx, "StandBack", F * CF(0, 7, 18.6), V(segLen, 14, 8), C.WHITE, M.CONC)
			obox(ctx, "StandBand", F * CF(0, 11, 22.75), V(segLen, 1.6, 0.3), C.ORANGE, M.WOOD)
			obox(ctx, "StandRoof", F * CF(0, 14.3, 10.6), V(segLen + 0.4, 0.6, 24), C.BROWN, M.PLAS)
			obox(ctx, "StandSolar", F * CF(0, 14.75, 10.6), V(segLen - 0.8, 0.3, 20), C.SOLAR, M.GLASS)
			if i == 1 or i == 4 or i == 7 then
				obox(ctx, "StandDoor", F * CF(0, 4.4, 22.75), V(4, 8.8, 0.3), C.DARK, M.PLAS)
			end
		end
		-- two aisle stairs (1-stud risers) at segment joints
		for _, deg in ipairs({ -5.25, 8.75 }) do
			local a = rad(deg)
			local s, c = math.sin(a), math.cos(a)
			local F = CFrame.fromMatrix(V(OX + RF * s, 0, OZ + RF * c), V(c, 0, -s), V(0, 1, 0), V(s, 0, c))
			for k = 0, 7 do
				obox(ctx, "StandStair", F * CF(0, (1 + k) / 2, 0.6 + 1.75 * k + 0.875), V(2.4, 1 + k, 1.75), Color3.fromRGB(214, 212, 206), M.CONC)
			end
		end
	end, nil, DECK)

	env.section("Structure/PitchHouse", function(ctx)
		box(ctx, "PitchHouseBody", 31, 55, 0, 10, -36, -16, C.WHITE, M.CONC)
		box(ctx, "PitchHouseRoof", 29.5, 56.5, 10, 10.8, -37.5, -14.5, C.MAROON, M.PLAS)
		-- low hip: two wedges rising to a ridge along x at z -26
		ctx:wedge("PitchHouseRoofSlope", V(27, 3, 11.5), CF(43, 12.3, -31.75), C.MAROON, M.PLAS)
		ctx:wedge("PitchHouseRoofSlope", V(27, 3, 11.5), CF(43, 12.3, -20.25) * ANG(0, PI, 0), C.MAROON, M.PLAS)
		box(ctx, "PitchHouseDoor", 41, 45, 0, 8.8, -16, -15.7, C.DARK, M.PLAS)
		local g = box(ctx, "PitchHouseGlass", 47, 53, 3, 8, -16, -15.8, C.GLASS, M.GLASS)
		g.Transparency = 0.25
	end, nil, DECK)
end
