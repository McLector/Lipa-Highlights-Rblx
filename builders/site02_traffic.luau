-- site02_traffic: the street traffic of Site 02, tricycles, motorbikes and jeepneys on the apron kerbs and in the side yards (job R5e, owner request 2026-10-30, a busier street).
-- Studio copy: ServerStorage.Builders.site02_traffic. Assembler: builders/site02.luau. Check: tests/site02_check.luau, group "yard" (R5e: street traffic).
-- Owns Yard (the Model that already holds YardSlab, top y 0.3, shared with site02_vehicles). 160 parts: 8 tricycles x 5 + 24 motorbikes x 4 + 3 jeepneys x 8.
-- StreetTricycle1..8: Models with Kind "Tricycle", parts STri<n>Body, STri<n>Roof, STri<n>Wheel1..3 (the TricycleBody/Roof/Wheel recipe of site02_vehicles, 8 long x 5.2 wide x 6.3 tall).
-- Motorbike1..24: Models with Kind "Motorbike", parts MB<n>Frame, MB<n>Seat, MB<n>Wheel1..2 (5.2 long x 1.2 wide x 3.0 tall; wheels Cylinder 2.0 across, 0.5 thick). Not drawn in the blueprints.
-- StreetJeepney1..3: Models with Kind "Jeepney", parts SJ<n>Body, Hood, Glass, Top, Wheel1..4 (the jeepney recipe of site02_vehicles, 11.1 long x 6 wide x 6.3 tall).
-- Apron vehicles stand on the slab (y0 0.3), yard vehicles on the ground (y0 0). Nothing stands in the Guide band z 140..180. Nose N is -z, S +z, E +x, W -x.
-- All coordinates are WORLD (x east, z south, y up); wbox and env.W convert to the assembler's local frame. Pure function of env.
return function(env)
	local V, CF, ANG, PI = env.V, env.CF, env.ANG, env.PI
	local wbox, W = env.wbox, env.W
	local C3 = Color3.fromRGB
	local MSMO = Enum.Material.SmoothPlastic
	local DARK, GLASS, WHITE = C3(52, 54, 60), C3(58, 72, 90), C3(238, 234, 224)
	local SY = 0.3

	-- u runs along the length (nose at +u), w across; returns the world x, z of a point and the yaw that turns a wheel axis (local X) across the vehicle
	local function frameOf(cx, cz, nose)
		if nose == "S" then return function(u, w) return cx + w, cz + u end, 0 end
		if nose == "N" then return function(u, w) return cx + w, cz - u end, 0 end
		if nose == "E" then return function(u, w) return cx + u, cz + w end, PI / 2 end
		return function(u, w) return cx - u, cz + w end, PI / 2
	end
	-- a box in vehicle terms: u0..u1 along, h0..h1 above y0, w0..w1 across
	local function B(ctx, name, f, y0, u0, u1, h0, h1, w0, w1, color)
		local xa, za = f(u0, w0)
		local xb, zb = f(u1, w1)
		wbox(ctx, name, math.min(xa, xb), math.max(xa, xb), y0 + h0, y0 + h1, math.min(za, zb), math.max(za, zb), color, MSMO)
	end
	local function wheel(ctx, name, f, rot, y0, u, w, thick)
		local x, z = f(u, w)
		ctx:cyl(name, V(thick, 2.0, 2.0), CF(W(x, y0 + 1.0, z)) * ANG(0, rot, 0), DARK, MSMO)
	end
	local yard = env.container("Yard")
	local function newModel(name, kind)
		local model = env.newChild(yard, name, "Model")
		model:SetAttribute("Kind", kind)
		return model
	end

	------------------------------------------------------------------ tricycles
	-- { n, centre x, centre z, y0, nose, colour }: 1 and 3 on the apron (north queue end, south pocket), 4..6 in the north yard, 2 and 7..8 in the south yard
	local TRI = {
		{ 1, -234.0, 94.0, SY, "N", C3(40, 150, 160) }, { 2, -391.0, 246.2, 0, "W", C3(238, 128, 40) },
		{ 3, -234.5, 273.5, SY, "E", C3(150, 110, 190) }, { 4, -437.0, 45.5, 0, "E", C3(200, 56, 52) },
		{ 5, -427.5, 45.5, 0, "E", C3(44, 110, 200) }, { 6, -418.0, 45.5, 0, "E", C3(240, 200, 60) },
		{ 7, -410.0, 246.2, 0, "W", C3(62, 160, 84) }, { 8, -400.5, 246.2, 0, "W", C3(236, 232, 222) },
	}
	for _, t in ipairs(TRI) do
		local n, cx, cz, y0, nose, col = t[1], t[2], t[3], t[4], t[5], t[6]
		local f, rot = frameOf(cx, cz, nose)
		local pre = "STri" .. n
		env.section("Yard", function(ctx)
			B(ctx, pre .. "Body", f, y0, -4.0, 4.0, 2.0, 5.9, -2.1, 2.1, col)
			B(ctx, pre .. "Roof", f, y0, -3.0, 3.0, 5.9, 6.3, -2.3, 2.3, col:Lerp(WHITE, 0.5))
			wheel(ctx, pre .. "Wheel1", f, rot, y0, 3.0, 0, 0.5)
			wheel(ctx, pre .. "Wheel2", f, rot, y0, -2.6, -2.35, 0.5)
			wheel(ctx, pre .. "Wheel3", f, rot, y0, -2.6, 2.35, 0.5)
		end, newModel("StreetTricycle" .. n, "Tricycle"))
	end

	------------------------------------------------------------------ motorbikes
	-- 1..12 along the apron east kerb (x -229.7) beside the tricycle queues, 13..16 on the north yard edge, 17..20 in the north van gaps, 21..24 in the south yard
	local MBCOL = { C3(200, 56, 52), C3(44, 110, 200), C3(240, 200, 60), C3(62, 160, 84), C3(238, 128, 40), C3(236, 232, 222), C3(120, 70, 150), C3(40, 150, 160) }
	local MB = {
		{ -229.7, 103.0, SY, "N" }, { -229.7, 109.0, SY, "S" }, { -229.7, 115.0, SY, "N" }, { -229.7, 121.0, SY, "S" },
		{ -229.7, 127.0, SY, "N" }, { -229.7, 133.0, SY, "S" }, { -229.7, 188.0, SY, "N" }, { -229.7, 194.0, SY, "S" },
		{ -229.7, 200.0, SY, "N" }, { -229.7, 206.0, SY, "S" }, { -229.7, 212.0, SY, "N" }, { -229.7, 218.0, SY, "S" },
		{ -468.0, 34.0, 0, "E" }, { -438.0, 34.0, 0, "W" }, { -410.0, 34.0, 0, "E" }, { -372.0, 34.0, 0, "W" },
		{ -408.0, 39.0, 0, "N" }, { -404.2, 39.0, 0, "S" }, { -347.5, 39.0, 0, "N" }, { -343.8, 39.0, 0, "S" },
		{ -446.8, 266.0, 0, "N" }, { -443.2, 266.0, 0, "S" }, { -440.0, 252.5, 0, "N" }, { -436.4, 252.5, 0, "S" },
	}
	for n, m in ipairs(MB) do
		local cx, cz, y0, nose = m[1], m[2], m[3], m[4]
		local f, rot = frameOf(cx, cz, nose)
		local pre = "MB" .. n
		env.section("Yard", function(ctx)
			B(ctx, pre .. "Frame", f, y0, -1.8, 1.8, 0.9, 2.4, -0.5, 0.5, MBCOL[(n - 1) % #MBCOL + 1])
			B(ctx, pre .. "Seat", f, y0, -2.0, 0.4, 2.4, 3.0, -0.6, 0.6, DARK)
			wheel(ctx, pre .. "Wheel1", f, rot, y0, -1.6, 0, 0.5)
			wheel(ctx, pre .. "Wheel2", f, rot, y0, 1.6, 0, 0.5)
		end, newModel("Motorbike" .. n, "Motorbike"))
	end

	------------------------------------------------------------------ jeepneys
	-- { n, centre x, centre z, y0, nose, colour }: 1 and 2 in the apron west lane, 3 in the south yard
	local JEEP = {
		{ 1, -243.5, 66.5, SY, "S", C3(238, 128, 40) }, { 2, -243.5, 236.5, SY, "N", C3(120, 70, 150) }, { 3, -400.0, 273.6, 0, "E", C3(40, 150, 160) },
	}
	for _, j in ipairs(JEEP) do
		local n, cx, cz, y0, nose, col = j[1], j[2], j[3], j[4], j[5], j[6]
		local f, rot = frameOf(cx, cz, nose)
		local pre = "SJ" .. n
		env.section("Yard", function(ctx)
			B(ctx, pre .. "Body", f, y0, -5.5, 2.5, 1.0, 3.4, -2.5, 2.5, col)
			B(ctx, pre .. "Hood", f, y0, 2.5, 5.5, 1.0, 3.0, -2.3, 2.3, col)
			B(ctx, pre .. "Glass", f, y0, -5.3, 1.8, 3.4, 5.8, -2.4, 2.4, GLASS) -- the open passenger bay seen from outside
			B(ctx, pre .. "Top", f, y0, -5.6, 2.1, 5.8, 6.3, -2.7, 2.7, WHITE)
			local k = 0
			for _, u in ipairs({ -3.5, 3.5 }) do
				for _, s in ipairs({ -1, 1 }) do
					k += 1
					wheel(ctx, pre .. "Wheel" .. k, f, rot, y0, u, s * 2.65, 0.7)
				end
			end
		end, newModel("StreetJeepney" .. n, "Jeepney"))
	end
end
