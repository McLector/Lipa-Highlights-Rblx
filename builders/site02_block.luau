-- site02_block: the corner block and the service block of Site 02 (Candido B. Lopez Memorial Public Market), Slice 4 job r2r3. Studio copy: ServerStorage.Builders.site02_block.
-- Assembler: builders/site02.luau. Check: tests/site02_check.luau, group "block" (the exact specification: numbers and names below are binding).
-- Owns Structure/CornerBlock and Structure/ServiceBlock (plain Folders that hold parts directly). All coordinates are WORLD (x east, z south, y up); env.wbox converts.
-- CornerBlock (BP2 isometric, bp2_iso_corner_block.png and bp2_iso_block_whole.png): a boxy four-storey louvred block x -574..-540, z 244..324 (BP2 draws it about 100 long; the
--   slot allows 80 without touching the Bagsakan walls that end at z 241.2), long face parallel to the hall front. Height 30 (four storeys of 7.5) plus a 1.0 parapet.
--   East face: the black-and-white checkerboard hoarding (3 x 4 squares of 8 x 6, z 272..296, y 3..27), louvre grids beside it, storey bands, two ground doors.
--   Louvre grids on both end faces. BP1 draws only two storeys; the owner chose BP2's height. No ring logo, no street sign, no text of any kind (not approved).
-- ServiceBlock (BP1 plan top left, BP2 plan and isometric): a low flat-roofed block x -552..-497, z 33..60 (top 9.6) with an annex x -552..-524, z 60..83 (top 9.0), light roof edges,
--   doors 8.4 tall (README rule 7, so the box is taller than the 7 the drawings read), windows and one roll-up door. Pure function of env: nothing is read from the DataModel.
return function(env)
	local wbox = env.wbox
	local C3 = Color3.fromRGB
	local MCON, MSMO, MMET = Enum.Material.Concrete, Enum.Material.SmoothPlastic, Enum.Material.Metal
	local BODY, BAND, PARAPET, PLINTH = C3(205, 204, 198), C3(232, 230, 224), C3(226, 225, 219), C3(150, 150, 146)
	local WHITE, BLACK, FRAME = C3(235, 235, 235), C3(35, 38, 44), C3(60, 64, 72)
	local LOUVRE, SLAT, DOOR, ROOFBOX = C3(92, 96, 104), C3(140, 144, 152), C3(60, 70, 95), C3(170, 172, 170)
	local SWALL, SEDGE, SGLASS, SMETAL = C3(214, 208, 194), C3(150, 152, 156), C3(92, 112, 126), C3(150, 154, 158)

	local function namer(prefix)
		local n = 0
		return function() n += 1 return prefix .. n end
	end

	------------------------------------------------------------------ Structure/CornerBlock
	env.section("CornerBlock", function(ctx)
		local X0, X1, Z0, Z1, TOP = -574, -540, 244, 324, 30
		wbox(ctx, "CornerBlockBody", X0, X1, 0, TOP, Z0, Z1, BODY, MCON)
		-- parapet round the flat roof, and three low plant boxes (top 31.8, inside the 29..32 bound)
		local pn = namer("BlockParapet")
		wbox(ctx, pn(), X0, X1, TOP, TOP + 1, Z0, Z0 + 1, PARAPET, MCON)
		wbox(ctx, pn(), X0, X1, TOP, TOP + 1, Z1 - 1, Z1, PARAPET, MCON)
		wbox(ctx, pn(), X0, X0 + 1, TOP, TOP + 1, Z0 + 1, Z1 - 1, PARAPET, MCON)
		wbox(ctx, pn(), X1 - 1, X1, TOP, TOP + 1, Z0 + 1, Z1 - 1, PARAPET, MCON)
		local rn = namer("BlockRoofBox")
		wbox(ctx, rn(), -566, -558, TOP, TOP + 1.8, 262, 271, ROOFBOX, MCON)
		wbox(ctx, rn(), -553, -545, TOP, TOP + 1.8, 288, 297, ROOFBOX, MCON)
		wbox(ctx, rn(), -567, -560, TOP, TOP + 1.8, 303, 311, ROOFBOX, MCON)
		-- plinth along the east face and both ends
		local sn = namer("BlockPlinth")
		wbox(ctx, sn(), X1, X1 + 0.5, 0, 1, Z0, Z1, PLINTH, MCON)
		wbox(ctx, sn(), X0, X1, 0, 1, Z0 - 0.5, Z0, PLINTH, MCON)
		wbox(ctx, sn(), X0, X1, 0, 1, Z1, Z1 + 0.5, PLINTH, MCON)

		-- the checkerboard hoarding on the east face: columns by z (272..296), rows by y (3..27), 8 x 6 squares, 0.6 proud of the wall
		local cn = namer("Checker")
		for row = 0, 3 do
			for col = 0, 2 do
				local z, y = 272 + col * 8, 3 + row * 6
				wbox(ctx, cn(), X1, X1 + 0.6, y, y + 6, z, z + 8, (row + col) % 2 == 0 and WHITE or BLACK, MSMO)
			end
		end
		local fn = namer("BlockFrame") -- thin frame, 0.3 proud: top, bottom, and the two sides
		wbox(ctx, fn(), X1, X1 + 0.3, 27, 27.6, 271.4, 296.6, FRAME, MMET)
		wbox(ctx, fn(), X1, X1 + 0.3, 2.4, 3, 271.4, 296.6, FRAME, MMET)
		wbox(ctx, fn(), X1, X1 + 0.3, 3, 27, 271.4, 272, FRAME, MMET)
		wbox(ctx, fn(), X1, X1 + 0.3, 3, 27, 296, 296.6, FRAME, MMET)

		-- storey bands at y 7.5, 15, 22.5: the east face is cut round the hoarding (z 272..296), the ends run full width
		local bn = namer("BlockBand")
		for _, y in ipairs({ 7.5, 15, 22.5 }) do
			wbox(ctx, bn(), X1, X1 + 0.4, y - 0.4, y + 0.4, Z0, 272, BAND, MCON)
			wbox(ctx, bn(), X1, X1 + 0.4, y - 0.4, y + 0.4, 296, Z1, BAND, MCON)
			wbox(ctx, bn(), X0, X1, y - 0.4, y + 0.4, Z0 - 0.4, Z0, BAND, MCON)
			wbox(ctx, bn(), X0, X1, y - 0.4, y + 0.4, Z1, Z1 + 0.4, BAND, MCON)
		end

		-- two ground doors on the east face, 8.8 tall (human scale 8..9.6)
		local dn = namer("BlockDoor")
		wbox(ctx, dn(), X1, X1 + 0.8, 0, 8.8, 249, 255, DOOR, MMET)
		wbox(ctx, dn(), X1, X1 + 0.8, 0, 8.8, 313, 319, DOOR, MMET)

		-- louvre grids: a dark panel (0.7 deep) with two lighter slat strips on it. Two storeys high each (y 9..14 and 16.5..21.5), clear of the bands.
		-- East face: beside the hoarding (z 258..270 and 298..310). North and south ends: three columns of 8.
		local ln, tn = namer("Louvre"), namer("LouvreSlat")
		local STOREY = { { 9, 14 }, { 16.5, 21.5 } }
		for _, s in ipairs(STOREY) do
			local y0, y1 = s[1], s[2]
			local function slats(xa, xb, za, zb)
				for k = 1, 2 do
					local y = y0 + (y1 - y0) * k / 3
					wbox(ctx, tn(), xa, xb, y - 0.2, y + 0.2, za, zb, SLAT, MMET)
				end
			end
			for _, z in ipairs({ 258, 298 }) do
				wbox(ctx, ln(), X1, X1 + 0.7, y0, y1, z, z + 12, LOUVRE, MMET)
				slats(X1, X1 + 0.9, z, z + 12)
			end
			for _, x in ipairs({ -571, -559, -547 }) do
				wbox(ctx, ln(), x, x + 8, y0, y1, Z0 - 0.7, Z0, LOUVRE, MMET)
				slats(x, x + 8, Z0 - 0.9, Z0)
				wbox(ctx, ln(), x, x + 8, y0, y1, Z1, Z1 + 0.7, LOUVRE, MMET)
				slats(x, x + 8, Z1, Z1 + 0.9)
			end
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
