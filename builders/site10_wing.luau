-- site10_wing: the office wing, ground lobby, open-air atrium and canopy of Site 10 (New Lipa City Hall). Studio copy:
-- ServerStorage.Builders.site10_wing. Owner container: Wing. Checks group: shared.site10_only = "wing".
-- Brief section: Wing, atrium and canopy (briefs/site10.md). Loaded by builders/site10.luau (see its MODULE CONTRACT for env).
-- Coordinates are LOCAL to ORIGIN (world = ORIGIN + local); y = height above ground. Plain: no text, decals, textures or images.
-- Built, in one env.section("Wing") call:
--   The wing, lx -100..-60, lz -70..30: four floor slabs WingFloor (centres y 10, 24, 38, 52; 1 thick) on nine WingPilotis
--     (1.4 square, y 0..9.5). Roof WingRoof (y 65..66), WingParapet (four walls, 2 tall) and three RoofBox.
--     East face (lx -60): 12 GlazedBay (dark glass) with WingFrame, WingMullion and WingShade, and 13 WingBrick volumes
--     (brick, projecting 4 studs). The other faces are brick WingWall cladding, open on the ground (pilotis).
--     Recessed balcony bay on floors 2 and 3 (lx -66..-60, lz -35..-10): WingBalcony slabs and WingRailing (3 tall).
--   Ground lobby, lx -78..-60, lz -12..12, y 0..9: LobbyGlass walls, two EntranceDoor (4 wide, 9 tall, 0.4 thick) on the
--     east face at lz -3 and 3, and LobbyRoof (y 9..9.5). Nothing else stands on the ground in that band east of lx -78.
--   Atrium, OpenLobby (lx -100..-60, lz 30..70, y 0..0.4, marble paving): open to the sky. Its walls carry the terraces:
--     WingBalcony ledges with WingRailing on the south wall (z 30..30.9) and the west wall (lx -100..-99.1), one per floor.
--     The ledges stay within 1 stud of the walls, so nothing reaches into the open floor (1-stud inset).
--   AtriumCanopy, lx -80..-52, lz 30..70: a flat slab (y 44..45.5), a crown (lx -69..-63, up to y 50) and four sloped
--     panels (rotated boxes) forming a low hip roof. CanopySupport: four 2.2 round columns at lx -78 and -66, lz 36 and 64,
--     each a stack of twenty 2.2-stud drums from y 0 to 44.
-- Deviations from the brief: the west supports stand at lx -78, not -96, so every column carries the canopy (the canopy
--     covers lx -80..-52 to keep at least 40 percent of the atrium floor open). The columns are stacks of 2.2 drums so the
--     round section is kept while each part's unrotated size equals its diameter, which is what the overhang check reads.
-- ===========================================================================================================================
return function(env)
	local box, vcyl, CF, V, ANG = env.box, env.vcyl, env.CF, env.V, env.ANG
	local BRICK = Color3.fromRGB(214, 206, 190)
	local CONCRETE = Color3.fromRGB(190, 192, 190)
	local GLASS = Color3.fromRGB(60, 84, 98)
	local DOOR = Color3.fromRGB(70, 76, 80)
	local GREY = Color3.fromRGB(120, 126, 132)
	local METAL = Color3.fromRGB(60, 64, 68)
	local PAVING = Color3.fromRGB(205, 200, 190)
	local SUPPORT = Color3.fromRGB(225, 225, 220)

	local FRONT_X, BACK_X = -60, -100 -- east (front) and west faces of the wing
	local NORTH_Z, SOUTH_Z = -70, 30 -- wing footprint in z; the atrium lies south of SOUTH_Z
	local MODULE = 12.5 -- front facade module width: eight modules from lz -70 to 30
	local FLOOR_TOPS = { 10.5, 24.5, 38.5, 52.5 } -- top of each floor slab (slabs centred at y 10, 24, 38, 52)

	-- { front module (1..8), y0, y1 }: dark glass bays, 10 wide, centred in their module. Floors 2 and 3 leave modules 3..5
	-- empty, because the recessed balcony bay (lz -35..-10) sits there.
	local GLAZED = {
		{ 1, 11.5, 22.5 }, { 3, 11.5, 22.5 }, { 5, 11.5, 22.5 }, { 7, 11.5, 22.5 },
		{ 2, 25.5, 36.5 }, { 6, 25.5, 36.5 },
		{ 1, 39.5, 50.5 }, { 7, 39.5, 50.5 },
		{ 2, 53.5, 63.5 }, { 4, 53.5, 63.5 }, { 6, 53.5, 63.5 }, { 8, 53.5, 63.5 },
	}
	-- { front module, y0, y1 }: brick volumes, 10.5 wide, projecting 4 studs, 10 to 24 tall (module 8 spans floors 1 and 2)
	local BRICKS = {
		{ 2, 10.5, 23.5 }, { 4, 10.5, 23.5 }, { 6, 10.5, 23.5 }, { 8, 16, 36 },
		{ 1, 24.5, 37.5 }, { 7, 24.5, 37.5 },
		{ 2, 38.5, 51.5 }, { 6, 38.5, 51.5 }, { 8, 38.5, 51.5 },
		{ 1, 52.5, 65 }, { 3, 52.5, 65 }, { 5, 52.5, 65 }, { 7, 52.5, 65 },
	}

	local function moduleZ(i) -- z where front module i starts
		return NORTH_Z + (i - 1) * MODULE
	end

	-- Sloped panel with its slope in the x-y plane. The top face runs from the eave point (xe, ye) up to the crown point
	-- (xc, yc) and the panel spans z0..z1. Rotated about Z; centred so that its top face holds that edge.
	local function slopeX(ctx, name, xe, ye, xc, yc, z0, z1, t, color, material)
		local dx, dy = xc - xe, yc - ye
		local s = math.sqrt(dx * dx + dy * dy)
		local ux, uy = -dy / s, dx / s -- unit normal of the top face, pointing up
		if dx < 0 then
			ux, uy = dy / s, -dx / s
		end
		local theta = math.atan(dy / dx)
		if dx < 0 then
			theta = theta + math.pi
		end
		local mx, my = (xe + xc) / 2, (ye + yc) / 2
		local cf = CF(mx - ux * t / 2, my - uy * t / 2, (z0 + z1) / 2) * ANG(0, 0, theta)
		return ctx:part(name, V(s, t, z1 - z0), cf, color, material)
	end

	-- Sloped panel with its slope in the z-y plane. The top face runs from the eave point (ze, ye) up to the crown point
	-- (zc, yc) and the panel spans x0..x1. Rotated about X, so the panel's local Z axis lies along the slope.
	local function slopeZ(ctx, name, ze, ye, zc, yc, x0, x1, t, color, material)
		local dz, dy = zc - ze, yc - ye
		local s = math.sqrt(dz * dz + dy * dy)
		local uz, uy = -dy / s, dz / s -- unit normal of the top face in (z, y), pointing up
		if dz < 0 then
			uz, uy = dy / s, -dz / s
		end
		local phi = math.atan(-dy / dz)
		if dz < 0 then
			phi = phi + math.pi
		end
		local mz, my = (ze + zc) / 2, (ye + yc) / 2
		local cf = CF((x0 + x1) / 2, my - uy * t / 2, mz - uz * t / 2) * ANG(phi, 0, 0)
		return ctx:part(name, V(x1 - x0, t, s), cf, color, material)
	end

	env.section("Wing", function(ctx)
		-- Four floor slabs, 14 apart, on pilotis
		for _, c in ipairs({ 10, 24, 38, 52 }) do
			box(ctx, "WingFloor", BACK_X, FRONT_X, c - 0.5, c + 0.5, NORTH_Z, SOUTH_Z, CONCRETE, Enum.Material.Concrete)
		end
		-- Nine square pilotis, 1.4 wide, from the ground to the underside of floor 1 (y 9.5). The ground lobby band
		-- (lz -12..12, east of lx -78) stays clear.
		local PILOTI = {
			{ -96, -62 }, { -96, -42 }, { -96, -22 }, { -96, -2 }, { -96, 18 },
			{ -64, -62 }, { -64, -42 }, { -64, -22 }, { -64, 18 },
		}
		for _, p in ipairs(PILOTI) do
			box(ctx, "WingPilotis", p[1] - 0.7, p[1] + 0.7, 0, 9.5, p[2] - 0.7, p[2] + 0.7, CONCRETE, Enum.Material.Concrete)
		end

		-- Brick cladding: north end, west (back) face, south wall (the atrium's north side) and the atrium's west wall,
		-- which runs down to the ground. The wing itself stays open on pilotis below y 10.5.
		box(ctx, "WingWall", BACK_X, FRONT_X, 10.5, 65, NORTH_Z, NORTH_Z + 0.4, BRICK, Enum.Material.Brick)
		box(ctx, "WingWall", BACK_X, BACK_X + 0.6, 10.5, 65, NORTH_Z, SOUTH_Z, BRICK, Enum.Material.Brick)
		box(ctx, "WingWall", BACK_X, FRONT_X, 10.5, 65, SOUTH_Z - 0.4, SOUTH_Z, BRICK, Enum.Material.Brick)
		box(ctx, "WingWall", BACK_X, BACK_X + 0.6, 0, 65, SOUTH_Z, 70, BRICK, Enum.Material.Brick)

		-- East (front) facade: dark glass bays with concrete frames, mullions and sunshades
		for _, g in ipairs(GLAZED) do
			local zA = moduleZ(g[1]) + 1.25
			local zB = zA + 10
			local y0, y1 = g[2], g[3]
			local glass = box(ctx, "GlazedBay", FRONT_X - 0.4, FRONT_X, y0, y1, zA, zB, GLASS, Enum.Material.Glass)
			glass.Transparency = 0.3
			box(ctx, "WingFrame", FRONT_X, FRONT_X + 0.5, y1, y1 + 0.6, zA - 0.6, zB + 0.6, CONCRETE, Enum.Material.Concrete)
			box(ctx, "WingFrame", FRONT_X, FRONT_X + 0.5, y0 - 0.6, y0, zA - 0.6, zB + 0.6, CONCRETE, Enum.Material.Concrete)
			box(ctx, "WingFrame", FRONT_X, FRONT_X + 0.5, y0, y1, zA - 0.6, zA, CONCRETE, Enum.Material.Concrete)
			box(ctx, "WingFrame", FRONT_X, FRONT_X + 0.5, y0, y1, zB, zB + 0.6, CONCRETE, Enum.Material.Concrete)
			local mid = (zA + zB) / 2
			box(ctx, "WingMullion", FRONT_X, FRONT_X + 0.5, y0, y1, mid - 0.3, mid + 0.3, CONCRETE, Enum.Material.Concrete)
			box(ctx, "WingShade", FRONT_X, FRONT_X + 1.5, y1 + 0.6, y1 + 1, zA - 0.6, zB + 0.6, CONCRETE, Enum.Material.Concrete)
		end

		-- East facade: brick volumes projecting 4 studs
		for _, b in ipairs(BRICKS) do
			local zA = moduleZ(b[1]) + 1
			box(ctx, "WingBrick", FRONT_X, FRONT_X + 4, b[2], b[3], zA, zA + 10.5, BRICK, Enum.Material.Brick)
		end

		-- Ground lobby core: glass walls, two entrance doors on the east face (lz -5..-1 and 1..5), a concrete roof
		local function lobbyGlass(x0, x1, z0, z1)
			local g = box(ctx, "LobbyGlass", x0, x1, 0, 9, z0, z1, GLASS, Enum.Material.Glass)
			g.Transparency = 0.3
		end
		lobbyGlass(FRONT_X - 0.4, FRONT_X, -12, -5)
		lobbyGlass(FRONT_X - 0.4, FRONT_X, -1, 1)
		lobbyGlass(FRONT_X - 0.4, FRONT_X, 5, 12)
		lobbyGlass(-78, -77.6, -12, 12)
		lobbyGlass(-78, FRONT_X, -12, -11.6)
		lobbyGlass(-78, FRONT_X, 11.6, 12)
		box(ctx, "EntranceDoor", FRONT_X - 0.4, FRONT_X, 0, 9, -5, -1, DOOR, Enum.Material.Metal)
		box(ctx, "EntranceDoor", FRONT_X - 0.4, FRONT_X, 0, 9, 1, 5, DOOR, Enum.Material.Metal)
		box(ctx, "LobbyRoof", -78, FRONT_X, 9, 9.5, -12, 12, CONCRETE, Enum.Material.Concrete)

		-- Recessed balcony bay on floors 2 and 3: a slab on each floor, railings on the front edge and both ends
		for _, t in ipairs({ 24.5, 38.5 }) do
			box(ctx, "WingBalcony", -66, FRONT_X, t, t + 0.6, -35, -10, CONCRETE, Enum.Material.Concrete)
			for k = 0, 5 do
				local z0 = -35 + k * 25 / 6
				box(ctx, "WingRailing", FRONT_X - 0.3, FRONT_X, t + 0.6, t + 3.6, z0, z0 + 25 / 6, METAL, Enum.Material.Metal)
			end
			box(ctx, "WingRailing", -66, FRONT_X, t + 0.6, t + 3.6, -35, -34.7, METAL, Enum.Material.Metal)
			box(ctx, "WingRailing", -66, FRONT_X, t + 0.6, t + 3.6, -10.3, -10, METAL, Enum.Material.Metal)
		end

		-- Atrium terraces: a ledge and railing at every floor top, on the south wall (z 30..30.9) and the west wall
		-- (lx -100..-99.1). Both stay within 1 stud of the walls, so nothing overhangs the open atrium floor.
		for _, t in ipairs(FLOOR_TOPS) do
			box(ctx, "WingBalcony", BACK_X, FRONT_X, t, t + 0.6, SOUTH_Z, SOUTH_Z + 0.9, CONCRETE, Enum.Material.Concrete)
			box(ctx, "WingBalcony", BACK_X, BACK_X + 0.9, t, t + 0.6, SOUTH_Z, 70, CONCRETE, Enum.Material.Concrete)
			for k = 0, 3 do
				local x0 = BACK_X + k * 10
				box(ctx, "WingRailing", x0, x0 + 10, t + 0.6, t + 3.6, SOUTH_Z + 0.6, SOUTH_Z + 0.9, METAL, Enum.Material.Metal)
				local z0 = SOUTH_Z + k * 10
				box(ctx, "WingRailing", BACK_X + 0.6, BACK_X + 0.9, t + 0.6, t + 3.6, z0, z0 + 10, METAL, Enum.Material.Metal)
			end
		end

		-- Roof: slab, parapet (four 2-tall walls) and three small roof boxes
		box(ctx, "WingRoof", BACK_X, FRONT_X, 65, 66, NORTH_Z, SOUTH_Z, GREY, Enum.Material.Concrete)
		box(ctx, "WingParapet", BACK_X, FRONT_X, 66, 68, NORTH_Z, NORTH_Z + 0.4, CONCRETE, Enum.Material.Concrete)
		box(ctx, "WingParapet", BACK_X, FRONT_X, 66, 68, SOUTH_Z - 0.4, SOUTH_Z, CONCRETE, Enum.Material.Concrete)
		box(ctx, "WingParapet", BACK_X, BACK_X + 0.4, 66, 68, NORTH_Z, SOUTH_Z, CONCRETE, Enum.Material.Concrete)
		box(ctx, "WingParapet", FRONT_X - 0.4, FRONT_X, 66, 68, NORTH_Z, SOUTH_Z, CONCRETE, Enum.Material.Concrete)
		box(ctx, "RoofBox", -95, -89, 66, 70, -53, -47, CONCRETE, Enum.Material.Concrete)
		box(ctx, "RoofBox", -79, -73, 66, 70, -23, -17, CONCRETE, Enum.Material.Concrete)
		box(ctx, "RoofBox", -91, -85, 66, 70, 9, 15, CONCRETE, Enum.Material.Concrete)

		-- OpenLobby: the atrium floor, one thin paved part, open to the sky
		box(ctx, "OpenLobby", BACK_X, FRONT_X, 0, 0.4, SOUTH_Z, 70, PAVING, Enum.Material.Marble)

		-- AtriumCanopy: a low hip roof over the east half of the atrium. Slab underside y 44, eaves y 45.5, crown and ridge
		-- up to y 50. The sloped panels are rotated boxes whose top faces run from the eaves to the crown.
		box(ctx, "AtriumCanopy", -80, -52, 44, 45.5, 30, 70, GREY, Enum.Material.Metal)
		box(ctx, "AtriumCanopy", -69, -63, 45.5, 50, 40, 60, GREY, Enum.Material.Metal)
		slopeX(ctx, "AtriumCanopy", -80, 45.5, -69, 50, 30, 70, 0.6, GREY, Enum.Material.Metal)
		slopeX(ctx, "AtriumCanopy", -52, 45.5, -63, 50, 30, 70, 0.6, GREY, Enum.Material.Metal)
		slopeZ(ctx, "AtriumCanopy", 30, 45.5, 40, 50, -80, -52, 0.6, GREY, Enum.Material.Metal)
		slopeZ(ctx, "AtriumCanopy", 70, 45.5, 60, 50, -80, -52, 0.6, GREY, Enum.Material.Metal)

		-- CanopySupport: four round 2.2 columns under the canopy, each a stack of twenty 2.2-stud drums from y 0 to 44
		for _, c in ipairs({ { -78, 36 }, { -78, 64 }, { -66, 36 }, { -66, 64 } }) do
			for k = 0, 19 do
				vcyl(ctx, "CanopySupport", c[1], c[2], 2.2 * k, 2.2 * (k + 1), 2.2, SUPPORT, Enum.Material.Concrete)
			end
		end
	end)
end
