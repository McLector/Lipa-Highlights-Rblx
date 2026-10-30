-- site03_dining: the dining room of Site 03 (Lomi King), job L3a. A PORT of the dining recipes of the old single-file builder (scratch/site03_old.luau): no visual change.
-- Studio copy: ServerStorage.Builders.site03_dining. Assembler: builders/site03.luau. Check: tests/site03_check.luau, group "dining" (also "general" and "clear").
-- Owns Counter, Tables, LomiBowls, Menu, Utensils, Patio (Models directly under Site03_Lomi, each holding its parts) and Diners (a Folder holding the 3 rigs).
-- 231 parts (budget 260): Counter 4, Tables 102, LomiBowls 26, Menu 16, Utensils 49, Patio 34. The 3 Diner rigs (48 parts) are outside the module budget (env.addRig).
-- Naming (same as the old builder): CounterBody CounterTop Register StockPot; TableTop TableLeg ChairSeat ChairBack ChairLeg; Bowl BowlSoup BowlEgg CounterBowl CounterBowlSoup;
--   BannerBlock1..6 BannerDish1..8 FramedMenu MenuBoard; Caddy CaddyBottle Chopsticks Spoon CounterCaddy CounterCaddyBottle UtensilCup CupChopstick;
--   Patio = FloorTile FrontStep Pot Topiary TopiaryUpper TopiaryTop PendantCord PendantGlobe Stove KitchenHood; Diners = Diner1..Diner3.
-- FRAME: every section is built in the Lomi frame env.LK (the old LK: local +X = South, local +Z = West, the frontage side). The helper L() takes the OLD world coordinates
--   of the Slice 07 builder (site centre x 180, z 140) and converts them, so every box stays axis-aligned in the world; the site now stands at x 292, so the whole dining
--   room sits 112 east of its old world position. A SurfaceGui on the frontage side is on the part's local +Z face = Enum.NormalId.Back (the WEST face only because of LK).
-- The rigs use absolute coordinates, so DX/DZ shift them by the same 112. Players:CreateHumanoidModelFromDescription yields, so this module only runs from a yielding coordinator.
return function(env)
	local V, CF, ANG, PI = env.V, env.CF, env.ANG, env.PI
	local LK = env.LK
	local Players = game:GetService("Players")

	-- Colours (by eye from Lomi_King_Front_Oblique_2015.jpg; see briefs/site03.md).
	local WHITE = Color3.fromRGB(240, 240, 236)
	local RED = Color3.fromRGB(200, 30, 40)
	local BANNER = Color3.fromRGB(240, 170, 50)
	local BANNER2 = Color3.fromRGB(236, 150, 40)
	local CREAM_GREY = Color3.fromRGB(200, 196, 184)
	local DARKF = Color3.fromRGB(40, 42, 48)
	local WOOD_C = Color3.fromRGB(84, 56, 40)
	local CADDY = Color3.fromRGB(190, 190, 186)
	local SOY = Color3.fromRGB(70, 40, 24)
	local CHOP = Color3.fromRGB(214, 190, 140)
	local BOWL = Color3.fromRGB(240, 226, 190)
	local SOUP = Color3.fromRGB(160, 80, 30)
	local EGG = Color3.fromRGB(250, 200, 60)
	local STEEL = Color3.fromRGB(150, 154, 160)
	local TILE = Color3.fromRGB(170, 164, 150)
	local TERRA = Color3.fromRGB(190, 100, 60)
	local LEAF = Color3.fromRGB(60, 130, 50)
	local LAMP = Color3.fromRGB(255, 236, 190)
	local SMOOTH, WOODM, METAL = Enum.Material.SmoothPlastic, Enum.Material.Wood, Enum.Material.Metal
	local NEON = Enum.Material.Neon

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

	------------------------------------------------------------------ Patio: floor tile, step, pots and topiary, pendants, kitchen suggestion
	-- The dining parts of the old Structure block (which also held the walls, awning, letters, tower and so on, now other modules' work).
	local function buildPatio(ctx)
		-- Thin ground parts, all inside x 128..228, z 100..180 (old coordinates).
		B(ctx, "FloorTile", 172, 216, 0, 0.2, 116, 150, TILE, SMOOTH)
		B(ctx, "FrontStep", 162.5, 172, 0, 1, 116, 150, TILE, SMOOTH)

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

	env.section("Counter", buildCounter, nil, LK)
	env.section("Tables", buildTables, nil, LK)
	env.section("LomiBowls", buildBowls, nil, LK)
	env.section("Menu", buildMenu, nil, LK)
	env.section("Utensils", buildUtensils, nil, LK)
	env.section("Patio", buildPatio, nil, LK)

	------------------------------------------------------------------ Diners: idle R15 rigs, built like site01 buildPeople.
	-- The Slice 07 coordinates are absolute, so DX/DZ move them to the site as it stands now (centre 292, 140 against 180, 140).
	local DX, DZ = env.ORIGIN.X - 180, env.ORIGIN.Z - 140
	local skins = { Color3.fromRGB(224, 172, 130), Color3.fromRGB(198, 134, 92), Color3.fromRGB(141, 85, 60), Color3.fromRGB(241, 194, 125) }
	local shirts = { Color3.fromRGB(200, 60, 60), Color3.fromRGB(60, 100, 170), Color3.fromRGB(230, 200, 80), Color3.fromRGB(90, 150, 100) }
	-- { old world x, old world z, world yaw }: Diner1 is the cook behind the counter, facing W; Diner2 and Diner3 face the north tables.
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
		rig:SetAttribute("SiteId", 3)
		rig:PivotTo(CF(s[1] + DX, groundAt(s[1] + DX, s[2] + DZ) + 3, s[2] + DZ) * ANG(0, s[3], 0))
		hrp.Anchored = true
		env.addRig(rig, "Diners")
	end
end
