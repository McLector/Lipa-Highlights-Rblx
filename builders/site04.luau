-- site04: Cafe de Lipa, Tibig/STAR branch only (Slice 08). Studio copy: ServerStorage.Builders.site04; run with
--   require(game.ServerStorage.Builders.site04:Clone())()
-- Needs Workspace.Sites.Site04_Cafe (created by the placeholder build, with Guide and InfoPanel).
-- IDEMPOTENT: replaces Block, Structure, CoffeeBar, BarakoBeans, CoffeePacks, BrewingSet, Tables, Pendants and Staff.
-- Guide, InfoPanel and anything else under the site are kept. Touches nothing outside Workspace.Sites.Site04_Cafe.
-- No terrain change: thin ground parts lie inside x 112..212, z -200..-120 (the repainted Pavement).
-- Brief: briefs/site04.md. The interior is representative and the sign in it says so.
-- FRAMES: the site pivot is yawed to W, so it is NOT used as the origin.
--   ORIGIN = CFrame.new(pivot position): world-aligned, +X east, +Z south.
--   FR     = ORIGIN * fromMatrix(0, (0,0,1), (0,1,0), (-1,0,0)): local +Z = W (frontage, outward), local +X = S.
--            World = (160 - lz, y, -160 + lx).
--   The helpers below take WORLD coordinates and convert them, so every box stays axis-aligned in the world.
--   A SurfaceGui on the frontage side is on the part's local +Z face = Enum.NormalId.Back.
-- Fail-safe order as in site03: everything is built into unparented pieces first (budget counted); only then are the
-- old children deleted and the containers parented one at a time with task.wait(). An error before that point destroys
-- the partial build and leaves the placeholder Block untouched.
return function()
	local Players = game:GetService("Players")
	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
	local BuildKit = require(game.ServerStorage.BuildKit:Clone())

	local V, CF, ANG = Vector3.new, CFrame.new, CFrame.Angles
	local PI = math.pi
	local row = SiteData.byId(4)
	assert(row and row.facing == "W", "site04: SiteData row 4 is missing or not facing W")
	local sites = workspace:FindFirstChild("Sites")
	local site = sites and sites:FindFirstChild("Site04_Cafe")
	assert(site, "site04: Workspace.Sites.Site04_Cafe not found (run builders/placeholders first)")
	local pivotBefore = site:GetPivot()
	local PX, PZ = pivotBefore.Position.X, pivotBefore.Position.Z
	assert(math.abs(PX - 160) < 1e-3 and math.abs(PZ + 160) < 1e-3, "site04: pivot is not at (160, 0, -160)")
	local ORIGIN = CF(pivotBefore.Position)
	local FR = ORIGIN * CFrame.fromMatrix(V(0, 0, 0), V(0, 0, 1), V(0, 1, 0), V(-1, 0, 0))

	local PART_BUDGET = 2500
	local REPLACED = {
		Block = true, Structure = true, CoffeeBar = true, BarakoBeans = true, CoffeePacks = true,
		BrewingSet = true, Tables = true, Pendants = true, Staff = true,
	}

	-- Colours (by eye from the night photo; see briefs/site04.md).
	local CHARCOAL = Color3.fromRGB(48, 42, 46)
	local NEON_Y = Color3.fromRGB(255, 226, 70)
	local SOFFIT = Color3.fromRGB(236, 232, 226)
	local DOWNLIGHT = Color3.fromRGB(255, 240, 200)
	local GLASS_C = Color3.fromRGB(170, 200, 210)
	local MULLION = Color3.fromRGB(30, 30, 34)
	local TILE_LIGHT = Color3.fromRGB(226, 224, 216)
	local CHECK_LIGHT = Color3.fromRGB(222, 218, 208)
	local CHECK_DARK = Color3.fromRGB(60, 56, 54)
	local BAR_WOOD = Color3.fromRGB(176, 120, 70)
	local BAR_TOP = Color3.fromRGB(110, 70, 40)
	local TABLE_WOOD = Color3.fromRGB(170, 125, 75)
	local LEG_DARK = Color3.fromRGB(50, 38, 32)
	local RED = Color3.fromRGB(200, 48, 36)
	local DARK_WOOD = Color3.fromRGB(58, 44, 36)
	local WARM = Color3.fromRGB(255, 220, 150)
	local COPPER = Color3.fromRGB(184, 115, 51)
	local STEEL = Color3.fromRGB(190, 190, 186)
	local DARKMETAL = Color3.fromRGB(40, 42, 48)
	local WHITE = Color3.fromRGB(240, 240, 236)
	local CUP = Color3.fromRGB(240, 226, 190)
	local SACK = Color3.fromRGB(150, 120, 80)
	local JAR = Color3.fromRGB(120, 70, 40)
	local KRAFT = Color3.fromRGB(190, 150, 100)
	local KRAFT_DARK = Color3.fromRGB(120, 90, 50)
	local SMOOTH, WOODM, METAL = Enum.Material.SmoothPlastic, Enum.Material.Wood, Enum.Material.Metal
	local GLASS, NEON, FABRIC = Enum.Material.Glass, Enum.Material.Neon, Enum.Material.Fabric

	-- World -> Cafe-local CFrame (no rotation): lx = z - PZ, ly = y, lz = PX - x.
	local function L(x, y, z)
		return CF(z - PZ, y, PX - x)
	end
	-- Axis-aligned world box x0..x1, y0..y1, z0..z1. Local X carries the world Z extent, local Z the world X extent.
	local function B(ctx, name, x0, x1, y0, y1, z0, z1, color, material)
		return ctx:part(name, V(z1 - z0, y1 - y0, x1 - x0), L((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), color, material)
	end
	-- Vertical cylinder (axis = world Y) from y0 to y1, centred on (x, z).
	local function VCyl(ctx, name, x, z, y0, y1, dia, color, material)
		return ctx:cyl(name, V(y1 - y0, dia, dia), L(x, (y0 + y1) / 2, z) * ANG(0, 0, PI / 2), color, material)
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

	-- One unparented piece built in the Cafe frame. Parts are counted against the budget as they are made.
	local function build(name, fn)
		local model = Instance.new("Model")
		model.Name = name
		local ctx = BuildKit.new(model, FR, { budget = PART_BUDGET - used })
		fn(ctx)
		ctx:flush()
		used += ctx:count()
		return model
	end

	-- Lowercase pixel letters for the fascia sign. Six rows, top to bottom: row 1 is the ascender line, rows 2..5 the
	-- x-height, row 6 the descender. Each glyph is three columns wide.
	local FONT = {
		c = { "   ", "###", "#  ", "#  ", "###", "   " },
		a = { "   ", "###", "  #", "###", "###", "   " },
		f = { " ##", " # ", " # ", "###", " # ", "   " },
		e = { "   ", "###", "###", "#  ", "###", "   " },
		d = { "  #", "###", "# #", "# #", "###", "   " },
		l = { " # ", " # ", " # ", " # ", " # ", "   " },
		i = { " # ", "   ", " # ", " # ", " # ", "   " },
		p = { "   ", "###", "# #", "###", "#  ", "#  " },
	}
	-- Neon letters on the sign band's west face (x xLo..xHi, proud by 0.6), reading left to right from the street, i.e.
	-- increasing z. Runs of lit pixels in a row become one block each.
	local function buildWord(ctx, word, z0, yTop, pitch, pixH, xLo, xHi)
		local cursor = z0
		for ch in word:gmatch(".") do
			local glyph = FONT[ch]
			assert(glyph, "site04: no glyph for " .. ch)
			for r = 1, #glyph do
				local line = glyph[r]
				local yHi = yTop - (r - 1) * pixH
				local yLo = yHi - pixH
				local c = 1
				while c <= #line do
					if line:sub(c, c) == "#" then
						local e = c
						while e < #line and line:sub(e + 1, e + 1) == "#" do e += 1 end
						B(ctx, "NeonLetter", xLo, xHi, yLo, yHi, cursor + (c - 1) * pitch, cursor + e * pitch, NEON_Y, NEON)
						c = e + 1
					else
						c += 1
					end
				end
			end
			cursor += 4 * pitch
		end
	end

	------------------------------------------------------------------ Structure: ground, arcade, unit shell, glass, sign
	local function buildStructure(ctx)
		-- Thin ground parts, all inside x 112..212, z -200..-120.
		B(ctx, "TerraceTile", 144, 164, 0, 0.2, -188, -128, TILE_LIGHT, SMOOTH)
		B(ctx, "UnitFloor", 164, 204, 0, 0.2, -186, -134, CHECK_LIGHT, SMOOTH)
		for i = 0, 9 do
			for j = 0, 12 do
				if (i + j) % 2 == 0 then
					local x0, z0 = 164 + i * 4, -186 + j * 4
					B(ctx, "CheckerDark", x0, x0 + 4, 0.2, 0.25, z0, z0 + 4, CHECK_DARK, SMOOTH)
				end
			end
		end
		-- Plain dark neighbour bay south of the unit (kept to one block).
		B(ctx, "NeighbourBay", 164, 204, 0, 12, -134, -122, CHARCOAL, SMOOTH)

		-- Arcade: white soffit (underside y 13), slim charcoal columns on the west edge (none in the lane), Neon downlights.
		B(ctx, "ArcadeRoof", 144, 164, 13, 14, -188, -128, SOFFIT, SMOOTH)
		for _, z in ipairs({ -186, -176, -146, -136, -130 }) do
			B(ctx, "ArcadeColumn", 144, 145, 0, 13, z - 0.5, z + 0.5, CHARCOAL, SMOOTH)
		end
		for _, x in ipairs({ 148, 156 }) do
			for _, z in ipairs({ -182, -170, -150, -138 }) do
				VCyl(ctx, "Downlight", x, z, 12.8, 13, 0.8, DOWNLIGHT, NEON)
			end
		end

		-- Fascia band carrying the lowercase sign, the ceiling mass over the unit, the walls.
		B(ctx, "SignFascia", 163, 165, 12, 18, -186, -134, CHARCOAL, SMOOTH)
		-- The sign sits on a charcoal band rising above the arcade's outer (west) edge, so the letters are seen from the street;
		-- on the fascia behind the roof slab they were hidden (guard "sign letters are visible from the street").
		B(ctx, "ArcadeSignBand", 144, 145.2, 14, 21.6, -188, -128, CHARCOAL, SMOOTH)
		buildWord(ctx, "cafedelipa", -185.5, 20.7, 1.3, 0.9, 143.4, 144)
		B(ctx, "CafeBody", 164, 204, 12, 17, -186, -134, CHARCOAL, SMOOTH)
		B(ctx, "BackWall", 202, 204, 0, 12, -186, -134, CHARCOAL, SMOOTH)
		B(ctx, "SideWallN", 164, 204, 0, 12, -186, -185.5, CHARCOAL, SMOOTH)
		B(ctx, "SideWallS", 164, 204, 0, 12, -134.5, -134, CHARCOAL, SMOOTH)

		-- Full-height glass front at x 164 with dark mullions. The door opening is z -165..-155 (10 wide).
		local panes = { { -186, -181 }, { -181, -176 }, { -176, -171 }, { -171, -165 },
			{ -155, -150 }, { -150, -145 }, { -145, -140 }, { -140, -134.5 } }
		for _, p in ipairs(panes) do
			B(ctx, "GlassPane", 163.9, 164.1, 0, 11.6, p[1], p[2], GLASS_C, GLASS).Transparency = 0.6
		end
		for _, z in ipairs({ -186, -181, -176, -171, -165, -155, -150, -145, -140, -134 }) do
			B(ctx, "Mullion", 163.7, 164.3, 0, 12, z - 0.25, z + 0.25, MULLION, METAL)
		end
		B(ctx, "GlassHead", 163.7, 164.3, 11.6, 12, -186, -165, MULLION, METAL)
		B(ctx, "GlassHead", 163.7, 164.3, 11.6, 12, -155, -134, MULLION, METAL)
		B(ctx, "DoorHeader", 163.7, 164.3, 10, 11.6, -165, -155, MULLION, METAL)
		B(ctx, "DoorHandle", 163.5, 164.5, 1, 9, -165.6, -165.2, DARKMETAL, METAL)
		B(ctx, "DoorHandle", 163.5, 164.5, 1, 9, -154.8, -154.4, DARKMETAL, METAL)

		-- Representative-interior sign on the back wall: 12 wide, 2.5 tall, centred on y 9.5, clear of the shelves.
		local rep = B(ctx, "RepresentativeSign", 201.5, 202, 8.25, 10.75, -166, -154, WHITE, SMOOTH)
		gui(rep, "INTERIOR SHOWN IS REPRESENTATIVE", DARKMETAL, 40)
	end

	------------------------------------------------------------------ CoffeeBar (anchor: BarTop)
	local function buildCoffeeBar(ctx)
		B(ctx, "BarBody", 190, 196, 0, 3, -182, -138, BAR_WOOD, WOODM)
		B(ctx, "BarTop", 190, 196, 3, 3.5, -182, -138, BAR_TOP, WOODM)
		-- Espresso machine at the north (left from the lane) end, grinder beside it, cups along the front.
		B(ctx, "EspressoMachine", 191.5, 194.5, 3.5, 5.8, -180, -175, STEEL, METAL)
		B(ctx, "EspressoCap", 191.5, 194.5, 5.8, 6, -180, -175, DARKMETAL, METAL)
		VCyl(ctx, "Grinder", 192.5, -170, 3.5, 5.4, 1.2, DARKMETAL, METAL)
		B(ctx, "Register", 194.2, 195.6, 3.5, 4.2, -146, -143, DARKMETAL, SMOOTH)
		for i = 0, 2 do
			VCyl(ctx, "Cup", 191.6, -166 + i * 1.2, 3.5, 4.1, 0.8, CUP, SMOOTH)
		end
	end

	------------------------------------------------------------------ BrewingSet: pour-over, press, kettle, cups (on the bar)
	local function buildBrewingSet(ctx)
		VCyl(ctx, "Kettle", 192.5, -143, 3.5, 4.5, 1.0, STEEL, METAL)
		VCyl(ctx, "PourOverCone", 194.2, -141.5, 3.5, 4.0, 1.0, WHITE, SMOOTH)
		VCyl(ctx, "Carafe", 194.2, -139.5, 3.5, 4.2, 0.9, GLASS_C, GLASS).Transparency = 0.5
		VCyl(ctx, "FrenchPress", 192.5, -139.5, 3.5, 4.6, 0.9, DARKMETAL, METAL)
		VCyl(ctx, "PressPlunger", 192.5, -139.5, 4.6, 5.2, 0.15, STEEL, METAL)
		for _, x in ipairs({ 191.5, 192.6, 193.7 }) do
			VCyl(ctx, "BrewCup", x, -146, 3.5, 4.0, 0.7, CUP, SMOOTH)
		end
	end

	------------------------------------------------------------------ CoffeePacks: generic kraft packs on the north back shelves
	local function buildCoffeePacks(ctx)
		for k, yT in ipairs({ 1.2, 3.2, 5.2 }) do
			B(ctx, "PackShelf", 198.5, 202, yT - 0.2, yT, -184, -172, BAR_WOOD, WOODM)
			for i = 1, 5 do
				local z0 = -183.5 + (i - 1) * 1.4
				B(ctx, "BarakoPack", 198.9, 200.4, yT, yT + 0.9, z0, z0 + 1.2, (i + k) % 2 == 0 and KRAFT or KRAFT_DARK, SMOOTH)
			end
		end
	end

	------------------------------------------------------------------ BarakoBeans: burlap sacks and glass jars, south back shelves
	local function buildBarakoBeans(ctx)
		B(ctx, "BeanShelf", 198.5, 202, 1.0, 1.2, -148, -136, BAR_WOOD, WOODM)
		B(ctx, "BeanShelf", 198.5, 202, 5.0, 5.2, -148, -136, BAR_WOOD, WOODM)
		for _, z in ipairs({ -147.5, -144.5, -141.5, -138.5 }) do
			B(ctx, "BeanSack", 199, 200.3, 1.2, 2.2, z - 0.5, z + 0.5, SACK, FABRIC)
			VCyl(ctx, "BeanJar", 200.8, z, 5.2, 6.2, 0.9, JAR, GLASS).Transparency = 0.4
		end
	end

	------------------------------------------------------------------ Tables: terrace (8) and interior (4), with chairs
	local function buildTables(ctx)
		local chairCount = 0
		local function tableAt(tx, tz, round)
			if round then
				VCyl(ctx, "TableBase", tx, tz, 0, 0.2, 1.4, LEG_DARK, WOODM)
				VCyl(ctx, "TablePedestal", tx, tz, 0.2, 2.6, 0.3, LEG_DARK, WOODM)
				VCyl(ctx, "TableTop", tx, tz, 2.6, 3.0, 2.4, TABLE_WOOD, WOODM)
			else
				B(ctx, "TableTop", tx - 1.2, tx + 1.2, 2.6, 3.0, tz - 1.2, tz + 1.2, TABLE_WOOD, WOODM)
				for _, dx in ipairs({ -1, 1 }) do
					for _, dz in ipairs({ -1, 1 }) do
						B(ctx, "TableLeg", tx + dx * 1.0 - 0.1, tx + dx * 1.0 + 0.1, 0, 2.6, tz + dz * 1.0 - 0.1, tz + dz * 1.0 + 0.1, LEG_DARK, WOODM)
					end
				end
			end
		end
		-- One chair on side (dx, dz) of a table: seat y 1.6..2, back y 2..4 on the far side, four legs. Red and dark wood alternate.
		local function chair(tx, tz, dx, dz)
			chairCount += 1
			local red = chairCount % 2 == 1
			local color, mat = red and RED or DARK_WOOD, red and SMOOTH or WOODM
			local cx, cz = tx + dx * 2.3, tz + dz * 2.3
			B(ctx, "ChairSeat", cx - 0.7, cx + 0.7, 1.6, 2, cz - 0.7, cz + 0.7, color, mat)
			if dx ~= 0 then
				local a, b = cx + dx * 0.7, cx + dx * 0.9
				B(ctx, "ChairBack", math.min(a, b), math.max(a, b), 2, 4, cz - 0.7, cz + 0.7, color, mat)
			else
				local a, b = cz + dz * 0.7, cz + dz * 0.9
				B(ctx, "ChairBack", cx - 0.7, cx + 0.7, 2, 4, math.min(a, b), math.max(a, b), color, mat)
			end
			for _, lx in ipairs({ -0.55, 0.55 }) do
				for _, lz in ipairs({ -0.55, 0.55 }) do
					B(ctx, "ChairLeg", cx + lx - 0.06, cx + lx + 0.06, 0, 1.6, cz + lz - 0.06, cz + lz + 0.06, color, mat)
				end
			end
		end
		local function table4(tx, tz, round, dirs)
			tableAt(tx, tz, round)
			for _, d in ipairs(dirs) do
				chair(tx, tz, d[1], d[2])
			end
		end
		-- Terrace: x 150 and 158, z -180, -172, -148, -140. None in the lane (z -164..-156); chairs stay z <= -166 or >= -154.
		for _, tx in ipairs({ 150, 158 }) do
			for _, tz in ipairs({ -180, -172, -148, -140 }) do
				local dirs = { { -1, 0 }, { 1, 0 } }
				if tx == 158 and (tz == -172 or tz == -140) then
					table.insert(dirs, { 0, 1 })
				end
				table4(tx, tz, (tx == 150 and tz == -180) or (tx == 158 and tz == -140), dirs)
			end
		end
		-- Interior: x 172 and 180, z -178 and -142.
		for _, tx in ipairs({ 172, 180 }) do
			for _, tz in ipairs({ -178, -142 }) do
				table4(tx, tz, (tx == 172 and tz == -178) or (tx == 180 and tz == -142), { { -1, 0 }, { 1, 0 } })
			end
		end
	end

	------------------------------------------------------------------ Pendants: warm globes, each with a small warm PointLight
	local function buildPendants(ctx)
		local spots = { { 168, -172 }, { 168, -148 }, { 176, -172 }, { 176, -148 }, { 184, -172 }, { 184, -148 }, { 193, -170 }, { 193, -150 } }
		for _, s in ipairs(spots) do
			local x, z = s[1], s[2]
			B(ctx, "PendantCord", x - 0.05, x + 0.05, 11.8, 12, z - 0.05, z + 0.05, DARKMETAL, METAL)
			VCyl(ctx, "PendantCap", x, z, 11.4, 11.8, 0.9, COPPER, METAL)
			local globe = ball(ctx, "PendantGlobe", x, 10.8, z, 1.2, WARM, NEON)
			local light = Instance.new("PointLight")
			light.Color = WARM
			light.Range = 12
			light.Brightness = 1.5
			light.Parent = globe
		end
	end

	------------------------------------------------------------------ Staff: idle R15 rigs, built like site03.
	-- CreateHumanoidModelFromDescription yields, so this runs as its own step before the swap.
	local function buildStaff(folder)
		local skins = { Color3.fromRGB(224, 172, 130), Color3.fromRGB(141, 85, 60) }
		local shirts = { Color3.fromRGB(240, 240, 236), Color3.fromRGB(200, 60, 60) }
		local pants = { Color3.fromRGB(40, 40, 50), Color3.fromRGB(60, 60, 70) }
		-- { world x, world z, world yaw }: Staff1 is the barista behind the bar, facing W; Staff2 stands on the terrace
		-- beside a table, outside the lane, facing E.
		local spots = { { 199, -160, PI / 2 }, { 146, -152.5, -PI / 2 } }
		for i, s in ipairs(spots) do
			local desc = Instance.new("HumanoidDescription")
			desc.HeadColor = skins[i]
			desc.TorsoColor, desc.LeftArmColor, desc.RightArmColor = shirts[i], shirts[i], shirts[i]
			desc.LeftLegColor, desc.RightLegColor = pants[i], pants[i]
			local rig = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
			desc:Destroy()
			rig.Name = "Staff" .. i
			for _, d in ipairs(rig:GetDescendants()) do
				if d:IsA("BasePart") then d.Anchored = false end
			end
			local hrp = rig:WaitForChild("HumanoidRootPart")
			local hum = rig:FindFirstChildOfClass("Humanoid")
			hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			hum.WalkSpeed = 0
			rig.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
			rig:SetAttribute("SiteId", row.id)
			rig:PivotTo(CF(s[1], groundAt(s[1], s[2]) + 3, s[2]) * ANG(0, s[3], 0))
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
		add(build("CoffeeBar", buildCoffeeBar), site)
		add(build("BrewingSet", buildBrewingSet), site)
		add(build("CoffeePacks", buildCoffeePacks), site)
		add(build("BarakoBeans", buildBarakoBeans), site)
		add(build("Tables", buildTables), site)
		add(build("Pendants", buildPendants), site)
		local staff = add(Instance.new("Folder"), site)
		staff.Name = "Staff"
		buildStaff(staff)
		used += countParts(staff)
		assert(used <= PART_BUDGET, string.format("site04: %d parts exceeds the %d budget", used, PART_BUDGET))
	end)
	if not ok then
		for _, e in ipairs(plan) do e.inst:Destroy() end
		error("site04: build failed, the placeholder Block was left untouched: " .. tostring(err), 0)
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
		"site04: the site pivot changed during the build")

	local total = countParts(site)
	return {
		parts = total,
		keptParts = keptParts,
		builtParts = total - keptParts,
	}
end
