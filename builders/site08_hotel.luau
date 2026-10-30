-- site08_hotel: the board's "Hotel & Suites wing" (Revision 2). Studio copy: ServerStorage.Builders.site08_hotel (run through builders/site08.luau only).
-- World frame. Placed as the board places it relative to the gate and the clubhouse: to the right of and behind the clubhouse when seen from the
-- main entrance (world -x, +z), along the north edge beside the pond, with its own pool terrace in front (the board's free-form pool, two rectangles here).
-- Massing (board 3D view): a long four-storey wing with balconies under one long red-tile hip roof, a taller five-storey block at its east end with
-- its own hip roof, and a low two-storey wing at the west end. Cream walls, white balcony rails, glazed lobby (doors 9 high).
-- The ground slopes 0.1 per stud along x, so everything stands on one level podium (floor y 9.6) seated from the ground by raycast.
-- Pinned (site08_check hotel group): Hotel container, HotelWindow (50 on 5 levels), HotelWall (cream), RoofHip x 3, HotelBalconyRail (10).
return function(env)
	local V, CF = env.V, env.CF
	local C, M = env.C, env.M
	local box, vcyl, ball = env.box, env.vcyl, env.ball
	local hotel = env.container("Hotel")
	local FLOOR = 9.6
	local LEVELS = { 9.6, 19.6, 28.6, 37.6, 46.6, 55.6 } -- storey bases; the wing tops out at 46.6, the east block at 55.6

	local function glass(p)
		p.Transparency = 0.3
		return p
	end

	env.section("Hotel", function(ctx)
		-- Podium: from below the lowest ground to the floor level.
		local gmin = math.min(env.gnd(362, 850), env.gnd(362, 878))
		box(ctx, "HotelPodium", 361, 459, gmin - 1, FLOOR, 849, 879, C.SAND, M.LIME)
		-- Walls (cream masses).
		box(ctx, "HotelWall", 376, 440, FLOOR, LEVELS[5], 856, 874, C.CREAM, M.PLASTER) -- main wing, four storeys
		box(ctx, "HotelWall", 440, 458, FLOOR, LEVELS[6], 852, 877, C.CREAM, M.PLASTER) -- east block, five storeys
		box(ctx, "HotelWall", 362, 376, FLOOR, LEVELS[3], 858, 872, C.CREAM, M.PLASTER) -- west low wing, two storeys
		-- Cornices under the eaves.
		box(ctx, "HotelCornice", 375.6, 440, LEVELS[5] - 1, LEVELS[5], 855.6, 874.4, C.TRIM, M.SMOOTH)
		box(ctx, "HotelCornice", 439.6, 458.4, LEVELS[6] - 1, LEVELS[6], 851.6, 877.4, C.TRIM, M.SMOOTH)
		box(ctx, "HotelCornice", 361.6, 376, LEVELS[3] - 1, LEVELS[3], 857.6, 872.4, C.TRIM, M.SMOOTH)
		-- Main wing front (south, z 856): 10 window bays on four storeys, vertical piers, balconies with rails on floors 2..4.
		for i = 0, 9 do
			local x = 381.9 + 5.8 * i
			for f = 1, 4 do
				local y0 = LEVELS[f] + (f == 1 and 2 or 1.6)
				if not (f == 1 and (i == 4 or i == 5)) then
					glass(box(ctx, "HotelWindow", x - 1.6, x + 1.6, y0, y0 + 5.6, 855.4, 856.1, C.GLASS, M.GLASS))
				end
			end
		end
		for _, x in ipairs({ 378, 390, 402, 414, 426, 438 }) do
			box(ctx, "HotelPier", x - 0.6, x + 0.6, FLOOR, LEVELS[5] - 1, 852.4, 856, C.CREAM, M.PLASTER)
		end
		for f = 2, 4 do
			local y = LEVELS[f]
			box(ctx, "HotelBalcony", 378, 438, y - 0.3, y + 0.5, 852.4, 856, C.TRIM, M.SMOOTH)
			box(ctx, "HotelBalconyRail", 378.6, 407.6, y + 0.5, y + 3.5, 852.4, 852.9, C.TRIM, M.SMOOTH)
			box(ctx, "HotelBalconyRail", 408.4, 437.4, y + 0.5, y + 3.5, 852.4, 852.9, C.TRIM, M.SMOOTH)
		end
		-- Lobby: glazed front in the two middle bays, doors 9 high, a white canopy on two posts.
		glass(box(ctx, "HotelLobbyGlass", 404, 416, FLOOR, FLOOR + 9, 855.6, 856.1, C.GLASS, M.GLASS))
		box(ctx, "HotelCanopy", 402, 418, FLOOR + 10, FLOOR + 10.8, 846, 856, C.TRIM, M.SMOOTH)
		for _, x in ipairs({ 403, 417 }) do
			vcyl(ctx, "HotelCanopyPost", x, 847, FLOOR, FLOOR + 10, 0.8, C.TRIM, M.SMOOTH)
		end
		-- East block front (z 852): 2 windows on each of five storeys, balconies with rails on floors 2..5.
		for f = 1, 5 do
			local y0 = LEVELS[f] + (f == 1 and 2 or 1.6)
			for _, x in ipairs({ 445, 453 }) do
				glass(box(ctx, "HotelWindow", x - 2, x + 2, y0, y0 + 5.6, 851.4, 852.1, C.GLASS, M.GLASS))
			end
			if f >= 2 then
				local y = LEVELS[f]
				box(ctx, "HotelBalcony", 441, 457, y - 0.3, y + 0.5, 849.4, 852, C.TRIM, M.SMOOTH)
				box(ctx, "HotelBalconyRail", 441, 457, y + 0.5, y + 3.5, 849.4, 849.9, C.TRIM, M.SMOOTH)
			end
		end
		-- West wing windows (two storeys, 2 each) and side windows on the east block's east face.
		for f = 1, 2 do
			for _, x in ipairs({ 366, 372 }) do
				glass(box(ctx, "HotelWindow", x - 1.6, x + 1.6, LEVELS[f] + 2, LEVELS[f] + 7, 857.4, 858.1, C.GLASS, M.GLASS))
			end
		end
		for f = 1, 5 do
			for _, z in ipairs({ 858, 870 }) do
				glass(box(ctx, "HotelSideWindow", 457.9, 458.6, LEVELS[f] + 2, LEVELS[f] + 7, z - 2, z + 2, C.GLASS, M.GLASS))
			end
		end
		-- Ridge caps.
		box(ctx, "HotelRidge", 389, 427, LEVELS[5] + 7.6, LEVELS[5] + 8.4, 864.6, 865.4, C.TERRA_CAP, M.TILE)

		-- Pool terrace in front of the hotel: a raised deck (top y 9.0, solid to the ground), the pool, coping, loungers and umbrellas.
		local dmin = env.gnd(382, 838)
		box(ctx, "HotelPoolDeck", 382, 434, dmin - 1, 9.0, 828, 849, C.COPING, M.LIME)
		local w1 = box(ctx, "HotelPoolWater", 388, 420, 8.4, 9.2, 832, 844, C.AQUA, M.GLASS)
		local w2 = box(ctx, "HotelPoolWater", 418, 429, 8.4, 9.2, 836, 846, C.AQUA, M.GLASS)
		for _, w in ipairs({ w1, w2 }) do
			w.Transparency = 0.3
			w.CanCollide = false
		end
		for _, c in ipairs({ { 387, 421, 831, 832 }, { 387, 388, 831, 845 }, { 387, 418, 844, 845 }, { 418, 430, 846, 847 }, { 429, 430, 835, 847 }, { 420, 430, 835, 836 } }) do
			box(ctx, "HotelPoolCoping", c[1], c[2], 9.0, 9.5, c[3], c[4], C.TRIM, M.SMOOTH)
		end
		for _, x in ipairs({ 392, 398, 404, 410 }) do
			box(ctx, "Lounger", x, x + 2.2, 9.0, 9.6, 828.6, 830.6, C.CART_T, M.SMOOTH)
		end
		for _, p in ipairs({ { 395, 848 }, { 425, 830 } }) do
			vcyl(ctx, "UmbrellaPole", p[1], p[2], 9.0, 16, 0.4, C.WHITE, M.SMOOTH)
			vcyl(ctx, "UmbrellaCanopy", p[1], p[2], 15.4, 16, 6, C.TRIM, M.SMOOTH)
		end
	end)

	-- Hip roofs: the long wing, the taller east block, the low west wing.
	env.roof("Hotel", hotel, env.ID, CF(408, LEVELS[5], 865), 68, 22, 8.4)
	env.roof("Hotel", hotel, env.ID, CF(449, LEVELS[6], 864.5), 22, 29, 8)
	env.roof("Hotel", hotel, env.ID, CF(369, LEVELS[3], 865), 17, 17, 5)
end
