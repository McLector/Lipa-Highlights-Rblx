-- filler_check: guards the city filler (builders/filler.luau, Workspace.World.CityFill), the haze, the golden-hour light and the music
-- (builders/mood.luau). Studio copy: ServerStorage.Checks.filler_check.
-- Run in Edit mode: require(game.ServerStorage.Checks.filler_check:Clone())  -- returns JSON {passed, failed, failures}
-- Why (owner, 2026-10-31): generic town buildings line the outer roads so the far sites stay hidden until a player arrives, and a light haze
-- fades what is still in view. The filler must never touch a site (footprint + 10 percent, the BuildCheck box, plus 24), a road body
-- (half width + 3), the core town where the walking routes run (x -600..360, z -330..352), or the world edge (+-980). Fourth round (more town):
-- nor the reserved land (future Outlets and Farm slots, Malarayat's new entrance), with 12 studs clear of the road edges for new buildings.
local HttpService = game:GetService("HttpService")
local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
local RoadData = require(game.ReplicatedStorage.LipaShared.RoadData:Clone())
local BuildCheck = require(game.ServerStorage.BuildCheck:Clone())

local results = { passed = 0, failed = 0, failures = {} }
local function check(name, cond, detail)
	if cond then
		results.passed += 1
	else
		results.failed += 1
		table.insert(results.failures, name .. (detail and (" | " .. detail) or ""))
	end
end

local CORE = { x0 = -600, x1 = 360, z0 = -330, z1 = 352 }
local SITE_MARGIN, ROAD_CLEAR, EDGE = 24, 3, 980

local fill = workspace:FindFirstChild("World") and workspace.World:FindFirstChild("CityFill")
check("Workspace.World.CityFill exists", fill ~= nil)

local parts = {}
if fill then
	for _, d in ipairs(fill:GetDescendants()) do
		if d:IsA("BasePart") then table.insert(parts, d) end
	end
end
check("CityFill holds 1500..5000 parts", #parts >= 1500 and #parts <= 5000, #parts .. " parts")

local buildings = 0
if fill then
	for _, c in ipairs(fill:GetChildren()) do
		if c:IsA("Model") and c:FindFirstChild("Body") then buildings += 1 end
	end
end
-- Owner, 2026-10-31 (second round): more buildings, three rows deep.
check("CityFill has 220 or more buildings, each a Model with a Body", buildings >= 220, buildings .. " buildings")

-- Site boxes: the footprint + 10 percent (BuildCheck's rule) plus SITE_MARGIN.
local siteBoxes = {}
for _, s in ipairs(SiteData.sites) do
	local hx, hz = s.size.X / 2 * 1.1 + SITE_MARGIN, s.size.Y / 2 * 1.1 + SITE_MARGIN
	table.insert(siteBoxes, { key = s.key, x0 = s.pos.X - hx, x1 = s.pos.X + hx, z0 = s.pos.Z - hz, z1 = s.pos.Z + hz })
end
local segs = {}
for _, r in ipairs(RoadData.all()) do
	for i = 1, #r.pts - 1 do
		table.insert(segs, { name = r.name, a = r.pts[i], b = r.pts[i + 1], clear = r.w / 2 + ROAD_CLEAR })
	end
end
local function segDist(px, pz, a, b)
	local ax, az, bx, bz = a[1], a[2], b[1], b[2]
	local dx, dz = bx - ax, bz - az
	local t = ((px - ax) * dx + (pz - az) * dz) / (dx * dx + dz * dz)
	t = math.clamp(t, 0, 1)
	local cx, cz = ax + t * dx - px, az + t * dz - pz
	return math.sqrt(cx * cx + cz * cz)
end
local function overlaps(b, x0, x1, z0, z1)
	return x0 < b.x1 and x1 > b.x0 and z0 < b.z1 and z1 > b.z0
end

local inSite, inCore, onRoad, offEdge, loose, scripted = {}, {}, {}, {}, {}, {}
for i, p in ipairs(parts) do
	local half = p.Size / 2
	local cf = p.CFrame
	-- world xz extent of the rotated box
	local ex = math.abs(cf.RightVector.X) * half.X + math.abs(cf.UpVector.X) * half.Y + math.abs(cf.LookVector.X) * half.Z
	local ez = math.abs(cf.RightVector.Z) * half.X + math.abs(cf.UpVector.Z) * half.Y + math.abs(cf.LookVector.Z) * half.Z
	local x0, x1, z0, z1 = p.Position.X - ex, p.Position.X + ex, p.Position.Z - ez, p.Position.Z + ez
	for _, b in ipairs(siteBoxes) do
		if overlaps(b, x0, x1, z0, z1) then table.insert(inSite, p:GetFullName() .. " in " .. b.key) break end
	end
	if overlaps(CORE, x0, x1, z0, z1) then table.insert(inCore, p:GetFullName()) end
	if math.max(math.abs(x0), math.abs(x1), math.abs(z0), math.abs(z1)) > EDGE then table.insert(offEdge, p:GetFullName()) end
	-- road bodies: sample the part's xz box every 3 studs
	local nx, nz = math.max(1, math.ceil((x1 - x0) / 3)), math.max(1, math.ceil((z1 - z0) / 3))
	local hit = nil
	for ix = 0, nx do
		for iz = 0, nz do
			local px, pz = x0 + (x1 - x0) * ix / nx, z0 + (z1 - z0) * iz / nz
			for _, s in ipairs(segs) do
				if segDist(px, pz, s.a, s.b) < s.clear then hit = s.name break end
			end
			if hit then break end
		end
		if hit then break end
	end
	if hit then table.insert(onRoad, p:GetFullName() .. " on " .. hit) end
	if not p.Anchored then table.insert(loose, p:GetFullName()) end
	if i % 200 == 0 then task.wait() end
end
local function list(t) return #t .. ": " .. table.concat(t, ", ", 1, math.min(#t, 4)) end
check("no filler part inside a site box (footprint + 10 percent + 24)", #inSite == 0, list(inSite))
check("no filler part in the core town box", #inCore == 0, list(inCore))
check("no filler part on a road body (half width + 3)", #onRoad == 0, list(onRoad))
check("no filler part beyond +-980", #offEdge == 0, list(offEdge))
check("every filler part is anchored", #loose == 0, list(loose))

if fill then
	for _, d in ipairs(fill:GetDescendants()) do
		if d:IsA("LuaSourceContainer") or d:IsA("SurfaceGui") or d:IsA("Decal") or d:IsA("Texture") or d:IsA("BillboardGui") then
			table.insert(scripted, d:GetFullName())
		end
	end
end
check("no scripts, text or images in the filler", #scripted == 0, list(scripted))

-- Human scale: every door is at least 8 studs tall.
local shortDoors, doors = {}, 0
for _, p in ipairs(parts) do
	if p.Name == "Door" then
		doors += 1
		if p.Size.Y < 8 then table.insert(shortDoors, p:GetFullName()) end
	end
end
check("every building has a door 8 or more studs tall", doors >= buildings and #shortDoors == 0, doors .. " doors, short " .. list(shortDoors))

-- The building stands on its lot: the Body's bottom is within 0.05 of its Lot's top.
local floating = {}
if fill then
	for _, m in ipairs(fill:GetChildren()) do
		local body, lot = m:FindFirstChild("Body"), m:FindFirstChild("Lot")
		if body and lot then
			local gap = (body.Position.Y - body.Size.Y / 2) - (lot.Position.Y + lot.Size.Y / 2)
			if math.abs(gap) > 0.05 then table.insert(floating, m.Name .. string.format(" %.2f", gap)) end
		elseif m:IsA("Model") then
			table.insert(floating, m.Name .. " no Body/Lot")
		end
	end
end
check("every Body stands on its Lot", #floating == 0, list(floating))

-- The world budget (BuildCheck's 20000 cap).
local w = BuildCheck.checkWorld()
check("world part budget holds with the filler", w.failed == 0, w.parts .. " parts")

-- Pavement (owner, second round: "concrete pavements like a road"): the lots tile the street edge with no grass gaps. Every 8 studs along
-- each side of every road, 7 studs out from the road edge, a point that lies outside the core, the site boxes and every road body must
-- have a concrete Lot under it; at least 75 percent of them (slopes over 5 studs and water stay bare).
if fill then
	local lp = RaycastParams.new()
	lp.FilterType = Enum.RaycastFilterType.Include
	lp.FilterDescendantsInstances = { fill, workspace.Terrain }
	local eligible, covered = 0, 0
	-- Ground (owner, third round: "repaint under the town"): where a Lot stands at the street edge, the terrain under it and on the verge
	-- between the road body and the sidewalk (2 studs out from the road edge) is no longer Grass, so no grass blades show in the town.
	local tp = RaycastParams.new()
	tp.FilterType = Enum.RaycastFilterType.Include
	tp.FilterDescendantsInstances = { workspace.Terrain }
	local groundPts, grassPts = 0, {}
	local function terrainMat(px, pz)
		local r = workspace:Raycast(Vector3.new(px, 400, pz), Vector3.new(0, -800, 0), tp)
		return r and r.Material
	end
	local function free(px, pz)
		if px < -EDGE or px > EDGE or pz < -EDGE or pz > EDGE then return false end
		if px > CORE.x0 - 4 and px < CORE.x1 + 4 and pz > CORE.z0 - 4 and pz < CORE.z1 + 4 then return false end
		for _, b in ipairs(siteBoxes) do
			if px > b.x0 - 4 and px < b.x1 + 4 and pz > b.z0 - 4 and pz < b.z1 + 4 then return false end
		end
		for _, s in ipairs(segs) do
			if segDist(px, pz, s.a, s.b) < s.clear + 2 then return false end
		end
		return true
	end
	for _, s in ipairs(segs) do
		local ax, az, bx, bz = s.a[1], s.a[2], s.b[1], s.b[2]
		local L = math.sqrt((bx - ax) ^ 2 + (bz - az) ^ 2)
		local ux, uz = (bx - ax) / L, (bz - az) / L
		for _, side in ipairs({ 1, -1 }) do
			local nx, nz = -uz * side, ux * side
			local off = s.clear - ROAD_CLEAR + 7
			for t = 16, L - 16, 8 do
				local px, pz = ax + ux * t + nx * off, az + uz * t + nz * off
				if free(px, pz) then
					local r = workspace:Raycast(Vector3.new(px, 400, pz), Vector3.new(0, -800, 0), lp)
					if r and not (r.Instance == workspace.Terrain and r.Material == Enum.Material.Water) then
						eligible += 1
						if r.Instance.Name == "Lot" then
							covered += 1
							local vx, vz = ax + ux * t + nx * (off - 5), az + uz * t + nz * (off - 5)
							for _, q in ipairs({ { px, pz }, { vx, vz } }) do
								groundPts += 1
								if terrainMat(q[1], q[2]) == Enum.Material.Grass then
									table.insert(grassPts, string.format("(%.0f,%.0f)", q[1], q[2]))
								end
							end
						end
					end
				end
			end
		end
	end
	check("street edges are paved: 75 percent or more of the free road-edge points stand on a Lot", eligible > 0 and covered >= eligible * 0.75,
		covered .. " of " .. eligible)
	check("no Grass under the street-edge Lots or on the verge beside them", groundPts > 0 and #grassPts == 0,
		#grassPts .. " of " .. groundPts .. " grass: " .. table.concat(grassPts, " ", 1, math.min(#grassPts, 6)))
end

-- More town (owner, fourth round, 2026-10-31: "build more filler buildings"). The builder adds rows 5 and 6 behind the four street rows, then fills
-- the remaining gaps outward from the roads (Pass 2 and Pass 3 buildings carry the attribute Pass), and paves the grass corner by the Road A/B
-- junction. Budget: at most about 2000 new parts, so CityFill stays at or under 4400 parts.
do
	-- Reserved land, hard-coded so a SiteData edit cannot shrink it: the FUTURE slots of the Outlets (x 325..775, z -850..-550) and the Farm
	-- (x 570..970, z 80..400), each plus 26; 60 studs around Malarayat's new main entrance at the Road D mouth (450, 560); the current slots of
	-- Carmel (x -410..-190, z -690..-510) and Malarayat (x 360..760, z 560..880) with the site rule (footprint + 10 percent + 26).
	local RESERVED = {
		{ key = "Outlets future slot + 26", x0 = 299, x1 = 801, z0 = -876, z1 = -524 },
		{ key = "Farm future slot + 26", x0 = 544, x1 = 996, z0 = 54, z1 = 426 },
		{ key = "Malarayat entrance (450,560) + 60", x0 = 390, x1 = 510, z0 = 500, z1 = 620 },
		{ key = "Carmel slot + 10 percent + 26", x0 = -447, x1 = -153, z0 = -725, z1 = -475 },
		{ key = "Malarayat slot + 10 percent + 26", x0 = 314, x1 = 806, z0 = 518, z1 = 922 },
	}
	local function xzBox(p)
		local half, cf = p.Size / 2, p.CFrame
		local ex = math.abs(cf.RightVector.X) * half.X + math.abs(cf.UpVector.X) * half.Y + math.abs(cf.LookVector.X) * half.Z
		local ez = math.abs(cf.RightVector.Z) * half.X + math.abs(cf.UpVector.Z) * half.Y + math.abs(cf.LookVector.Z) * half.Z
		return p.Position.X - ex, p.Position.X + ex, p.Position.Z - ez, p.Position.Z + ez
	end
	local inReserved = {}
	for _, p in ipairs(parts) do
		local x0, x1, z0, z1 = xzBox(p)
		for _, b in ipairs(RESERVED) do
			if overlaps(b, x0, x1, z0, z1) then table.insert(inReserved, p:GetFullName() .. " in " .. b.key) break end
		end
	end
	check("no filler part inside the reserved land (future Outlets and Farm slots, Malarayat entrance, Carmel and Malarayat slots)", #inReserved == 0, list(inReserved))
	-- Tagbakin (site 09, slot x -720..-480, z 450..650) gets Taal Volcano and the lake view: nothing within 250 studs of (-600, 550), and nothing
	-- west of x -480 where z > 300 (coordinator, 2026-10-31).
	local nearTaal = {}
	for _, p in ipairs(parts) do
		local x0, x1, z0, z1 = xzBox(p)
		local qx, qz = math.clamp(-600, x0, x1), math.clamp(550, z0, z1)
		if (qx + 600) ^ 2 + (qz - 550) ^ 2 < 250 ^ 2 or (x0 < -480 and z1 > 300) then table.insert(nearTaal, p:GetFullName()) end
	end
	check("no filler part within 250 studs of Tagbakin (-600, 550) or west of x -480 with z > 300", #nearTaal == 0, list(nearTaal))

	check("CityFill holds 450 or more buildings (was 262)", buildings >= 450, buildings .. " buildings")
	check("CityFill holds 3600..4400 parts (was 2387; budget about 2000 new)", #parts >= 3600 and #parts <= 4400, #parts .. " parts")

	-- New-pass buildings keep a 12-stud clear band from every road edge (the street rows already line the roads), and some stand deep.
	local newB, banded, deep = 0, {}, 0
	local function roadDist(px, pz)
		local best = math.huge
		for _, s in ipairs(segs) do best = math.min(best, segDist(px, pz, s.a, s.b) - (s.clear - ROAD_CLEAR)) end
		return best -- distance from the nearest road EDGE
	end
	if fill then
		for _, m in ipairs(fill:GetChildren()) do
			if m:IsA("Model") and (m:GetAttribute("Pass") or 1) >= 2 and m:FindFirstChild("Body") then
				newB += 1
				for _, p in ipairs(m:GetDescendants()) do
					if p:IsA("BasePart") then
						local x0, x1, z0, z1 = xzBox(p)
						local hit = false
						for ix = 0, 4 do
							for iz = 0, 4 do
								if roadDist(x0 + (x1 - x0) * ix / 4, z0 + (z1 - z0) * iz / 4) < 12 then hit = true end
							end
						end
						if hit then table.insert(banded, p:GetFullName()) break end
					end
				end
				local lot = m:FindFirstChild("Lot")
				if lot and roadDist(lot.Position.X, lot.Position.Z) > 144 then deep += 1 end
			end
		end
	end
	check("150 or more new-pass buildings (attribute Pass 2 or 3)", newB >= 150, newB .. " new")
	check("no new-pass building comes within 12 studs of a road edge", newB > 0 and #banded == 0, newB .. " new, " .. list(banded))
	check("rows deeper than the old four: 60 or more new buildings whose Lot centre is over 144 studs from every road edge", deep >= 60, deep .. " deep")

	-- The grass corner by the Road A/B junction (handoff 059, owed): x -104..352, z -448..-336 (between City Hall's box, Road A, Road B and the
	-- core town). Every 8 studs, off the road bodies (half width + 5), a downward ray must land on a CityFill part, not on terrain.
	local lp = RaycastParams.new()
	lp.FilterType = Enum.RaycastFilterType.Include
	lp.FilterDescendantsInstances = { fill or workspace.World, workspace.Terrain }
	local cornerN, bare = 0, {}
	for x = -104, 352, 8 do
		for z = -448, -336, 8 do
			local nearRoad = false
			for _, s in ipairs(segs) do
				if segDist(x, z, s.a, s.b) < s.clear - ROAD_CLEAR + 5 then nearRoad = true break end
			end
			if not nearRoad then
				cornerN += 1
				local r = workspace:Raycast(Vector3.new(x, 400, z), Vector3.new(0, -800, 0), lp)
				if not r or r.Instance == workspace.Terrain then table.insert(bare, string.format("(%d,%d)", x, z)) end
			end
		end
	end
	check("the Road A/B corner (x -104..352, z -448..-336) is filled: every sample lands on a CityFill part", cornerN > 0 and #bare == 0,
		#bare .. " of " .. cornerN .. " bare: " .. table.concat(bare, " ", 1, math.min(#bare, 8)))

	-- Lots touch but never overlap (more than 0.1 stud) one another.
	local lots = {}
	for _, p in ipairs(parts) do
		if p.Name == "Lot" then
			local x0, x1, z0, z1 = xzBox(p)
			table.insert(lots, { p = p, x0 = x0, x1 = x1, z0 = z0, z1 = z1 })
		end
	end
	local clash = {}
	for i = 1, #lots do
		local a = lots[i]
		for j = i + 1, #lots do
			local b = lots[j]
			if a.x0 < b.x1 - 0.1 and a.x1 > b.x0 + 0.1 and a.z0 < b.z1 - 0.1 and a.z1 > b.z0 + 0.1 then
				table.insert(clash, a.p.Parent.Name .. "/" .. b.p.Parent.Name)
			end
		end
		if i % 100 == 0 then task.wait() end
	end
	check("no two Lots overlap", #lots > 0 and #clash == 0, #lots .. " lots, " .. list(clash))

	-- Some variety: three kinds of roof detail among the new buildings.
	local kinds = {}
	if fill then
		for _, m in ipairs(fill:GetChildren()) do
			if m:IsA("Model") and (m:GetAttribute("Pass") or 1) >= 2 then
				for _, n in ipairs({ "Tank", "RoofBox", "Gable" }) do
					if m:FindFirstChild(n) then kinds[n] = true end
				end
			end
		end
	end
	local nk = 0
	for _ in pairs(kinds) do nk += 1 end
	check("new buildings show 3 kinds of roof detail (Tank, RoofBox, Gable)", nk == 3, nk .. " kinds")
end

-- Mood (owner, second round: "a nice mood of weather like sunny or sunset"): golden late afternoon.
check("golden hour: Lighting.ClockTime 16.6..17.9", game.Lighting.ClockTime >= 16.6 and game.Lighting.ClockTime <= 17.9, tostring(game.Lighting.ClockTime))

-- Music (owner, second round: "a relaxing music"): a looping track in SoundService tagged Music=true, started with the ambient loop by
-- WelcomeClient and silenced with it by the PassportClient Mute button. Track: "Lofi Chill Blue Cat Study and Relaxing" (DistrokidOfficial,
-- Creator Store, free).
local SoundService = game:GetService("SoundService")
local music
for _, s in ipairs(SoundService:GetChildren()) do
	if s:IsA("Sound") and s:GetAttribute("Music") == true then music = s break end
end
check("a Sound in SoundService is tagged Music=true", music ~= nil)
if music then
	check("music: the chosen track, looped, volume 0.1..0.4", music.SoundId == "rbxassetid://76934240287978" and music.Looped and music.Volume >= 0.1 and music.Volume <= 0.4,
		music.SoundId .. " looped " .. tostring(music.Looped) .. " vol " .. music.Volume)
end
local sps = game:GetService("StarterPlayer").StarterPlayerScripts
local welcome, passport = sps:FindFirstChild("WelcomeClient"), sps:FindFirstChild("PassportClient")
check("WelcomeClient starts the Music sounds", welcome ~= nil and string.find(welcome.Source, 'GetAttribute("Music")', 1, true) ~= nil)
check("PassportClient Mute also silences the Music sounds", passport ~= nil and string.find(passport.Source, 'GetAttribute("Music")', 1, true) ~= nil)

-- Haze: Lighting.Atmosphere thickened (was Density 0.30, Haze 0).
local atmo = game.Lighting:FindFirstChildOfClass("Atmosphere")
check("Lighting has one Atmosphere", atmo ~= nil)
if atmo then
	check("haze: Atmosphere Density 0.38..0.5 and Haze 1..2.5", atmo.Density >= 0.38 and atmo.Density <= 0.5 and atmo.Haze >= 1 and atmo.Haze <= 2.5,
		string.format("Density %.2f Haze %.2f", atmo.Density, atmo.Haze))
end

return HttpService:JSONEncode(results)
