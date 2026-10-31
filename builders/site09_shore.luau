-- site09_shore: sandy beaches on the Tagbakin lakeshore (Revision 3, session 061; Revision 4, session 062).
-- Owner, session 061: "make the off shores like sand some parts"; session 062: the six patches barely show from the dock, make
-- them bigger so a sandy shore reads from the Guide / dock view. Photo basis (no Tagbakin board draws the beach):
-- Tagbakin_Shoreline_Building_From_Lake.jpg and _Oblique.jpg show open sand on the building's SE side and an earthy strip on the NW.
-- Studio copy: ServerStorage.Builders.site09_shore; site09 calls it after the swap. Run alone with
--   require(game.ServerStorage.Builders.site09_shore:Clone())()      -- returns { columns = repainted 4-stud columns, cells = CountCells }
-- IDEMPOTENT and terrain-only: Terrain:ReplaceMaterial Grass -> Sand, one 4 x 16 x 4 column at a time, so only Grass changes
-- (Water, Pavement, Asphalt and every part are left alone; no Air is filled). A second run finds no Grass left and repaints 0.
-- The selection depends only on the Water cells, the Site09 parts and math.noise, never on Grass vs Sand, so it is stable.
-- Four beaches, two per arm, each arm split by one Grass gap:
--   NW arm: x -860..-720 (z 508..600), depth 16..28 studs from the water, gap across the shore at (-750, 558);
--   SE arm: z 646..800 (x -668..-556), depth 24..40 studs by the quay (z <= 704) and 16..28 beyond, gap at (-602, 710).
-- (Revision 4 first tried 12..24 studs; from the Guide camera that still read as a thin line, so the depths were raised.)
-- A 4-stud column is repainted when its surface cell (y -4..0) is Grass, it lies in an arm, its distance to the nearest Water
-- cell (cell centre to cell centre) is within the arm's ragged depth (math.noise), it is not in the gap, and no Site09 part
-- stands over it. The outer ends of the arms taper over 20..24 studs so they do not stop on a straight line.
-- Spec: tests/site09_check.luau "shore:" checks; world_check's Tagbakin Grass controls are all under parts or 28+ studs inland.
return function()
	local T = workspace.Terrain
	local M = Enum.Material
	local V = Vector3.new
	local site = workspace:FindFirstChild("Sites") and workspace.Sites:FindFirstChild("Site09_Tagbakin")
	assert(site, "site09_shore: Workspace.Sites.Site09_Tagbakin not found")

	local X0, X1, Z0, Z1 = -868, -552, 504, 804 -- the surface layer read (4-stud grid); site09_check scans the same box
	local REACH = 10 -- cells searched for Water (40 studs, the deepest beach)
	local mats = T:ReadVoxels(Region3.new(V(X0, -4, Z0), V(X1, 0, Z1)), 4)
	local nx, nz = mats.Size.X, mats.Size.Z
	local function at(i, k)
		if i < 1 or k < 1 or i > nx or k > nz then return nil end
		return mats[i][1][k]
	end
	local function waterDist(i, k)
		local best = math.huge
		for di = -REACH, REACH do
			for dk = -REACH, REACH do
				if at(i + di, k + dk) == M.Water then best = math.min(best, 4 * math.sqrt(di * di + dk * dk)) end
			end
		end
		return best
	end
	-- along-shore gap: |offset . u| <= half width, u = the shore direction of that arm
	local function inGap(cx, cz, gx, gz, ux, uz, n)
		return math.abs((cx - gx) * ux + (cz - gz) * uz) <= 4 + 3 * n
	end
	local function depthAt(cx, cz)
		local n = math.clamp(math.noise(cx / 16, cz / 16, 0.37) + 0.5, 0, 1)
		if cx >= -864 and cx <= -716 and cz >= 508 and cz <= 600 then -- NW arm
			if inGap(cx, cz, -750, 558, 0.95, 0.31, n) then return 0 end
			return (16 + 12 * n) * math.clamp((cx + 860) / 20, 0, 1)
		elseif cx >= -668 and cx <= -556 and cz >= 646 and cz <= 800 then -- SE arm
			if inGap(cx, cz, -602, 710, 0.36, 0.93, n) then return 0 end
			local d = cz <= 704 and (24 + 16 * n) or (16 + 12 * n)
			return d * math.clamp((800 - cz) / 24, 0, 1)
		end
		return 0
	end
	local op = OverlapParams.new()
	op.FilterType = Enum.RaycastFilterType.Include
	op.FilterDescendantsInstances = { site }

	local columns = 0
	for i = 1, nx do
		for k = 1, nz do
			if at(i, k) == M.Grass then
				local cx, cz = X0 + (i - 0.5) * 4, Z0 + (k - 0.5) * 4
				local depth = depthAt(cx, cz)
				if depth > 0 and waterDist(i, k) <= depth
					and #workspace:GetPartBoundsInBox(CFrame.new(cx, 10, cz), V(3.9, 20, 3.9), op) == 0 then
					T:ReplaceMaterial(Region3.new(V(cx - 2, -12, cz - 2), V(cx + 2, 4, cz + 2)), 4, M.Grass, M.Sand)
					columns += 1
				end
			end
		end
		if i % 20 == 0 then task.wait() end
	end
	return { columns = columns, cells = T:CountCells() }
end
