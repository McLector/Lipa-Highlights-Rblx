-- site08: Mount Malarayat Golf & Country Club (Slice 10). Studio copy: ServerStorage.Builders.site08; run with
--   require(game.ServerStorage.Builders.site08:Clone())()
-- Needs Workspace.Sites.Site08_Malarayat with its kept children (Guide, InfoPanel, JeepStop, JeepSignPole, JeepSign, Jeepney).
-- IDEMPOTENT: replaces Block, Structure, Clubhouse, MountainBackdrop and LeisureSpacesPanel. The kept children are left alone.
-- No terrain writes. Brief: briefs/site08.md.
-- FRAMES: the site pivot is yawed NW and sits on a slope, so it is NOT used as the origin.
--   ORIGIN = (620, PADY, 780). CFL = fromMatrix(ORIGIN, (-s,0,s), (0,1,0)): local +X = SW, local +Z = NW (the frontage), +Y up.
--   World = (620 - s*(lx+lz), PADY + ly, 780 + s*(lx-lz)). World-space sections use an identity origin.
-- Fail-safe order as in site07: everything is built into unparented chunks first; only then are the old children
-- deleted and the new containers filled chunk by chunk with task.wait(). An error before that leaves the Block untouched.
return function()
	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
	local BuildKit = require(game.ServerStorage.BuildKit:Clone())

	local V, CF, ANG = Vector3.new, CFrame.new, CFrame.Angles
	local PI = math.pi
	local row = SiteData.byId(8)
	assert(row and row.facing == "NW", "site08: SiteData row 8 is missing or not facing NW")
	local sites = workspace:FindFirstChild("Sites")
	local site = sites and sites:FindFirstChild("Site08_Malarayat")
	assert(site, "site08: Workspace.Sites.Site08_Malarayat not found (run builders/placeholders first)")
	local pivotBefore = site:GetPivot()
	assert(math.abs(pivotBefore.Position.X - 560) < 1e-3 and math.abs(pivotBefore.Position.Z - 720) < 1e-3, "site08: pivot is not at (560, 19.8, 720)")

	local PADY = 20.0
	local ORIGIN = V(620, PADY, 780)
	local S = 0.70711
	local CFL = CFrame.fromMatrix(ORIGIN, V(-S, 0, S), V(0, 1, 0))
	local ID = CFrame.new()
	local PART_BUDGET = 2500
	local REPLACED = { Block = true, Structure = true, Clubhouse = true, MountainBackdrop = true, LeisureSpacesPanel = true }

	-- Colours (brief table) and materials.
	local TERRA = Color3.fromRGB(200, 84, 52) -- the photos' roof is a bright orange-red; the first pass (170,70,45) read dull pink
	local TERRA_CAP = Color3.fromRGB(168, 64, 40)
	local OFFW = Color3.fromRGB(232, 228, 214)
	local TAN = Color3.fromRGB(176, 160, 130)
	local MINT = Color3.fromRGB(150, 196, 170)
	local STONE_J = Color3.fromRGB(128, 114, 90)
	local BROWN = Color3.fromRGB(130, 90, 60)
	local GLASSC = Color3.fromRGB(150, 190, 200)
	local CONC = Color3.fromRGB(186, 178, 166)
	local BRICK = Color3.fromRGB(160, 70, 50)
	local CREAM = Color3.fromRGB(226, 214, 190)
	local AQUA = Color3.fromRGB(60, 180, 215)
	local CART_C = Color3.fromRGB(236, 226, 190)
	local CART_G = Color3.fromRGB(60, 120, 80)
	local CART_T = Color3.fromRGB(190, 160, 110)
	local DARK = Color3.fromRGB(74, 70, 66)
	local PINE = Color3.fromRGB(40, 92, 52)
	local PTRUNK = Color3.fromRGB(120, 98, 70)
	local FROND = Color3.fromRGB(50, 110, 50)
	local SHRUB = Color3.fromRGB(46, 100, 50)
	local MTN = Color3.fromRGB(70, 104, 96)
	local MTN_D = Color3.fromRGB(52, 82, 76)
	local TIMBER = Color3.fromRGB(150, 104, 64)
	local WHITE_M = Color3.fromRGB(245, 245, 240)
	local BLACK = Color3.fromRGB(30, 30, 34)
	local FLAG_R = Color3.fromRGB(220, 40, 40)
	local BOARD = Color3.fromRGB(240, 236, 224)
	local TEXT = Color3.fromRGB(40, 60, 50)
	local SMOOTH, SLATE, STONE = Enum.Material.SmoothPlastic, Enum.Material.Slate, Enum.Material.Limestone
	local GLASSM, WOODM, CONCM = Enum.Material.Glass, Enum.Material.Wood, Enum.Material.Concrete
	local BRICKM, PEBM, GRASSM = Enum.Material.Brick, Enum.Material.Pebble, Enum.Material.LeafyGrass
	local METAL = Enum.Material.Metal

	-- Ground read: the first terrain surface under (x, z), ray from y 200 straight down.
	local terrainParams = RaycastParams.new()
	terrainParams.FilterType = Enum.RaycastFilterType.Include
	terrainParams.FilterDescendantsInstances = { workspace.Terrain }
	local function gnd(x, z)
		local r = workspace:Raycast(V(x, 200, z), V(0, -400, 0), terrainParams)
		return r and r.Position.Y or PADY
	end

	-- Local (lx, ly, lz) -> world position.
	local function lw(lx, ly, lz)
		return ORIGIN + V(-S * (lx + lz), ly, S * (lx - lz))
	end

	-- Axis-aligned box in the ctx frame, x0..x1 / y0..y1 / z0..z1 (CFrame-free so it works in both frames).
	local function box(ctx, name, x0, x1, y0, y1, z0, z1, color, material)
		return ctx:part(name, V(x1 - x0, y1 - y0, z1 - z0), CF((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), color, material)
	end
	-- Vertical cylinder from y0 to y1 centred on (x, z), in the ctx frame.
	local function vcyl(ctx, name, x, z, y0, y1, dia, color, material)
		return ctx:cyl(name, V(y1 - y0, dia, dia), CF(x, (y0 + y1) / 2, z) * ANG(0, 0, PI / 2), color, material)
	end
	local function ball(ctx, name, x, y, z, dia, color, material)
		return ctx:ball(name, dia, CF(x, y, z), color, material)
	end

	-- Containers (unparented until the swap). Chunks are parented into them one at a time.
	local clubhouse = Instance.new("Model")
	clubhouse.Name = "Clubhouse"
	local backdrop = Instance.new("Model")
	backdrop.Name = "MountainBackdrop"
	local panel = Instance.new("Model")
	panel.Name = "LeisureSpacesPanel"
	local structure = Instance.new("Folder")
	structure.Name = "Structure"
	local subs = {}
	local function sub(name)
		local m = Instance.new("Model")
		m.Name = name
		table.insert(subs, m)
		return m
	end

	-- Kept children count against the budget; the rest of the site is rebuilt.
	local keptParts = 0
	local function countParts(inst)
		local n = inst:IsA("BasePart") and 1 or 0
		for _, d in ipairs(inst:GetDescendants()) do
			if d:IsA("BasePart") then n += 1 end
		end
		return n
	end
	for _, c in ipairs(site:GetChildren()) do
		if not REPLACED[c.Name] then keptParts += countParts(c) end
	end
	local used = keptParts

	-- Runs fn(ctx) with a fresh BuildKit ctx, flushes its chunks into an unparented holder, and records each chunk
	-- with the container it belongs to. Nothing reaches the DataModel here.
	local plan = {}
	local function section(origin, dest, fn)
		local holder = Instance.new("Model")
		local ctx = BuildKit.new(holder, origin, { budget = PART_BUDGET - used })
		fn(ctx)
		ctx:flush()
		used += ctx:count()
		for _, chunk in ipairs(holder:GetChildren()) do
			table.insert(plan, { chunk = chunk, dest = dest })
		end
		return dest
	end

	------------------------------------------------------------------ Clubhouse (container, local frame CFL; ly from PADY)
	local function buildClubhouse(ctx)
		-- Foundation (buried, seats the block on the slope) and the stone plinth to ly 4, proud 0.4 on the front.
		box(ctx, "Foundation", -50, 50, -8, 0, -20, 16.4, TAN, STONE)
		box(ctx, "Plinth", -50, 50, 0, 4, -20, 16.4, TAN, STONE)
		-- Arcade floor, out to the balcony edge and under the entry gable.
		box(ctx, "ArcadeFloor", -50, 50, -8, 4, 16.4, 30, TAN, STONE)
		-- Ground floor to ly 12: white at the rear and sides, tan cladding on the front face (lz 15.6..16.2).
		box(ctx, "GroundWall", -50, 50, 4, 12, -20, 15.6, OFFW, SMOOTH)
		box(ctx, "GroundCladding", -50, 50, 4, 12, 15.6, 16.2, TAN, STONE)
		-- Upper floor ly 12..24, white.
		box(ctx, "UpperWall", -50, 50, 12, 24, -20, 16, OFFW, SMOOTH)
		-- Mint pilasters on the front every 12.5 (outside the entry gable) and a mint band under the upper windows.
		for _, x in ipairs({ -37.5, -25, 25, 37.5 }) do
			box(ctx, "Pilaster", x - 0.6, x + 0.6, 4, 12, 16.2, 16.8, MINT, SMOOTH)
		end
		box(ctx, "MintBand", -50, 50, 11.4, 11.8, 16.2, 16.6, MINT, SMOOTH)
		-- Cut-stone courses on the cladding and mint surrounds on the six ground-floor windows (cart-side photo).
		for _, y in ipairs({ 5.5, 7, 8.5, 10 }) do
			box(ctx, "StoneCourse", -50, 50, y, y + 0.15, 16.2, 16.4, STONE_J, STONE)
		end
		for _, x in ipairs({ -43.75, -31.25, -18.75, 18.75, 31.25, 43.75 }) do
			box(ctx, "WindowTrim", x - 4.6, x - 4, 4.4, 11.6, 15.9, 16.9, MINT, SMOOTH)
			box(ctx, "WindowTrim", x + 4, x + 4.6, 4.4, 11.6, 15.9, 16.9, MINT, SMOOTH)
			box(ctx, "WindowTrim", x - 4.6, x + 4.6, 11, 11.6, 15.9, 16.9, MINT, SMOOTH)
			box(ctx, "WindowTrim", x - 4.6, x + 4.6, 4.4, 5, 15.9, 16.9, MINT, SMOOTH)
		end
		-- Balcony slab (front, except the entry gable), slim columns under it, and eight separate rail segments.
		box(ctx, "BalconySlabL", -50, -14, 12, 12.8, 16, 21, OFFW, SMOOTH)
		box(ctx, "BalconySlabR", 14, 50, 12, 12.8, 16, 21, OFFW, SMOOTH)
		for _, x in ipairs({ -37.5, -25, 25, 37.5 }) do
			box(ctx, "BalconyColumn", x - 0.5, x + 0.5, 4, 12, 20, 21, OFFW, SMOOTH)
		end
		for _, seg in ipairs({ { -49.5, -44.5 }, { -43.5, -38.5 }, { -36.5, -26.5 }, { -23.5, -14.5 }, { 14.5, 23.5 }, { 26.5, 36.5 }, { 38.5, 43.5 }, { 44.5, 49.5 } }) do
			box(ctx, "ClubhouseBalconyRail", seg[1], seg[2], 12.8, 15.8, 20.8, 21.4, OFFW, SMOOTH)
		end
		-- Windows: six bays (|lx| >= 18.75) on each floor, on the NW face. Centre-bay and side glass are named differently.
		for _, x in ipairs({ -43.75, -31.25, -18.75, 18.75, 31.25, 43.75 }) do
			box(ctx, "ClubhouseWindow", x - 4, x + 4, 5, 11, 15.9, 16.6, GLASSC, GLASSM).Transparency = 0.5
			box(ctx, "ClubhouseWindow", x - 4, x + 4, 15.5, 21.5, 15.9, 16.6, GLASSC, GLASSM).Transparency = 0.5
		end
		-- Entry: two glazed doors (8 high) in the gable front, and two shallow steps down to the forecourt.
		box(ctx, "EntryGlassL", -5, -1, 4, 12, 30, 30.3, GLASSC, GLASSM).Transparency = 0.5
		box(ctx, "EntryGlassR", 1, 5, 4, 12, 30, 30.3, GLASSC, GLASSM).Transparency = 0.5
		box(ctx, "EntryStep1", -8, 8, -8, 1, 30, 31, TAN, STONE)
		box(ctx, "EntryStep2", -8, 8, -8, 2, 31, 32, TAN, STONE)
		box(ctx, "EntryStep3", -8, 8, -8, 3, 32, 33, TAN, STONE)
		box(ctx, "EntryStep4", -8, 8, -8, 4, 33, 34, TAN, STONE)
		-- Entry gable: walls, pitched tiers, and the ridge cap ClubhouseEntryGable.
		box(ctx, "EntryWall", -14, 14, 4, 20, 16, 30, OFFW, SMOOTH)
		box(ctx, "EntryRoofT1", -15, 15, 20, 22.5, 15, 31, TERRA, SLATE)
		box(ctx, "EntryRoofT2", -11, 11, 22.5, 26, 17, 29, TERRA, SLATE)
		box(ctx, "EntryRoofT3", -7, 7, 26, 29, 19, 27, TERRA, SLATE)
		box(ctx, "ClubhouseEntryGable", -3, 3, 29, 31, 17, 29, TERRA_CAP, SLATE)
		-- Porte-cochere: canopy slab PorteCochere (clear height 12) on four posts. The NE-side posts sit at lz 39
		-- (not the corner 43) to keep walking lane b (lx -2..2) and lane c free.
		box(ctx, "PorteCochere", -12, 12, 12, 13.2, 30, 44, TERRA, SLATE)
		for _, x in ipairs({ -11, 11 }) do
			for _, z in ipairs({ 31, 39 }) do
				box(ctx, "Portepost", x - 0.4, x + 0.4, 0, 12, z - 0.4, z + 0.4, OFFW, SMOOTH)
			end
		end
		-- Main hipped roof as stacked tiers (eave ly 24, overhang 4), capped by the ridge ClubhouseRoofMain.
		local tiers = { { 54, -19, 20, 24, 26 }, { 49, -18, 16, 26, 28 }, { 44, -16, 12, 28, 30 }, { 39, -12, 8, 30, 32 }, { 34, -8, 4, 32, 34 } }
		for k, t in ipairs(tiers) do
			box(ctx, "RoofTier" .. k, -t[1], t[1], t[4], t[5], t[2], t[3], TERRA, SLATE)
		end
		box(ctx, "Soffit", -50, 50, 23.4, 24, 16, 20, BROWN, WOODM)
		box(ctx, "ClubhouseRoofMain", -34, 34, 34, 36, -4, 0, TERRA_CAP, SLATE)
		-- Left wing (SW, lx 50..74): one storey with its own lower hipped roof, never merged with the main roof.
		box(ctx, "WingFoundation", 50, 74, -8, 0, -10, 14.4, TAN, STONE)
		box(ctx, "WingPlinth", 50, 74, 0, 4, -10, 14.4, TAN, STONE)
		box(ctx, "WingWall", 50, 74, 4, 12, -10, 14, OFFW, SMOOTH)
		box(ctx, "WingSideGlassA", 54, 62, 5, 11, 14, 14.4, GLASSC, GLASSM).Transparency = 0.5
		box(ctx, "WingSideGlassB", 64, 72, 5, 11, 14, 14.4, GLASSC, GLASSM).Transparency = 0.5
		box(ctx, "WingRoofT0", 50, 74, 12, 13.5, -12, 14, TERRA, SLATE)
		box(ctx, "WingRoofT1", 54, 70, 13.5, 15.5, -8, 10, TERRA, SLATE)
		box(ctx, "WingRoofT2", 58, 66, 15.5, 17, -4, 6, TERRA, SLATE)
		box(ctx, "WingRidge", 60, 64, 17, 17.8, -2, 4, TERRA_CAP, SLATE)
	end
	section(CFL, clubhouse, buildClubhouse)

	------------------------------------------------------------------ Forecourt (local frame): plate, kerb, carts, flagpole
	local function buildForecourt(ctx)
		box(ctx, "ForecourtPlate", -32, 32, -1, 0.3, 40, 56, CONC, CONCM)
		box(ctx, "ForecourtKerb", -32, 32, 0, 0.6, 55.4, 56.4, CONC, CONCM)
		-- A cart seats on the highest ground under its four corners (so no corner floats). Canopy top <= ly 4.4.
		local function cart(cx, cz, bodyCol, canopyCol)
			local base = -math.huge
			for _, c in ipairs({ { -3, -1.75 }, { 3, -1.75 }, { -3, 1.75 }, { 3, 1.75 } }) do
				local p = lw(cx + c[1], 0, cz + c[2])
				base = math.max(base, gnd(p.X, p.Z) - PADY)
			end
			box(ctx, "CartBody", cx - 3, cx + 3, base - 0.5, base + 1.6, cz - 1.75, cz + 1.75, bodyCol, SMOOTH)
			box(ctx, "CartSeat", cx - 2.2, cx + 1.2, base + 1.6, base + 2.6, cz - 1.2, cz + 1.2, CART_T, SMOOTH)
			for _, c in ipairs({ { -2.6, -1.5 }, { 2.6, -1.5 }, { -2.6, 1.5 }, { 2.6, 1.5 } }) do
				vcyl(ctx, "CartPole", cx + c[1], cz + c[2], base + 1.6, base + 4.0, 0.3, OFFW, SMOOTH)
			end
			box(ctx, "CartCanopy", cx - 3.2, cx + 3.2, base + 4.0, base + 4.4, cz - 2, cz + 2, canopyCol, SMOOTH)
			for _, c in ipairs({ { -2.2, -1.9 }, { 2.2, -1.9 }, { -2.2, 1.9 }, { 2.2, 1.9 } }) do
				ball(ctx, "CartWheel", cx + c[1], base + 0.3, cz + c[2], 1.4, BLACK, SMOOTH)
			end
		end
		-- Two rows at lz 52.5 (lx 17..36 and -40..-21) and a second row at lz 46 (lx -40..-21).
		for i, x in ipairs({ 20, 26.5, 33 }) do
			cart(x, 52.5, i % 2 == 0 and CART_G or CART_C, CART_C)
		end
		for i, x in ipairs({ -37, -30.5, -24 }) do
			cart(x, 52.5, i % 2 == 0 and CART_C or CART_G, CART_C)
			cart(x, 46, i % 2 == 0 and CART_G or CART_C, CART_C)
		end
		-- A third row on the left (the right side is walking lane c to the pool), as the aerial shows carts lined up along the drive.
		for i, x in ipairs({ -37, -30.5, -24 }) do
			cart(x, 41, i % 2 == 0 and CART_C or CART_G, CART_C)
		end
		-- Flagpole outside the lanes, with a small cloth.
		vcyl(ctx, "Flagpole", -44, 30, 0, 14, 0.4, OFFW, SMOOTH)
		box(ctx, "FlagCloth", -44, -40.5, 11, 13.5, 30, 30.15, FLAG_R, SMOOTH)
	end
	section(CFL, sub("Forecourt"), buildForecourt)

	------------------------------------------------------------------ Pool (local frame): raised deck top ly 1.0 (y 21.0)
	local function buildPool(ctx)
		-- Stone-brick deck on a solid plinth (top 21.0), cream coping ring 1 high, basin water at 21.0..21.8.
		-- Starts at lx 88: the NW corner (lx 78..88) sits on ground at 20.0..20.9, which would make the deck thin.
		box(ctx, "PoolDeck", 88, 134, -12, 1.0, -4, 28, BRICK, BRICKM)
		local coping = {
			{ 85, 122, 3, 4 }, { 85, 86, 3, 23 }, { 85, 112, 22, 23 }, { 130, 131, 9, 25 },
			{ 112, 131, 24, 25 }, { 122, 123, 3, 10 }, { 122, 130, 9, 10 }, { 111, 112, 10, 22 },
		}
		for _, c in ipairs(coping) do
			box(ctx, "PoolCoping", c[1], c[2], 1.0, 2.0, c[3], c[4], CREAM, SMOOTH)
		end
		local water = box(ctx, "PoolWater", 86, 122, 1.0, 1.8, 4, 22, AQUA, GLASSM)
		water.Transparency = 0.3
		water.CanCollide = false
		local lobe = box(ctx, "PoolWaterLobe", 112, 130, 1.0, 1.8, 10, 24, AQUA, GLASSM)
		lobe.Transparency = 0.3
		lobe.CanCollide = false
		-- Six loungers (four on the north deck, two on the south) and one umbrella.
		local function lounger(lx, lz)
			box(ctx, "Lounger", lx, lx + 2.2, 1.0, 1.6, lz, lz + 5, CART_T, SMOOTH)
			box(ctx, "LoungerBack", lx, lx + 0.8, 1.6, 3.0, lz, lz + 5, CART_T, SMOOTH)
			box(ctx, "LoungerCushion", lx + 0.3, lx + 1.9, 1.6, 1.9, lz + 0.5, lz + 4.5, OFFW, SMOOTH)
		end
		for _, x in ipairs({ 92, 100, 108, 116 }) do
			lounger(x, -3)
		end
		for _, x in ipairs({ 92, 100 }) do
			lounger(x, 23.5)
		end
		vcyl(ctx, "UmbrellaPole", 128, 0, 1.0, 9, 0.4, OFFW, SMOOTH)
		vcyl(ctx, "UmbrellaCanopy", 128, 0, 8.2, 8.8, 7, FLAG_R, SMOOTH)
	end
	section(CFL, sub("Pool"), buildPool)

	------------------------------------------------------------------ Course and pond (world frame, identity origin)
	local function gy(x, z) -- ground plus a little, for markers on the grass
		return gnd(x, z) + 0.6
	end
	local function inPond(x, z)
		return (x >= 440 and x <= 488 and z >= 772 and z <= 812) or (x >= 452 and x <= 496 and z >= 808 and z <= 848)
	end
	local function boulder(ctx, x, z, d)
		local y = inPond(x, z) and (5.5 + d * 0.1) or (gnd(x, z) + d * 0.2)
		return ball(ctx, "Boulder", x, y, z, d, DARK, SLATE)
	end
	local function signpost(ctx, x, z, label)
		local g = gnd(x, z)
		vcyl(ctx, "DistancePost", x, z, g, g + 2.6, 0.3, BROWN, WOODM)
		box(ctx, "DistanceSign" .. label, x - 1.2, x + 1.2, g + 2.2, g + 2.9, z - 0.1, z + 0.1, OFFW, SMOOTH)
	end

	local function buildPond(ctx)
		-- Rims and water boulders around the two terrain ponds (the water itself is terrain).
		local rim = {
			{ 446, 770 }, { 458, 769 }, { 470, 769.5 }, { 484, 770 }, { 494, 774 },
			{ 492, 786 }, { 497, 800 }, { 498, 826 }, { 500, 838 },
			{ 486, 852 }, { 470, 853 }, { 456, 853 }, { 446, 850 },
			{ 439, 800 }, { 438, 812 }, { 440, 826 },
			{ 480, 822 }, { 466, 836 }, { 446, 826 }, { 504, 812 }, { 500, 850 },
			{ 476, 780 }, { 478, 806 }, { 462, 810 }, { 500, 790 },
		}
		for i, p in ipairs(rim) do
			boulder(ctx, p[1], p[2], 2.6 + (i % 3) * 0.7)
		end
		-- Bunker boulders (the bunkers are terrain).
		for _, p in ipairs({ { 706, 642 }, { 742, 610 }, { 382, 702 }, { 418, 722 }, { 701, 606 } }) do
			boulder(ctx, p[1], p[2], 3)
		end
	end
	section(ID, sub("Pond"), buildPond)

	local function buildCourse(ctx)
		-- Island green flag (ONE pole, 14 high from the island at (466, 792)); its cloth is a separate part.
		vcyl(ctx, "IslandFlag", 466, 792, 9.0, 23.0, 0.4, OFFW, SMOOTH)
		box(ctx, "IslandFlagCloth", 466.2, 468.0, 20.0, 22.5, 791.9, 792.1, FLAG_R, SMOOTH)
		-- Footbridge: deck top 8.0, 4 wide, over the pond from the west bank to the island.
		box(ctx, "IslandBridge", 441, 456, 7.0, 8.0, 790, 794, TIMBER, WOODM)
		-- Tee markers, flags on the greens of holes 2 and 3, benches, ball washers and distance signs.
		for _, p in ipairs({ { 424, 789 }, { 430, 789 } }) do
			ball(ctx, "TeeMarker", p[1], gy(p[1], p[2]), p[2], 1.4, WHITE_M, SMOOTH)
		end
		for _, p in ipairs({ { 576, 640 }, { 584, 640 } }) do
			ball(ctx, "TeeMarker", p[1], gy(p[1], p[2]), p[2], 1.4, WHITE_M, SMOOTH)
		end
		for _, p in ipairs({ { 384, 588 }, { 392, 588 } }) do
			ball(ctx, "TeeMarker", p[1], gy(p[1], p[2]), p[2], 1.4, WHITE_M, SMOOTH)
		end
		for _, g in ipairs({ { 724, 620 }, { 400, 716 } }) do
			local base = gnd(g[1], g[2])
			vcyl(ctx, "GreenFlag", g[1], g[2], base, base + 11, 0.35, OFFW, SMOOTH)
			box(ctx, "GreenFlagCloth", g[1] + 0.2, g[1] + 2.4, base + 9, base + 10.8, g[2] - 0.1, g[2] + 0.1, FLAG_R, SMOOTH)
		end
		for _, p in ipairs({ { 566, 650 }, { 386, 572 } }) do
			local g = gnd(p[1], p[2])
			box(ctx, "TeeBench", p[1] - 2, p[1] + 2, g + 0.8, g + 1.4, p[2] - 1.5, p[2] + 1.5, TIMBER, WOODM)
		end
		for _, p in ipairs({ { 580, 626 }, { 390, 606 } }) do
			local g = gnd(p[1], p[2])
			vcyl(ctx, "BallWasher", p[1], p[2], g, g + 1.2, 0.8, DARK, SLATE)
		end
		signpost(ctx, 418, 780, "1")
		signpost(ctx, 592, 630, "2")
		signpost(ctx, 372, 600, "3")
	end
	section(ID, sub("Course"), buildCourse)

	------------------------------------------------------------------ MountainBackdrop (world frame): tiered summits, CanCollide off
	local function mpart(ctx, name, x, z, y0, y1, dia, color)
		local p = vcyl(ctx, name, x, z, y0, y1, dia, color, SMOOTH)
		p.CanCollide = false
		return p
	end
	local function buildBackdrop(ctx)
		-- Ridge summits along the east edge (x 705..751), blue-green with darker shadow tiers.
		local summits = { { 580, 0.9 }, { 615, 1.0 }, { 650, 0.85 }, { 685, 1.0 }, { 760, 0.95 }, { 800, 1.0 }, { 835, 0.9 }, { 865, 0.85 } }
		for i, s in ipairs(summits) do
			local z, k = s[1], s[2]
			local c1, c2 = i % 2 == 0 and MTN or MTN_D, i % 2 == 0 and MTN_D or MTN
			mpart(ctx, "MountainTier", 728, z, 30, 44, 46 * k, c1)
			mpart(ctx, "MountainTier", 728, z, 44, 54, 36 * k, c2)
			mpart(ctx, "MountainTier", 728, z, 54, 62, 24 * k, c1)
		end
		-- The main peak: a stack of tiers, then BackdropPeak (ONE part, centre (735, 78, 720), 66..90 high).
		mpart(ctx, "PeakTier", 735, 720, 30, 50, 46, MTN_D)
		mpart(ctx, "PeakTier", 735, 720, 50, 60, 38, MTN)
		mpart(ctx, "PeakTier", 735, 720, 60, 66, 32, MTN_D)
		mpart(ctx, "BackdropPeak", 735, 720, 66, 90, 30, MTN)
		-- Flattened ridge blocks between the summits.
		for _, z in ipairs({ 598, 668, 742, 848 }) do
			local b = box(ctx, "RidgeBlock", 712, 748, 30, 40, z - 10, z + 10, MTN_D, SMOOTH)
			b.CanCollide = false
		end
	end
	section(ID, backdrop, buildBackdrop)

	------------------------------------------------------------------ LeisureSpacesPanel (world frame): board on two posts
	local function buildPanel(ctx)
		-- Board centre (574, PADY + 6.5, 706), 12 wide, 7 tall. Its +Z (Back face) points SW (toward lane b).
		local bpos = V(574, PADY + 6.5, 706)
		local rot = CFrame.fromMatrix(bpos, V(S, 0, S), V(0, 1, 0), V(-S, 0, S))
		local board = ctx:part("LeisureBoard", V(12, 7, 0.6), rot, BOARD, SMOOTH)
		local gui = Instance.new("SurfaceGui")
		gui.Face = Enum.NormalId.Back
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 30
		gui.Parent = board
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(0.94, 0.86)
		label.Position = UDim2.fromScale(0.03, 0.07)
		label.BackgroundTransparency = 1
		label.TextColor3 = TEXT
		-- 225 characters: a fixed TextSize (TextScaled shrinks a board this long to unreadable type).
		label.TextScaled = false
		label.TextSize = 16
		label.TextWrapped = true
		label.Font = Enum.Font.GothamBold
		label.Text = "LEISURE SPACES. Mount Malarayat Golf & Country Club is a recreation and hospitality destination in Lipa's mountain setting. It offers golf, accommodation and other leisure facilities; access depends on the service or booking."
		label.Parent = gui
		-- Two posts at the board's ends, from the ground to the board's underside.
		for _, k in ipairs({ -5, 5 }) do
			local x, z = 574 + k * S, 706 + k * S
			local g = gnd(x, z)
			box(ctx, "LeisurePost", x - 0.4, x + 0.4, g - 0.5, PADY + 3, z - 0.4, z + 0.4, BROWN, WOODM)
		end
	end
	section(ID, panel, buildPanel)

	------------------------------------------------------------------ Trees and planting (world frame): trunks collide, fronds do not
	-- Norfolk pine, 34 high: a trunk and eight slender stepped tiers (the photos' pines are tall and narrow). Seated on the ground under (x, z).
	local function pine(ctx, x, z)
		local g = gnd(x, z)
		vcyl(ctx, "PineTrunk", x, z, g, g + 34, 1.2, PTRUNK, WOODM)
		for k = 0, 7 do
			local y0 = 6 + k * 3.5
			vcyl(ctx, "PineTier", x, z, g + y0, g + y0 + 3.2, 9.5 - k * 0.95, PINE, GRASSM)
		end
	end
	-- Palm, 15 high: three stacked trunk segments and six non-colliding fronds.
	local function palm(ctx, x, z)
		local g = gnd(x, z)
		local h = 18
		for k = 0, 2 do
			vcyl(ctx, "PalmTrunk", x, z, g + k * h / 3, g + (k + 1) * h / 3, 1.2, PTRUNK, WOODM)
		end
		for k = 1, 8 do
			local ang = (k - 1) * PI / 4 + 0.3
			local fr = ctx:part("PalmFrond", V(9.5, 0.3, 1.8), CF(x, g + h, z) * ANG(0, ang, 0) * CF(4.6, 0, 0) * ANG(0, 0, -0.5), FROND, GRASSM)
			fr.CanCollide = false
		end
	end
	-- Shrub clump, no taller than 2.4, on the ground.
	local function clump(ctx, x, z)
		local g = gnd(x, z)
		ball(ctx, "Shrub", x, g + 1.2, z, 2.4, SHRUB, GRASSM)
		ball(ctx, "Shrub", x + 1.1, g + 1.1, z + 0.7, 2.0, SHRUB, GRASSM)
		ball(ctx, "Shrub", x - 0.7, g + 1.0, z - 0.9, 1.8, SHRUB, GRASSM)
	end
	local function buildTrees(ctx)
		-- Pines only in the zones the brief allows (not the road-eye bundle, not the Guide-porte line).
		for _, p in ipairs({
			{ 612, 612 }, { 640, 606 }, { 664, 636 }, { 628, 664 }, { 664, 684 },
			{ 620, 575 }, { 650, 580 }, { 684, 572 }, { 688, 640 }, { 692, 700 },
			{ 690, 820 }, { 692, 870 }, { 600, 866 }, { 620, 872 }, { 648, 870 }, { 574, 880 },
		}) do
			pine(ctx, p[1], p[2])
		end
		-- Palms around the pool and the pond (outside lane d).
		for _, p in ipairs({
			{ 515, 822 }, { 508, 846 }, { 520, 872 }, { 560, 878 }, { 590, 872 },
			{ 430, 830 }, { 455, 862 }, { 490, 872 }, { 505, 806 },
		}) do
			palm(ctx, p[1], p[2])
		end
		for _, p in ipairs({
			{ 470, 650 }, { 480, 680 }, { 600, 600 }, { 612, 626 }, { 650, 650 }, { 680, 620 }, { 690, 660 },
			{ 540, 880 }, { 552, 890 }, { 580, 890 }, { 500, 890 }, { 450, 826 },
		}) do
			clump(ctx, p[1], p[2])
		end
	end
	section(ID, sub("Trees"), buildTrees)

	------------------------------------------------------------------ Swap: old children out, new containers in, chunks one by one
	assert(used <= PART_BUDGET, string.format("site08: %d parts exceeds the %d budget", used, PART_BUDGET))
	for _, child in ipairs(site:GetChildren()) do
		if REPLACED[child.Name] then child:Destroy() end
	end
	structure.Parent = site
	for _, m in ipairs(subs) do
		m.Parent = structure
	end
	clubhouse.Parent = site
	backdrop.Parent = site
	panel.Parent = site
	for _, e in ipairs(plan) do
		e.chunk.Parent = e.dest
		task.wait()
	end

	local pivotAfter = site:GetPivot()
	assert((pivotAfter.Position - pivotBefore.Position).Magnitude < 1e-3 and pivotAfter.LookVector:Dot(pivotBefore.LookVector) > 0.9999,
		"site08: the site pivot changed during the build")

	local total = countParts(site)
	return {
		parts = total,
		keptParts = keptParts,
		builtParts = total - keptParts,
	}
end
