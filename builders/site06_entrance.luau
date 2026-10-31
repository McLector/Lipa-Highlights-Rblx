-- site06_entrance: the board's main entrance ("entry from LIMA Estate main road with branded monument signage"): the ring road with
-- the entry road at Road B's end (430, -550), the slatted "% THE OUTLETS" monument facing SW, the perimeter hedges; plus the two required
-- display props on the arrival plaza (EstateModelPedestal, LipaMalvarPanel; their words are unchanged from the Slice 05 builder).
-- Module of builders/site06.luau (see its MODULE CONTRACT). Containers: Grounds, EstateModelPedestal, LipaMalvarPanel.
-- Local frame: +X east, +Z south, origin (550, 0, -700). Road B's end is local (-120, 150), 12 wide (x -126..-114). The roads are decks
-- (world y 0..1.3, see DECK in builders/site06.luau) and the Grounds section on them is lifted by DECK; EntryRoad is a wedge ramp from
-- the deck down to Road B's end (y 0 at z 150). The hedges stand on the grass (not lifted); the two props stand on the bare plaza.
return function(env)
	local V, CF, ANG, PI, C, M, SW, SE, DECK = env.V, env.CF, env.ANG, env.PI, env.C, env.M, env.SW, env.SE, env.DECK
	local box, obox, vcyl, gui, richGui, lamp = env.box, env.obox, env.vcyl, env.gui, env.richGui, env.lamp
	local INK = Color3.fromRGB(30, 36, 48)

	env.section("Grounds", function(ctx)
		-- ring road (light asphalt decks) and the entry ramp down to Road B's end (its high edge at z 140, inside the south road)
		box(ctx, "SouthRoad", -222, 212, -DECK, 0, 134, 146, C.ROAD, M.ASPHALT)
		box(ctx, "WestRoad", -222, -210, -DECK, 0, -106, 134, C.ROAD, M.ASPHALT)
		box(ctx, "EastRoad", 200, 212, -DECK, 0, -106, 134, C.ROAD, M.ASPHALT)
		box(ctx, "NorthRoad", -222, 212, -DECK, 0, -116, -106, C.ROAD, M.ASPHALT)
		ctx:wedge("EntryRoad", V(12, DECK, 10), CF(-120, -DECK / 2, 145) * ANG(0, PI, 0), C.ROAD, M.ASPHALT)
		-- zebra crossing where the entry walk meets the south road
		for i = 0, 3 do
			local x = -111.2 + 2.2 * i
			box(ctx, "ZebraBar", x - 0.6, x + 0.6, 0, 0.05, 135, 145, C.LINE, M.PLAS)
		end
		-- entry walk lamps (west side of the walk, clear of the road mouth x -126..-114)
		for _, z in ipairs({ 112, 128 }) do lamp(ctx, -113, z) end
		-- road lamps on the south road's north verge, and a palm at the entry
		for _, x in ipairs({ -165, 60, 100, 140, 180 }) do lamp(ctx, x, 132, 14) end
		env.palm(ctx, -129, 131, 15)

		-- The slatted monument (board inset "MAIN ENTRANCE MONUMENT"): white slats on the left, the lettering panel on the right, facing SW
		-- toward Road B. Frame: local +Z = SW (the front), local +X = SE.
		local MF = CFrame.fromMatrix(V(-90, 0, 121), SE, V(0, 1, 0), SW)
		obox(ctx, "MonumentBase", MF * CF(0, 0.5, 0), V(30, 1, 4), C.CONCRETE, M.CONC)
		local panel = obox(ctx, "MonumentPanel", MF * CF(4, 6.5, 0), V(20, 11, 0.6), Color3.fromRGB(205, 206, 208), M.PLAS)
		richGui(panel, Enum.NormalId.Back,
			'<font color="#D8231F">%</font> <font color="#2B2E3A">THE</font> <font color="#0A4FC4">O</font>'
				.. '<font color="#2FA83A">U</font><font color="#0A4FC4">T</font><font color="#E0502A">L</font>'
				.. '<font color="#B1182B">E</font><font color="#E5A21E">T</font><font color="#4B1B5A">S</font>', 20, 60)
		for i = 0, 9 do
			obox(ctx, "MonumentSlat", MF * CF(-14.5 + 1.1 * i, 8, 0.6), V(0.7, 14, 1.2), C.WHITE, M.CONC)
		end
		for i = 0, 3 do
			obox(ctx, "MonumentSlat", MF * CF(3 + 3.6 * i, 8, -0.9), V(0.7, 14, 1.2), C.WHITE, M.CONC)
		end
		obox(ctx, "MonumentTop", MF * CF(-9.5, 15.4, 0.6), V(12, 0.8, 1.6), C.WHITE, M.CONC)
		obox(ctx, "MonumentBed", MF * CF(0, 0.25, 4), V(24, 0.5, 3), C.LAWN, M.GRASS)
		for _, lx in ipairs({ -10, 0, 10 }) do
			ctx:ball("MonumentShrub", 2.2, MF * CF(lx, 1.1, 4), C.HEDGE, M.GRASS)
		end
	end, nil, DECK)

	-- perimeter hedges on the grass (gap for the entry road and the walk, x -128..-102), not lifted
	env.section("Grounds", function(ctx)
		box(ctx, "PerimeterHedge", -225, -128, 0, 3.5, 146.5, 150, C.HEDGE, M.GRASS)
		box(ctx, "PerimeterHedge", -102, 212, 0, 3.5, 146.5, 150, C.HEDGE, M.GRASS)
		box(ctx, "PerimeterHedge", -225, -222, 0, 3.5, -118, 146.5, C.HEDGE, M.GRASS)
		box(ctx, "PerimeterHedge", 222, 225, 0, 3.5, -118, 150, C.HEDGE, M.GRASS)
		box(ctx, "PerimeterHedge", -222, 222, 0, 3.5, -118, -116, C.HEDGE, M.GRASS)
	end)

	-- The estate model on its plinth (arrival plaza, south-east, label facing north to the Guide). The plaza is bare terrain, which renders
	-- up to about 1.25 above y 0, so the labelled plinth stands on a 1.5 base.
	env.section("EstateModelPedestal", function(ctx)
		local x, z = -10, 93
		box(ctx, "PlinthBase", x - 4.3, x + 4.3, 0, 1.5, z - 4.3, z + 4.3, C.CONCRETE, M.CONC)
		local plinth = box(ctx, "Plinth", x - 4, x + 4, 1.5, 5.8, z - 4, z + 4, C.WHITE, M.CONC)
		gui(plinth, Enum.NormalId.Front, "LIMA ESTATE MODEL", "A small model of the estate. LIMA Estate spans Lipa and Malvar.", INK, 40, 24, 20)
		box(ctx, "ModelBase", x - 3.7, x + 3.7, 5.8, 6.1, z - 3.7, z + 3.7, C.DARK, M.PLAS)
		box(ctx, "ModelPitch", x + 0.6, x + 3.2, 6.1, 6.25, z - 2.6, z + 0.2, C.TURF, M.PLAS)
		box(ctx, "ModelShop", x - 3.2, x - 0.8, 6.1, 7.7, z - 3, z - 1, C.ORANGE, M.PLAS)
		box(ctx, "ModelWing", x - 2.4, x + 0.2, 6.1, 7.2, z - 0.6, z + 1.4, C.WHITE, M.PLAS)
		box(ctx, "ModelStand", x + 0.6, x + 3.2, 6.1, 6.55, z + 0.6, z + 1.4, C.CONCRETE, M.PLAS)
		local case = box(ctx, "ModelCase", x - 3.7, x + 3.7, 6.1, 9.1, z - 3.7, z + 3.7, C.GLASS, M.GLASS)
		case.Transparency = 0.75
	end)

	-- The Lipa/Malvar panel on the plaza's west edge, facing east (local +Z of its frame = +X).
	env.section("LipaMalvarPanel", function(ctx)
		local P = CF(-60, 0, 77) * ANG(0, PI / 2, 0)
		for _, dx in ipairs({ -9.5, 9.5 }) do
			obox(ctx, "PanelPost", P * CF(dx, 6.8, -0.5), V(0.6, 13.6, 0.6), C.STEEL, M.METAL)
		end
		local title = obox(ctx, "PanelTitle", P * CF(0, 12.4, 0), V(22, 2.4, 0.5), INK, M.PLAS)
		gui(title, Enum.NormalId.Back, "LIMA ESTATE SPANS LIPA AND MALVAR", nil, Color3.new(1, 1, 1), 40, 36)
		local left = obox(ctx, "PanelLipa", P * CF(-5.625, 8.2, 0), V(10.75, 6, 0.5), Color3.fromRGB(30, 70, 140), M.PLAS)
		gui(left, Enum.NormalId.Back, "LIPA CITY", nil, Color3.new(1, 1, 1), 40, 60)
		local right = obox(ctx, "PanelMalvar", P * CF(5.625, 8.2, 0), V(10.75, 6, 0.5), Color3.fromRGB(40, 120, 70), M.PLAS)
		gui(right, Enum.NormalId.Back, "MALVAR", nil, Color3.new(1, 1, 1), 40, 60)
		obox(ctx, "PanelDivider", P * CF(0, 8.2, 0), V(0.5, 6, 0.7), C.WHITE, M.PLAS)
		local foot = obox(ctx, "PanelFooter", P * CF(0, 4.2, 0), V(22, 2, 0.5), INK, M.PLAS)
		gui(foot, Enum.NormalId.Back, "Schematic map, not to scale. The estate spans Lipa and Malvar.", nil, Color3.new(1, 1, 1), 40, 22)
	end)
end
