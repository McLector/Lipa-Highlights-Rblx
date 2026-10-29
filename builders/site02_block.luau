-- site02_block: the corner block and the service block of Site 02 (Candido B. Lopez Memorial Public Market), Slice 4 job r2r3, reworked in job r6. Studio copy: ServerStorage.Builders.site02_block.
-- Assembler: builders/site02.luau. Check: tests/site02_check.luau, group "block" (the exact specification: numbers and names below are binding).
-- Owns Structure/CornerBlock and Structure/ServiceBlock (plain Folders that hold parts directly). All coordinates are WORLD (x east, z south, y up); env.wbox converts.
-- CornerBlock (BP2 isometric, bp2_iso_corner_block.png and bp2_iso_block_whole.png): a boxy four-storey louvred block x -574..-540, z 244..324 (BP2 draws it about 100 long; the
--   slot allows 80 without touching the Bagsakan walls that end at z 241.2), long face parallel to the hall front. Height 30 (four storeys of 7.5) plus a 1.0 parapet.
--   East face: the white and blue-grey checkerboard hoarding in the north half (3 x 4 squares of 8 x 6, z 258..282, y 3..27) inside a thick frame that stands 1.2 proud,
--   louvre grids above the north door and a wrap-round screen at the south end of the face, storey bands cut round the hoarding, vertical panel ribs, two ground doors.
--   South end: one large dense louvre screen (4 panels, 24 slats). North end: three columns of louvres. A very shallow hip roof (BlockHip plates and a ridge beam) sits inside the
--   parapet; BP2 draws no plant boxes. BP1 draws only two storeys; the owner chose BP2's height. No ring logo, no street sign, no text of any kind (not approved).
-- ServiceBlock (BP1 plan top left, BP2 plan and isometric): a low flat-roofed block x -552..-497, z 33..60 (top 9.6) with an annex x -552..-524, z 60..83 (top 9.0), light roof edges,
--   thin overhanging canopy slabs round the eave (BP1 iso), doors 8.4 tall (README rule 7, so the box is taller than the 7 the drawings read), windows and one roll-up door.
--   Pure function of env: nothing is read from the DataModel.
return function(env)
	local wbox = env.wbox
	local V = env.V
	local ox, oz = env.ORIGIN.X, env.ORIGIN.Z
	local C3 = Color3.fromRGB
	local MCON, MSMO, MMET = Enum.Material.Concrete, Enum.Material.SmoothPlastic, Enum.Material.Metal
	local BODY, BAND, PARAPET, PLINTH, RIB = C3(205, 204, 198), C3(232, 230, 224), C3(226, 225, 219), C3(150, 150, 146), C3(184, 183, 177)
	local WHITE, BLUEGREY, FRAME = C3(235, 235, 235), C3(120, 135, 160), C3(60, 64, 72)
	local LOUVRE, SLAT, DOOR, HIPC, HIPRIDGE = C3(92, 96, 104), C3(140, 144, 152), C3(60, 70, 95), C3(146, 150, 156), C3(118, 122, 128)
	local SWALL, SEDGE, SGLASS, SMETAL, SCANOPY = C3(214, 208, 194), C3(150, 152, 156), C3(92, 112, 126), C3(150, 154, 158), C3(196, 196, 192)

	local function namer(prefix)
		local n = 0
		return function() n += 1 return prefix .. n end
	end

	------------------------------------------------------------------ Structure/CornerBlock
	env.section("CornerBlock", function(ctx)
		local X0, X1, Z0, Z1, TOP = -574, -540, 244, 324, 30
		wbox(ctx, "CornerBlockBody", X0, X1, 0, TOP, Z0, Z1, BODY, MCON)
		-- parapet round the flat roof (top 31)
		local pn = namer("BlockParapet")
		wbox(ctx, pn(), X0, X1, TOP, TOP + 1, Z0, Z0 + 1, PARAPET, MCON)
		wbox(ctx, pn(), X0, X1, TOP, TOP + 1, Z1 - 1, Z1, PARAPET, MCON)
		wbox(ctx, pn(), X0, X0 + 1, TOP, TOP + 1, Z0 + 1, Z1 - 1, PARAPET, MCON)
		wbox(ctx, pn(), X1 - 1, X1, TOP, TOP + 1, Z0 + 1, Z1 - 1, PARAPET, MCON)

		-- very shallow hip roof inside the parapet (BP2 draws a clean roof, no plant boxes): footprint x -572.8..-541.2, z 245.2..322.8, eave plane y 30.3, ridge plane y 31.75
		-- (rise 1.45 over the 15.8 half width). Each face is a thin plate (rectangle or right-triangle wedge) whose TOP face is the roof plane, the same technique as the hall roofs;
		-- a trapezoid slope is a rectangle plus two wedges and an end hip is two wedges, so the faces are BlockHip1..10. The ridge beam stands 0.2 above the ridge plane (top 31.95).
		local RX0, RX1, RZ0, RZ1 = X0 + 1.2, X1 - 1.2, Z0 + 1.2, Z1 - 1.2
		local YE, YR, TH = 30.3, 31.75, 0.3
		local function lv(p) return V(p.X - ox, p.Y, p.Z - oz) end
		local function alongZ(u, v, y) return V(v, y, u) end -- (position along the ridge z, across x, height) -> world point
		local function wedgeAt(nm, P, Q1, Q2) -- right-angle plate: right angle at P, legs to Q1 and Q2
			local u1, u2 = Q1 - P, Q2 - P
			local a, b = u1.Magnitude, u2.Magnitude
			u1, u2 = u1 / a, u2 / b
			if u1:Cross(u2).Y < 0 then u1, u2, a, b = u2, u1, b, a end
			local n = u1:Cross(u2)
			local c = P + u1 * (a / 2) + u2 * (b / 2) - n * (TH / 2)
			return ctx:wedge(nm(), V(TH, b, a), CFrame.fromMatrix(lv(c), n, u2, -u1), HIPC, MCON)
		end
		local function tri(nm, A, B, C) -- any triangle as two right-angle plates (A-B must be its longest side)
			local ab = B - A
			local F = A + ab * ((C - A):Dot(ab) / ab:Dot(ab))
			wedgeAt(nm, F, A, C)
			wedgeAt(nm, F, B, C)
		end
		local hn = namer("BlockHip")
		local vm, hw = (RX0 + RX1) / 2, (RX1 - RX0) / 2
		for _, sv in ipairs({ RX0, RX1 }) do
			local O = alongZ(RZ0 + hw, sv, YE)
			local r = alongZ(RZ1 - hw, sv, YE) - O
			local s = alongZ(RZ0 + hw, vm, YR) - O
			local n = r:Cross(s).Unit
			if n.Y < 0 then n = -n end
			local rx = r.Unit
			ctx:part(hn(), V(r.Magnitude, TH, s.Magnitude), CFrame.fromMatrix(lv(O + r / 2 + s / 2 - n * (TH / 2)), rx, n, rx:Cross(n)), HIPC, MCON)
			wedgeAt(hn, alongZ(RZ0 + hw, sv, YE), alongZ(RZ0, sv, YE), alongZ(RZ0 + hw, vm, YR))
			wedgeAt(hn, alongZ(RZ1 - hw, sv, YE), alongZ(RZ1, sv, YE), alongZ(RZ1 - hw, vm, YR))
		end
		tri(hn, alongZ(RZ0, RX0, YE), alongZ(RZ0, RX1, YE), alongZ(RZ0 + hw, vm, YR)) -- north end hip
		tri(hn, alongZ(RZ1, RX0, YE), alongZ(RZ1, RX1, YE), alongZ(RZ1 - hw, vm, YR)) -- south end hip
		local ridge = namer("BlockHipRidge")
		wbox(ctx, ridge(), vm - 0.7, vm + 0.7, 31.55, 31.95, RZ0 + hw, RZ1 - hw, HIPRIDGE, MCON)

		-- plinth along the east face and both ends
		local sn = namer("BlockPlinth")
		wbox(ctx, sn(), X1, X1 + 0.5, 0, 1, Z0, Z1, PLINTH, MCON)
		wbox(ctx, sn(), X0, X1, 0, 1, Z0 - 0.5, Z0, PLINTH, MCON)
		wbox(ctx, sn(), X0, X1, 0, 1, Z1, Z1 + 0.5, PLINTH, MCON)

		-- the checkerboard hoarding on the east face, in the north half: columns by z (258..282), rows by y (3..27), 8 x 6 squares, 0.6 proud of the wall.
		-- BP2 draws white and blue-grey squares (not black).
		local cn = namer("Checker")
		for row = 0, 3 do
			for col = 0, 2 do
				local z, y = 258 + col * 8, 3 + row * 6
				wbox(ctx, cn(), X1, X1 + 0.6, y, y + 6, z, z + 8, (row + col) % 2 == 0 and WHITE or BLUEGREY, MSMO)
			end
		end
		-- frame round the squares, 1.2 proud of the wall (bars 0.8 wide): top, bottom, and the two sides
		local fn = namer("BlockFrame")
		wbox(ctx, fn(), X1, X1 + 1.2, 27, 27.8, 257.2, 282.8, FRAME, MMET)
		wbox(ctx, fn(), X1, X1 + 1.2, 2.2, 3, 257.2, 282.8, FRAME, MMET)
		wbox(ctx, fn(), X1, X1 + 1.2, 3, 27, 257.2, 258, FRAME, MMET)
		wbox(ctx, fn(), X1, X1 + 1.2, 3, 27, 282, 282.8, FRAME, MMET)

		-- storey bands at y 7.5, 15, 22.5: the east face is cut round the hoarding (z 257..283), the ends run full width
		local bn = namer("BlockBand")
		for _, y in ipairs({ 7.5, 15, 22.5 }) do
			wbox(ctx, bn(), X1, X1 + 0.4, y - 0.4, y + 0.4, Z0, 257, BAND, MCON)
			wbox(ctx, bn(), X1, X1 + 0.4, y - 0.4, y + 0.4, 283, Z1, BAND, MCON)
			wbox(ctx, bn(), X0, X1, y - 0.4, y + 0.4, Z0 - 0.4, Z0, BAND, MCON)
			wbox(ctx, bn(), X0, X1, y - 0.4, y + 0.4, Z1, Z1 + 0.4, BAND, MCON)
		end

		-- two ground doors on the east face, 8.8 tall (human scale 8..9.6)
		local dn = namer("BlockDoor")
		wbox(ctx, dn(), X1, X1 + 0.8, 0, 8.8, 249, 255, DOOR, MMET)
		wbox(ctx, dn(), X1, X1 + 0.8, 0, 8.8, 313, 319, DOOR, MMET)

		-- louvre grids: a dark panel (0.7 deep) with lighter slat strips on it (0.4 tall, 0.9 deep).
		-- East face: two panels above the north door (z 245..256) and a wrap-round screen at the south end of the face (z 306..322), clear of the bands and the hoarding.
		-- North end: three columns of 8, two storeys. South end: ONE large dense screen, 4 panels of 7.5 side by side (x -572..-542, y 5..23) with 6 slats each.
		local ln, tn = namer("Louvre"), namer("LouvreSlat")
		for _, e in ipairs({ { 245, 256, 9, 14 }, { 245, 256, 16.5, 21.5 }, { 306, 322, 10, 15.5 }, { 306, 322, 16.5, 22 } }) do
			local za, zb, y0, y1 = e[1], e[2], e[3], e[4]
			wbox(ctx, ln(), X1, X1 + 0.7, y0, y1, za, zb, LOUVRE, MMET)
			for k = 1, 2 do
				local y = y0 + (y1 - y0) * k / 3
				wbox(ctx, tn(), X1, X1 + 0.9, y - 0.2, y + 0.2, za, zb, SLAT, MMET)
			end
		end
		for _, s in ipairs({ { 9, 14 }, { 16.5, 21.5 } }) do
			local y0, y1 = s[1], s[2]
			for _, x in ipairs({ -571, -559, -547 }) do
				wbox(ctx, ln(), x, x + 8, y0, y1, Z0 - 0.7, Z0, LOUVRE, MMET)
				for k = 1, 2 do
					local y = y0 + (y1 - y0) * k / 3
					wbox(ctx, tn(), x, x + 8, y - 0.2, y + 0.2, Z0 - 0.9, Z0, SLAT, MMET)
				end
			end
		end
		for i = 0, 3 do
			local xa = -572 + i * 7.5
			wbox(ctx, ln(), xa, xa + 7.5, 5, 23, Z1, Z1 + 0.7, LOUVRE, MMET)
			for k = 1, 6 do
				local y = 5 + 18 * k / 7
				wbox(ctx, tn(), xa, xa + 7.5, y - 0.2, y + 0.2, Z1, Z1 + 0.9, SLAT, MMET)
			end
		end

		-- vertical panel ribs (BP2 divides the faces into a panel grid): thin darker-concrete strips in the wall gaps between louvre panels, never across the hoarding.
		-- East face (0.5 proud) between the louvres, doors and hoarding; north face between the louvre columns; south face beside the screen.
		local rb = namer("BlockRib")
		for _, z in ipairs({ 244.6, 256.6, 283.6, 290, 298, 304.5, 323.4 }) do
			wbox(ctx, rb(), X1, X1 + 0.5, 1, 29.6, z - 0.4, z + 0.4, RIB, MCON)
		end
		for _, x in ipairs({ -561, -549 }) do
			wbox(ctx, rb(), x - 0.4, x + 0.4, 1, 29.6, Z0 - 0.5, Z0, RIB, MCON)
		end
		for _, x in ipairs({ -573, -541 }) do
			wbox(ctx, rb(), x - 0.4, x + 0.4, 1, 29.6, Z1, Z1 + 0.5, RIB, MCON)
		end
	end)

	------------------------------------------------------------------ Structure/ServiceBlock
	env.section("ServiceBlock", function(ctx)
		wbox(ctx, "ServiceBlockBody", -552, -497, 0, 9.6, 33, 60, SWALL, MCON)
		wbox(ctx, "ServiceAnnex", -552, -524, 0, 9.0, 60, 83, SWALL, MCON)
		-- flat roof edges, 0.6 high: four round the block (top 10.2), three round the annex (top 9.6)
		local en = namer("ServiceRoofEdge")
		wbox(ctx, en(), -552, -497, 9.6, 10.2, 33, 33.6, SEDGE, MCON)
		wbox(ctx, en(), -552, -497, 9.6, 10.2, 59.4, 60, SEDGE, MCON)
		wbox(ctx, en(), -552, -551.4, 9.6, 10.2, 33.6, 59.4, SEDGE, MCON)
		wbox(ctx, en(), -497.6, -497, 9.6, 10.2, 33.6, 59.4, SEDGE, MCON)
		wbox(ctx, en(), -552, -551.4, 9, 9.6, 60, 83, SEDGE, MCON)
		wbox(ctx, en(), -551.4, -524, 9, 9.6, 82.4, 83, SEDGE, MCON)
		wbox(ctx, en(), -524.6, -524, 9, 9.6, 60, 82.4, SEDGE, MCON)
		-- overhanging canopy slabs (BP1 iso draws the block under a flat canopy roof): 0.4 thick, y 9.1..9.5, 1.8 to 2 out from the walls on the north, east and west,
		-- and along the annex's east wall. The north strip is the only one that reaches z 31.2; the side strips start at the wall line so no slab overlaps another.
		local cn = namer("ServiceCanopy")
		wbox(ctx, cn(), -554, -495.2, 9.1, 9.5, 31.2, 33, SCANOPY, MCON)
		wbox(ctx, cn(), -497, -495.2, 9.1, 9.5, 33, 60, SCANOPY, MCON)
		wbox(ctx, cn(), -554, -552, 9.1, 9.5, 33, 83, SCANOPY, MCON)
		wbox(ctx, cn(), -524, -522.2, 9.1, 9.5, 60, 83, SCANOPY, MCON)
		-- doors 8.4 tall with a small hood over each: north face, east face of the block, east face of the annex
		local dn, hn = namer("ServiceDoor"), namer("ServiceHood")
		wbox(ctx, dn(), -549, -543, 0, 8.4, 32.5, 33, DOOR, MMET)
		wbox(ctx, hn(), -549.5, -542.5, 8.6, 9.0, 32.2, 33, SEDGE, MCON)
		wbox(ctx, dn(), -497, -496.5, 0, 8.4, 49, 55, DOOR, MMET)
		wbox(ctx, hn(), -497, -496.2, 8.6, 9.0, 48.5, 55.5, SEDGE, MCON)
		wbox(ctx, dn(), -524, -523.5, 0, 8.4, 66, 72, DOOR, MMET)
		wbox(ctx, hn(), -524, -523.2, 8.6, 9.0, 65.5, 72.5, SEDGE, MCON)
		-- roll-up door on the east face of the block
		wbox(ctx, "ServiceRollup1", -497, -496.6, 0, 5.4, 36, 45, SMETAL, MMET)
		-- windows: four on the north face, one on the annex east face, two on the annex west face
		local wn = namer("ServiceWindow")
		for _, x in ipairs({ -538, -529, -520, -511 }) do
			wbox(ctx, wn(), x, x + 6, 4.5, 7.2, 32.7, 33, SGLASS, Enum.Material.Glass)
		end
		wbox(ctx, wn(), -524, -523.7, 4.5, 7.2, 74.5, 79, SGLASS, Enum.Material.Glass)
		wbox(ctx, wn(), -552.3, -552, 4.5, 7.2, 64, 69, SGLASS, Enum.Material.Glass)
		wbox(ctx, wn(), -552.3, -552, 4.5, 7.2, 73, 78, SGLASS, Enum.Material.Glass)
	end)
end
