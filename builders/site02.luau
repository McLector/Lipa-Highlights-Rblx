-- site02: Candido B. Lopez Memorial Public Market (Slice 06, reworked in Slice 17). Studio copy: ServerStorage.Builders.site02; run with
--   require(game.ServerStorage.Builders.site02:Clone())()
-- Run builders/placeholders first (it creates Workspace.Sites.Site02_Market with Guide, InfoPanel...).
-- IDEMPOTENT: replaces Block / Structure / Yard / MarketStalls / Baskets / Produce / PriceSigns / VendorNPCs and keeps
-- Guide, InfoPanel and anything else outside that set. Touches nothing outside Workspace.Sites.Site02_Market. No terrain change.
-- Brief: briefs/site02.md (see "Revision 1 (Slice 17)"). FRAMES: the site pivot is yawed to E, so it is NOT used as the origin.
--   ORIGIN = CFrame.new(pivot position): world-aligned, +X east, +Z south.
--   MK     = ORIGIN * fromMatrix(0, (0,0,-1), up, (1,0,0)): the market frame. Local +Z = E (the frontage, outward),
--            local +X = N, local -X = S. World = (pivot.x + lz, 0, pivot.z - lx).
--   A SurfaceGui on the frontage side of a part in MK is on the part's local +Z face = Enum.NormalId.Back.
-- Slice 17: the hall is 90 deep (OSM footprint, about 40 m), has a low-pitch blue-grey roof with end gables, a south upper gallery on
-- round yellow portico columns under a dark awning and a plain blue billboard, a stair that runs along the facade and rises to the
-- south under a full-length roof, tilted shutter awnings, a continuous tin lean-to row, tricycles and a tighter stall yard.
-- Fail-safe order as in site06: everything is built into unparented pieces first (budget counted); only then are the old
-- children deleted and the containers parented one at a time with task.wait(). An error before that point destroys the
-- partial build and leaves the placeholder Block untouched. The model, its WorldPivot and PrimaryPart are never touched.
return function()
	local Players = game:GetService("Players")
	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
	local BuildKit = require(game.ServerStorage.BuildKit:Clone())

	local V, CF, ANG = Vector3.new, CFrame.new, CFrame.Angles
	local PI = math.pi
	local row = SiteData.byId(2)
	assert(row and row.facing == "E", "site02: SiteData row 2 is missing or not facing E")
	local sites = workspace:FindFirstChild("Sites")
	local site = sites and sites:FindFirstChild("Site02_Market")
	assert(site, "site02: Workspace.Sites.Site02_Market not found (run builders/placeholders first)")
	local pivotBefore = site:GetPivot()
	local ORIGIN = CF(pivotBefore.Position)
	local MK = ORIGIN * CFrame.fromMatrix(V(0, 0, 0), V(0, 0, -1), V(0, 1, 0), V(1, 0, 0))

	local PART_BUDGET = 2500
	local REPLACED = {
		Block = true, Structure = true, Yard = true, MarketStalls = true, Baskets = true,
		Produce = true, PriceSigns = true, VendorNPCs = true,
	}

	-- Colours (Market_Facade_2014.jpg, Market_Open_Air_Vegetable_Stalls_2011.jpg, OSM roof:colour #6b88b4; see briefs/site02.md).
	local WALL = Color3.fromRGB(222, 190, 110)
	local WALL_LIGHT = Color3.fromRGB(232, 214, 150)
	local MAROON = Color3.fromRGB(120, 40, 40)
	local RUST_PATCH = Color3.fromRGB(150, 62, 52)
	local GALLERY_WALL = Color3.fromRGB(140, 58, 50)
	local END_BAY = Color3.fromRGB(150, 66, 66)
	local WHITE = Color3.fromRGB(236, 234, 228)
	local BLUE_TEXT = Color3.fromRGB(40, 70, 170)
	local BILLBOARD = Color3.fromRGB(36, 92, 190)
	local ROOF_BLUE = Color3.fromRGB(50, 70, 150)
	local ROOF_SLATE = Color3.fromRGB(107, 136, 180)
	local ROOF_SEAM = Color3.fromRGB(150, 176, 212)
	local ROOF_GREY = Color3.fromRGB(92, 96, 104)
	local SHUTTER = Color3.fromRGB(110, 96, 84)
	local AWNING_DARK = Color3.fromRGB(60, 56, 56)
	local GLASSC = Color3.fromRGB(60, 76, 88)
	local DARK_GLASS = Color3.fromRGB(38, 46, 54)
	local RUST = Color3.fromRGB(150, 90, 60)
	local TIN = Color3.fromRGB(130, 134, 138)
	local TARP_BLUE = Color3.fromRGB(40, 100, 190)
	local TARP_GREEN = Color3.fromRGB(60, 150, 80)
	local TARP_ORANGE = Color3.fromRGB(230, 130, 40)
	local TARP_GREY = Color3.fromRGB(170, 160, 140)
	local WOOD_C = Color3.fromRGB(150, 110, 70)
	local TRAY = Color3.fromRGB(200, 176, 130)
	local BASKET_C = Color3.fromRGB(176, 128, 74)
	local YARD = Color3.fromRGB(160, 158, 152)
	local CONC_LIGHT = Color3.fromRGB(190, 188, 182)
	local YELLOW = Color3.fromRGB(235, 200, 80)
	local STEEL = Color3.fromRGB(120, 124, 130)
	local DARK = Color3.fromRGB(40, 42, 48)
	local TRIKE_RED = Color3.fromRGB(190, 50, 44)
	local TRIKE_BLUE = Color3.fromRGB(46, 96, 170)
	local TOMATO = Color3.fromRGB(200, 50, 40)
	local ONION = Color3.fromRGB(120, 60, 130)
	local PEPPER = Color3.fromRGB(70, 150, 60)
	local SQUASH = Color3.fromRGB(230, 130, 40)
	local BANANA = Color3.fromRGB(240, 210, 60)
	local GREENS = Color3.fromRGB(60, 130, 50)
	local FISH = Color3.fromRGB(190, 195, 200)
	local PLAS, GLASS, CONC, WOOD = Enum.Material.SmoothPlastic, Enum.Material.Glass, Enum.Material.Concrete, Enum.Material.Wood
	local METAL, FABRIC = Enum.Material.Metal, Enum.Material.Fabric
	local TARPS = { TARP_BLUE, TARP_GREEN, TARP_ORANGE }
	local PRODUCE_COLS = { TOMATO, ONION, PEPPER, SQUASH, BANANA, GREENS, FISH }
	local PRICES = { "KAMATIS\nP 80/kg", "SIBUYAS\nP 120/kg", "SAGING\nP 60/kg", "TALONG\nP 50/kg", "MANGGA\nP 90/kg", "ISDA\nP 150/kg" }

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

	-- The stall grid (market frame): local X = north, local Z = east (toward the aisle). Stall i alternates between a
	-- produce counter (tray and balls) and a basket counter, so the two props interleave across the yard.
	-- Slice 17: five rows 17 apart (was 20, out to z 94), so the yard is tighter and sits closer to the lean-to frontage.
	local stalls = {}
	local function addStalls(xs, zs)
		for _, x in ipairs(xs) do
			for _, z in ipairs(zs) do
				table.insert(stalls, { x = x, z = z })
			end
		end
	end
	addStalls({ 30, 46, 62 }, { 12, 29, 46, 63, 80 }) -- north block (east of the hall, north of the aisle)
	addStalls({ -22, -38, -54, -70 }, { 29, 46, 63, 80 }) -- south block (south of the aisle, past the stair)
	for i, s in ipairs(stalls) do
		s.produce = (i % 2 == 1)
		s.tarp = TARPS[(i - 1) % #TARPS + 1]
		s.price = PRICES[(i - 1) % #PRICES + 1]
	end

	local terrainParams = RaycastParams.new()
	terrainParams.FilterType = Enum.RaycastFilterType.Include
	terrainParams.FilterDescendantsInstances = { workspace.Terrain }
	local function groundAt(p)
		local r = workspace:Raycast(V(p.X, 400, p.Z), V(0, -800, 0), terrainParams)
		assert(r, string.format("site02: no terrain at (%.1f, %.1f)", p.X, p.Z))
		return r.Position.Y
	end

	-- A label on the part's Back face (the frontage side in MK, so it reads from the east). Pass fixedSize (pixels) for one long
	-- line at a set size (the name band): TextScaled with wrapping off rendered it at a tenth of the band's width.
	local function signGui(part, text, color, ppstud, fixedSize)
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
		if fixedSize then
			t.TextScaled = false
			t.TextSize = fixedSize
			t.TextWrapped = false
		else
			t.TextScaled = true
			t.TextWrapped = true
		end
		t.Font = Enum.Font.GothamBlack
		t.Text = text
		t.Parent = g
	end

	-- One unparented piece built in the market frame. Parts are counted against the budget as they are made.
	local function build(name, fn)
		local model = Instance.new("Model")
		model.Name = name
		local ctx = BuildKit.new(model, MK, { budget = PART_BUDGET - used })
		fn(ctx)
		ctx:flush()
		used += ctx:count()
		return model
	end

	------------------------------------------------------------------ Hall: two storeys, 150 long, 90 deep (local z -90..0), low-pitch roof
	local DEPTH = 90 -- OSM: about 40 m at massScale 3 is 120; 90 keeps the footprint inside x -440
	local RISE = 6.3 -- ridge height over the eaves: a low pitch, about 8 degrees
	local HALF = DEPTH / 2
	local SLOPE_LEN = math.sqrt(HALF * HALF + RISE * RISE)
	local PITCH = math.atan2(RISE, HALF)
	local P = 150 / 16 -- bay pitch: 16 bays with a maroon pilaster on each of the 17 bay lines
	local function bayX(k) return -75 + P * (k + 0.5) end
	local function pilX(k) return -75 + P * k end
	local GALLERY_BAYS = 3 -- bays k = 0..3 (south, lx -75..-37.5) carry the upper gallery instead of shuttered windows

	local function buildHall(ctx)
		ctx:part("HallBody", V(150, 24, DEPTH), CF(0, 12, -HALF), WALL, PLAS)
		-- two-tone wall: the upper storey is cladded lighter than the ground storey
		ctx:part("UpperWall", V(150, 12, 0.3), CF(0, 18, 0.15), WALL_LIGHT, PLAS)
		ctx:part("StoreyBand", V(150.6, 0.9, 1.5), CF(0, 12, 0.75), WALL_LIGHT, PLAS)
		for k = 0, 16 do
			ctx:part("Pilaster", V(1.6, 24, 1.2), CF(pilX(k), 12, 0.6), MAROON, PLAS)
			ctx:part("PilasterCap", V(2.2, 1, 1.6), CF(pilX(k), 23.5, 0.6), MAROON, PLAS)
		end
		for k = 0, 15 do
			local lc = bayX(k)
			-- ground storey: arched glazed bays with a grid (in the south third they stand behind the portico)
			ctx:arch("ArchBay", {
				width = 5.6, height = 9, depth = 1.2, wallWidth = P - 1.6, wallHeight = 12,
				cframe = CF(lc, 6, 0.6), color = WALL, material = PLAS,
			})
			for _, p in ipairs(ctx:window("BayGlass", 5.2, 8.6, 0.4, CF(lc, 0, 0.6), GLASSC, GLASS)) do
				p.Transparency = 0.3
			end
			ctx:window("BayBack", 5.4, 8.8, 0.2, CF(lc, 0, 0.2), DARK_GLASS, PLAS)
			ctx:part("BayMullion", V(0.25, 8.6, 0.5), CF(lc, 4.3, 0.85), WALL_LIGHT, PLAS)
			ctx:part("BayTransom", V(5.2, 0.25, 0.5), CF(lc, 4.2, 0.85), WALL_LIGHT, PLAS)
			if k > GALLERY_BAYS then
				-- upper storey: open window with two tilted grey-brown shutter awnings (the 2014 photo shows them in pairs)
				ctx:part("UpperBack", V(6, 5.6, 0.2), CF(lc, 16.2, 0.1), DARK_GLASS, PLAS)
				ctx:part("UpperGlass", V(6, 5.6, 0.4), CF(lc, 16.2, 0.2), GLASSC, GLASS).Transparency = 0.3
				ctx:part("UpperSill", V(6.8, 0.4, 1), CF(lc, 13.1, 0.6), WALL_LIGHT, PLAS)
				ctx:part("Shutter", V(6.6, 0.25, 2.6), CF(lc, 18.4, 1.5) * ANG(0.45, 0, 0), SHUTTER, PLAS)
				ctx:part("Shutter", V(6.6, 0.25, 2.6), CF(lc, 15.2, 1.5) * ANG(0.45, 0, 0), SHUTTER, PLAS)
			else
				ctx:part("GalleryOpening", V(6, 5, 0.3), CF(lc, 16, 0.85), DARK_GLASS, PLAS)
			end
		end
		-- weathering: red-oxide stains on the spandrels above some arches (colour only, no photo textures)
		for _, k in ipairs({ 5, 7, 8, 11, 13, 14 }) do
			ctx:part("RustPatch", V(5, 2.2, 0.15), CF(bayX(k), 10.9, 1.28), RUST_PATCH, PLAS)
		end

		-- name band: tall enough that the blue capitals fill it; it runs from the stair end to the north end
		local band = ctx:part("NameBand", V(120, 5, 0.6), CF(15, 22, 1.3), WHITE, PLAS)
		signGui(band, "CANDIDO B. LOPEZ MEMORIAL PUBLIC MARKET", BLUE_TEXT, 16, 60)
		-- the blue ad billboard over the south gallery: a plain panel, no text (brands are never reproduced)
		ctx:part("Billboard", V(30, 5, 0.6), CF(-60.5, 22, 1.3), BILLBOARD, PLAS)

		-- low-pitch blue-grey standing-seam roof, ridge along the hall, gables closing the ends
		ctx:part("RoofEdge", V(152, 1.6, 0.8), CF(0, 25, 0.4), ROOF_BLUE, PLAS)
		for _, side in ipairs({ { 1, -HALF / 2 }, { -1, -HALF * 1.5 } }) do
			-- side 1 slopes down toward the frontage (+Z), side -1 down toward the rear
			local cf = CF(0, 24.6 + RISE / 2, side[2]) * ANG(side[1] * PITCH, 0, 0)
			ctx:part("RoofSlope", V(152, 0.8, SLOPE_LEN + 1), cf, ROOF_SLATE, PLAS)
			for j = 0, 14 do
				ctx:part("RoofSeam", V(0.35, 0.18, SLOPE_LEN + 1), cf * CF(-70 + 10 * j, 0.5, 0), ROOF_SEAM, PLAS)
			end
		end
		ctx:gable("GableN", DEPTH, RISE + 0.3, 0.8, CF(75.4, 24, -HALF) * ANG(0, PI / 2, 0), WALL, PLAS)
		ctx:gable("GableS", DEPTH, RISE + 0.3, 0.8, CF(-75.4, 24, -HALF) * ANG(0, PI / 2, 0), WALL, PLAS)

		-- sides and rear are not photographed: plain walls with a maroon base and a few windows
		ctx:part("SideBase", V(0.4, 3, DEPTH), CF(75.2, 1.5, -HALF), MAROON, PLAS)
		ctx:part("SideBase", V(0.4, 3, DEPTH), CF(-75.2, 1.5, -HALF), MAROON, PLAS)
		ctx:part("RearBase", V(150, 3, 0.4), CF(0, 1.5, -DEPTH - 0.2), MAROON, PLAS)
		for j = 0, 7 do
			ctx:part("RearWindow", V(5, 4, 0.3), CF(-65 + 18.5 * j, 16, -DEPTH - 0.15), DARK_GLASS, PLAS)
		end
		for _, side in ipairs({ -1, 1 }) do
			for _, z in ipairs({ -22, -45, -68 }) do
				ctx:part("EndWindow", V(0.3, 4, 5), CF(side * 75.15, 16, z), DARK_GLASS, PLAS)
			end
		end
	end

	------------------------------------------------------------------ South upper gallery on round portico columns (the 2014 photo's left third)
	local function buildGallery(ctx)
		-- deck at y 12.05, lx -76..-40, projecting 7 from the facade; its cream fascia hangs below the front edge
		ctx:part("UpperGallery", V(36, 0.6, 7), CF(-58, 11.75, 3.5), CONC_LIGHT, CONC)
		ctx:part("GalleryFascia", V(36, 1.4, 0.5), CF(-58, 11.2, 7.25), WALL_LIGHT, PLAS)
		ctx:part("GalleryRail", V(36, 0.3, 0.3), CF(-58, 15.2, 6.85), STEEL, METAL)
		for x = -75, -42, 3 do
			ctx:part("GalleryPost", V(0.2, 3, 0.2), CF(x, 13.55, 6.85), STEEL, METAL)
		end
		-- the weathered maroon wall behind it, with dark openings, and the dark shed awning over it
		ctx:part("GalleryWall", V(36, 6.8, 0.4), CF(-58, 16, 0.5), GALLERY_WALL, PLAS)
		ctx:part("GalleryAwning", V(37, 0.3, 8.5), CF(-58, 18.6, 4.2) * ANG(0.2, 0, 0), AWNING_DARK, METAL)
		-- round yellow columns carry the deck (the south end of the stair lands at lx -46, so the last column stands at -50)
		for _, x in ipairs({ -74, -66, -58, -50 }) do
			ctx:cyl("PorticoColumn", V(11.9, 1.3, 1.3), CF(x, 5.95, 6.4) * ANG(0, 0, PI / 2), YELLOW, PLAS)
		end
	end

	------------------------------------------------------------------ Exterior stair: runs along the facade, rises to the south, roofed over its full length
	local function buildStair(ctx)
		local S = V(-22, 0, 9) -- foot, in the north end of the stair run, on the yard side
		local T = V(-46, 0, 4) -- head, landing on the gallery deck at the upper level
		local dv = T - S
		local L = dv.Magnitude
		local dir = dv / L
		local perp = V(-dir.Z, 0, dir.X)
		local run = L / 12
		for i = 1, 12 do -- twelve 1-stud risers
			local c = S + dir * ((i - 0.5) * run)
			local centre = V(c.X, i / 2, c.Z)
			ctx:part("Step" .. i, V(4, i, run), CFrame.lookAt(centre, centre + dir), CONC_LIGHT, CONC)
		end
		for _, side in ipairs({ -2, 2 }) do
			-- solid side panel along the flight, then the rail on top of it
			local sa = S + perp * (side * 1.1) + V(0, 0.6, 0)
			local sb = T + perp * (side * 1.1) + V(0, 12.0, 0)
			ctx:part("StairStringer", V(0.4, 2.2, (sb - sa).Magnitude + 1), CFrame.lookAt((sa + sb) / 2, sb), CONC_LIGHT, CONC)
			local a = S + perp * side + V(0, 3, 0)
			local b = T + perp * side + V(0, 15, 0)
			ctx:part("StairRail", V(0.25, 0.25, (b - a).Magnitude), CFrame.lookAt((a + b) / 2, b), STEEL, METAL)
			for j = 1, 5 do
				local p = a:Lerp(b, j / 6)
				ctx:part("RailPost", V(0.25, 3, 0.25), CF(p.X, p.Y - 1.5, p.Z), STEEL, METAL)
			end
		end
		-- Roof over the whole run, on round yellow piers (three each side).
		local c0 = S + V(0, 10, 0)
		local c1 = T + V(0, 19, 0)
		ctx:part("StairCover", V(6.4, 0.35, (c1 - c0).Magnitude + 1), CFrame.lookAt((c0 + c1) / 2, c1), RUST, PLAS)
		for _, f in ipairs({ 0.04, 0.5, 0.96 }) do
			for _, side in ipairs({ -2.7, 2.7 }) do
				local p = S:Lerp(T, f) + perp * side
				local h = 9.7 + 9 * f
				ctx:cyl("StairPier", V(h, 1.3, 1.3), CF(p.X, h / 2, p.Z) * ANG(0, 0, PI / 2), YELLOW, PLAS)
			end
		end
	end

	------------------------------------------------------------------ End balcony at the north end of the upper floor
	local function buildBalcony(ctx)
		ctx:part("BalconyDeck", V(22, 0.6, 6), CF(63, 12.3, 3), CONC_LIGHT, CONC)
		ctx:part("BalconyRail", V(22, 0.3, 0.3), CF(63, 15.6, 6), STEEL, METAL)
		for x = 53, 73, 2 do
			ctx:part("Baluster", V(0.2, 3, 0.2), CF(x, 14.1, 6), STEEL, METAL)
		end
		for _, x in ipairs({ 53, 58, 63, 68, 73 }) do
			ctx:cyl("BalconyColumn", V(12, 1, 1), CF(x, 6, 6) * ANG(0, 0, PI / 2), YELLOW, PLAS)
		end
		-- the pink-maroon spandrel over the end bays
		ctx:part("EndBayWall", V(22, 2.6, 0.3), CF(63, 10.7, 1.35), END_BAY, PLAS)
	end

	------------------------------------------------------------------ Lean-to tin-roof stalls along the ground frontage (north of the stair)
	local function buildFront(ctx)
		local x0, x1, n = -16, 50, 8
		local step = (x1 - x0) / n
		for i = 1, n do
			local a = x0 + step * (i - 1)
			local cx = a + step / 2
			ctx:part("LeanRoof", V(step, 0.3, 6), CF(cx, 9.1, 4.2) * ANG(0.165, 0, 0), (i % 2 == 1) and RUST or TIN, PLAS)
			ctx:part("LeanCounter", V(step - 1, 3.5, 2), CF(cx, 1.75, 6), WOOD_C, WOOD)
		end
		for i = 0, n do
			ctx:part("LeanPost", V(0.5, 8.6, 0.5), CF(x0 + step * i, 4.3, 7), WOOD_C, WOOD)
		end
	end

	------------------------------------------------------------------ Concrete trading apron: the south block (keeps off the aisle)
	local function buildYard(ctx)
		ctx:part("YardSlab", V(62, 0.3, 40), CF(-39, 0.15, 74), YARD, CONC)
	end

	------------------------------------------------------------------ Stall frames: counter, four posts, tarp canopy
	local function buildStalls(ctx)
		for _, s in ipairs(stalls) do
			local x, z = s.x, s.z
			ctx:part("Counter", V(7, 3.5, 2.5), CF(x, 1.75, z), WOOD_C, WOOD)
			for _, dx in ipairs({ -3.2, 3.2 }) do
				ctx:part("FrontPost", V(0.5, 9, 0.5), CF(x + dx, 4.5, z + 1.6), WOOD_C, WOOD)
				ctx:part("BackPost", V(0.5, 9, 0.5), CF(x + dx, 4.5, z - 1.6), WOOD_C, WOOD)
			end
			ctx:part("Canopy", V(8.2, 0.3, 4.8), CF(x, 9, z) * ANG(0.08, 0, 0), s.tarp, PLAS)
		end
	end

	------------------------------------------------------------------ Carts, tarp heaps, umbrellas, crate stacks, tricycles
	local function buildExtras(ctx)
		local function cart(x, z)
			ctx:part("CartBed", V(4.2, 0.8, 6), CF(x, 2.4, z), WOOD_C, WOOD)
			for _, dz in ipairs({ -2.9, 2.9 }) do
				ctx:part("CartSide", V(4.2, 1.6, 0.3), CF(x, 3.6, z + dz), WOOD_C, WOOD)
			end
			for _, dx in ipairs({ -2.1, 2.1 }) do
				ctx:cyl("CartWheel", V(0.6, 2.4, 2.4), CF(x + dx, 1.2, z), DARK, WOOD)
			end
		end
		cart(70, 40)
		cart(-62, 54.5)
		for _, h in ipairs({ { 66, 20 }, { -66, 88 }, { -30, 17 } }) do
			ctx:ball("TarpHeap", 5, CF(h[1], 0.3, h[2]), TARP_GREY, FABRIC)
		end
		for _, u in ipairs({ { 14, 88, Color3.fromRGB(200, 60, 60) }, { -14, 66, WHITE } }) do
			ctx:part("UmbrellaPole", V(0.3, 6, 0.3), CF(u[1], 3, u[2]), STEEL, METAL)
			ctx:cyl("UmbrellaTop", V(0.8, 5.5, 5.5), CF(u[1], 6.4, u[2]) * ANG(0, 0, PI / 2), u[3], PLAS)
		end
		for _, c in ipairs({ { 11, 66 }, { -11, 80 } }) do
			for lvl = 0, 2 do
				ctx:part("Crate", V(2.4, 1.4, 1.8), CF(c[1], 0.7 + 1.4 * lvl, c[2]), WOOD_C, WOOD)
			end
		end
		-- tricycle taxis at the yard's mouth, nose to the north: sidecar cab, roof on four posts, three wheels
		local function trike(x, z, col)
			ctx:part("TricycleBody", V(7, 2, 3), CF(x, 2.8, z), col, PLAS)
			ctx:part("TricycleRoof", V(7.4, 0.3, 4.2), CF(x - 0.4, 6.9, z + 0.3), ROOF_GREY, PLAS)
			for _, dx in ipairs({ -3.1, 2.7 }) do
				for _, dz in ipairs({ -1.5, 2 }) do
					ctx:part("TricyclePost", V(0.25, 3.9, 0.25), CF(x + dx, 4.85, z + dz), STEEL, METAL)
				end
			end
			ctx:cyl("TricycleWheel", V(0.5, 2.2, 2.2), CF(x + 3.2, 1.1, z - 1.4) * ANG(0, PI / 2, 0), DARK, PLAS)
			ctx:cyl("TricycleWheel", V(0.5, 2.2, 2.2), CF(x - 3, 1.1, z - 1.4) * ANG(0, PI / 2, 0), DARK, PLAS)
			ctx:cyl("TricycleWheel", V(0.5, 2.2, 2.2), CF(x - 1, 1.1, z + 2) * ANG(0, PI / 2, 0), DARK, PLAS)
		end
		trike(32, 98, TRIKE_RED)
		trike(-30, 99, TRIKE_BLUE)
		trike(-52, 98, TRIKE_RED)
	end

	------------------------------------------------------------------ Baskets: on the basket counters and on the ground
	local function buildBaskets(ctx)
		for _, s in ipairs(stalls) do
			if not s.produce then
				for _, dx in ipairs({ -2.2, 0, 2.2 }) do
					ctx:cyl("Basket", V(1.0, 1.8, 1.8), CF(s.x + dx, 4.0, s.z - 0.2) * ANG(0, 0, PI / 2), BASKET_C, WOOD)
				end
				ctx:cyl("GroundBasket", V(0.9, 1.6, 1.6), CF(s.x + 5.4, 0.45, s.z + 0.4) * ANG(0, 0, PI / 2), BASKET_C, WOOD)
				ctx:wedge("DisplayCrate", V(2.6, 1.6, 2.0), CF(s.x + 5.4, 0.8, s.z - 2.0), WOOD_C, WOOD)
			end
		end
	end

	------------------------------------------------------------------ Produce: coloured balls on trays, on the counter and the ground
	local function buildProduce(ctx)
		for i, s in ipairs(stalls) do
			if s.produce then
				local col = PRODUCE_COLS[(i - 1) % #PRODUCE_COLS + 1]
				ctx:part("ProduceTray", V(5.6, 0.25, 2.0), CF(s.x, 3.625, s.z - 0.2), TRAY, WOOD)
				for _, dz in ipairs({ -0.6, 0.5 }) do
					for j = 0, 4 do
						ctx:ball("Produce", 0.9, CF(s.x - 2.2 + 1.1 * j, 4.2, s.z + dz), col, PLAS)
					end
				end
				ctx:part("GroundTray", V(3.6, 0.25, 2.6), CF(s.x + 5.4, 0.125, s.z + 0.4), TRAY, WOOD)
				for j = -1, 1 do
					ctx:ball("GroundProduce", 0.8, CF(s.x + 5.4 + 0.8 * j, 0.65, s.z + 0.4), col, PLAS)
				end
			end
		end
	end

	------------------------------------------------------------------ Price signs: one board per stall, plus the sample board
	local function buildSigns(ctx)
		for _, s in ipairs(stalls) do
			local board = ctx:part("PriceBoard", V(4.2, 1.4, 0.25), CF(s.x, 4.7, s.z + 1.65), WHITE, PLAS)
			signGui(board, s.price, DARK, 40)
		end
		ctx:part("SamplePost", V(0.4, 6, 0.4), CF(10.5, 3, 95.5), STEEL, METAL)
		ctx:part("SamplePost", V(0.4, 6, 0.4), CF(21.5, 3, 95.5), STEEL, METAL)
		local sample = ctx:part("SampleBoard", V(12, 4, 0.3), CF(16, 6, 95.5), WHITE, PLAS)
		signGui(sample, "SAMPLE PRICES - FOR ILLUSTRATION", DARK, 30)
	end

	------------------------------------------------------------------ Vendors: built exactly like site01 buildPeople.
	-- CreateHumanoidModelFromDescription yields, so this runs as its own step before the swap.
	local function buildVendors(folder)
		local skins = { Color3.fromRGB(224, 172, 130), Color3.fromRGB(198, 134, 92), Color3.fromRGB(141, 85, 60), Color3.fromRGB(241, 194, 125) }
		local shirts = { Color3.fromRGB(200, 60, 60), Color3.fromRGB(60, 100, 170), Color3.fromRGB(230, 200, 80), Color3.fromRGB(90, 150, 100) }
		-- { local x, local z, yaw }: vendors stand 2.6 behind a counter and face east (yaw PI) toward the aisle.
		local spots = {
			{ 30, 9.4, PI }, { 46, 26.4, PI }, { 62, 43.4, PI }, { -22, 26.4, PI },
			{ -38, 43.4, PI }, { -54, 60.4, PI }, { -70, 77.4, PI }, { 18, 56, PI / 2 },
		}
		for i, s in ipairs(spots) do
			local desc = Instance.new("HumanoidDescription")
			desc.HeadColor = skins[(i - 1) % #skins + 1]
			local shirt = shirts[(i - 1) % #shirts + 1]
			desc.TorsoColor, desc.LeftArmColor, desc.RightArmColor = shirt, shirt, shirt
			desc.LeftLegColor, desc.RightLegColor = Color3.fromRGB(50, 50, 70), Color3.fromRGB(50, 50, 70)
			local rig = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
			desc:Destroy()
			rig.Name = "Vendor" .. i
			for _, d in ipairs(rig:GetDescendants()) do
				if d:IsA("BasePart") then d.Anchored = false end
			end
			local hrp = rig:WaitForChild("HumanoidRootPart")
			local hum = rig:FindFirstChildOfClass("Humanoid")
			hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			hum.WalkSpeed = 0
			rig.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
			rig:SetAttribute("SiteId", row.id)
			local frame = MK * CF(s[1], 0, s[2]) * ANG(0, s[3], 0)
			local p = frame.Position
			rig:PivotTo(CF(p.X, groundAt(p) + 3, p.Z) * frame.Rotation)
			hrp.Anchored = true
			rig.Parent = folder
		end
	end

	------------------------------------------------------------------ Build, then swap
	local plan = {} -- { inst, into }: parents are listed before their children
	local function add(inst, into)
		table.insert(plan, { inst = inst, into = into })
		return inst
	end
	local function newModel(name)
		local m = Instance.new("Model")
		m.Name = name
		return m
	end
	local function newFolder(name)
		local f = Instance.new("Folder")
		f.Name = name
		return f
	end

	local ok, err = pcall(function()
		local structure = add(newFolder("Structure"), site)
		add(build("Hall", buildHall), structure)
		add(build("Gallery", buildGallery), structure)
		add(build("ExteriorStair", buildStair), structure)
		add(build("EndBalcony", buildBalcony), structure)
		add(build("FrontStalls", buildFront), structure)
		add(build("Yard", buildYard), site)

		local marketM = add(newModel("MarketStalls"), site)
		add(build("Stalls", buildStalls), marketM)
		add(build("Extras", buildExtras), marketM)

		local basketsM = add(newModel("Baskets"), site)
		add(build("BasketsAll", buildBaskets), basketsM)

		local produceM = add(newModel("Produce"), site)
		add(build("ProduceAll", buildProduce), produceM)

		local signsM = add(newModel("PriceSigns"), site)
		add(build("SignsAll", buildSigns), signsM)

		local vendors = add(newFolder("VendorNPCs"), site)
		buildVendors(vendors)
		used += countParts(vendors)

		assert(used <= PART_BUDGET, string.format("site02: %d parts exceeds the %d budget", used, PART_BUDGET))
	end)
	if not ok then
		for _, e in ipairs(plan) do e.inst:Destroy() end
		error("site02: build failed, the placeholder Block was left untouched: " .. tostring(err), 0)
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
		"site02: the site pivot changed during the build")

	return {
		parts = countParts(site),
		keptParts = keptParts,
		builtParts = used - keptParts,
	}
end
