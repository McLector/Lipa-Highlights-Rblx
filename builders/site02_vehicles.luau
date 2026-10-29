-- site02_vehicles: the tricycle queue and the parked jeepneys and vans of Site 02 (job R5c; BP1 iso_stairN / iso_northyard, BP2 bp2_iso_vendors_tricycles).
-- Studio copy: ServerStorage.Builders.site02_vehicles. Assembler: builders/site02.luau. Check: tests/site02_check.luau, groups "yard" (tricycles, vehicles).
-- Owns Yard (the Model that already holds YardSlab, top y 0.3). 128 parts: 8 tricycles x 5 + 11 vehicles x 8.
-- Tricycles: TricycleBody<i> (motorcycle and sidecar cabin as one box), TricycleRoof<i> (flat canopy), TricycleWheel<i>1..3 (Cylinder, axis along world X).
--   Centres x -234, z 103.5 / 113 / 122.5 / 132 (north queue) and 188 / 197.5 / 207 / 216.5 (south queue), standing on the apron (y 0.3).
-- Parked vehicles: Models ParkedVehicle1..11 with the attribute Kind (Jeepney or Van), 8 parts each: PV<n>Body, PV<n>Hood, PV<n>Glass, PV<n>Top, PV<n>Wheel1..4.
--   About 11 long x 6 wide x 6.3 tall. Apron vehicles (1..4) nose south on the slab (y 0.3); yard vehicles (5..11) nose east on the ground (y 0).
-- All coordinates are WORLD (x east, z south, y up); wbox and env.W convert to the assembler's local frame. Pure function of env.
return function(env)
	local V, CF, ANG, PI = env.V, env.CF, env.ANG, env.PI
	local wbox, W = env.wbox, env.W
	local C3 = Color3.fromRGB
	local MSMO = Enum.Material.SmoothPlastic
	local DARK, GLASS, WHITE = C3(52, 54, 60), C3(58, 72, 90), C3(238, 234, 224)
	local SY = 0.3

	------------------------------------------------------------------ tricycles
	local TRI_Z = { 103.5, 113.0, 122.5, 132.0, 188.0, 197.5, 207.0, 216.5 }
	local TRI_COL = { C3(200, 56, 52), C3(44, 110, 200), C3(240, 200, 60), C3(62, 160, 84), C3(238, 128, 40), C3(236, 232, 222), C3(120, 70, 150), C3(40, 150, 160) }
	env.section("Yard", function(ctx)
		local cx = -234.0
		for i, z in ipairs(TRI_Z) do
			local col = TRI_COL[i]
			wbox(ctx, "TricycleBody" .. i, cx - 2.1, cx + 2.1, 2.3, 6.2, z - 4.0, z + 4.0, col, MSMO)
			wbox(ctx, "TricycleRoof" .. i, cx - 2.3, cx + 2.3, 6.2, 6.6, z - 3.0, z + 3.0, col:Lerp(WHITE, 0.5), MSMO)
			local spots = { { cx, z - 3.0 }, { cx - 2.35, z + 2.6 }, { cx + 2.35, z + 2.6 } }
			for k, s in ipairs(spots) do
				ctx:cyl("TricycleWheel" .. i .. k, V(0.5, 2.0, 2.0), CF(W(s[1], SY + 1.0, s[2])), DARK, MSMO)
			end
		end
	end)

	------------------------------------------------------------------ parked jeepneys and vans
	-- nose "z": long axis along z, nose south (+z), wheels already point sideways; nose "x": long axis along x, nose east (+x), wheels turned 90 degrees about Y
	local JEEP = { C3(200, 56, 52), C3(44, 110, 200), C3(240, 200, 60), C3(62, 160, 84) }
	local VANC = { C3(240, 238, 230), C3(150, 154, 160), C3(232, 220, 190), C3(160, 200, 230) }
	local VEH = {
		{ "Jeepney", -233.5, 68, SY, "z", JEEP[1] }, { "Jeepney", -233.5, 80, SY, "z", JEEP[2] },
		{ "Jeepney", -233.5, 229, SY, "z", JEEP[3] }, { "Jeepney", -233.5, 241, SY, "z", JEEP[4] },
		{ "Van", -450, 39, 0, "x", VANC[1] }, { "Jeepney", -420, 39, 0, "x", JEEP[2] }, { "Van", -390, 39, 0, "x", VANC[2] },
		{ "Jeepney", -360, 39, 0, "x", JEEP[3] }, { "Van", -330, 39, 0, "x", VANC[3] },
		{ "Van", -455, 266, 0, "x", VANC[4] }, { "Van", -435, 266, 0, "x", VANC[1] },
	}
	local yard = env.container("Yard")
	for n, v in ipairs(VEH) do
		local kind, cx, cz, y0, nose, col = v[1], v[2], v[3], v[4], v[5], v[6]
		local model = env.newChild(yard, "ParkedVehicle" .. n, "Model")
		model:SetAttribute("Kind", kind)
		env.section("Yard", function(ctx)
			local pre = "PV" .. n
			-- u along the length (nose at +u), w across, h above the ground of the vehicle
			local function B(name, u0, u1, h0, h1, w0, w1, color)
				if nose == "z" then
					wbox(ctx, pre .. name, cx + w0, cx + w1, y0 + h0, y0 + h1, cz + u0, cz + u1, color, MSMO)
				else
					wbox(ctx, pre .. name, cx + u0, cx + u1, y0 + h0, y0 + h1, cz + w0, cz + w1, color, MSMO)
				end
			end
			if kind == "Jeepney" then
				B("Body", -5.5, 2.5, 1.0, 3.4, -2.5, 2.5, col)
				B("Hood", 2.5, 5.5, 1.0, 3.0, -2.3, 2.3, col)
				B("Glass", -5.3, 1.8, 3.4, 5.8, -2.4, 2.4, GLASS) -- the open passenger bay seen from outside
				B("Top", -5.6, 2.1, 5.8, 6.3, -2.7, 2.7, WHITE)
			else
				B("Body", -5.5, 2.5, 1.0, 5.9, -2.5, 2.5, col)
				B("Hood", 2.5, 5.5, 1.0, 3.2, -2.3, 2.3, col)
				B("Glass", -4.5, 2.2, 3.8, 5.2, -2.58, 2.58, GLASS) -- window band, proud of both sides
				B("Top", -5.6, 2.7, 5.9, 6.3, -2.6, 2.6, col:Lerp(WHITE, 0.4))
			end
			local k = 0
			for _, u in ipairs({ -3.5, 3.5 }) do
				for _, s in ipairs({ -1, 1 }) do
					k += 1
					local wx, wz = cx + s * 2.65, cz + u
					local rot = 0
					if nose == "x" then wx, wz, rot = cx + u, cz + s * 2.65, PI / 2 end
					ctx:cyl(pre .. "Wheel" .. k, V(0.7, 2.0, 2.0), CF(W(wx, y0 + 1.0, wz)) * ANG(0, rot, 0), DARK, MSMO)
				end
			end
		end, model)
	end
end
