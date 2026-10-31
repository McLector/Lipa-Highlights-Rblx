-- site06_retail: the ~20 low-rise outlet blocks of "The Outlets at Lima Estate Blueprint.png" (main retail clusters round the central
-- promenade): white render, orange timber-look volumes, dark glass storefronts, brown awnings, terracotta roof rims, solar panel strips.
-- Module of builders/site06.luau (see its MODULE CONTRACT). Containers: Structure/RetailWest, Structure/RetailCentre, Structure/RetailEast.
-- Local frame: +X east, +Z south, origin (550, 0, -700). Positions come from the board's site-plan inset at 1.05 studs/m; the blocks keep
-- clear of the arrival plaza round the kept Guide / JeepStop / Jeepney (x -64..4, z 30..100), the promenade spine (x -52..-18), the oval
-- (x -49..-19, z -64..-16), the entry walk (x -112..-104 and z 100..108), the ring road and the parking courts.
-- One block is the identified one (look-at line): ShopBlock, the white ShopBody in an orange timber frame with dark glass, the brown
-- ShopCanopy between the floors and the covered walkway (WalkwayRoof) in front of it. ShopBody and WalkwayRoof are unique names.
return function(env)
	local V, CF, ANG, PI, C, M = env.V, env.CF, env.ANG, env.PI, env.C, env.M
	local box, obox, vcyl = env.box, env.obox, env.vcyl
	local rad = math.rad

	-- { name, container, cx, cz, w (x extent before yaw), d (z extent), yaw (deg), h, front side, timber end ("L"/"R"/nil), noAwning }
	-- "L"/"R" are as seen facing the storefront from outside. Blocks with a covered walkway along their front get no awning.
	local BLOCKS = {
		{ "NorthWest", "Structure/RetailWest", -145, -52, 56, 36, 15, 16, "S", "R" },
		{ "GardenKiosk", "Structure/RetailWest", -118, -92, 14, 10, 0, 12, "S", nil },
		{ "OvalWestA", "Structure/RetailWest", -84, -50, 14, 44, 20, 14, "E", "L" },
		{ "MidWest", "Structure/RetailWest", -88, -2, 14, 30, 30, 14, "E", "R" },
		{ "WestBig", "Structure/RetailWest", -140, 28, 50, 34, 20, 16, "S", "L" },
		{ "SouthWestA", "Structure/RetailWest", -145, 78, 34, 30, 10, 14, "E", "R" },
		{ "SouthRowA", "Structure/RetailWest", -146, 118, 28, 18, 0, 13, "S", "L" },
		{ "NorthRow", "Structure/RetailCentre", -22, -97, 76, 12, 0, 13, "S", "R" },
		{ "NorthSmall", "Structure/RetailCentre", -54, -80, 14, 12, 0, 12, "E", nil },
		{ "OvalWestB", "Structure/RetailCentre", -58, -38, 12, 36, 0, 14, "E", "L" },
		{ "OvalEast", "Structure/RetailCentre", -8, -45, 11, 30, 0, 14, "W", "R" },
		{ "SpineWest", "Structure/RetailCentre", -62, 12, 16, 26, 0, 14, "E", "R", true },
		{ "CentralBig", "Structure/RetailCentre", -88, 62, 34, 56, 0, 16, "E", "L", true },
		{ "SouthRowB", "Structure/RetailCentre", -58, 121, 30, 18, 0, 13, "N", nil, true },
		{ "SouthRowC", "Structure/RetailCentre", -22, 121, 30, 18, 0, 13, "N", nil, true },
		{ "EastRowNorth", "Structure/RetailEast", 11, -62, 18, 52, 0, 16, "W", "L" },
		{ "EastRowSouth", "Structure/RetailEast", 13, -16, 20, 30, 0, 15, "W", "R" },
		{ "SpineEast", "Structure/RetailEast", -8, 13, 20, 24, 0, 14, "W", "L", true },
		{ "SouthEastL", "Structure/RetailEast", 20, 88, 32, 28, 0, 15, "N", "R" },
		-- tidy round (owner, 2026-10-31): bars that chain the clusters as on the board's site-plan inset (2..4 studs from their neighbours)
		{ "WestMidBar", "Structure/RetailWest", -146.5, -6.5, 37, 15, 0, 14, "S", "L" },
		{ "WestNorthBar", "Structure/RetailWest", -105.5, -50, 10, 40, 0, 13, "S", nil, true },
		{ "WestBar", "Structure/RetailWest", -115, 75.5, 14, 35, 0, 14, "S", nil, true },
		{ "CentralNorth", "Structure/RetailCentre", -86, 25, 28, 14, 0, 14, "W", "L" },
		{ "OvalNorth", "Structure/RetailCentre", -30, -79, 28, 14, 0, 13, "S", "R" },
		{ "SpineWestN", "Structure/RetailCentre", -61, -10.5, 14, 13, 0, 13, "E", nil, true },
		{ "SpineEastN", "Structure/RetailEast", -8, -14, 16, 26, 0, 14, "W", "L" },
		{ "EastBar", "Structure/RetailEast", 36.5, 63, 13, 18, 0, 14, "W", "R" },
	}

	local GREY = Color3.fromRGB(150, 152, 156)

	local function glass(ctx, name, cf, size)
		local p = obox(ctx, name, cf, size, C.GLASS, M.GLASS)
		p.Transparency = 0.25
		p.Reflectance = 0.05
		return p
	end

	-- One block. Fb = body frame (yawed); Ff = facade frame: the storefront lies on z = 0, outward +Z, along x in [-L/2, L/2], the body
	-- behind it in z [-D, 0].
	local function block(ctx, def)
		local _, _, cx, cz, w, d, yaw, h, front, timber, noAwning = table.unpack(def)
		local Fb = CF(cx, 0, cz) * ANG(0, rad(yaw), 0)
		local Ff, L, D
		if front == "S" then
			Ff, L, D = Fb * CF(0, 0, d / 2), w, d
		elseif front == "N" then
			Ff, L, D = Fb * CF(0, 0, -d / 2) * ANG(0, PI, 0), w, d
		elseif front == "E" then
			Ff, L, D = Fb * CF(w / 2, 0, 0) * ANG(0, PI / 2, 0), d, w
		else
			Ff, L, D = Fb * CF(-w / 2, 0, 0) * ANG(0, -PI / 2, 0), d, w
		end
		obox(ctx, "RetailBody", Fb * CF(0, h / 2, 0), V(w, h, d), C.WHITE, M.CONC)
		-- terracotta roof rims on the front and back edges
		obox(ctx, "RoofFascia", Ff * CF(0, h - 0.7, 0.3), V(L + 0.6, 1.4, 0.6), C.TERRA, M.PLAS)
		obox(ctx, "RoofFascia", Ff * CF(0, h - 0.7, -D - 0.3), V(L + 0.6, 1.4, 0.6), C.TERRA, M.PLAS)
		for _, sx in ipairs({ -1, 1 }) do
			obox(ctx, "RoofFascia", Ff * CF(sx * (L / 2 + 0.3), h - 0.7, -D / 2), V(0.6, 1.4, D), C.TERRA, M.PLAS)
		end
		obox(ctx, "RoofDeck", Ff * CF(0, h + 0.05, -D / 2), V(L - 1.2, 0.1, D - 1.2), Color3.fromRGB(204, 204, 200), M.CONC)
		if L >= 24 then
			obox(ctx, "BackGlass", Ff * CF(L / 4, 6, -D - 0.15), V(math.min(L * 0.3, 10), 5, 0.3), C.GLASS, M.GLASS)
		end

		-- storefront span, leaving the timber end free
		local tw = math.clamp(L * 0.28, 7, 14)
		local x0, x1 = -L / 2 + 1.5, L / 2 - 1.5
		if timber == "L" then x0 = -L / 2 + tw + 0.5 elseif timber == "R" then x1 = L / 2 - tw - 0.5 end
		local gw, gx = x1 - x0, (x0 + x1) / 2
		glass(ctx, "StoreGlass", Ff * CF(gx, 4.9, 0.15), V(gw, 9, 0.3))
		local n = math.clamp(math.floor(gw / 6), 1, 6)
		for i = 1, n - 1 do
			obox(ctx, "Mullion", Ff * CF(x0 + i * gw / n, 4.9, 0.3), V(0.4, 9, 0.5), C.DARK, M.METAL)
		end
		obox(ctx, "StoreDoor", Ff * CF(gx, 4.8, 0.45), V(4, 8.8, 0.4), C.DARK, M.PLAS)
		if gw > 24 then
			obox(ctx, "StoreDoor", Ff * CF(gx + gw / 3, 4.8, 0.45), V(4, 8.8, 0.4), C.DARK, M.PLAS)
		end
		obox(ctx, "SignBand", Ff * CF(gx, 9.95, 0.2), V(gw, 0.9, 0.4), C.DARK, M.PLAS)
		for _, sx in ipairs({ -1, 1 }) do
			if not ((timber == "L" and sx == -1) or (timber == "R" and sx == 1)) then
				obox(ctx, "Pilaster", Ff * CF(sx * (L / 2 - 0.6), h / 2, 0.4), V(1.2, h, 0.8), C.OFFWHITE, M.CONC)
			end
		end
		if not noAwning then
			obox(ctx, "Awning", Ff * CF(gx, 10.6, 2), V(gw + 1, 0.5, 4), C.BROWN, M.PLAS)
		end
		if h >= 16 then
			glass(ctx, "UpperGlass", Ff * CF(gx, 12.8, 0.15), V(gw, 2.4, 0.3))
		end
		-- side glazing at the corner away from the timber end
		local sideX = (timber == "L") and (L / 2 + 0.15) or (-L / 2 - 0.15)
		glass(ctx, "SideGlass", Ff * CF(sideX, 4.9, -math.min(D * 0.2, 5) - 1), V(0.3, 9, math.min(D * 0.4, 10)))

		-- the orange timber-look volume: taller than the body, standing 2.5 proud of the storefront, ribs above a tall glass slot
		if timber then
			local sx = (timber == "L") and -1 or 1
			local tx = sx * (L / 2 - tw / 2)
			obox(ctx, "TimberVolume", Ff * CF(tx, (h + 3) / 2, -2), V(tw, h + 3, 9), C.ORANGE, M.WOOD)
			local ribH = h + 3 - 10.4
			for i = 1, 3 do
				obox(ctx, "TimberRib", Ff * CF(tx + (i - 2) * tw / 4, 10.4 + ribH / 2, 2.6), V(0.5, ribH, 0.2), C.ORANGE2, M.WOOD)
			end
			glass(ctx, "StoreGlass", Ff * CF(tx, 4.9, 2.6), V(tw - 3, 9, 0.2))
		end

		-- solar panel strips over the roof (rows parallel to the storefront, split in two where the roof is wide)
		local sx0, sx1 = -L / 2 + 2, L / 2 - 2
		if timber == "L" then sx0 = -L / 2 + tw + 1 elseif timber == "R" then sx1 = L / 2 - tw - 1 end
		local rows = math.clamp(math.floor((D - 5) / 4.4), 1, 6)
		local span = sx1 - sx0
		local halves = (span > 34) and 3 or ((span > 16) and 2 or 1)
		for k = 0, rows - 1 do
			local z = -2.8 - 4.4 * k
			for hh = 1, halves do
				local len = span / halves - 0.6
				local x = sx0 + (hh - 0.5) * span / halves
				obox(ctx, "SolarStrip", Ff * CF(x, h + 0.55, z) * ANG(0.2, 0, 0), V(len, 0.3, 3.4), C.SOLAR, M.GLASS)
			end
		end
		obox(ctx, "RoofUnit", Ff * CF((timber == "R") and (-L / 2 + 3) or (L / 2 - 3), h + 0.8, -D + 2.5), V(3, 1.6, 3), GREY, M.METAL)
		obox(ctx, "ServiceDoor", Ff * CF(0, 4.4, -D - 0.15), V(4, 8.8, 0.3), C.DARK, M.PLAS)
	end

	-- The identified block, world-aligned: x 5..35, z 7..37, two storeys (20), storefront facing south onto the walkway.
	local function shopBlock(ctx)
		local cx, fz = 20, 37
		box(ctx, "ShopBody", 5, 35, 0, 20, 7, 37, C.WHITE, M.CONC)
		for _, sx in ipairs({ -1, 1 }) do
			local lx = cx + sx * 13.5
			box(ctx, "TimberLeg", lx - 1.5, lx + 1.5, 0, 21, fz - 1, fz + 3, C.ORANGE, M.WOOD)
		end
		box(ctx, "TimberBand", 5, 35, 17, 22, fz - 1, fz + 4.5, C.ORANGE, M.WOOD)
		for i = 0, 7 do
			local x = 7.6 + i * 3.6
			box(ctx, "TimberPlank", x - 0.25, x + 0.25, 17.2, 21.8, fz + 4.5, fz + 4.7, C.ORANGE2, M.WOOD)
		end
		box(ctx, "TimberSoffit", 8, 32, 16.7, 17, fz - 1, fz + 4.5, C.SOFFIT, M.WOOD)
		for _, x in ipairs({ 11, 17, 23, 29 }) do
			ctx:ball("Downlight", 0.6, CF(x, 16.6, fz + 2), C.BULB, M.NEON)
		end
		for _, x in ipairs({ 12, 20, 28 }) do
			for _, yy in ipairs({ { 0.4, 9.4 }, { 11.4, 16.4 } }) do
				local p = box(ctx, "ShopGlass", x - 3.8, x + 3.8, yy[1], yy[2], fz, fz + 0.3, C.GLASS, M.GLASS)
				p.Transparency = 0.25
				p.Reflectance = 0.05
			end
		end
		for _, x in ipairs({ 16, 24 }) do
			box(ctx, "Mullion", x - 0.2, x + 0.2, 0.4, 16.4, fz, fz + 0.5, C.DARK, M.METAL)
		end
		box(ctx, "Transom", 8, 32, 9.4, 10.3, fz, fz + 0.4, C.DARK, M.METAL)
		box(ctx, "StoreDoor", 18, 22, 0.4, 9.2, fz + 0.3, fz + 0.6, C.DARK, M.PLAS)
		box(ctx, "ShopCanopy", 8, 32, 10.3, 10.9, fz, fz + 5, C.BROWN, M.PLAS)
		-- the covered walkway in front of the block (shoppers stand under it, builders/npcs.luau [6])
		box(ctx, "WalkwayRoof", 2, 38, 11.6, 12.2, fz + 4, fz + 13, C.BROWN, M.PLAS)
		for _, x in ipairs({ 5, 12, 20, 28, 36 }) do
			vcyl(ctx, "WalkwayPost", x, fz + 12.5, 0, 11.6, 0.5, C.STEEL, M.METAL)
		end
		for k = 0, 5 do
			obox(ctx, "SolarStrip", CF(20, 20.55, 10 + 4.4 * k) * ANG(0.2, 0, 0), V(26, 0.3, 3.4), C.SOLAR, M.GLASS)
		end
		box(ctx, "RoofFascia", 4.4, 35.6, 18.6, 20, 6.4, 7, C.TERRA, M.PLAS)
		box(ctx, "RoofFascia", 35, 35.6, 18.6, 20, 7, 37, C.TERRA, M.PLAS)
		local sg = box(ctx, "SideGlass", 35, 35.3, 0.4, 9.4, 26, 34, C.GLASS, M.GLASS)
		sg.Transparency = 0.25
	end

	-- every block stands on the cluster deck (site06_promenade), so every section is lifted by DECK
	for _, def in ipairs(BLOCKS) do
		local holder = env.newFolder(def[2], def[1], "Model")
		env.section(def[2], function(ctx) block(ctx, def) end, holder, env.DECK)
	end
	local sb = env.newFolder("Structure/RetailEast", "ShopBlock", "Model")
	env.section("Structure/RetailEast", shopBlock, sb, env.DECK)
end
