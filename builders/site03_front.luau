-- site03_front: the FRONT of Site 03 (Lomi King), job L3c. Built from the Lomi King Architectural Blueprint Board (crops board_storefront, board_sign, board_right_ctx)
--   and the Street View photo; the recipes of the old single-file builder (scratch/site03_old.luau) are PORTED: steel posts and rail, letters, logo, bamboo, parking sign,
--   poster, corner pier, sign posts, driveway. Ported text is byte-identical (the 8 letters, RamenPoster, ParkingSign); no new on-screen text.
-- Studio copy: ServerStorage.Builders.site03_front. Assembler: builders/site03.luau. Check: tests/site03_check.luau, group "front" (also "general", "tower", "clear").
-- Owns Storefront and Sign (Models directly under Site03_Lomi). Budget 220.
-- FRAME: every number is WORLD (x east, z south, y up; this site faces WEST, the street is at small x). env.wbox / wvcyl / wball build world-aligned parts, env.W converts a
--   world point to the assembler's local frame. A SurfaceGui on a world-aligned part: Left = WEST face, Back = SOUTH face (+Z). Pure function of env: no DataModel reads, no TextService.
-- Storefront: AwningFascia (orange block x 274.4..284, z 114..166, y 12..16, no text) with a top lip, dark hems and the south return band (x 274.4..300, z 165.5..166.5);
--   LetterRail + Letter_1L..Letter_8G (silver LOMI, gold KING: invisible plates carrying one big SurfaceGui glyph on the west face, so the letters read as free-standing
--   metal letters on the canopy top); SteelPost1..3 and SteelRail (black frame of the open front, around the dining Menu banner at x 274.5..274.9); CornerPier;
--   the framed bamboo slat wall on the south face (SlatBack, BambooSlat*, SlatFrame*, BambooCap), RamenPoster (+ PosterBorder), ParkingSign (+ SignFrame*, SignPost*),
--   the black corner lamp (CornerLamp*), DrivewayAsphalt and the dashed DrivewayLine.
-- Sign: the round Lomi King / Kopi Vinz signboard north of the tower: LogoDisk (dark rim, faces west), LogoFace, LogoRing, LogoCore, LogoBowl (red / white / red / cream, ported
--   from the old file), LogoArm + LogoBracket joining it to the lattice mast: SignMast (central steel spine) with MastBrace* chords, ties and zigzag diagonals, and MastFoot.
-- Seams: the dining Menu banner is x 274.5..274.9, y 8.5..12, z 116..150; the dining FrontStep is x 274.5..284, y 0..1, z 116..150; pots x 275.5..280.5; the podium slab and south
--   wall stop at z 165.5; the tower bay glass starts at x 280; the south context neighbour and the car start at z 181 (the driveway ends at z 178).
return function(env)
	local V, CF = env.V, env.CF
	local W, wbox, wvcyl, wball = env.W, env.wbox, env.wvcyl, env.wball

	-- Colours
	local C3 = Color3.fromRGB
	local ORANGE, ORANGE_LIGHT, ORANGE_DARK = C3(225, 110, 40), C3(238, 128, 52), C3(170, 78, 28)
	local STEEL_D, SILVER = C3(40, 40, 45), C3(190, 194, 202)
	local PIER = C3(205, 120, 100)
	local SLAT, SLAT_BACK, BAMBOO_CAP = C3(190, 158, 104), C3(140, 108, 66), C3(120, 86, 50)
	local WHITE, RED, CREAM_GREY = C3(240, 240, 236), C3(200, 30, 40), C3(200, 196, 184)
	local ASPHALT, CONCRETE_C, LAMP = C3(62, 62, 66), C3(130, 128, 124), C3(255, 236, 190)
	local SMOOTH, METAL, WOODM = Enum.Material.SmoothPlastic, Enum.Material.Metal, Enum.Material.Wood
	local CONC, NEON = Enum.Material.Concrete, Enum.Material.Neon

	-- A flat label on one face of a part, fixed TextSize (never TextScaled on a long line; the `general` check measures the fit).
	local function gui(part, face, text, color, ppstud, size, scaleX, scaleY)
		local g = Instance.new("SurfaceGui")
		g.Face = face
		g.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		g.PixelsPerStud = ppstud
		g.Parent = part
		local t = Instance.new("TextLabel")
		t.Size = UDim2.fromScale(scaleX, scaleY)
		t.Position = UDim2.fromScale((1 - scaleX) / 2, (1 - scaleY) / 2)
		t.BackgroundTransparency = 1
		t.TextColor3 = color
		t.TextScaled = false
		t.TextSize = size
		t.TextWrapped = true
		t.Font = Enum.Font.GothamBlack
		t.Text = text
		t.Parent = g
		return t
	end

	------------------------------------------------------------------ Storefront
	env.section("Storefront", function(ctx)
		------------------------------------------------ canopy (orange block, no text on it)
		wbox(ctx, "AwningFascia", 274.4, 284, 12, 16, 114, 166, ORANGE, SMOOTH)
		-- south return band: the canopy block seen from the driveway, over the slat wall
		wbox(ctx, "AwningReturn", 274.4, 300, 12, 16, 165.5, 166.5, ORANGE, SMOOTH)
		-- top lip around the front, north and south edges (the letters stand inside it)
		wbox(ctx, "AwningLipFront", 274.4, 274.9, 16, 16.5, 114, 166.5, ORANGE_LIGHT, SMOOTH)
		wbox(ctx, "AwningLipN", 274.9, 284, 16, 16.5, 114, 114.5, ORANGE_LIGHT, SMOOTH)
		wbox(ctx, "AwningLipS", 274.9, 300, 16, 16.5, 165.5, 166.5, ORANGE_LIGHT, SMOOTH)
		-- darker hems along the lower edge of the west face and of the south return
		wbox(ctx, "AwningHemW", 274.1, 274.4, 12, 12.8, 114, 166.5, ORANGE_DARK, SMOOTH)
		wbox(ctx, "AwningHemS", 274.4, 300, 12, 12.8, 166.5, 166.8, ORANGE_DARK, SMOOTH)

		------------------------------------------------ letters LOMI KING (west face text, north to south)
		-- The plates are invisible: the glyph is the letter (silver LOMI, gold KING, dark outline), 8.5 studs of plate for a 4.7 stud cap height.
		-- Glyph advances at TextSize 100 (GothamBlack, measured once): L 51, O 70, M 79, I 29, K 63, I 29, N 67, G 63.
		-- Every plate is at least 4.2 wide (the label-fit rule charges 0.6 * TextSize px per glyph); neighbours may overlap, nothing collides.
		local word = "LOMIKING"
		local adv = { 51, 70, 79, 29, 63, 29, 67, 63 }
		local PPS, MARGIN, GAP = 15, 0.5, 2.0
		local total = GAP
		for i = 1, 8 do total += adv[i] / PPS + MARGIN end
		local zCursor = 140 - total / 2
		local zEnd = zCursor
		for i = 1, 8 do
			local ch = word:sub(i, i)
			local slot = adv[i] / PPS + MARGIN
			local centre = zCursor + slot / 2
			local half = math.max(slot, 4.2) / 2
			local p = wbox(ctx, "Letter_" .. i .. ch, 276.5, 278, 15.6, 24.1, centre - half, centre + half, STEEL_D, METAL)
			p.Transparency = 1
			p.CanCollide = false
			p.CastShadow = false
			local gold = i > 4
			local t = gui(p, Enum.NormalId.Left, ch, WHITE, PPS, 100, 1, 1)
			t.TextWrapped = false
			t.TextYAlignment = Enum.TextYAlignment.Bottom
			local grad = Instance.new("UIGradient")
			grad.Rotation = 90
			if gold then
				grad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, C3(255, 240, 175)), ColorSequenceKeypoint.new(0.45, C3(232, 190, 90)),
					ColorSequenceKeypoint.new(0.55, C3(165, 118, 38)), ColorSequenceKeypoint.new(1, C3(222, 180, 82)),
				})
			else
				grad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, C3(255, 255, 255)), ColorSequenceKeypoint.new(0.45, C3(214, 218, 226)),
					ColorSequenceKeypoint.new(0.55, C3(138, 144, 156)), ColorSequenceKeypoint.new(1, C3(200, 205, 214)),
				})
			end
			grad.Parent = t
			local stroke = Instance.new("UIStroke")
			stroke.Thickness = 3
			stroke.Color = C3(48, 40, 36)
			stroke.Parent = t
			zCursor += slot
			if i == 4 then zCursor += GAP end
			zEnd = zCursor
		end
		-- the metal channel the letters stand in
		wbox(ctx, "LetterRail", 276.6, 277.9, 16, 16.8, 140 - total / 2 - 0.3, zEnd + 0.3, SILVER, METAL)

		------------------------------------------------ black steel frame of the open front (the dining banner hangs in it)
		-- Posts stay out of the aisle (z 138..142); the middle post stands on the dining front step (top y 1).
		wbox(ctx, "SteelPost1", 274.95, 275.75, 0, 12, 115.2, 115.95, STEEL_D, METAL)
		wbox(ctx, "SteelPost2", 274.95, 275.75, 1.02, 12.02, 125.6, 126.4, STEEL_D, METAL)
		wbox(ctx, "SteelPost3", 274.95, 275.75, 0, 12, 150.05, 150.8, STEEL_D, METAL)
		wbox(ctx, "SteelRail", 274.95, 275.75, 11.4, 12, 115.2, 150.8, STEEL_D, METAL)

		------------------------------------------------ corner pier (darker than the wall), ground to canopy top
		wbox(ctx, "CornerPier", 274.4, 276.4, 0, 16, 164, 166, PIER, SMOOTH)

		------------------------------------------------ south face: framed bamboo slat wall (z 166..166.6), poster, parking sign (z 166.6..167.05)
		wbox(ctx, "SlatBack", 276.4, 300, 0.5, 11, 166, 166.2, SLAT_BACK, WOODM)
		-- vertical slats: two columns on the east half (full height) and one column above the sign
		local function slats(x0, x1, y0, y1)
			local n = math.floor((x1 - x0) / 1.1)
			local pitch = (x1 - x0) / n
			for k = 0, n - 1 do
				local a = x0 + k * pitch + (pitch - 0.6) / 2
				wbox(ctx, "BambooSlat" .. k, a, a + 0.6, y0, y1, 166.2, 166.45, SLAT, WOODM)
			end
		end
		slats(288.2, 293.6, 0.5, 11)
		slats(294, 299.6, 0.5, 11)
		slats(282.4, 287.8, 8.6, 11)
		-- black steel frame: five uprights and four rails (not Steel*: those names belong to the open front)
		for _, x in ipairs({ 276.4, 282, 287.8, 293.6, 299.6 }) do
			wbox(ctx, "SlatFrameV", x, x + 0.4, 0.5, 11, 166.4, 166.6, STEEL_D, METAL)
		end
		wbox(ctx, "SlatFrameBase", 276.4, 300, 0, 0.5, 166, 166.6, STEEL_D, METAL)
		wbox(ctx, "SlatFrameMid", 288.2, 300, 4.2, 4.5, 166.4, 166.6, STEEL_D, METAL)
		wbox(ctx, "SlatFrameUpper", 276.4, 300, 8.3, 8.6, 166.4, 166.6, STEEL_D, METAL)
		wbox(ctx, "SlatFrameTop", 276.4, 300, 11, 11.5, 166.4, 166.6, STEEL_D, METAL)
		wbox(ctx, "BambooCap", 276.4, 300, 11.5, 12, 166, 166.6, BAMBOO_CAP, WOODM)

		-- the red ramen poster above the sign, white border behind it
		wbox(ctx, "PosterBorder", 277, 281, 8.45, 11.45, 166.6, 166.65, WHITE, SMOOTH)
		local poster = wbox(ctx, "RamenPoster", 277.2, 280.8, 8.65, 11.25, 166.65, 166.85, RED, SMOOTH)
		gui(poster, Enum.NormalId.Back, "LOMI KING RAMEN", WHITE, 30, 20, 0.94, 0.8)

		-- the parking sign faces the driveway (south, +Z): white board, red text, black frame, two low posts
		local sign = wbox(ctx, "ParkingSign", 276.5, 288.5, 2.2, 8.2, 166.6, 167, WHITE, SMOOTH)
		gui(sign, Enum.NormalId.Back, "PARKING FOR LOMI KING CUSTOMERS ONLY", RED, 30, 38, 0.96, 0.84)
		wbox(ctx, "SignFrameT", 276.3, 288.7, 8.2, 8.4, 166.6, 167.05, STEEL_D, METAL)
		wbox(ctx, "SignFrameB", 276.3, 288.7, 2, 2.2, 166.6, 167.05, STEEL_D, METAL)
		wbox(ctx, "SignFrameL", 276.3, 276.5, 2.2, 8.2, 166.6, 167.05, STEEL_D, METAL)
		wbox(ctx, "SignFrameR", 288.5, 288.7, 2.2, 8.2, 166.6, 167.05, STEEL_D, METAL)
		wbox(ctx, "SignPost1", 277.5, 278, 0, 2, 166.6, 167, STEEL_D, METAL)
		wbox(ctx, "SignPost2", 287, 287.5, 0, 2, 166.6, 167, STEEL_D, METAL)

		-- the black lamp post at the corner of the pavement (board: in front of the pier)
		wvcyl(ctx, "CornerLampBase", 273.3, 167.2, 0, 0.6, 1.1, STEEL_D, METAL)
		wvcyl(ctx, "CornerLampPole", 273.3, 167.2, 0.6, 9.5, 0.45, STEEL_D, METAL)
		wball(ctx, "CornerLampGlobe", 273.3, 9.9, 167.2, 1.3, LAMP, NEON)

		------------------------------------------------ driveway south of the building (z 168..178; the context neighbour starts at z 181)
		wbox(ctx, "DrivewayAsphalt", 244, 340, 0, 0.2, 168, 178, ASPHALT, CONC)
		for k = 0, 10 do
			wbox(ctx, "DrivewayLine", 248 + k * 8, 252 + k * 8, 0.2, 0.3, 172.8, 173.2, WHITE, SMOOTH)
		end
	end)

	------------------------------------------------------------------ Sign: round signboard on a lattice mast, north of the tower
	env.section("Sign", function(ctx)
		local CY = 27 -- disc centre height; the disc is 10 across (y 22..32), centre z 114.5 (z 109.5..119.5), thin along x
		local function disc(name, x0, x1, dia, color)
			return ctx:cyl(name, V(x1 - x0, dia, dia), CF(W((x0 + x1) / 2, CY, 114.5)), color, SMOOTH)
		end
		disc("LogoDisk", 278.5, 279.5, 10, STEEL_D) -- dark rim and back of the board
		disc("LogoFace", 278.2, 278.5, 9.2, RED)
		disc("LogoRing", 278.0, 278.2, 8.2, WHITE)
		disc("LogoCore", 277.8, 278.0, 6.6, RED)
		disc("LogoBowl", 277.6, 277.8, 3.8, CREAM_GREY)
		wbox(ctx, "LogoArm", 279.5, 280.5, 30.4, 31.2, 111.4, 112.6, STEEL_D, METAL)
		wbox(ctx, "LogoBracket", 279.5, 280.5, 23.4, 24.2, 111.4, 112.6, STEEL_D, METAL)

		-- lattice mast: x 279.6..282, z 110.5..113.5, y 0..40: a central spine, four corner chords, zigzag diagonals and horizontal ties
		wbox(ctx, "MastFoot", 279.2, 282.4, 0, 0.5, 110.1, 113.9, CONCRETE_C, CONC)
		wbox(ctx, "SignMast", 280.4, 281.2, 0, 40, 111.6, 112.4, STEEL_D, METAL)
		local n = 0
		for _, x in ipairs({ 279.6, 281.6 }) do
			for _, z in ipairs({ 110.5, 113.1 }) do
				n += 1
				wbox(ctx, "MastBraceChord" .. n, x, x + 0.4, 0, 40, z, z + 0.4, STEEL_D, METAL)
			end
		end
		-- a strut between two world points (square section t)
		local function strut(name, ax, ay, az, bx, by, bz, t)
			local a, b = W(ax, ay, az), W(bx, by, bz)
			local mid = (a + b) / 2
			return ctx:part(name, V(t, t, (b - a).Magnitude), CFrame.lookAt(mid, b), STEEL_D, METAL)
		end
		local STEP = 5
		for k = 0, 7 do
			local y0, y1 = k * STEP, (k + 1) * STEP
			local flip = k % 2 == 0
			-- west face (the street side): diagonal and a tie at the top of each panel
			strut("MastBraceDiagW" .. k, 279.8, y0, flip and 110.7 or 113.3, 279.8, y1, flip and 113.3 or 110.7, 0.25)
			-- north and south faces
			strut("MastBraceDiagN" .. k, flip and 279.8 or 281.8, y0, 110.7, flip and 281.8 or 279.8, y1, 110.7, 0.25)
			strut("MastBraceDiagS" .. k, flip and 281.8 or 279.8, y0, 113.3, flip and 279.8 or 281.8, y1, 113.3, 0.25)
			local top = k == 7 and 39.7 or y1 - 0.15
			wbox(ctx, "MastBraceTieW" .. k, 279.65, 279.95, top, top + 0.3, 110.9, 113.1, STEEL_D, METAL)
			if k % 2 == 1 then
				wbox(ctx, "MastBraceTieN" .. k, 280, 281.6, top, top + 0.3, 110.55, 110.85, STEEL_D, METAL)
				wbox(ctx, "MastBraceTieS" .. k, 280, 281.6, top, top + 0.3, 113.15, 113.45, STEEL_D, METAL)
			end
		end
	end)
end
