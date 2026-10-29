-- site02_props: the props of Site 02 (Candido B. Lopez Memorial Public Market): price boards, the sample board, goods, baskets, crates, carts and the vendors of the street front and the side yards (Slice 4, jobs R5b-1 and R5b-2).
-- Studio copy: ServerStorage.Builders.site02_props. Assembler: builders/site02.luau. Check: tests/site02_check.luau, groups "yard" and "general".
-- Owns PriceSigns, Produce, Baskets, MarketStalls and VendorNPCs (five Folders directly under Site02_Market). Budget 380 parts; the vendor rigs are outside it (env.addRig).
-- All coordinates are WORLD (x east, z south, y up, ground y 0, apron top y 0.3). The 11 street stalls come from builders/site02_yard.luau (STALLS below is a copy, keep in step):
--   each has a counter part "Stall<i>Table" (x cx+0.5..cx+2.2, z cz-2..cz+2, y 0.3..3.8) with three goods crates on it (x cx+0.8..1.95, tops 0.7 / 0.9 / 0.6 above the counter top).
-- The checks measure boards, goods and vendors against the counters: ^Counter%d*$ (side booths) and the yard's ^Stall%d+Table$.
-- Price boards: one per stall, standing on the counter's east edge, facing the street. Sample board: east edge of the apron, between the Guide box and the tricycle strip.
-- Goods: three produce items per stall on the goods crates, one basket on the middle crate, one stack of three crates at the north end of the apron.
-- Vendors: eight R15 rigs (Players:CreateHumanoidModelFromDescription yields, so this module is only run from a yielding coordinator): Vendor1..4 at the end of a street counter facing east,
--   Vendor5..8 behind a side-yard booth counter (1.5 studs behind it) facing the customers.
-- Side yards (R5b-2): the 21 booths and the 11 awning counters come from builders/site02_yard.luau (BOOTHS below is a copy, keep in step). Booth counters are 6 x 2 (x cx-3..cx+3), top y 3.5; the awning
--   counters are 5 x 2 (x cx-2.5..cx+2.5, z 66..68), cx = -455 + 14 (i - 1). PriceBoard12..22 hang on the front face of the north booths' counters (face -Z), 23..27 on the shed-row booths (face +Z),
--   28..32 on the street-row booths (face -Z). Each booth counter carries a basket and two produce items, each awning counter two produce items. Two hand carts and two crate stacks stand in free spots at the yard ends.
return function(env)
	local V, CF, ANG, PI = env.V, env.CF, env.ANG, env.PI
	local wbox, wvcyl, wball = env.wbox, env.wvcyl, env.wball
	local C3 = Color3.fromRGB
	local MSMO, MWOO, MMET, MWOOD = Enum.Material.SmoothPlastic, Enum.Material.WoodPlanks, Enum.Material.Metal, Enum.Material.Wood
	local SY = 0.3 -- the apron top
	local TOP = SY + 3.5 -- counter top (3.8)
	local HS = { 0.7, 0.9, 0.6 } -- heights of the three goods crates above the counter top (as the yard builds them)
	local WHITE, DARK, STEEL, BASKET = C3(246, 246, 242), C3(30, 34, 42), C3(126, 128, 132), C3(150, 102, 58)
	local CRATE = C3(150, 110, 70)

	-- copy of the yard's STALLS: north cluster 6, south cluster 5
	local STALLS = {
		{ -243.0, 40.0 }, { -236.0, 40.6 }, { -243.4, 47.0 }, { -235.6, 47.5 }, { -243.0, 54.0 }, { -236.2, 53.6 },
		{ -243.2, 254.0 }, { -235.8, 254.5 }, { -243.0, 261.2 }, { -236.0, 260.8 }, { -243.4, 268.0 },
	}
	-- copy of the yard's BOOTHS (side yards): front = which way the customers stand (-1 north, +1 south); c0..c1 = counter z range; roof z0..z1
	local BOOTHS = {}
	for i = 1, 11 do BOOTHS[#BOOTHS + 1] = { cx = -455 + 14 * (i - 1), z0 = 50, z1 = 57, c0 = 53, c1 = 55, front = -1 } end
	for i = 1, 5 do BOOTHS[#BOOTHS + 1] = { cx = -450 + 30 * (i - 1), z0 = 234, z1 = 241, c0 = 238, c1 = 240, front = 1 } end
	for k = 1, 5 do BOOTHS[#BOOTHS + 1] = { cx = -392 + 18 * (k - 1), z0 = 263, z1 = 270, c0 = 265, c1 = 267, front = -1 } end
	local PRICES = {
		"KAMATIS\nP 80/kg", "SIBUYAS\nP 120/kg", "SAGING\nP 60/kg", "MANGGA\nP 150/kg", "BAWANG\nP 160/kg", "TALONG\nP 70/kg",
		"REPOLYO\nP 50/kg", "PATATAS\nP 90/kg", "KALAMANSI\nP 100/kg", "LUYA\nP 130/kg", "ISDA\nP 180/kg",
	}

	-- a SurfaceGui with ONE fixed-size TextLabel on a face of the part (default the +X face: world east for an unrotated part; the parts here are never rotated).
	-- Front is local -Z = world north, Back is local +Z = world south.
	local function signGui(part, text, ppstud, textSize, wrapped, face)
		local g = Instance.new("SurfaceGui")
		g.Face = face or Enum.NormalId.Right
		g.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		g.PixelsPerStud = ppstud
		g.Parent = part
		local t = Instance.new("TextLabel")
		t.Size = UDim2.fromScale(1, 1)
		t.BackgroundTransparency = 1
		t.TextColor3 = DARK
		t.TextScaled = false
		t.TextSize = textSize
		t.TextWrapped = wrapped
		t.Font = Enum.Font.GothamBold
		t.Text = text
		t.Parent = g
	end

	------------------------------------------------------------------ PriceSigns: PriceBoard1..11, SampleBoard with two posts
	env.section("PriceSigns", function(ctx)
		for i, c in ipairs(STALLS) do
			local cx, cz = c[1], c[2]
			-- 3.6 wide (z) x 2.2 tall x 0.2 thick (x), standing on the counter's east edge (x cx+2.0..2.2), centre y 5.0
			local b = wbox(ctx, "PriceBoard" .. i, cx + 2.0, cx + 2.2, TOP + 0.1, TOP + 2.3, cz - 1.8, cz + 1.8, WHITE, MSMO)
			signGui(b, PRICES[(i - 1) % #PRICES + 1], 50, 22, false)
		end
		-- side yard boards 12..32: 3.6 x 2.2 x 0.2, hung on the counter's front face (touching it, y 1.2..3.4), text on the face that looks at the customers
		for n, B in ipairs(BOOTHS) do
			local num = 11 + n
			local b
			if B.front < 0 then
				b = wbox(ctx, "PriceBoard" .. num, B.cx - 1.8, B.cx + 1.8, 1.2, 3.4, B.c0 - 0.2, B.c0, WHITE, MSMO)
			else
				b = wbox(ctx, "PriceBoard" .. num, B.cx - 1.8, B.cx + 1.8, 1.2, 3.4, B.c1, B.c1 + 0.2, WHITE, MSMO)
			end
			signGui(b, PRICES[(num - 1) % #PRICES + 1], 50, 22, false, B.front < 0 and Enum.NormalId.Front or Enum.NormalId.Back)
		end
		-- sample board on the east edge of the apron: 10 (z) x 4 x 0.3 (x), centre (-230.6, 6, 178), on two steel posts
		local sb = wbox(ctx, "SampleBoard", -230.75, -230.45, 4, 8, 173, 183, WHITE, MSMO)
		signGui(sb, "SAMPLE PRICES - FOR ILLUSTRATION", 40, 30, true)
		wvcyl(ctx, "SamplePost1", -230.6, 174.2, SY, 4, 0.4, STEEL, MMET)
		wvcyl(ctx, "SamplePost2", -230.6, 181.8, SY, 4, 0.4, STEEL, MMET)
	end)

	------------------------------------------------------------------ MarketStalls: a stack of three crates at the north end of the apron, two hand carts and two crate stacks in the side yards
	env.section("MarketStalls", function(ctx)
		local yaw = { 0, 0.12, -0.1 }
		local dx = { 0, 0.08, -0.05 }
		for k = 1, 3 do
			local p = env.W(-240.5 + dx[k], SY + 0.8 + (k - 1) * 1.6, 34.7)
			ctx:part("StockCrate" .. k, V(1.6, 1.6, 1.6), CF(p) * ANG(0, yaw[k], 0), CRATE, MWOO)
		end
		-- hand carts (5 parts): bed 5 x 0.4 x 2.5 at y 1.6..2.0 on two wheels (dark disc, axis along z) and two handle bars pointing east; standing on the ground
		local function cart(n, cxc, zc)
			wbox(ctx, "Cart" .. n .. "Bed", cxc - 2.5, cxc + 2.5, 1.6, 2.0, zc - 1.25, zc + 1.25, CRATE, MWOO)
			for k, dz in ipairs({ -1.55, 1.55 }) do
				ctx:cyl("Cart" .. n .. "Wheel" .. k, V(0.3, 1.8, 1.8), CF(env.W(cxc, 0.9, zc + dz)) * ANG(0, PI / 2, 0), DARK, MSMO)
			end
			for k, dz in ipairs({ -0.9, 0.9 }) do
				wbox(ctx, "Cart" .. n .. "Handle" .. k, cxc + 2.0, cxc + 5.0, 1.7, 1.9, zc + dz - 0.1, zc + dz + 0.1, STEEL, MSMO)
			end
		end
		cart(1, -466, 60) -- north yard, west end of the walkway between the booths and the awning
		cart(2, -466, 238) -- south yard, west of the shed-row booths
		-- crate stacks: two crates side by side and one on top (3 parts)
		local function stack(n, x, z)
			ctx:part("CrateStack" .. n .. "A", V(1.6, 1.6, 1.6), CF(env.W(x - 0.85, 0.8, z)), CRATE, MWOO)
			ctx:part("CrateStack" .. n .. "B", V(1.6, 1.6, 1.6), CF(env.W(x + 0.85, 0.8, z)) * ANG(0, 0.08, 0), CRATE, MWOO)
			ctx:part("CrateStack" .. n .. "C", V(1.6, 1.6, 1.6), CF(env.W(x, 2.4, z)) * ANG(0, -0.12, 0), CRATE, MWOO)
		end
		stack(1, -314.5, 60.5) -- north yard, east end of the walkway
		stack(2, -316, 238) -- south yard, east of the shed-row booths
	end)

	------------------------------------------------------------------ Produce: three items per stall on its goods crates (tomato, onion, pepper, squash, banana)
	local KINDS = {
		{ "Tomato", C3(200, 52, 44), "ball", 0.55 },
		{ "Onion", C3(140, 70, 150), "ball", 0.5 },
		{ "Pepper", C3(76, 150, 70), "vcyl", 0.7 },
		{ "Squash", C3(238, 128, 40), "ball", 0.6 },
		{ "Banana", C3(244, 196, 52), "hcyl", 0.6 },
	}
	local function putGood(ctx, name, kd, x, top, z) -- one item standing on a surface at height top
		if kd[3] == "ball" then
			wball(ctx, name, x, top + kd[4] / 2, z, kd[4], kd[2], MSMO)
		elseif kd[3] == "vcyl" then
			wvcyl(ctx, name, x, z, top, top + kd[4], 0.4, kd[2], MSMO)
		else
			ctx:cyl(name, V(kd[4], 0.3, 0.3), CF(env.W(x, top + 0.15, z)), kd[2], MSMO)
		end
	end
	env.section("Produce", function(ctx)
		for i, c in ipairs(STALLS) do
			local cx, cz = c[1], c[2]
			local spots = { -- x, crate top, z
				{ cx + 1.15, TOP + HS[1], cz - 1.5 },
				{ cx + 1.65, TOP + HS[1], cz - 1.1 },
				{ cx + 1.4, TOP + HS[3], cz + 1.3 },
			}
			for k, s in ipairs(spots) do
				local kd = KINDS[(i + k) % #KINDS + 1]
				putGood(ctx, kd[1] .. i .. "_" .. k, kd, s[1], s[2], s[3])
			end
		end
		-- side yards: two items on each booth counter (numbers 12..32), two on each awning counter (33..43); counter top y 3.5
		for n, B in ipairs(BOOTHS) do
			local num, zm = 11 + n, (B.c0 + B.c1) / 2
			for k = 1, 2 do
				local kd = KINDS[(num + k) % #KINDS + 1]
				putGood(ctx, kd[1] .. num .. "_" .. k, kd, B.cx + 0.8 + (k - 1) * 1.3, 3.5, zm + (k == 1 and -0.3 or 0.3))
			end
		end
		for j = 1, 11 do
			local num, cx = 32 + j, -455 + 14 * (j - 1)
			for k = 1, 2 do
				local kd = KINDS[(num + k) % #KINDS + 1]
				putGood(ctx, kd[1] .. num .. "_" .. k, kd, cx - 1.0 + (k - 1) * 2.0, 3.5, 67)
			end
		end
	end)

	------------------------------------------------------------------ Baskets: one woven basket on the middle goods crate of each stall
	env.section("Baskets", function(ctx)
		for i, c in ipairs(STALLS) do
			wvcyl(ctx, "Basket" .. i, c[1] + 1.2, c[2], TOP + HS[2], TOP + HS[2] + 0.9, 1.4, BASKET, MWOOD)
		end
		for n, B in ipairs(BOOTHS) do -- side yards: one basket on each booth counter, left of the goods
			wvcyl(ctx, "Basket" .. (11 + n), B.cx - 1.8, (B.c0 + B.c1) / 2, 3.5, 4.4, 1.4, BASKET, MWOOD)
		end
	end)

	------------------------------------------------------------------ VendorNPCs: eight R15 rigs behind counters
	local Players = game:GetService("Players")
	local SKINS = { C3(224, 172, 130), C3(198, 134, 92), C3(141, 85, 60), C3(241, 194, 125) }
	local SHIRTS = { C3(200, 60, 60), C3(60, 100, 170), C3(230, 200, 80), C3(90, 150, 100) }
	-- stall indices: two in the north cluster, two in the south. Each vendor stands 1.2 west of the stall pole and 2.9 south of its centre line (just past the counter's south end,
	-- clear of the stock crate and the pole), facing east toward the street, HRP centre y 3.3 (apron 0.3 + 3.0)
	local VENDOR_STALLS = { 1, 6, 7, 10 }
	local VENDORS = {}
	for _, si in ipairs(VENDOR_STALLS) do
		local c = STALLS[si]
		table.insert(VENDORS, { pos = V(c[1] - 1.2, SY + 3.0, c[2] + 2.9), dir = V(1, 0, 0) })
	end
	-- side yards (ground y 0, HRP centre y 3.0): 1.5 studs behind a booth counter, facing the customers. North booths 3 and 8, shed-row booth S2 (BOOTHS[13]), street-row booth S8 (BOOTHS[19]).
	for _, bi in ipairs({ 3, 8, 13, 19 }) do
		local B = BOOTHS[bi]
		if B.front < 0 then
			table.insert(VENDORS, { pos = V(B.cx, 3.0, B.c1 + 1.5), dir = V(0, 0, -1) })
		else
			table.insert(VENDORS, { pos = V(B.cx, 3.0, B.c0 - 1.5), dir = V(0, 0, 1) })
		end
	end
	for n, vd in ipairs(VENDORS) do
		local pos = vd.pos
		local desc = Instance.new("HumanoidDescription")
		desc.HeadColor = SKINS[(n - 1) % #SKINS + 1]
		local shirt = SHIRTS[(n - 1) % #SHIRTS + 1]
		desc.TorsoColor, desc.LeftArmColor, desc.RightArmColor = shirt, shirt, shirt
		desc.LeftLegColor, desc.RightLegColor = C3(50, 50, 70), C3(50, 50, 70)
		local rig = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
		desc:Destroy()
		rig.Name = "Vendor" .. n
		for _, d in ipairs(rig:GetDescendants()) do
			if d:IsA("BasePart") then d.Anchored = false end
		end
		local hrp = rig:WaitForChild("HumanoidRootPart")
		local hum = rig:FindFirstChildOfClass("Humanoid")
		hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		hum.WalkSpeed = 0
		rig.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
		rig:SetAttribute("SiteId", 2)
		local animate = rig:FindFirstChild("Animate")
		if animate then animate:Destroy() end
		rig:PivotTo(CFrame.lookAt(pos, pos + vd.dir))
		hrp.Anchored = true
		env.addRig(rig)
	end
end
