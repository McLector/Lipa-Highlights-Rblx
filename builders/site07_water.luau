-- site07_water: the Big Lagoon with its pavilion, the Acqua Hydrotherapy Sanctuary pools and the Front Office with its lagoon (Site 07).
-- Studio copy: ServerStorage.Builders.site07_water. Assembler: builders/site07.luau. Check: tests/site07_check.luau, groups north, south, east.
-- Owns Structure/BigLagoon, Structure/Acqua, Structure/FrontOffice. Budget 350.
-- Source: "San_benito_blueprint.png": the Big Lagoon north of the centre, an irregular blue pond with a hip-roofed pavilion on a deck at its
--   edge (inset D: square pavilion, two roof tiers, posts, the deck over the water); the Acqua Hydrotherapy Sanctuary in the west (inset C:
--   interlocking rectangular pools in a pale stone deck with hip-roofed cabanas); the Front Office in the east with its lagoon east of it.
-- Water is parts (no terrain). Tidy (owner's look): every water top sits at y 1.05..1.4, above the rendered grass blades (about y 0.9);
--   lagoon discs are opaque SmoothPlastic, share one colour and one top height (no seams); decks and paths over them are raised to match.
-- Frame: WORLD coordinates, y above the ground (0). Pure function of env. No text.
return function(env)
	local V, CF, PI = env.V, env.CF, env.PI
	local box, vcyl, ball, hipRoof = env.box, env.vcyl, env.ball, env.hipRoof
	local C3 = Color3.fromRGB
	local LAGOON, POOL, RIM, ROCK = C3(40, 128, 160), C3(70, 172, 216), C3(176, 162, 128), C3(140, 136, 128)
	local STONE, DECKC, CREAM, TIMBER, DARK = C3(226, 220, 206), C3(150, 104, 70), C3(236, 226, 204), C3(140, 90, 56), C3(72, 50, 36)
	local ROOF, GLASS, RATTAN, TEAL = C3(146, 90, 58), C3(70, 96, 110), C3(190, 150, 100), C3(60, 170, 170)
	local SMOOTH, WOOD, GL, CONC, SLATE = Enum.Material.SmoothPlastic, Enum.Material.Wood, Enum.Material.Glass, Enum.Material.Concrete, Enum.Material.Slate

	local function water(ctx, name, x, z, dia, color)
		local w = vcyl(ctx, name, x, z, 0.3, 1.05, dia, color, SMOOTH)
		w.CanCollide = false
		return w
	end

	------------------------------------------------------------------ Big Lagoon (x 720..799, z 130..195) with its pavilion and boardwalk
	env.section("Structure/BigLagoon", function(ctx)
		local discs = { { 742, 160, 44 }, { 776, 150, 40 }, { 784, 180, 30 }, { 752, 184, 22 }, { 730, 140, 20 } }
		for _, d in ipairs(discs) do
			vcyl(ctx, "LagoonRim", d[1], d[2], 0, 0.95, d[3] + 4, RIM, Enum.Material.Sand)
		end
		for _, d in ipairs(discs) do
			water(ctx, "LagoonWater", d[1], d[2], d[3], LAGOON)
		end
		for _, r in ipairs({ { 722, 152, 2.6 }, { 726, 172, 2.0 }, { 738, 183, 2.4 }, { 768, 128.5, 2.2 }, { 797, 160, 2.6 }, { 760, 196, 1.8 } }) do
			ball(ctx, "LagoonRock", r[1], 0.9, r[2], r[3], ROCK, SLATE)
		end
		-- Pavilion on a deck at the water's south-east edge: 4 posts, a two-tier brown hip roof, railings 3 high on three sides.
		box(ctx, "LagoonPavilionDeck", 776, 794, 0.9, 1.6, 168, 186, DECKC, WOOD)
		for _, x in ipairs({ 777.5, 792.5 }) do
			for _, z in ipairs({ 169.5, 184.5 }) do
				vcyl(ctx, "LagoonPavilionPost", x, z, 1.6, 9.2, 0.8, DARK, WOOD)
			end
		end
		hipRoof(ctx, "LagoonPavilionRoof", 773, 797, 166, 188, 9.2, 3.5, ROOF, SLATE)
		hipRoof(ctx, "LagoonPavilionRoofTop", 779, 791, 172, 182, 11.7, 3, ROOF, SLATE)
		box(ctx, "LagoonRail", 776, 794, 1.6, 4.6, 168, 168.5, DARK, WOOD)
		box(ctx, "LagoonRail", 793.5, 794, 1.6, 4.6, 168.5, 186, DARK, WOOD)
		box(ctx, "LagoonRail", 776, 776.5, 1.6, 4.6, 168.5, 186, DARK, WOOD)
		-- Boardwalk from the central lawn (z 200) to the deck, and two benches on the deck.
		box(ctx, "LagoonBoardwalk", 782, 788, 0.9, 1.5, 186, 200, DECKC, WOOD)
		for _, x in ipairs({ 778.5, 791.5 }) do
			box(ctx, "LagoonBench", x - 0.8, x + 0.8, 1.6, 3.6, 172, 180, DARK, WOOD)
		end
	end)

	------------------------------------------------------------------ Acqua Hydrotherapy Sanctuary: deck, five pools with copings, two cabanas, loungers
	env.section("Structure/Acqua", function(ctx)
		-- the deck is 1.0 thick so the grass blades under it never show (tidy)
		box(ctx, "AcquaDeck", 606, 648, 0, 1.0, 254, 296, STONE, SLATE)
		local function pool(name, x0, x1, z0, z1)
			box(ctx, "AcquaCoping", x0 - 1, x1 + 1, 1.0, 1.3, z0 - 1, z1 + 1, C3(200, 196, 186), CONC)
			local w = box(ctx, name, x0, x1, 1.3, 1.4, z0, z1, POOL, GL)
			w.Transparency = 0.15
			w.CanCollide = false
			return w
		end
		pool("PoolWater", 614, 630, 262, 278) -- the main pool (the PoolWater anchor)
		pool("AcquaPool", 633, 643, 260, 270)
		pool("AcquaPool", 633, 643, 273, 283)
		pool("AcquaPool", 616, 628, 282, 291)
		vcyl(ctx, "AcquaCoping", 636, 289, 1.0, 1.3, 9, C3(200, 196, 186), CONC)
		local jac = vcyl(ctx, "AcquaPool", 636, 289, 1.3, 1.4, 7, POOL, GL)
		jac.Transparency = 0.15
		jac.CanCollide = false
		-- Two hip-roofed cabanas on four posts (inset C).
		for _, c in ipairs({ { 605.5, 614.5, 287, 295 }, { 640, 648, 285.5, 292.5 } }) do
			for _, x in ipairs({ c[1] + 1.5, c[2] - 1.5 }) do
				for _, z in ipairs({ c[3] + 1.5, c[4] - 1.5 }) do
					vcyl(ctx, "CabanaPost", x, z, 1.0, 9.1, 0.6, DARK, WOOD)
				end
			end
			hipRoof(ctx, "CabanaRoof", c[1], c[2], c[3], c[4], 9.1, 2.6, ROOF, SLATE)
		end
		-- Loungers along the north edge of the deck (seat 0.5 high, back up to 1.8), teal cushions.
		for _, x in ipairs({ 612, 619, 626, 640 }) do
			box(ctx, "AcquaLounger", x, x + 2.2, 1.0, 1.5, 254.6, 258.6, RATTAN, SMOOTH)
			box(ctx, "AcquaCushion", x + 0.1, x + 2.1, 1.5, 1.7, 254.8, 258.4, TEAL, Enum.Material.Fabric)
		end
	end)

	------------------------------------------------------------------ Front Office (east) and its lagoon east of it
	env.section("Structure/FrontOffice", function(ctx)
		box(ctx, "FrontOfficeBody", 848, 882, 0, 11, 236, 262, CREAM, CONC)
		box(ctx, "FrontOfficePlinth", 847.6, 882.4, 0, 0.8, 235.6, 262.4, C3(206, 198, 180), CONC)
		hipRoof(ctx, "FrontOfficeRoof", 846, 884, 234, 264, 11, 6, ROOF, SLATE)
		-- South entrance porch toward the east walk: 4 posts, its own low hip roof, door 8.5 tall, windows on the south and west faces.
		for _, x in ipairs({ 858.5, 871.5 }) do
			for _, z in ipairs({ 262.5, 267.5 }) do
				vcyl(ctx, "PorchPost", x, z, 0, 8.6, 0.7, DARK, WOOD)
			end
		end
		hipRoof(ctx, "FrontOfficePorchRoof", 857, 873, 261.5, 268.5, 8.6, 2.2, ROOF, SLATE)
		box(ctx, "FrontOfficeDoor", 862, 868, 0, 8.5, 262, 262.3, DARK, WOOD)
		for _, x in ipairs({ 850.5, 875 }) do
			box(ctx, "FrontOfficeWindow", x, x + 5, 3, 8, 262, 262.25, GLASS, GL)
		end
		for _, z in ipairs({ 239, 247, 255 }) do
			box(ctx, "FrontOfficeWindow", 847.75, 848, 3, 8, z, z + 5, GLASS, GL)
		end
		-- The lagoon east of the office (two discs), its sandy rim and a few rocks.
		vcyl(ctx, "FrontLagoonRim", 906, 246, 0, 0.95, 32, RIM, Enum.Material.Sand)
		vcyl(ctx, "FrontLagoonRim", 922, 258, 0, 0.95, 22, RIM, Enum.Material.Sand)
		water(ctx, "FrontLagoonWater", 906, 246, 28, LAGOON)
		water(ctx, "FrontLagoonWater", 922, 258, 18, LAGOON)
		for _, r in ipairs({ { 893, 238, 2.2 }, { 914, 232.5, 1.8 }, { 930, 265, 2.0 } }) do
			ball(ctx, "LagoonRock", r[1], 0.9, r[2], r[3], ROCK, SLATE)
		end
	end)
end
