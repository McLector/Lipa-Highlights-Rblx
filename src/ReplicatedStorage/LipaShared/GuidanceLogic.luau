-- GuidanceLogic: the "next stop" hint for a first-time player (pure; plain Vector3s, no Instances). PassportClient shows the
-- text under the HUD and a NEXT pin at `point`; JeepneyClient highlights jeepTarget(nextSite). Every position comes from SiteData,
-- never from Workspace, because far sites stream out. Why: in the 2026-10-31 playtest nothing told a newcomer where to go after
-- Ate Joy, and the three walk-only shops (no jeep stop, not in the jeep menu, no sign) could not be found.
-- World axes: North = -Z, East = +X. All text is ASCII (site names go through plain()).
local SiteData = require(game:GetService("ReplicatedStorage"):WaitForChild("LipaShared"):WaitForChild("SiteData"))

local GuidanceLogic = {}

-- City Hall (the spawn), the Plaza, the three shops on foot from the Plaza, then the five far sites by jeepney.
GuidanceLogic.ORDER = { 10, 1, 2, 3, 4, 5, 6, 7, 8, 9 }

GuidanceLogic.TALK_RANGE = 15 -- studs from a guide: close enough to press the prompt (12) after a step or two
GuidanceLogic.NEAR_RANGE = 120 -- a site with a jeep stop: walk when its guide is this close, else ride
GuidanceLogic.SHOP_WALK = 400 -- a walk-only shop: walk when its guide is this close (the Plaza stop is 256..323 away), else ride to the Plaza

local SHOPS = { [2] = "west", [3] = "east", [4] = "east" } -- which Plaza side stairs lead to each shop
-- The fenced Cathedral compound (slot x -120..120, z -100..215); its exits are the side stairs at x -121 / 121, z 26.
local COMPOUND = { minX = -120, maxX = 120, minZ = -100, maxZ = 215 }
local STAIRS = { west = Vector3.new(-126, 0, 26), east = Vector3.new(126, 0, 26) }
local COMPASS = { "north", "north-east", "east", "south-east", "south", "south-west", "west", "north-west" }

local function stampedSet(ids)
	local set = {}
	if type(ids) ~= "table" then
		return set
	end
	for _, id in ipairs(ids) do
		if SiteData.byId(id) then
			set[id] = true
		end
	end
	return set
end

function GuidanceLogic.nextSite(stampedIds)
	local set = stampedSet(stampedIds)
	for _, id in ipairs(GuidanceLogic.ORDER) do
		if not set[id] then
			return id
		end
	end
	return nil
end

function GuidanceLogic.compass(from, to)
	local dx, dz = to.X - from.X, to.Z - from.Z
	local deg = math.deg(math.atan2(dx, -dz)) % 360
	return COMPASS[math.floor((deg + 22.5) / 45) % 8 + 1]
end

function GuidanceLogic.plain(s)
	if type(s) ~= "string" then
		return ""
	end
	s = string.gsub(s, "\195\169", "e") -- e-acute (Cafe de Lipa)
	return (string.gsub(s, "[\128-\255]", ""))
end

function GuidanceLogic.jeepTarget(id)
	if SHOPS[id] then
		return 1
	end
	if SiteData.hasJeepStop(id) then
		return id
	end
	return nil
end

local function flat(a, b)
	return (Vector3.new(a.X, 0, a.Z) - Vector3.new(b.X, 0, b.Z)).Magnitude
end

local function nearestStop(pos)
	local best, bestD = nil, math.huge
	for _, s in ipairs(SiteData.sites) do
		local p = SiteData.jeepStopPos(s.id)
		if p and flat(p, pos) < bestD then
			best, bestD = p, flat(p, pos)
		end
	end
	return best
end

local function insideCompound(pos)
	return pos.X >= COMPOUND.minX and pos.X <= COMPOUND.maxX and pos.Z >= COMPOUND.minZ and pos.Z <= COMPOUND.maxZ
end

function GuidanceLogic.hint(stampedIds, playerPos)
	local id = GuidanceLogic.nextSite(stampedIds)
	if not id then
		return { mode = "done", text = "All 10 stamps! Open your Certificate." }
	end
	local name = GuidanceLogic.plain(SiteData.byId(id).name)
	local guide = SiteData.guidePos(id)
	if typeof(playerPos) ~= "Vector3" then
		return { siteId = id, mode = "walk", point = guide, text = "Next: Find the guide at " .. name .. "." }
	end
	local d = flat(playerPos, guide)
	if d <= GuidanceLogic.TALK_RANGE then
		return { siteId = id, mode = "talk", point = guide, text = "Next: Talk to the guide at " .. name .. "." }
	end
	local side = SHOPS[id]
	if side and insideCompound(playerPos) then
		return { siteId = id, mode = "stairs", point = STAIRS[side],
			text = "Next: Leave the Plaza by the " .. side .. " side stairs, then walk to " .. name .. "." }
	end
	if d <= (side and GuidanceLogic.SHOP_WALK or GuidanceLogic.NEAR_RANGE) then
		return { siteId = id, mode = "walk", point = guide,
			text = "Next: Walk " .. GuidanceLogic.compass(playerPos, guide) .. " to the guide at " .. name .. "." }
	end
	local stop = nearestStop(playerPos)
	if side then
		local dir = GuidanceLogic.compass(SiteData.jeepStopPos(1), guide)
		return { siteId = id, mode = "jeep", point = stop, text = "Next: Ride the jeepney to the Plaza, then walk " .. dir .. " to " .. name .. "." }
	end
	return { siteId = id, mode = "jeep", point = stop, text = "Next: Ride the jeepney to " .. name .. "." }
end

return GuidanceLogic
