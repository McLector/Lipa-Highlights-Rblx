-- site02_hall: the front arcade of Site 02 (Candido B. Lopez Memorial Public Market), rebuilt from PublicMarketBP1.jpg (Slice 4, job 4a).
-- Studio copy: ServerStorage.Builders.site02_hall. Assembler: builders/site02.luau. Check: tests/site02_check.luau, group "hall".
-- Owns Structure/Hall/Shell (walls, pilasters, bays, doors, slabs, cornices, railings, roofs, NameBand) and Structure/Hall/Windows
-- (ArchWindow / ArchWindowTall Models, Window2_n). NOT built here (job 4b, module site02_front): portico terrace, stairs, scaffold.
-- Numbers: scratch/site02/layout.md 3.1. All coordinates below are WORLD (frame x east, z south, y up); wbox / W convert to the
-- assembler's local frame (local = world - ORIGIN, y unchanged). Pure function of env: nothing read from the DataModel.
-- Storeys: ground (open rectangular bays, no arches) y 0..9.5, floor 2 to 18.5, floor 3 to the cornice at 30.5; arches on floor 3 only.
-- Bays (north to south): 1 tall end bay, 7 north-wing bays, 3 pavilion bays (tall, ordinary, tall), 6 south-wing bays, 1 tall end bay = 18.
-- BP1 and BP2: the 13 wing arches repeat at a pitch of 9.25 (one bay each) and are 7.9 wide, shallow, on the floor-3 rail; the end tall bays take the rest.
-- Roofs: SOUTH wing a low hip (eave 30.5, ridge 34.5, ridge along z); NORTH wing BP2's huge broad ribbed hip (hybrid: the 7 BP1 arches stay under it):
-- eave 30.5, ridge 35.4, z 66..145.6, overhanging the walls by 4, hipped only at the north end, a vertical gable plate flush with the pavilion's north face,
-- RoofRib strips (darker red) up the slopes. Taller hip over the pavilion body (apex 36, ridge along x) that stops at the body face x -262.6: BP1 draws
-- the portico as an open terrace (job 4b) with no roof over it. Each roof face is a thin plate (rectangle or right-triangle wedge).
return function(env)
	local V, ANG, PI = env.V, env.ANG, env.PI
	local W, wbox = env.W, env.wbox
	local ox, oz = env.ORIGIN.X, env.ORIGIN.Z
	local C3 = Color3.fromRGB
	local MCON, MSMO, MGLA, MMET = Enum.Material.Concrete, Enum.Material.SmoothPlastic, Enum.Material.Glass, Enum.Material.Metal
	local WALL, RED, DRED, ROOF = C3(230, 226, 214), C3(176, 62, 50), C3(146, 46, 40), C3(172, 78, 72)
	local GLASS, FRAME, DARK, SHUT, WHITE = C3(60, 78, 92), C3(205, 208, 210), C3(58, 52, 50), C3(34, 104, 176), C3(244, 244, 240)
	local XW, XE = -299.7, -262.6 -- west and east wall faces of the wings
	local Z0, Z1, ZP0, ZP1 = 71.4, 249.3, 145.6, 174.4 -- building ends and the pavilion's sides
	local PITCH, PH = 9.25, 0.7 -- BP1 and BP2: every wing arch repeats at 9.25; pilasters are 1.4 wide (half PH)
	local ZE = 244.2 -- centre of the south end pilaster: it stands in from the building end, leaving a short railed strip (ZE + PH .. Z1) beyond it

	------------------------------------------------------------------ bays: { z start, z end, kind [, tall arch centre, tall arch outer width] }
	-- The 13 wing bays are exactly one pitch wide; the end tall bays take what is left (north 9.45, south 14.3), so their tall arch is placed by hand.
	local bays = {}
	local function addBay(a, b, kind, c, w) bays[#bays + 1] = { a, b, kind, c, w } end
	local zn = ZP0 - 7 * PITCH -- 80.85, where the north end bay stops and the 7 wing arches begin
	addBay(Z0, zn, "tall", ((Z0 + 2 * PH) + (zn - PH)) / 2, 7.8) -- squeezed between the end pilaster and the first one: about 7.35 clear
	for k = 0, 6 do addBay(zn + PITCH * k, zn + PITCH * (k + 1), "n") end
	addBay(ZP0, ZP0 + 9.6, "ptall")
	addBay(ZP0 + 9.6, ZP0 + 19.2, "mid")
	addBay(ZP0 + 19.2, ZP1, "ptall")
	for k = 0, 5 do addBay(ZP1 + PITCH * k, ZP1 + PITCH * (k + 1), "s") end
	addBay(ZP1 + 6 * PITCH, ZE, "tall", (ZP1 + 6 * PITCH + ZE) / 2, 8.5) -- 14.3 wide bay between pilaster 18 and the end pilaster, the tall arch centred in it (z 237.05, about 2 of wall each side)
	assert(#bays == 18, "site02_hall: expected 18 bays")

	------------------------------------------------------------------ roof plates (world points, thin plates whose top face is the roof plane)
	local TH = 0.4
	local function lv(p) return V(p.X - ox, p.Y, p.Z - oz) end
	local function wedgeAt(ctx, nm, P, Q1, Q2) -- right-angle plate: right angle at P, legs to Q1 and Q2
		local u1, u2 = Q1 - P, Q2 - P
		local a, b = u1.Magnitude, u2.Magnitude
		u1, u2 = u1 / a, u2 / b
		if u1:Cross(u2).Y < 0 then u1, u2, a, b = u2, u1, b, a end
		local n = u1:Cross(u2)
		local c = P + u1 * (a / 2) + u2 * (b / 2) - n * (TH / 2)
		return ctx:wedge(nm(), V(TH, b, a), CFrame.fromMatrix(lv(c), n, u2, -u1), ROOF, MMET)
	end
	local function tri(ctx, nm, A, B, C) -- any triangle as two right-angle plates (A-B must be its longest side)
		local ab = B - A
		local F = A + ab * ((C - A):Dot(ab) / ab:Dot(ab))
		wedgeAt(ctx, nm, F, A, C)
		wedgeAt(ctx, nm, F, B, C)
	end
	local function hip(ctx, nm, u0, u1, v0, v1, y0, y1, pt) -- hip roof over u0..u1 (ridge direction) by v0..v1; pt(u, v, y) -> world point
		local vm, h = (v0 + v1) / 2, (v1 - v0) / 2
		for _, sv in ipairs({ v0, v1 }) do
			local O = pt(u0 + h, sv, y0)
			local r = pt(u1 - h, sv, y0) - O
			local s = pt(u0 + h, vm, y1) - O
			local n = r:Cross(s).Unit
			if n.Y < 0 then n = -n end
			local rx = r.Unit
			ctx:part(nm(), V(r.Magnitude, TH, s.Magnitude), CFrame.fromMatrix(lv(O + r / 2 + s / 2 - n * (TH / 2)), rx, n, rx:Cross(n)), ROOF, MMET)
			wedgeAt(ctx, nm, pt(u0 + h, sv, y0), pt(u0, sv, y0), pt(u0 + h, vm, y1))
			wedgeAt(ctx, nm, pt(u1 - h, sv, y0), pt(u1, sv, y0), pt(u1 - h, vm, y1))
		end
		tri(ctx, nm, pt(u0, v0, y0), pt(u0, v1, y0), pt(u0 + h, vm, y1))
		tri(ctx, nm, pt(u1, v0, y0), pt(u1, v1, y0), pt(u1 - h, vm, y1))
	end
	local function namer(prefix)
		local n = 0
		return function() n += 1 return prefix .. n end
	end

	------------------------------------------------------------------ Structure/Hall/Shell
	env.section("Hall/Shell", function(ctx)
		-- wall blocks (ONE part each, same colour and material so the shared faces do not show)
		wbox(ctx, "HallBody", XW, XE, 0, 30.5, Z0, Z1, WALL, MCON)
		wbox(ctx, "PavilionBody", -303.3, XE, 0, 30.5, ZP0, ZP1, WALL, MCON)
		-- 19 red pilasters (1.4 wide) at the bay boundaries, full height; the north end one sits flush with the building end, the south one closes the last bay at ZE
		for i = 0, 18 do
			local z = (i < 18) and bays[i + 1][1] or ZE
			z = math.max(Z0 + PH, math.min(Z1 - PH, z))
			wbox(ctx, "Pilaster" .. (i + 1), XE, -261.0, 0, 30.0, z - PH, z + PH, RED, MSMO)
		end
		-- ground storey: 18 open rectangular bays (dark recesses), roller-shutter doors in 8 of them
		local doorAt = { [2] = true, [4] = true, [6] = true, [8] = true, [12] = true, [14] = true, [16] = true, [18] = true }
		local d = 0
		for i, b in ipairs(bays) do
			wbox(ctx, "GroundBay" .. i, XE, -262.3, 0.05, 9.0, b[1] + 1.2, b[2] - 1.2, DARK, MCON)
			if doorAt[i] then
				d += 1
				local dc = (b[1] + b[2]) / 2 -- the south end bay (14.3 wide) gets a normal 8.5 door under its tall arch
				local dh = math.min((b[2] - b[1]) / 2 - 1.3, 4.25)
				wbox(ctx, "Door" .. d, -262.3, -261.95, 0.05, 8.45, dc - dh, dc + dh, SHUT, Enum.Material.Metal)
			end
		end
		-- storey slabs: floor-2 deck (3 deep, top 9.5) and floor-3 balcony (2.4 deep, top 18.5) along both wings
		wbox(ctx, "FloorSlab2N", XE, -259.6, 8.9, 9.5, Z0, ZP0, WALL, MCON)
		wbox(ctx, "FloorSlab2S", XE, -259.6, 8.9, 9.5, ZP1, Z1, WALL, MCON)
		wbox(ctx, "FloorSlab3N", XE, -260.2, 17.9, 18.5, Z0, ZP0, WALL, MCON)
		wbox(ctx, "FloorSlab3S", XE, -260.2, 17.9, 18.5, ZP1, Z1, WALL, MCON)
		-- frieze band under the cornice: the NameBand sits proud of the pilasters, so no pilaster cuts the lettering
		local nb = wbox(ctx, "NameBand", XE, -260.6, 26.8, 30.4, Z0 + 0.6, Z1 - 0.6, WHITE, MSMO)
		local gui = Instance.new("SurfaceGui")
		gui.Name = "NameBandGui"
		gui.Face = Enum.NormalId.Right -- the part is unrotated, so Right is world +X (east)
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 25
		gui.LightInfluence = 0
		gui.Parent = nb
		local lab = Instance.new("TextLabel")
		lab.Name = "NameLabel"
		lab.BackgroundTransparency = 1
		lab.Size = UDim2.new(1, 0, 0.8, 0)
		lab.Position = UDim2.new(0, 0, 0.16, 0)
		lab.Text = "CANDIDO B. LOPEZ MEMORIAL PUBLIC MARKET"
		lab.Font = Enum.Font.GothamBold
		lab.TextSize = 60
		lab.TextScaled = false
		lab.TextWrapped = false
		lab.TextXAlignment = Enum.TextXAlignment.Center
		lab.TextYAlignment = Enum.TextYAlignment.Center
		lab.TextColor3 = C3(20, 50, 170)
		lab.Parent = gui
		-- cornice (top 30.5): east face, both ends, west, and the pavilion's west face
		wbox(ctx, "Cornice1", XE, -260.0, 29.9, 30.5, Z0 - 1.0, Z1 + 1.0, DRED, MSMO)
		wbox(ctx, "Cornice2", -300.9, XE, 29.9, 30.5, Z0 - 1.0, Z0, DRED, MSMO)
		wbox(ctx, "Cornice3", -300.9, XE, 29.9, 30.5, Z1, Z1 + 1.0, DRED, MSMO)
		wbox(ctx, "Cornice4", -300.9, XW, 29.9, 30.5, Z0, Z1, DRED, MSMO)
		wbox(ctx, "Cornice5", -304.5, -303.3, 29.9, 30.5, ZP0 - 1.0, ZP1 + 1.0, DRED, MSMO)
		-- balustrades: rail top 12.5 (floor 2) and 21.5 (floor 3), low rail, posts 3.0 tall every 4.6 or so. BP1 and BP2 draw no rail across the two tall end arches:
		-- the north rail starts past pilaster 2, the south rail stops at pilaster 18, and the plain strip beyond the south end pilaster (E) has its own short rail
		local post = 0
		for _, wing in ipairs({ { "N", zn + PH, ZP0 }, { "S", ZP1, bays[18][1] + PH }, { "E", ZE + PH, Z1 } }) do
			for _, fl in ipairs({ { 2, 9.5, -259.9 }, { 3, 18.5, -260.5 } }) do
				local y0, xc = fl[2], fl[3]
				wbox(ctx, "Balustrade" .. fl[1] .. wing[1], xc - 0.3, xc + 0.3, y0 + 2.6, y0 + 3.0, wing[2], wing[3], WALL, MCON)
				wbox(ctx, "RailLow" .. fl[1] .. wing[1], xc - 0.25, xc + 0.25, y0 + 0.9, y0 + 1.2, wing[2], wing[3], WALL, MCON)
				local n = math.ceil((wing[3] - wing[2]) / 4.6)
				for k = 0, n do
					post += 1
					local z = wing[2] + 0.25 + (wing[3] - wing[2] - 0.5) * k / n
					wbox(ctx, "RailPost" .. post, xc - 0.25, xc + 0.25, y0, y0 + 3.0, z - 0.25, z + 0.25, WALL, MCON)
				end
			end
		end
		-- roofs: low hip over each wing (ridge along z), taller hip over the pavilion body (ridge along x, stops at the body face; the portico is an open terrace)
		local function alongZ(u, v, y) return V(v, y, u) end
		local function alongX(u, v, y) return V(u, y, v) end
		local wn = namer("WingRoof")
		-- north wing: BP2's big roof. Ridge line x XC, half depth HD (4 past each wall face), flat ridge z ZH..ZP0, hip run HD at the north end only, so
		-- ZN = ZH - HD. The south end is a vertical cut at ZP0 closed by a thin gable plate. Long slopes are cut into 4 plates a side to keep every plate short.
		local XC, HD, ZN, YE, YR = (XW + XE) / 2, 22.5, 66.0, 30.5, 35.4
		local ZH = ZN + HD
		local xa, xb = XC - HD, XC + HD
		for _, sv in ipairs({ xa, xb }) do
			local segs = 4
			local dz = (ZP0 - ZH) / segs
			for k = 0, segs - 1 do
				local O = alongZ(ZH + dz * k, sv, YE)
				local r = alongZ(ZH + dz * (k + 1), sv, YE) - O
				local s = alongZ(ZH + dz * k, XC, YR) - O
				local n = r:Cross(s).Unit
				if n.Y < 0 then n = -n end
				local rx = r.Unit
				ctx:part(wn(), V(r.Magnitude, TH, s.Magnitude), CFrame.fromMatrix(lv(O + r / 2 + s / 2 - n * (TH / 2)), rx, n, rx:Cross(n)), ROOF, MMET)
			end
			wedgeAt(ctx, wn, alongZ(ZH, sv, YE), alongZ(ZN, sv, YE), alongZ(ZH, XC, YR)) -- the slope's triangle over the hip run
		end
		tri(ctx, wn, alongZ(ZN, xa, YE), alongZ(ZN, xb, YE), alongZ(ZH, XC, YR)) -- the north hip face
		-- gable plate in the plane z ZP0 (argument order puts the plate on its north side, so nothing pokes into the pavilion)
		wedgeAt(ctx, wn, alongZ(ZP0, XC, YE), alongZ(ZP0, XC, YR), alongZ(ZP0, xa, YE))
		wedgeAt(ctx, wn, alongZ(ZP0, XC, YE), alongZ(ZP0, xb, YE), alongZ(ZP0, XC, YR))
		-- ribs: thin darker-red strips lying on the faces, running up the slope (a few long ones, not dozens of small parts)
		local RIB = C3(160, 64, 60)
		local rn = namer("RoofRib")
		local function rib(A, B, n) -- surface points A (low) to B (high), n the face's upward normal
			local rx = (B - A).Unit
			ctx:part(rn(), V((B - A).Magnitude, 0.2, 0.35), CFrame.fromMatrix(lv((A + B) / 2 + n * 0.07), rx, n, rx:Cross(n)), RIB, MMET)
		end
		for _, zc in ipairs({ 95, 108, 121, 134 }) do
			for _, sv in ipairs({ xa, xb }) do
				local A, B = alongZ(zc, sv + (XC - sv) * 0.04, YE + (YR - YE) * 0.04), alongZ(zc, sv + (XC - sv) * 0.96, YE + (YR - YE) * 0.96)
				local n = (B - A):Cross(Vector3.new(0, 0, 1)).Unit
				rib(A, B, n.Y < 0 and -n or n)
			end
		end
		local hipN = Vector3.new(0, HD, -(YR - YE)).Unit -- the hip face leans north
		for _, d in ipairs({ -9, 0, 9 }) do -- on the hip face only: at x offset d it ends where the side slope takes over, z ZN + |d|
			local zb = (d == 0) and ZH - 0.6 or ZN + math.abs(d) - 1.0
			local function onHip(z) return alongZ(z, XC + d, YE + (YR - YE) * (z - ZN) / HD) end
			rib(onHip(ZN + 1.0), onHip(zb), hipN)
		end
		hip(ctx, wn, ZP1, Z1, XW, XE, 30.5, 34.5, alongZ)
		hip(ctx, namer("PavilionRoof"), -303.3, XE, ZP0, ZP1, 30.5, 36.0, alongX)
	end)

	------------------------------------------------------------------ Structure/Hall/Windows
	local WIN = env.container("Hall/Windows")
	local function arch(name, zc, w, y0, h, grid)
		local m = env.newChild(WIN, name, "Model")
		env.section("Hall/Windows", function(ctx)
			local function at(x, y) return CFrame.new(W(x, y, zc)) * ANG(0, PI / 2, 0) end
			ctx:window(name .. "_Frame", w + 0.6, h + 0.4, 0.3, at(-262.45, y0 - 0.2), FRAME, MSMO)
			ctx:window(name .. "_Glass", w, h, 0.3, at(-262.3, y0), GLASS, MGLA)
			if grid then
				for _, dz in ipairs({ -w / 6, w / 6 }) do wbox(ctx, name .. "_Mullion", -262.15, -261.9, y0, y0 + h - 1.5, zc + dz - 0.12, zc + dz + 0.12, FRAME, MSMO) end
				for _, f in ipairs({ 0.3, 0.55, 0.8 }) do wbox(ctx, name .. "_Transom", -262.15, -261.9, y0 + h * f, y0 + h * f + 0.25, zc - w / 2, zc + w / 2, FRAME, MSMO) end
			end
		end, m)
	end
	-- wing arch (BP1 and BP2): a SHALLOW opening 7.9 wide on the floor-3 rail, sill y 21.0, hood top y 26.4: a frame rectangle and a glass rectangle whose two
	-- top corners are cut by wall-coloured wedges (rise 1.6 over 2.6), with a thin frame-coloured hood strip along each slope. No mullion: neither sheet draws one.
	local WING_W, SILL, HOOD = 7.9, 21.0, 26.4
	local function wingArch(name, zc)
		local m = env.newChild(WIN, name, "Model")
		env.section("Hall/Windows", function(ctx)
			local hw, ax, ay = WING_W / 2, 2.6, 1.6
			wbox(ctx, name .. "_Frame", -262.6, -262.3, SILL - 0.2, HOOD, zc - hw, zc + hw, FRAME, MSMO)
			wbox(ctx, name .. "_Glass", -262.45, -262.15, SILL, HOOD - 0.3, zc - hw + 0.3, zc + hw - 0.3, GLASS, MGLA)
			for _, s in ipairs({ -1, 1 }) do
				local P = V(-262.0, HOOD, zc + s * hw) -- the top outer corner; the wedge's right angle
				local u1, u2 = V(0, -ay, 0), V(0, 0, -s * ax)
				local a, b = ay, ax
				if u1:Cross(u2).X < 0 then u1, u2, a, b = u2, u1, b, a end
				local n = u1:Cross(u2).Unit
				local c = P + u1 / 2 + u2 / 2 - n * 0.15
				ctx:wedge(name .. "_Spandrel", V(0.3, b, a), CFrame.fromMatrix(lv(c), n, u2.Unit, -u1.Unit), WALL, MCON)
				local d = V(0, ay, -s * ax) -- the slope, rising toward the middle
				local inward = V(0, -ax, -s * ay).Unit * 0.175 -- the strip lies just inside the cut
				local mid = V(-261.9, HOOD - ay / 2, zc + s * (hw - ax / 2)) + inward
				local du = d.Unit
				ctx:part(name .. "_Hood", V(0.2, d.Magnitude, 0.35), CFrame.fromMatrix(lv(mid), V(1, 0, 0), du, V(1, 0, 0):Cross(du)), FRAME, MSMO)
			end
		end, m)
	end
	local nArch, nTall, nWin = 0, 0, 0
	local function window2(zc, w) -- floor-2 rectangular window (BP1: wide, above the floor-2 rail)
		nWin += 1
		env.section("Hall/Windows", function(ctx)
			wbox(ctx, "Window2Frame" .. nWin, XE, -262.3, 12.5, 16.7, zc - w / 2, zc + w / 2, FRAME, MSMO)
			wbox(ctx, "Window2_" .. nWin, XE, -262.15, 12.7, 16.5, zc - w / 2 + 0.3, zc + w / 2 - 0.3, GLASS, MGLA)
		end)
	end
	for _, b in ipairs(bays) do
		local zc, kind = (b[1] + b[2]) / 2, b[3]
		if kind == "tall" or kind == "ptall" then -- tall arches keep BuildKit:window's round head: glass width = outer width - 0.6 (flanks 5.0, ends by hand)
			nTall += 1
			arch("ArchWindowTall" .. nTall, b[4] or zc, (b[5] or 5.0) - 0.6, 10.0, 15.1, true)
		elseif kind == "mid" then -- the pavilion centre arch: round head 7.8 wide, 7.5 tall above y 18.7 so BuildKit:window's disc does not poke below
			nArch += 1
			arch("ArchWindow" .. nArch, zc, 7.2, 18.7, 7.5, false)
			window2(zc, 7.4)
		else
			nArch += 1
			wingArch("ArchWindow" .. nArch, zc)
			window2(zc, 7.5)
		end
	end
	assert(nArch == 14 and nTall == 4 and nWin == 14, string.format("site02_hall: %d arches, %d tall, %d floor-2 windows", nArch, nTall, nWin))
end
