-- CreditsData: static data for the CreditsBoard at the spawn. Source pages are transcribed from content/site_credits.md
-- (generated from SOURCES.csv); a disk-side script checks the two stay equal. The student identity is filled in before Ship.
local CreditsData = {}

CreditsData.sites = {
	{ id = 1, urls = {
		"https://commons.wikimedia.org/wiki/Category:Lipa_Cathedral",
		"https://lipacitybatangas.blogspot.com/2012/10/all-about-lipa-city-batangas.html",
		"https://commons.wikimedia.org/wiki/Category:Aerial_photographs_of_Lipa_Cathedral",
	} },
	{ id = 2, urls = {
		"https://jeromedoe.blogspot.com/2014/04/sidetrip-candido-lopez-public-market-in.html",
		"https://www.flickr.com/photos/25609128@N07/4798040027",
		"https://www.flickr.com/photos/25609128@N07/5578415545",
	} },
	{ id = 3, urls = {
		"https://primer.com.ph/food/location/philippines/batangas/lomi-king-the-king-of-all-noodles-in-lipa-2/",
	} },
	{ id = 4, urls = {
		"https://cafe-1740.menufyy.com/",
		"https://www.tripadvisor.com.ph/Restaurant_Review-g1469074-d9810306-Reviews-Cafe_de_Lipa-Lipa_City_Batangas_Province_Calabarzon_Region_Luzon.html",
		"https://www.thepoortraveler.net/2012/04/cafe-de-lipa-kapeng-barako-batangas-history/",
	} },
	{ id = 5, urls = {
		"https://www.carmelitaniscalzi.com/en/2021/06/24/lipa-carmels-75th-anniversary-of-foundation-written-by-the-sisters-of-lipa/",
		"https://www.tripadvisor.co.uk/Attraction_Review-g1469074-d2706118-Reviews-Our_Lady_of_Mt_Carmel_Church-Lipa_City_Batangas_Province_Calabarzon_Region_Luzon.html",
		"https://www.trip.com/moments/detail/lipa-57532-131168270/",
		"https://commons.wikimedia.org/wiki/Category:Our_Lady_of_Mount_Carmel_Church_of_Lipa",
	} },
	{ id = 6, urls = {
		"https://architizer.com/projects/the-outlets-at-lipa/",
	} },
	{ id = 7, urls = {
		"https://www.marriott.com/en-us/hotels/mnlfs-the-farm-at-san-benito-autograph-collection/photos/",
		"https://www.thefarmatsanbenito.com/event/pura-healing-retreat-at-the-farm/",
		"https://artemlevy.com/project/the-farm-at-san-benito-artem-levy-projects/",
	} },
	{ id = 8, urls = {
		"https://malarayat.com/golf-club/",
		"https://www.golfsavers.com/philippines/manila-golf-courses/mt-malarayat-golf-country-club",
		"https://malarayat.com/gallerycat/amenities/",
	} },
	{ id = 9, urls = {
		"https://www.wowbatangas.com/lipa-citys-hidden-gem-sitio-tagbakin-halang-lipa-city/",
	} },
}

-- Student identity for the board. pending = true shows the TO BE ADDED slot; set it false once all three are filled.
CreditsData.identity = { name = "", course = "", section = "", pending = true }

local PENDING_TEXT = "Name / Course / Section: TO BE ADDED"

local function filled(s)
	return type(s) == "string" and string.match(s, "%S") ~= nil
end

function CreditsData.identityText()
	local id = CreditsData.identity
	if id.pending or not (filled(id.name) and filled(id.course) and filled(id.section)) then
		return PENDING_TEXT
	end
	return id.name .. " - " .. id.course .. " - " .. id.section
end

-- Printable lines for the board: a title, one block per site (name then its source urls), then the identity slot.
-- `sites` is SiteData.sites; a missing site falls back to "Site N" instead of erroring.
function CreditsData.boardLines(sites)
	local names = {}
	for _, s in ipairs(sites or {}) do
		names[s.id] = s.name
	end
	local lines = { "PHOTO AND SOURCE CREDITS" }
	for _, entry in ipairs(CreditsData.sites) do
		table.insert(lines, entry.id .. ". " .. (names[entry.id] or ("Site " .. entry.id)))
		for _, url in ipairs(entry.urls) do
			table.insert(lines, url)
		end
	end
	table.insert(lines, CreditsData.identityText())
	return lines
end

return CreditsData
