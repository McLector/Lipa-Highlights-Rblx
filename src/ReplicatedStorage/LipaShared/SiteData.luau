-- SiteData: the nine Lipa sites. Source of truth for layout (structure_model_positioning.png, Market shifted to -230),
-- categories (png legend), and display text. Dialogue is the approved Slice 12 text (content/dialogue_draft.md): ASCII only,
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
			"Welcome to the Metropolitan Cathedral of San Sebastian in Lipa. Down the steps from this forecourt is Plaza Independencia, the city's open square.",
			"Today the plaza is where Lipa gathers for events and everyday socializing, and the cathedral anchors the city's religious life.",
			"The tower narrows tier by tier as it rises to a ribbed cupola. Paired columns repeat across the front, and warm yellow walls sit against mauve-grey trim and red roofs.",
			"Look at the bell tower on the model and count its tiers. Then find the triangular pediment and the paired columns on the front.",
		},
		"Plaza Independencia and the Cathedral connect religious life, public gatherings and the city's historic center.",
		{ "commons.wikimedia.org", "lipacitybatangas.blogspot.com" },
		{ "PlazaPeople", "Benches", "Lamps", "Flagpole", "EventStage" }),
	site(2, "Market", "Candido B. Lopez Memorial Public Market", "Eat", -230, 0, 160, "E", 200, 160, 3.0,
		"Market Vendor",
		{
			"This is the Candido B. Lopez Memorial Public Market, the palengke in Lipa where people shop for produce, food, and daily needs.",
			"It shows everyday Lipa through food vendors, produce, coffee, and small businesses. The facade photo dates from 2014, so it may look different today.",
			"The long front repeats rounded arches along the ground floor, and the rows of windows above repeat the same rhythm. The building feels steady and orderly.",
			"Look at the arched openings along the front. Count how many repeat, and notice how the stairs break up the line.",
		},
		"The public market shows everyday Lipa through food vendors, produce, coffee, local delicacies and small businesses.",
		{ "jeromedoe.blogspot.com", "www.flickr.com" },
		{ "MarketStalls", "Baskets", "Produce", "PriceSigns", "VendorNPCs" }),
	site(3, "Lomi", "Lomi King", "Eat", 180, 0, 140, "W", 100, 80, 3.5,
		"Lomi Host",
		{
			"This is Lomi King, one of Lipa's lomi houses, where people sit down together for a hot bowl of lomi noodles.",
			"Lomi is part of Lipa's food culture, and sharing a bowl is a social way to eat together. The reference photo is from 2015, so the front may have changed.",
			"The front is a bold orange sign band, with a menu banner and globe lamps below. The bright colors pull the eye to the name before anything else.",
			"Look at the sign band above the entrance on the model. Follow the menu boards down to the doorway.",
		},
		"Lomi remains a recognizable part of Lipa's food culture, and a lomihan is a place for eating together.",
		{ "primer.com.ph" },
		{ "Counter", "Tables", "LomiBowls", "Menu", "Utensils" }),
	site(4, "Cafe", "Café de Lipa", "Eat", 160, 0, -160, "W", 100, 80, 3.5,
		"Cafe Barista",
		{
			"This is Cafe de Lipa, a coffee shop linked to kapeng barako, the strong coffee Batangas is known for.",
			"Coffee links Lipa's farming past with today's cafe culture. This model shows the Tibig/STAR branch. The interior is a representative display, not a copy.",
			"The glass front glows warm against the dark fascia, and lit yellow letters spell the name above it, so the cafe looks inviting from the street.",
			"Look at the glass storefront on the model. Notice how the warm light spills out onto the outdoor seating.",
		},
		"Coffee connects Lipa's agricultural heritage with its present café culture. The interior shown is representative.",
		{ "www.tripadvisor.com.ph", "www.thepoortraveler.net" },
		{ "CoffeeBar", "BarakoBeans", "CoffeePacks", "BrewingSet" }),
	site(5, "Carmel", "Monastery of Our Lady of Mount Carmel", "Pray", -300, 0, -600, "S", 220, 180, 2.5,
		"Pilgrim Guide",
		{
			"Hi, I'm a volunteer guide and a pilgrim, not a nun. This is the Monastery of Our Lady of Mount Carmel in Lipa, a Carmelite community founded on May 31, 1946.",
			"In 1948, Teresita Castillo reported apparitions of Mary here. The reports drew pilgrims to Lipa, and local devotion grew around them.",
			"In 1951, a commission of Filipino bishops found no supernatural character in the events. The Holy See has since reaffirmed that judgment.",
			"In 2015, Archbishop Ramon Arguelles declared the events worthy of belief. The Holy See rejected that declaration, and he later withdrew it.",
			"The entry arch and the tall arched windows repeat in a steady rhythm, and the stepped top of the front wall gives the facade a clear shape.",
			"Look at the entry arch on the model. Find the arched windows above it and notice how they repeat the same shape.",
		},
		"A Carmelite monastery founded on May 31, 1946, a place of prayer and pilgrimage in Lipa.",
		{ "commons.wikimedia.org", "www.carmelitaniscalzi.com", "www.tripadvisor.co.uk", "www.trip.com" },
		{ "Pews", "Kneeler", "Candles", "HistoryPanels" }),
	site(6, "Outlets", "The Outlets at LIMA Estate", "Love", 550, 0, -650, "SW", 300, 200, 2.5,
		"Outlets Guide",
		{
			"This is The Outlets at LIMA Estate, an outdoor shopping street with a covered walkway, beside the Aboitiz Pitch. LIMA Estate spans Lipa and Malvar.",
			"It was called The Outlets at Lipa until it was renamed in 2025. It stands for modern shopping, dining, and an economy tied to growing industry.",
			"Warm orange timber cladding sits against white walls and dark glass. A deep overhang and canopy cast shade and run in a long horizontal line along the shops.",
			"Look at the orange shop block on the model. Follow the canopy along the covered walkway, then find the slatted sign by the road.",
		},
		"Contemporary shopping, dining and recreation. LIMA Estate spans Lipa and Malvar.",
		{ "architizer.com" },
		{ "ShopStreet", "SportsField", "EstateModelPedestal", "LipaMalvarPanel" }),
	site(7, "Farm", "The Farm at San Benito", "Love", 700, 0, 240, "W", 260, 260, 3.0,
		"Farm Guide",
		{
			"This is The Farm at San Benito, a wellness resort in Lipa with gardens, a lagoon, and places to stay.",
			"It represents Lipa's wellness tourism today, with gardens, dining, and organized activities like yoga. Visits involve a booking or paid services.",
			"A round thatched cone roof sits beside the straight-edged villa. Its curve and rough texture contrast with the flat, geometric walls, so each makes the other stand out.",
			"Look at the thatched pavilion on the model. Then follow the patterned path and notice where it leads your eye.",
		},
		"An operating resort representing Lipa's contemporary wellness tourism: gardens, accommodation and dining.",
		{ "www.marriott.com", "www.thefarmatsanbenito.com", "artemlevy.com" },
		{ "GardenPavilion", "LandscapedPath", "WellnessPanel" }),
	site(8, "Malarayat", "Mount Malarayat Golf & Country Club", "Love", 560, 19.8, 720, "NW", 400, 320, 2.0,
		"Club Guide",
		{
			"This is Mount Malarayat Golf and Country Club, in Barangay Dagatan, Lipa. It has a golf course with a view of the mountains.",
			"Today it is a place for golf, hotel stays, and leisure. Access depends on membership or a booking.",
			"One large hipped roof dominates the clubhouse. A smaller gabled entry and a lower side wing have roofs of their own, and the red-brown roofs stand out against the green lawn.",
			"Look at the big roof on the clubhouse model. Find the entry gable and the wing roof, then notice the repeated windows and columns below.",
		},
		"A present-day recreation and hospitality destination associated with Lipa's mountain setting.",
		{ "malarayat.com", "www.golfsavers.com" },
		{ "Clubhouse", "MountainBackdrop", "LeisureSpacesPanel" }),
	site(9, "Tagbakin", "Tagbakin", "Love", -600, 0, 550, "NE", 240, 200, 3.0,
		"Lakeside Guide",
		{
			"This is Tagbakin, a sitio in Barangay Halang, on Lipa's lakeside.",
			"The city calls Halang one of its developed tourist spots, and says the waters off Tagbakin have long teemed with tawilis, a well-known local fish.",
			"A long dock leads the eye across the water toward the volcano. Beside it, a grey building with stepped roofs and a row of windows stands against the curve of the shore.",
			"Look along the dock on the model and count the posts that repeat. Then find the volcano beyond the water and the windows on the lakeside building.",
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
