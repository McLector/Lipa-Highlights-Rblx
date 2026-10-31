-- SiteData: the ten Lipa sites (nine town sites plus New Lipa City Hall, id 10, added in Slice 3b). Source of truth for layout (structure_model_positioning.png), with ONE deliberate deviation made in
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

-- Optional per-row local offsets (`locals`: guideLocal, jeepLocal, panelLocal), each a Vector2 (lx, lz) in the site's LOCAL FRAME:
-- origin = the site pos, +lx = forward (the facing direction), lz = to the right of the facing, i.e. (-f.Z, 0, f.X)
-- (facing E: forward +X, right +Z). When a row has no offset, the old default formulas apply (see guidePos / jeepStopPos).
local function site(id, key, name, category, x, groundY, z, facing, sx, sz, massScale, guideName, dialogue, panelText, credits, requiredProps, locals)
	locals = locals or {}
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
		guideLocal = locals.guideLocal,
		jeepLocal = locals.jeepLocal,
		panelLocal = locals.panelLocal,
	}
end

SiteData.sites = {
	site(1, "Cathedral", "Plaza Independencia & Metropolitan Cathedral", "Pray", 0, 0, 57.5, "S", 240, 315, 2.0,
		"Plaza Guide",
		{
			"Welcome to the Metropolitan Cathedral of San Sebastian, the center of Lipa's religious life. Down the steps from this forecourt is Plaza Independencia, where the city gathers for events.",
			"Did you know? The cathedral's octagonal bell tower first had five stories. It was made taller when the church was restored in the 1950s, after damage in World War II.",
			"Look at the bell tower and count its tiers as it narrows up to the cupola. Then find the paired columns and the warm yellow walls on the front.",
		},
		"Plaza Independencia and the Cathedral connect religious life, public gatherings and the city's historic center.",
		{ "commons.wikimedia.org", "lipacitybatangas.blogspot.com" },
		{ "PlazaPeople", "Benches", "Lamps", "Flagpole", "EventStage" },
		-- Cathedral south growth (Slice 4 B3b): the slot grew from z -100..100 to z -100..215, so its centre moved to (0, 57.5). The locals keep the
		-- WORLD positions of the Guide (0,30), the jeep stop (default: guide + 20 to the right = (-20,30)) and the InfoPanel (12,24) unchanged.
		-- Facing S: forward +Z, right -X. Guide lx = 30 - 57.5; panel lx = 24 - 57.5, lz = -12 (world x +12).
		{ guideLocal = Vector2.new(-27.5, 0), panelLocal = Vector2.new(-33.5, -12) }),
	-- Row 2: the Market, rebuilt from BP1 (Slice 4, 2026-10-29). Slot 348 x 330 at (-402, 160), facing E (x -576..-228, z -5..325); the east edge is flush with the end of Road F.
	-- Owner decision: the Guide and the InfoPanel stand on the forecourt at the stairs. The Market keeps no JeepStop. Facing E: forward +X, right +Z, so world = (-402 + lx, 160 + lz):
	-- Guide (-241, 160) = local (161, 0); InfoPanel (-247, 148) = local (155, -12).
	site(2, "Market", "Candido B. Lopez Memorial Public Market", "Eat", -402, 0, 160, "E", 348, 330, 3.0,
		"Market Vendor",
		{
			"This is the Candido B. Lopez Memorial Public Market, the palengke where Lipa shops for produce, food, and daily needs. Our model follows a plan drawing and recent street photos, so some details may differ.",
			"Did you know? Lipa's market goes back over a century. In 1914, a government report called the town's new concrete market probably the most complete of any provincial town in the islands.",
			"Look at the rounded arches repeating along the top floor in a steady rhythm. Count the arches, and notice how the two stairs climb toward the middle.",
		},
		"The public market shows everyday Lipa through food vendors, produce, coffee, local delicacies and small businesses.",
		{ "jeromedoe.blogspot.com", "www.flickr.com" },
		{ "MarketStalls", "Baskets", "Produce", "PriceSigns", "VendorNPCs" },
		{ guideLocal = Vector2.new(161, 0), panelLocal = Vector2.new(155, -12) }),
	site(3, "Lomi", "Lomi King", "Eat", 292, 0, 140, "W", 100, 110, 3.5,
		"Lomi Host",
		{
			"This is Lomi King, one of Lipa's lomi houses. Lomi is part of the city's food culture, and sharing a hot bowl is a social way to eat. Our model follows a 2026 Street View image and a drawn board, so details may differ.",
			"Did you know? Batangas lomi is credited to To Kim Eng, a Chinese immigrant who began serving it in Lipa in the late 1960s.",
			"Look at the bold orange sign band above the entrance. Its bright colors pull your eye to the name first. Then follow the menu boards down to the doorway.",
		},
		"Lomi remains a recognizable part of Lipa's food culture, and a lomihan is a place for eating together.",
		{ "primer.com.ph", "www.google.com" },
		{ "Counter", "Tables", "LomiBowls", "Menu", "Utensils" }),
	site(4, "Cafe", "Café de Lipa", "Eat", 272, 0, -160, "W", 100, 80, 3.5,
		"Cafe Barista",
		{
			"This is Cafe de Lipa, linked to kapeng barako, the strong coffee Batangas is known for. Coffee links Lipa's farming past with today's cafe culture. This model shows the Tibig/STAR branch.",
			"Did you know? Coffee made Lipa rich in the 1800s. In 1887, Spain's Queen Regent Maria Cristina gave the town the title Villa de Lipa.",
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
			"Did you know? The monastery was founded less than a year after World War II ended, when Lipa was one of the most damaged areas. Its first sisters came from the Manila Carmel.",
			"Look at the entry arch and the tall arched windows above it, repeating the same shape. The stepped top of the front wall gives the facade its clear outline.",
		},
		"A Carmelite monastery founded on May 31, 1946, a place of prayer and pilgrimage in Lipa.",
		{ "commons.wikimedia.org", "www.carmelitaniscalzi.com", "www.tripadvisor.co.uk", "www.trip.com" },
		{ "Pews", "Kneeler", "Candles", "HistoryPanels" }),
	-- Row 6: the Outlets, rebuilt from the LIMA Estate board (2026-10-31, briefs/site06.md Revision 2). Slot 450 x 300 at (550, -700), facing SW
	-- (x 325..775, z -850..-550; the south edge stays flush with Road B's end). The Guide (528.79, -628.79), the JeepStop (514.64, -642.93, the
	-- default 20 to the right of the Guide; no jeepLocal) and the InfoPanel (541.51, -624.54) keep their world positions: guideLocal and
	-- panelLocal are the old offsets (30, 0) and (24, -12) plus the centre shift 25 * sqrt 2 forward and to the left.
	site(6, "Outlets", "The Outlets at LIMA Estate", "Love", 550, 0, -700, "SW", 450, 300, 2.5,
		"Outlets Guide",
		{
			"This is The Outlets at LIMA Estate, called The Outlets at Lipa until 2025. Its outdoor shops beside the Aboitiz Pitch stand for modern shopping, dining, and an economy tied to growing industry.",
			"Did you know? Aboitiz, the developer, calls LIMA Estate the largest privately owned industrial estate in the Philippines. In 2024 it had about 71,000 workers.",
			"Look at the orange timber block against the white walls and dark glass. Follow the long canopy along the covered walkway, then find the slatted sign by the road.",
		},
		"Contemporary shopping, dining and recreation. LIMA Estate spans Lipa and Malvar.",
		{ "architizer.com" },
		{ "ShopStreet", "SportsField", "EstateModelPedestal", "LipaMalvarPanel" },
		{ guideLocal = Vector2.new(65.3553391, -35.3553391), panelLocal = Vector2.new(59.3553391, -47.3553391) }),
	-- Row 7: the Farm, rebuilt from the San Benito board (2026-10-31, briefs/site07.md Revision 2). Slot 400 x 320 at (770, 240), facing W (x 570..970,
	-- z 80..400; the west edge stays at Road C's end). Facing W: forward -X, right -Z, so world = (770 - lx, 240 - lz). The locals keep the WORLD
	-- positions: Guide (670, 240) = local (100, 0); InfoPanel (676, 252) = local (94, -12); the JeepStop stays at the default (670, 220).
	site(7, "Farm", "The Farm at San Benito", "Love", 770, 0, 240, "W", 400, 320, 3.0,
		"Farm Guide",
		{
			"This is The Farm at San Benito, a wellness resort in Lipa with gardens, a lagoon, and activities like yoga. It shows Lipa's wellness tourism today. Visits involve a booking or paid services.",
			"Did you know? The Farm opened on December 14, 2002, on 51 hectares of land.",
			"Look at the round thatched pavilion beside the straight-edged villa. Its curve and rough texture contrast with the flat walls. Then follow the patterned path.",
		},
		"An operating resort representing Lipa's contemporary wellness tourism: gardens, accommodation and dining.",
		{ "www.marriott.com", "www.thefarmatsanbenito.com", "artemlevy.com" },
		{ "GardenPavilion", "LandscapedPath", "WellnessPanel" },
		{ guideLocal = Vector2.new(100, 0), panelLocal = Vector2.new(94, -12) }),
	site(8, "Malarayat", "Mount Malarayat Golf & Country Club", "Love", 560, 19.8, 720, "NW", 400, 320, 2.0,
		"Club Guide",
		{
			"This is Mount Malarayat Golf and Country Club in Barangay Dagatan, Lipa, a place for golf, hotel stays, and leisure with a view of the mountains. Access depends on membership or a booking.",
			"Did you know? The club sits in the Malarayat mountain range, and its 27-hole championship course is split into three courses: Lobo, Makulot, and Malipunyo.",
			"Look at the big hipped roof on the clubhouse, then find the smaller entry gable and the wing roof. Their red-brown color stands out against the green lawn.",
		},
		"A present-day recreation and hospitality destination associated with Lipa's mountain setting.",
		{ "malarayat.com", "www.golfsavers.com" },
		{ "Clubhouse", "MountainBackdrop", "LeisureSpacesPanel" }),
	site(9, "Tagbakin", "Tagbakin", "Love", -600, 0, 550, "NE", 240, 200, 3.0,
		"Lakeside Guide",
		{
			"This is Tagbakin, a sitio in Barangay Halang on Lipa's lakeside. The city calls Halang one of its developed tourist spots, and says the waters off Tagbakin have long teemed with tawilis.",
			"Did you know? Tawilis is a freshwater sardine found only in Taal Lake. In 2019 the IUCN declared it an endangered species.",
			"Look along the dock and count its repeating posts. The dock leads your eye across the water to the volcano, past the grey lakeside building with stepped roofs.",
		},
		"Tagbakin, in Barangay Halang, introduces Lipa's lakeside identity.",
		{ "www.wowbatangas.com" },
		{ "LocationMapPanel", "FishingActivity", "Dock", "Bancas" }),
	-- Row 10: New Lipa City Hall, the Welcome gateway. Pivot (-270, 0, -305), facing E, slot 240 x 286 (x -390..-150, z -448..-162),
	-- rebuilt from the blueprint (Step C). The dialogue is PROVISIONAL: derived from TourContent site 10 (firstTalk / trivia / lookAt)
	-- in the Slice 3b data step, until Slice 11 makes GuideClient read TourContent directly. The local offsets keep Ate Joy, the jeep
	-- stop and the InfoPanel where they were in the WORLD (Guide -223/-260, JeepStop -155/-230, InfoPanel -217/-282; the spawn pad is
	-- world x -214..-202, z -266..-254): guide at local (47, 45), jeep stop at (115, 75), InfoPanel at (53, 23).
	site(10, "CityHall", "New Lipa City Hall", "Welcome", -270, 0, -305, "E", 240, 286, 2.0,
		"Ate Joy",
		{
			"Hiii, welcome to Lipa! This is the New Lipa City Hall, inaugurated April 8, 2026 in Ayala Land's Areza estate. I'm Joy, your tour guide today.",
			"Did you know? The real building has 72 elevated blocks, one for each of Lipa's 72 barangays, which are like neighborhoods.",
			"Look at the shape of the huge faceted canopy on its tall round columns. Then follow the white brick boxes stepping along the wing in a steady rhythm.",
		},
		"Lipa's new seat of local government, inaugurated April 8, 2026, with open lobbies, gardens and shaded walkways.",
		{ "www.google.com" },
		-- requiredProps are direct child names of the model (BuildCheck): Blocks = the staggered white-brick boxes, Landscape = pocket gardens,
		-- Wing = open lobby, Forecourt = front plaza (billboard and tour map spot), JeepStop = the jeepney stop.
		{ "Blocks", "Landscape", "Wing", "Forecourt", "JeepStop" },
		{ guideLocal = Vector2.new(47, 45), jeepLocal = Vector2.new(115, 75), panelLocal = Vector2.new(53, 23) }),
}

local byIdMap = {}
for _, s in ipairs(SiteData.sites) do
	byIdMap[s.id] = s
end

-- Strict: only whole-number ids 1..10 resolve; anything else is nil.
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

-- Local frame -> world (Y = the site's groundY): origin = site pos, lx along the facing, lz to the right of the facing.
function SiteData.localToWorld(id, lx, lz)
	local s = SiteData.byId(id)
	if not s then
		return nil
	end
	local f = SiteData.facingVector(s.facing)
	local right = Vector3.new(-f.Z, 0, f.X)
	return s.pos + f * lx + right * lz
end

-- Where the Guide stands: the row's guideLocal when it has one, else 30 studs in front of the site centre
-- (XZ; Y is seated on terrain by the builder).
function SiteData.guidePos(id)
	local s = SiteData.byId(id)
	if not s then
		return nil
	end
	if s.guideLocal then
		return SiteData.localToWorld(id, s.guideLocal.X, s.guideLocal.Y)
	end
	local f = SiteData.facingVector(s.facing)
	return s.pos + f * 30
end

-- Jeep stops exist for the plaza, the five outer sites and City Hall only. Default: 20 studs to the right of the Guide, which
-- is outside the Guide's 12-stud prompt radius but inside the 25-stud stamp range. A row with jeepLocal puts the stop there.
local JEEP_SITES = { [1] = true, [5] = true, [6] = true, [7] = true, [8] = true, [9] = true, [10] = true }
function SiteData.jeepStopPos(id)
	if type(id) ~= "number" or not JEEP_SITES[id] then
		return nil
	end
	local s = byIdMap[id]
	if s.jeepLocal then
		return SiteData.localToWorld(id, s.jeepLocal.X, s.jeepLocal.Y)
	end
	local f = SiteData.facingVector(s.facing)
	local right = Vector3.new(-f.Z, 0, f.X)
	return SiteData.guidePos(id) + right * 20
end

function SiteData.hasJeepStop(id)
	return type(id) == "number" and JEEP_SITES[id] == true
end

-- Category colours (one table for the panels, guides and the passport). nil for a missing or unknown category.
local CATEGORY_COLORS = {
	Eat = Color3.fromRGB(232, 150, 70),
	Pray = Color3.fromRGB(90, 150, 230),
	Love = Color3.fromRGB(100, 190, 110),
	Welcome = Color3.fromRGB(230, 190, 80),
}
function SiteData.categoryColor(category)
	if type(category) ~= "string" then
		return nil
	end
	return CATEGORY_COLORS[category]
end

return SiteData
