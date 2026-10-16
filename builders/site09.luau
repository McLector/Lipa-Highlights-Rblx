-- site09: Tagbakin, Brgy. Halang (Slice 12). Studio copy: ServerStorage.Builders.site09; run with
--   require(game.ServerStorage.Builders.site09:Clone())()
-- Needs Workspace.Sites.Site09_Tagbakin with its kept children (Guide, InfoPanel, JeepStop, JeepSignPole, JeepSign, Jeepney).
-- IDEMPOTENT: replaces Block, Structure, Dock, Bancas, FishingActivity and LocationMapPanel. The kept children are left alone.
-- No terrain writes. Brief: briefs/site09.md.
-- FRAMES: the site pivot is yawed NE and sits on the shore diagonal, so it is NOT used as the origin.
--   ORIGIN = (-650, 0, 588), s = 0.70711. CFL = fromMatrix(ORIGIN, (s,0,s), (0,1,0)): local +X = SE, local +Z = SW (the lake),
--   +Y up. World = (-650 + s*(lx - lz), ly, 588 + s*(lx + lz)).
-- Fail-safe order: everything is built into unparented parts first (the plan); only then are the old children deleted and
-- the new containers and parts parented in small batches with task.wait(). An error before that leaves the old children untouched.
return function()
	local Players = game:GetService("Players")
	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
	local BuildKit = require(game.ServerStorage.BuildKit:Clone())

	local V, CF, ANG = Vector3.new, CFrame.new, CFrame.Angles
	local PI = math.pi
	local row = SiteData.byId(9)
	assert(row and row.facing == "NE", "site09: SiteData row 9 is missing or not facing NE")
	local sites = workspace:FindFirstChild("Sites")
	local site = sites and sites:FindFirstChild("Site09_Tagbakin")
	assert(site, "site09: Workspace.Sites.Site09_Tagbakin not found (run builders/placeholders first)")
	local pivotBefore = site:GetPivot()
	assert(math.abs(pivotBefore.Position.X + 600) < 1e-3 and math.abs(pivotBefore.Position.Z - 550) < 1e-3, "site09: pivot is not at (-600, 0, 550)")

	local ORIGIN = V(-650, 0, 588)
	local S = 0.70711
	local CFL = CFrame.fromMatrix(ORIGIN, V(S, 0, S), V(0, 1, 0))
	local PART_BUDGET = 2500
	local REPLACED = { Block = true, Structure = true, Dock = true, Bancas = true, FishingActivity = true, LocationMapPanel = true }

	-- Colours (brief table) and materials.
	local WALL = Color3.fromRGB(203, 206, 204)
	local BAND = Color3.fromRGB(150, 154, 152)
	local ROOF = Color3.fromRGB(172, 176, 178)
	local ROOF_E = Color3.fromRGB(120, 124, 126)
	local GLASS_C = Color3.fromRGB(96, 120, 128)
	local WHITE_F = Color3.fromRGB(232, 232, 228)
	local DOOR = Color3.fromRGB(70, 76, 80)
	local SEAWALL = Color3.fromRGB(168, 166, 158)
	local PAVE = Color3.fromRGB(200, 190, 172)
	local TIMBER = Color3.fromRGB(150, 104, 64)
	local POST_T = Color3.fromRGB(96, 70, 48)
	local BANCA_W = Color3.fromRGB(236, 238, 236)
	local BANCA_B = Color3.fromRGB(36, 92, 160)
	local BANCA_R = Color3.fromRGB(190, 50, 44)
	local BAMBOO = Color3.fromRGB(196, 172, 100)
	local PTRUNK = Color3.fromRGB(120, 98, 70)
	local FROND = Color3.fromRGB(56, 120, 56)
	local LAMP_C = Color3.fromRGB(64, 70, 76)
	local NEON = Color3.fromRGB(255, 226, 160)
	local THATCH = Color3.fromRGB(190, 158, 88)
	local NET_C = Color3.fromRGB(150, 136, 100)
	local BROWN = Color3.fromRGB(110, 80, 52)
	local CREAM = Color3.fromRGB(240, 236, 224)
	local LAKE_C = Color3.fromRGB(96, 160, 206)
	local ISLAND_C = Color3.fromRGB(96, 150, 92)
	local TEXT_C = Color3.fromRGB(40, 60, 50)
	local PIN_C = Color3.fromRGB(200, 50, 40)
	local BUCKET_C = Color3.fromRGB(120, 130, 140)
	local COOLER_C = Color3.fromRGB(80, 110, 140)
	local SMOOTH, CONC, WOOD = Enum.Material.SmoothPlastic, Enum.Material.Concrete, Enum.Material.Wood
	local GLASSM, METAL, FABRIC = Enum.Material.Glass, Enum.Material.Metal, Enum.Material.Fabric
	local GRASS, NEONM = Enum.Material.LeafyGrass, Enum.Material.Neon

	-- Axis-aligned box in the ctx frame: x0..x1 / y0..y1 / z0..z1 (local coordinates).
	local function box(ctx, name, x0, x1, y0, y1, z0, z1, color, material)
		return ctx:part(name, V(x1 - x0, y1 - y0, z1 - z0), CF((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), color, material)
	end
	-- Vertical cylinder from y0 to y1, centred on (x, z), in the ctx frame.
	local function vcyl(ctx, name, x, z, y0, y1, dia, color, material)
		return ctx:cyl(name, V(y1 - y0, dia, dia), CF(x, (y0 + y1) / 2, z) * ANG(0, 0, PI / 2), color, material)
	end
	local function ball(ctx, name, x, y, z, dia, color, material)
		return ctx:ball(name, dia, CF(x, y, z), color, material)
	end
	-- The lake edge crosses local Z at lzc(lx) (brief, measured in Studio).
	local function lzc(lx)
		return 312.543 - math.sqrt(78400 - (lx - 15.556) ^ 2)
	end
	-- SurfaceGui on a part's face (Back = local +Z), 30 px per stud.
	local function gui(part, face)
		local g = Instance.new("SurfaceGui")
		g.Face = face or Enum.NormalId.Back
		g.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		g.PixelsPerStud = 30
		g.Parent = part
		return g
	end

	-- Plan: every part and container, with its destination, built before anything reaches the DataModel.
	local used = 0
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
	used = keptParts
	local plan = {}
	local function place(inst, dest)
		table.insert(plan, { inst = inst, dest = dest })
	end
	-- An empty container, planned into dest before its contents.
	local function newInst(class, name, dest)
		local inst = Instance.new(class)
		inst.Name = name
		place(inst, dest)
		return inst
	end
	-- Runs fn(ctx) with a fresh BuildKit ctx and plans every part it made into dest.
	local function section(origin, dest, fn)
		local holder = Instance.new("Model") -- unparented scratch; BuildKit's chunks sit inside it and are never parented
		local ctx = BuildKit.new(holder, origin, { budget = PART_BUDGET - used })
		fn(ctx)
		used += ctx:count()
		for _, p in ipairs(ctx:parts()) do
			place(p, dest)
		end
		return dest
	end

	------------------------------------------------------------------ Containers (empty until the swap)
	local structure = newInst("Folder", "Structure", site)
	local quay = newInst("Model", "Quay", structure)
	local building = newInst("Model", "ShoreBuilding", structure)
	local dressing = newInst("Model", "Dressing", structure)
	local dock = newInst("Model", "Dock", site)
	local bancas = newInst("Model", "Bancas", site)
	local fishing = newInst("Model", "FishingActivity", site)
	local panel = newInst("Model", "LocationMapPanel", site)

	------------------------------------------------------------------ Terrace (in Structure): one slab, top 1.2
	section(CFL, structure, function(ctx)
		box(ctx, "Terrace", -44, 44, -0.8, 1.2, -24, 28, PAVE, CONC)
	end)

	------------------------------------------------------------------ Quay: six seawall segments and seven promenade strips
	-- { lx0, lx1, cx, cz, len, yaw (deg), px, pz } from briefs/site09.md.
	local QUAY = {
		{ -60, -40, -50.00, 41.52, 20.57, 13.55, -51.87, 33.74 },
		{ -40, -20, -30.00, 37.46, 20.27, 9.37, -31.30, 29.57 },
		{ -20, -5, -12.50, 35.05, 15.08, 5.75, -13.30, 27.09 },
		{ 5, 20, 12.50, 33.66, 15.00, 0.63, 12.41, 25.66 },
		{ 20, 40, 30.00, 34.09, 20.03, -2.96, 30.41, 26.11 },
		{ 40, 56, 48.00, 35.55, 16.11, -6.66, 48.93, 27.60 },
	}
	section(CFL, quay, function(ctx)
		for _, q in ipairs(QUAY) do
			local yaw = math.rad(q[6])
			ctx:part("SeawallSegment", V(q[5] + 0.6, 6.4, 6.0), CF(q[3], -0.8, q[4]) * ANG(0, yaw, 0), SEAWALL, CONC)
			ctx:part("PromenadeStrip", V(q[5] + 0.6, 2.0, 9.0), CF(q[7], 0.2, q[8]) * ANG(0, yaw, 0), PAVE, CONC)
		end
		-- The seventh strip bridges the dock gap (lx -5..5).
		ctx:part("PromenadeStrip", V(10.6, 2.0, 9.0), CF(0, 0.2, 25.98), PAVE, CONC)
	end)

	------------------------------------------------------------------ ShoreBuilding (Model in Structure): the lake-facing block
	-- A glass pane 0.4 thick, its face on the wall plane z, with a white frame behind it.
	local function pane(ctx, name, x0, x1, y0, y1, z)
		box(ctx, "ShoreWindowFrame", x0 - 0.25, x1 + 0.25, y0 - 0.25, y1 + 0.25, z - 0.1, z + 0.05, WHITE_F, SMOOTH)
		local p = box(ctx, name, x0, x1, y0, y1, z + 0.05, z + 0.45, GLASS_C, GLASSM)
		p.Transparency = 0.3
		return p
	end
	section(CFL, building, function(ctx)
		box(ctx, "ShoreBody", -14, 14, 1.2, 23.2, -15, 11, WALL, CONC)
		box(ctx, "PavilionL", -36, -14, 1.2, 25.2, -15, 15, WALL, CONC)
		box(ctx, "PavilionR", 14, 36, 1.2, 25.2, -15, 15, WALL, CONC)
		-- Base bands (150, 154, 152), 2 high, proud 0.3 on the SW and NE faces; the centre bay band stops at the door.
		box(ctx, "BaseBand", -36, -14, 1.2, 3.2, 15, 15.3, BAND, CONC)
		box(ctx, "BaseBand", 14, 36, 1.2, 3.2, 15, 15.3, BAND, CONC)
		box(ctx, "BaseBand", -14, -4.5, 1.2, 3.2, 11, 11.3, BAND, CONC)
		box(ctx, "BaseBand", 4.5, 14, 1.2, 3.2, 11, 11.3, BAND, CONC)
		box(ctx, "BaseBand", -36, -14, 1.2, 3.2, -15.3, -15, BAND, CONC)
		box(ctx, "BaseBand", 14, 36, 1.2, 3.2, -15.3, -15, BAND, CONC)
		box(ctx, "BaseBand", -14, -3, 1.2, 3.2, -15.3, -15, BAND, CONC)
		box(ctx, "BaseBand", 3, 14, 1.2, 3.2, -15.3, -15, BAND, CONC)
		-- Roof deck (recessed roof terrace) with a 1.4 parapet on its four edges.
		box(ctx, "ShoreRoofDeck", -14, 14, 23.2, 24.0, -15, 11, ROOF, METAL)
		box(ctx, "Parapet", -14, 14, 24.0, 25.4, -15, -14.6, WALL, CONC)
		box(ctx, "Parapet", -14, 14, 24.0, 25.4, 10.6, 11, WALL, CONC)
		box(ctx, "Parapet", -14, -13.6, 24.0, 25.4, -14.6, 10.6, WALL, CONC)
		box(ctx, "Parapet", 13.6, 14, 24.0, 25.4, -14.6, 10.6, WALL, CONC)
		-- Pavilion roofs: three stacked tiers each; tier 3 is the single part PavilionRoofL / PavilionRoofR.
		box(ctx, "PavilionTier1L", -38, -12, 25.2, 26.4, -17, 17, ROOF_E, METAL)
		box(ctx, "PavilionTier2L", -34, -16, 26.4, 27.6, -13, 13, ROOF, METAL)
		box(ctx, "PavilionRoofL", -30, -20, 27.6, 28.6, -9, 9, ROOF, METAL)
		box(ctx, "PavilionTier1R", 12, 38, 25.2, 26.4, -17, 17, ROOF_E, METAL)
		box(ctx, "PavilionTier2R", 16, 34, 26.4, 27.6, -13, 13, ROOF, METAL)
		box(ctx, "PavilionRoofR", 20, 30, 27.6, 28.6, -9, 9, ROOF, METAL)
		-- Lake-facade glass (SW face). Pavilions at lz 15: a ground and an upper pane per column.
		for _, c in ipairs({ -29, -21, 21, 29 }) do
			pane(ctx, "ShoreWindow", c - 2.5, c + 2.5, 5.2, 10.2, 15)
			pane(ctx, "ShoreWindow", c - 2.5, c + 2.5, 16.2, 21.2, 15)
		end
		-- Centre bay at lz 11: double door glass and flank panes; the dark door sits behind the glass.
		box(ctx, "CentreDoor", -4.5, 4.5, 1.2, 9.2, 11.0, 11.15, DOOR, METAL)
		pane(ctx, "ShoreWindow", -4.5, -0.3, 1.8, 9.2, 11)
		pane(ctx, "ShoreWindow", 0.3, 4.5, 1.8, 9.2, 11)
		pane(ctx, "ShoreWindow", -11, -7, 4.2, 9.2, 11)
		pane(ctx, "ShoreWindow", 7, 11, 4.2, 9.2, 11)
		box(ctx, "EntryCanopy", -14, 14, 10.4, 11.0, 11, 15, ROOF, METAL)
		-- Rear (NE face, lz -15): the rear door, its canopy, and six plainer RearWindow panes.
		box(ctx, "RearDoor", -2.2, 2.2, 1.2, 9.2, -15.4, -15.0, DOOR, METAL)
		box(ctx, "RearCanopy", -5, 5, 10, 10.6, -21, -15, ROOF, METAL)
		for _, c in ipairs({ -29, -21, -7, 7, 21, 29 }) do
			box(ctx, "RearWindow", c - 2, c + 2, 16, 21, -15.45, -15.05, GLASS_C, GLASSM).Transparency = 0.3
		end
	end)

	------------------------------------------------------------------ Dock (container): deck lz 24..84, top 1.2, tip DockEnd
	section(CFL, dock, function(ctx)
		-- 14 planks of 4 studs (lz 24..80) with no gaps, a plank 80..82, and the last plank DockEnd (82..84).
		for k = 0, 13 do
			box(ctx, "DockPlank", -4, 4, 0.4, 1.2, 24 + 4 * k, 28 + 4 * k, TIMBER, WOOD)
		end
		box(ctx, "DockPlank", -4, 4, 0.4, 1.2, 80, 82, TIMBER, WOOD)
		box(ctx, "DockEnd", -4, 4, 0.4, 1.2, 82, 84, TIMBER, WOOD)
		-- Posts: eight pairs at lx +-4.5 (lz 28..76 every 8, and 82 at the tip), round, 1.0 across, y -6..3.2.
		for _, lz in ipairs({ 28, 36, 44, 52, 60, 68, 76, 82 }) do
			vcyl(ctx, "DockPost", -4.5, lz, -6, 3.2, 1.0, POST_T, WOOD)
			vcyl(ctx, "DockPost", 4.5, lz, -6, 3.2, 1.0, POST_T, WOOD)
		end
		-- Rails along both sides from lz 27 to 82 (none across the landing end or at the promenade end; clear of lane d at lz 22..26).
		box(ctx, "DockRail", -4.2, -3.8, 3.6, 4.2, 27, 82, POST_T, WOOD)
		box(ctx, "DockRail", 3.8, 4.2, 3.6, 4.2, 27, 82, POST_T, WOOD)
		box(ctx, "DockRailMid", -4.2, -3.8, 2.2, 2.6, 27, 82, POST_T, WOOD)
		box(ctx, "DockRailMid", 3.8, 4.2, 2.2, 2.6, 27, 82, POST_T, WOOD)
		-- Ladder on the NW side of the tip, two bollards, and a bench each side of the tip with its back to the rail.
		box(ctx, "DockLadder", -5.0, -4.5, -2.0, 1.2, 82.6, 83.2, POST_T, WOOD)
		vcyl(ctx, "Bollard", -2.9, 83, 1.2, 1.8, 0.6, POST_T, WOOD)
		vcyl(ctx, "Bollard", 2.9, 83, 1.2, 1.8, 0.6, POST_T, WOOD)
		box(ctx, "DockBench", -3.6, -2.6, 1.2, 1.8, 80, 82, TIMBER, WOOD)
		box(ctx, "DockBenchBack", -3.85, -3.6, 1.8, 3.0, 80, 82, TIMBER, WOOD)
		box(ctx, "DockBench", 2.6, 3.6, 1.2, 1.8, 80, 82, TIMBER, WOOD)
		box(ctx, "DockBenchBack", 3.6, 3.85, 1.8, 3.0, 80, 82, TIMBER, WOOD)
	end)

	------------------------------------------------------------------ Bancas (container of four Models): outrigger hulls on the water
	-- One banca in its own frame: a 14 x 2.4 x 1.6 hull (centre y 0.4), bow and stern wedges, a blue band, a red stripe,
	-- thwarts and gunwales, two bamboo outriggers 12 long at lx +-5.5, and two cross poles and two float ends each side.
	local function banca(ctx, hullName, cx, cz, yawDeg)
		local base = CF(cx, 0, cz) * ANG(0, math.rad(yawDeg), 0)
		local function at(x, y, z)
			return base * CF(x, y, z)
		end
		ctx:part(hullName, V(1.6, 2.4, 14), at(0, 0.4, 0), BANCA_W, SMOOTH)
		ctx:wedge("BancaBow", V(1.6, 2.4, 2.5), at(0, 0.4, 8.25) * ANG(0, PI, 0), BANCA_W, SMOOTH)
		ctx:wedge("BancaStern", V(1.6, 2.4, 2.5), at(0, 0.4, -8.25), BANCA_W, SMOOTH)
		ctx:part("BancaBand", V(1.65, 0.5, 14.1), at(0, 0.25, 0), BANCA_B, SMOOTH)
		ctx:part("BancaStripe", V(1.65, 0.3, 14.1), at(0, 0.9, 0), BANCA_R, SMOOTH)
		ctx:part("BancaThwart", V(1.8, 0.3, 1.0), at(0, 1.6, 0), TIMBER, WOOD)
		ctx:part("BancaThwart", V(1.8, 0.3, 1.0), at(0, 1.6, -3), TIMBER, WOOD)
		ctx:part("BancaGunwale", V(0.3, 0.2, 13.5), at(0.85, 1.7, 0), TIMBER, WOOD)
		ctx:part("BancaGunwale", V(0.3, 0.2, 13.5), at(-0.85, 1.7, 0), TIMBER, WOOD)
		for _, side in ipairs({ 5.5, -5.5 }) do
			-- Outrigger float along the boat's length (its axis is the boat's Z), centre y 0.2.
			ctx:cyl("BancaOutrigger", V(12, 0.6, 0.6), at(side, 0.2, 0) * ANG(0, PI / 2, 0), BAMBOO, SMOOTH)
			local mid = side > 0 and 3.0 or -3.0
			for _, z in ipairs({ -3, 3 }) do
				ctx:cyl("BancaPole", V(4.4, 0.3, 0.3), at(mid, 0.9, z), BAMBOO, SMOOTH)
			end
			for _, z in ipairs({ -6, 6 }) do
				ctx:ball("BancaFloatEnd", 0.6, at(side, 0.2, z), BAMBOO, SMOOTH)
			end
		end
	end
	local boats = {
		{ "Banca1", -14, 56, 0, "BancaMain" },
		{ "Banca2", 14, 66, 15, "BancaHull" },
		{ "Banca3", 30, 44, 0, "BancaHull" },
		{ "Banca4", -24, 68, 0, "BancaHull" },
	}
	for _, b in ipairs(boats) do
		local model = newInst("Model", b[1], bancas)
		section(CFL, model, function(ctx)
			banca(ctx, b[5], b[2], b[3], b[4])
		end)
	end

	------------------------------------------------------------------ FishingActivity: two R15 anglers (built as buildVendors in site02)
	-- CreateHumanoidModelFromDescription yields, so this runs as its own step before the swap.
	local function buildAnglers(folder)
		local skins = { Color3.fromRGB(198, 134, 92), Color3.fromRGB(141, 85, 60) }
		local shirts = { Color3.fromRGB(90, 150, 100), Color3.fromRGB(200, 60, 60) }
		-- { local x, local z }: angler 1 on the dock tip, angler 2 on the promenade by the wall. Both look toward the lake (+z).
		local spots = { { 2.5, 78 }, { -30, 29 } }
		for i, s in ipairs(spots) do
			local desc = Instance.new("HumanoidDescription")
			desc.HeadColor = skins[i]
			desc.TorsoColor, desc.LeftArmColor, desc.RightArmColor = shirts[i], shirts[i], shirts[i]
			desc.LeftLegColor, desc.RightLegColor = Color3.fromRGB(50, 50, 70), Color3.fromRGB(50, 50, 70)
			local rig = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
			desc:Destroy()
			rig.Name = "Angler" .. i
			for _, d in ipairs(rig:GetDescendants()) do
				if d:IsA("BasePart") then d.Anchored = false end
			end
			local hrp = rig:WaitForChild("HumanoidRootPart")
			local hum = rig:FindFirstChildOfClass("Humanoid")
			hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			hum.WalkSpeed = 0
			rig.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
			rig:SetAttribute("SiteId", row.id)
			local frame = CFL * CF(s[1], 0, s[2]) * ANG(0, PI, 0)
			local p = frame.Position
			rig:PivotTo(CF(p.X, 4.2, p.Z) * frame.Rotation) -- deck top 1.2 + 3 for the rig's root height
			hrp.Anchored = true
			place(rig, folder)
			used += countParts(rig)
		end
	end
	buildAnglers(fishing)

	local function buildFishing(ctx)
		-- Rods: 9 long, 0.15 across, raised 40 degrees toward the water (+z), from the right hand, clear of the lanes.
		local function rod(name, bx, by, bz)
			local a = math.rad(40)
			local d = V(0, math.sin(a), math.cos(a))
			local u = V(0, math.cos(a), -math.sin(a))
			local mid = V(bx, by, bz) + d * 4.5
			ctx:cyl(name, V(9, 0.15, 0.15), CFrame.fromMatrix(mid, d, u, d:Cross(u)), POST_T, WOOD)
		end
		rod("AnglerRod", 3.6, 4.8, 77.5)
		rod("AnglerRod", -31.5, 4.8, 29)
		-- Buckets (1.6 across, 1.6 high) and a cooler box on the promenade.
		vcyl(ctx, "AnglerBucket", -2.9, 76, 1.2, 2.8, 1.6, BUCKET_C, SMOOTH)
		vcyl(ctx, "AnglerBucket", -33.5, 28.5, 1.2, 2.8, 1.6, BUCKET_C, SMOOTH)
		box(ctx, "AnglerCooler", -27, -25, 1.2, 2.2, 28, 30, COOLER_C, SMOOTH)
		-- Drying net on the SE lawn: two poles 8 high and a draped net (Fabric, 8 x 5 x 0.1, 0.4 transparent).
		vcyl(ctx, "NetPole", 43, -4, 0, 8, 0.4, POST_T, WOOD)
		vcyl(ctx, "NetPole", 51, -4, 0, 8, 0.4, POST_T, WOOD)
		box(ctx, "DryingNet", 43, 51, 3, 8, -4.05, -3.95, NET_C, FABRIC).Transparency = 0.4
		-- Fish rack on the lawn: two posts, a bar, and six small flat fish.
		vcyl(ctx, "FishRackPost", 54.5, -14, 0, 5, 0.4, POST_T, WOOD)
		vcyl(ctx, "FishRackPost", 57.5, -14, 0, 5, 0.4, POST_T, WOOD)
		box(ctx, "FishRackBar", 54.5, 57.5, 4.6, 5.0, -14.2, -13.8, POST_T, WOOD)
		for k = 0, 5 do
			box(ctx, "DryingFish", 54.8 + 0.5 * k, 55.2 + 0.5 * k, 2.8, 3.4, -14.4, -13.6, NET_C, SMOOTH)
		end
	end
	section(CFL, fishing, buildFishing)

	------------------------------------------------------------------ LocationMapPanel (container): board on two posts
	local function buildMapPanel(ctx)
		-- Board centre (-7.5, 9.5, -70) local: 14 wide along lz, 9 tall, 0.5 thick. Its Back face (local +Z) points to +lx (SE),
		-- toward the walking lane at lx 8.5.
		local board = ctx:part("MapBoard", V(14, 9, 0.5), CF(-7.5, 9.5, -70) * ANG(0, PI / 2, 0), CREAM, SMOOTH)
		box(ctx, "MapFrame", -8.1, -7.8, 4.6, 14.4, -77.4, -62.6, BROWN, WOOD)
		box(ctx, "MapPost", -8.4, -7.6, 0, 5.0, -75.5, -74.5, BROWN, WOOD)
		box(ctx, "MapPost", -8.4, -7.6, 0, 5.0, -65.5, -64.5, BROWN, WOOD)
		local g = gui(board, Enum.NormalId.Back)
		local function shape(parent, px, py, sx, sy, color, radius)
			local f = Instance.new("Frame")
			f.Position = UDim2.fromScale(px, py)
			f.Size = UDim2.fromScale(sx, sy)
			f.BackgroundColor3 = color
			f.BorderSizePixel = 0
			f.Parent = parent
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(radius, 0)
			c.Parent = f
			return f
		end
		local function text(parent, str, px, py, sx, sy)
			local t = Instance.new("TextLabel")
			t.BackgroundTransparency = 1
			t.Position = UDim2.fromScale(px, py)
			t.Size = UDim2.fromScale(sx, sy)
			t.TextColor3 = TEXT_C
			t.TextScaled = true
			t.TextWrapped = true
			t.Font = Enum.Font.GothamBold
			t.Text = str
			t.Parent = parent
			return t
		end
		local bg = shape(g, 0, 0, 1, 1, CREAM, 0)
		text(bg, "LOCATION MAP", 0.03, 0.02, 0.94, 0.12)
		local lake = shape(bg, 0.03, 0.17, 0.56, 0.7, LAKE_C, 0.12)
		text(lake, "Taal Lake", 0.04, 0.8, 0.4, 0.16)
		shape(lake, 0.4, 0.3, 0.14, 0.175, ISLAND_C, 0.5)
		text(lake, "Volcano Island", 0.3, 0.5, 0.36, 0.1)
		shape(lake, 0.84, 0.12, 0.06, 0.074, PIN_C, 0.5)
		text(lake, "Tagbakin, Brgy. Halang", 0.42, 0.0, 0.52, 0.1)
		text(bg, "Tagbakin sits on the shore of Taal Lake in Barangay Halang, Lipa City.\nThe city records a glamping development at Tagbakin.", 0.63, 0.17, 0.34, 0.6)
		text(bg, "Schematic map, not to scale.", 0.03, 0.9, 0.94, 0.08)
	end
	section(CFL, panel, buildMapPanel)

	------------------------------------------------------------------ Dressing (Model in Structure): palms, lamps, kiosk, benches
	-- Palm, 15 high: three stacked trunk segments (they collide) and six non-colliding fronds at the top.
	local function palm(ctx, x, z)
		local h = 15
		for k = 0, 2 do
			vcyl(ctx, "PalmTrunk", x, z, k * h / 3, (k + 1) * h / 3, 1.2, PTRUNK, WOOD)
		end
		for k = 1, 6 do
			local ang = (k - 1) * PI / 3 + 0.3
			local fr = ctx:part("PalmFrond", V(6.5, 0.3, 1.5), CF(x, h, z) * ANG(0, ang, 0) * CF(3.4, 0, 0) * ANG(0, 0, -0.35), FROND, GRASS)
			fr.CanCollide = false
		end
	end
	-- Lamp post, 9 high, standing on the promenade at lz = lzc(lx) - 4.5, with a neon head.
	local function lamp(ctx, lx)
		local lz = lzc(lx) - 4.5
		vcyl(ctx, "LampPost", lx, lz, 1.2, 10.2, 0.4, LAMP_C, METAL)
		ball(ctx, "LampHead", lx, 10.5, lz, 1.0, NEON, NEONM)
	end
	-- Kiosk (8 x 8) on the SE lawn: a two-thick floor (top 1.2, so it is not a thin plate on grass), four posts, a counter and a stepped thatch roof.
	local function kiosk(ctx)
		box(ctx, "KioskFloor", 48, 56, -0.8, 1.2, 2, 10, PAVE, CONC)
		for _, x in ipairs({ 48.5, 55.5 }) do
			for _, z in ipairs({ 2.5, 9.5 }) do
				vcyl(ctx, "KioskPost", x, z, 1.2, 5.5, 0.5, POST_T, WOOD)
			end
		end
		box(ctx, "KioskCounter", 49, 55, 1.2, 2.6, 9.0, 9.8, TIMBER, WOOD)
		box(ctx, "KioskThatch", 47, 57, 5.5, 6.5, 1, 11, THATCH, GRASS)
		box(ctx, "KioskThatch", 49, 55, 6.5, 7.5, 3, 9, THATCH, GRASS)
	end
	local function buildDressing(ctx)
		-- Palms at the brief's positions, except (54, 8) moved to (60, 6) for the kiosk footprint, and (18, -34) moved to
		-- (14, -34) because its trunk sat on the Guide-to-PavilionR sight-line.
		for _, p in ipairs({ { -56, -8 }, { -52, 8 }, { -48, -22 }, { -62, 4 }, { 50, -6 }, { 60, 6 }, { 48, -22 }, { 58, 18 }, { -44, -34 }, { -24, -34 }, { 14, -34 }, { 34, -34 } }) do
			palm(ctx, p[1], p[2])
		end
		for _, lx in ipairs({ -56, -44, -26, 26, 44, 56 }) do
			lamp(ctx, lx)
		end
		kiosk(ctx)
		-- Two benches on the terrace behind the building, clear of the sight corridors.
		for _, x in ipairs({ -30, 30 }) do
			box(ctx, "TerraceBench", x - 2, x + 2, 1.2, 1.8, -21, -19, TIMBER, WOOD)
			box(ctx, "TerraceBenchBack", x - 2, x + 2, 1.8, 2.8, -21.4, -21, TIMBER, WOOD)
		end
	end
	section(CFL, dressing, buildDressing)

	------------------------------------------------------------------ Swap: old children out, then the plan in small batches
	assert(used <= PART_BUDGET, string.format("site09: %d parts exceeds the %d budget", used, PART_BUDGET))
	for _, child in ipairs(site:GetChildren()) do
		if REPLACED[child.Name] then child:Destroy() end
	end
	-- Containers come first in the plan, so each one is parented empty and then filled part by part.
	for i, e in ipairs(plan) do
		e.inst.Parent = e.dest
		if i % 150 == 0 then task.wait() end
	end

	local pivotAfter = site:GetPivot()
	assert((pivotAfter.Position - pivotBefore.Position).Magnitude < 1e-3 and pivotAfter.LookVector:Dot(pivotBefore.LookVector) > 0.9999,
		"site09: the site pivot changed during the build")
	local total = countParts(site)
	return {
		parts = total,
		keptParts = keptParts,
		builtParts = total - keptParts,
	}
end
