-- site02_bands: the band traffic of Site 02, kerb vehicles, utility poles and wires in the north and south bands (job R6a, owner request 2026-10-30).
-- Studio copy: ServerStorage.Builders.site02_bands. Assembler: builders/site02.luau. Check: tests/site02_check.luau, group "bands". Spec: scratch/site02/r6a-positions.md.
-- Owns BandTraffic (a Folder directly under the site). 240 parts: 12 jeepneys x 8 + 8 tricycles x 5 + 12 motorbikes x 4 + 12 poles x 3 + 20 wires.
-- BandJeepney1..12: Models with Kind "Jeepney", parts BJ<n>Body, Hood, Glass, Top, Wheel1..4 (the recipe of site02_traffic, 11.1 long x 6 wide x 6.3 tall).
-- BandTricycle1..8: Models with Kind "Tricycle", parts BTri<n>Body, Roof, Wheel1..3 (8 long x 5.2 wide x 6.3 tall).
-- BandMotorbike1..12: Models with Kind "Motorbike", parts BMB<n>Frame, Seat, Wheel1..2 (5.2 long x 1.2 wide x 3.0 tall). Not drawn in the blueprints.
-- UtilityPole<n>, PoleArm<n>, PoleLamp<n> (n 1..12) and PoleWire<n> (n 1..20) are plain parts directly in BandTraffic.
-- NORTH band: z -5..31, street at z -20..-8, jeepneys 1..6, tricycles 1..4, motorbikes 1..6, poles 1..6 (lamp end -z), wires 1..10.
-- SOUTH band: z 277..325, road at z 344, jeepneys 7..12, tricycles 5..8, motorbikes 7..12, poles 7..12 (lamp end +z), wires 11..20.
-- Everything stands on the ground (y0 0). Nose N is -z, S +z, E +x, W -x.
-- All coordinates are WORLD (x east, z south, y up); wbox and env.W convert to the assembler's local frame. Pure function of env.
return function(env)
	local V, CF, ANG, PI = env.V, env.CF, env.ANG, env.PI
	local wbox, W = env.wbox, env.W
	local C3 = Color3.fromRGB
	local MSMO = Enum.Material.SmoothPlastic
	local DARK, GLASS, WHITE = C3(52, 54, 60), C3(58, 72, 90), C3(238, 234, 224)
	local POLE, WIRE, LAMP = C3(96, 78, 62), C3(34, 34, 38), C3(250, 228, 150)

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
	local bands = env.container("BandTraffic")
	local function newModel(name, kind)
		local model = env.newChild(bands, name, "Model")
		model:SetAttribute("Kind", kind)
		return model
	end
	local Y0 = 0

	------------------------------------------------------------------ jeepneys
	-- { n, centre x, centre z, nose, colour }: 1..6 north (z -1.5, row A), 7..12 south (z 321.5, row A)
	local JEEP = {
		{ 1, -238, -1.5, "E", C3(238, 128, 40) }, { 2, -256, -1.5, "E", C3(44, 110, 200) }, { 3, -300, -1.5, "W", C3(200, 56, 52) },
		{ 4, -330, -1.5, "W", C3(62, 160, 84) }, { 5, -372, -1.5, "E", C3(120, 70, 150) }, { 6, -468, -1.5, "W", C3(240, 200, 60) },
		{ 7, -240, 321.5, "W", C3(40, 150, 160) }, { 8, -278, 321.5, "E", C3(200, 56, 52) }, { 9, -318, 321.5, "W", C3(238, 128, 40) },
		{ 10, -340, 321.5, "W", C3(44, 110, 200) }, { 11, -394, 321.5, "E", C3(240, 200, 60) }, { 12, -466, 321.5, "W", C3(62, 160, 84) },
	}
	for _, j in ipairs(JEEP) do
		local n, cx, cz, nose, col = j[1], j[2], j[3], j[4], j[5]
		local f, rot = frameOf(cx, cz, nose)
		local pre = "BJ" .. n
		env.section("BandTraffic", function(ctx)
			B(ctx, pre .. "Body", f, Y0, -5.5, 2.5, 1.0, 3.4, -2.5, 2.5, col)
			B(ctx, pre .. "Hood", f, Y0, 2.5, 5.5, 1.0, 3.0, -2.3, 2.3, col)
			B(ctx, pre .. "Glass", f, Y0, -5.3, 1.8, 3.4, 5.8, -2.4, 2.4, GLASS)
			B(ctx, pre .. "Top", f, Y0, -5.6, 2.1, 5.8, 6.3, -2.7, 2.7, WHITE)
			local k = 0
			for _, u in ipairs({ -3.5, 3.5 }) do
				for _, s in ipairs({ -1, 1 }) do
					k += 1
					wheel(ctx, pre .. "Wheel" .. k, f, rot, Y0, u, s * 2.65, 0.7)
				end
			end
		end, newModel("BandJeepney" .. n, "Jeepney"))
	end

	------------------------------------------------------------------ tricycles
	-- { n, centre x, centre z, nose, colour }: 1..4 north (z 8.5, row B), 5..8 south (z 314.5, row B)
	local TRI = {
		{ 1, -246, 8.5, "E", C3(150, 110, 190) }, { 2, -285, 8.5, "W", C3(40, 150, 160) },
		{ 3, -340, 8.5, "E", C3(238, 128, 40) }, { 4, -440, 8.5, "W", C3(200, 56, 52) },
		{ 5, -246, 314.5, "W", C3(44, 110, 200) }, { 6, -296, 314.5, "E", C3(240, 200, 60) },
		{ 7, -352, 314.5, "W", C3(62, 160, 84) }, { 8, -430, 314.5, "E", C3(236, 232, 222) },
	}
	for _, t in ipairs(TRI) do
		local n, cx, cz, nose, col = t[1], t[2], t[3], t[4], t[5]
		local f, rot = frameOf(cx, cz, nose)
		local pre = "BTri" .. n
		env.section("BandTraffic", function(ctx)
			B(ctx, pre .. "Body", f, Y0, -4.0, 4.0, 2.0, 5.9, -2.1, 2.1, col)
			B(ctx, pre .. "Roof", f, Y0, -3.0, 3.0, 5.9, 6.3, -2.3, 2.3, col:Lerp(WHITE, 0.5))
			wheel(ctx, pre .. "Wheel1", f, rot, Y0, 3.0, 0, 0.5)
			wheel(ctx, pre .. "Wheel2", f, rot, Y0, -2.6, -2.35, 0.5)
			wheel(ctx, pre .. "Wheel3", f, rot, Y0, -2.6, 2.35, 0.5)
		end, newModel("BandTricycle" .. n, "Tricycle"))
	end

	------------------------------------------------------------------ motorbikes
	-- { centre x, centre z, nose }: 1..6 north, 7..12 south
	local MBCOL = { C3(44, 110, 200), C3(240, 200, 60), C3(200, 56, 52), C3(236, 232, 222), C3(62, 160, 84), C3(238, 128, 40), C3(40, 150, 160), C3(120, 70, 150) }
	local MB = {
		{ -262, 8.0, "E" }, { -268, 9.5, "W" }, { -318, 8.0, "E" }, { -325, 9.0, "E" }, { -396, 8.5, "W" }, { -410, 8.5, "E" },
		{ -262, 314.0, "W" }, { -268, 315.5, "E" }, { -332, 314.0, "E" }, { -374, 314.5, "W" }, { -388, 314.5, "E" }, { -492, 314.5, "W" },
	}
	for n, m in ipairs(MB) do
		local cx, cz, nose = m[1], m[2], m[3]
		local f, rot = frameOf(cx, cz, nose)
		local pre = "BMB" .. n
		env.section("BandTraffic", function(ctx)
			B(ctx, pre .. "Frame", f, Y0, -1.8, 1.8, 0.9, 2.4, -0.5, 0.5, MBCOL[(n + 1) % #MBCOL + 1])
			B(ctx, pre .. "Seat", f, Y0, -2.0, 0.4, 2.4, 3.0, -0.6, 0.6, DARK)
			wheel(ctx, pre .. "Wheel1", f, rot, Y0, -1.6, 0, 0.5)
			wheel(ctx, pre .. "Wheel2", f, rot, Y0, 1.6, 0, 0.5)
		end, newModel("BandMotorbike" .. n, "Motorbike"))
	end

	------------------------------------------------------------------ utility poles and wires
	-- 6 poles a band at x -250 .. -500 step 50; north z 14.5 with the lamp end toward -z, south z 308.5 with the lamp end toward +z
	local POLE_X = { -250, -300, -350, -400, -450, -500 }
	local BAND_POLES = { { z = 14.5, side = -1, first = 1 }, { z = 308.5, side = 1, first = 7 } }
	env.section("BandTraffic", function(ctx)
		for _, b in ipairs(BAND_POLES) do
			for i, px in ipairs(POLE_X) do
				local n = b.first + i - 1
				local lz = b.z + b.side * 3.1
				wbox(ctx, "UtilityPole" .. n, px - 0.45, px + 0.45, 0, 24, b.z - 0.45, b.z + 0.45, POLE, Enum.Material.Wood)
				wbox(ctx, "PoleArm" .. n, px - 0.25, px + 0.25, 22.0, 22.5, b.z - 3.0, b.z + 3.0, POLE, Enum.Material.Wood)
				wbox(ctx, "PoleLamp" .. n, px - 0.6, px + 0.6, 20.6, 21.8, lz - 0.6, lz + 0.6, LAMP, MSMO)
			end
		end
		-- 5 gaps a band, 2 wires a gap at pole z -2.5 and +2.5, each centred between two pole axes and 50 long
		local w = 0
		for _, b in ipairs(BAND_POLES) do
			for g = 1, #POLE_X - 1 do
				local xa, xb = POLE_X[g + 1], POLE_X[g] -- xa < xb
				for _, dz in ipairs({ -2.5, 2.5 }) do
					w += 1
					wbox(ctx, "PoleWire" .. w, xa, xb, 22.2, 22.4, b.z + dz - 0.1, b.z + dz + 0.1, WIRE, MSMO)
				end
			end
		end
	end)
end
