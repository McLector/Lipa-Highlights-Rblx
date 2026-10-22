-- SiteData: the nine Lipa sites. Source of truth for layout (structure_model_positioning.png), with ONE deliberate deviation made in
-- Slice 14 at the user's request: the three town-core shops were pushed out from the Cathedral so the core is not crowded (Market
-- -230 -> -330, Lomi King 180 -> 292, Cafe 160 -> 272; z unchanged; the image is not edited). Categories (png legend), and display text. Dialogue is the approved text in content/dialogue_draft.md (Slice 12, shortened after the professor's feedback): ASCII only,
-- because GuideClient's typewriter slices lines by byte.
-- World axes: North = -Z, East = +X. `size` is Vector2(X extent, Z extent) of the world-aligned footprint.
local SiteData = {}

-- Unit look direction (X, Z) per facing.
local R = 1 / math.sqrt(2)
local FACING_DIRS = {
	N = Vector3.new(0, 0, -1), S = Vector3.new(0, 0, 1), E = Vector3.new(1, 0, 0), W = Vector3.new(-1, 0, 0),
	NE = Vector3.new(R, 0, -R), NW = Vector3.new(-R, 0, -R), SE = Vector3.new(R, 0, R), SW = Vector3.new(-R, 0, R),
}

local function site(id, key, name, category, x, groundY, z, facing, sx, sz, massScale, guideName, dialogue, panelText, credits, requiredProps)
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
		dialogue = dialogue,
		panelText = panelText,
		credits = credits,
		requiredProps = requiredProps,
	}
end

SiteData.sites = {
	site(1, "Cathedral", "Plaza Independencia & Metropolitan Cathedral", "Pray", 0, 0, 0, "S", 240, 200, 2.0,
		"Plaza Guide",
		{
			"Welcome to the Metropolitan Cathedral of San Sebastian, the center of Lipa's religious life. Down the steps from this forecourt is Plaza Independencia, where the city gathers for events.",
			"Look at the bell tower and count its tiers as it narrows up to the cupola. Then find the paired columns and the warm yellow walls on the front.",
		},
		"Plaza Independencia and the Cathedral connect religious life, public gatherings and the city's historic center.",
		{ "commons.wikimedia.org", "lipacitybatangas.blogspot.com" },
		{ "PlazaPeople", "Benches", "Lamps", "Flagpole", "EventStage" }),
	site(2, "Market", "Candido B. Lopez Memorial Public Market", "Eat", -330, 0, 160, "E", 200, 160, 3.0,
		"Market Vendor",
		{
			"This is the Candido B. Lopez Memorial Public Market, the palengke where Lipa shops for produce, food, and daily needs. Our facade photo is from 2014, so it may look different today.",
			"Look at the rounded arches repeating along the front, with rows of windows above them. Count the arches, and notice how the stairs break up the line.",
		},
		"The public market shows everyday Lipa through food vendors, produce, coffee, local delicacies and small businesses.",
		{ "jeromedoe.blogspot.com", "www.flickr.com" },
		{ "MarketStalls", "Baskets", "Produce", "PriceSigns", "VendorNPCs" }),
	site(3, "Lomi", "Lomi King", "Eat", 292, 0, 140, "W", 100, 80, 3.5,
		"Lomi Host",
		{
			"This is Lomi King, one of Lipa's lomi houses. Lomi is part of the city's food culture, and sharing a hot bowl is a social way to eat. Our photo is from 2015, so the front may have changed.",
			"Look at the bold orange sign band above the entrance. Its bright colors pull your eye to the name first. Then follow the menu boards down to the doorway.",
		},
		"Lomi remains a recognizable part of Lipa's food culture, and a lomihan is a place for eating together.",
		{ "primer.com.ph" },
		{ "Counter", "Tables", "LomiBowls", "Menu", "Utensils" }),
	site(4, "Cafe", "Café de Lipa", "Eat", 272, 0, -160, "W", 100, 80, 3.5,
		"Cafe Barista",
		{
			"This is Cafe de Lipa, linked to kapeng barako, the strong coffee Batangas is known for. Coffee links Lipa's farming past with today's cafe culture. This model shows the Tibig/STAR branch.",
			"Look at the glass storefront glowing warm under the dark fascia and the lit yellow letters. Notice how the light spills out onto the outdoor seating.",
		},
		"Coffee connects Lipa's agricultural heritage with its present café culture. The interior shown is representative.",
		{ "www.tripadvisor.com.ph", "www.thepoortraveler.net" },
		{ "CoffeeBar", "BarakoBeans", "CoffeePacks", "BrewingSet" }),
	site(5, "Carmel", "Monastery of Our Lady of Mount Carmel", "Pray", -300, 0, -600, "S", 220, 180, 2.5,
		"Pilgrim Guide",
		{
			"Hi, I'm a volunteer guide and a pilgrim, not a nun. This is the Monastery of Our Lady of Mount Carmel in Lipa, a Carmelite community founded on May 31, 1946.",
			"In 1948, Teresita Castillo reported apparitions of Mary here, drawing pilgrims to Lipa. In 1951, a commission of Filipino bishops found no supernatural character in the events.",
			"The Holy See has since reaffirmed that 1951 judgment. In 2015, Archbishop Ramon Arguelles declared the events worthy of belief. The Holy See rejected that, and he later withdrew it.",
			"Look at the entry arch and the tall arched windows above it, repeating the same shape. The stepped top of the front wall gives the facade its clear outline.",
		},
		"A Carmelite monastery founded on May 31, 1946, a place of prayer and pilgrimage in Lipa.",
		{ "commons.wikimedia.org", "www.carmelitaniscalzi.com", "www.tripadvisor.co.uk", "www.trip.com" },
		{ "Pews", "Kneeler", "Candles", "HistoryPanels" }),
	site(6, "Outlets", "The Outlets at LIMA Estate", "Love", 550, 0, -650, "SW", 300, 200, 2.5,
		"Outlets Guide",
		{
			"This is The Outlets at LIMA Estate, called The Outlets at Lipa until 2025. Its outdoor shops beside the Aboitiz Pitch stand for modern shopping, dining, and an economy tied to growing industry.",
			"Look at the orange timber block against the white walls and dark glass. Follow the long canopy along the covered walkway, then find the slatted sign by the road.",
		},
		"Contemporary shopping, dining and recreation. LIMA Estate spans Lipa and Malvar.",
		{ "architizer.com" },
		{ "ShopStreet", "SportsField", "EstateModelPedestal", "LipaMalvarPanel" }),
	site(7, "Farm", "The Farm at San Benito", "Love", 700, 0, 240, "W", 260, 260, 3.0,
		"Farm Guide",
		{
			"This is The Farm at San Benito, a wellness resort in Lipa with gardens, a lagoon, and activities like yoga. It shows Lipa's wellness tourism today. Visits involve a booking or paid services.",
			"Look at the round thatched pavilion beside the straight-edged villa. Its curve and rough texture contrast with the flat walls. Then follow the patterned path.",
		},
		"An operating resort representing Lipa's contemporary wellness tourism: gardens, accommodation and dining.",
		{ "www.marriott.com", "www.thefarmatsanbenito.com", "artemlevy.com" },
		{ "GardenPavilion", "LandscapedPath", "WellnessPanel" }),
	site(8, "Malarayat", "Mount Malarayat Golf & Country Club", "Love", 560, 19.8, 720, "NW", 400, 320, 2.0,
		"Club Guide",
		{
			"This is Mount Malarayat Golf and Country Club in Barangay Dagatan, Lipa, a place for golf, hotel stays, and leisure with a view of the mountains. Access depends on membership or a booking.",
			"Look at the big hipped roof on the clubhouse, then find the smaller entry gable and the wing roof. Their red-brown color stands out against the green lawn.",
		},
		"A present-day recreation and hospitality destination associated with Lipa's mountain setting.",
		{ "malarayat.com", "www.golfsavers.com" },
		{ "Clubhouse", "MountainBackdrop", "LeisureSpacesPanel" }),
	site(9, "Tagbakin", "Tagbakin", "Love", -600, 0, 550, "NE", 240, 200, 3.0,
		"Lakeside Guide",
		{
			"This is Tagbakin, a sitio in Barangay Halang on Lipa's lakeside. The city calls Halang one of its developed tourist spots, and says the waters off Tagbakin have long teemed with tawilis.",
			"Look along the dock and count its repeating posts. The dock leads your eye across the water to the volcano, past the grey lakeside building with stepped roofs.",
		},
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
