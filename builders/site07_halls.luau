-- site07_halls: the Temple of Five Elements with its labyrinth garden, and the Holistic Medical Sanctuary of Site 07.
-- Studio copy: ServerStorage.Builders.site07_halls. Assembler: builders/site07.luau. Check: tests/site07_check.luau, groups north, east.
-- Owns Structure/Temple, Structure/Sanctuary, Structure/Gym. Budget 300.
-- Revision 3 (session 062, west half denser): the Pure Energy Gym, the board's hip-roofed block just north of the parking area.
-- Source: "San_benito_blueprint.png": inset E (Temple of Five Elements and garden: a square two-tier hip-roofed pavilion on a stone plinth
--   behind a round garden of concentric stone and green rings with a fountain at its centre, hedges and paths around); in the main view the
--   round garden lies north-west of the Big Lagoon. The Holistic Medical Sanctuary is the long two-storey block under brown hip roofs in the
--   south-east, south of the Front Office.
-- Not built: any symbol for the five elements (the board shows none to copy).
-- Frame: WORLD coordinates, y above the ground (0). Pure function of env. No text.
return function(env)
	local box, vcyl, ball, hipRoof, ring = env.box, env.vcyl, env.ball, env.hipRoof, env.ring
	local C3 = Color3.fromRGB
	local STONE, PALE, DARK, CREAM, TIMBER = C3(214, 206, 190), C3(232, 228, 216), C3(70, 48, 34), C3(236, 226, 204), C3(140, 90, 56)
	local ROOF, GLASS, GRASS, HEDGE, WATER = C3(146, 90, 58), C3(70, 96, 110), C3(96, 150, 70), C3(40, 96, 46), C3(70, 172, 216)
	local WOOD, GL, CONC, SLATE, GRASSM = Enum.Material.Wood, Enum.Material.Glass, Enum.Material.Concrete, Enum.Material.Slate, Enum.Material.Grass

	------------------------------------------------------------------ Temple of Five Elements (plinth x 682..698, z 128..144) and the labyrinth (centre (690,166))
	env.section("Structure/Temple", function(ctx)
		box(ctx, "TemplePlinth", 682, 698, 0, 1.2, 128, 144, STONE, SLATE)
		box(ctx, "TempleStep", 686, 694, 0, 0.6, 144, 147, STONE, SLATE)
		for _, x in ipairs({ 684.5, 695.5 }) do
			for _, z in ipairs({ 130.5, 141.5 }) do
				vcyl(ctx, "TemplePost", x, z, 1.2, 9, 0.9, DARK, WOOD)
			end
		end
		hipRoof(ctx, "TempleRoof", 680.5, 699.5, 127, 145, 9, 3.5, ROOF, SLATE)
		hipRoof(ctx, "TempleRoofTop", 685, 695, 131.5, 140.5, 11.5, 3, ROOF, SLATE)
		ball(ctx, "TempleFinial", 690, 15, 136, 1.2, DARK, WOOD)
		box(ctx, "TempleAltar", 689, 691, 1.2, 4, 135, 137, PALE, CONC)

		-- Labyrinth garden: eight concentric rings, stone and lawn by turns, each a disc 0.02 higher than the one around it.
		local dias = { 34, 30, 26, 22, 18, 14, 10, 6 }
		for i, d in ipairs(dias) do
			local light = (i % 2 == 1)
			vcyl(ctx, "LabyrinthRing", 690, 166, 0, 0.2 + 0.02 * i, d, light and PALE or GRASS, light and SLATE or GRASSM)
		end
		box(ctx, "LabyrinthPath", 688, 692, 0, 0.4, 168, 183.2, PALE, SLATE)
		vcyl(ctx, "LabyrinthFountain", 690, 166, 0.36, 1.2, 4, STONE, SLATE)
		local w = vcyl(ctx, "LabyrinthFountainWater", 690, 166, 1.2, 1.3, 3.2, WATER, GL)
		w.CanCollide = false
		vcyl(ctx, "LabyrinthFountainColumn", 690, 166, 1.2, 2.8, 0.8, PALE, CONC)
		-- clipped hedge ring, open to the south where the path comes in
		ring(ctx, "LabyrinthHedge", 690, 166, 18.6, 12, 1.2, 0, 1.4, HEDGE, GRASSM, function(k) return k == 2 or k == 3 end)
	end)

	------------------------------------------------------------------ Holistic Medical Sanctuary (x 830..910, z 288..308), two storeys, veranda on the north
	env.section("Structure/Sanctuary", function(ctx)
		box(ctx, "SanctuaryBody", 830, 910, 0, 19, 288, 308, CREAM, CONC)
		box(ctx, "SanctuaryPlinth", 829.6, 910.4, 0, 0.8, 287.6, 308.4, STONE, CONC)
		box(ctx, "SanctuaryBand", 829.7, 910.3, 9.6, 10.4, 287.7, 288, TIMBER, WOOD)
		hipRoof(ctx, "SanctuaryRoof", 828, 858, 286, 310, 19, 5, ROOF, SLATE)
		hipRoof(ctx, "SanctuaryRoof", 855, 885, 284, 312, 19, 7, ROOF, SLATE)
		hipRoof(ctx, "SanctuaryRoof", 882, 912, 286, 310, 19, 5, ROOF, SLATE)
		-- veranda along the north face: timber roof on eight columns, the door in the middle
		box(ctx, "SanctuaryVeranda", 830, 910, 9, 9.6, 283, 288, TIMBER, WOOD)
		for k = 0, 7 do
			vcyl(ctx, "SanctuaryColumn", 833 + k * 10.6, 283.8, 0, 9, 0.9, CREAM, CONC)
		end
		box(ctx, "SanctuaryDoor", 866, 872, 0.8, 9, 287.7, 288, DARK, WOOD)
		for k = 0, 7 do
			local x = 834 + 9.6 * k
			if x < 862 or x > 872 then
				box(ctx, "SanctuaryGlass", x, x + 5, 2, 7.6, 287.75, 288, GLASS, GL)
			end
		end
		for k = 0, 9 do
			local x = 833.5 + 7.6 * k
			box(ctx, "SanctuaryWindow", x, x + 4, 12, 16.5, 287.75, 288, GLASS, GL)
		end
	end)

	------------------------------------------------------------------ Pure Energy Gym (x 664..688, z 272..288): one storey, brown hip roof, door north
	-- Board: a long low building with a brown hip roof just north of the parking area's west end. The door faces the plaza (north); walk G
	-- (site07_grounds) leads to it from the south walk. Kept out of lane (c) (x 698..702) and the InfoPanel zone (z <= 258).
	env.section("Structure/Gym", function(ctx)
		box(ctx, "GymBody", 664, 688, 0, 10, 272, 288, CREAM, CONC)
		hipRoof(ctx, "GymRoof", 662.8, 689.2, 270.8, 289.2, 10, 4, ROOF, SLATE)
		box(ctx, "GymDoor", 674, 678, 0, 8.4, 271.7, 272, DARK, WOOD)
		box(ctx, "GymWindow", 666, 671, 3.5, 7.5, 271.75, 272, GLASS, GL)
		box(ctx, "GymWindow", 681, 686, 3.5, 7.5, 271.75, 272, GLASS, GL)
	end)
end
