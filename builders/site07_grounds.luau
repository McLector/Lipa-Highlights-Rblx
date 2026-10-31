-- site07_grounds: the paths (LandscapedPath), the plazas, the Wellness board and the planting (dense palms, trees, shrubs) of Site 07.
-- Studio copy: ServerStorage.Builders.site07_grounds. Assembler: builders/site07.luau. Check: tests/site07_check.luau, groups centre, planting,
--   ground; tests/sites_check.luau (lanes, keep-clear boxes, sight-lines).
-- Owns LandscapedPath/Entry, LandscapedPath/Plaza, LandscapedPath/Walks, WellnessPanel, Structure/PalmsA, Structure/PalmsB, Structure/PalmsC,
-- Structure/Trees, Structure/TreesB, Structure/TreesC, Structure/Hedges. Budget 1850.
-- Revision 3 (session 062, owner: the west half is still open, make it denser so it matches the board): the parts come from the planting
--   outside the river ring (its 49 palms became broadleaf trees, 3 parts instead of 8). Planting now fills the west half of the land first
--   (trees, then palms in the gaps; palms may stand nearer the small villas, as on the board), then the east half up to 62 palms, then the
--   forest beyond the river. Trees in the west get larger crowns (22..24, still inside the 12-stud corridor margin). Trunks keep a crown
--   radius plus one from the sites_check keep-clear boxes (env.LAYOUT.keepClear). New: walks A (the north-west villa loop to the temple),
--   F (along the Sulu Terraces), G (to the gym door); low hedges (<= 2.4 high) in the west lawns where tall planting would cut the sight-lines.
-- Tidy (owner's look, 2026-10-31): the big grey courts became lawn (Grass-material parts in the terrain's grass colour over the old Pavement
--   cells) with walks and small terraces; the planting is much denser (100 palms, 256 broadleaf trees; the low shrubs gave way to canopy) so the oval reads as canopy.
-- Source: "San_benito_blueprint.png": pale winding paths link every zone; dense palms and broadleaf trees fill the oval and the banks beyond
--   the river. The patterned path keeps the Slice 09/20 look (dark pebble, white fish-scale chevrons, mossy curbs, briefs/site07.md).
-- Covers every old Pavement cell (P1..P5 of the Slice 09 build) with path or plaza parts; terrain is never written.
-- Planting is placed on a fixed grid with a position hash (no randomness: every run is equal) and kept out of the zones, the walks, the
--   river band and the sight-line corridors of env.LAYOUT. Palms stand 16..22 tall; trunks collide, fronds do not.
-- Frame: WORLD coordinates, y above the ground (0). Pure function of env. The only text: the Wellness board (unchanged words).
return function(env)
	local V, CF, PI = env.V, env.CF, env.PI
	local box, seg, vcyl = env.box, env.seg, env.vcyl
	local C3 = Color3.fromRGB
	local PEBBLE, INLAY, MOSS, PLAZA = C3(62, 62, 66), C3(200, 196, 188), C3(70, 96, 54), C3(206, 198, 180)
	local WALK, CREAM, DARK, LAWN = C3(196, 186, 164), C3(222, 214, 196), C3(70, 48, 34), C3(104, 124, 60)
	local PEB, SMOOTH, GRASSM, SLATE, WOOD = Enum.Material.Pebble, Enum.Material.SmoothPlastic, Enum.Material.Grass, Enum.Material.Slate, Enum.Material.Wood
	local L = env.LAYOUT

	-- white chevron pair (the fish-scale approximation) centred at (x, z), opening toward +X
	local function chevron(ctx, x, z)
		for _, ang in ipairs({ 0.6, -0.6 }) do
			ctx:part("PathInlay", V(0.4, 0.06, 5), CF(x, 0.33, z) * CFrame.Angles(0, ang + PI / 2, 0), INLAY, SMOOTH)
		end
	end

	------------------------------------------------------------------ Entry: PathStart, the patterned entry path, curbs (gaps for the two walks)
	env.section("LandscapedPath/Entry", function(ctx)
		box(ctx, "PathStart", 595, 607, 0, 0.3, 232, 248, PEBBLE, PEB)
		box(ctx, "EntryPath", 607, 652, 0, 0.3, 232, 248, PEBBLE, PEB)
		for _, run in ipairs({ { 595, 636 }, { 644, 652 } }) do
			box(ctx, "EntryCurb", run[1], run[2], 0, 1, 231, 232, MOSS, GRASSM)
			box(ctx, "EntryCurb", run[1], run[2], 0, 1, 248, 249, MOSS, GRASSM)
		end
		for x = 600, 648, 6 do
			chevron(ctx, x, 236)
			chevron(ctx, x, 244)
		end
	end)

	------------------------------------------------------------------ Plaza: the arrival band and jeep apron, lawns over the old Pavement cells, the south walk
	env.section("LandscapedPath/Plaza", function(ctx)
		-- Arrival (old Pavement cell P2, x 652..700, z 192..260): a patterned band z 230..250 along the Guide's axis (bare under the Guide,
		-- x 667..673, z 237..243), a pebble apron under the jeepney (x 660..680, z 192..230, bare under the pad x 665..675, z 215..225), lawn elsewhere.
		box(ctx, "PlazaSlab", 652, 667, 0, 0.3, 230, 250, PEBBLE, PEB)
		box(ctx, "PlazaSlab", 673, 700, 0, 0.3, 230, 250, PEBBLE, PEB)
		box(ctx, "PlazaSlab", 667, 673, 0, 0.3, 230, 237, PEBBLE, PEB)
		box(ctx, "PlazaSlab", 667, 673, 0, 0.3, 243, 250, PEBBLE, PEB)
		box(ctx, "JeepApron", 660, 665, 0, 0.3, 192, 230, PEBBLE, PEB)
		box(ctx, "JeepApron", 675, 680, 0, 0.3, 192, 230, PEBBLE, PEB)
		box(ctx, "JeepApron", 665, 675, 0, 0.3, 192, 215, PEBBLE, PEB)
		box(ctx, "JeepApron", 665, 675, 0, 0.3, 225, 230, PEBBLE, PEB)
		box(ctx, "Lawn", 652, 660, 0, 0.3, 192, 230, LAWN, GRASSM)
		box(ctx, "Lawn", 680, 700, 0, 0.3, 192, 230, LAWN, GRASSM)
		box(ctx, "Lawn", 652, 700, 0, 0.3, 250, 260, LAWN, GRASSM)
		-- the pattern carries on across the band toward the amphitheater (outside the Guide box)
		for x = 686, 698, 6 do
			chevron(ctx, x, 236)
			chevron(ctx, x, 244)
		end
		-- Central lawn over the old central plaza (cell P3 inside it); walks run over it (LandscapedPath/Walks).
		box(ctx, "Lawn", 700, 800, 0, 0.3, 200, 280, LAWN, GRASSM)
		-- Lawn over the old cells P4 and P5, under the south walk.
		box(ctx, "Lawn", 692, 708, 0, 0.3, 260, 300, LAWN, GRASSM)
		box(ctx, "Lawn", 708, 752, 0, 0.3, 284, 300, LAWN, GRASSM)
		-- South walk to the Banaba forecourt (lane c, x 698..702, runs down it; lane d, z 290..294, along its east leg).
		box(ctx, "SouthWalk", 696, 704, 0, 0.36, 260, 296, PEBBLE, PEB)
		box(ctx, "SouthWalk", 704, 752, 0, 0.36, 288, 296, PEBBLE, PEB)
		for z = 266, 287, 7 do
			for _, ang in ipairs({ 0.6, -0.6 }) do
				ctx:part("PathInlay", V(0.4, 0.06, 5), CF(700, 0.39, z) * CFrame.Angles(0, ang, 0), INLAY, SMOOTH)
			end
		end
	end)

	------------------------------------------------------------------ Walks: the winding paths (6 wide, joints rounded with discs)
	local WALKS = {
		{ w = 5, pts = { { 690, 192 }, { 690, 183 } } }, -- arrival lawn to the labyrinth
		{ w = 5, pts = { { 802, 204 }, { 816, 178 }, { 836, 163 }, { 864, 175 }, { 894, 183 }, { 912, 200 }, { 918, 226 } } }, -- NE: Narra villas to the Front Office
		{ w = 4, pts = { { 821, 173 }, { 821, 141 } } }, { w = 4, pts = { { 851, 168 }, { 851, 151 } } }, { w = 4, pts = { { 880, 179 }, { 880, 167 } } },
		{ w = 5, pts = { { 800, 273 }, { 830, 273 }, { 900, 273 }, { 926, 276 } } }, -- east: the Front Office porch and the Sanctuary veranda
		{ w = 5, pts = { { 806, 318 }, { 816, 296 }, { 822, 275 } } }, -- Banaba court to the east walk
		{ w = 8, pts = { { 640, 249 }, { 640, 255 } } }, -- entry path to Acqua
		{ w = 5, pts = { { 640, 231 }, { 636, 206 }, { 646, 186 }, { 664, 176 }, { 673, 170 } } }, -- entry path north-east to the labyrinth
		-- tidy: walks across the central lawn (round the amphitheater to the pavilion and the villa, to the boardwalk, the aisle, the east walk)
		{ w = 5, pts = { { 700, 240 }, { 716, 224 }, { 744, 216 }, { 776, 226 } } },
		{ w = 5, pts = { { 760, 220 }, { 785, 202 } } },
		{ w = 5, pts = { { 700, 258 }, { 722, 257 } } },
		{ w = 5, pts = { { 776, 256 }, { 800, 272 } } },
		-- Revision 3: A the north-west loop past the Acacia and Mahogany doors to the temple; F along the Sulu Terraces to the east walk; G to the gym
		{ w = 5, pts = { { 636, 206 }, { 616, 201 }, { 629, 184 }, { 642, 170 }, { 654, 156 }, { 660, 146 }, { 676, 140 } } },
		{ w = 5, pts = { { 704, 273.5 }, { 776, 273.5 }, { 800, 273 } } },
		{ w = 5, pts = { { 696, 266 }, { 676, 268 } } },
	}
	env.section("LandscapedPath/Walks", function(ctx)
		for _, wk in ipairs(WALKS) do
			for i = 1, #wk.pts - 1 do
				local a, b = wk.pts[i], wk.pts[i + 1]
				seg(ctx, "PathSegment", a[1], a[2], b[1], b[2], wk.w, 0, 0.36, WALK, SLATE)
				if i > 1 then vcyl(ctx, "PathJoint", a[1], a[2], 0, 0.36, wk.w, WALK, SLATE) end
			end
		end
	end)

	------------------------------------------------------------------ WellnessPanel: signboard on two posts, text facing west (the -X face)
	env.section("WellnessPanel", function(ctx)
		local board = box(ctx, "WellnessBoard", 702, 704, 3, 9, 194, 206, CREAM, SMOOTH)
		env.gui(board, Enum.NormalId.Left, "WELLNESS TOURISM. The Farm at San Benito is an operating resort representing Lipa's contemporary wellness tourism: gardens, accommodation, dining and organized activities. Visits involve bookings or paid services.", nil, DARK, 40, 18)
		box(ctx, "WellnessPost", 702, 704, 0, 3, 195, 196, DARK, WOOD)
		box(ctx, "WellnessPost", 702, 704, 0, 3, 204, 205, DARK, WOOD)
	end)

	------------------------------------------------------------------ Hedges (Revision 3): low clipped hedges in the west lawns, all <= 2.4 high, outside the
	-- lanes, the keep-clear boxes and the walks; the sight-line rays (eye y 6) pass over them.
	local HEDGES = {
		{ 684, 698, 196, 199 }, { 684, 698, 207, 210 }, { 684, 698, 216, 219 }, -- plaza lawn east of the jeep apron (x > 682), west of the Wellness board
		{ 651, 657, 252, 259 }, { 684, 696, 253, 257 }, -- plaza lawn either side of the InfoPanel zone (x 664..676) and south of the Guide box
		{ 714, 734, 205, 208 }, -- central lawn between the Wellness board and the round pavilion
		{ 704, 714, 246, 250 }, { 706, 718, 263, 268 }, -- either side of the walk to the amphitheater aisle
		{ 658, 661, 262, 292 }, { 691, 694, 272, 292 }, -- along the gym, between the drive and the south walk
		{ 654, 657, 194, 210 }, { 654, 657, 222, 227 }, -- plaza lawn west of the jeep box (x < 658)
		{ 664, 676, 128, 133 }, { 694, 700, 187, 192 }, -- north-west of the temple; south of the labyrinth beside its walk
	}
	env.section("Structure/Hedges", function(ctx)
		for _, h in ipairs(HEDGES) do
			box(ctx, "Hedge", h[1], h[2], 0, 2.4, h[3], h[4], C3(40, 96, 46), GRASSM)
		end
	end)

	------------------------------------------------------------------ Planting
	local function hash(a, b)
		local s = math.sin(a * 12.9898 + b * 78.233) * 43758.5453
		return s - math.floor(s)
	end
	local function distSeg(px, pz, a, b)
		local dx, dz = b[1] - a[1], b[2] - a[2]
		local t = ((px - a[1]) * dx + (pz - a[2]) * dz) / (dx * dx + dz * dz)
		t = math.clamp(t, 0, 1)
		local qx, qz = a[1] + t * dx, a[2] + t * dz
		return math.sqrt((px - qx) ^ 2 + (pz - qz) ^ 2)
	end
	local function inTri(px, pz, t)
		local function s(a, b) return (px - b[1]) * (a[2] - b[2]) - (a[1] - b[1]) * (pz - b[2]) end
		local d1, d2, d3 = s(t[1], t[2]), s(t[2], t[3]), s(t[3], t[1])
		local neg = d1 < 0 or d2 < 0 or d3 < 0
		local pos = d1 > 0 or d2 > 0 or d3 > 0
		return not (neg and pos)
	end
	local E = L.ellipse
	-- tall = palm or tree (collides, crowns reach ~10): kept out of the corridors too; low = shrub (<= 3 high). palm = a palm (fronds high
	-- above the roofs): it may stand 9 x 8 from a small villa without a pool (trees keep 16 x 15).
	local function valid(x, z, tall, palm)
		if x < 582 or x > 958 or z < 92 or z > 388 then return false end
		local ein = ((x - E.cx) / (E.a - E.w / 2 - 6)) ^ 2 + ((z - E.cz) / (E.b - E.w / 2 - 6)) ^ 2
		local eout = ((x - E.cx) / (E.a + E.w / 2 + 6)) ^ 2 + ((z - E.cz) / (E.b + E.w / 2 + 6)) ^ 2
		if ein > 1 and eout < 1 then return false end
		local r = tall and 4 or 2
		for _, o in ipairs(L.occupied) do
			if x > o[1] - r and x < o[2] + r and z > o[3] - r and z < o[4] + r then return false end
		end
		if tall then -- Revision 3: a crown radius plus one from the keep-clear boxes (their queries see non-colliding crowns and fronds)
			local k = palm and 10 or 13
			for _, o in ipairs(L.keepClear) do
				if x > o[1] - k and x < o[2] + k and z > o[3] - k and z < o[4] + k then return false end
			end
		end
		for _, v in ipairs(L.smallVillas) do -- the 10 x 8 house and its pool, within 12 x 11 of the centre
			local mx, mz = 12 + r, 11 + r
			if palm and not v[3] then mx, mz = 9, 8 end
			if math.abs(x - v[1]) < mx and math.abs(z - v[2]) < mz then return false end
		end
		for _, wk in ipairs(WALKS) do
			for i = 1, #wk.pts - 1 do
				if distSeg(x, z, wk.pts[i], wk.pts[i + 1]) < wk.w / 2 + (tall and 2.5 or 1.5) then return false end
			end
		end
		if tall then
			for _, t in ipairs(L.corridors) do
				if inTri(x, z, t) then return false end
				for i = 1, 3 do
					if distSeg(x, z, t[i], t[i % 3 + 1]) < 12 then return false end
				end
			end
		end
		return true
	end
	-- Revision 3: candidates in three tiers (1 = land west of x 770, 2 = land east, 3 = beyond the river), hash order inside each tier.
	local function inLand(x, z) return ((x - 770) / 182) ^ 2 + ((z - 240) / 140) ^ 2 <= 1 end
	local cands = {}
	for i = 0, 54 do
		for j = 0, 42 do
			local x = 582 + 7 * i + (hash(i, j) - 0.5) * 4
			local z = 92 + 7 * j + (hash(j + 101, i) - 0.5) * 4
			local tier = inLand(x, z) and (x < 770 and 1 or 2) or 3
			table.insert(cands, { x = x, z = z, h = hash(i + 7, j + 13), tier = tier })
		end
	end
	table.sort(cands, function(a, b)
		if a.tier ~= b.tier then return a.tier < b.tier end
		return a.h < b.h
	end)
	local PALMS, TREES = 62, 390
	local palms, trees, shrubs = {}, {}, {}
	local function spaced(list, x, z, d)
		for _, p in ipairs(list) do
			if (p.x - x) ^ 2 + (p.z - z) ^ 2 < d * d then return false end
		end
		return true
	end
	-- 1. west trees, 2. west palms in the gaps (nearer the villas, spaced 6), 3. east palms up to PALMS, 4. east trees, then the forest beyond the river
	for _, c in ipairs(cands) do
		if c.tier == 1 and valid(c.x, c.z, true) and spaced(trees, c.x, c.z, 6.5) then table.insert(trees, c) end
	end
	for _, c in ipairs(cands) do
		if c.tier == 1 and #palms < PALMS and valid(c.x, c.z, true, true) and spaced(trees, c.x, c.z, 6) and spaced(palms, c.x, c.z, 6) then
			table.insert(palms, c)
		end
	end
	for _, c in ipairs(cands) do
		if c.tier == 2 and #palms < PALMS and valid(c.x, c.z, true, true) and spaced(trees, c.x, c.z, 7) and spaced(palms, c.x, c.z, 8) then
			table.insert(palms, c)
		end
	end
	for _, c in ipairs(cands) do
		if c.tier >= 2 and #trees < TREES and valid(c.x, c.z, true) and spaced(palms, c.x, c.z, 6.5) and spaced(trees, c.x, c.z, 6.5) then
			table.insert(trees, c)
		end
	end
	-- palms in three containers of at most 45 (360 parts each, under the 400 cap)
	for c, path in ipairs({ "Structure/PalmsA", "Structure/PalmsB", "Structure/PalmsC" }) do
		env.section(path, function(ctx)
			for i = (c - 1) * 45 + 1, math.min(c * 45, #palms) do
				local p = palms[i]
				env.palm(ctx, p.x, p.z, 16 + 6 * hash(p.x, p.z))
			end
		end)
	end
	-- broadleaf trees (crowns 17..23 across, 22..24 in the west; under the 12-stud corridor margin; the board's canopy) in three containers
	-- of at most 130 (390 parts each); the shrubs (<= 3 high, none at present) go with the last
	local function plantTrees(ctx, i0, i1)
		for i = i0, math.min(i1, #trees) do
			local t = trees[i]
			local k = hash(t.z, t.x)
			local d = t.tier == 1 and (22 + 2 * k) or (17 + 6 * k)
			env.tree(ctx, t.x, t.z, d, d)
		end
	end
	env.section("Structure/Trees", function(ctx) plantTrees(ctx, 1, 130) end)
	env.section("Structure/TreesB", function(ctx) plantTrees(ctx, 131, 260) end)
	env.section("Structure/TreesC", function(ctx)
		plantTrees(ctx, 261, 390)
		for _, sh in ipairs(shrubs) do
			env.shrub(ctx, sh.x, sh.z, 2.4 + 1.2 * hash(sh.x + 3, sh.z))
		end
	end)
end
