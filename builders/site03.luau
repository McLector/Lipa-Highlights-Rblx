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
	local PINK = Color3.fromRGB(232, 130, 112)
	local PINK_DARK = Color3.fromRGB(214, 112, 96)
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
	local function gui(part, text, color, ppstud)
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
		t.TextScaled = true
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
		for _, z in ipairs({ 116, 126, 150 }) do
			B(ctx, "FrontColumn", 171, 172.6, 0, 14, z - 0.8, z + 0.8, PINK_DARK, SMOOTH)
		end

		-- Awning fascia across the open front, letter board on top, LOMI KING on the street face.
		local awning = B(ctx, "AwningFascia", 162.4, 172, 12, 16, 114, 166, ORANGE, SMOOTH)
		gui(awning, "LOMI KING", WHITE, 30)
		local letters = B(ctx, "LetterBoard", 165, 170.5, 16, 18.2, 122, 158, CREAM_GREY, SMOOTH)
		gui(letters, "LOMI KING", BLUE_GREY, 24)

		-- Upper storeys: one pink mass on top of the ground storey (hollow below y 14), flat parapet roof.
		B(ctx, "LomiBody", 172, 216, 14, 44, 114, 166, PINK, SMOOTH)
		B(ctx, "RoofSlab", 172, 216, 44, 45, 114, 166, ROOF, CONC)
		B(ctx, "FrontParapet", 172, 172.6, 44, 45.5, 114, 166, PINK, SMOOTH)
		for _, zr in ipairs({ { 116.5, 120.5 }, { 128.5, 135.5 }, { 137.5, 148.5 }, { 151.5, 159.5 } }) do
			B(ctx, "WindowGlassA", 171.6, 171.95, 20, 26, zr[1], zr[2], GLASS_C, GLASS).Transparency = 0.25
		end
		for _, zr in ipairs({ { 116.5, 122.5 }, { 125.5, 134.5 }, { 146.5, 159.5 } }) do
			B(ctx, "WindowGlassB", 171.6, 171.95, 30, 36, zr[1], zr[2], GLASS_C, GLASS).Transparency = 0.25
		end
		-- Second-floor round bay on the west face.
		VCyl(ctx, "RoundBay", 171.4, 124, 19, 27, 6, PINK, SMOOTH)
		-- Round red logo sign on a bracket high on the west face.
		B(ctx, "LogoBracket", 169.2, 172, 30.6, 31.4, 139.8, 140.2, DARKF, METAL)
		XCyl(ctx, "LogoDisk", 169.15, 169.65, 31, 140, 7, RED, SMOOTH)
		XCyl(ctx, "LogoBowl", 168.9, 169.15, 31, 140, 4, CREAM_GREY, SMOOTH)

		-- Closed bay west face: bamboo screen and the parking sign on two posts.
		B(ctx, "BambooScreen", 171.5, 171.9, 2, 12, 152, 164, TAN, WOODM)
		local sign = B(ctx, "ParkingSign", 170.8, 171.2, 3, 8, 152, 164, WHITE, SMOOTH)
		gui(sign, "PARKING FOR LOMI KING CUSTOMERS ONLY", RED, 30)
		B(ctx, "SignPost", 170.85, 171.15, 0, 3, 153, 153.3, STEEL, METAL)
		B(ctx, "SignPost", 170.85, 171.15, 0, 3, 162.7, 163, STEEL, METAL)

		-- Terracotta pots with topiary on the step, outside the aisle.
		for _, z in ipairs({ 122, 147 }) do
			VCyl(ctx, "Pot", 166, z, 1, 2.2, 2.4, TERRA, SMOOTH)
			ball(ctx, "Topiary", 166, 4.6, z, 3, LEAF, SMOOTH)
		end

		-- Globe pendants (lamp bulb at y 10.8, above the walking lane). Under the awning and inside the room.
		local pendants = {
			{ 168, 122, 12 }, { 168, 131, 12 }, { 168, 140, 12 },
			{ 182, 131, 14 }, { 182, 140, 14 }, { 196, 131, 14 }, { 196, 140, 14 },
		}
		for _, p in ipairs(pendants) do
			B(ctx, "PendantCord", p[1] - 0.05, p[1] + 0.05, 11.4, p[3], p[2] - 0.05, p[2] + 0.05, DARKF, METAL)
			ball(ctx, "PendantGlobe", p[1], 10.8, p[2], 1.2, LAMP, NEON)
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
		local banner = B(ctx, "MenuBanner", 162.6, 163, 9, 11.3, 116, 150, BANNER, SMOOTH)
		gui(banner, "LOMI   PANCIT   RICE MEALS   SANDWICHES   COFFEE", RED, 20)
		B(ctx, "MenuStripe", 162.6, 163, 11.3, 12, 116, 150, RED, SMOOTH)
		local framed = B(ctx, "FramedMenu", 179, 179.2, 3, 4.6, 124.2, 125.8, WHITE, SMOOTH)
		gui(framed, "MENU", DARKF, 30)
		local board = B(ctx, "MenuBoard", 213.6, 214, 5, 12, 124, 148, WHITE, SMOOTH)
		gui(board, "MENU   LOMI   PANCIT   RICE MEALS   SANDWICHES   COFFEE", DARKF, 30)
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
