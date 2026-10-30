-- site08_clubhouse: the main golf clubhouse after the board's "Main clubhouse elevation" inset and its 3D view (Revision 2), plus the
-- forecourt and the pool. Studio copy: ServerStorage.Builders.site08_clubhouse (run through builders/site08.luau only).
-- Frame env.CFL (local +X = SW, +Z = NW = the frontage, ly from PADY 20). Left to right as the board draws it (viewer's left = -lx):
--   left pavilion (two storeys, arched windows, hip roof with a small cupola) | main block with an arched loggia and a balcony above |
--   entry pavilion with three arches and the porte-cochere in front | the higher central pavilion (belvedere) rising out of the main roof |
--   right block (two storeys, arched windows) | low right-end pavilion. Cream walls, red-tile hip roofs, white trim.
-- Pinned (sites_check, site08_check): ClubhouseRoofMain (central pavilion cap, highest part), ClubhouseEntryGable, PorteCochere, ClubhouseWindow (22),
-- ClubhouseBalconyRail (8), LoggiaArch (9), ClubWall, PavilionWall, RoundPlanter, PoolWater. Lanes b and c and the window sight-lines stay clear:
-- the arcade bays are centred on the ground-floor windows and the porte-cochere roof stays inside lx -12..12.
return function(env)
	local V, CF, ANG, PI = env.V, env.CF, env.ANG, env.PI
	local C, M = env.C, env.M
	local box, vcyl, ball = env.box, env.vcyl, env.ball
	local CFL = env.CFL
	local club = env.container("Clubhouse")

	local function glass(p)
		p.Transparency = 0.35
		return p
	end
	-- Arched window on a front face at lz (facing +lz): box body named ClubhouseWindow, disc head named ClubhouseWindowHead.
	local function archWindow(ctx, lx, ly0, lz, w, h)
		local body, head = env.arch(ctx, "ClubhouseWindow", CF(lx, ly0, lz) * ANG(0, PI, 0), w, h, 0.6, C.GLASS, M.GLASS)
		glass(body)
		glass(head)
		box(ctx, "WindowSill", lx - w / 2 - 0.4, lx + w / 2 + 0.4, ly0 - 0.5, ly0, lz - 0.2, lz + 0.6, C.TRIM, M.SMOOTH)
	end
	-- An arcade bay: a CSG wall piece with a round-arched opening (BuildKit:arch; 5-part pointed fallback if CSG fails).
	local function bay(ctx, lx, lz, width, height, openW, openH)
		local res = ctx:arch("LoggiaArch", {
			width = openW, height = openH, depth = 1.2, wallWidth = width, wallHeight = height,
			cframe = CF(lx, 1 + height / 2, lz), color = C.CREAM, material = M.PLASTER,
		})
		for _, p in ipairs(res.parts) do
			if p:IsA("BasePart") then
				pcall(function() p.CollisionFidelity = Enum.CollisionFidelity.PreciseConvexDecomposition end)
				if p.Name ~= "LoggiaArch" then p.Name = "LoggiaArch" end
			end
		end
	end

	------------------------------------------------------------------ masses and walls
	env.section("Clubhouse", function(ctx)
		-- Stone plinth (buried below the pad) under every block, the loggia and the entry pavilion.
		box(ctx, "Plinth", -62, 82, -8, 1, -20, 12.5, C.STONE, M.LIME)
		box(ctx, "LoggiaFloor", -40, 40, -8, 1, 12.5, 21, C.STONE, M.LIME)
		box(ctx, "EntryFloor", -13, 13, -8, 1, 21, 30, C.STONE, M.LIME)
		-- Left pavilion (lx -62..-40), main block (-40..40), right block (40..70), right-end pavilion (70..82).
		box(ctx, "ClubWall", -62, -40, 1, 22, -14, 12, C.CREAM, M.PLASTER)
		box(ctx, "ClubWall", -40, 40, 1, 22, -20, 14, C.CREAM, M.PLASTER)
		box(ctx, "ClubWall", 40, 70, 1, 20, -14, 12, C.CREAM, M.PLASTER)
		box(ctx, "ClubWall", 70, 82, 1, 12, -8, 8, C.CREAM, M.PLASTER)
		-- White string courses and cornices.
		box(ctx, "Cornice", -62.4, -39.6, 21.2, 22.4, -14.4, 12.4, C.TRIM, M.SMOOTH)
		box(ctx, "Cornice", -40.4, 40.4, 21.2, 22.4, -20.4, 14.4, C.TRIM, M.SMOOTH)
		box(ctx, "Cornice", 39.6, 70.4, 19.2, 20.4, -14.4, 12.4, C.TRIM, M.SMOOTH)
		box(ctx, "Cornice", 69.6, 82.4, 11.2, 12.4, -8.4, 8.4, C.TRIM, M.SMOOTH)
		box(ctx, "StringCourse", -62.4, -40, 11.4, 12.2, 12, 12.6, C.TRIM, M.SMOOTH)
		box(ctx, "StringCourse", 40, 70.4, 10.4, 11.2, 12, 12.6, C.TRIM, M.SMOOTH)
		-- Windows: the left pavilion (2 per floor), the right block (3 per floor), all arched.
		for _, lx in ipairs({ -56, -46 }) do
			archWindow(ctx, lx, 2.5, 12.3, 5, 8)
			archWindow(ctx, lx, 14, 12.3, 5, 7)
		end
		for _, lx in ipairs({ 46, 54, 62 }) do
			archWindow(ctx, lx, 2.5, 12.3, 5, 8)
			archWindow(ctx, lx, 12.8, 12.3, 5, 6.4)
		end
		-- Main block: ground-floor arched windows behind the loggia bays, upper windows above the balcony.
		for _, s in ipairs({ -1, 1 }) do
			for _, k in ipairs({ 18, 26, 34 }) do
				archWindow(ctx, s * k, 2, 14.3, 5, 8.5)
				glass(box(ctx, "ClubhouseWindow", s * k - 2.25, s * k + 2.25, 15, 21, 14, 14.6, C.GLASS, M.GLASS))
			end
		end
		-- Balcony over the loggia (both sides of the entry pavilion) and eight separate white rail segments.
		box(ctx, "BalconySlab", -38.4, -13, 12, 13, 14, 21, C.TRIM, M.SMOOTH)
		box(ctx, "BalconySlab", 13, 38.4, 12, 13, 14, 21, C.TRIM, M.SMOOTH)
		for _, s in ipairs({ -1, 1 }) do
			for _, seg in ipairs({ { 14.2, 20 }, { 20.2, 26 }, { 26.2, 32 }, { 32.2, 38 } }) do
				local a, b = s * seg[1], s * seg[2]
				box(ctx, "ClubhouseBalconyRail", math.min(a, b), math.max(a, b), 13, 16, 20.3, 20.8, C.TRIM, M.SMOOTH)
			end
		end
		-- Entry pavilion (lx -13..13, lz 14..30): side walls, solid upper front, glazed doors (8+ high) behind the arches, two steps.
		box(ctx, "ClubWall", -13, -12, 1, 26, 14, 30, C.CREAM, M.PLASTER)
		box(ctx, "ClubWall", 12, 13, 1, 26, 14, 30, C.CREAM, M.PLASTER)
		box(ctx, "EntryUpperWall", -13, 13, 14, 26, 29, 30, C.CREAM, M.PLASTER)
		box(ctx, "EntryCornice", -13.4, 13.4, 25.2, 26.4, 13.6, 30.4, C.TRIM, M.SMOOTH)
		-- The entry gable: a cream pediment on the entry pavilion's front (the elevation inset's gabled centre), keeps the look-at line true.
		for _, w in ipairs(ctx:gable("EntryPediment", 26, 5, 0.8, CF(0, 26.4, 31))) do w.Color = C.CREAM end
		for _, lx in ipairs({ -8.5, 0, 8.5 }) do
			box(ctx, "EntryUpperWindow", lx - 1.8, lx + 1.8, 17, 23, 30, 30.4, C.GLASS, M.GLASS).Transparency = 0.35
		end
		box(ctx, "EntryGlass", -10, 10, 1, 10, 22, 22.4, C.GLASS, M.GLASS).Transparency = 0.4
		box(ctx, "EntryStep", -9, 9, -8, 0.5, 30, 32, C.STONE, M.LIME)
		-- Central pavilion (belvedere) rising out of the main roof: corner piers, a floor above the roof, the cornice.
		for _, c in ipairs({ { -10, -10 }, { 8, -10 }, { -10, 8 }, { 8, 8 } }) do
			box(ctx, "PavilionWall", c[1], c[1] + 2, 22, 38, c[2], c[2] + 2, C.CREAM, M.PLASTER)
		end
		box(ctx, "PavilionFloor", -9, 9, 25, 26.5, -9, 9, C.CREAM, M.PLASTER)
		box(ctx, "PavilionCornice", -10.6, 10.6, 37, 38.6, -10.6, 10.6, C.TRIM, M.SMOOTH)
		-- Left-pavilion cupola.
		box(ctx, "Cupola", -54, -48, 26, 33, -4, 2, C.CREAM, M.PLASTER)
		-- Ridge caps: the main roof ridge (decorative), the entry ridge ClubhouseEntryGable, the pavilion finial ClubhouseRoofMain (highest part).
		box(ctx, "RidgeCap", -27, 27, 32.6, 33.6, -3.6, -2.4, C.TERRA_CAP, M.TILE)
		box(ctx, "ClubhouseEntryGable", -4, 4, 33.6, 34.6, 21.4, 22.6, C.TERRA_CAP, M.TILE)
		box(ctx, "ClubhouseRoofMain", -1.2, 1.2, 46.2, 47.6, -1.2, 1.2, C.TERRA_CAP, M.TILE)
	end, nil, CFL)

	-- Arcade bays (CSG), one per ground-floor window, and the three entry arches.
	env.section("Clubhouse", function(ctx)
		for _, s in ipairs({ -1, 1 }) do
			for _, k in ipairs({ 18, 26, 34 }) do
				bay(ctx, s * k, 20, 8, 11, 6, 9.5)
			end
		end
		for _, lx in ipairs({ -8.67, 0, 8.67 }) do
			bay(ctx, lx, 29.6, 8.66, 13, 6.4, 11.5)
		end
		-- Belvedere: one arched wall per side of the central pavilion (open, so the sky shows through).
		for _, w in ipairs({ { CF(0, 0, 9.4), 16 }, { CF(0, 0, -9.4), 16 }, { CF(9.4, 0, 0) * ANG(0, PI / 2, 0), 16 }, { CF(-9.4, 0, 0) * ANG(0, PI / 2, 0), 16 } }) do
			local res = ctx:arch("PavilionArch", {
				width = 8, height = 11, depth = 1.2, wallWidth = 16, wallHeight = 11.5,
				cframe = w[1] * CF(0, 26.5 + 11.5 / 2, 0), color = C.CREAM, material = M.PLASTER,
			})
			for _, p in ipairs(res.parts) do p.Name = "PavilionArch" end
		end
	end, nil, CFL)

	------------------------------------------------------------------ hip roofs (each a RoofHip Model)
	env.roof("Clubhouse", club, CFL, CF(-51, 22, -1), 26, 30, 8) -- left pavilion
	env.roof("Clubhouse", club, CFL, CF(-51, 33, -1), 8, 8, 3) -- its cupola
	env.roof("Clubhouse", club, CFL, CF(0, 22, -3), 88, 42, 11) -- main block (top ly 33)
	env.roof("Clubhouse", club, CFL, CF(0, 26, 22), 30, 18, 8) -- entry pavilion (lz 13..31)
	env.roof("Clubhouse", club, CFL, CF(0, 38.6, 0), 26, 26, 8) -- central pavilion (top ly 46.6)
	env.roof("Clubhouse", club, CFL, CF(55, 20, -1), 34, 30, 8) -- right block
	env.roof("Clubhouse", club, CFL, CF(76, 12, 0), 16, 20, 5) -- right-end pavilion
	env.roof("Clubhouse", club, CFL, CF(0, 13.2, 37.5), 24, 16, 4.5) -- porte-cochere (lx -12..12)

	-- Porte-cochere slab and posts (NE-side posts at lz 39, clear of lanes b and c).
	env.section("Clubhouse", function(ctx)
		box(ctx, "PorteCochere", -12, 12, 12, 13.2, 30, 44, C.TRIM, M.SMOOTH)
		for _, x in ipairs({ -11, 11 }) do
			for _, z in ipairs({ 31, 39 }) do
				vcyl(ctx, "Portepost", x, z, 0, 12, 1.2, C.TRIM, M.SMOOTH)
			end
		end
	end, nil, CFL)

	------------------------------------------------------------------ forecourt: paving, the round planter (off the lane-b centre line), flagpole, lamps
	env.section("Structure/Forecourt", function(ctx)
		box(ctx, "ForecourtPlate", -32, 32, -1, 0.3, 40, 56, C.CONC, M.CONC)
		box(ctx, "ForecourtKerb", -32, 32, 0, 0.6, 55.4, 56.4, C.CONC, M.CONC)
		vcyl(ctx, "RoundPlanter", -12, 50, 0, 1.6, 9, C.STONE, M.LIME)
		vcyl(ctx, "PlanterSoil", -12, 50, 1.6, 1.8, 8, C.SHRUB, M.GRASS)
		for k = 0, 5 do
			local a = k * PI / 3
			local p = ball(ctx, "PlanterShrub", -12 + 2.6 * math.cos(a), 2.4, 50 + 2.6 * math.sin(a), 1.8, k % 2 == 0 and C.FLOWER_R or C.SHRUB, M.GRASS)
			p.CanCollide = false
		end
		ball(ctx, "PlanterShrub", -12, 3, 50, 2.6, C.FLOWER_Y, M.GRASS).CanCollide = false
		vcyl(ctx, "Flagpole", -44, 30, 0, 14, 0.4, C.WHITE, M.SMOOTH)
		box(ctx, "FlagCloth", -44, -40.5, 11, 13.5, 30, 30.15, C.RED, M.SMOOTH)
		for _, p in ipairs({ { -30, 54 }, { 30, 54 } }) do
			vcyl(ctx, "LampPost", p[1], p[2], 0.3, 10, 0.4, C.IRON, M.METAL)
			ball(ctx, "LampGlobe", p[1], 10.4, p[2], 1.2, C.WHITE, M.SMOOTH)
		end
	end, nil, CFL)

	------------------------------------------------------------------ pool (unchanged from Revision 1): raised deck top ly 1.0 (y 21.0)
	env.section("Structure/Pool", function(ctx)
		box(ctx, "PoolDeck", 88, 134, -12, 1.0, -4, 28, C.BRICK, M.BRICK)
		for _, c in ipairs({
			{ 85, 122, 3, 4 }, { 85, 86, 3, 23 }, { 85, 112, 22, 23 }, { 130, 131, 9, 25 },
			{ 112, 131, 24, 25 }, { 122, 123, 3, 10 }, { 122, 130, 9, 10 }, { 111, 112, 10, 22 },
		}) do
			box(ctx, "PoolCoping", c[1], c[2], 1.0, 2.0, c[3], c[4], C.COPING, M.SMOOTH)
		end
		local water = box(ctx, "PoolWater", 86, 122, 1.0, 1.8, 4, 22, C.AQUA, M.GLASS)
		water.Transparency = 0.3
		water.CanCollide = false
		local lobe = box(ctx, "PoolWaterLobe", 112, 130, 1.0, 1.8, 10, 24, C.AQUA, M.GLASS)
		lobe.Transparency = 0.3
		lobe.CanCollide = false
		local function lounger(lx, lz)
			box(ctx, "Lounger", lx, lx + 2.2, 1.0, 1.6, lz, lz + 5, C.CART_T, M.SMOOTH)
			box(ctx, "LoungerBack", lx, lx + 0.8, 1.6, 3.0, lz, lz + 5, C.CART_T, M.SMOOTH)
			box(ctx, "LoungerCushion", lx + 0.3, lx + 1.9, 1.6, 1.9, lz + 0.5, lz + 4.5, C.WHITE, M.SMOOTH)
		end
		for _, x in ipairs({ 92, 100, 108, 116 }) do lounger(x, -3) end
		for _, x in ipairs({ 92, 100 }) do lounger(x, 23.5) end
		vcyl(ctx, "UmbrellaPole", 128, 0, 1.0, 9, 0.4, C.WHITE, M.SMOOTH)
		vcyl(ctx, "UmbrellaCanopy", 128, 0, 8.2, 8.8, 7, C.RED, M.SMOOTH)
	end, nil, CFL)
end
