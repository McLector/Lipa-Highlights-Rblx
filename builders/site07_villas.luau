-- site07_villas: the look-at group (the round thatched GardenPavilion beside the straight-edged glass villa), the row of three Narra pool
-- villas and the amphitheater of Site 07.
-- Studio copy: ServerStorage.Builders.site07_villas. Assembler: builders/site07.luau. Check: tests/site07_check.luau, groups centre, east.
-- Owns GardenPavilion, Structure/GlassVilla, Structure/NarraVillas, Structure/Amphitheater, Structure/SmallVillas. Budget 550.
-- Source: "San_benito_blueprint.png": just north of the amphitheater the board draws a round cone-roofed thatched hut beside a straight-walled
--   villa under a brown hip roof (the Palmera / Lakan villas); the amphitheater is a stepped octagon in the centre; the Narra Pool Villas are
--   a row of hip-roofed houses along the North river, each with a private blue pool (inset B). The look-at line of SiteData row 7 ("the
--   round thatched pavilion beside the straight-edged villa ... the patterned path") stays true: both stand east of the Guide in view.
-- The thatched cone keeps the Slice 20 profile (12 tiers, 18 down to about 1.9, a finial). The villa glass faces west (the sites_check
--   sight-lines from the plaza eye (664,6,234) and the road-mouth eye (576,6,236) reach its panes).
-- Frame: WORLD coordinates, y above the ground (0). Pure function of env. No text.
return function(env)
	local V, CF, PI = env.V, env.CF, env.PI
	local box, vcyl, ball, hipRoof, ring = env.box, env.vcyl, env.ball, env.hipRoof, env.ring
	local C3 = Color3.fromRGB
	local STRAW, DARK, DECKC = C3(128, 104, 62), C3(70, 48, 34), C3(150, 104, 70)
	local CREAM, TIMBER, GLASS_C, STONE = C3(236, 226, 204), C3(140, 84, 50), C3(150, 190, 190), C3(206, 198, 180)
	local ROOF, POOL, BLUE, RATTAN = C3(146, 90, 58), C3(70, 172, 216), C3(30, 110, 220), C3(190, 150, 100)
	local SEAT = C3(196, 186, 166)
	local SMOOTH, WOOD, GL, CONC, SLATE = Enum.Material.SmoothPlastic, Enum.Material.Wood, Enum.Material.Glass, Enum.Material.Concrete, Enum.Material.Slate

	------------------------------------------------------------------ GardenPavilion: round thatched cone on 8 posts, raised round floor (top 1.0)
	local PX, PZ = 756, 206
	env.section("GardenPavilion", function(ctx)
		vcyl(ctx, "PavilionDeck", PX, PZ, 0, 1.0, 16, DECKC, WOOD)
		box(ctx, "PavilionStep", PX - 9.5, PX - 7.6, 0, 0.5, PZ - 2.5, PZ + 2.5, DECKC, WOOD)
		for k = 0, 7 do
			local a = k * PI / 4 + PI / 8
			vcyl(ctx, "PavilionPost", PX + 7 * math.cos(a), PZ + 7 * math.sin(a), 1.0, 8, 0.7, DARK, WOOD)
		end
		vcyl(ctx, "PavilionBeam", PX, PZ, 7.6, 8, 15.2, DARK, WOOD)
		-- twelve fine tiers on a slightly convex profile (eave y 8, peak y 14.8), a dark finial on top
		for i = 0, 11 do
			local y0 = 8 + i * 0.57
			vcyl(ctx, "PavilionThatch", PX, PZ, y0, y0 + 0.57, 18 * (1 - i / 12) ^ 0.9, STRAW, WOOD)
		end
		ball(ctx, "PavilionFinial", PX, 15.2, PZ, 1.4, DARK, WOOD)
	end)

	------------------------------------------------------------------ Glass villa: x 780..808, z 220..252, glass front on x 780 (west), brown hip roof
	env.section("Structure/GlassVilla", function(ctx)
		box(ctx, "VillaSlab", 776, 812, 0.3, 0.8, 216, 256, STONE, SLATE)
		for k = 0, 7 do
			local z0 = 220 + 4 * k
			local p = box(ctx, "VillaGlassPane", 779.9, 780.1, 1, 11, z0 + 0.2, z0 + 3.8, GLASS_C, GL)
			p.Transparency = 0.45
		end
		for k = 0, 8 do
			local z = 220 + 4 * k
			box(ctx, "GlassPost", 779.6, 780.4, 0.8, 12, z - 0.2, z + 0.2, TIMBER, WOOD)
		end
		box(ctx, "GlassHead", 779.6, 780.4, 11, 12, 220, 252, TIMBER, WOOD)
		box(ctx, "GlassSill", 779.6, 780.4, 0.8, 1, 220, 252, TIMBER, WOOD)
		box(ctx, "VillaSideN", 780.4, 806, 0.8, 12, 220, 221, CREAM, CONC)
		box(ctx, "VillaSideS", 780.4, 806, 0.8, 12, 251, 252, CREAM, CONC)
		box(ctx, "VillaBody", 806, 808, 0.8, 12, 220, 252, CREAM, CONC)
		box(ctx, "VillaCeiling", 780.4, 806, 11.6, 12, 221, 251, TIMBER, WOOD)
		hipRoof(ctx, "VillaRoof", 777, 811, 217, 255, 12, 5, ROOF, SLATE)
		-- Dining table and four chairs seen through the glass (slab top 0.8: table top +2.6..3.0, chair seats +2).
		box(ctx, "DiningTop", 791, 795, 3.4, 3.8, 233.5, 238.5, TIMBER, WOOD)
		box(ctx, "DiningLeg", 792.6, 793.4, 0.8, 3.4, 235.6, 236.4, DARK, WOOD)
		for _, c in ipairs({ { 789.5, 236, -1, 0 }, { 796.5, 236, 1, 0 }, { 793, 231.5, 0, -1 }, { 793, 240.5, 0, 1 } }) do
			local x, z, dx, dz = c[1], c[2], c[3], c[4]
			box(ctx, "ChairSeat", x - 0.7, x + 0.7, 2.4, 2.8, z - 0.7, z + 0.7, TIMBER, WOOD)
			box(ctx, "ChairBase", x - 0.3, x + 0.3, 0.8, 2.4, z - 0.3, z + 0.3, DARK, WOOD)
			if dx ~= 0 then
				local a = x + dx * 0.55
				box(ctx, "ChairBack", math.min(a, a + dx * 0.3), math.max(a, a + dx * 0.3), 2.8, 4.4, z - 0.7, z + 0.7, TIMBER, WOOD)
			else
				local a = z + dz * 0.55
				box(ctx, "ChairBack", x - 0.7, x + 0.7, 2.8, 4.4, math.min(a, a + dz * 0.3), math.max(a, a + dz * 0.3), TIMBER, WOOD)
			end
		end
		vcyl(ctx, "BluePot", 777.5, 218, 0.8, 2.2, 1.4, BLUE, SMOOTH)
		vcyl(ctx, "BluePot", 777.5, 254, 0.8, 2.2, 1.4, BLUE, SMOOTH)
	end)

	------------------------------------------------------------------ Narra pool villas: three houses along the North river, each with its pool south
	-- The deck is 1.0 thick (tidy: grass blades reach about y 0.9) and everything on it starts at y D = 1.0.
	local VILLAS = { { 821, 124 }, { 851, 134 }, { 880, 150 } }
	local D = 1.0
	for i, c in ipairs(VILLAS) do
		local cx, cz = c[1], c[2]
		local holder = env.newFolder("Structure/NarraVillas", "NarraVilla" .. i, "Model")
		env.section("Structure/NarraVillas", function(ctx)
			box(ctx, "NarraDeck", cx - 9, cx + 9, 0, D, cz - 8, cz + 16, DECKC, WOOD)
			box(ctx, "NarraVillaBody", cx - 7, cx + 7, D, D + 8.6, cz - 6, cz + 6, CREAM, CONC)
			hipRoof(ctx, "NarraRoof", cx - 8.5, cx + 8.5, cz - 7.5, cz + 7.5, D + 8.6, 4.5, ROOF, SLATE)
			box(ctx, "NarraDoor", cx - 2, cx + 2, D, D + 8.2, cz + 6, cz + 6.3, TIMBER, WOOD)
			for _, x in ipairs({ cx - 5.5, cx + 3 }) do
				box(ctx, "NarraWindow", x, x + 2.5, D + 2.6, D + 6.6, cz + 6, cz + 6.25, C3(70, 96, 110), GL)
			end
			box(ctx, "NarraWindow", cx - 7.25, cx - 7, D + 2.6, D + 6.6, cz - 2, cz + 2, C3(70, 96, 110), GL)
			box(ctx, "NarraWindow", cx + 7, cx + 7.25, D + 2.6, D + 6.6, cz - 2, cz + 2, C3(70, 96, 110), GL)
			box(ctx, "NarraPoolCoping", cx - 5, cx + 5, D, D + 0.3, cz + 8, cz + 15, STONE, CONC)
			local w = box(ctx, "NarraPoolWater", cx - 4.3, cx + 4.3, D + 0.3, D + 0.45, cz + 8.7, cz + 14.3, POOL, GL)
			w.Transparency = 0.15
			w.CanCollide = false
			box(ctx, "NarraLounger", cx + 6, cx + 8.2, D, D + 0.5, cz + 8.5, cz + 12.5, RATTAN, SMOOTH)
			box(ctx, "NarraLounger", cx - 8.2, cx - 6, D, D + 0.5, cz + 8.5, cz + 12.5, RATTAN, SMOOTH)
		end, holder)
	end

	------------------------------------------------------------------ Small villas (tidy, owner's look): the board's many small brown hip-roof houses
	-- (Garden Glass on the north edge; Acacia and Mahogany Luxury on the west; Mahogany Pool Villas in the south-west), env.LAYOUT.smallVillas.
	-- Each 10 x 8, 8.6 high, a brown hip roof, a door 8.2 tall and a window on the side facing the centre (770, 240); a raised pool where listed.
	for i, c in ipairs(env.LAYOUT.smallVillas) do
		local cx, cz, poolSide = c[1], c[2], c[3]
		local holder = env.newFolder("Structure/SmallVillas", "SmallVilla" .. i, "Model")
		env.section("Structure/SmallVillas", function(ctx)
			box(ctx, "SmallVillaBody", cx - 5, cx + 5, 0, 8.6, cz - 4, cz + 4, CREAM, CONC)
			hipRoof(ctx, "SmallVillaRoof", cx - 5.6, cx + 5.6, cz - 4.6, cz + 4.6, 8.6, 3.4, ROOF, SLATE)
			local dx, dz = 770 - cx, 240 - cz
			if math.abs(dx) > math.abs(dz) then
				local fx = cx + (dx > 0 and 5 or -5.3)
				box(ctx, "SmallVillaDoor", fx, fx + 0.3, 0, 8.2, cz - 1.5, cz + 1.5, TIMBER, WOOD)
				box(ctx, "SmallVillaWindow", fx, fx + 0.3, 3, 6.5, cz + 2, cz + 3.4, C3(70, 96, 110), GL)
			else
				local fz = cz + (dz > 0 and 4 or -4.3)
				box(ctx, "SmallVillaDoor", cx - 1.5, cx + 1.5, 0, 8.2, fz, fz + 0.3, TIMBER, WOOD)
				box(ctx, "SmallVillaWindow", cx + 2, cx + 3.8, 3, 6.5, fz, fz + 0.3, C3(70, 96, 110), GL)
			end
			if poolSide then
				local x0, x1, z0, z1
				if poolSide == "E" then x0, x1, z0, z1 = cx + 5.5, cx + 11, cz - 3, cz + 3 else x0, x1, z0, z1 = cx - 4, cx + 4, cz - 10, cz - 4.5 end
				box(ctx, "SmallPoolDeck", x0, x1, 0, 1.0, z0, z1, STONE, CONC)
				local w = box(ctx, "SmallPoolWater", x0 + 0.6, x1 - 0.6, 1.0, 1.2, z0 + 0.6, z1 - 0.6, POOL, GL)
				w.Transparency = 0.15
				w.CanCollide = false
			end
		end, holder)
	end

	------------------------------------------------------------------ Amphitheater: 4 octagonal seat tiers rising outward around a round stage
	local AX, AZ = 744, 248
	env.section("Structure/Amphitheater", function(ctx)
		vcyl(ctx, "AmphiStage", AX, AZ, 0.3, 0.9, 12, STONE, SLATE)
		-- segment 3 (west-south-west) is left out on every tier: the aisle in from the plaza
		for t = 1, 4 do
			ring(ctx, "AmphiTier", AX, AZ, 5 + 4 * t, 8, 4, 0.3, 0.3 + 0.8 * t - 0.05, SEAT, CONC, function(k) return k == 3 end)
		end
	end)
end
