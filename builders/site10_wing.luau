-- site10_wing: the office wing, atrium and faceted canopy of Site 10 (New Lipa City Hall). Studio copy: ServerStorage.Builders.site10_wing.
-- Owner container: Wing = Models LongWing, Pilotis, Atrium, Canopy. Module budget: 900 parts. Check group: shared.site10_only = "wing".
-- Design: scratch/site10/layout.md + model.py (mass tables), with the owner decisions of job 3b applied on top:
--   (1) SPAWN CLASH option (b): the Canopy (facets, soffit, fascia) is built AS DRAWN (pentagon PD, V3/V4 pushed out over the spawn pad),
--       while everything that stands on the ground (plinth, floor, walls, balconies, atrium pilotis, columns) uses the pulled-back pentagon PC.
--       The canopy is >= 45 up, so it may overhang the pad; no solid below y 30 comes within 2 studs of the pad, Guide or InfoPanel.
--   (2) PilotiA at lz -46, -55, -64 are dropped (they would stand inside CoreLobby).
--   (3) Heights are not scaled with the plan: floors 14, 21.2, 28.4, 35.6, roof 42.8..43.8, parapet 45.2, canopy soffit 45; doors 9, rails 3.
-- PLAN
--   LongWing : podium, 2 glass bodies (4 dark GlassBand each) with mullions, white spandrel FloorBand1..3, recessed core (CoreBack,
--              CoreLobby with Door1..3, CoreBalcony1..3 + rails), RoofSlab, Parapet*, RoofBox1..3.
--   Pilotis  : PilotiA (front row, on the podium) and PilotiB (rear row, from the ground).
--   Atrium   : plinth + floor (triangle prisms), three glass walls (SE, SW, Back) with mullions, four terraced balcony levels with rails,
--              atrium pilotis, under-slabs.
--   Canopy   : 11 hipped facets. Each facet = a thin plate through its 3 corners (2 right-triangle wedges, CanopyPlate<n>) plus a raised
--              ramp panel CanopyFacet<n> whose slope face lies in the facet plane (a wedge cannot be a triangle in plan), soffit, 5 fascia
--              edges, 8 round Columns, 3 CanopyRoofBox.
-- Pure function of env: nothing is read from the DataModel, so it is idempotent (the assembler replaces the Wing container each run).
return function(env)
	local V, CF, ANG, PI = env.V, env.CF, env.ANG, env.PI
	local ORIGIN = env.ORIGIN
	local box, vcyl = env.box, env.vcyl
	local C3 = Color3.fromRGB
	local rad = math.rad

	local GLASS, GLASSM = C3(40, 50, 60), Enum.Material.Glass
	local CONC, ROOFC, WHITE, SLATE = C3(190, 192, 190), C3(120, 126, 132), C3(225, 225, 220), C3(178, 180, 178)
	local CREAM, DOORC, METAL = C3(235, 232, 222), C3(30, 40, 48), C3(70, 78, 88)
	local MCONC, MSLATE, MMETAL = Enum.Material.Concrete, Enum.Material.Slate, Enum.Material.Metal
	local FL = { 14, 21.2, 28.4, 35.6, 42.8 }
	local ROOF1, PARAPET = 43.8, 45.2

	------------------------------------------------------------------ 2D polygon helpers (ported from scratch/site10/model.py)
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
	-- inward normal of edge i (P[i] -> P[i+1]), 1-based
	local function inward(P, i)
		local tx, tz = unit(P[i], P[i % #P + 1])
		local s = area(P) > 0 and 1 or -1
		return -tz * s, tx * s
	end
	-- d[i] = inward offset of edge i; negative = outward
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
	-- box along edge i between along-edge u0..u1 and inward offset w0..w1 (w > 0 inward): centre, size, yaw in degrees
	local function eb(P, i, u0, u1, w0, w1)
		local A = P[i]
		local tx, tz = unit(A, P[i % #P + 1])
		local nx, nz = inward(P, i)
		local um, wm = (u0 + u1) / 2, (w0 + w1) / 2
		return {
			cx = A[1] + tx * um + nx * wm, cz = A[2] + tz * um + nz * wm,
			sx = u1 - u0, sz = w1 - w0, rot = math.deg(math.atan2(-tz, tx)),
		}
	end
	local function edgeLen(P, i)
		local _, _, l = unit(P[i], P[i % #P + 1])
		return l
	end
	local function ptOnEdge(P, i, u, w)
		local A = P[i]
		local tx, tz = unit(A, P[i % #P + 1])
		local nx, nz = inward(P, i)
		return A[1] + tx * u + nx * w, A[2] + tz * u + nz * w
	end

	-- yaw box from an eb() result
	local function ybox(ctx, name, g, y0, y1, color, material)
		return ctx:part(name, V(g.sx, y1 - y0, g.sz), CF(g.cx, (y0 + y1) / 2, g.cz) * ANG(0, rad(g.rot), 0), color, material)
	end

	------------------------------------------------------------------ plate geometry: a triangle in 3D as two right-triangle wedges
	-- A wedge's profile (local Y,Z) is a right triangle: right angle at (y -h/2, z +d/2), legs along -Z and +Y. Local X is the plate thickness.
	-- plateSpecs returns {size, cf} for a plate whose TOP face lies in the plane of A, B, C and which is t thick below it.
	local function plateSpecs(A, B, C, t)
		local pts = { A, B, C }
		local best, bi = -1, 1
		for i = 1, 3 do
			local d = (pts[i % 3 + 1] - pts[i]).Magnitude
			if d > best then best, bi = d, i end
		end
		local P1, P2, P3 = pts[bi], pts[bi % 3 + 1], pts[(bi + 1) % 3 + 1] -- P1P2 is the longest edge, P3 the apex
		local eu = (P2 - P1).Unit
		local D = P1 + eu * (P3 - P1):Dot(eu)
		local nrm = eu:Cross(P3 - P1)
		if nrm.Magnitude < 1e-4 then return {} end
		nrm = nrm.Unit
		if nrm.Y < 0 then nrm = -nrm end
		local out = {}
		local function right(R, Pa, Pz)
			local ya, za = Pa - R, R - Pz
			local yl, zl = ya.Magnitude, za.Magnitude
			if yl < 0.05 or zl < 0.05 then return end
			local Y, Z = ya / yl, za / zl
			local X = Y:Cross(Z).Unit
			local centre = R + Y * (yl / 2) - Z * (zl / 2) - nrm * (t / 2)
			table.insert(out, { size = V(t, yl, zl), cf = CFrame.fromMatrix(centre, X, Y, Z) })
		end
		right(D, P3, P1)
		right(D, P3, P2)
		return out
	end

	-- pins (local): nothing solid below y 30 may come within 2 studs (2D) of these; plates are tested by their bounding box, so they are
	-- split until the boxes clear the pins by 2.6.
	local PAD = { 56, 68, 39, 51 }
	local PINPTS = { { 47, 45 }, { 53, 23 } } -- Guide, InfoPanel
	local function nearPin(spec)
		local lo, hi = { math.huge, math.huge }, { -math.huge, -math.huge }
		for _, sx in ipairs({ -1, 1 }) do
			for _, sy in ipairs({ -1, 1 }) do
				for _, sz in ipairs({ -1, 1 }) do
					local w = spec.cf * V(sx * spec.size.X / 2, sy * spec.size.Y / 2, sz * spec.size.Z / 2)
					lo = { math.min(lo[1], w.X), math.min(lo[2], w.Z) }
					hi = { math.max(hi[1], w.X), math.max(hi[2], w.Z) }
				end
			end
		end
		local dx = math.max(PAD[1] - hi[1], lo[1] - PAD[2], 0)
		local dz = math.max(PAD[3] - hi[2], lo[2] - PAD[4], 0)
		if math.sqrt(dx * dx + dz * dz) < 2.6 then return true end
		for _, p in ipairs(PINPTS) do
			local ex = math.max(lo[1] - p[1], p[1] - hi[1], 0)
			local ez = math.max(lo[2] - p[2], p[2] - hi[2], 0)
			if math.sqrt(ex * ex + ez * ez) < 2.6 then return true end
		end
		return false
	end

	-- A convex plan polygon as a prism: fan of triangles, top at y1, t thick. Splits plates whose boxes come near a pin.
	local function prism(ctx, name, P, y1, t, color, material, avoidPins)
		local function emit(A, B, C, depth)
			local specs = plateSpecs(A, B, C, t)
			if avoidPins and depth < 5 then
				for _, s in ipairs(specs) do
					if nearPin(s) then
						-- split the longest edge at its middle
						local pts = { A, B, C }
						local bi, best = 1, -1
						for i = 1, 3 do
							local d = (pts[i % 3 + 1] - pts[i]).Magnitude
							if d > best then best, bi = d, i end
						end
						local P1, P2, P3 = pts[bi], pts[bi % 3 + 1], pts[(bi + 1) % 3 + 1]
						local M = (P1 + P2) / 2
						emit(P1, M, P3, depth + 1)
						emit(M, P2, P3, depth + 1)
						return
					end
				end
			end
			for _, s in ipairs(specs) do ctx:wedge(name, s.size, s.cf, color, material) end
		end
		for i = 2, #P - 1 do
			emit(V(P[1][1], y1, P[1][2]), V(P[i][1], y1, P[i][2]), V(P[i + 1][1], y1, P[i + 1][2]), 0)
		end
	end

	-- The largest ramp wedge (rectangular sloped face) that fits inside triangle A, B, C and lies in its plane, lifted 0.12 above it.
	local function ramp(ctx, name, A, B, C, color, material)
		local n = (B - A):Cross(C - A)
		if n.Y < 0 then n = -n end
		n = n.Unit
		if n.Y < 1e-3 then return nil end
		local gx, gz = -n.X / n.Y, -n.Z / n.Y
		local s = math.sqrt(gx * gx + gz * gz)
		if s < 0.03 then return nil end
		local Zd = V(gx / s, 0, gz / s) -- horizontal, uphill
		local Xd = V(0, 1, 0):Cross(Zd)
		local pts = { A, B, C }
		local U, W = {}, {}
		for i = 1, 3 do
			local d = pts[i] - A
			U[i], W[i] = d:Dot(Xd), d:Dot(Zd)
		end
		local function span(v)
			local lo, hi = math.huge, -math.huge
			for i = 1, 3 do
				local j = i % 3 + 1
				local vi, vj = W[i], W[j]
				if vi ~= vj and (vi - v) * (vj - v) <= 0 then
					local u = U[i] + (U[j] - U[i]) * (v - vi) / (vj - vi)
					lo, hi = math.min(lo, u), math.max(hi, u)
				end
			end
			return lo, hi
		end
		local vmin, vmax = math.min(W[1], W[2], W[3]), math.max(W[1], W[2], W[3])
		local N, MARGIN = 18, 0.6
		local bestA, b0, b1, bu0, bu1 = 0, 0, 0, 0, 0
		for a = 0, N - 1 do
			for b = a + 1, N do
				local va, vb = vmin + (vmax - vmin) * a / N, vmin + (vmax - vmin) * b / N
				local lv = { va, vb }
				for i = 1, 3 do
					if W[i] > va and W[i] < vb then table.insert(lv, W[i]) end
				end
				local L, R = -math.huge, math.huge
				for _, v in ipairs(lv) do
					local l, r = span(v)
					L, R = math.max(L, l), math.min(R, r)
				end
				local ar = (R - L - 2 * MARGIN) * (vb - va - 2 * MARGIN)
				if R - L > 2 * MARGIN + 1.5 and vb - va > 2 * MARGIN + 1.5 and ar > bestA then
					bestA, b0, b1, bu0, bu1 = ar, va + MARGIN, vb - MARGIN, L + MARGIN, R - MARGIN
				end
			end
		end
		if bestA <= 0 then return nil end
		local du, dv = bu1 - bu0, b1 - b0
		local cu, cv = (bu0 + bu1) / 2, (b0 + b1) / 2
		local c = A + Xd * cu + Zd * cv
		local low = c - Zd * (dv / 2)
		local yLow = A.Y + gx * (low.X - A.X) + gz * (low.Z - A.Z)
		local rise = s * dv
		return ctx:wedge(name, V(du, rise, dv), CFrame.fromMatrix(V(c.X, yLow + 0.12 + rise / 2, c.Z), Xd, V(0, 1, 0), Zd), color, material)
	end

	------------------------------------------------------------------ plan data
	-- AS DRAWN canopy pentagon (lx, lz): edge 1 back, 2 wing side, 3 front (V3-V4), 4 south-east, 5 south-west.
	local PD = { { -15.2, 80.0 }, { -15.5, -4.0 }, { 31.0, 10.3 }, { 70.3, 54.4 }, { 16.4, 109.4 } }
	-- Pulled-back pentagon for everything on the ground: the front face moved 18.0 toward the atrium (model.py FRONT_SHIFT).
	local PC = offsetPoly(PD, { 0, 0, 18.0, 0, 0 })

	local lw = env.newFolder("Wing", "LongWing", "Model")
	local pil = env.newFolder("Wing", "Pilotis", "Model")
	local atr = env.newFolder("Wing", "Atrium", "Model")
	local can = env.newFolder("Wing", "Canopy", "Model")

	------------------------------------------------------------------ LongWing
	env.section("Wing", function(ctx)
		-- podium under the front half of the wing (top y 4 = stair top)
		box(ctx, "WingPodium", 6, 47, 0, 4, -117, -60, CONC, MCONC)
		box(ctx, "WingPodium", 6, 47, 0, 4, -60, -4, CONC, MCONC)
		-- the two glass bodies: 4 dark GlassBand each, between the white spandrels
		local bands = {
			{ FL[1], FL[2] - 0.5 }, { FL[2] + 0.5, FL[3] - 0.5 }, { FL[3] + 0.5, FL[4] - 0.5 }, { FL[4] + 0.5, FL[5] },
		}
		for _, z in ipairs({ { -113, -64 }, { -46, -6 } }) do
			for _, b in ipairs(bands) do
				box(ctx, "GlassBand", -13, 23, b[1], b[2], z[1], z[2], GLASS, GLASSM)
			end
			-- slim mullions every 6 studs, front and back faces
			local zz = z[1] + 3
			while zz < z[2] - 1 do
				box(ctx, "Mullion", 23, 23.5, FL[1], FL[5], zz - 0.25, zz + 0.25, METAL, MMETAL)
				box(ctx, "Mullion", -13.5, -13, FL[1], FL[5], zz - 0.25, zz + 0.25, METAL, MMETAL)
				zz += 6
			end
		end
		-- underside of the raised wing
		box(ctx, "WingUnderside", -13, 23, 13.4, 14, -113, -6, CONC, MCONC)
		-- recessed core: glass back wall (floors 1-4), open in front of floors 2-4
		box(ctx, "CoreBack", -13, 12, FL[1], FL[5], -64, -46, GLASS, GLASSM)
		for k = 1, 3 do
			box(ctx, "CoreBackBand" .. k, -13, 12.2, FL[k + 1] - 0.5, FL[k + 1] + 0.5, -64, -46, WHITE, MCONC)
		end
		-- glazed entrance lobby on the podium (y 4 .. 21.2), front glass at lx 24
		box(ctx, "CoreLobbyFront", 23.6, 24, 13, FL[2], -64, -46, GLASS, GLASSM).Transparency = 0.15
		box(ctx, "CoreLobbyFrontLow", 23.6, 23.9, 4, 13, -64, -46, GLASS, GLASSM).Transparency = 0.35
		box(ctx, "CoreLobbySideN", 12, 24, 4, FL[2], -64, -63.6, GLASS, GLASSM).Transparency = 0.2
		box(ctx, "CoreLobbySideS", 12, 24, 4, FL[2], -46.4, -46, GLASS, GLASSM).Transparency = 0.2
		for k, z in ipairs({ -63.6, -58, -52, -46.4 }) do
			box(ctx, "CoreLobbyPost" .. k, 23.5, 24.5, 4, 13, z - 0.4, z + 0.4, WHITE, MCONC)
		end
		box(ctx, "CoreLobbyPortico", 22, 25, 20.4, FL[2], -64.5, -45.5, CREAM, MCONC)
		box(ctx, "DoorLintel", 23.8, 25, 13, 14, -64, -46, WHITE, MCONC)
		for k, z in ipairs({ -49, -55, -61 }) do
			box(ctx, "Door" .. k, 23.9, 24.5, 4, 13, z - 2.5, z + 2.5, DOORC, GLASSM)
		end
		-- balconies in the core recess (slab at y 21.2, 28.4, 35.6) with 3-high glass rails on the front and both sides
		for k = 1, 3 do
			local y = FL[k + 1]
			box(ctx, "CoreBalcony" .. k, 12, 22, y - 0.8, y, -64, -46, CREAM, MCONC)
			local rails = {
				{ "CoreRailF", 21.75, 22, -64, -46 }, { "CoreRailN", 12, 22, -64, -63.75 }, { "CoreRailS", 12, 22, -46.25, -46 },
			}
			for _, r in ipairs(rails) do
				local p = box(ctx, r[1] .. k, r[2], r[3], y, y + 3, r[4], r[5], C3(200, 215, 225), GLASSM)
				p.Transparency = 0.5
			end
		end
		-- slim white spandrels at the floor lines, cut where the core recess is
		for k = 1, 3 do
			local y = FL[k + 1]
			box(ctx, "FloorBand" .. k, -13.4, 23.4, y - 0.5, y + 0.5, -113.4, -64, WHITE, MCONC)
			box(ctx, "FloorBand" .. k, -13.4, 23.4, y - 0.5, y + 0.5, -46, -5.6, WHITE, MCONC)
			box(ctx, "FloorBand" .. k, -13.4, 12, y - 0.5, y + 0.5, -64, -46, WHITE, MCONC)
		end
		-- roof, parapet, roof boxes
		box(ctx, "RoofSlab", -14, 24, FL[5], ROOF1, -114, -60, ROOFC, MCONC)
		box(ctx, "RoofSlab", -14, 24, FL[5], ROOF1, -60, -5, ROOFC, MCONC)
		box(ctx, "ParapetBack", -14, -13, ROOF1, PARAPET, -114, -5, WHITE, MCONC)
		box(ctx, "ParapetFront", 23, 24, ROOF1, PARAPET, -114, -5, WHITE, MCONC)
		box(ctx, "ParapetNorth", -14, 24, ROOF1, PARAPET, -114, -113, WHITE, MCONC)
		box(ctx, "ParapetSouth", -14, 24, ROOF1, PARAPET, -6, -5, WHITE, MCONC)
		local rbs = { { -11, -5, -24.5, -13.5 }, { -9, -3, -92.5, -83.5 }, { -8, 0, -113, -99 } }
		for k, r in ipairs(rbs) do
			box(ctx, "RoofBox" .. k, r[1], r[2], ROOF1, 48.6, r[3], r[4], WHITE, MCONC)
			box(ctx, "RoofBoxCap" .. k, r[1] - 0.3, r[2] + 0.3, 48.6, 49, r[3] - 0.3, r[4] + 0.3, ROOFC, MCONC)
			box(ctx, "RoofBoxBand" .. k, r[2], r[2] + 0.1, 45.4, 47.2, r[3] + 1, r[4] - 1, GLASS, GLASSM)
		end
	end, lw)

	------------------------------------------------------------------ Pilotis (PilotiA front row on the podium, PilotiB rear row from the ground)
	env.section("Wing", function(ctx)
		local DROPPED = { [5] = true, [6] = true, [7] = true } -- lz -46, -55, -64: inside CoreLobby
		for k = 1, 12 do
			local z = -10 - 9 * (k - 1)
			if not DROPPED[k] then vcyl(ctx, "PilotiA" .. k, 21, z, 4, FL[1], 1.8, WHITE, MCONC) end
			vcyl(ctx, "PilotiB" .. k, -10, z, 0, FL[1], 1.8, WHITE, MCONC)
		end
	end, pil)

	------------------------------------------------------------------ Atrium (pulled-back pentagon PC)
	env.section("Wing", function(ctx)
		prism(ctx, "AtriumPlinth", offsetPoly(PC, { -0.5, 0.5, 4.0, -1.5, -1.5 }), 4.0, 4.0, WHITE, MCONC, true)
		prism(ctx, "AtriumFloor", offsetPoly(PC, { 2, 2, 5.5, 2.5, 2.5 }), 4.4, 0.4, SLATE, MSLATE, true)
		local walls = { { 4, "SE" }, { 5, "SW" }, { 1, "Back" } }
		for _, w in ipairs(walls) do
			local ei, nm = w[1], w[2]
			local L = edgeLen(PC, ei)
			ybox(ctx, "AtriumWall" .. nm, eb(PC, ei, 0, L, 1.5, 7.0), FL[1], FL[5], GLASS, GLASSM)
			ybox(ctx, "AtriumUnder" .. nm, eb(PC, ei, 0, L, 1.5, 7.0), 13.4, FL[1], CONC, MCONC)
			-- mullions on the inner (court) face, every 6 studs
			local u = 3
			local mk = 1
			while u < L - 1 do
				ybox(ctx, "AtriumMullion" .. nm .. mk, eb(PC, ei, u - 0.25, u + 0.25, 7.0, 7.5), FL[1], FL[5], METAL, MMETAL)
				u += 6
				mk += 1
			end
			-- terraced balconies (lower floors project more), 3-high glass rail on the free edge
			for lvl, dep in ipairs({ 8.0, 6.0, 4.5, 3.0 }) do
				local y = FL[lvl]
				ybox(ctx, "Balcony" .. nm .. lvl, eb(PC, ei, 0, L, 7.0, 7.0 + dep), y - 0.8, y, CREAM, MCONC)
				local r = ybox(ctx, "Rail" .. nm .. lvl, eb(PC, ei, 0, L, 7.0 + dep - 0.2, 7.0 + dep), y, y + 3, C3(200, 215, 225), GLASSM)
				r.Transparency = 0.5
			end
			-- pilotis under the wall
			local np = math.floor(L / 9)
			for k = 1, np do
				local x, z = ptOnEdge(PC, ei, 4.5 + 9 * (k - 1), ei == 1 and 3.0 or 3.5)
				vcyl(ctx, "PilotiAtr" .. nm .. k, x, z, 4.4, FL[1], 1.8, WHITE, MCONC)
			end
		end
	end, atr)

	------------------------------------------------------------------ Canopy (as drawn: pentagon PD)
	env.section("Wing", function(ctx)
		-- the 8 round columns, 2 studs inside the (pulled-back) front edge of the plinth line
		local COLS = {
			{ 2.3, 8.1 }, { 8.3, 14.9 }, { 14.3, 21.6 }, { 20.2, 28.3 }, { 26.2, 35.0 }, { 32.2, 41.7 }, { 38.2, 48.5 }, { 44.2, 55.2 },
		}
		for k, c in ipairs(COLS) do
			vcyl(ctx, "Column" .. k, c[1], c[2], 4.4, 46, 2.4, WHITE, MCONC)
			vcyl(ctx, "ColumnCap" .. k, c[1], c[2], 44.4, 46, 3.4, CONC, MCONC)
		end
		-- soffit under all facets: y 45 .. 46
		prism(ctx, "CanopySoffit", PD, 46.0, 1.0, WHITE, MCONC, false)
		-- fascia: thin white overhang edge 2.6 tall, centred on each edge of PD
		for i = 1, 5 do
			local L = edgeLen(PD, i)
			ybox(ctx, "CanopyFascia" .. i, eb(PD, i, -0.6, L + 0.6, -0.6, 0.6), 45, 47.6, WHITE, MCONC)
		end
		-- 11 hipped facets (option b coordinates, layout.md section d)
		local F = {
			{ { -15.2, 80.0, 47.2 }, { -15.3, 42.3, 47.2 }, { 27.6, 69.4, 50.5 } },
			{ { -15.3, 42.3, 47.2 }, { 21.0, 49.3, 52.0 }, { 27.6, 69.4, 50.5 } },
			{ { -15.3, 42.3, 47.2 }, { -15.4, 29.0, 47.2 }, { 13.8, 30.7, 53.0 } },
			{ { -15.3, 42.3, 47.2 }, { 13.8, 30.7, 53.0 }, { 21.0, 49.3, 52.0 } },
			{ { -15.4, 29.0, 47.2 }, { -15.5, -4.0, 47.2 }, { 13.8, 30.7, 53.0 } },
			{ { -15.5, -4.0, 47.2 }, { 31.0, 10.3, 47.2 }, { 13.8, 30.7, 53.0 } },
			{ { 31.0, 10.3, 47.2 }, { 21.0, 49.3, 52.0 }, { 13.8, 30.7, 53.0 } },
			{ { 31.0, 10.3, 47.2 }, { 70.3, 54.4, 47.2 }, { 21.0, 49.3, 52.0 } },
			{ { 70.3, 54.4, 47.2 }, { 27.6, 69.4, 50.5 }, { 21.0, 49.3, 52.0 } },
			{ { 70.3, 54.4, 47.2 }, { 16.4, 109.4, 47.2 }, { 27.6, 69.4, 50.5 } },
			{ { 16.4, 109.4, 47.2 }, { -15.2, 80.0, 47.2 }, { 27.6, 69.4, 50.5 } },
		}
		for k, f in ipairs(F) do
			local A, B, C = V(f[1][1], f[1][3], f[1][2]), V(f[2][1], f[2][3], f[2][2]), V(f[3][1], f[3][3], f[3][2])
			for _, s in ipairs(plateSpecs(A, B, C, 1.2)) do
				ctx:wedge("CanopyPlate" .. k, s.size, s.cf, ROOFC, MCONC)
			end
			ramp(ctx, "CanopyFacet" .. k, A, B, C, ROOFC, MCONC)
		end
		-- three small boxes on the back edge, sitting on the facets
		for k, z in ipairs({ 66, 40, 14 }) do
			box(ctx, "CanopyRoofBox" .. k, -13, -7, 47.2, 50.2, z - 4.5, z + 4.5, WHITE, MCONC)
			box(ctx, "CanopyRoofBoxCap" .. k, -13.3, -6.7, 50.2, 50.7, z - 4.8, z + 4.8, ROOFC, MCONC)
			box(ctx, "CanopyRoofBoxBand" .. k, -7, -6.9, 48.4, 49.6, z - 3.5, z + 3.5, GLASS, GLASSM)
		end
	end, can)
end
