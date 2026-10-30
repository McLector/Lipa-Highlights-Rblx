-- site09_taal: Taal Volcano island across the lake, in front of the Tagbakin lake facade (Revision 2, briefs/site09.md).
-- Studio copy: ServerStorage.Builders.site09_taal; called at the end of builders/site09.luau, or alone with
--   require(game.ServerStorage.Builders.site09_taal:Clone())()
-- Reference: "2nd Reference/tagbakin_halang/taal volcano-in-front-of-tagbakin-halang-structure/caption.jpg" (from a boat): a low wide
-- green cone, the crater top with two peaks (the right one higher), a dip between them, a bare brown breach facing the viewer, open
-- water in front. images (2).jpg (aerial) gives the crater lake and the flat coastal skirt; tagaytay-volcano.webp only the colours.
-- WHERE: World.Backdrops.Taal_Volcano, a root BasePart with every other part under it (world_check reads Backdrops' direct children
-- only). Not in the site model: BuildCheck's footprint+10% bounds forbid a far backdrop there. It REPLACES exactly the two old balls
-- Backdrops.Taal_Volcano and Backdrops.Taal_Ridge (made by builders/world.luau, which is never run; rerunning world.luau brings the
-- balls back until this runs again). Nothing else in World is touched. No terrain writes: the lake water already reaches past it.
-- PLACEMENT: on the dock axis (local +Z of the site frame = SW), DIST studs from the dock tip, so the dock leads the eye to it.
-- Every part: anchored, CanCollide/CanQuery/CastShadow false (it must never block the site's sight-line rays or shade the site).
-- IDEMPOTENT; built unparented first, then the old parts are removed and the new ones parented in batches with task.wait().
return function()
	local V = Vector3.new
	local back = workspace:FindFirstChild("World") and workspace.World:FindFirstChild("Backdrops")
	assert(back, "site09_taal: Workspace.World.Backdrops not found")

	local S = math.sqrt(0.5)
	local AXIS = V(-S, 0, S) -- the dock axis (SW), the view direction from the dock end
	local TOWARD = -AXIS -- from the island back toward the viewer (NE)
	local RIGHT = V(-S, 0, -S) -- the viewer's right when looking SW (NW)
	local DOCK_TIP = V(-708.7, 0, 646.7)
	local DIST = 700 -- dock tip to the crater centre; the near shore is DIST - SKIRT_R out (830 first; pulled in to read through the haze)
	local C = DOCK_TIP + AXIS * DIST
	local H = 175 -- summit (the right-hand crater peak)
	local R = 300 -- cone foot
	local SKIRT_R = 380 -- the flat coastal plain's waterline (aerial photo)
	local SKIRT_H = 14 -- height of the plain where the cone starts
	local RIM_F = 0.28 -- crater rim radius as a fraction of R
	local N = 24 -- sectors
	local THICK = 2
	local BATCH = 200

	-- Crater rim height (fraction of H) by angle phi in degrees: 0 = toward the viewer, +90 = the viewer's right.
	-- caption.jpg: left peak ~0.88, the far rim seen as the dip ~0.80 (the photo's ~0.82), the right peak 1.0, the brown breach toward the viewer ~0.5.
	local RIM = {
		{ -180, 0.80 }, { -135, 0.82 }, { -85, 0.88 }, { -45, 0.72 }, { -15, 0.52 }, { 0, 0.48 },
		{ 15, 0.52 }, { 50, 0.82 }, { 100, 1.00 }, { 140, 0.90 }, { 180, 0.80 },
	}
	local function rimAt(phi)
		while phi > 180 do phi -= 360 end
		while phi < -180 do phi += 360 end
		for i = 1, #RIM - 1 do
			local a, b = RIM[i], RIM[i + 1]
			if phi >= a[1] and phi <= b[1] then
				local t = (phi - a[1]) / (b[1] - a[1])
				t = t * t * (3 - 2 * t) -- smooth between the table points
				return a[2] + (b[2] - a[2]) * t
			end
		end
		return RIM[1][2]
	end
	-- Rings as fractions of R; the vertex height at (ring f, angle phi).
	local RINGS = { 0.16, RIM_F, 0.45, 0.66, 1.0, SKIRT_R / R }
	local function heightAt(f, phi)
		local rim = rimAt(phi) * H
		if f <= 0.16 + 1e-6 then
			return 0.44 * H + 0.3 * (rim - 0.44 * H) -- the crater's inner wall
		elseif f <= RIM_F + 1e-6 then
			return rim
		elseif f < 1.0 - 1e-6 then
			local t = (1 - f) / (1 - RIM_F)
			local r = math.rad(phi)
			local gully = 1 + 0.05 * math.sin(7 * r + 0.6) + 0.03 * math.sin(13 * r + 1.9) -- ribs and gullies on the flanks
			return SKIRT_H + (rim - SKIRT_H) * (t ^ 1.15) * gully
		elseif f <= 1.0 + 1e-6 then
			return SKIRT_H + 3 * math.sin(math.rad(phi) * 3 + 0.4)
		end
		return -4 -- the skirt dips under the lake surface, so the shoreline is where it meets the water
	end
	local function vertex(f, phi)
		local r = math.rad(phi)
		local d = TOWARD * math.cos(r) + RIGHT * math.sin(r)
		local p = C + d * (f * R)
		return V(p.X, heightAt(f, phi), p.Z)
	end

	-- Colours by eye from caption.jpg (olive forest flanks, a bare brown breach and crater) and the aerial (lighter coastal plain).
	local FLANK_LO = Color3.fromRGB(70, 94, 56)
	local FLANK_MID = Color3.fromRGB(76, 98, 58)
	local FLANK_HI = Color3.fromRGB(92, 100, 62)
	local PLAIN = Color3.fromRGB(108, 124, 72)
	local SCAR = Color3.fromRGB(152, 114, 82)
	local CRATER = Color3.fromRGB(140, 108, 78)
	local LAKE = Color3.fromRGB(52, 96, 104)
	local FAR = Color3.fromRGB(96, 118, 110)
	local GRASS, GROUND, SMOOTH = Enum.Material.Grass, Enum.Material.Ground, Enum.Material.SmoothPlastic

	local made = {} -- { inst, dest }
	local function backdropPart(class, name, color, material)
		local p = Instance.new(class)
		p.Name = name
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.Color = color
		p.Material = material
		return p
	end
	-- A triangle a, b, c from two wedges (the usual right-triangle split along the longest edge).
	local function tri(dest, name, a, b, c, color, material)
		local ab, ac, bc = b - a, c - a, c - b
		local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)
		if abd > acd and abd > bcd then
			c, a = a, c
		elseif acd > bcd and acd > abd then
			a, b = b, a
		end
		ab, ac, bc = b - a, c - a, c - b
		local right = ac:Cross(ab).Unit
		local up = bc:Cross(right).Unit
		local backv = bc.Unit
		local height = math.abs(ab:Dot(up))
		local w1 = backdropPart("WedgePart", name, color, material)
		w1.Size = V(THICK, height, math.abs(ab:Dot(backv)))
		w1.CFrame = CFrame.fromMatrix((a + b) / 2, right, up, backv)
		local w2 = backdropPart("WedgePart", name, color, material)
		w2.Size = V(THICK, height, math.abs(ac:Dot(backv)))
		w2.CFrame = CFrame.fromMatrix((a + c) / 2, -right, up, -backv)
		table.insert(made, { w1, dest })
		table.insert(made, { w2, dest })
	end

	-- Containers (parented after the swap, before their parts).
	local root = backdropPart("Part", "Taal_Volcano", LAKE, SMOOTH)
	root.Size = V(4, 4, 4)
	root.Transparency = 1
	root.CFrame = CFrame.new(C.X, 2, C.Z)
	local island = Instance.new("Folder")
	island.Name = "Island"
	local cone = Instance.new("Folder")
	cone.Name = "Cone"
	local far = Instance.new("Folder")
	far.Name = "FarShore"

	local function colourFor(fAvg, phiMid, hAvg)
		if fAvg < RIM_F - 0.02 then return CRATER, GROUND end
		if fAvg < 0.5 and math.abs(phiMid) < 32 then return SCAR, GROUND end -- the bare breach toward the viewer
		if fAvg > 1.0 then return PLAIN, GRASS end
		local hf = hAvg / H
		if hf > 0.66 then return FLANK_HI, GRASS end
		if hf > 0.36 then return FLANK_MID, GRASS end
		return FLANK_LO, GRASS
	end
	local step = 360 / N
	local function phiOf(j) return -180 + (j - 0.5) * step end -- sector edges sit off the axis so a vertex is never exactly at 0
	-- Crater floor: a fan from the centre to the first ring.
	local centre = V(C.X, 0.40 * H, C.Z)
	for j = 1, N do
		local p1, p2 = vertex(RINGS[1], phiOf(j)), vertex(RINGS[1], phiOf(j + 1))
		tri(cone, "TaalCrater", centre, p1, p2, CRATER, GROUND)
	end
	-- Ring bands: two triangles per sector.
	for k = 1, #RINGS - 1 do
		local f0, f1 = RINGS[k], RINGS[k + 1]
		for j = 1, N do
			local a0, a1 = phiOf(j), phiOf(j + 1)
			local p00, p01 = vertex(f0, a0), vertex(f0, a1)
			local p10, p11 = vertex(f1, a0), vertex(f1, a1)
			local mid = (a0 + a1) / 2
			local col, mat = colourFor((f0 + f1) / 2, mid, (p00.Y + p01.Y + p10.Y + p11.Y) / 4)
			local name = (f1 > 1.0 + 1e-6) and "TaalPlain" or "TaalFlank"
			tri(cone, name, p00, p10, p11, col, mat)
			tri(cone, name, p00, p11, p01, col, mat)
		end
	end
	-- Crater lake hint (aerial photo): a flat disc in the crater floor, its rim inside the inner wall.
	local lake = backdropPart("Part", "TaalCraterLake", LAKE, SMOOTH)
	lake.Shape = Enum.PartType.Cylinder
	lake.Size = V(1, 0.26 * R, 0.26 * R)
	lake.CFrame = CFrame.new(C.X, 0.40 * H + 2.5, C.Z) * CFrame.Angles(0, 0, math.pi / 2)
	table.insert(made, { lake, island })

	-- The far western shore: a low skyline on an arc behind the island (it also hides the end of the water at the map's edge).
	local FAR_D = 1500
	local FAR_H = { 46, 60, 54, 72, 90, 84, 70, 62, 76, 58, 44 }
	local function farPoint(i, y)
		local a = math.rad(-50 + (i - 1) * 10)
		local p = DOCK_TIP + (AXIS * math.cos(a) + RIGHT * math.sin(a)) * FAR_D
		return V(p.X, y, p.Z)
	end
	for i = 1, #FAR_H - 1 do
		local b0, b1 = farPoint(i, -40), farPoint(i + 1, -40)
		local t0, t1 = farPoint(i, FAR_H[i]), farPoint(i + 1, FAR_H[i + 1])
		tri(far, "TaalFarShore", b0, t0, t1, FAR, GRASS)
		tri(far, "TaalFarShore", b0, t1, b1, FAR, GRASS)
	end

	-- Swap: remove exactly the two old balls (and any earlier island), then parent in batches.
	for _, c in ipairs(back:GetChildren()) do
		if c.Name == "Taal_Volcano" or c.Name == "Taal_Ridge" then c:Destroy() end
	end
	root.Parent = back
	island.Parent = root
	cone.Parent = island
	far.Parent = root
	for i, e in ipairs(made) do
		e[1].Parent = e[2]
		if i % BATCH == 0 then task.wait() end
	end
	local n = 1
	for _, d in ipairs(root:GetDescendants()) do
		if d:IsA("BasePart") then n += 1 end
	end
	return { parts = n, centre = C, summit = H }
end
