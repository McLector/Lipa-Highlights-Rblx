-- site02_sheds: the sheds, wet markets, dry goods area, cross aisle and Bagsakan of Site 02 (Candido B. Lopez Memorial Public Market), rebuilt from
-- PublicMarketBP1.jpg (Slice 4, job 5a). Studio copy: ServerStorage.Builders.site02_sheds. Assembler: builders/site02.luau. Check: tests/site02_check.luau, group "sheds".
-- Owns Structure/Sheds/Gabled (Models ShedA..ShedD, Folder MidBands), Structure/Sheds/Markets (Models WetMarket1, WetMarket2, DryGoods, parts CrossAisle*)
-- and Structure/Bagsakan (BagsakanWall/Roof/Door/Glass, TruckBay pads, Truck Models). Numbers: scratch/site02/layout.md 3.4, 3.5; BP1 readings:
-- scratch/site02/audit_bp1.md (a1 wet-market cells, b1..b5 sheds, c1 dry goods, c3 cross aisle, d1..d3 Bagsakan). Naming contract: tests/site02_check.luau header.
-- All coordinates are WORLD (x east, z south, y up); env.wbox / env.W convert to the assembler's local frame. Pure function of env: nothing is read from the DataModel.
-- Sheds: gabled, ridge along x, walls to eave y 11.5, ridge 16, one raised glazed clerestory on the ridge (top 18.7). Shed C stops at z 150.5 (BP1: the central aisle
--   z 150.5..159 is roof-free), so ShedC is 35.5 wide, not the 42.8 of the old text. Each shed column steps down toward the front (east) into a MidBand
--   (eave 8, ridge 12) with a short clerestory; the D band runs on to the cross aisle (BP1: one long ribbed roof); the B band continues as the DryGoods roof.
-- Wet markets: open stall grids (no roof), plus-shaped aisle, 3 rows at the west (tarp stalls) and 4 rows at the east (round table + umbrella stalls).
--   Each stall: Counter, Canopy tarp and one StallPost. WetMarket1 28 stalls (2x3 + 2x3 / 2x4 + 2x4), WetMarket2 35 (2x3 + 3x3 / 2x4 + 3x4).
-- Bagsakan: long low shed (eave 12.5, ridge 16), ridge along z, 6 dock doors under a 12-panel glazed band, 6 TruckBay pads each with one box truck (7 parts).
return function(env)
	local V, CF, ANG, PI = env.V, env.CF, env.ANG, env.PI
	local W, wbox, wvcyl = env.W, env.wbox, env.wvcyl
	local ox, oz = env.ORIGIN.X, env.ORIGIN.Z
	local C3 = Color3.fromRGB
	local MCON, MSMO, MGLA, MMET, MWOO = Enum.Material.Concrete, Enum.Material.SmoothPlastic, Enum.Material.Glass, Enum.Material.Metal, Enum.Material.WoodPlanks
	local WALL, WALLSH, ROOF, DRED = C3(230, 226, 214), C3(214, 208, 194), C3(172, 78, 72), C3(146, 46, 40)
	local GLASS, STEEL, DARK, DOOR = C3(92, 112, 126), C3(126, 128, 132), C3(58, 52, 50), C3(150, 154, 158)
	local RUST, RUSTD, GALV, PAD = C3(146, 76, 64), C3(122, 60, 52), C3(150, 154, 158), C3(62, 62, 64)
	local TARPS = { C3(44, 118, 208), C3(62, 178, 92), C3(238, 128, 40), C3(196, 58, 52), C3(206, 186, 140) } -- blue, green, orange, red, tan
	local CRATE = { C3(175, 70, 60), C3(50, 110, 170), C3(72, 140, 130), C3(150, 110, 70) } -- red, blue, teal, wood
	local TH = 0.4

	local function namer(prefix)
		local n = 0
		return function() n += 1 return prefix .. n end
	end
	local function lv(p) return V(p.X - ox, p.Y, p.Z - oz) end

	-- a thin plate: corner O (world), r along the long edge (world vector), s up the slope (world vector); its top face is the roof plane
	local function slab(ctx, name, O, r, s, color, material)
		local n = r:Cross(s).Unit
		if n.Y < 0 then n = -n end
		local rx = r.Unit
		return ctx:part(name, V(r.Magnitude, TH, s.Magnitude), CFrame.fromMatrix(lv(O + r / 2 + s / 2 - n * (TH / 2)), rx, n, rx:Cross(n)), color, material)
	end
	-- gabled roof with the ridge along x: two slopes with an eave overhang ov (also past the x ends)
	local function roofAlongX(ctx, nm, xa, xb, z0, z1, ye, yr, ov, color)
		local zm = (z0 + z1) / 2
		local m = (yr - ye) / (zm - z0)
		local ya = ye - m * ov
		local r = V(xb - xa + 2 * ov, 0, 0)
		slab(ctx, nm(), V(xa - ov, ya, z0 - ov), r, V(0, yr - ya, zm - (z0 - ov)), color, MMET)
		slab(ctx, nm(), V(xa - ov, ya, z1 + ov), r, V(0, yr - ya, zm - (z1 + ov)), color, MMET)
	end
	-- vertical gable triangle in the plane x = xw, thickness 0.8 on the side given by dir (+1 = toward +x); base z0..z1 at height ye, apex yr at the middle
	local function gable(ctx, nm, xw, dir, z0, z1, ye, yr, color)
		local zm, h, hw, t = (z0 + z1) / 2, yr - ye, (z1 - z0) / 2, 0.8
		local xc = xw + dir * t / 2
		-- a WedgePart has its right angle at +Z bottom and falls toward -Z; X = Y cross Z
		ctx:wedge(nm(), V(t, h, hw), CFrame.fromMatrix(W(xc, ye + h / 2, zm - hw / 2), V(1, 0, 0), V(0, 1, 0), V(0, 0, 1)), color, MCON)
		ctx:wedge(nm(), V(t, h, hw), CFrame.fromMatrix(W(xc, ye + h / 2, zm + hw / 2), V(-1, 0, 0), V(0, 1, 0), V(0, 0, -1)), color, MCON)
	end

	------------------------------------------------------------------ Structure/Sheds/Gabled
	local GAB = env.container("Sheds/Gabled")
	local XA, XB = -471.4, -415.6
	local EAVE, RIDGE = 11.5, 16.0
	local SHED = { A = { 196.7, 232.0 }, B = { 158.6, 190.2 }, C = { 115.0, 150.5 }, D = { 72.2, 107.4 } }
	for _, L in ipairs({ "A", "B", "C", "D" }) do
		local z0, z1 = SHED[L][1], SHED[L][2]
		local zm = (z0 + z1) / 2
		local model = env.newChild(GAB, "Shed" .. L, "Model")
		env.section("Sheds/Gabled", function(ctx)
			local wn, cn = namer("Shed" .. L .. "Wall"), namer("Shed" .. L .. "Column")
			-- four wall plates (north, south, west and east ends) and the glazed strips under the eaves
			wbox(ctx, wn(), XA, XB, 0, EAVE, z0, z0 + 0.8, WALL, MCON)
			wbox(ctx, wn(), XA, XB, 0, EAVE, z1 - 0.8, z1, WALL, MCON)
			wbox(ctx, wn(), XA, XA + 0.8, 0, EAVE, z0 + 0.8, z1 - 0.8, WALL, MCON)
			wbox(ctx, wn(), XB - 0.8, XB, 0, EAVE, z0 + 0.8, z1 - 0.8, WALL, MCON)
			wbox(ctx, wn(), XA + 3, XB - 3, 7.6, 10.4, z0 - 0.15, z0, GLASS, MGLA)
			wbox(ctx, wn(), XA + 3, XB - 3, 7.6, 10.4, z1, z1 + 0.15, GLASS, MGLA)
			gable(ctx, wn, XA, 1, z0, z1, EAVE, RIDGE, WALL)
			gable(ctx, wn, XB, -1, z0, z1, EAVE, RIDGE, WALL)
			-- steel columns on the long sides: both ends and the middle
			for _, x in ipairs({ XA + 0.6, (XA + XB) / 2, XB - 0.6 }) do
				wbox(ctx, cn(), x - 0.4, x + 0.4, 0, EAVE, z0 - 0.6, z0, STEEL, MMET)
				wbox(ctx, cn(), x - 0.4, x + 0.4, 0, EAVE, z1, z1 + 0.6, STEEL, MMET)
			end
			-- red roof slopes, ridge cap, and the clerestory monitor on the ridge (glazed body under a red lid)
			roofAlongX(ctx, namer("Shed" .. L .. "Roof"), XA, XB, z0, z1, EAVE, RIDGE, 0.8, ROOF)
			wbox(ctx, "Shed" .. L .. "Ridge", XA - 0.8, XB + 0.8, RIDGE, RIDGE + 0.45, zm - 0.5, zm + 0.5, DRED, MSMO)
			wbox(ctx, "Shed" .. L .. "Clerestory1", -460.6, -425.7, 14.2, 18.2, zm - 5.35, zm + 5.35, GLASS, MGLA)
			wbox(ctx, "Shed" .. L .. "Clerestory2", -461.2, -425.1, 18.2, 18.7, zm - 6.0, zm + 6.0, ROOF, MMET)
		end, model)
	end

	-- the lower stepped bands: one per shed column (eave 8, ridge 12), D runs on to the cross aisle; each carries a short clerestory
	local BANDS = {
		{ XB, -379.6, SHED.A[1], SHED.A[2], -405.7, -387.7 },
		{ XB, -379.6, SHED.B[1], SHED.B[2], -413.8, -384.3 },
		{ XB, -377.8, SHED.C[1], SHED.C[2], -405.7, -387.7 },
		{ XB, -311.2, SHED.D[1], SHED.D[2], -405.7, -387.7 },
	}
	local mid = env.newFolder("Sheds/Gabled", "MidBands")
	env.section("Sheds/Gabled", function(ctx)
		local rn, wn, cn = namer("MidBand"), namer("BandWall"), namer("BandClerestory")
		for _, b in ipairs(BANDS) do
			local x0, x1, z0, z1, cx0, cx1 = b[1], b[2], b[3], b[4], b[5], b[6]
			local zm = (z0 + z1) / 2
			wbox(ctx, wn(), x0, x1, 0, 8, z0, z0 + 0.6, WALLSH, MCON)
			wbox(ctx, wn(), x0, x1, 0, 8, z1 - 0.6, z1, WALLSH, MCON)
			roofAlongX(ctx, rn, x0, x1, z0, z1, 8, 12, 0.6, ROOF)
			wbox(ctx, cn(), cx0, cx1, 10.4, 14.2, zm - 4, zm + 4, GLASS, MGLA)
		end
	end, mid)

	------------------------------------------------------------------ Structure/Sheds/Markets
	local MK = env.container("Sheds/Markets")
	-- one stall: tarp stalls (kind "x", west rows) or round table + umbrella (kind "ring", east rows); cx, cz = cell centre, w along x, d along z
	local function stall(ctx, cn, kn, pn, cx, cz, w, d, kind, ci)
		local tarp = TARPS[ci % #TARPS + 1]
		if kind == "x" then
			wbox(ctx, cn(), cx + 0.9, cx + w / 2 - 0.3, 0, 3.5, cz - d / 2 + 0.7, cz + d / 2 - 0.7, CRATE[ci % 4 + 1], ci % 4 == 3 and MWOO or MSMO)
			wvcyl(ctx, pn(), cx, cz, 0, 8.4, 0.45, STEEL, MMET)
			wbox(ctx, kn(), cx - w / 2 + 0.15, cx + w / 2 - 0.15, 8.3, 8.6, cz - d / 2 + 0.15, cz + d / 2 - 0.15, tarp, MSMO)
		else
			wvcyl(ctx, cn(), cx, cz, 0, 3.5, 3.4, CRATE[ci % 4 + 1], ci % 4 == 3 and MWOO or MSMO)
			wvcyl(ctx, pn(), cx, cz, 0, 8.2, 0.4, STEEL, MMET)
			wvcyl(ctx, kn(), cx, cz, 8.0, 8.5, math.min(w, d) - 0.3, tarp, MSMO)
		end
	end
	-- a market: zBlocks = { { z start, columns } ... } across z, three rows then the cross aisle then four rows along x
	local function market(name, X0, dx, aisleX, dz, zBlocks)
		local model = env.newChild(MK, name, "Model")
		env.section("Sheds/Markets", function(ctx)
			local cn, kn, pn = namer("Counter"), namer("Canopy"), namer("StallPost")
			local ci = 0
			for bi, zb in ipairs(zBlocks) do
				for _, band in ipairs({ { "x", X0, 3 }, { "ring", X0 + 3 * dx + aisleX, 4 } }) do
					for row = 0, band[3] - 1 do
						for col = 0, zb[2] - 1 do
							ci += 1
							stall(ctx, cn, kn, pn, band[2] + dx * (row + 0.5), zb[1] + dz * (col + 0.5), dx, dz, band[1], ci + bi + row)
						end
					end
				end
			end
		end, model)
	end
	market("WetMarket1", -373.0, 6.8, 10.8, 7.6, { { 194.4, 2 }, { 194.4 + 2 * 7.6 + 6.2, 2 } }) -- 12 + 16 = 28 stalls
	market("WetMarket2", -373.0, 6.8, 10.8, 6.0, { { 114.6, 2 }, { 114.6 + 2 * 6.0 + 5.8, 3 } }) -- 15 + 20 = 35 stalls

	-- dry goods: two ladder rows of 20 bays at 2.8 pitch either side of a centre aisle with a rail, under the continuation of the B band roof
	do
		local model = env.newChild(MK, "DryGoods", "Model")
		env.section("Sheds/Markets", function(ctx)
			local bn = namer("DryBay")
			for _, zr in ipairs({ { 160.0, 169.0 }, { 180.0, 189.0 } }) do
				for i = 0, 19 do
					local x = -378.4 + 2.8 * i
					wbox(ctx, bn(), x, x + 2.3, 0, 3.5, zr[1], zr[2], CRATE[(i + (zr[1] > 170 and 2 or 0)) % 4 + 1], i % 4 == 3 and MWOO or MSMO)
				end
			end
			wbox(ctx, "DryRail1", -378.4, -322.4, 0, 1.1, 174.35, 174.65, STEEL, MMET)
			roofAlongX(ctx, namer("DryRoof"), -379.6, -311.2, SHED.B[1], SHED.B[2], 8, 12, 0, ROOF)
			local pn = namer("DryPost")
			for _, x in ipairs({ -377.4, -345.0, -313.0 }) do
				wbox(ctx, pn(), x - 0.3, x + 0.3, 0, 8.0, SHED.B[1] + 0.2, SHED.B[1] + 0.8, STEEL, MMET)
				wbox(ctx, pn(), x - 0.3, x + 0.3, 0, 8.0, SHED.B[2] - 0.8, SHED.B[2] - 0.2, STEEL, MMET)
			end
		end, model)
	end

	-- cross aisle: the low canopy strip behind the arcade (high at the wall x -299.7, y 8; low at the outer edge, y 7.2) on slim posts
	env.section("Sheds/Markets", function(ctx)
		local zs = { 71.4, 130.7, 190.0, 249.3 }
		local cols = { RUST, GALV, RUSTD }
		for i = 1, 3 do
			slab(ctx, "CrossAisleRoof" .. i, V(-311.2, 7.2, zs[i]), V(0, 0, zs[i + 1] - zs[i]), V(11.5, 0.8, 0), cols[i], MMET)
		end
		for k = 0, 9 do
			local z = 71.9 + (249.3 - 71.9 - 0.5) * k / 9
			wbox(ctx, "CrossAislePost" .. (k + 1), -310.9, -310.4, 0, 7.0, z - 0.25, z + 0.25, STEEL, MMET)
		end
	end)

	------------------------------------------------------------------ Structure/Bagsakan
	local BAG = env.container("Bagsakan")
	local BX0, BX1, BZ0, BZ1 = -556.0, -506.3, 84.0, 240.6
	local BEAVE, BRIDGE = 12.5, 16.0
	local BAYS = { { 220, 1 }, { 204.3, 2 }, { 191.5, 3 }, { 135, 4 }, { 122.7, 5 }, { 104, 6 } } -- z centre, number (BP1 plan: 3 + 3 round the central gap)
	env.section("Bagsakan", function(ctx)
		local wn = namer("BagsakanWall")
		wbox(ctx, wn(), BX1 - 1.0, BX1, 0, BEAVE, BZ0, BZ1, WALLSH, MCON) -- east wall (dock side)
		wbox(ctx, wn(), BX0, BX0 + 0.8, 0, BEAVE, BZ0 + 0.8, BZ1 - 0.8, WALLSH, MCON)
		wbox(ctx, wn(), BX0 + 0.8, BX1 - 1.0, 0, BEAVE, BZ0, BZ0 + 0.8, WALLSH, MCON)
		wbox(ctx, wn(), BX0 + 0.8, BX1 - 1.0, 0, BEAVE, BZ1 - 0.8, BZ1, WALLSH, MCON)
		-- gable triangles on the north and south ends: vertical plates in a z plane, base x BX0..BX1, apex at the middle
		local xm, hw, h, t = (BX0 + BX1) / 2, (BX1 - BX0) / 2, BRIDGE - BEAVE, 0.8
		for _, e in ipairs({ { BZ0, 1 }, { BZ1, -1 } }) do
			local zc = e[1] + e[2] * t / 2
			-- right angle at +Z bottom: the wedge's +Z is world +x for the west half and world -x for the east half; X = Y cross Z
			ctx:wedge(wn(), V(t, h, hw), CFrame.fromMatrix(W(xm - hw / 2, BEAVE + h / 2, zc), V(0, 0, -1), V(0, 1, 0), V(1, 0, 0)), WALLSH, MCON)
			ctx:wedge(wn(), V(t, h, hw), CFrame.fromMatrix(W(xm + hw / 2, BEAVE + h / 2, zc), V(0, 0, 1), V(0, 1, 0), V(-1, 0, 0)), WALLSH, MCON)
		end
		-- very low pitch roof, ridge along z (BP1: about 8 degrees), 1.0 overhang toward the dock
		local rn = namer("BagsakanRoof")
		local m = (BRIDGE - BEAVE) / ((BX1 - BX0) / 2)
		local ov = 1.0
		local ya = BEAVE - m * ov
		local r = V(0, 0, BZ1 - BZ0 + 1.2)
		slab(ctx, rn(), V(BX0 - ov, ya, BZ0 - 0.6), r, V((BX1 - BX0) / 2 + ov, BRIDGE - ya, 0), ROOF, MMET)
		slab(ctx, rn(), V(BX1 + ov, ya, BZ0 - 0.6), r, V(-((BX1 - BX0) / 2 + ov), BRIDGE - ya, 0), ROOF, MMET)
		wbox(ctx, "BagsakanRidge", xm - 0.5, xm + 0.5, BRIDGE, BRIDGE + 0.45, BZ0 - 0.6, BZ1 + 0.6, DRED, MSMO)
		-- dock side: six dock doors (one per bay) in the lower band, a 12-panel glazed band above
		for _, b in ipairs(BAYS) do
			wbox(ctx, "BagsakanDoor" .. b[2], BX1, BX1 + 0.35, 0, 8.8, b[1] - 3.0, b[1] + 3.0, DOOR, MMET)
		end
		local pitch = (BZ1 - BZ0) / 12
		for i = 0, 11 do
			local zc = BZ0 + pitch * (i + 0.5)
			wbox(ctx, "BagsakanGlass" .. (i + 1), BX1, BX1 + 0.2, 9.8, 12.0, zc - pitch / 2 + 1.0, zc + pitch / 2 - 1.0, GLASS, MGLA)
		end
	end)

	-- truck bays: dark pad (16.6 x 6.4) with one box truck backed to the dock door, cab to the east
	local function truck(ctx, cabCol, boxCol, zc)
		local x0, x1 = -504.7, -490.9 -- box -504.7..-495.2, cab -495.1..-490.9
		wbox(ctx, "TruckBox", x0, -495.2, 1.6, 7.0, zc - 3.0, zc + 3.0, boxCol, MSMO)
		wbox(ctx, "TruckCab", -495.1, x1, 1.4, 5.6, zc - 2.9, zc + 2.9, cabCol, MSMO)
		wbox(ctx, "TruckWindscreen", x1, x1 + 0.3, 3.2, 5.2, zc - 2.3, zc + 2.3, GLASS, MGLA)
		for _, wx in ipairs({ -493.0, -501.5 }) do
			for _, side in ipairs({ -1, 1 }) do
				ctx:cyl("TruckWheel", V(0.9, 2.2, 2.2), CF(W(wx, 1.15, zc + side * 2.85)) * ANG(0, PI / 2, 0), DARK, MSMO)
			end
		end
	end
	local CABS = { C3(44, 118, 208), C3(244, 244, 240), C3(62, 178, 92), C3(238, 128, 40), C3(196, 58, 52), C3(44, 118, 208) }
	local BOXES = { C3(244, 244, 240), C3(206, 186, 140), C3(244, 244, 240), C3(230, 226, 214), C3(244, 244, 240), C3(206, 186, 140) }
	env.section("Bagsakan", function(ctx)
		for _, b in ipairs(BAYS) do
			wbox(ctx, "TruckBay" .. b[2], -504.9, -488.3, 0, 0.15, b[1] - 3.2, b[1] + 3.2, PAD, MCON)
		end
	end)
	for _, b in ipairs(BAYS) do
		local model = env.newChild(BAG, "Truck" .. b[2], "Model")
		env.section("Bagsakan", function(ctx)
			truck(ctx, CABS[b[2]], BOXES[b[2]], b[1])
		end, model)
	end
end
