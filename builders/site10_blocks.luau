-- site10_blocks: the staggered white-brick slabs and the sunshade ledge of Site 10 (New Lipa City Hall). Studio copy: ServerStorage.Builders.site10_blocks.
-- Owner container: Blocks. Module budget: 500 parts. Check group: shared.site10_only = "blocks" (tests/site10_check.luau).
-- Design: scratch/site10/layout.md ("Blocks") + model.py; the owner's drawing "Lipa City Hall Blueprint.png" is the truth. Loaded by builders/site10.luau.
-- PLAN
--   Blocks.WingBoxes   : Models WB01..WB09 (the long-wing slabs) and Sunshade1 (thin ledge over the lobby doors).
--   Blocks.AtriumBoxes : Models AB1..AB5 (rotated with the atrium: they sit on the SE and SW faces of the pulled-back pentagon PC).
--     The drawing shows a FEW BIG FLAT SLABS of cream brick, staggered in front of the glass, with glazed bays between them. So every box is
--     a thin plate (main body 3 to 4.7 deep, 8 to 24 wide, 1 to 2 storeys tall); five long-wing slabs (WB01, 02, 05, 07, 09) rise to the roof line.
--     One slab (a Model named by its layout label) is made of
--       WhiteBrickBox  = the main volume (a Part, Brick, cream 235,232,222)
--       WhiteBrickBoxF = the centre third of the curved front face, pushed out (Part)
--       WhiteBrickBoxW = two plan-triangle wedges that join the body to the centre facet, so the front reads as a 3-facet curved face (WedgePart)
--       WhiteBrickBoxC = thin darker cream brick lines proud of the front facets: horizontal bed lines every 3.6 studs and staggered
--                        vertical joints (running bond) every 6 studs.
--     Everything in a slab is named WhiteBrickBox<letter> on purpose: the clearance check ignores brick boxes that stack on each other, and the
--     lines and wedges are brick too. Pilotis_<label> are slim white columns under the low slabs that stand 10 up (WB03, 06, 08).
--   Rules kept: slabs start at lx 23.5 (the face of the glass mullions; 24 for the roof-line slabs, the end of the roof slab) so nothing is
--     buried in the glass; the main volume of every slab has its centre column clear of glass, spandrels and wall undersides (the raised-box
--     clearance check looks straight down from it); no part is named *Rail*; no Decals, no text, no logo (the drawing's seal slab WB07 and the
--     end cap WB09 stay plain brick); nothing near the spawn pad, Guide or panel.
--   Notes: stacked slabs touch (WB02 on WB03, WB05 on WB06, WB07 on WB08); Sunshade1 spans lz -62.5..-47.5 (no slab centre there);
--     WB09 is flush with the north end of the roof slab (lz -114); the atrium slabs are big thin plates in two tiers on the SE face (edge 4,
--     59 long) and the SW face (edge 5, 43 long) of PC. SE: two TALL plates AB2 (u 3..18, y 20.8..42.8) and AB1 (u 20.5..35.5, y 24.8..42.8), a small low
--     plate AB3 (u 35.5..43, y 14.4..22.4) and the corner strip AB6. SW: upper tier y 29.4..42.8 (AB4 u 2..27), lower tier y 14.4..26.4 (AB5 u 12..40).
--     A glass strip shows between neighbours. AB3 and AB5 (bottom 14.4, 10 over the
--     atrium floor top 4.4) have no pilotis: they hang off the glass wall like the others.
-- Pure function of env: nothing is read from the DataModel, so it is idempotent (the assembler replaces the Blocks container each run).
return function(env)
	local V, CF = env.V, env.CF
	local vcyl = env.vcyl
	local C3 = Color3.fromRGB
	local rad = math.rad
	local UP = V(0, 1, 0)

	local BRICK, COURSE, WHITE = C3(235, 232, 222), C3(220, 216, 203), C3(225, 225, 220)
	local MBRICK, MCONC = Enum.Material.Brick, Enum.Material.Concrete
	local ROW, COURSE_T, COURSE_H, JOINT_S, JOINT_W = 3.6, 0.15, 0.5, 6.0, 0.4
	local FACET = 2.0 -- how far the centre third of the front face is pushed out of the body (the slightly curved face of the drawing)

	------------------------------------------------------------------ 2D polygon helpers (same as site10_wing, for the atrium pentagon PC)
	local function area(P)
		local s = 0
		for i = 1, #P do
			local a, b = P[i], P[i % #P + 1]
			s += a[1] * b[2] - b[1] * a[2]
		end
		return s / 2
	end
	local function unit(a, b)
		local dx, dz = b[1] - a[1], b[2] - a[2]
		local l = math.sqrt(dx * dx + dz * dz)
		return dx / l, dz / l, l
	end
	local function inward(P, i)
		local tx, tz = unit(P[i], P[i % #P + 1])
		local s = area(P) > 0 and 1 or -1
		return -tz * s, tx * s
	end
	local function offsetPoly(P, d)
		local L = {}
		for i = 1, #P do
			local nx, nz = inward(P, i)
			local b = P[i % #P + 1]
			L[i] = { P[i][1] + nx * d[i], P[i][2] + nz * d[i], b[1] - P[i][1], b[2] - P[i][2] }
		end
		local out = {}
		for i = 1, #P do
			local p = L[(i - 2) % #P + 1]
			local q = L[i]
			local den = p[3] * q[4] - p[4] * q[3]
			local u = ((q[1] - p[1]) * q[4] - (q[2] - p[2]) * q[3]) / den
			out[i] = { p[1] + p[3] * u, p[2] + p[4] * u }
		end
		return out
	end

	------------------------------------------------------------------ one brick slab
	-- spec: cx, cz = centre of the BACK face (plan), nx, nz = outward unit vector, W = width, D = depth (back to front), y0, y1,
	--       piles = { {d, u, base y (default 4)}, ... } pilotis positions.
	-- Frame: d runs outward from the back face, u along the width (u axis = outward x up, so for outward +x it is +z).
	local function brickBox(dest, spec)
		env.section("Blocks", function(ctx)
			local nO = V(spec.nx, 0, spec.nz)
			local tU = nO:Cross(UP)
			local C0 = V(spec.cx, 0, spec.cz)
			local W, D, y0, y1 = spec.W, spec.D, spec.y0, spec.y1
			local s = FACET
			local Db = D - s -- the body ends here; the centre facet carries the face out to D
			local third = W / 6
			local function pos(d, u, y) return C0 + nO * d + tU * u + V(0, y or 0, 0) end

			local function slab(name, d0, d1, u0, u1, ya, yb, color)
				return ctx:part(name, V(d1 - d0, yb - ya, u1 - u0),
					CFrame.fromMatrix(pos((d0 + d1) / 2, (u0 + u1) / 2, (ya + yb) / 2), nO, UP, tU), color, MBRICK)
			end
			-- vertical prism over the right triangle R (right angle), Pa, Pz given as (d, u) pairs
			local function tri(name, rd, ru, ad, au, zd, zu)
				local R, Pa, Pz = pos(rd, ru), pos(ad, au), pos(zd, zu)
				local Y = Pa - R
				local yl = Y.Magnitude
				Y = Y / yl
				local Zv = R - Pz
				local zl = Zv.Magnitude
				Zv = Zv / zl
				local X = Y:Cross(Zv)
				local c = R + Y * (yl / 2) - Zv * (zl / 2) + V(0, (y0 + y1) / 2, 0)
				return ctx:wedge(name, V(y1 - y0, yl, zl), CFrame.fromMatrix(c, X, Y, Zv), BRICK, MBRICK)
			end
			-- one brick line along the face segment (d0,u0) -> (d1,u1), centred on height y, proud of the face by COURSE_T.
			-- height h and length cut to cut (default the full segment); a short piece is centred at arc position m along the segment.
			local function strip(d0, u0, d1, u1, out, y, h, m, len)
				local A, B = pos(d0, u0), pos(d1, u1)
				local Zs = B - A
				local L = Zs.Magnitude
				Zs = Zs / L
				if UP:Cross(Zs):Dot(out) < 0 then Zs = -Zs end
				local Xs = UP:Cross(Zs)
				local mid = (A + B) / 2
				if m then mid = A + (B - A) / L * m end
				local c = mid + Xs * (COURSE_T / 2) + V(0, y, 0)
				if spec.skipLine and spec.skipLine(c.X, c.Z, y - (h or COURSE_H) / 2) then return nil end
				return ctx:part("WhiteBrickBoxC", V(COURSE_T, h or COURSE_H, len or L), CFrame.fromMatrix(c, Xs, UP, Zs), COURSE, MBRICK)
			end

			slab("WhiteBrickBox", 0, Db, -W / 2, W / 2, y0, y1, BRICK)
			slab("WhiteBrickBoxF", Db - 0.01, D, -third, third, y0, y1, BRICK)
			tri("WhiteBrickBoxW", Db, -third, Db, -W / 2, D, -third)
			tri("WhiteBrickBoxW", Db, third, Db, W / 2, D, third)

			-- the front is a polyline of 3 facets: P1 -> P2 -> P3 -> P4 (plan, (d, u))
			local P = { { Db, -W / 2 }, { D, -third }, { D, third }, { Db, W / 2 } }
			local segL, total = {}, 0
			for i = 1, 3 do
				local dd, du = P[i + 1][1] - P[i][1], P[i + 1][2] - P[i][2]
				segL[i] = math.sqrt(dd * dd + du * du)
				total += segL[i]
			end
			-- horizontal bed lines on the 3 front facets, at the row edges
			local y = y0 + ROW
			while y < y1 - 0.5 do
				for i = 1, 3 do strip(P[i][1], P[i][2], P[i + 1][1], P[i + 1][2], nO, y) end
				y += ROW
			end
			-- vertical joints, staggered by half a spacing on every other row (running bond)
			local j = 0
			while y0 + ROW * j + ROW * 0.7 <= y1 do
				local yc = y0 + ROW * j + ROW / 2
				local a = 3.0 + ((j % 2 == 1) and JOINT_S / 2 or 0)
				while a < total - 1.5 do
					local acc, k = 0, 1
					while k < 3 and a > acc + segL[k] do
						acc += segL[k]
						k += 1
					end
					strip(P[k][1], P[k][2], P[k + 1][1], P[k + 1][2], nO, yc, ROW - 0.2, a - acc, JOINT_W)
					a += JOINT_S
				end
				j += 1
			end

			for _, p in ipairs(spec.piles or {}) do
				local q = pos(p[1], p[2])
				vcyl(ctx, "Pilotis_" .. spec.label, q.X, q.Z, p[3] or 4, y0, 1.6, WHITE, MCONC)
			end
		end, dest)
	end

	------------------------------------------------------------------ city seal and wordmark on the seal slab WB07 (owner decision 2026-10-28)
	-- Parts and text only. WB07 faces +X; its centre facet front is lx 29.5. Every disc stands on lx 29.36 (a little inside the facet) and comes out to its own
	-- front x, so the stack reads as rings from the east. A Cylinder part has its circular faces on local +/-X: no rotation is needed.
	local LOGO_CY, LOGO_CZ, LOGO_X0 = 38.0, -96.0, 29.36
	local LOGO_WHITE, LOGO_CREAM = C3(250, 248, 240), C3(244, 238, 222)
	local LOGO_GOLD, LOGO_BLUE = C3(212, 170, 60), C3(35, 75, 165)
	local LOGO_RED, LOGO_GREEN = C3(205, 40, 45), C3(45, 150, 70)
	-- name, front x, dy, dz (from the seal centre), diameter, colour
	local LOGO_DISCS = {
		{ "SealRimWhite", 29.74, 0, 0, 7.2, LOGO_WHITE },
		{ "SealRingGold", 29.78, 0, 0, 6.7, LOGO_GOLD },
		{ "SealBandCream", 29.82, 0, 0, 6.3, LOGO_CREAM },
		{ "SealLineGold", 29.86, 0, 0, 5.9, LOGO_GOLD },
		{ "SealFieldBlue", 29.90, 0, 0, 5.5, LOGO_BLUE },
		{ "SealHillGreen", 29.96, -1.0, 0, 3.0, LOGO_GREEN },
		{ "SealShieldRed", 29.96, 1.35, 0, 1.5, LOGO_RED },
		{ "SealStarGoldL", 29.96, 0.2, -1.9, 0.7, LOGO_GOLD },
		{ "SealStarGoldR", 29.96, 0.2, 1.9, 0.7, LOGO_GOLD },
	}
	-- the wordmark plate: x depth, height, width, centre y, front x
	local WM_DEPTH, WM_H, WM_W, WM_CY, WM_PPS = 0.5, 2.0, 11.0, 32.7, 50
	local LOGO_SUPPORTS = {}
	for _, d in ipairs(LOGO_DISCS) do
		table.insert(LOGO_SUPPORTS, { x0 = LOGO_X0, x1 = d[2], cz = LOGO_CZ + d[4], hz = d[5] / 2, top = LOGO_CY + d[3] + d[5] / 2 })
	end
	table.insert(LOGO_SUPPORTS, { x0 = LOGO_X0, x1 = LOGO_X0 + WM_DEPTH, cz = LOGO_CZ, hz = WM_W / 2, top = WM_CY + WM_H / 2 })

	local function buildLogo(wb07)
		local logo = env.newChild(wb07, "SealLogo")
		env.section("Blocks", function(ctx)
			for _, d in ipairs(LOGO_DISCS) do
				local t = d[2] - LOGO_X0
				ctx:cyl(d[1], V(t, d[5], d[5]), CF(LOGO_X0 + t / 2, LOGO_CY + d[3], LOGO_CZ + d[4]), d[6], Enum.Material.SmoothPlastic)
			end
			local plate = ctx:part("LogoText", V(WM_DEPTH, WM_H, WM_W), CF(LOGO_X0 + WM_DEPTH / 2, WM_CY, LOGO_CZ), LOGO_WHITE, Enum.Material.SmoothPlastic)
			local gui = Instance.new("SurfaceGui")
			gui.Name = "LogoGui"
			gui.Face = Enum.NormalId.Right
			gui.Adornee = plate
			gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
			gui.PixelsPerStud = WM_PPS
			gui.LightInfluence = 1
			gui.AlwaysOnTop = false
			gui.Enabled = true
			local function label(name, text, color, xs, xp, align)
				local l = Instance.new("TextLabel")
				l.Name = name
				l.Text = text
				l.TextColor3 = color
				l.Font = Enum.Font.GothamBlack
				l.TextScaled = false
				l.RichText = false
				l.TextSize = 85
				l.BackgroundTransparency = 1
				l.BorderSizePixel = 0
				l.Size = UDim2.new(xs, 0, 1, 0)
				l.Position = UDim2.new(xp, 0, 0, 0)
				l.TextXAlignment = align
				l.TextYAlignment = Enum.TextYAlignment.Center
				l.Parent = gui
			end
			-- canvas 550 x 100 px; GothamBlack 85 is 335 px for BAGONG and 174 px for LIPA, so the pair is centred with a 14 px gap
			label("LogoBagong", "BAGONG", C3(200, 40, 40), 0.636, 0, Enum.TextXAlignment.Right)
			label("LogoLipa", "LIPA", C3(30, 70, 170), 0.34, 0.658, Enum.TextXAlignment.Left)
			gui.Parent = plate
		end, logo)
	end

	------------------------------------------------------------------ long-wing slabs
	-- label, lz a (north) .. b (south), depth D (back to front, centre facet included), y0, y1, flags.
	-- back = the x of the back face: 23.5 (the face of the glass mullions) or 24 (the end of the roof slab) for the slabs at the roof line.
	local WB = {
		{ "WB01", -16.5, -6.5, 5.5, 28.4, 43.8, { a = 24 } },
		{ "WB02", -30, -18, 5.0, 28.4, 43.8, { a = 24 } },
		{ "WB03", -33, -13, 6.5, 14.0, 28.4, { piles = true } },
		{ "WB04", -45.5, -34, 5.5, 17.6, 32.0, {} },
		{ "WB05", -85, -64, 5.0, 29.4, 43.8, { a = 24 } },
		{ "WB06", -83, -72, 6.0, 14.0, 29.4, { piles = true } },
		{ "WB07", -106, -86, 5.5, 28.4, 43.8, { a = 24 } },
		{ "WB08", -110, -86, 6.7, 14.0, 28.4, { piles = true } },
		{ "WB09", -114, -106, 5.0, 29.4, 43.8, { a = 24 } },
	}
	local wingBoxes = env.newFolder("Blocks", "WingBoxes", "Model")
	for _, r in ipairs(WB) do
		local label, a, b, D, y0, y1, f = r[1], r[2], r[3], r[4], r[5], r[6], r[7]
		local back = f.a or 23.5
		local W = b - a
		local s = FACET
		local piles
		if f.piles then
			piles = { { D - s - 1.0, -(W / 2 - 1.6) }, { D - s - 1.0, W / 2 - 1.6 } }
		end
		local m = env.newChild(wingBoxes, label)
		local skipLine
		if label == "WB07" then
			-- bed lines and joints that would sit behind the seal or its wordmark are left out: the logo covers them, and a logo part
			-- standing in the 2 x 2 column under a raised line would count as a support for the 10-stud clearance rule
			skipLine = function(px, pz, loY)
				for _, q in ipairs(LOGO_SUPPORTS) do
					if q.top <= loY + 0.05 and math.abs(pz - q.cz) < q.hz + 1.05 and px - 1 < q.x1 and px + 1 > q.x0 then return true end
				end
				return false
			end
		end
		brickBox(m, {
			label = label, cx = back, cz = (a + b) / 2, nx = 1, nz = 0, W = W, D = D, y0 = y0, y1 = y1, piles = piles, skipLine = skipLine,
		})
		if label == "WB07" then buildLogo(m) end
	end

	-- thin sunshade ledge over the lobby doors (floor 4 level); clear of WB04 (lz -45.5) and of WB05 (lz -64)
	env.section("Blocks", function(ctx)
		env.box(ctx, "Sunshade1", 23, 33, 36.0, 36.8, -62.5, -47.5, WHITE, MCONC)
	end, wingBoxes)

	------------------------------------------------------------------ atrium slabs (SE face = pentagon edge 4, SW face = edge 5 of PC)
	local PD = { { -15.2, 80.0 }, { -15.5, -4.0 }, { 31.0, 10.3 }, { 70.3, 54.4 }, { 16.4, 109.4 } }
	local PC = offsetPoly(PD, { 0, 0, 18.0, 0, 0 })
	local atriumBoxes = env.newFolder("Blocks", "AtriumBoxes", "Model")
	-- label, edge, u0, u1, front w (negative = outside the wall line), y0, y1, pilotis u offsets from the slab centre
	local AB = {
		-- Outer-end proportions of the drawing (owner complaint 2026-10-30): AB1 and AB2 are TALL plates (15 wide, 18 and 22 high, staggered
		-- bottoms), AB3 is the small low plate beside them (it must end before u 44: BalconySW1 reaches under the SE face there), and AB4/AB5 stay the wide bands on the SW face.
		{ "AB1", 4, 20.5, 35.5, -4.6, 24.8, 42.8, nil },
		{ "AB2", 4, 3, 18, -3.8, 20.8, 42.8, nil },
		{ "AB3", 4, 35.5, 43, -5.0, 14.4, 22.4, nil },
		{ "AB4", 5, 2, 27, -4.2, 29.4, 42.8, nil },
		{ "AB5", 5, 12, 40, -5.0, 14.4, 26.4, nil },
		-- the south corner of the atrium (edge 4, u 52..58.97) was bare glass: a narrow upper-tier slab wraps it. It stays away from
		-- RailSW2 (its near end is at u 46) so the 10-stud clearance rule keeps its margin; 0.3 gap to AB1 keeps a glass joint.
		-- No lower-tier twin: the SW wall underside AtriumUnderSW (top y 14.0) passes under the corner, so a slab starting at y 14.4 would
		-- have 0.4 of clearance there; the lower tier of the corner stays dark glass.
		{ "AB6", 4, 52.3, 58.9, -4.6, 29.4, 42.8, nil },
	}
	local BACKW = 1.5 -- back face of an atrium slab, measured inward from the pentagon edge (the glass wall starts there)
	for _, r in ipairs(AB) do
		local label, ei, u0, u1, wf, y0, y1, pu = r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8]
		local A = PC[ei]
		local tx, tz = unit(A, PC[ei % #PC + 1])
		local nx, nz = inward(PC, ei)
		local um = (u0 + u1) / 2
		local D = BACKW - wf
		local piles
		if pu then
			piles = {}
			for _, u in ipairs(pu) do table.insert(piles, { BACKW + 4.6, u, 0 }) end -- w = -4.6: on the ground just outside the plinth edge (w -1.5)
		end
		local m = env.newChild(atriumBoxes, label)
		brickBox(m, {
			label = label, cx = A[1] + tx * um + nx * BACKW, cz = A[2] + tz * um + nz * BACKW, nx = -nx, nz = -nz,
			W = u1 - u0, D = D, y0 = y0, y1 = y1, piles = piles,
		})
	end
end
