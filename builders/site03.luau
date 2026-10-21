-- site03: Lomi King (Slice 07). Studio copy: ServerStorage.Builders.site03; run with
--   require(game.ServerStorage.Builders.site03:Clone())()
-- Needs Workspace.Sites.Site03_Lomi (created by the placeholder build, with Guide and InfoPanel).
-- IDEMPOTENT: replaces Block, Structure, Counter, Tables, LomiBowls, Menu, Utensils and Diners. Guide, InfoPanel and
-- anything else under the site are kept. Touches nothing outside Workspace.Sites.Site03_Lomi. No terrain change.
-- Brief: briefs/site03.md. FRAMES: the site pivot is yawed to W, so it is NOT used as the origin.
--   ORIGIN = CFrame.new(pivot position): world-aligned, +X east, +Z south.
--   LK     = ORIGIN * fromMatrix(0, (0,0,1), (0,1,0), (-1,0,0)): the Lomi frame. Local +Z = W (frontage, outward),
--            local +X = S. World = (180 - lz, y, 140 + lx).
--   The helpers below take WORLD coordinates and convert them, so every box stays axis-aligned in the world.
--   A SurfaceGui on the frontage side is on the part's local +Z face = Enum.NormalId.Back.
-- Fail-safe order as in site02: everything is built into unparented pieces first (budget counted); only then are the
-- old children deleted and the containers parented one at a time with task.wait(). An error before that point destroys
-- the partial build and leaves the placeholder Block untouched.
return function()
	local Players = game:GetService("Players")
	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
	local BuildKit = require(game.ServerStorage.BuildKit:Clone())

	local V, CF, ANG = Vector3.new, CFrame.new, CFrame.Angles
	local PI = math.pi
	local row = SiteData.byId(3)
	assert(row and row.facing == "W", "site03: SiteData row 3 is missing or not facing W")
	local sites = workspace:FindFirstChild("Sites")
	local site = sites and sites:FindFirstChild("Site03_Lomi")
	assert(site, "site03: Workspace.Sites.Site03_Lomi not found (run builders/placeholders first)")
	local pivotBefore = site:GetPivot()
	local ORIGIN = CF(pivotBefore.Position)
	local LK = ORIGIN * CFrame.fromMatrix(V(0, 0, 0), V(0, 0, 1), V(0, 1, 0), V(-1, 0, 0))
	-- The builder's world coordinates are the Slice 07 ones (centre (180, 140)); Slice 14 moved the site to (292, 140). L() below subtracts
	-- the ORIGINAL centre, so every part follows the pivot by itself; the rigs use absolute coordinates, so DX/DZ shifts them.
	local DX, DZ = pivotBefore.Position.X - 180, pivotBefore.Position.Z - 140

	local PART_BUDGET = 2500
	local REPLACED = {
		Block = true, Structure = true, Counter = true, Tables = true,
		LomiBowls = true, Menu = true, Utensils = true, Diners = true,
	}

	-- Colours (by eye from Lomi_King_Front_Oblique_2015.jpg; see briefs/site03.md).
	local PINK = Color3.fromRGB(242, 129, 108)
	local PINK_DARK = Color3.fromRGB(216, 104, 88)
	local STEEL_BLK = Color3.fromRGB(30, 32, 38)
	local BANNER2 = Color3.fromRGB(236, 150, 40)
	local SLAT = Color3.fromRGB(176, 146, 98)
	local ORANGE = Color3.fromRGB(226, 120, 30)
	local CREAM_GREY = Color3.fromRGB(200, 196, 184)
	local BLUE_GREY = Color3.fromRGB(110, 140, 170)
	local WHITE = Color3.fromRGB(240, 240, 236)
	local RED = Color3.fromRGB(200, 30, 40)
	local BANNER = Color3.fromRGB(240, 170, 50)
	local TAN = Color3.fromRGB(200, 170, 120)
	local GLASS_C = Color3.fromRGB(60, 76, 88)
	local DARKF = Color3.fromRGB(40, 42, 48)
	local ROOF = Color3.fromRGB(120, 116, 112)
	local WOOD_C = Color3.fromRGB(84, 56, 40)
	local CADDY = Color3.fromRGB(190, 190, 186)
	local SOY = Color3.fromRGB(70, 40, 24)
	local CHOP = Color3.fromRGB(214, 190, 140)
	local BOWL = Color3.fromRGB(240, 226, 190)
	local SOUP = Color3.fromRGB(160, 80, 30)
	local EGG = Color3.fromRGB(250, 200, 60)
	local STEEL = Color3.fromRGB(150, 154, 160)
	local TILE = Color3.fromRGB(170, 164, 150)
	local ASPHALT = Color3.fromRGB(80, 80, 84)
	local TERRA = Color3.fromRGB(190, 100, 60)
	local LEAF = Color3.fromRGB(60, 130, 50)
	local LAMP = Color3.fromRGB(255, 236, 190)
	local SMOOTH, WOODM, METAL = Enum.Material.SmoothPlastic, Enum.Material.Wood, Enum.Material.Metal
	local GLASS, NEON, CONC = Enum.Material.Glass, Enum.Material.Neon, Enum.Material.Concrete

	-- World -> Lomi-local CFrame (no rotation): lx = z - 140, ly = y, lz = 180 - x.
	local function L(x, y, z)
		return CF(z - 140, y, 180 - x)
	end
	-- Axis-aligned world box x0..x1, y0..y1, z0..z1.
	local function B(ctx, name, x0, x1, y0, y1, z0, z1, color, material)
		return ctx:part(name, V(z1 - z0, y1 - y0, x1 - x0), L((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), color, material)
	end
	-- Vertical cylinder (axis = world Y) from y0 to y1, centred on (x, z).
	local function VCyl(ctx, name, x, z, y0, y1, dia, color, material)
		return ctx:cyl(name, V(y1 - y0, dia, dia), L(x, (y0 + y1) / 2, z) * ANG(0, 0, PI / 2), color, material)
	end
	-- Cylinder with its axis along world X, from x0 to x1, at height y and depth z.
	local function XCyl(ctx, name, x0, x1, y, z, dia, color, material)
		return ctx:cyl(name, V(x1 - x0, dia, dia), L((x0 + x1) / 2, y, z) * ANG(0, -PI / 2, 0), color, material)
	end
	local function ball(ctx, name, x, y, z, dia, color, material)
		return ctx:ball(name, dia, L(x, y, z), color, material)
	end
	-- Text on the part's frontage (Back) face.
	local function gui(part, text, color, ppstud, fixedSize)
		local g = Instance.new("SurfaceGui")
		g.Face = Enum.NormalId.Back
		g.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		g.PixelsPerStud = ppstud or 30
		g.Parent = part
		local t = Instance.new("TextLabel")
		t.Size = UDim2.fromScale(0.94, 0.8)
		t.Position = UDim2.fromScale(0.03, 0.1)
		t.BackgroundTransparency = 1
		t.TextColor3 = color
		-- A long line must use a fixed TextSize: TextScaled renders tiny on a wide SurfaceGui (the Slice 17 name-band bug).
		t.TextScaled = fixedSize == nil
		if fixedSize then t.TextSize = fixedSize end
		t.TextWrapped = true
		t.Font = Enum.Font.GothamBlack
		t.Text = text
		t.Parent = g
	end

	local terrainParams = RaycastParams.new()
	terrainParams.FilterType = Enum.RaycastFilterType.Include
	terrainParams.FilterDescendantsInstances = { workspace.Terrain }
	local function groundAt(x, z)
		local r = workspace:Raycast(V(x, 400, z), V(0, -800, 0), terrainParams)
		return r and r.Position.Y or 0
	end

	local function countParts(inst)
		local n = inst:IsA("BasePart") and 1 or 0
		for _, d in ipairs(inst:GetDescendants()) do
			if d:IsA("BasePart") then n += 1 end
		end
		return n
	end

	-- Parts already in the site that survive the rebuild count against the 2,500 budget.
	local used = 0
	for _, c in ipairs(site:GetChildren()) do
		if not REPLACED[c.Name] then used += countParts(c) end
	end
	local keptParts = used

	-- One unparented piece built in the Lomi frame. Parts are counted against the budget as they are made.
	local function build(name, fn)
		local model = Instance.new("Model")
		model.Name = name
		local ctx = BuildKit.new(model, LK, { budget = PART_BUDGET - used })
		fn(ctx)
		ctx:flush()
		used += ctx:count()
		return model
	end

	------------------------------------------------------------------ Structure: floor, step, walls, awning, upper storeys
	local function buildStructure(ctx)
		-- Thin ground parts, all inside x 128..228, z 100..180.
		B(ctx, "FloorTile", 172, 216, 0, 0.2, 116, 150, TILE, SMOOTH)
		B(ctx, "FrontStep", 162.5, 172, 0, 1, 116, 150, TILE, SMOOTH)
		B(ctx, "DrivewayAsphalt", 172, 216, 0, 0.2, 168, 178, ASPHALT, CONC)
		B(ctx, "DrivewayLine", 178, 210, 0.2, 0.3, 172.5, 173, WHITE, SMOOTH)

		-- Ground storey: north wall, rear (east) wall, closed bay (south). The west side is open between z 116 and 150.
		B(ctx, "NorthWall", 172, 216, 0, 14, 114, 116, PINK, SMOOTH)
		B(ctx, "RearWall", 214, 216, 0, 14, 116, 150, PINK_DARK, SMOOTH)
		B(ctx, "ClosedBay", 172, 216, 0, 14, 150, 166, PINK, SMOOTH)
		-- Black steel frame of the open front (the banner hangs in it); the posts stay out of the aisle (z 138..142).
		for _, z in ipairs({ 115.6, 126, 150.4 }) do
			B(ctx, "SteelPost", 162.9, 163.6, 0, 12, z - 0.4, z + 0.4, STEEL_BLK, METAL)
		end
		B(ctx, "SteelRail", 162.9, 163.6, 11.4, 12, 115, 151, STEEL_BLK, METAL)

		-- Awning fascia across the open front, letter board on top, LOMI KING on the street face.
		B(ctx, "AwningFascia", 162.4, 172, 12, 16, 114, 166, ORANGE, SMOOTH)
		-- Eight free-standing letters on the awning top (cream-grey LOMI, blue-grey KING), reading north to south.
		for i = 1, 8 do
			local g = ("LOMIKING"):sub(i, i)
			local z0 = 122.45 + (i - 1) * 4.5
			local letter = B(ctx, "Letter_" .. i .. g, 165, 167.6, 16, 19, z0, z0 + 3.6, i <= 4 and CREAM_GREY or BLUE_GREY, SMOOTH)
			gui(letter, g, DARKF, 30, 50)
		end

		-- Upper storeys: one pink mass on top of the ground storey (hollow below y 14), flat parapet roof.
		B(ctx, "LomiBody", 172, 216, 14, 44, 114, 166, PINK, SMOOTH)
		B(ctx, "RoofSlab", 172, 216, 44, 45, 114, 166, ROOF, CONC)
		B(ctx, "FrontParapet", 172, 172.6, 44, 45.5, 114, 166, PINK, SMOOTH)
		for _, zr in ipairs({ { 116.5, 119.5 }, { 139.5, 148.5 }, { 151.5, 159.5 } }) do
			B(ctx, "WindowGlassA", 171.6, 171.95, 20, 26, zr[1], zr[2], GLASS_C, GLASS).Transparency = 0.25
		end
		for _, zr in ipairs({ { 116.5, 122.5 }, { 125.5, 134.5 }, { 146.5, 159.5 } }) do
			B(ctx, "WindowGlassB", 171.6, 171.95, 30, 36, zr[1], zr[2], GLASS_C, GLASS).Transparency = 0.25
		end
		-- Curved second-floor bay (about 18 wide, 4 deep, z 120..138): 7 dark glass panels between a sill and a head band, each panel
		-- a flat part yawed along the ellipse (local frame: lx = z - 140, lz = 180 - x).
		do
			local function bayPt(k)
				local th = -PI / 2 + k * PI / 7
				return 9 * math.sin(th) - 11, 8 + 4 * math.cos(th)
			end
			for k = 0, 6 do
				local ax, az = bayPt(k)
				local bx, bz = bayPt(k + 1)
				local len = math.sqrt((bx - ax) ^ 2 + (bz - az) ^ 2)
				local rot = ANG(0, math.atan2(-(bz - az), bx - ax), 0)
				local mx, mz = (ax + bx) / 2, (az + bz) / 2
				ctx:part("CurvedBayGlass" .. k, V(len + 0.2, 7.5, 0.5), CF(mx, 23.25, mz) * rot, GLASS_C, GLASS).Transparency = 0.25
				ctx:part("CurvedBaySill" .. k, V(len + 0.4, 1, 0.8), CF(mx, 19, mz) * rot, PINK, SMOOTH)
				ctx:part("CurvedBayHead" .. k, V(len + 0.4, 1, 0.8), CF(mx, 27.5, mz) * rot, PINK, SMOOTH)
			end
		end
		-- Iron grille over the southern upper window: 8 vertical bars and 2 rails.
		for k = 0, 7 do
			B(ctx, "GrilleBar" .. k, 171.3, 171.6, 29.8, 36.2, 147 + k * 1.65, 147.2 + k * 1.65, DARKF, METAL)
		end
		for _, y in ipairs({ 31.5, 34.5 }) do
			B(ctx, "GrilleBar", 171.3, 171.6, y, y + 0.2, 146.8, 158.8, DARKF, METAL)
		end
		-- Round red logo (white ring, red core, cream bowl) at the north corner on a steel bracket rising from the awning top.
		B(ctx, "LogoBracket", 167.9, 168.5, 16, 33, 118.1, 118.9, STEEL_BLK, METAL)
		B(ctx, "LogoArm", 167.9, 172, 32.4, 33, 118.1, 118.9, STEEL_BLK, METAL)
		XCyl(ctx, "LogoDisk", 166.9, 167.7, 29, 118.5, 9, RED, SMOOTH)
		XCyl(ctx, "LogoRing", 166.6, 166.9, 29, 118.5, 8, WHITE, SMOOTH)
		XCyl(ctx, "LogoCore", 166.4, 166.6, 29, 118.5, 6.4, RED, SMOOTH)
		XCyl(ctx, "LogoBowl", 166.1, 166.4, 29, 118.5, 3.6, CREAM_GREY, SMOOTH)

		-- Closed bay west face: bamboo screen and the parking sign on two posts.
		B(ctx, "BambooScreen", 171.5, 171.9, 2, 12, 152, 164, TAN, WOODM)
		for k = 0, 7 do
			B(ctx, "BambooSlat" .. k, 171.25, 171.5, 8.5, 12, 152.3 + k * 1.5, 152.3 + k * 1.5 + 1.2, SLAT, WOODM)
		end
		B(ctx, "BambooCap", 170.9, 172.6, 12, 12.6, 151.5, 164, ORANGE, SMOOTH)
		local sign = B(ctx, "ParkingSign", 170.8, 171.2, 1.5, 8.5, 152, 164, WHITE, SMOOTH)
		gui(sign, "PARKING FOR LOMI KING CUSTOMERS ONLY", RED, 30, 40)
		local poster = B(ctx, "RamenPoster", 171.0, 171.25, 8.7, 12, 160, 163.5, RED, SMOOTH)
		gui(poster, "LOMI KING RAMEN", WHITE, 30, 20)
		-- The darker pier on the south edge, ground to parapet.
		B(ctx, "CornerPier", 170, 172, 0, 44, 164, 166.6, PINK_DARK, SMOOTH)
		B(ctx, "SignPost", 170.85, 171.15, 0, 3, 153, 153.3, STEEL, METAL)
		B(ctx, "SignPost", 170.85, 171.15, 0, 3, 162.7, 163, STEEL, METAL)

		-- Terracotta pots with topiary on the step, outside the aisle.
		for _, z in ipairs({ 122, 147 }) do
			VCyl(ctx, "Pot", 166, z, 1, 3.4, 3.2, TERRA, SMOOTH)
			ball(ctx, "Topiary", 166, 5.9, z, 5, LEAF, SMOOTH)
			ball(ctx, "TopiaryUpper", 166.3, 8.0, z + 0.4, 3.8, LEAF, SMOOTH)
			ball(ctx, "TopiaryTop", 166.1, 9.5, z - 0.4, 2.6, LEAF, SMOOTH)
		end

		-- Globe pendants (lamp bulb at y 10.8, above the walking lane). Under the awning and inside the room.
		local pendants = {
			{ 182, 131, 14 }, { 182, 140, 14 }, { 196, 131, 14 }, { 196, 140, 14 },
		}
		for _, p in ipairs(pendants) do
			B(ctx, "PendantCord", p[1] - 0.05, p[1] + 0.05, 11.4, p[3], p[2] - 0.05, p[2] + 0.05, DARKF, METAL)
			ball(ctx, "PendantGlobe", p[1], 10.8, p[2], 1.2, LAMP, NEON)
		end
		-- Row of seven globes just behind the banner (bulb y 9.4, above the lane).
		for k = 0, 6 do
			local z = 119 + k * 5
			B(ctx, "PendantCord", 165.95, 166.05, 10, 12, z - 0.05, z + 0.05, DARKF, METAL)
			ball(ctx, "PendantGlobe", 166, 9.4, z, 1.2, LAMP, NEON)
		end

		-- Kitchen suggestion behind the counter.
		B(ctx, "Stove", 209.5, 213, 0, 3.4, 127, 131, STEEL, METAL)
		B(ctx, "KitchenHood", 209.2, 213.4, 6, 7, 126.5, 131.5, STEEL, METAL)
	end

	------------------------------------------------------------------ Counter (anchor: CounterTop)
	local function buildCounter(ctx)
		B(ctx, "CounterBody", 203.4, 207.6, 0, 3.2, 120.5, 159.5, WOOD_C, WOODM)
		B(ctx, "CounterTop", 203, 208, 3.2, 3.5, 120, 160, CREAM_GREY, SMOOTH)
		B(ctx, "Register", 206, 207.6, 3.5, 4.6, 136, 138.5, DARKF, SMOOTH)
		VCyl(ctx, "StockPot", 206.5, 145.5, 3.5, 4.6, 1.5, STEEL, METAL)
	end

	------------------------------------------------------------------ Tables: four north (N/S chairs), two south (E/W chairs)
	local TABLES = {
		{ 178, 125, "NS" }, { 186, 125, "NS" }, { 194, 125, "NS" }, { 200, 125, "NS" },
		{ 180, 147.5, "EW" }, { 192, 147.5, "EW" },
	}
	-- One chair on side (ox, oz) of a table: seat y 1.6..2, back y 2..4 on the far side, four legs.
	local function chair(ctx, tx, tz, ox, oz)
		local cx, cz = tx + ox * 2.3, tz + oz * 2.3
		B(ctx, "ChairSeat", cx - 0.7, cx + 0.7, 1.6, 2, cz - 0.7, cz + 0.7, WOOD_C, WOODM)
		if ox ~= 0 then
			local a, b = cx + ox * 0.7, cx + ox * 0.9
			B(ctx, "ChairBack", math.min(a, b), math.max(a, b), 2, 4, cz - 0.7, cz + 0.7, WOOD_C, WOODM)
		else
			local a, b = cz + oz * 0.7, cz + oz * 0.9
			B(ctx, "ChairBack", cx - 0.7, cx + 0.7, 2, 4, math.min(a, b), math.max(a, b), WOOD_C, WOODM)
		end
		for _, dx in ipairs({ -0.55, 0.55 }) do
			for _, dz in ipairs({ -0.55, 0.55 }) do
				B(ctx, "ChairLeg", cx + dx - 0.06, cx + dx + 0.06, 0, 1.6, cz + dz - 0.06, cz + dz + 0.06, WOOD_C, WOODM)
			end
		end
	end
	local function buildTables(ctx)
		for _, t in ipairs(TABLES) do
			local tx, tz, layout = t[1], t[2], t[3]
			B(ctx, "TableTop", tx - 1.3, tx + 1.3, 2.6, 3, tz - 1.3, tz + 1.3, WOOD_C, WOODM)
			for _, dx in ipairs({ -1, 1 }) do
				for _, dz in ipairs({ -1, 1 }) do
					B(ctx, "TableLeg", tx + dx * 1.1 - 0.1, tx + dx * 1.1 + 0.1, 0, 2.6, tz + dz * 1.1 - 0.1, tz + dz * 1.1 + 0.1, WOOD_C, WOODM)
				end
			end
			local seats = layout == "EW" and { { -1, 0 }, { 1, 0 } } or { { 0, -1 }, { 0, 1 } }
			for _, o in ipairs(seats) do
				chair(ctx, tx, tz, o[1], o[2])
			end
		end
	end

	------------------------------------------------------------------ LomiBowls: bowls on the tables and in counter stacks
	local function buildBowls(ctx)
		for _, t in ipairs(TABLES) do
			local bx, bz = t[1] + 0.3, t[2] + 0.2
			VCyl(ctx, "Bowl", bx, bz, 3, 3.42, 1.1, BOWL, SMOOTH)
			VCyl(ctx, "BowlSoup", bx, bz, 3.42, 3.48, 0.9, SOUP, SMOOTH)
			ball(ctx, "BowlEgg", bx + 0.15, 3.65, bz, 0.3, EGG, SMOOTH)
		end
		for _, z in ipairs({ 124.5, 156 }) do
			for k = 0, 2 do
				VCyl(ctx, "CounterBowl", 205.5, z, 3.5 + 0.4 * k, 3.9 + 0.4 * k, 1.1, BOWL, SMOOTH)
			end
			VCyl(ctx, "CounterBowlSoup", 205.5, z, 4.7, 4.76, 0.9, SOUP, SMOOTH)
		end
	end

	------------------------------------------------------------------ Menu: banner under the awning, menu board, framed menu
	local function buildMenu(ctx)
		-- Banner: six coloured blocks hanging in the steel frame (y 8.5..12), labels at a fixed size; the KOPI VINZ name and the
		-- phone number of the photo are not reproduced.
		local blocks = {
			{ 116, 122, "SPECIALS", RED, WHITE }, { 122, 127.5, "LOMI", BANNER, RED }, { 127.5, 133, "PANCIT", BANNER2, RED },
			{ 133, 140, "RICE MEALS", BANNER, RED }, { 140, 146.5, "SANDWICHES", BANNER2, RED }, { 146.5, 150, "", RED, WHITE },
		}
		for i, b in ipairs(blocks) do
			local blk = B(ctx, "BannerBlock" .. i, 162.5, 162.9, 8.5, 12, b[1], b[2], b[4], SMOOTH)
			if b[3] ~= "" then gui(blk, b[3], b[5], 40, 32) end
		end
		-- Dish squares (bowls, plates) above the labels of the four menu blocks.
		local dishCols = { BOWL, EGG, SOUP, LEAF, BOWL, EGG, SOUP, LEAF }
		for i = 1, 4 do
			local b = blocks[i + 1]
			for j = 0, 1 do
				local z = j == 0 and b[1] + 0.9 or b[2] - 2.0
				B(ctx, "BannerDish" .. (i * 2 - 1 + j), 162.3, 162.5, 10.85, 11.95, z, z + 1.1, dishCols[i * 2 - 1 + j], SMOOTH)
			end
		end
		local framed = B(ctx, "FramedMenu", 179, 179.2, 3, 4.6, 124.2, 125.8, WHITE, SMOOTH)
		gui(framed, "MENU", DARKF, 30)
		local board = B(ctx, "MenuBoard", 213.6, 214, 4, 12, 124, 148, WHITE, SMOOTH)
		gui(board, "MENU\nLOMI\nPANCIT\nRICE MEALS\nSANDWICHES\nCOFFEE", DARKF, 30, 24)
	end

	------------------------------------------------------------------ Utensils: caddies, chopsticks, spoons
	local function buildUtensils(ctx)
		for _, t in ipairs(TABLES) do
			local tx, tz = t[1], t[2]
			local cx, cz = tx - 0.6, tz + 0.6
			B(ctx, "Caddy", cx - 0.25, cx + 0.25, 3, 3.35, cz - 0.2, cz + 0.2, CADDY, SMOOTH)
			for j = -1, 1 do
				VCyl(ctx, "CaddyBottle", cx + 0.15 * j, cz, 3.35, 3.6, 0.1, SOY, SMOOTH)
			end
			B(ctx, "Chopsticks", tx - 0.8, tx + 0.8, 3, 3.05, tz - 0.95, tz - 0.9, CHOP, SMOOTH)
			B(ctx, "Chopsticks", tx - 0.8, tx + 0.8, 3, 3.05, tz - 0.85, tz - 0.8, CHOP, SMOOTH)
			B(ctx, "Spoon", tx - 1, tx - 0.2, 3, 3.04, tz + 1, tz + 1.05, STEEL, METAL)
		end
		-- Counter: condiment caddy and a utensil cup.
		B(ctx, "CounterCaddy", 204.2, 205, 3.5, 3.8, 134.6, 135.4, CADDY, SMOOTH)
		for j = -1, 1 do
			VCyl(ctx, "CounterCaddyBottle", 204.6, 135 + 0.25 * j, 3.8, 4.1, 0.14, SOY, SMOOTH)
		end
		VCyl(ctx, "UtensilCup", 206.5, 150.5, 3.5, 4.3, 0.8, STEEL, METAL)
		B(ctx, "CupChopstick", 206.45, 206.55, 4.3, 5, 150.35, 150.4, CHOP, SMOOTH)
		B(ctx, "CupChopstick", 206.45, 206.55, 4.3, 5, 150.6, 150.65, CHOP, SMOOTH)
	end

	------------------------------------------------------------------ Diners: idle R15 rigs, built like site01 buildPeople.
	-- CreateHumanoidModelFromDescription yields, so this runs as its own step before the swap.
	local function buildDiners(folder)
		local skins = { Color3.fromRGB(224, 172, 130), Color3.fromRGB(198, 134, 92), Color3.fromRGB(141, 85, 60), Color3.fromRGB(241, 194, 125) }
		local shirts = { Color3.fromRGB(200, 60, 60), Color3.fromRGB(60, 100, 170), Color3.fromRGB(230, 200, 80), Color3.fromRGB(90, 150, 100) }
		-- { world x, world z, world yaw }: Diner1 is the cook behind the counter, facing W; Diner2 and Diner3 face the north tables.
		local spots = { { 210.5, 140, PI / 2 }, { 186, 130.5, 0 }, { 194, 119.5, PI } }
		for i, s in ipairs(spots) do
			local desc = Instance.new("HumanoidDescription")
			desc.HeadColor = skins[i]
			desc.TorsoColor, desc.LeftArmColor, desc.RightArmColor = shirts[i], shirts[i], shirts[i]
			desc.LeftLegColor, desc.RightLegColor = Color3.fromRGB(50, 50, 70), Color3.fromRGB(50, 50, 70)
			local rig = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
			desc:Destroy()
			rig.Name = "Diner" .. i
			for _, d in ipairs(rig:GetDescendants()) do
				if d:IsA("BasePart") then d.Anchored = false end
			end
			local hrp = rig:WaitForChild("HumanoidRootPart")
			local hum = rig:FindFirstChildOfClass("Humanoid")
			hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			hum.WalkSpeed = 0
			rig.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
			rig:SetAttribute("SiteId", row.id)
			rig:PivotTo(CF(s[1] + DX, groundAt(s[1] + DX, s[2] + DZ) + 3, s[2] + DZ) * ANG(0, s[3], 0))
			hrp.Anchored = true
			rig.Parent = folder
		end
	end

	------------------------------------------------------------------ Build, then swap
	local plan = {} -- { inst, into }
	local function add(inst, into)
		table.insert(plan, { inst = inst, into = into })
		return inst
	end

	local ok, err = pcall(function()
		add(build("Structure", buildStructure), site)
		add(build("Counter", buildCounter), site)
		add(build("Tables", buildTables), site)
		add(build("LomiBowls", buildBowls), site)
		add(build("Menu", buildMenu), site)
		add(build("Utensils", buildUtensils), site)
		local diners = add(Instance.new("Folder"), site)
		diners.Name = "Diners"
		buildDiners(diners)
		used += countParts(diners)
		assert(used <= PART_BUDGET, string.format("site03: %d parts exceeds the %d budget", used, PART_BUDGET))
	end)
	if not ok then
		for _, e in ipairs(plan) do e.inst:Destroy() end
		error("site03: build failed, the placeholder Block was left untouched: " .. tostring(err), 0)
	end

	for _, child in ipairs(site:GetChildren()) do
		if REPLACED[child.Name] then child:Destroy() end
	end
	for _, e in ipairs(plan) do
		e.inst.Parent = e.into
		task.wait()
	end

	local pivotAfter = site:GetPivot()
	assert((pivotAfter.Position - pivotBefore.Position).Magnitude < 1e-3 and pivotAfter.LookVector:Dot(pivotBefore.LookVector) > 0.9999,
		"site03: the site pivot changed during the build")

	local total = countParts(site)
	return {
		parts = total,
		keptParts = keptParts,
		builtParts = total - keptParts,
	}
end
