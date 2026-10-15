-- SiteData: the nine Lipa sites. Source of truth for layout (structure_model_positioning.png, Market shifted to -230),
-- categories (png legend), and display text. Dialogue lines here are [PLACEHOLDER]s until the Slice 12 content gate.
-- World axes: North = -Z, East = +X. `size` is Vector2(X extent, Z extent) of the world-aligned footprint.
local SiteData = {}

-- Unit look direction (X, Z) per facing.
local R = 1 / math.sqrt(2)
local FACING_DIRS = {
	N = Vector3.new(0, 0, -1), S = Vector3.new(0, 0, 1), E = Vector3.new(1, 0, 0), W = Vector3.new(-1, 0, 0),
	NE = Vector3.new(R, 0, -R), NW = Vector3.new(-R, 0, -R), SE = Vector3.new(R, 0, R), SW = Vector3.new(-R, 0, R),
}

local function placeholder(name)
	return {
		"[PLACEHOLDER] Welcome to " .. name .. "!",
		"[PLACEHOLDER] This guide will introduce what the place is and what it represents in modern Lipa City.",
		"[PLACEHOLDER] Look closely at the building: what shapes, colors and patterns do you notice?",
	}
end

local function site(id, key, name, category, x, groundY, z, facing, sx, sz, massScale, guideName, panelText, credits, requiredProps)
	return {
		id = id,
		key = key,
		name = name,
		category = category,
		pos = Vector3.new(x, groundY, z),
		groundY = groundY,
		facing = facing,
		size = Vector2.new(sx, sz),
		massScale = massScale,
		guideName = guideName,
		dialogue = placeholder(name),
		panelText = panelText,
		credits = credits,
		requiredProps = requiredProps,
	}
end

SiteData.sites = {
	site(1, "Cathedral", "Plaza Independencia & Metropolitan Cathedral", "Pray", 0, 0, 0, "S", 240, 200, 2.0,
		"Plaza Guide",
		"Plaza Independencia and the Cathedral connect religious life, public gatherings and the city's historic center.",
		{ "commons.wikimedia.org", "lipacitybatangas.blogspot.com" },
		{ "PlazaPeople", "Benches", "Lamps", "Flagpole", "EventStage" }),
	site(2, "Market", "Candido B. Lopez Memorial Public Market", "Eat", -230, 0, 160, "E", 200, 160, 3.0,
		"Market Vendor",
		"The public market shows everyday Lipa through food vendors, produce, coffee, local delicacies and small businesses.",
		{ "jeromedoe.blogspot.com", "www.flickr.com" },
		{ "MarketStalls", "Baskets", "Produce", "PriceSigns", "VendorNPCs" }),
	site(3, "Lomi", "Lomi King", "Eat", 180, 0, 140, "W", 100, 80, 3.5,
		"Lomi Host",
		"Lomi remains a recognizable part of Lipa's food culture, and a lomihan is a place for eating together.",
		{ "primer.com.ph" },
		{ "Counter", "Tables", "LomiBowls", "Menu", "Utensils" }),
	site(4, "Cafe", "Café de Lipa", "Eat", 160, 0, -160, "W", 100, 80, 3.5,
		"Cafe Barista",
		"Coffee connects Lipa's agricultural heritage with its present café culture. The interior shown is representative.",
		{ "www.tripadvisor.com.ph", "www.thepoortraveler.net" },
		{ "CoffeeBar", "BarakoBeans", "CoffeePacks", "BrewingSet" }),
	site(5, "Carmel", "Monastery of Our Lady of Mount Carmel", "Pray", -300, 0, -600, "S", 220, 180, 2.5,
		"Pilgrim Guide",
		"A Carmelite monastery founded in 1946, a place of prayer and pilgrimage in Lipa.",
		{ "commons.wikimedia.org", "www.carmelitaniscalzi.com", "www.tripadvisor.co.uk", "www.trip.com" },
		{ "Pews", "Kneeler", "Candles", "HistoryPanels" }),
	site(6, "Outlets", "The Outlets at LIMA Estate", "Love", 550, 0, -650, "SW", 300, 200, 2.5,
		"Outlets Guide",
		"Contemporary shopping, dining and recreation. LIMA Estate spans Lipa and Malvar.",
		{ "architizer.com" },
		{ "ShopStreet", "SportsField", "EstateModelPedestal", "LipaMalvarPanel" }),
	site(7, "Farm", "The Farm at San Benito", "Love", 700, 0, 240, "W", 260, 260, 3.0,
		"Farm Guide",
		"An operating resort representing Lipa's contemporary wellness tourism: gardens, accommodation and dining.",
		{ "www.marriott.com", "www.thefarmatsanbenito.com", "artemlevy.com" },
		{ "GardenPavilion", "LandscapedPath", "WellnessPanel" }),
	site(8, "Malarayat", "Mount Malarayat Golf & Country Club", "Love", 560, 19.8, 720, "NW", 400, 320, 2.0,
		"Club Guide",
		"A present-day recreation and hospitality destination associated with Lipa's mountain setting.",
		{ "malarayat.com", "www.golfsavers.com" },
		{ "Clubhouse", "MountainBackdrop", "LeisureSpacesPanel" }),
	site(9, "Tagbakin", "Tagbakin", "Love", -600, 0, 550, "NE", 240, 200, 3.0,
		"Lakeside Guide",
		"Tagbakin, in Barangay Halang, introduces Lipa's lakeside identity.",
		{ "www.wowbatangas.com" },
		{ "LocationMapPanel", "FishingActivity", "Dock", "Bancas" }),
}

local byIdMap = {}
for _, s in ipairs(SiteData.sites) do
	byIdMap[s.id] = s
end

-- Strict: only whole-number ids 1..9 resolve; anything else is nil.
function SiteData.byId(id)
	if type(id) ~= "number" then
		return nil
	end
	return byIdMap[id]
end

-- Unit look direction (world space) for a facing.
function SiteData.facingVector(facing)
	local v = FACING_DIRS[facing]
	if not v then
		error("SiteData: unknown facing " .. tostring(facing), 2)
	end
	return v
end

-- Yaw (radians) such that CFrame.Angles(0, yaw, 0).LookVector points along the facing.
function SiteData.facingToYaw(facing)
	local v = SiteData.facingVector(facing)
	return math.atan2(-v.X, -v.Z)
end

-- Where the Guide stands: 30 studs in front of the site centre (XZ; Y is seated on terrain by the builder).
function SiteData.guidePos(id)
	local s = SiteData.byId(id)
	if not s then
		return nil
	end
	local f = SiteData.facingVector(s.facing)
	return s.pos + f * 30
end

-- Jeep stops exist for the plaza and the five outer sites only: 20 studs to the right of the Guide, which is
-- outside the Guide's 12-stud prompt radius but inside the 25-stud stamp range.
local JEEP_SITES = { [1] = true, [5] = true, [6] = true, [7] = true, [8] = true, [9] = true }
function SiteData.jeepStopPos(id)
	if type(id) ~= "number" or not JEEP_SITES[id] then
		return nil
	end
	local s = byIdMap[id]
	local f = SiteData.facingVector(s.facing)
	local right = Vector3.new(-f.Z, 0, f.X)
	return SiteData.guidePos(id) + right * 20
end

function SiteData.hasJeepStop(id)
	return type(id) == "number" and JEEP_SITES[id] == true
end

return SiteData
