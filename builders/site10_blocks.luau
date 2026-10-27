-- site10_blocks: the staggered white-brick boxes and the sunshade ledge of Site 10 (New Lipa City Hall). Studio copy: ServerStorage.Builders.site10_blocks.
-- Owner container: Blocks. Module budget: 500 parts. Check group: shared.site10_only = "blocks" (tests/site10_check.luau).
-- Design: scratch/site10/layout.md ("Blocks") + model.py; the owner's drawing "Lipa City Hall Blueprint.png" is the truth. Loaded by builders/site10.luau.
-- PLAN
--   Blocks.WingBoxes   : Models WB01..WB11 (the long-wing boxes) and Sunshade1 (thin ledge over the lobby doors).
--   Blocks.AtriumBoxes : Models AB1..AB5 (rotated with the atrium: they sit on the SE and SW faces of the pulled-back pentagon PC).
--   One brick box (a Model named by its layout label) is made of
--       WhiteBrickBox  = the main volume (a Part, Brick, cream 235,232,222)
--       WhiteBrickBoxF = the centre third of the curved front face, pushed out (Part)
--       WhiteBrickBoxW = two plan-triangle wedges that join the body to the centre facet, so the front reads as a 3-facet curved face (WedgePart)
--       WhiteBrickBoxC = thin darker cream courses (horizontal bed lines, every 3.6 studs) on the 3 front facets and on the two side faces.
--     Everything in a box is named WhiteBrickBox<letter> on purpose: the clearance check ignores brick boxes that stack on each other, and the
--     courses and wedges are brick too. Pilotis_<label> are slim white columns under the boxes that stand 10 up (WB03, 04, 07, 09, 11).
--   Rules kept: boxes start at lx 23.5 (the face of the glass mullions) so nothing is buried in the glass; the main volume of every box has
--     its centre column clear of glass, spandrels and wall undersides (the raised-box clearance check looks straight down from it); no part
--     is named *Rail*; no Decals, no text, no logo (the drawing's seal box WB08 stays plain brick); nothing near the spawn pad, Guide or panel.
--   Deviations from layout.md (all to satisfy the clearance rule or contact): WB10/WB11 start at lx 21 instead of 8 (the cap no longer buries
--     the glass body end); WB07 top 33 (touches WB05's underside); WB03 ends at lz -15 (touches WB01, no overlap);
--     Sunshade1 spans lz -62.5..-47.5 (clear of WB04 and of WB05's side courses); atrium boxes are slid along the faces and made narrower
--     (AB1 u 28..42, AB2 8..26, AB3 2..20, AB4 17.5..33, AB5 35..43) because the SW and SE balconies of the Wing cross near the south corner
--     C5 (their tops are 7.2 apart, so no box centre column there can have 10 studs clear); AB3 and AB5 (bottom 14.4, 10 over the atrium floor top 4.4) have no pilotis: they hang off the
--     glass wall like the others (every spot near the plinth is blocked for a pilotis, the wedge plates of the plinth have large bounding boxes).
-- Pure function of env: nothing is read from the DataModel, so it is idempotent (the assembler replaces the Blocks container each run).
return function(env)
	local V, CF = env.V, env.CF
	local vcyl = env.vcyl
	local C3 = Color3.fromRGB
	local rad = math.rad
	local UP = V(0, 1, 0)

	local BRICK, COURSE, WHITE = C3(235, 232, 222), C3(220, 216, 203), C3(225, 225, 220)
	local MBRICK, MCONC = Enum.Material.Brick, Enum.Material.Concrete
	local ROW, COURSE_T, COURSE_H = 3.6, 0.12, 0.35

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

	------------------------------------------------------------------ one brick box
	-- spec: cx, cz = centre of the BACK face (plan), nx, nz = outward unit vector, W = width, D = depth (back to front), y0, y1,
	--       noL / noR = no side courses on the u-min / u-max face (those faces touch another box), piles = { {d, u, base y (default 4)}, ... } pilotis positions.
	-- Frame: d runs outward from the back face, u along the width (u axis = outward x up, so for outward +x it is +z).
	local function brickBox(dest, spec)
		env.section("Blocks", function(ctx)
			local nO = V(spec.nx, 0, spec.nz)
			local tU = nO:Cross(UP)
			local C0 = V(spec.cx, 0, spec.cz)
			local W, D, y0, y1 = spec.W, spec.D, spec.y0, spec.y1
			local s = (D >= 6) and 1.8 or 1.2
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
			-- one course line along the face segment (d0,u0) -> (d1,u1), centred on height y, proud of the face by COURSE_T
			local function strip(d0, u0, d1, u1, out, y)
				local A, B = pos(d0, u0), pos(d1, u1)
				local Zs = B - A
				local L = Zs.Magnitude
				Zs = Zs / L
				if UP:Cross(Zs):Dot(out) < 0 then Zs = -Zs end
				local Xs = UP:Cross(Zs)
				local c = (A + B) / 2 + Xs * (COURSE_T / 2) + V(0, y, 0)
				return ctx:part("WhiteBrickBoxC", V(COURSE_T, COURSE_H, L), CFrame.fromMatrix(c, Xs, UP, Zs), COURSE, MBRICK)
			end

			slab("WhiteBrickBox", 0, Db, -W / 2, W / 2, y0, y1, BRICK)
			slab("WhiteBrickBoxF", Db - 0.01, D, -third, third, y0, y1, BRICK)
			tri("WhiteBrickBoxW", Db, -third, Db, -W / 2, D, -third)
			tri("WhiteBrickBoxW", Db, third, Db, W / 2, D, third)

			local y = y0 + 1.8
			while y < y1 - 1.0 do
				strip(Db, -W / 2, D, -third, nO, y)
				strip(D, -third, D, third, nO, y)
				strip(D, third, Db, W / 2, nO, y)
				if not spec.noL then strip(0, -W / 2, Db, -W / 2, -tU, y) end
				if not spec.noR then strip(0, W / 2, Db, W / 2, tU, y) end
				y += ROW
			end

			for _, p in ipairs(spec.piles or {}) do
				local q = pos(p[1], p[2])
				vcyl(ctx, "Pilotis_" .. spec.label, q.X, q.Z, p[3] or 4, y0, 1.6, WHITE, MCONC)
			end
		end, dest)
	end

	------------------------------------------------------------------ long-wing boxes
	local BACK = 23.5 -- the face of the glass mullions
	local wingBoxes = env.newFolder("Blocks", "WingBoxes", "Model")
	-- label, lz a (north) .. b (south), front face lx, y0, y1, flags
	local WB = {
		{ "WB01", -15.0, -6.5, 30, 21.2, 42.8, {} },
		{ "WB02", -31, -18, 33, 25.0, 42.8, {} },
		{ "WB03", -31, -15, 36, 14.0, 25.0, { noR = true, piles = true } },
		{ "WB04", -43, -32, 38, 14.0, 36.5, { piles = true } },
		{ "WB05", -81, -64, 34, 33.0, 42.8, {} },
		{ "WB06", -72, -64, 30, 22.0, 33.0, { noL = true, noR = true } },
		{ "WB07", -81, -72, 41, 14.0, 33.0, { noR = true, piles = true } },
		{ "WB08", -106, -86, 35, 28.4, 42.8, {} },
		{ "WB09", -106, -86, 40, 14.0, 28.4, { piles = true } },
		{ "WB10", -116, -106, 31, 25.0, 42.8, { a = 21 } },
		{ "WB11", -116, -106, 38, 14.0, 25.0, { a = 21, piles = true } },
	}
	for _, r in ipairs(WB) do
		local label, a, b, lf, y0, y1, f = r[1], r[2], r[3], r[4], r[5], r[6], r[7]
		local back = f.a or BACK
		local W, D = b - a, lf - back
		local s = (D >= 6) and 1.8 or 1.2
		local piles
		if f.piles then
			piles = { { D - s - 1.0, -(W / 2 - 1.6) }, { D - s - 1.0, W / 2 - 1.6 } }
		end
		local m = env.newChild(wingBoxes, label)
		brickBox(m, {
			label = label, cx = back, cz = (a + b) / 2, nx = 1, nz = 0, W = W, D = D, y0 = y0, y1 = y1,
			noL = f.noL, noR = f.noR, piles = piles,
		})
	end

	-- thin sunshade ledge over the lobby doors (floor 4 level); clear of WB04 (lz -43) and of WB05's side courses (lz -64)
	env.section("Blocks", function(ctx)
		env.box(ctx, "Sunshade1", 23, 33, 36.0, 36.8, -62.5, -47.5, WHITE, MCONC)
	end, wingBoxes)

	------------------------------------------------------------------ atrium boxes (SE face = pentagon edge 4, SW face = edge 5 of PC)
	local PD = { { -15.2, 80.0 }, { -15.5, -4.0 }, { 31.0, 10.3 }, { 70.3, 54.4 }, { 16.4, 109.4 } }
	local PC = offsetPoly(PD, { 0, 0, 18.0, 0, 0 })
	local atriumBoxes = env.newFolder("Blocks", "AtriumBoxes", "Model")
	-- label, edge, u0, u1, front w (negative = outside the wall line), y0, y1, pilotis u offsets from the box centre
	local AB = {
		{ "AB1", 4, 28, 42, -5, 21.2, 42.8, nil },
		{ "AB2", 4, 8, 26, -3, 22.0, 38.0, nil },
		{ "AB3", 4, 2, 20, -6, 14.4, 22.0, nil },
		{ "AB4", 5, 17.5, 33, -4, 21.2, 42.8, nil },
		{ "AB5", 5, 35, 43, -5.5, 14.4, 28.4, nil },
	}
	local BACKW = 1.5 -- back face of an atrium box, measured inward from the pentagon edge (the glass wall starts there)
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
