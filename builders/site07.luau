-- site07: The Farm at San Benito (Slice 09). Studio copy: ServerStorage.Builders.site07; run with
--   require(game.ServerStorage.Builders.site07:Clone())()
-- Needs Workspace.Sites.Site07_Farm with its kept children (Guide, InfoPanel, JeepStop, JeepSignPole, JeepSign, Jeepney).
-- IDEMPOTENT: replaces Block, Structure, GardenPavilion, LandscapedPath and WellnessPanel. The kept children are left alone.
-- No terrain change: every thin ground part lies inside the repainted Pavement regions P1..P5 (briefs/site07.md).
-- FRAMES: the site pivot is yawed to W, so it is NOT used as the origin.
--   ORIGIN = CFrame.new(700, 0, 240): world-aligned, +X east, +Z south.
--   FR     = ORIGIN * fromMatrix(0, (0,0,1), (0,1,0), (-1,0,0)): local +Z = W (frontage, outward), local +X = S.
--            World = (700 - lz, y, 240 + lx).
--   The helpers take WORLD coordinates and convert them. A SurfaceGui on the frontage is on Enum.NormalId.Back.
-- Fail-safe order as in site04: everything is built into unparented pieces first; only then are the old children
-- deleted and the new pieces parented one at a time with task.wait(). An error before that leaves the Block untouched.
return function()
	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
	local BuildKit = require(game.ServerStorage.BuildKit:Clone())

	local V, CF, ANG = Vector3.new, CFrame.new, CFrame.Angles
	local PI = math.pi
	local row = SiteData.byId(7)
	assert(row and row.facing == "W", "site07: SiteData row 7 is missing or not facing W")
	local sites = workspace:FindFirstChild("Sites")
	local site = sites and sites:FindFirstChild("Site07_Farm")
	assert(site, "site07: Workspace.Sites.Site07_Farm not found (run builders/placeholders first)")
	local pivotBefore = site:GetPivot()
	assert(math.abs(pivotBefore.Position.X - 700) < 1e-3 and math.abs(pivotBefore.Position.Z - 240) < 1e-3, "site07: pivot is not at (700, 0, 240)")
	local ORIGIN = CF(700, 0, 240)
	local FR = ORIGIN * CFrame.fromMatrix(V(0, 0, 0), V(0, 0, 1), V(0, 1, 0), V(-1, 0, 0))

	local PART_BUDGET = 2500
	local REPLACED = {
		Block = true, Structure = true, GardenPavilion = true, LandscapedPath = true, WellnessPanel = true,
	}

	-- Colours (by eye, from the three Farm photos and the brief's table).
	local ROOF = Color3.fromRGB(62, 66, 64)
	local CREAM = Color3.fromRGB(222, 214, 196)
	local TIMBER = Color3.fromRGB(140, 84, 50)
	local GLASS_C = Color3.fromRGB(150, 190, 190)
	local SLAT = Color3.fromRGB(150, 98, 58)
	local STONE = Color3.fromRGB(200, 194, 182)
	local POOL_B = Color3.fromRGB(58, 78, 74)
	local COPING = Color3.fromRGB(86, 104, 98)
	local WATER = Color3.fromRGB(24, 98, 94) -- dark teal-green, as in Farm_Villa_Pool_Front.jpg (the first pass was bright cyan)
	local POOL_J = Color3.fromRGB(36, 52, 50)
	local RATTAN = Color3.fromRGB(190, 150, 100)
	local TEAL = Color3.fromRGB(60, 170, 170)
	local BLUE = Color3.fromRGB(30, 110, 220)
	local PEBBLE = Color3.fromRGB(62, 62, 66)
	local INLAY = Color3.fromRGB(200, 196, 188)
	local MOSS = Color3.fromRGB(70, 96, 54)
	local STRAW = Color3.fromRGB(128, 104, 62)
	local DARKWOOD = Color3.fromRGB(70, 48, 34)
	local DECK = Color3.fromRGB(96, 64, 44)
	local TRUNK = Color3.fromRGB(120, 98, 70)
	local FROND = Color3.fromRGB(50, 110, 50)
	local SHRUB = Color3.fromRGB(36, 84, 44)
	local STONE_R = Color3.fromRGB(150, 146, 138)
	local REED = Color3.fromRGB(70, 110, 60)
	local LILY = Color3.fromRGB(60, 120, 60)
	local SMOOTH, WOODM = Enum.Material.SmoothPlastic, Enum.Material.Wood
	local SLATE, PEB, GLASSM = Enum.Material.Slate, Enum.Material.Pebble, Enum.Material.Glass
	local GRASSM, FABRIC = Enum.Material.LeafyGrass, Enum.Material.Fabric

	-- Kept-object footprints (measured in Studio): the paving leaves these holes open (plus a margin).
	-- Jeepney + JeepStop pad + sign pole: x 664..676, z 197..226. Guide: x 667..673, z 237..243.
	-- InfoPanel (a wall panel hung at y 1..9): x 675..677, z 245..259.
	local PLAZA_HOLES = {
		{ 664, 676, 197, 226 },
		{ 667, 673, 237, 243 },
		{ 675, 677, 245, 259 },
	}

	-- World -> site-local CFrame (no rotation): lx = z - 240, ly = y, lz = 700 - x.
	local function L(x, y, z)
		return CF(z - 240, y, 700 - x)
	end
	-- Axis-aligned world box x0..x1, y0..y1, z0..z1. Local X carries the world Z extent, local Z the world X extent.
	local function B(ctx, name, x0, x1, y0, y1, z0, z1, color, material)
		return ctx:part(name, V(z1 - z0, y1 - y0, x1 - x0), L((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), color, material)
	end
	-- Vertical cylinder from y0 to y1, centred on (x, z).
	local function VCyl(ctx, name, x, z, y0, y1, dia, color, material)
		return ctx:cyl(name, V(y1 - y0, dia, dia), L(x, (y0 + y1) / 2, z) * ANG(0, 0, PI / 2), color, material)
	end
	local function ball(ctx, name, x, y, z, dia, color, material)
		return ctx:ball(name, dia, L(x, y, z), color, material)
	end
	-- Text on the part's frontage (Back face, which points west).
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
		-- A long line must use a fixed TextSize: TextScaled shrinks a 200-character board to unreadable type.
		t.TextScaled = fixedSize == nil
		if fixedSize then t.TextSize = fixedSize end
		t.TextWrapped = true
		t.Font = Enum.Font.GothamBlack
		t.Text = text
		t.Parent = g
	end

	-- Paves x0..x1, z0..z1 with slabs (top 0.3) on a grid cut at the hole edges. Cells whose centre is inside a hole stay bare.
	local function paveRegion(ctx, name, x0, x1, z0, z1, holes, color, material)
		local xs, zs = { x0, x1 }, { z0, z1 }
		for _, h in ipairs(holes) do
			for _, v in ipairs({ h[1], h[2] }) do
				if v > x0 and v < x1 then table.insert(xs, v) end
			end
			for _, v in ipairs({ h[3], h[4] }) do
				if v > z0 and v < z1 then table.insert(zs, v) end
			end
		end
		table.sort(xs)
		table.sort(zs)
		for i = 1, #xs - 1 do
			for j = 1, #zs - 1 do
				if xs[i + 1] > xs[i] and zs[j + 1] > zs[j] then
					local cx, cz = (xs[i] + xs[i + 1]) / 2, (zs[j] + zs[j + 1]) / 2
					local hole = false
					for _, h in ipairs(holes) do
						if cx > h[1] and cx < h[2] and cz > h[3] and cz < h[4] then hole = true break end
					end
					if not hole then
						B(ctx, name, xs[i], xs[i + 1], 0, 0.3, zs[j], zs[j + 1], color, material)
					end
				end
			end
		end
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

	-- One unparented piece built in the Farm frame. Parts are counted against the budget as they are made.
	local function build(name, fn)
		local model = Instance.new("Model")
		model.Name = name
		local ctx = BuildKit.new(model, FR, { budget = PART_BUDGET - used })
		fn(ctx)
		ctx:flush()
		used += ctx:count()
		return model
	end

	------------------------------------------------------------------ Structure / Villa: slab, terrace, central bay, wings
	local function buildVilla(ctx)
		-- Villa slab and terrace, x 748..794, z 212..268 (light stone).
		B(ctx, "VillaSlab", 748, 794, 0, 0.4, 212, 268, STONE, SMOOTH)
		-- Four rattan loungers (two rows, outside the sight corridor z 230..250) with teal cushions; two blue pots.
		for _, lz in ipairs({ 222, 254 }) do
			for _, lx in ipairs({ 749, 757 }) do
				B(ctx, "Lounger", lx, lx + 6, 0.4, 0.9, lz, lz + 4, RATTAN, SMOOTH)
				B(ctx, "LoungerBack", lx, lx + 1, 0.9, 2.2, lz, lz + 4, RATTAN, SMOOTH)
				B(ctx, "LoungerCushion", lx + 1, lx + 6, 0.9, 1.1, lz + 0.2, lz + 3.8, TEAL, FABRIC)
			end
		end
		VCyl(ctx, "BluePot", 761.5, 219.5, 0.4, 1.8, 1.4, BLUE, SMOOTH)
		VCyl(ctx, "BluePot", 761.5, 260.5, 0.4, 1.8, 1.4, BLUE, SMOOTH)

		-- Central bay (x 764..790, z 228..252): cream walls to y 11.6, timber ceiling. VillaBody is the back wall.
		B(ctx, "VillaBody", 786, 790, 0, 12, 228, 252, CREAM, SMOOTH)
		B(ctx, "BaySideN", 764, 790, 0, 11.6, 228, 229, CREAM, SMOOTH)
		B(ctx, "BaySideS", 764, 790, 0, 11.6, 251, 252, CREAM, SMOOTH)
		B(ctx, "BayCeiling", 764, 790, 11.6, 12, 228, 252, TIMBER, WOODM)
		-- Timber fascia under the eave (y 12..12.5), so the eave tier rests on the bay rather than floating above it.
		B(ctx, "EaveBeam", 764, 790, 12, 12.5, 228, 252, TIMBER, WOODM)

		-- Glass front at x 764: six panes (two groups of three) either side of an open centre z 236..244 (11 high).
		local panes = { { 228, 230.67 }, { 230.67, 233.33 }, { 233.33, 236 }, { 244, 246.67 }, { 246.67, 249.33 }, { 249.33, 252 } }
		for _, p in ipairs(panes) do
			B(ctx, "VillaGlassPane", 763.9, 764.1, 1, 11, p[1] + 0.1, p[2] - 0.1, GLASS_C, GLASSM).Transparency = 0.55
		end
		for _, z in ipairs({ 228, 230.67, 233.33, 236, 244, 246.67, 249.33, 252 }) do
			B(ctx, "GlassPost", 763.6, 764.4, 0, 12, z - 0.2, z + 0.2, TIMBER, WOODM)
		end
		B(ctx, "GlassHead", 763.6, 764.4, 11, 12, 228, 236, TIMBER, WOODM)
		B(ctx, "GlassHead", 763.6, 764.4, 11, 12, 244, 252, TIMBER, WOODM)
		B(ctx, "GlassSill", 763.6, 764.4, 0, 1, 228, 236, TIMBER, WOODM)
		B(ctx, "GlassSill", 763.6, 764.4, 0, 1, 244, 252, TIMBER, WOODM)
		B(ctx, "OpeningHead", 763.6, 764.4, 11, 12, 236, 244, TIMBER, WOODM)

		-- Dining table and four chairs seen through the open centre (table top 2.6..3.0, chairs 2 high, as site04).
		B(ctx, "DiningTop", 773.8, 776.2, 2.6, 3.0, 238.8, 241.2, TIMBER, WOODM)
		for _, lx in ipairs({ 773.9, 776.1 }) do
			for _, lz in ipairs({ 238.9, 241.1 }) do
				B(ctx, "DiningLeg", lx - 0.1, lx + 0.1, 0, 2.6, lz - 0.1, lz + 0.1, DARKWOOD, WOODM)
			end
		end
		local chairs = { { 772.2, 240, -1, 0 }, { 777.8, 240, 1, 0 }, { 775, 237.2, 0, -1 }, { 775, 242.8, 0, 1 } }
		for _, c in ipairs(chairs) do
			local cx, cz, dx, dz = c[1], c[2], c[3], c[4]
			B(ctx, "ChairSeat", cx - 0.7, cx + 0.7, 1.6, 2.0, cz - 0.7, cz + 0.7, TIMBER, WOODM)
			if dx ~= 0 then
				-- The back overlaps the seat edge by 0.15 so it rests on the seat.
				local a, b = math.min(cx + dx * 0.55, cx + dx * 0.9), math.max(cx + dx * 0.55, cx + dx * 0.9)
				B(ctx, "ChairBack", a, b, 2.0, 3.6, cz - 0.7, cz + 0.7, TIMBER, WOODM)
			else
				local a, b = math.min(cz + dz * 0.55, cz + dz * 0.9), math.max(cz + dz * 0.55, cz + dz * 0.9)
				B(ctx, "ChairBack", cx - 0.7, cx + 0.7, 2.0, 3.6, a, b, TIMBER, WOODM)
			end
			for _, lx in ipairs({ cx - 0.55, cx + 0.55 }) do
				for _, lz in ipairs({ cz - 0.55, cz + 0.55 }) do
					B(ctx, "ChairLeg", lx - 0.1, lx + 0.1, 0, 1.6, lz - 0.1, lz + 0.1, DARKWOOD, WOODM)
				end
			end
		end

		-- Central hipped roof as stepped slate tiers: eave at y 12.5 with a deep overhang from x 758; VillaRoof is the cap.
		B(ctx, "VillaRoofEave", 758, 794, 12.5, 13.3, 224, 256, ROOF, SLATE)
		B(ctx, "VillaRoofTier2", 762, 790, 13.3, 14.5, 228, 252, ROOF, SLATE)
		B(ctx, "VillaRoofTier3", 766, 786, 14.5, 15.8, 232, 248, ROOF, SLATE)
		B(ctx, "VillaRoof", 770, 785, 15.8, 17.0, 233, 247, ROOF, SLATE)

		-- Wings: north (z 212..228) and south (z 252..268). Each has its own lower slate roof and slatted screens on the west face.
		for _, w in ipairs({ { 212, 228, 210, 228 }, { 252, 268, 252, 270 } }) do
			B(ctx, "WingBody", 765, 786, 0, 10.5, w[1], w[2], CREAM, SMOOTH)
			-- Timber posts frame the screens under the eave (the photo's wings sit between posts).
			for _, pz in ipairs({ w[1] + 0.3, (w[1] + w[2]) / 2, w[2] - 0.3 }) do
				B(ctx, "WingPost", 763.6, 765.2, 0, 10.5, pz - 0.3, pz + 0.3, TIMBER, WOODM)
			end
			B(ctx, "WingRoof", 762, 788, 10.5, 11.3, w[3], w[4], ROOF, SLATE)
			for z = w[1] + 0.5, w[2] - 0.5, 1 do
				B(ctx, "WingSlat", 764, 765, 0, 9, z - 0.3, z + 0.3, SLAT, WOODM)
			end
		end
	end

	------------------------------------------------------------------ Structure / Pool: raised basin, low west edge, water
	local function buildPool(ctx)
		B(ctx, "PoolFloor", 714, 744, 0, 0.4, 208, 272, POOL_B, SMOOTH)
		B(ctx, "PoolWallN", 714, 744, 0, 1.2, 208, 210, POOL_B, SMOOTH)
		B(ctx, "PoolWallS", 714, 744, 0, 1.2, 270, 272, POOL_B, SMOOTH)
		B(ctx, "PoolWallE", 742, 744, 0, 1.2, 210, 270, POOL_B, SMOOTH)
		B(ctx, "PoolCopingW", 712, 714, 0, 0.5, 208, 272, COPING, SLATE)
		B(ctx, "PoolCopingE", 744, 748, 0, 0.5, 208, 272, COPING, SLATE)
		local water = B(ctx, "PoolWater", 714, 744, 0.4, 1.0, 208, 272, WATER, GLASSM)
		water.Transparency = 0.2
		water.CanCollide = false
		-- Cut-stone joints on the pool's east wall (the photo's wall is laid stone blocks).
		for k = 0, 11 do
			local z = 211 + k * 4.9
			B(ctx, "CopingJoint", 741.9, 742, 0, 1.2, z, z + 0.12, POOL_J, SMOOTH)
		end
	end

	------------------------------------------------------------------ Structure / LagoonEdge: rim stones, reeds, lily pads
	local function buildLagoonEdge(ctx)
		for _, s in ipairs({ { 756, 301 }, { 766, 300.6 }, { 778, 300.6 }, { 790, 301 }, { 797, 305 } }) do
			ball(ctx, "RimStone", s[1], 0.2, s[2], 1.8, STONE_R, SMOOTH)
		end
		for _, r in ipairs({ { 786, 306 }, { 792, 314 }, { 796, 322 }, { 790, 332 } }) do
			VCyl(ctx, "Reed", r[1], r[2], 0, 3, 0.3, REED, GRASSM)
		end
		-- Lily pads: open water is kept in front of the deck (z 322..330).
		VCyl(ctx, "LilyPad", 776, 336, 0, 0.1, 2.4, LILY, GRASSM)
		VCyl(ctx, "LilyPad", 760, 344, 0, 0.1, 2.4, LILY, GRASSM)
	end

	------------------------------------------------------------------ Structure / Palms: trunks collide, fronds do not
	local function palm(ctx, x, z, h)
		local seg = h / 3
		for k = 0, 2 do
			VCyl(ctx, "PalmTrunk", x, z, k * seg, (k + 1) * seg, 1.2, TRUNK, WOODM)
		end
		for k = 1, 8 do
			local ang = (k - 1) * PI / 4 + 0.3
			local fr = ctx:part("PalmFrond", V(9.5, 0.3, 1.8), L(x, h, z) * ANG(0, ang, 0) * CF(4.6, 0, 0) * ANG(0, 0, -0.5), FROND, GRASSM)
			fr.CanCollide = false
		end
	end
	local function buildPalms(ctx)
		-- Only in the allowed zones: north lawn z 120..200, villa rear x 800..826, south z 340..368 (outside the lagoon),
		-- and south-west x 580..640 z 255..335.
		for _, p in ipairs({
			{ 600, 150 }, { 622, 128 }, { 648, 170 }, { 690, 134 }, { 728, 160 }, { 770, 128 }, { 806, 176 }, { 585, 176 }, { 712, 186 },
			{ 816, 218 }, { 816, 264 },
			{ 640, 348 }, { 690, 360 }, { 748, 362 }, { 790, 358 },
			{ 598, 268 }, { 620, 284 }, { 604, 308 }, { 628, 330 },
		}) do
			palm(ctx, p[1], p[2], 16 + (p[1] + p[2]) % 3 * 2) -- 16, 18 or 20 tall (the photo's palms tower over the pavilion)
		end
	end

	------------------------------------------------------------------ Structure / Shrubs: clumps no taller than 2.4
	local function clump(ctx, x, z)
		ball(ctx, "Shrub", x, 1.2, z, 2.4, SHRUB, GRASSM)
		ball(ctx, "Shrub", x + 1.1, 1.1, z + 0.7, 2.0, SHRUB, GRASSM)
		ball(ctx, "Shrub", x - 0.7, 1.0, z - 0.9, 1.8, SHRUB, GRASSM)
	end
	local function buildShrubs(ctx)
		-- Planting either side of the entry path, outside the lane (z 238..242) and the road sight corridor.
		for x = 580, 646, 6 do
			clump(ctx, x, 223)
			clump(ctx, x + 3, 257)
		end
		-- Villa rear, north lawn, beside the pool (north and south) and the south-west lawn.
		for _, z in ipairs({ 220, 228, 236, 244, 252, 260, 268 }) do
			clump(ctx, 803, z)
		end
		for x = 590, 810, 20 do
			clump(ctx, x, 184)
		end
		for x = 716, 786, 14 do
			clump(ctx, x, 200)
			clump(ctx, x, 280)
		end
		for _, p in ipairs({ { 586, 292 }, { 636, 292 }, { 592, 318 }, { 640, 314 }, { 586, 336 }, { 616, 342 } }) do
			clump(ctx, p[1], p[2])
		end
	end

	------------------------------------------------------------------ GardenPavilion (container): deck, posts, round thatched cone
	local function buildPavilion(ctx)
		-- Deck x 728..752, z 292..322. The land end (z 292..300) sits on a solid base inside P5; the rest reaches over the lagoon.
		B(ctx, "PavilionDeck", 728, 752, 0.7, 1.0, 292, 322, DECK, WOODM)
		B(ctx, "DeckLandBase", 728, 752, 0.2, 0.7, 292, 300, DECK, WOODM)
		for _, p in ipairs({ { 730, 302 }, { 750, 302 }, { 730, 320 }, { 750, 320 } }) do
			VCyl(ctx, "DeckPost", p[1], p[2], -3, 0.7, 0.8, DARKWOOD, WOODM)
		end
		-- Railings, 3 high, on the water-facing and side edges (kept clear of lane d at x 708..728).
		B(ctx, "DeckRailW", 728.2, 728.8, 1.0, 4.0, 292, 322, DARKWOOD, WOODM)
		B(ctx, "DeckRailE", 751.2, 751.8, 1.0, 4.0, 292, 322, DARKWOOD, WOODM)
		B(ctx, "DeckRailS", 728.2, 751.8, 1.0, 4.0, 321.2, 321.8, DARKWOOD, WOODM)
		-- Eight posts on radius 8 around (740, 312), eave at y 8.
		for k = 0, 7 do
			local a = k * PI / 4
			VCyl(ctx, "PavilionPost", 740 + 8 * math.cos(a), 312 + 8 * math.sin(a), 0.7, 8, 0.7, DARKWOOD, WOODM)
		end
		-- Round thatched cone: twelve fine tiers on a slightly convex profile (eave at y 8, peak at y 14.8), so it reads as the
		-- photo's smooth hat rather than a stepped pyramid; a dark finial caps it.
		for i = 0, 11 do
			local y0 = 8 + i * 0.57
			VCyl(ctx, "PavilionThatch", 740, 312, y0, y0 + 0.57, 18 * (1 - i / 12) ^ 0.9, STRAW, WOODM)
		end
		ball(ctx, "PavilionFinial", 740, 15.2, 312, 1.4, DARKWOOD, WOODM)
	end

	------------------------------------------------------------------ LandscapedPath (container): entry path, plaza, walks, shore apron
	local function buildPath(ctx)
		-- P1 entry path, x 572..652, z 232..248. PathStart is the first slab (x 572..584).
		B(ctx, "PathStart", 572, 584, 0, 0.3, 232, 248, PEBBLE, PEB)
		B(ctx, "EntryPath", 584, 652, 0, 0.3, 232, 248, PEBBLE, PEB)
		B(ctx, "CurbN", 584, 652, 0, 1, 231, 232, MOSS, GRASSM)
		B(ctx, "CurbS", 584, 652, 0, 1, 248, 249, MOSS, GRASSM)
		-- Fish-scale approximation: staggered white bars in chevron pairs, every 8 studs.
		for x = 588, 644, 8 do
			for _, ang in ipairs({ 0.6, -0.6 }) do
				ctx:part("PathInlay", V(5, 0.06, 0.4), L(x + 2, 0.33, 236) * ANG(0, ang, 0), INLAY, SMOOTH)
				ctx:part("PathInlay", V(5, 0.06, 0.4), L(x + 2, 0.33, 244) * ANG(0, ang, 0), INLAY, SMOOTH)
			end
		end
		-- P2 arrival plaza, x 652..700, z 192..260, with holes where the kept Guide, JeepStop, jeepney and InfoPanel stand.
		paveRegion(ctx, "PlazaSlab", 652, 700, 192, 260, PLAZA_HOLES, PEBBLE, PEB)
		-- P3 east walk, pool surround and villa edges; P4 south walk; P5 shore apron.
		B(ctx, "EastWalkW", 700, 712, 0, 0.3, 204, 260, PEBBLE, PEB)
		B(ctx, "EastWalkN", 712, 796, 0, 0.3, 204, 208, PEBBLE, PEB)
		B(ctx, "EastWalkS", 712, 796, 0, 0.3, 272, 276, PEBBLE, PEB)
		B(ctx, "EdgeN", 748, 796, 0, 0.3, 208, 212, PEBBLE, PEB)
		B(ctx, "EdgeS", 748, 796, 0, 0.3, 268, 272, PEBBLE, PEB)
		B(ctx, "EdgeE", 794, 796, 0, 0.3, 212, 268, PEBBLE, PEB)
		B(ctx, "SouthWalk", 692, 708, 0, 0.3, 260, 300, PEBBLE, PEB)
		B(ctx, "SouthWalkE", 708, 712, 0, 0.3, 260, 276, PEBBLE, PEB)
		B(ctx, "ShoreApron", 708, 752, 0, 0.3, 284, 300, PEBBLE, PEB)
	end

	------------------------------------------------------------------ WellnessPanel (container): signboard on two posts
	local function buildWellness(ctx)
		-- Moved from the brief's z 224..236 to z 204..216: at z 224..236 it blocks the sight-line to the villa glass.
		local board = B(ctx, "WellnessBoard", 702, 704, 3, 9, 204, 216, CREAM, SMOOTH)
		gui(board, "WELLNESS TOURISM. The Farm at San Benito is an operating resort representing Lipa's contemporary wellness tourism: gardens, accommodation, dining and organized activities. Visits involve bookings or paid services.", DARKWOOD, 40, 18)
		B(ctx, "WellnessPost", 702, 704, 0, 3, 205, 206, DARKWOOD, WOODM)
		B(ctx, "WellnessPost", 702, 704, 0, 3, 213, 214, DARKWOOD, WOODM)
	end

	------------------------------------------------------------------ Build, then swap
	local plan = {} -- { inst, into }
	local function add(inst, into)
		table.insert(plan, { inst = inst, into = into })
		return inst
	end

	local ok, err = pcall(function()
		local structure = Instance.new("Folder")
		structure.Name = "Structure"
		add(structure, site)
		add(build("Villa", buildVilla), structure)
		add(build("Pool", buildPool), structure)
		add(build("LagoonEdge", buildLagoonEdge), structure)
		add(build("Palms", buildPalms), structure)
		add(build("Shrubs", buildShrubs), structure)
		add(build("GardenPavilion", buildPavilion), site)
		add(build("LandscapedPath", buildPath), site)
		add(build("WellnessPanel", buildWellness), site)
		assert(used <= PART_BUDGET, string.format("site07: %d parts exceeds the %d budget", used, PART_BUDGET))
	end)
	if not ok then
		for _, e in ipairs(plan) do e.inst:Destroy() end
		error("site07: build failed, the placeholder Block was left untouched: " .. tostring(err), 0)
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
		"site07: the site pivot changed during the build")

	local total = countParts(site)
	return {
		parts = total,
		keptParts = keptParts,
		builtParts = total - keptParts,
	}
end
