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
-- 5. Terrain: the new centre lines are Asphalt; the City Hall ground x -324..-148, z -448..-188 is Concrete and the cells just outside it are still Grass.
local HttpService = game:GetService("HttpService")
local RoadData = require(game.ReplicatedStorage.LipaShared.RoadData:Clone())
local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())

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
-- B3c-0b: the two entrance roads to the Cathedral side stairs (section 7, briefs/site01.md "B3c-0b roads"). Every exception made for them in
-- sections 1, 3 and 6 reads this one table; every other road is checked exactly as before.
local ENTRY_ROADS = { WEST_ENTRY = true, EAST_ENTRY = true }
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
			elseif ENTRY_ROADS[road.name] and name == "Site01_Cathedral" then
				-- B3c-0b: an entrance road ends at the stair foot, inside the +10% margin by design; its body (sides w/2, no end caps) must
				-- still stay clear of the Cathedral's real bounds (x -128..128, where the stair treads end). Other sites keep the margin test.
				local body = a[1] == b[1] and { x0 = a[1] - road.w / 2, x1 = a[1] + road.w / 2, z0 = math.min(a[2], b[2]), z1 = math.max(a[2], b[2]) }
					or { x0 = math.min(a[1], b[1]), x1 = math.max(a[1], b[1]), z0 = a[2] - road.w / 2, z1 = a[2] + road.w / 2 }
				check(road.name .. " seg " .. i .. " body (no margin, no end caps) is clear of " .. name .. " real bounds", not overlap(body, r),
					string.format("road x[%.0f,%.0f] z[%.0f,%.0f] vs x[%.1f,%.1f] z[%.1f,%.1f]", body.x0, body.x1, body.z0, body.z1, r.x0, r.x1, r.z0, r.z1))
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
		if ENTRY_ROADS[road.name] then
			-- B3c-0b: an entrance road ends at the foot of the stair, not on a road (section 7 ties it to the stair parts)
			check(road.name .. " ends at the stair foot (|x| 128, z 26)", math.abs(last[1]) == 128 and last[2] == 26, last[1] .. "," .. last[2])
		else
			check(road.name .. " ends on a road centre line", endOn ~= nil, last[1] .. "," .. last[2])
		end
	end
	local touchesOriginal = false
	for _, orig in ipairs(RoadData.ROADS) do
		for _, p in ipairs({ first, last }) do
			for i = 1, #orig.pts - 1 do
				if onSegment(p, orig.pts[i], orig.pts[i + 1], 0.01) then touchesOriginal = true end
			end
		end
	end
	if ENTRY_ROADS[road.name] then
		-- B3c-0b: an entrance road starts on a new bypass; that bypass must itself touch an original road
		local hostTouches = false
		for _, host in ipairs(RoadData.NEW_ROADS) do
			if host.name == startOn then
				for _, orig in ipairs(RoadData.ROADS) do
					for _, p in ipairs({ host.pts[1], host.pts[#host.pts] }) do
						for i = 1, #orig.pts - 1 do
							if onSegment(p, orig.pts[i], orig.pts[i + 1], 0.01) then hostTouches = true end
						end
					end
				end
			end
		end
		check(road.name .. " touches an original road through its bypass (" .. tostring(startOn) .. ")", hostTouches and not ENTRY_ROADS[startOn])
	else
		check(road.name .. " touches an original road", touchesOriginal)
	end
end
check("WEST_BYPASS starts on the SPUR", onRoad(RoadData.NEW_ROADS[2].pts[1], { RoadData.NEW_ROADS[1] }, nil) == "SPUR")
check("WEST_BYPASS ends on Road F", onRoad(RoadData.NEW_ROADS[2].pts[#RoadData.NEW_ROADS[2].pts], RoadData.ROADS, nil) == "F_to_Market")
check("EAST_BYPASS starts on Road H", onRoad(RoadData.NEW_ROADS[3].pts[1], RoadData.ROADS, nil) == "H_to_Cafe")
check("EAST_BYPASS ends on Road G", onRoad(RoadData.NEW_ROADS[3].pts[#RoadData.NEW_ROADS[3].pts], RoadData.ROADS, nil) == "G_to_Lomi")
do
	local eastX = RoadData.NEW_ROADS[3].pts[1][1]
	check("EAST_BYPASS crosses Road C (it is a junction)", onRoad({ eastX, 0 }, RoadData.ROADS, nil) == "C_to_Farm", tostring(eastX))
end
do
	-- B3c-0b: 7 new roads, in this order (the position-indexed checks above rely on SPUR, WEST_BYPASS, EAST_BYPASS being 1..3)
	local expectedNew = { "SPUR", "WEST_BYPASS", "EAST_BYPASS", "WEST_LINK", "EAST_LINK", "WEST_ENTRY", "EAST_ENTRY" }
	local namesOk = #RoadData.NEW_ROADS == #expectedNew
	for i, nm in ipairs(expectedNew) do
		if not RoadData.NEW_ROADS[i] or RoadData.NEW_ROADS[i].name ~= nm then namesOk = false end
	end
	check("RoadData.all() lists the 8 original roads then the 7 new ones (SPUR, two bypasses, two south links, WEST_ENTRY, EAST_ENTRY)",
		#all == #RoadData.ROADS + #RoadData.NEW_ROADS and #RoadData.ROADS == 8 and namesOk, tostring(#all))
end
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

-- 6. Cathedral south growth (Slice 4 B3b) -------------------------------------------------------------------------------------
-- The Cathedral slot (SiteData row 1) is 240 x 315 at (0, 57.5): x -120..120, z -100..215; BuildCheck allows the model 10 percent of the
-- full extent beyond it on each side (x -144..144, z -131.5..246.5). No road may enter the slot, and no road may enter the margin zone
-- except the three that START at the compound's edge: A (north edge, (0,-100)), C (east edge, (120,0)) and E (south edge, (0,225)).
do
	local c = SiteData.byId(1)
	local slot = { x0 = c.pos.X - c.size.X / 2, x1 = c.pos.X + c.size.X / 2, z0 = c.pos.Z - c.size.Y / 2, z1 = c.pos.Z + c.size.Y / 2 }
	local zone = expand(slot, 0.1 * c.size.X, 0.1 * c.size.Y)
	check("Cathedral slot is x -120..120, z -100..215", slot.x0 == -120 and slot.x1 == 120 and slot.z0 == -100 and slot.z1 == 215,
		string.format("x[%.1f,%.1f] z[%.1f,%.1f]", slot.x0, slot.x1, slot.z0, slot.z1))
	local EDGE_STARTS = { A_to_Carmel = true, C_to_Farm = true, E_to_Tagbakin = true }
	-- the road body without end caps (the sides are w/2; the ends are the segment ends)
	local function body(a, b, w)
		if a[1] == b[1] then return { x0 = a[1] - w / 2, x1 = a[1] + w / 2, z0 = math.min(a[2], b[2]), z1 = math.max(a[2], b[2]) } end
		return { x0 = math.min(a[1], b[1]), x1 = math.max(a[1], b[1]), z0 = a[2] - w / 2, z1 = a[2] + w / 2 }
	end
	for _, road in ipairs(all) do
		for i = 1, #road.pts - 1 do
			local r = body(road.pts[i], road.pts[i + 1], road.w)
			check(road.name .. " seg " .. i .. " (centre line and both edges) stays out of the Cathedral slot", not overlap(r, slot),
				string.format("road x[%.0f,%.0f] z[%.0f,%.0f]", r.x0, r.x1, r.z0, r.z1))
			-- B3c-0b exception (briefs/site01.md "B3c-0b roads"): the two entrance roads must cross x 128..144 to reach the side stairs; they
			-- are still checked against the slot above and in section 7 (|x| >= 128, no contact with the treads).
			if not (EDGE_STARTS[road.name] and i == 1) and not ENTRY_ROADS[road.name] then
				check(road.name .. " seg " .. i .. " stays out of the slot's 10 percent margin zone", not overlap(r, zone),
					string.format("road x[%.0f,%.0f] z[%.0f,%.0f] vs zone x[%.1f,%.1f] z[%.1f,%.1f]", r.x0, r.x1, r.z0, r.z1, zone.x0, zone.x1, zone.z0, zone.z1))
			end
		end
	end
	local byName = {}
	for _, r in ipairs(all) do byName[r.name] = r end
	local e, f, g = byName.E_to_Tagbakin, byName.F_to_Market, byName.G_to_Lomi
	check("Road A starts flush on the slot's north edge (0,-100)", byName.A_to_Carmel.pts[1][1] == 0 and byName.A_to_Carmel.pts[1][2] == slot.z0)
	check("Road E starts on the slot's south edge side: (0, 225), 10 studs south of the slot", e.pts[1][1] == 0 and e.pts[1][2] == slot.z1 + 10,
		e.pts[1][1] .. "," .. e.pts[1][2])
	local wb, eb = byName.WEST_BYPASS, byName.EAST_BYPASS
	check("Road F starts at the west bypass end (-170,160) and runs west to (-228,160)", f.pts[1][1] == wb.pts[#wb.pts][1] and f.pts[1][2] == wb.pts[#wb.pts][2]
		and f.pts[1][1] == -170 and f.pts[2][1] == -228 and f.pts[2][2] == 160, f.pts[1][1] .. "," .. f.pts[1][2])
	check("Road G starts at the east bypass end (165,140) and runs east to (240,140)", g.pts[1][1] == eb.pts[#eb.pts][1] and g.pts[1][2] == eb.pts[#eb.pts][2]
		and g.pts[1][1] == 165 and g.pts[2][1] == 240 and g.pts[2][2] == 140, g.pts[1][1] .. "," .. g.pts[1][2])
	-- the south links join each bypass to Road E (the only way the Market, Lomi King and Tagbakin sides of the graph connect to Road E now)
	for _, nm in ipairs({ "WEST_LINK", "EAST_LINK" }) do
		local l = byName[nm]
		check(nm .. " exists and is 12 wide", l ~= nil and l.w == 12)
		if l then
			local last = l.pts[#l.pts]
			check(nm .. " ends on Road E", onRoad(last, { e }, nil) == "E_to_Tagbakin", last[1] .. "," .. last[2])
			check(nm .. " starts on a bypass end", onRoad(l.pts[1], { wb, eb }, nil) ~= nil, l.pts[1][1] .. "," .. l.pts[1][2])
		end
	end
	-- Road E must be connected to the rest of the network: the Tagbakin Guide is reachable from the spawn (checked in section 4 too)
	if spawn then
		local dist = shortest(buildGraph(all, attachments()), "spawn")
		check("spawn reaches the Tagbakin Guide over the roads", dist["guide:Site09_Tagbakin"] ~= nil)
		table.insert(results.info, "graph spawn -> Site09_Tagbakin: " .. (dist["guide:Site09_Tagbakin"] and fmt(dist["guide:Site09_Tagbakin"]) or "unreachable"))
	end
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
	-- Owner decision 2026-10-29: grass blades poked through the steps, plaza and terraces of City Hall, so the whole site ground is repainted Concrete.
	-- Light concrete (152,152,152) is a neutral grey like the drawing's plaza. Sampled over the whole footprint on the 4-stud grid (the model's real bounds are x -322..-150, z -446..-188).
	local pts = {
		{ -320, -444 }, { -152, -444 }, { -300, -420 }, { -260, -400 }, { -200, -440 }, -- north wing and its ends
		{ -300, -300 }, { -250, -330 }, { -250, -260 }, { -300, -224 },                 -- long wing front and rear
		{ -200, -380 }, { -220, -340 }, { -216, -344 },                                 -- atrium and canopy area
		{ -200, -320 }, { -190, -300 }, { -224, -300 },                                 -- steps and terraces
		{ -170, -300 }, { -190, -260 }, { -176, -228 },                                 -- loop and island
		{ -224, -328 }, { -224, -196 }, { -176, -196 },                                 -- old forecourt strip
		{ -320, -196 }, { -280, -196 },                                                 -- parking
		{ -152, -330 }, { -152, -270 },                                                 -- tree row on the east edge
	}
	local bad = {}
	for _, p in ipairs(pts) do
		if cellMaterial(p[1], p[2]) ~= Enum.Material.Concrete then table.insert(bad, string.format("(%d,%d)=%s", p[1], p[2], cellMaterial(p[1], p[2]).Name)) end
	end
	check("City Hall ground (x -324..-148, z -448..-188) is Concrete at " .. #pts .. " sample points", #bad == 0, #bad .. " not concrete: " .. table.concat(bad, " ", 1, math.min(#bad, 3)))
	-- Control: the repaint must not spill. These cells sit just outside the region and read Grass today.
	local spill = {}
	for _, p in ipairs({ { -332, -300 }, { -300, -452 }, { -300, -184 }, { -146, -300 } }) do
		if cellMaterial(p[1], p[2]) ~= Enum.Material.Grass then table.insert(spill, string.format("(%d,%d)=%s", p[1], p[2], cellMaterial(p[1], p[2]).Name)) end
	end
	check("control: the cells just outside the repainted ground are still Grass", #spill == 0, table.concat(spill, " "))
end

-- 6a. The Market ground (Slice 4, owner decision 2026-10-29): the whole Market slot x -576..-228, z -5..325 is repainted Concrete (the model is a BP1 market; grass blades and the old
-- Pavement must not show). Samples sit at least 4 studs inside the slot (cells are 4-stud floored) and at x -232 or less on the east side (Road F's asphalt ends at x -228; the cell at
-- (-232,160) read Pavement before the repaint). They cover the old Pavement area (x -376..-228, z 80..240) and the old grass area. Controls: Grass just outside, Road F asphalt at (-224,160).
do
	local pts = {
		{ -572, -1 }, { -232, -1 }, { -572, 321 }, { -232, 321 }, -- the four corner cells
		{ -400, -1 }, { -400, 321 }, { -572, 160 }, { -500, 160 }, -- north and south edges, west edge, west of the old Market
		{ -540, 60 }, { -540, 260 }, { -450, 30 }, { -450, 300 }, { -520, 100 }, { -520, 220 }, -- Bagsakan, truck lane, side yards
		{ -440, 130 }, { -440, 200 }, { -400, 100 }, { -400, 230 }, { -380, 160 }, -- sheds and the old grass area
		{ -340, 120 }, { -340, 200 }, { -300, 78 }, { -300, 242 }, { -300, 160 }, -- wet markets, front arcade, old grass beside the Pavement
		{ -374, 82 }, { -270, 200 }, { -232, 238 }, { -232, 82 }, { -232, 160 }, { -232, 140 }, -- old Pavement area, forecourt, Road F mouth
	}
	local bad = {}
	for _, p in ipairs(pts) do
		if cellMaterial(p[1], p[2]) ~= Enum.Material.Concrete then table.insert(bad, string.format("(%d,%d)=%s", p[1], p[2], cellMaterial(p[1], p[2]).Name)) end
	end
	check("Market ground (x -576..-228, z -5..325) is Concrete at " .. #pts .. " sample points", #bad == 0, #bad .. " not concrete: " .. table.concat(bad, " ", 1, math.min(#bad, 3)))
	local spill = {}
	-- East controls moved from x -224 to x -212 (owner decision 2026-10-30): x -228..-216 is now the front street (section 6d), so the Grass beside Road F starts at x -216.
	-- North and south controls moved the same day (section 6e): (-400,-12) is now the north side street and (-300,332) the repainted south verge, so they became (-400,-24) and (-300,360).
	for _, p in ipairs({ { -580, 160 }, { -590, 160 }, { -400, -24 }, { -300, 360 }, { -212, 170 }, { -212, 150 } }) do
		if cellMaterial(p[1], p[2]) ~= Enum.Material.Grass then table.insert(spill, string.format("(%d,%d)=%s", p[1], p[2], cellMaterial(p[1], p[2]).Name)) end
	end
	check("control: the cells just outside the Market slot (west, north, south, and east of the front street beside Road F) are still Grass", #spill == 0, table.concat(spill, " "))
	check("control: Road F's asphalt end at (-224,160) is still Asphalt", cellMaterial(-224, 160) == Enum.Material.Asphalt, cellMaterial(-224, 160).Name)
end

-- 6b. The stretched Cathedral plaza (Slice 4 B3c-1): the ground under x -100..100, z 100..200 is repainted Pavement (builders/roads_extra.luau PAVED). Sampled OFF the old Road E
-- asphalt strip (x -6..6), which stays Asphalt: ReplaceMaterial Grass -> Pavement leaves it alone (the ForecourtPaving part covers it).
do
	local bad = {}
	for _, p in ipairs({ { -60, 120 }, { 60, 150 }, { -90, 190 }, { 90, 120 }, { -40, 190 }, { 40, 190 } }) do
		if cellMaterial(p[1], p[2]) ~= Enum.Material.Pavement then table.insert(bad, string.format("(%d,%d)=%s", p[1], p[2], cellMaterial(p[1], p[2]).Name)) end
	end
	check("B3c-1 Cathedral plaza ground (x -100..100, z 100..200) is Pavement at 6 points off the old Road E strip", #bad == 0, #bad .. " not pavement: " .. table.concat(bad, " ", 1, math.min(#bad, 3)))
	local spill = {}
	for _, p in ipairs({ { -108, 150 }, { 108, 150 }, { -60, 208 } }) do
		if cellMaterial(p[1], p[2]) == Enum.Material.Pavement then table.insert(spill, string.format("(%d,%d)", p[1], p[2])) end
	end
	check("B3c-1 control: the cells just outside the repainted plaza ground are not Pavement", #spill == 0, table.concat(spill, " "))
end

-- 6c. The Credits Plaza (Slice 4): CreditsPaving x 24..150, z 274..346 and EntryPath x 6..24, z 306..314 stand on terrain that builders/roads_extra.luau PAVED repaints Grass -> Pavement
-- (x 24..152, z 272..348 and x 4..24, z 304..316), so no grass blades show through the floor. Road E's asphalt at x 2 is not touched (ReplaceMaterial only swaps Grass).
do
	local function notMat(points, mat)
		local bad = {}
		for _, p in ipairs(points) do
			if cellMaterial(p[1], p[2]) ~= mat then table.insert(bad, string.format("(%d,%d)=%s", p[1], p[2], cellMaterial(p[1], p[2]).Name)) end
		end
		return bad
	end
	local plaza = notMat({ { 30, 280 }, { 90, 310 }, { 140, 340 }, { 60, 340 }, { 120, 285 }, { 36, 330 } }, Enum.Material.Pavement)
	check("Credits Plaza ground (x 24..152, z 272..348) is Pavement at 6 points", #plaza == 0, #plaza .. " not pavement: " .. table.concat(plaza, " ", 1, math.min(#plaza, 3)))
	local entry = notMat({ { 10, 310 }, { 18, 310 } }, Enum.Material.Pavement)
	check("Credits EntryPath ground (x 4..24, z 304..316) is Pavement at 2 points", #entry == 0, #entry .. " not pavement: " .. table.concat(entry, " ", 1, math.min(#entry, 3)))
	local south = notMat({ { 40, 360 } }, Enum.Material.Grass)
	check("control: the cell just south of the Credits Plaza repaint (40,360) is still Grass", #south == 0, table.concat(south, " "))
	local road = notMat({ { 2, 310 } }, Enum.Material.Asphalt)
	check("control: Road E asphalt at (2,310) beside the EntryPath is still Asphalt", #road == 0, table.concat(road, " "))
end

-- 6d. The Market front street (owner decision 2026-10-30, handoff 048): terrain only, Asphalt x -228..-216, z -8..328 (builders/roads_extra.luau STREET), with two zebra crossings at the
-- stair feet, z 88..96 and z 224..232 (ZEBRA): white (Salt) bars at x -228..-224 and x -220..-216, Asphalt between. It is not a RoadData.NEW_ROADS entry (that would break the margin rule).
-- Cells are 4-stud floored. The bars were Concrete at first and the west one merged with the Market's Concrete; owner "do what you think is best" 2026-10-30, so they are Salt (near white,
-- like a painted zebra) and read against both the Asphalt and the Concrete. Terrain only: no SetMaterialColor, which would change a place setting.
do
	local function notMat(points, mat)
		local bad = {}
		for _, p in ipairs(points) do
			if cellMaterial(p[1], p[2]) ~= mat then table.insert(bad, string.format("(%d,%d)=%s", p[1], p[2], cellMaterial(p[1], p[2]).Name)) end
		end
		return bad
	end
	local street = notMat({
		{ -222, 0 }, { -222, 40 }, { -222, 100 }, { -222, 200 }, { -222, 260 }, { -222, 320 }, -- centre of the street along its length
		{ -226, 40 }, { -218, 40 }, { -226, 260 }, { -218, 260 },                             -- both edges
	}, Enum.Material.Asphalt)
	check("Market front street (x -228..-216, z -8..328) is Asphalt at 10 points", #street == 0, #street .. " not asphalt: " .. table.concat(street, " ", 1, math.min(#street, 3)))
	local bars = notMat({ { -226, 92 }, { -218, 92 }, { -226, 228 }, { -218, 228 } }, Enum.Material.Salt)
	local gaps = notMat({ { -222, 92 }, { -222, 228 } }, Enum.Material.Asphalt)
	check("Market front street zebra crossings (z 88..96, z 224..232): Salt bars at x -226 and -218, Asphalt between", #bars == 0 and #gaps == 0,
		#bars .. " bars wrong, " .. #gaps .. " gaps wrong: " .. table.concat(bars, " ", 1, math.min(#bars, 2)) .. " " .. table.concat(gaps, " ", 1, math.min(#gaps, 2)))
	-- The end controls changed when 6e was added (owner "yes, both" 2026-10-30, south revised the same day): the north end is now the north side street (so the control moved from z -12 to z -24),
	-- and the south end joins the existing road at z 344 (so the control moved from (-222,332) to the cell east of the extension, (-212,334)).
	local spill = notMat({ { -212, 100 }, { -212, 200 }, { -222, -24 }, { -212, 334 } }, Enum.Material.Grass)
	check("control: the cells just east of the front street and beyond its north side street are still Grass", #spill == 0, table.concat(spill, " "))
end

-- 6e. The Market side streets (owner decision 2026-10-30): terrain only (builders/roads_extra.luau SIDE_STREETS, STREET_SOUTH, VERGE_SOUTH).
-- North: Asphalt 12 wide just outside the slot, x -576..-216, z -20..-8, meeting the front street's north end.
-- South: an Asphalt road already runs along z 344..356 (east of x -480), 16 studs south of the Market, so there is no new south street (owner chose "use the existing road"): the front street
-- is extended south (x -228..-216, z 328..344) to T into it, and the Grass strip z 328..344 (x -576..-228) is repainted Concrete so the Market ground meets that road flush, like the front.
-- All of it stays outside the slot (z -5..325 widened to -8..328), so the Market Concrete is unchanged.
do
	local function notMat(points, mat)
		local bad = {}
		for _, p in ipairs(points) do
			if cellMaterial(p[1], p[2]) ~= mat then table.insert(bad, string.format("(%d,%d)=%s", p[1], p[2], cellMaterial(p[1], p[2]).Name)) end
		end
		return bad
	end
	local north = notMat({
		{ -560, -14 }, { -400, -14 }, { -240, -14 }, { -222, -14 }, -- north street, centre line, joining the front street
		{ -400, -18 }, { -400, -10 },                               -- its two edges
	}, Enum.Material.Asphalt)
	check("Market north side street (x -576..-216, z -20..-8) is Asphalt at 6 points", #north == 0, #north .. " not asphalt: " .. table.concat(north, " ", 1, math.min(#north, 3)))
	local south = notMat({
		{ -222, 330 }, { -222, 338 }, { -222, 342 }, -- the front street extended south to the existing road
		{ -226, 336 }, { -218, 336 },                -- both edges of the extension
		{ -400, 348 }, { -222, 348 },                -- the existing road at z 344..356 is still Asphalt
	}, Enum.Material.Asphalt)
	check("Market front street reaches the existing south road: Asphalt at x -228..-216, z 328..344 and the road beyond", #south == 0, #south .. " not asphalt: " .. table.concat(south, " ", 1, math.min(#south, 3)))
	local verge = notMat({ { -400, 330 }, { -400, 342 }, { -560, 334 }, { -300, 334 }, { -480, 338 }, { -232, 334 } }, Enum.Material.Concrete)
	check("Market south verge (x -576..-228, z 328..344) is Concrete at 6 points", #verge == 0, #verge .. " not concrete: " .. table.concat(verge, " ", 1, math.min(#verge, 3)))
	local grass = notMat({ { -400, -22 }, { -580, -14 }, { -212, -14 }, { -580, 334 }, { -212, 334 }, { -300, 360 } }, Enum.Material.Grass)
	check("control: the cells just outside the new ground (north of the north street, west of x -576, east of x -216, south of the existing road) are still Grass", #grass == 0, table.concat(grass, " "))
	local edge = notMat({ { -400, -6 }, { -400, 326 }, { -300, -6 }, { -300, 326 } }, Enum.Material.Concrete)
	check("control: the Market Concrete edge rows just inside the slot (z -6 and z 326) are still Concrete, not Asphalt", #edge == 0, table.concat(edge, " "))
end

-- 6f. The Lomi King ground (owner decision, Site 3 growth 100 x 80 -> 100 x 110): the slot is x 242..342, z 85..195 and the whole ground x 240..344, z 84..196 is repainted Concrete
-- (today it is Grass, with Pavement at the old shop forecourt). Samples sit at least 4 studs inside the region on the 4-stud grid. Controls: Road G's asphalt mouth west of the region
-- ((232,140) and (236,140) read Asphalt today; (240,140) reads Pavement today and is inside the region, so it is NOT an Asphalt control) and Grass just outside on the other three sides.
do
	local bad = {}
	local pts = {
		{ 250, 90 }, { 250, 190 }, { 292, 90 }, { 292, 190 }, { 340, 90 }, { 340, 190 }, -- the six edge cells north and south
		{ 292, 120 }, { 292, 160 },                                                      -- the old shop forecourt (Pavement today)
	}
	for _, p in ipairs(pts) do
		if cellMaterial(p[1], p[2]) ~= Enum.Material.Concrete then table.insert(bad, string.format("(%d,%d)=%s", p[1], p[2], cellMaterial(p[1], p[2]).Name)) end
	end
	check("Lomi King ground (x 240..344, z 84..196) is Concrete at " .. #pts .. " sample points", #bad == 0, #bad .. " not concrete: " .. table.concat(bad, " ", 1, math.min(#bad, 3)))
	local road = {}
	for _, p in ipairs({ { 232, 140 }, { 236, 140 } }) do
		if cellMaterial(p[1], p[2]) ~= Enum.Material.Asphalt then table.insert(road, string.format("(%d,%d)=%s", p[1], p[2], cellMaterial(p[1], p[2]).Name)) end
	end
	check("control: Road G's asphalt mouth west of the Lomi King ground at (232,140) and (236,140) is still Asphalt", #road == 0, table.concat(road, " "))
	local spill = {}
	for _, p in ipairs({ { 360, 140 }, { 292, 76 }, { 292, 204 } }) do
		if cellMaterial(p[1], p[2]) ~= Enum.Material.Grass then table.insert(spill, string.format("(%d,%d)=%s", p[1], p[2], cellMaterial(p[1], p[2]).Name)) end
	end
	check("control: the cells just outside the Lomi King ground (east, north, south) are still Grass", #spill == 0, table.concat(spill, " "))
end

-- 7. Entrance roads to the Cathedral side stairs (Slice 4 B3c-0b, owner markup) ---------------------------------------------------
-- WEST_ENTRY / EAST_ENTRY run from each bypass centre line straight along the stairs' centre z to the foot of SideStairsW / SideStairsE
-- (the lowest tread is the part with the largest |x|; its outer edge is the foot). They are the only roads allowed inside the slot's 10 percent
-- margin zone besides the edge starts of A, C and E (see section 6); they must stay out of the slot itself and must not touch the treads.
do
	local byName = {}
	for _, r in ipairs(all) do byName[r.name] = r end
	local cathModel = sites and sites:FindFirstChild("Site01_Cathedral")
	local treads, lowest = {}, {}
	if cathModel then
		for _, d in ipairs(cathModel:GetDescendants()) do
			if d:IsA("BasePart") and (d.Name == "SideStairsW" or d.Name == "SideStairsE") then
				table.insert(treads, d)
				local cur = lowest[d.Name]
				if cur == nil or math.abs(d.Position.X) > math.abs(cur.Position.X) then lowest[d.Name] = d end
			end
		end
	end
	check("B3c-0b: the Cathedral has SideStairs treads on both sides", #treads >= 2 and lowest.SideStairsW ~= nil and lowest.SideStairsE ~= nil, tostring(#treads))
	local function entryBody(a, b, w) -- road body without end caps (axis-aligned)
		if a[1] == b[1] then return { x0 = a[1] - w / 2, x1 = a[1] + w / 2, z0 = math.min(a[2], b[2]), z1 = math.max(a[2], b[2]) } end
		return { x0 = math.min(a[1], b[1]), x1 = math.max(a[1], b[1]), z0 = a[2] - w / 2, z1 = a[2] + w / 2 }
	end
	local specs = {
		{ stair = "SideStairsW", road = "WEST_ENTRY", bypass = "WEST_BYPASS", bx = -170, mid = -149, sign = -1 },
		{ stair = "SideStairsE", road = "EAST_ENTRY", bypass = "EAST_BYPASS", bx = 165, mid = 146, sign = 1 },
	}
	for _, s in ipairs(specs) do
		local st, road, bypass = lowest[s.stair], byName[s.road], byName[s.bypass]
		check("B3c-0b: " .. s.road .. " exists and is 12 wide", road ~= nil and road.w == 12)
		if st and road and bypass then
			local foot = math.abs(st.Position.X) + st.Size.X / 2 -- outer edge of the lowest tread
			local first, last = road.pts[1], road.pts[#road.pts]
			check("B3c-0b: " .. s.stair .. " foot is at |x| 128", foot == 128, fmt(foot))
			check("B3c-0b: " .. s.road .. " ends at the foot of " .. s.stair .. " (x within 1 stud of |x| 128, same side)",
				last[1] * s.sign > 0 and math.abs(math.abs(last[1]) - foot) <= 1, last[1] .. "," .. last[2])
			check("B3c-0b: " .. s.road .. " ends on the stair's centre z (within 1 stud of " .. fmt(st.Position.Z) .. ")", math.abs(last[2] - st.Position.Z) <= 1, last[1] .. "," .. last[2])
			check("B3c-0b: " .. s.road .. " starts on the " .. s.bypass .. " centre line (x " .. s.bx .. ")", first[1] == s.bx and onRoad(first, { bypass }, nil) == s.bypass, first[1] .. "," .. first[2])
			local axis = true
			for i = 1, #road.pts - 1 do
				if road.pts[i][1] ~= road.pts[i + 1][1] and road.pts[i][2] ~= road.pts[i + 1][2] then axis = false end
			end
			check("B3c-0b: " .. s.road .. " is axis-aligned and runs straight (one z) from the bypass to the stair", axis and first[2] == last[2] and #road.pts == 2)
			-- the narrow exception to section 6: out of the slot itself, and the end must not touch the treads
			local inSlot = false
			for i = 1, #road.pts - 1 do
				local r = entryBody(road.pts[i], road.pts[i + 1], road.w)
				if r.x0 < 128 and r.x1 > -128 then inSlot = true end -- the body overlaps x -128..128
			end
			check("B3c-0b: " .. s.road .. " stays out of the Cathedral slot (every point at |x| >= 128)", not inSlot)
			local touch = {}
			for i = 1, #road.pts - 1 do
				local r = entryBody(road.pts[i], road.pts[i + 1], road.w)
				for _, t in ipairs(treads) do
					if overlap(r, partRect(t)) then table.insert(touch, t.Name .. "@" .. fmt(t.Position.X)) end
				end
			end
			check("B3c-0b: " .. s.road .. " does not touch any stair tread", #touch == 0, table.concat(touch, ", "))
			-- the asphalt is really there
			local sample = {}
			for _, x in ipairs({ s.mid, s.sign * 129 }) do
				local m = cellMaterial(x, st.Position.Z)
				if m ~= Enum.Material.Asphalt then table.insert(sample, string.format("(%d,%d)=%s", x, st.Position.Z, m.Name)) end
			end
			check("B3c-0b: " .. s.road .. " is Asphalt terrain at its mid-point (x " .. s.mid .. ") and at |x| 129 on z 26", #sample == 0, table.concat(sample, " "))
		else
			check("B3c-0b: " .. s.road .. " can be checked (stair, road and bypass found)", false, tostring(st) .. " " .. tostring(road) .. " " .. tostring(bypass))
		end
	end
end

-- Credits job B (2026-10-27): the CreditsBoard stands in the Credits Plaza (x 24..150, z 274..346), east of Road E. Every road body (centre line widened by
-- width / 2 + 4, the margin rule of section 1) must stay clear of every board part, so no panel, post, bench or lamp stands on or beside a road. The one
-- allowed contact is the EntryPath ground strip (a part named EntryPath* whose top is at y <= 0.3) that links Road E's east edge (x 6) to the plaza.
do
	local board = workspace:FindFirstChild("World") and workspace.World:FindFirstChild("CreditsBoard")
	local near = {}
	if board then
		for _, road in ipairs(RoadData.all()) do
			for i = 1, #road.pts - 1 do
				local wide = segRect(road.pts[i], road.pts[i + 1], road.w / 2 + 4)
				for _, d in ipairs(board:GetDescendants()) do
					if d:IsA("BasePart") and not (string.match(d.Name, "^EntryPath") and d.Position.Y + d.Size.Y / 2 <= 0.3) and overlap(wide, partRect(d)) then
						table.insert(near, d.Name .. "@" .. road.name)
					end
				end
			end
		end
	end
	check("Credits Plaza: no CreditsBoard part (EntryPath ground strip excepted) is within 4 studs of any road body", board ~= nil and #near == 0,
		board and table.concat(near, ", ", 1, math.min(#near, 4)) or "CreditsBoard missing")
end

return HttpService:JSONEncode(results)
