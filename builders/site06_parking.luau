-- site06_parking: the board's parking courts ("customer parking areas with landscaped islands"): the big north-east court above the
-- pitch, the west court along the west road, a small south court beside the grandstand; bay lines, tree islands, lamps and a few cars.
-- Module of builders/site06.luau (see its MODULE CONTRACT). Container: Parking.
-- Local frame: +X east, +Z south, origin (550, 0, -700). Cars and bays are human scale (bay 6 x 12, car 5 x 10), not 1.05 studs/m.
-- The courts are decks (world y 0..1.3, see DECK in builders/site06.luau); the section is lifted by DECK, so local y 0 is the court top.
return function(env)
	local V, CF, ANG, PI, C, M, DECK = env.V, env.CF, env.ANG, env.PI, env.C, env.M, env.DECK
	local box, vcyl, tree = env.box, env.vcyl, env.tree

	local CAR_COLOURS = {
		Color3.fromRGB(235, 235, 232), Color3.fromRGB(40, 42, 48), Color3.fromRGB(150, 152, 158), Color3.fromRGB(170, 40, 40),
		Color3.fromRGB(40, 70, 130), Color3.fromRGB(210, 210, 214), Color3.fromRGB(90, 96, 104), Color3.fromRGB(196, 160, 90),
	}
	local carN = 0
	-- One car on the court top (local y 0), centre (x, z), long axis along x (alongX) or z: body, cabin, two axles (4 parts).
	local function car(ctx, x, z, alongX)
		carN += 1
		local col = CAR_COLOURS[(carN - 1) % #CAR_COLOURS + 1]
		local rot = alongX and ANG(0, PI / 2, 0) or CFrame.new()
		local base = CF(x, 0, z) * rot -- local +Z = the car's long axis
		ctx:part("CarBody", V(5, 2, 10), base * CF(0, 1.8, 0), col, M.PLAS)
		local cab = ctx:part("CarCabin", V(4.4, 1.7, 5.4), base * CF(0, 3.65, -0.4), C.GLASS, M.GLASS)
		cab.Transparency = 0.15
		for _, dz in ipairs({ -3.3, 3.3 }) do
			ctx:cyl("CarWheel", V(5.4, 2, 2), base * CF(0, 1.0, dz), C.BLACK, M.PLAS)
		end
	end
	local function lampPost(ctx, x, z)
		vcyl(ctx, "CarParkPole", x, z, 0.5, 14, 0.5, C.DARK, M.METAL)
		ctx:part("CarParkLamp", V(2.4, 0.5, 1.2), CF(x, 14.25, z), C.BULB, M.NEON)
	end

	env.section("Parking", function(ctx)
		------------------------------------------------------------------ north-east court (x 62..186, z -98..-18)
		box(ctx, "ParkingNE", 62, 186, -DECK, 0, -98, -18, C.PARK, M.ASPHALT)
		local rows = { { -98, -86 }, { -74, -62 }, { -58, -46 }, { -34, -22 } }
		for _, r in ipairs(rows) do
			for k = 1, 20 do
				local x = 62 + 6 * k
				box(ctx, "BayLine", x - 0.15, x + 0.15, 0, 0.05, r[1], r[2], C.LINE, M.PLAS)
			end
		end
		box(ctx, "ParkingIsland", 66, 182, 0, 0.5, -62, -58, C.LAWN, M.GRASS)
		box(ctx, "ParkingIsland", 66, 182, 0, 0.5, -22, -18, C.LAWN, M.GRASS)
		for _, x in ipairs({ 72, 92, 112, 132, 152, 172 }) do tree(ctx, x, -60, 12, 8) end
		for _, x in ipairs({ 80, 110, 140, 170 }) do tree(ctx, x, -20, 12, 8) end
		for _, x in ipairs({ 82, 122, 162 }) do lampPost(ctx, x, -60) end
		for _, x in ipairs({ 95, 155 }) do lampPost(ctx, x, -20) end
		for _, x in ipairs({ 68, 125, 180 }) do env.palm(ctx, x, -20, 14) end -- tidy round: palms on the island
		-- cars in the bays (bay centres x 65 + 6k)
		for _, p in ipairs({ { 71, -92 }, { 83, -92 }, { 89, -92 }, { 119, -92 }, { 143, -92 }, { 167, -92 }, { 77, -68 }, { 101, -68 },
			{ 131, -68 }, { 149, -52 }, { 107, -52 }, { 89, -28 }, { 125, -28 }, { 161, -28 }, { 95, -92 }, { 155, -92 }, { 113, -68 },
			{ 173, -68 }, { 71, -52 }, { 83, -52 }, { 179, -52 }, { 101, -28 }, { 137, -28 }, { 173, -28 }, { 101, -92 }, { 125, -92 },
			{ 137, -92 }, { 173, -92 }, { 89, -68 }, { 143, -68 }, { 161, -68 }, { 119, -52 }, { 137, -52 }, { 77, -28 } }) do
			car(ctx, p[1], p[2], false)
		end
		-- planted strip along the court's north edge
		box(ctx, "ParkingIsland", 66, 182, -DECK, 0.5, -103, -99, C.LAWN, M.GRASS)
		for _, x in ipairs({ 74, 96, 118, 140, 162, 180 }) do tree(ctx, x, -101, 12, 8) end

		------------------------------------------------------------------ west court (x -210..-172, z 30..120), bays 12 deep along x
		box(ctx, "ParkingW", -210, -172, -DECK, 0, 30, 120, C.PARK, M.ASPHALT)
		box(ctx, "ParkingIsland", -210, -174, 0, 0.5, 72.5, 76.5, C.LAWN, M.GRASS)
		for _, x in ipairs({ -204, -192, -180 }) do tree(ctx, x, 74.5, 12, 8) end
		lampPost(ctx, -198, 74.5)
		for _, seg in ipairs({ { 32, 72 }, { 77, 117 } }) do
			for z = seg[1], seg[2] - 1, 6 do
				box(ctx, "BayLine", -210, -198, 0, 0.05, z - 0.15, z + 0.15, C.LINE, M.PLAS)
				box(ctx, "BayLine", -186, -174, 0, 0.05, z - 0.15, z + 0.15, C.LINE, M.PLAS)
			end
		end
		for _, p in ipairs({ { -204, 41 }, { -204, 59 }, { -180, 47 }, { -180, 65 }, { -204, 86 }, { -180, 92 }, { -204, 110 }, { -180, 104 } }) do
			car(ctx, p[1], p[2], true)
		end

		------------------------------------------------------------------ south court beside the grandstand (x -2..44, z 100..134)
		box(ctx, "ParkingS", -2, 44, -DECK, 0, 100, 134, C.PARK, M.ASPHALT)
		for k = 1, 7 do
			local x = -2 + 6 * k
			box(ctx, "BayLine", x - 0.15, x + 0.15, 0, 0.05, 122, 134, C.LINE, M.PLAS)
		end
		for _, x in ipairs({ 7, 19, 31 }) do car(ctx, x, 128, false) end
		car(ctx, 13, 113, true)
	end, nil, DECK)
end
