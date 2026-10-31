-- site08_context: the course, the pond props, the Mount Malarayat backdrop, the Leisure Spaces board and the planting (Revision 2).
-- Studio copy: ServerStorage.Builders.site08_context (run through builders/site08.luau only). World frame throughout.
-- Reused from the Revision 1 builder with these changes: the hole-3 bench moves out of the new west lagoon (386,572 -> 404,600); two pond-B rim
-- boulders (446,850), (456,853), the palm (455,862) and the palm (430,830) give way to the hotel and its pool terrace; the pines drop from 16 to the
-- ones clear of the board's woods; the board's dense broadleaf woods are added (Structure/Woods), every tree tested against the pinned lanes,
-- keep-clear boxes and sight-lines (env.sightClear) and kept off the greens, tees, fairway corridors, ponds and buildings.
-- Revision 3 (owner look, 2026-10-31): the MountainBackdrop's stacked cylinder tiers (they read as tanks) become a faceted wedge ridge behind the
-- clubhouse; the Woods move to site08_course (one exclusion list with the new course); the pines and palms that stood in the new mountain or on
-- the new course move (briefs/site08.md Revision 3); the bunker boulders step off the new bunker plates.
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
		for _, p in ipairs({ { 714, 650 }, { 732, 600 }, { 372, 694 }, { 426, 728 }, { 698, 604 } }) do
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

	------------------------------------------------------------------ MountainBackdrop (Revision 3): the board's Mount Malarayat as a faceted wedge ridge
	-- A heightfield of triangles (two WedgeParts each, the site09_taal method) in the corner behind the clubhouse. The foot runs along x + z = 1480
	-- from (758, 722) to (602, 878), 50 studs behind the clubhouse's rear wall (x + z = 1429); the back row sits on the slot edges x 758 / z 878.
	-- Columns d = x - z (13, from the east end to the north-west end), rows foot / mid / ridge / back. The summit (90 above the ground, y about 127)
	-- stands behind the clubhouse seen from the gate (as far right as the sites_check pin x >= 690 allows), with shoulders rising from the left,
	-- as on the board. Two low arms widen it in the board view:
	-- east along x 734..757 south to z 566 (x >= 748 beside hole 2's green and bunker), and north-west along z 866..878 to x 548 (behind the pool).
	-- Every part anchored, CanCollide/CanQuery/CanTouch/CastShadow false. BackdropPeak = the wedge reaching the summit (sites_check: x >= 690, y >= 60).
	local THICK, PEAK_H = 2, 90
	local MT = {
		FOREST = Color3.fromRGB(56, 96, 58), LOW = Color3.fromRGB(64, 104, 68), HIGH = Color3.fromRGB(76, 110, 92), SUMMIT = Color3.fromRGB(90, 118, 112),
	}
	local SUN = V(-0.45, 0.75, -0.5).Unit
	local function mwedge(ctx, size, cf, color)
		local w = ctx:wedge("MountainFace", size, cf, color, M.GRASS)
		w.CanCollide, w.CanQuery, w.CanTouch, w.CastShadow = false, false, false, false
		return w
	end
	-- Triangle a, b, c from two wedges (site09_taal: split at the foot of the altitude onto the longest edge). hRel = height band 0..1.
	local function tri(ctx, a, b, c, hRel)
		local nrm = (b - a):Cross(c - a)
		if nrm.Magnitude < 4 then return end
		nrm = nrm.Unit
		if nrm.Y < 0 then nrm = -nrm end
		local base = hRel < 0.3 and MT.FOREST or (hRel < 0.6 and MT.LOW or (hRel < 0.85 and MT.HIGH or MT.SUMMIT))
		local f = 0.72 + 0.28 * math.max(0, nrm:Dot(SUN))
		local color = Color3.new(base.R * f, base.G * f, base.B * f)
		local ab, ac, bc = b - a, c - a, c - b
		local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)
		if abd > acd and abd > bcd then
			c, a = a, c
		elseif acd > bcd and acd > abd then
			a, b = b, a
		end
		ab, ac, bc = b - a, c - a, c - b
		local right = ac:Cross(ab).Unit
		local up = bc:Cross(right).Unit
		local backv = bc.Unit
		local height = math.abs(ab:Dot(up))
		mwedge(ctx, V(THICK, height, math.abs(ab:Dot(backv))), CFrame.fromMatrix((a + b) / 2, right, up, backv), color)
		mwedge(ctx, V(THICK, height, math.abs(ac:Dot(backv))), CFrame.fromMatrix((a + c) / 2, -right, up, -backv), color)
	end
	local RIDGE = { 0, 22, 38, 50, 56, 52, 70, 90, 76, 62, 48, 28, 0 } -- summit at column 7 (d = -146): behind the clubhouse seen from the gate
	local RFRAC = { 0.62, 0.6, 0.64, 0.58, 0.62, 0.6, 0.64, 0.6, 0.62, 0.58, 0.62, 0.6, 0.62 }
	local cols = {}
	for k = 0, 12 do
		local d = 36 - 26 * k
		local fx, fz = (1480 + d) / 2, (1480 - d) / 2
		local kx, kz
		if d >= -120 then kx, kz = 758, 758 - d else kx, kz = 878 + d, 878 end
		local h = RIDGE[k + 1]
		local spur = 0.5 + 0.14 * math.sin(k * 2.1)
		local function at(t, lift)
			local x, z = fx + (kx - fx) * t, fz + (kz - fz) * t
			return { V(x, gnd(x, z) + lift, z), math.max(lift, 0) }
		end
		cols[k] = { at(0, -1), at(0.32, h > 0 and h * spur or -1), at(RFRAC[k + 1], h > 0 and h or -1), at(1, -1) }
	end
	env.section("MountainBackdrop", function(ctx)
		for k = 0, 11 do
			local c0, c1 = cols[k], cols[k + 1]
			for r = 1, 3 do
				local hRel = (c0[r][2] + c0[r + 1][2] + c1[r][2] + c1[r + 1][2]) / 4 / PEAK_H
				local hTop = math.max(c0[r][2], c0[r + 1][2], c1[r][2], c1[r + 1][2]) / PEAK_H
				tri(ctx, c0[r][1], c1[r][1], c1[r + 1][1], (hRel + hTop) / 2)
				tri(ctx, c0[r][1], c1[r + 1][1], c0[r + 1][1], (hRel + hTop) / 2)
			end
		end
		-- East arm: a jagged skyline at x 757 over a foot inboard of it, z 566..734 (south to north).
		local ARM = { 6, 12, 14, 22, 20, 28, 26, 34, 32, 40, 38, 46, 44 }
		local prevF, prevT
		for i = 0, #ARM - 1 do
			local z = 566 + 14 * i
			local fx = z < 650 and 748 or (z < 664 and 748 - (z - 650) or 734)
			local F, T = V(fx, gnd(fx, z) - 1, z), V(757, gnd(757, z) + ARM[i + 1], z)
			if prevF then
				local hRel = (ARM[i] + ARM[i + 1]) / 2 / PEAK_H
				tri(ctx, prevF, F, T, hRel * 0.7)
				tri(ctx, prevF, T, prevT, hRel)
			end
			prevF, prevT = F, T
		end
		-- North-west arm behind the pool: foot z 866, skyline z 878, x 548..604, rising into the main ridge's end.
		local WEST = { { 548, 4 }, { 562, 14 }, { 576, 22 }, { 590, 18 }, { 604, 28 } }
		for i = 1, #WEST - 1 do
			local a, b = WEST[i], WEST[i + 1]
			local F0, F1 = V(a[1], gnd(a[1], 866) - 1, 866), V(b[1], gnd(b[1], 866) - 1, 866)
			local T0, T1 = V(a[1], gnd(a[1], 878) + a[2], 878), V(b[1], gnd(b[1], 878) + b[2], 878)
			local hRel = (a[2] + b[2]) / 2 / PEAK_H
			tri(ctx, F0, F1, T1, hRel * 0.7)
			tri(ctx, F0, T1, T0, hRel)
		end
		-- The one wedge whose box reaches highest carries the pinned name.
		local best, bestY = nil, -math.huge
		for _, p in ipairs(ctx:parts()) do
			local cf, h = p.CFrame, p.Size / 2
			for _, sx in ipairs({ -1, 1 }) do
				for _, sy in ipairs({ -1, 1 }) do
					for _, sz in ipairs({ -1, 1 }) do
						local y = cf:PointToWorldSpace(V(sx * h.X, sy * h.Y, sz * h.Z)).Y
						if y > bestY then best, bestY = p, y end
					end
				end
			end
		end
		assert(best and bestY >= 115, "site08_context: the mountain summit is below y 115")
		assert(best.Position.X >= 690, "site08_context: BackdropPeak's centre is west of x 690 (sites_check pin)")
		best.Name = "BackdropPeak"
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
		-- Revision 3: the row along the south edge and pairs at the mountain foot (the old spots stood on the new fairways, pond or mountain).
		for _, p in ipairs({
			{ 600, 606 }, { 628, 604 }, { 656, 606 }, { 684, 604 }, { 604, 664 },
			{ 690, 660 }, { 700, 752 }, { 716, 738 }, { 600, 860 }, { 472, 622 },
		}) do
			if env.sightClear(p[1], p[2], 5, gnd(p[1], p[2]) + 34) then
				env.pine(ctx, p[1], p[2])
				pinesBuilt += 1
			end
		end
		for _, p in ipairs({
			{ 515, 822 }, { 508, 846 }, { 520, 872 }, { 490, 872 }, { 505, 806 },
			{ 377, 836 }, { 438, 840 }, { 470, 862 },
		}) do
			if env.sightClear(p[1], p[2], 2, gnd(p[1], p[2]) + 18) then env.palm(ctx, p[1], p[2]) end
		end
		for _, p in ipairs({
			{ 470, 650 }, { 480, 680 }, { 600, 600 }, { 586, 614 }, { 642, 598 }, { 712, 600 }, { 696, 668 },
			{ 540, 876 }, { 500, 878 }, { 450, 822 },
		}) do
			env.clump(ctx, p[1], p[2])
		end
	end)
	assert(pinesBuilt >= 6, "site08_context: only " .. pinesBuilt .. " pines clear the sight-lines")
	-- The broadleaf woods (Structure/Woods) moved to site08_course in Revision 3.
end
