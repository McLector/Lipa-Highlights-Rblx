-- site08_context: the course, the pond props, the Mount Malarayat backdrop, the Leisure Spaces board and the planting (Revision 2).
-- Studio copy: ServerStorage.Builders.site08_context (run through builders/site08.luau only). World frame throughout.
-- Reused from the Revision 1 builder with these changes: the hole-3 bench moves out of the new west lagoon (386,572 -> 404,600); two pond-B rim
-- boulders (446,850), (456,853), the palm (455,862) and the palm (430,830) give way to the hotel and its pool terrace; the pines drop from 16 to the
-- ones clear of the board's woods; the board's dense broadleaf woods are added (Structure/Woods), every tree tested against the pinned lanes,
-- keep-clear boxes and sight-lines (env.sightClear) and kept off the greens, tees, fairway corridors, ponds and buildings.
return function(env)
	local V, CF, ANG, PI, S = env.V, env.CF, env.ANG, env.PI, env.S
	local C, M = env.C, env.M
	local box, vcyl, ball, gnd = env.box, env.vcyl, env.ball, env.gnd
	local PADY = env.PADY

	local function inPond(x, z)
		return (x >= 440 and x <= 488 and z >= 772 and z <= 812) or (x >= 452 and x <= 496 and z >= 808 and z <= 848)
	end
	local function boulder(ctx, x, z, d)
		local y = inPond(x, z) and (5.5 + d * 0.1) or (gnd(x, z) + d * 0.2)
		return ball(ctx, "Boulder", x, y, z, d, C.DARK, M.SLATE)
	end

	------------------------------------------------------------------ pond rims and bunker boulders
	env.section("Structure/Pond", function(ctx)
		local rim = {
			{ 446, 770 }, { 458, 769 }, { 470, 769.5 }, { 484, 770 }, { 494, 774 },
			{ 492, 786 }, { 497, 800 }, { 498, 826 }, { 500, 838 },
			{ 486, 852 }, { 470, 853 },
			{ 439, 800 }, { 438, 812 }, { 440, 826 },
			{ 480, 822 }, { 466, 836 }, { 446, 826 }, { 504, 812 }, { 500, 850 },
			{ 476, 780 }, { 478, 806 }, { 462, 810 }, { 500, 790 },
		}
		for i, p in ipairs(rim) do
			boulder(ctx, p[1], p[2], 2.6 + (i % 3) * 0.7)
		end
		for _, p in ipairs({ { 706, 642 }, { 742, 610 }, { 382, 702 }, { 418, 722 }, { 701, 606 } }) do
			boulder(ctx, p[1], p[2], 3)
		end
	end)

	------------------------------------------------------------------ the three holes
	local function signpost(ctx, x, z, label)
		local g = gnd(x, z)
		vcyl(ctx, "DistancePost", x, z, g, g + 2.6, 0.3, C.BROWN, M.WOOD)
		box(ctx, "DistanceSign" .. label, x - 1.2, x + 1.2, g + 2.2, g + 2.9, z - 0.1, z + 0.1, C.WHITE, M.SMOOTH)
	end
	env.section("Structure/Course", function(ctx)
		vcyl(ctx, "IslandFlag", 466, 792, 9.0, 23.0, 0.4, C.WHITE, M.SMOOTH)
		box(ctx, "IslandFlagCloth", 466.2, 468.0, 20.0, 22.5, 791.9, 792.1, C.RED, M.SMOOTH)
		box(ctx, "IslandBridge", 441, 456, 7.0, 8.0, 790, 794, C.TIMBER, M.WOOD)
		for _, p in ipairs({ { 424, 789 }, { 430, 789 }, { 576, 640 }, { 584, 640 }, { 384, 588 }, { 392, 588 } }) do
			ball(ctx, "TeeMarker", p[1], gnd(p[1], p[2]) + 0.6, p[2], 1.4, C.WHITE, M.SMOOTH)
		end
		for _, g in ipairs({ { 724, 620 }, { 400, 716 } }) do
			local base = gnd(g[1], g[2])
			vcyl(ctx, "GreenFlag", g[1], g[2], base, base + 11, 0.35, C.WHITE, M.SMOOTH)
			box(ctx, "GreenFlagCloth", g[1] + 0.2, g[1] + 2.4, base + 9, base + 10.8, g[2] - 0.1, g[2] + 0.1, C.RED, M.SMOOTH)
		end
		for _, p in ipairs({ { 566, 650 }, { 404, 600 } }) do
			local g = gnd(p[1], p[2])
			box(ctx, "TeeBench", p[1] - 2, p[1] + 2, g + 0.8, g + 1.4, p[2] - 1.5, p[2] + 1.5, C.TIMBER, M.WOOD)
		end
		for _, p in ipairs({ { 580, 626 }, { 390, 606 } }) do
			local g = gnd(p[1], p[2])
			vcyl(ctx, "BallWasher", p[1], p[2], g, g + 1.2, 0.8, C.DARK, M.SLATE)
		end
		signpost(ctx, 418, 780, "1")
		signpost(ctx, 592, 630, "2")
		signpost(ctx, 372, 600, "3")
	end)

	------------------------------------------------------------------ MountainBackdrop: tiered summits along the east edge, CanCollide off
	local function mpart(ctx, name, x, z, y0, y1, dia, color)
		local p = vcyl(ctx, name, x, z, y0, y1, dia, color, M.SMOOTH)
		p.CanCollide = false
		return p
	end
	env.section("MountainBackdrop", function(ctx)
		local summits = { { 580, 0.9 }, { 615, 1.0 }, { 650, 0.85 }, { 685, 1.0 }, { 760, 0.95 }, { 800, 1.0 }, { 835, 0.9 }, { 865, 0.85 } }
		for i, s in ipairs(summits) do
			local z, k = s[1], s[2]
			local c1, c2 = i % 2 == 0 and C.MTN or C.MTN_D, i % 2 == 0 and C.MTN_D or C.MTN
			mpart(ctx, "MountainTier", 728, z, 30, 44, 46 * k, c1)
			mpart(ctx, "MountainTier", 728, z, 44, 54, 36 * k, c2)
			mpart(ctx, "MountainTier", 728, z, 54, 62, 24 * k, c1)
		end
		mpart(ctx, "PeakTier", 735, 720, 30, 50, 46, C.MTN_D)
		mpart(ctx, "PeakTier", 735, 720, 50, 60, 38, C.MTN)
		mpart(ctx, "PeakTier", 735, 720, 60, 66, 32, C.MTN_D)
		mpart(ctx, "BackdropPeak", 735, 720, 66, 90, 30, C.MTN)
		for _, z in ipairs({ 598, 668, 742, 848 }) do
			box(ctx, "RidgeBlock", 712, 748, 30, 40, z - 10, z + 10, C.MTN_D, M.SMOOTH).CanCollide = false
		end
	end)

	------------------------------------------------------------------ LeisureSpacesPanel: board on two posts near the Guide (text unchanged)
	env.section("LeisureSpacesPanel", function(ctx)
		local bpos = V(574, PADY + 6.5, 706)
		local rot = CFrame.fromMatrix(bpos, V(S, 0, S), V(0, 1, 0), V(-S, 0, S))
		local board = ctx:part("LeisureBoard", V(12, 7, 0.6), rot, C.BOARD, M.SMOOTH)
		local gui = Instance.new("SurfaceGui")
		gui.Face = Enum.NormalId.Back
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 30
		gui.Parent = board
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(0.94, 0.86)
		label.Position = UDim2.fromScale(0.03, 0.07)
		label.BackgroundTransparency = 1
		label.TextColor3 = C.TEXT
		label.TextScaled = false
		label.TextSize = 16
		label.TextWrapped = true
		label.Font = Enum.Font.GothamBold
		label.Text = "LEISURE SPACES. Mount Malarayat Golf & Country Club is a recreation and hospitality destination in Lipa's mountain setting. It offers golf, accommodation and other leisure facilities; access depends on the service or booking."
		label.Parent = gui
		for _, k in ipairs({ -5, 5 }) do
			local x, z = 574 + k * S, 706 + k * S
			local g = gnd(x, z)
			box(ctx, "LeisurePost", x - 0.4, x + 0.4, g - 0.5, PADY + 3, z - 0.4, z + 0.4, C.BROWN, M.WOOD)
		end
	end)

	------------------------------------------------------------------ pines, palms and shrubs (Structure/Trees)
	local pinesBuilt = 0
	env.section("Structure/Trees", function(ctx)
		for _, p in ipairs({
			{ 612, 612 }, { 640, 606 }, { 664, 636 }, { 628, 664 }, { 664, 684 },
			{ 688, 640 }, { 690, 820 }, { 692, 870 }, { 600, 866 }, { 648, 870 },
		}) do
			if env.sightClear(p[1], p[2], 5, gnd(p[1], p[2]) + 34) then
				env.pine(ctx, p[1], p[2])
				pinesBuilt += 1
			end
		end
		for _, p in ipairs({
			{ 515, 822 }, { 508, 846 }, { 520, 872 }, { 560, 878 }, { 590, 872 }, { 490, 872 }, { 505, 806 },
			{ 377, 836 }, { 438, 840 }, { 470, 862 },
		}) do
			if env.sightClear(p[1], p[2], 2, gnd(p[1], p[2]) + 18) then env.palm(ctx, p[1], p[2]) end
		end
		for _, p in ipairs({
			{ 470, 650 }, { 480, 680 }, { 600, 600 }, { 612, 626 }, { 650, 650 }, { 680, 620 }, { 690, 660 },
			{ 540, 876 }, { 500, 878 }, { 450, 822 },
		}) do
			env.clump(ctx, p[1], p[2])
		end
	end)
	assert(pinesBuilt >= 6, "site08_context: only " .. pinesBuilt .. " pines clear the sight-lines")

	------------------------------------------------------------------ the board's broadleaf woods (Structure/Woods)
	local function localOf(x, z) -- world -> clubhouse local (lx, lz)
		local a, b = (620 - x) / S, (z - 780) / S
		return (a + b) / 2, (a - b) / 2
	end
	local EXCL = {
		{ 436, 500, 766, 852 }, -- ponds A and B
		{ 358, 462, 822, 880 }, -- hotel and its pool terrace
		{ 566, 594, 626, 654 }, { 704, 744, 600, 640 }, { 694, 754, 598, 654 }, -- hole 2 tee, green, bunkers
		{ 372, 424, 576, 734 }, -- hole 3 tee, fairway, green, bunkers
		{ 414, 438, 778, 806 }, -- hole 1 tee
		{ 566, 744, 604, 660 }, -- hole 2 fairway corridor
		{ 512, 584, 664, 728 }, -- Guide plaza, panel, jeep stop
		{ 700, 760, 560, 880 }, -- mountain backdrop strip
		{ 360, 560, 560, 616 }, -- the entrance (site08_entrance owns it)
	}
	local cands = {}
	for x = 368, 750, 14 do
		for z = 622, 874, 14 do
			table.insert(cands, { x + env.rng:NextNumber(-3, 3), z + env.rng:NextNumber(-3, 3) })
		end
	end
	for i = #cands, 2, -1 do
		local j = env.rng:NextInteger(1, i)
		cands[i], cands[j] = cands[j], cands[i]
	end
	env.section("Structure/Woods", function(ctx)
		local n = 0
		for _, p in ipairs(cands) do
			if n >= 70 then break end
			local x, z = p[1], p[2]
			local ok = x > 364 and x < 756 and z < 876
			for _, r in ipairs(EXCL) do
				if ok and x > r[1] - 6 and x < r[2] + 6 and z > r[3] - 6 and z < r[4] + 6 then ok = false end
			end
			local lx, lz = localOf(x, z)
			if ok and lx > -74 and lx < 140 and lz > -32 and lz < 66 then ok = false end
			if ok and env.sightClear(x, z, 7, gnd(x, z) + 17) then
				env.broadleaf(ctx, x, z, 0.9 + env.rng:NextNumber(0, 0.25))
				n += 1
			end
		end
	end)
end
