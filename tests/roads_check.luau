-- roads_check: the spec for the three new roads (Slice 3b, City Hall) and the ground under City Hall's forecourt.
-- Studio copy: ServerStorage.Checks.roads_check. Run in Edit via execute_luau; returns JSON {passed, failed, failures, info}.
-- Needs ReplicatedStorage.LipaShared.RoadData. Pure geometry plus terrain reads: no Play mode, no pathfinding.
--
-- 1. Margin rule: a new road segment, widened to width/2 + 4, must not overlap any site model's real axis-aligned bounds (computed from
--    the parts' rotated corners) expanded by 10 percent of its size on every side. The ONLY allowed contact is SPUR x Site10_CityHall:
--    the spur's west end sits 8 studs from City Hall's front edge (x -150) so the curb at (-155,-230) steps onto it. For that contact
--    the spur's own rectangle (no margin) must still stay clear of City Hall's real bounds.
-- 2. Clearance: no new road, at width/2 + 6, overlaps a Guide, JeepStop, Jeepney, InfoPanel or the SpawnLocation pad.
-- 3. Every new road ends on or crosses a road centre line (existing roads, or the SPUR for the start of WEST_BYPASS); the Road C crossing
--    of EAST_BYPASS is a junction. Each new road touches at least one ORIGINAL road.
-- 4. Reachability: a graph of the road centre lines (nodes where centre lines cross or touch) plus short walk links from the spawn
--    (<= 80 studs) and each Guide (<= 175 studs) to the nearest centre line. Every Guide must be reachable from the spawn, and without
--    the new roads the spawn must NOT reach the Cathedral Guide (negative control).
-- 5. Terrain: the new centre lines are Asphalt; the forecourt ground x -228..-148, z -332..-188 is Pavement and the cells around it are not.
local HttpService = game:GetService("HttpService")
local RoadData = require(game.ReplicatedStorage.LipaShared.RoadData:Clone())

local results = { passed = 0, failed = 0, failures = {}, info = {} }
local function check(name, cond, detail)
	if cond then
		results.passed += 1
	else
		results.failed += 1
		table.insert(results.failures, name .. (detail and (" | " .. detail) or ""))
	end
end
local function fmt(n) return string.format("%.1f", n) end

-- Footprints ---------------------------------------------------------------------------------------------------------
local function partRect(p)
	local x0, x1, z0, z1 = math.huge, -math.huge, math.huge, -math.huge
	for _, a in ipairs({ -0.5, 0.5 }) do
		for _, b in ipairs({ -0.5, 0.5 }) do
			local c = p.CFrame:PointToWorldSpace(Vector3.new(a * p.Size.X, 0, b * p.Size.Z))
			x0, x1, z0, z1 = math.min(x0, c.X), math.max(x1, c.X), math.min(z0, c.Z), math.max(z1, c.Z)
		end
	end
	return { x0 = x0, x1 = x1, z0 = z0, z1 = z1 }
end
local function modelRect(m)
	local r = { x0 = math.huge, x1 = -math.huge, z0 = math.huge, z1 = -math.huge }
	for _, d in ipairs(m:GetDescendants()) do
		if d:IsA("BasePart") then
			local q = partRect(d)
			r = { x0 = math.min(r.x0, q.x0), x1 = math.max(r.x1, q.x1), z0 = math.min(r.z0, q.z0), z1 = math.max(r.z1, q.z1) }
		end
	end
	return r
end
local function expand(r, mx, mz) return { x0 = r.x0 - mx, x1 = r.x1 + mx, z0 = r.z0 - mz, z1 = r.z1 + mz } end
local EPS = 1e-6
local function overlap(a, b) -- strict: touching edges do not overlap
	return a.x0 < b.x1 - EPS and b.x0 < a.x1 - EPS and a.z0 < b.z1 - EPS and b.z0 < a.z1 - EPS
end
local function segRect(a, b, half)
	return { x0 = math.min(a[1], b[1]) - half, x1 = math.max(a[1], b[1]) + half, z0 = math.min(a[2], b[2]) - half, z1 = math.max(a[2], b[2]) + half }
end

-- Scene --------------------------------------------------------------------------------------------------------------
local sites = workspace:FindFirstChild("Sites")
check("Workspace.Sites exists", sites ~= nil)
local siteRects, objects, guides = {}, {}, {}
if sites then
	for _, m in ipairs(sites:GetChildren()) do
		local r = modelRect(m)
		siteRects[m.Name] = r
		table.insert(results.info, string.format("%s x[%.0f,%.0f] z[%.0f,%.0f]", m.Name, r.x0, r.x1, r.z0, r.z1))
		for _, n in ipairs({ "Guide", "JeepStop", "Jeepney", "InfoPanel" }) do
			local o = m:FindFirstChild(n)
			if o then
				local rr = o:IsA("BasePart") and partRect(o) or modelRect(o)
				table.insert(objects, { name = m.Name .. "." .. n, rect = rr })
			end
		end
		local g = m:FindFirstChild("Guide")
		if g then table.insert(guides, { name = m.Name, pos = g:GetPivot().Position }) end
	end
end
local spawn = workspace:FindFirstChild("SpawnLocation")
check("SpawnLocation exists", spawn ~= nil)
if spawn then table.insert(objects, { name = "SpawnLocation", rect = partRect(spawn) }) end
check("ten Guides found", #guides == 10, tostring(#guides))

-- 1. Margin rule -----------------------------------------------------------------------------------------------------
local ALLOWED = { SPUR = { Site10_CityHall = true } }
for _, road in ipairs(RoadData.NEW_ROADS) do
	for i = 1, #road.pts - 1 do
		local a, b = road.pts[i], road.pts[i + 1]
		local wide = segRect(a, b, road.w / 2 + 4)
		for name, r in pairs(siteRects) do
			local slack = expand(r, 0.1 * (r.x1 - r.x0), 0.1 * (r.z1 - r.z0))
			local hit = overlap(wide, slack)
			if ALLOWED[road.name] and ALLOWED[road.name][name] then
				-- the intentional contact: the road may enter the margin zone but its own footprint may not touch the building
				check(road.name .. " seg " .. i .. " own footprint (no margin) is clear of " .. name .. " real bounds", not overlap(segRect(a, b, road.w / 2), r))
			else
				check(road.name .. " seg " .. i .. " margin (w/2+4) clears " .. name .. " bounds +10%", not hit,
					string.format("road x[%.0f,%.0f] z[%.0f,%.0f] vs x[%.1f,%.1f] z[%.1f,%.1f]", wide.x0, wide.x1, wide.z0, wide.z1, slack.x0, slack.x1, slack.z0, slack.z1))
			end
		end
	end
end
-- Cathedral: the compound is the reason for the bypasses, so state the clearance as studs too
local cath = siteRects["Site01_Cathedral"]
if cath then
	local minGap = math.huge
	for _, name in ipairs({ "WEST_BYPASS", "EAST_BYPASS" }) do
		for _, road in ipairs(RoadData.NEW_ROADS) do
			if road.name == name then
				for i = 1, #road.pts - 1 do
					local r = segRect(road.pts[i], road.pts[i + 1], road.w / 2)
					local gx = math.max(cath.x0 - r.x1, r.x0 - cath.x1, 0)
					local gz = math.max(cath.z0 - r.z1, r.z0 - cath.z1, 0)
					minGap = math.min(minGap, math.sqrt(gx * gx + gz * gz))
				end
			end
		end
	end
	check("bypasses keep at least 30 studs of clear ground from the Cathedral compound", minGap >= 30, fmt(minGap))
	table.insert(results.info, "bypass to Cathedral clearance " .. fmt(minGap))
end

-- 2. Clearance from Guides, JeepStops, Jeepneys, InfoPanels and the spawn pad -----------------------------------------------
for _, road in ipairs(RoadData.NEW_ROADS) do
	for i = 1, #road.pts - 1 do
		-- w/2 + 6 sideways, 6 along the segment (a free end has no cap; a joint is covered by the next segment's sideways margin)
		local a, b = road.pts[i], road.pts[i + 1]
		local wide = a[1] == b[1] and { x0 = a[1] - road.w / 2 - 6, x1 = a[1] + road.w / 2 + 6, z0 = math.min(a[2], b[2]) - 6, z1 = math.max(a[2], b[2]) + 6 }
			or { x0 = math.min(a[1], b[1]) - 6, x1 = math.max(a[1], b[1]) + 6, z0 = a[2] - road.w / 2 - 6, z1 = a[2] + road.w / 2 + 6 }
		local clash = {}
		for _, o in ipairs(objects) do
			if overlap(wide, o.rect) then table.insert(clash, o.name) end
		end
		check(road.name .. " seg " .. i .. " is 6 studs clear of every Guide, JeepStop, Jeepney, InfoPanel and the spawn pad", #clash == 0, table.concat(clash, ", "))
	end
end

-- 3. Junctions -----------------------------------------------------------------------------------------------------------
local function onSegment(p, a, b, tol)
	if a[1] == b[1] then return math.abs(p[1] - a[1]) <= tol and p[2] >= math.min(a[2], b[2]) - tol and p[2] <= math.max(a[2], b[2]) + tol end
	return math.abs(p[2] - a[2]) <= tol and p[1] >= math.min(a[1], b[1]) - tol and p[1] <= math.max(a[1], b[1]) + tol
end
local function onRoad(p, roads, skip)
	for _, r in ipairs(roads) do
		if r ~= skip then
			for i = 1, #r.pts - 1 do
				if onSegment(p, r.pts[i], r.pts[i + 1], 0.01) then return r.name end
			end
		end
	end
	return nil
end
local all = RoadData.all()
for _, road in ipairs(RoadData.NEW_ROADS) do
	local first, last = road.pts[1], road.pts[#road.pts]
	local startOn = onRoad(first, all, road)
	local endOn = onRoad(last, all, road)
	if road.name == "SPUR" then
		check("SPUR's east end is on Road A", endOn == "A_to_Carmel", tostring(endOn))
		check("SPUR's west end is the curb contact (8 studs east of City Hall's front edge)", first[1] == -142 and first[2] == -230, first[1] .. "," .. first[2])
	else
		check(road.name .. " starts on a road centre line", startOn ~= nil, first[1] .. "," .. first[2])
		check(road.name .. " ends on a road centre line", endOn ~= nil, last[1] .. "," .. last[2])
	end
	local touchesOriginal = false
	for _, orig in ipairs(RoadData.ROADS) do
		for _, p in ipairs({ first, last }) do
			for i = 1, #orig.pts - 1 do
				if onSegment(p, orig.pts[i], orig.pts[i + 1], 0.01) then touchesOriginal = true end
			end
		end
	end
	check(road.name .. " touches an original road", touchesOriginal)
end
check("WEST_BYPASS starts on the SPUR", onRoad(RoadData.NEW_ROADS[2].pts[1], { RoadData.NEW_ROADS[1] }, nil) == "SPUR")
check("WEST_BYPASS ends on Road F", onRoad(RoadData.NEW_ROADS[2].pts[#RoadData.NEW_ROADS[2].pts], RoadData.ROADS, nil) == "F_to_Market")
check("EAST_BYPASS starts on Road H", onRoad(RoadData.NEW_ROADS[3].pts[1], RoadData.ROADS, nil) == "H_to_Cafe")
check("EAST_BYPASS ends on Road G", onRoad(RoadData.NEW_ROADS[3].pts[#RoadData.NEW_ROADS[3].pts], RoadData.ROADS, nil) == "G_to_Lomi")
do
	local eastX = RoadData.NEW_ROADS[3].pts[1][1]
	check("EAST_BYPASS crosses Road C (it is a junction)", onRoad({ eastX, 0 }, RoadData.ROADS, nil) == "C_to_Farm", tostring(eastX))
end
check("RoadData.all() lists the 8 original roads then the 3 new ones", #all == #RoadData.ROADS + #RoadData.NEW_ROADS and #RoadData.NEW_ROADS == 3 and #RoadData.ROADS == 8, tostring(#all))
for _, r in ipairs(RoadData.NEW_ROADS) do check(r.name .. " is 12 wide", r.w == 12) end

-- 4. Reachability: graph of the centre lines ---------------------------------------------------------------------------------
local function buildGraph(roads, attachments)
	local segs = {}
	for _, r in ipairs(roads) do
		for i = 1, #r.pts - 1 do
			local a, b = r.pts[i], r.pts[i + 1]
			table.insert(segs, { a = a, b = b, vertical = a[1] == b[1], pts = { [a[1] .. "," .. a[2]] = a, [b[1] .. "," .. b[2]] = b } })
		end
	end
	local function addPt(s, x, z) s.pts[x .. "," .. z] = { x, z } end
	for i = 1, #segs do
		for j = i + 1, #segs do
			local s, t = segs[i], segs[j]
			if s.vertical ~= t.vertical then
				local v, h = s.vertical and s or t, s.vertical and t or s
				local x, z = v.a[1], h.a[2]
				if z >= math.min(v.a[2], v.b[2]) and z <= math.max(v.a[2], v.b[2]) and x >= math.min(h.a[1], h.b[1]) and x <= math.max(h.a[1], h.b[1]) then
					addPt(s, x, z)
					addPt(t, x, z)
				end
			else -- collinear: share the end points that lie on the other segment
				for _, p in ipairs({ s.a, s.b }) do if onSegment(p, t.a, t.b, 0) then addPt(t, p[1], p[2]) end end
				for _, p in ipairs({ t.a, t.b }) do if onSegment(p, s.a, s.b, 0) then addPt(s, p[1], p[2]) end end
			end
		end
	end
	local links = {}
	for _, at in ipairs(attachments) do
		local best, bd, bp = nil, math.huge, nil
		for _, s in ipairs(segs) do
			local px = math.clamp(at.x, math.min(s.a[1], s.b[1]), math.max(s.a[1], s.b[1]))
			local pz = math.clamp(at.z, math.min(s.a[2], s.b[2]), math.max(s.a[2], s.b[2]))
			local d = math.sqrt((px - at.x) ^ 2 + (pz - at.z) ^ 2)
			if d < bd then best, bd, bp = s, d, { px, pz } end
		end
		if best and bd <= at.max then
			addPt(best, bp[1], bp[2])
			table.insert(links, { from = at.id, to = bp[1] .. "," .. bp[2], len = bd })
		end
	end
	local adj = {}
	local function edge(u, v, len)
		adj[u] = adj[u] or {}
		adj[v] = adj[v] or {}
		table.insert(adj[u], { v, len })
		table.insert(adj[v], { u, len })
	end
	for _, s in ipairs(segs) do
		local list = {}
		for _, p in pairs(s.pts) do table.insert(list, p) end
		table.sort(list, function(p, q) if s.vertical then return p[2] < q[2] end return p[1] < q[1] end)
		for k = 1, #list - 1 do
			local p, q = list[k], list[k + 1]
			edge(p[1] .. "," .. p[2], q[1] .. "," .. q[2], math.abs(q[1] - p[1]) + math.abs(q[2] - p[2]))
		end
	end
	for _, l in ipairs(links) do edge(l.from, l.to, l.len) end
	return adj
end
local function shortest(adj, src)
	local dist, done = { [src] = 0 }, {}
	while true do
		local u, ud = nil, math.huge
		for n, d in pairs(dist) do if not done[n] and d < ud then u, ud = n, d end end
		if not u then break end
		done[u] = true
		for _, e in ipairs(adj[u] or {}) do
			local nd = ud + e[2]
			if dist[e[1]] == nil or nd < dist[e[1]] then dist[e[1]] = nd end
		end
	end
	return dist
end
local function attachments()
	local list = {}
	if spawn then table.insert(list, { id = "spawn", x = spawn.Position.X, z = spawn.Position.Z, max = 80 }) end
	for _, g in ipairs(guides) do table.insert(list, { id = "guide:" .. g.name, x = g.pos.X, z = g.pos.Z, max = 175 }) end
	return list
end
if spawn then
	local adj = buildGraph(all, attachments())
	local dist = shortest(adj, "spawn")
	for _, g in ipairs(guides) do
		local d = dist["guide:" .. g.name]
		check("spawn reaches the Guide of " .. g.name .. " over roads and walk links", d ~= nil)
		table.insert(results.info, string.format("graph spawn -> %s: %s", g.name, d and fmt(d) or "unreachable"))
	end
	-- the spawn must sit by the SPUR: its walk link must land on the spur, not on some other road
	local landed
	for _, e in ipairs(adj["spawn"] or {}) do
		local x, z = e[1]:match("^(-?[%d%.]+),(-?[%d%.]+)$")
		if x then landed = onRoad({ tonumber(x), tonumber(z) }, RoadData.NEW_ROADS, nil) end
	end
	check("the spawn's nearest road is the SPUR (City Hall forecourt)", landed == "SPUR", tostring(landed))
	-- negative control: without the new roads the spawn is cut off from the Cathedral
	local adj0 = buildGraph(RoadData.ROADS, attachments())
	local dist0 = shortest(adj0, "spawn")
	check("negative control: without the new roads the spawn cannot reach the Cathedral Guide", dist0["guide:Site01_Cathedral"] == nil)
end

-- 5. Terrain ---------------------------------------------------------------------------------------------------------------
local T = workspace.Terrain
local function cellMaterial(x, z)
	local fx, fz = math.floor(x / 4) * 4, math.floor(z / 4) * 4
	return T:ReadVoxels(Region3.new(Vector3.new(fx, -4, fz), Vector3.new(fx + 4, 0, fz + 4)), 4)[1][1][1]
end
for _, road in ipairs(RoadData.NEW_ROADS) do
	local bad, n = {}, 0
	for i = 1, #road.pts - 1 do
		local a, b = road.pts[i], road.pts[i + 1]
		local len = math.abs(b[1] - a[1]) + math.abs(b[2] - a[2])
		for d = 0, len, 20 do
			local t = d / len
			local x, z = a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t
			n += 1
			if cellMaterial(x, z) ~= Enum.Material.Asphalt then table.insert(bad, string.format("(%.0f,%.0f)=%s", x, z, cellMaterial(x, z).Name)) end
		end
	end
	check(road.name .. " centre line is Asphalt terrain at all " .. n .. " samples", #bad == 0, #bad .. " not asphalt: " .. table.concat(bad, " ", 1, math.min(#bad, 3)))
end
do
	local bad = {}
	for _, x in ipairs({ -224, -200, -176, -152 }) do
		for _, z in ipairs({ -328, -292, -260, -228, -196 }) do
			if cellMaterial(x, z) ~= Enum.Material.Pavement then table.insert(bad, string.format("(%d,%d)=%s", x, z, cellMaterial(x, z).Name)) end
		end
	end
	check("City Hall forecourt ground (x -228..-148, z -332..-188) is Pavement", #bad == 0, #bad .. " not pavement: " .. table.concat(bad, " ", 1, math.min(#bad, 3)))
	local spill = {}
	for _, p in ipairs({ { -236, -260 }, { -188, -340 }, { -188, -184 }, { -140, -300 } }) do
		if cellMaterial(p[1], p[2]) == Enum.Material.Pavement then table.insert(spill, string.format("(%d,%d)", p[1], p[2])) end
	end
	check("control: the cells just outside the repainted ground are not Pavement", #spill == 0, table.concat(spill, " "))
end

return HttpService:JSONEncode(results)
