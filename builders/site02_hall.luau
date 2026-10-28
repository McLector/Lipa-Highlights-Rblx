-- site02_hall: the front arcade of Site 02 (Candido B. Lopez Memorial Public Market), rebuilt from PublicMarketBP1.jpg (Slice 4, job 4a).
-- Studio copy: ServerStorage.Builders.site02_hall. Assembler: builders/site02.luau. Check: tests/site02_check.luau, group "hall".
-- Owns Structure/Hall/Shell (walls, pilasters, bays, doors, slabs, cornices, railings, roofs, NameBand) and Structure/Hall/Windows
-- (ArchWindow / ArchWindowTall Models, Window2_n). NOT built here (job 4b, module site02_front): portico columns and roof, stairs, scaffold.
-- Numbers: scratch/site02/layout.md 3.1. All coordinates below are WORLD (frame x east, z south, y up); wbox / W convert to the
-- assembler's local frame (local = world - ORIGIN, y unchanged). Pure function of env: nothing read from the DataModel.
-- Storeys: ground (open rectangular bays, no arches) y 0..9.5, floor 2 to 18.5, floor 3 to the cornice at 30.5; arches on floor 3 only.
-- Bays (north to south): 1 tall end bay, 7 north-wing bays, 3 pavilion bays (tall, ordinary, tall), 6 south-wing bays, 1 tall end bay = 18.
-- Roofs: low hips over each wing (eave 30.5, ridge 34.5, ridge along z), taller hip over the pavilion (apex 36, ridge along x) that
-- reaches x -250.4 so that the portico of job 4b has a roof overhead. Each roof face is a thin plate (rectangle or right-triangle wedge).
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

	------------------------------------------------------------------ bays: { z start, z end, kind }
	local bays = {}
	local function addBay(a, b, kind) bays[#bays + 1] = { a, b, kind } end
	addBay(Z0, Z0 + 12, "tall")
	local pn = (ZP0 - (Z0 + 12)) / 7
	for k = 0, 6 do addBay(Z0 + 12 + pn * k, Z0 + 12 + pn * (k + 1), "n") end
	addBay(ZP0, ZP0 + 9.6, "ptall")
	addBay(ZP0 + 9.6, ZP0 + 19.2, "mid")
	addBay(ZP0 + 19.2, ZP1, "ptall")
	local ps = ((Z1 - 12) - ZP1) / 6
	for k = 0, 5 do addBay(ZP1 + ps * k, ZP1 + ps * (k + 1), "s") end
	addBay(Z1 - 12, Z1, "tall")
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
		-- 19 red pilasters at the bay boundaries, full height
		for i = 0, 18 do
			local z = (i < 18) and bays[i + 1][1] or Z1
			z = math.max(Z0 + 0.8, math.min(Z1 - 0.8, z))
			wbox(ctx, "Pilaster" .. (i + 1), XE, -261.0, 0, 30.0, z - 0.8, z + 0.8, RED, MSMO)
		end
		-- ground storey: 18 open rectangular bays (dark recesses), roller-shutter doors in 8 of them
		local doorAt = { [2] = true, [4] = true, [6] = true, [8] = true, [12] = true, [14] = true, [16] = true, [18] = true }
		local d = 0
		for i, b in ipairs(bays) do
			wbox(ctx, "GroundBay" .. i, XE, -262.3, 0.05, 9.0, b[1] + 1.2, b[2] - 1.2, DARK, MCON)
			if doorAt[i] then
				d += 1
				wbox(ctx, "Door" .. d, -262.3, -261.95, 0.05, 8.45, b[1] + 1.3, b[2] - 1.3, SHUT, Enum.Material.Metal)
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
		-- balustrades: rail top 12.5 (floor 2) and 21.5 (floor 3), low rail, posts 3.0 tall every 4.6 or so
		local post = 0
		for _, wing in ipairs({ { "N", Z0, ZP0 }, { "S", ZP1, Z1 } }) do
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
		-- roofs: low hip over each wing (ridge along z), taller hip over the pavilion (ridge along x, reaches the portico line x -250.4)
		local function alongZ(u, v, y) return V(v, y, u) end
		local function alongX(u, v, y) return V(u, y, v) end
		local wn = namer("WingRoof")
		hip(ctx, wn, Z0, ZP0, XW, XE, 30.5, 34.5, alongZ)
		hip(ctx, wn, ZP1, Z1, XW, XE, 30.5, 34.5, alongZ)
		hip(ctx, namer("PavilionRoof"), -303.3, -250.4, ZP0, ZP1, 30.5, 36.0, alongX)
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
			else
				wbox(ctx, name .. "_Mullion", -262.15, -261.9, y0, y0 + h - 0.2, zc - 0.12, zc + 0.12, FRAME, MSMO)
			end
		end, m)
	end
	local nArch, nTall, nWin = 0, 0, 0
	local widthOf = { n = 6.0, s = 7.0, mid = 6.4 } -- BuildKit:window draws a full circle on top, so every arch is at least as tall as it is wide
	for _, b in ipairs(bays) do
		local zc, kind = (b[1] + b[2]) / 2, b[3]
		if kind == "tall" or kind == "ptall" then
			nTall += 1
			arch("ArchWindowTall" .. nTall, zc, (b[2] - b[1]) - 2.8, 10.0, 14.5, true)
		else
			nArch += 1
			arch("ArchWindow" .. nArch, zc, widthOf[kind], 19.0, 7.4, false)
			nWin += 1
			local ww = widthOf[kind] - 0.6
			env.section("Hall/Windows", function(ctx)
				wbox(ctx, "Window2Frame" .. nWin, XE, -262.3, 12.5, 18.1, zc - ww / 2 - 0.4, zc + ww / 2 + 0.4, FRAME, MSMO)
				wbox(ctx, "Window2_" .. nWin, XE, -262.15, 12.8, 17.8, zc - ww / 2, zc + ww / 2, GLASS, MGLA)
			end)
		end
	end
	assert(nArch == 14 and nTall == 4 and nWin == 14, string.format("site02_hall: %d arches, %d tall, %d floor-2 windows", nArch, nTall, nWin))
end
