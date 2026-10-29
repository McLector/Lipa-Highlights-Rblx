-- site02_yard: the street front of Site 02 (Candido B. Lopez Memorial Public Market), rebuilt from PublicMarketBP1.jpg and PublicMarketBP2.jpg (Slice 4, job R5a).
-- Studio copy: ServerStorage.Builders.site02_yard. Assembler: builders/site02.luau. Check: tests/site02_check.luau, group "yard".
-- Owns Yard (Model: the apron YardSlab) and Structure/Forecourt (LeanRoof1..3 with LeanPost / LeanBeam / LeanRib, LampPost1..6 with LampHead1..6, StreetStall1..11 Models).
-- NOT built here (later jobs): tricycle queues (x -237..-231), vans, side stalls, SampleBoard. Those strips stay free: tricycles z 100..136 and 184..220, vans z 62..96 and 224..248.
-- All coordinates are WORLD (x east, z south, y up, ground y 0); wbox / wvcyl / wball convert to the assembler's local frame. Pure function of env: nothing is read from the DataModel.
-- Lean-tos (BP2 iso, red mono-pitch roofs along the street edge of the north wing): eave y 8.5, high edge y 12.5, plate 0.4 thick, tin ribs on top, three posts and an eave beam each.
--   LeanRoof1 / LeanRoof2 on the strip north of the hall end wall (high edge at z 71.2 against the wall at 71.4, eave z 58); LeanRoof3 in front of the north wing (high edge
--   x -259.3, just in front of the floor-2 balustrade at x -259.6, eave at x -249, z 71.6..90, 1.5 studs short of the north stair foot at z 91.5). LeanRoof2's east half
--   (x -262.6..-250) has no wall behind it, so its high edge rides on LeanBeam4 and the corner LeanColumn1.
-- Street stalls (BP2 vendors, BP1 umbrella stalls): umbrella on a centre pole, counter 3.5 high above the apron with a cloth skirt, three crates of goods on it, a crate behind.
-- Lamp posts: thin dark posts 10.5 tall with a warm round head, along the kerb of the apron.
return function(env)
	local V = env.V
	local wbox, wvcyl, wball = env.wbox, env.wvcyl, env.wball
	local ox, oz = env.ORIGIN.X, env.ORIGIN.Z
	local C3 = Color3.fromRGB
	local MCON, MSMO, MMET, MFAB, MWOO = Enum.Material.Concrete, Enum.Material.SmoothPlastic, Enum.Material.Metal, Enum.Material.Fabric, Enum.Material.WoodPlanks
	local SLABC, ROOF, RIB = C3(196, 194, 188), C3(172, 78, 72), C3(146, 46, 40)
	local STEEL, LAMPD, LAMPH, COUNTER, WOOD = C3(126, 128, 132), C3(55, 58, 64), C3(255, 222, 140), C3(214, 208, 194), C3(150, 110, 70)
	local UMB = { C3(200, 56, 52), C3(240, 200, 60), C3(62, 160, 84), C3(44, 110, 200), C3(238, 128, 40), C3(240, 238, 230) } -- red, yellow, green, blue, orange, white
	local GOODS = { C3(200, 52, 44), C3(244, 196, 52), C3(76, 150, 70), C3(238, 128, 40), C3(140, 70, 150), C3(232, 120, 150) } -- tomato, mango, greens, oranges, eggplant, pink
	local TH = 0.4
	local SY = 0.3 -- the apron top: things on the apron stand on it

	local function lv(p) return V(p.X - ox, p.Y, p.Z - oz) end

	-- a thin plate: corner O (world), long edge r and slope edge s (world vectors); the top face is the plane through O, raised by off along the up-normal
	local function plate(ctx, name, O, r, s, th, off, color, material)
		local n = r:Cross(s).Unit
		if n.Y < 0 then n = -n end
		local rx = r.Unit
		return ctx:part(name, V(r.Magnitude, th, s.Magnitude), CFrame.fromMatrix(lv(O + r / 2 + s / 2 + n * (off - th / 2)), rx, n, rx:Cross(n)), color, material)
	end

	------------------------------------------------------------------ Yard: the apron
	env.section("Yard", function(ctx)
		wbox(ctx, "YardSlab", -250.4, -229.0, 0, SY, 33.3, 276.3, SLABC, MCON)
	end)

	------------------------------------------------------------------ Structure/Forecourt: lean-to roofs, posts, beams
	-- { low (eave) corner O, long edge r, up-slope edge s }: eave y 8.5, high edge y 12.5
	local ROOFS = {
		{ O = V(-301.0, 8.5, 58.0), r = V(25.0, 0, 0), s = V(0, 4.0, 13.2) }, -- LeanRoof1: strip north of the hall end wall, high edge z 71.2 (wall 71.4)
		{ O = V(-275.0, 8.5, 58.0), r = V(25.0, 0, 0), s = V(0, 4.0, 13.2) }, -- LeanRoof2: beside it
		{ O = V(-249.0, 8.5, 71.6), r = V(0, 0, 18.4), s = V(-10.3, 4.0, 0) }, -- LeanRoof3: in front of the north wing, high edge x -259.3 (balustrade front -259.6)
	}
	local function planeY(R, x, z) -- height of the roof's top plane over a plan point
		local sp = V(R.s.X, 0, R.s.Z)
		local t = ((x - R.O.X) * sp.X + (z - R.O.Z) * sp.Z) / (sp.X * sp.X + sp.Z * sp.Z)
		return R.O.Y + t * R.s.Y
	end

	env.section("Forecourt", function(ctx)
		local nPost, nBeam, nRib = 0, 0, 0
		for i, R in ipairs(ROOFS) do
			plate(ctx, "LeanRoof" .. i, R.O, R.r, R.s, TH, 0, ROOF, MMET)
			local L, rdir = R.r.Magnitude, R.r.Unit
			local sdir = V(R.s.X, 0, R.s.Z).Unit -- plan direction up the slope (away from the eave)
			-- tin ribs: dark strips up the slope, standing 0.2 proud of the plate
			local nr = (L > 20) and 6 or 4
			for k = 0, nr - 1 do
				local t = 0.35 + (L - 0.7) * k / (nr - 1)
				nRib += 1
				plate(ctx, "LeanRib" .. nRib, R.O + rdir * (t - 0.25), R.s, rdir * 0.5, 0.2, 0.2, RIB, MMET)
			end
			-- three posts 0.6 in from the eave edge, tops buried in the plate; an eave beam along them
			for _, f in ipairs({ 0.1, 0.5, 0.9 }) do
				local p = R.O + rdir * (L * f) + sdir * 0.6
				nPost += 1
				wvcyl(ctx, "LeanPost" .. nPost, p.X, p.Z, 0, planeY(R, p.X, p.Z) - 0.2, 0.6, STEEL, MMET)
			end
			nBeam += 1
			local a, b = R.O + sdir * 0.2, R.O + R.r + sdir * 1.0
			local top = planeY(R, R.O.X + sdir.X * 0.6, R.O.Z + sdir.Z * 0.6) - 0.2
			wbox(ctx, "LeanBeam" .. nBeam, math.min(a.X, b.X), math.max(a.X, b.X), top - 0.7, top, math.min(a.Z, b.Z), math.max(a.Z, b.Z), STEEL, MMET)
		end
		-- LeanRoof2 east of the hall end wall (x -262.6) has nothing behind its high edge: a beam under it and a tall corner column
		do
			local R = ROOFS[2]
			local top = planeY(R, -256.0, 70.85) - 0.2
			wbox(ctx, "LeanBeam4", -262.6, -250.0, top - 0.7, top, 70.5, 71.2, STEEL, MMET)
			wvcyl(ctx, "LeanColumn1", -250.5, 70.85, 0, top, 0.6, STEEL, MMET)
		end

		-- lamp posts along the kerb of the apron: collar, thin post 10.5 tall, warm round head, dark cap
		local LAMPZ = { 50, 108, 132, 188, 238, 266 }
		for i, z in ipairs(LAMPZ) do
			local x = -248.8
			wvcyl(ctx, "LampBase" .. i, x, z, SY, SY + 0.9, 1.1, LAMPD, MMET)
			wvcyl(ctx, "LampPost" .. i, x, z, SY, SY + 10.5, 0.6, LAMPD, MMET)
			wball(ctx, "LampHead" .. i, x, SY + 10.8, z, 1.3, LAMPH, MSMO)
			wvcyl(ctx, "LampCap" .. i, x, z, SY + 11.4, SY + 11.65, 1.7, LAMPD, MMET)
		end
	end)

	------------------------------------------------------------------ Structure/Forecourt: street stalls (each a Model)
	-- north cluster 6, south cluster 5 (one column short); small fixed offsets so the rows do not read as a grid; centres stay inside the contract boxes
	local STALLS = {
		{ -243.0, 40.0 }, { -236.0, 40.6 }, { -243.4, 47.0 }, { -235.6, 47.5 }, { -243.0, 54.0 }, { -236.2, 53.6 },
		{ -243.2, 254.0 }, { -235.8, 254.5 }, { -243.0, 261.2 }, { -236.0, 260.8 }, { -243.4, 268.0 },
	}
	local fc = env.container("Forecourt")
	for i, c in ipairs(STALLS) do
		local model = env.newChild(fc, "StreetStall" .. i, "Model")
		env.section("Forecourt", function(ctx)
			local cx, cz = c[1], c[2]
			local A = UMB[(i - 1) % #UMB + 1]
			local B = (i - 1) % #UMB == #UMB - 1 and UMB[1] or UMB[#UMB] -- stripe colour: white, or red under a white umbrella
			local pre = "Stall" .. i
			-- umbrella: centre pole, three stepped discs (wide rim, white or coloured stripe, crown) and a finial ball
			wvcyl(ctx, pre .. "Pole", cx, cz, SY, SY + 8.3, 0.4, STEEL, MMET)
			wvcyl(ctx, pre .. "Rim", cx, cz, SY + 8.3, SY + 8.55, 5.2, A, MFAB)
			wvcyl(ctx, pre .. "Stripe", cx, cz, SY + 8.55, SY + 8.8, 3.6, B, MFAB)
			wvcyl(ctx, pre .. "Crown", cx, cz, SY + 8.8, SY + 9.05, 2.0, A, MFAB)
			wball(ctx, pre .. "Finial", cx, SY + 9.3, cz, 0.6, STEEL, MMET)
			-- counter 3.5 high above the apron (README rule 7), facing the street, cloth skirt in the umbrella colour, three crates of goods on it
			-- (named Table, not Counter: the Counter%d* counts of the market checks stay the sheds' own)
			wbox(ctx, pre .. "Table", cx + 0.5, cx + 2.2, SY, SY + 3.5, cz - 2.0, cz + 2.0, COUNTER, MCON)
			wbox(ctx, pre .. "Skirt", cx + 2.2, cx + 2.38, SY + 0.9, SY + 3.4, cz - 2.0, cz + 2.0, A, MFAB)
			local hs = { 0.7, 0.9, 0.6 }
			for k = 1, 3 do
				local z = cz + (k - 2) * 1.3
				wbox(ctx, pre .. "Goods" .. k, cx + 0.8, cx + 1.95, SY + 3.5, SY + 3.5 + hs[k], z - 0.55, z + 0.55, GOODS[(i + k * 2) % #GOODS + 1], MSMO)
			end
			-- a stock crate behind the counter
			wbox(ctx, pre .. "Stock", cx - 2.2, cx - 1.0, SY, SY + 1.3, cz - 0.8, cz + 0.8, WOOD, MWOO)
		end, model)
	end
end
