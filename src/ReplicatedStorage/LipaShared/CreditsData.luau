-- CreditsData: static data for the CreditsBoard (ten sites, project lines, and the 25 tour sources). Source pages are transcribed from content/site_credits.md
-- (generated from SOURCES.csv); a disk-side script checks the two stay equal. The student identity is filled in before Ship.
local CreditsData = {}

CreditsData.sites = {
	{ id = 1, urls = {
		"https://commons.wikimedia.org/wiki/Category:Lipa_Cathedral",
		"https://lipacitybatangas.blogspot.com/2012/10/all-about-lipa-city-batangas.html",
		"https://commons.wikimedia.org/wiki/Category:Aerial_photographs_of_Lipa_Cathedral",
		"https://www.openstreetmap.org/way/249138738",
	} },
	{ id = 2, urls = {
		"https://jeromedoe.blogspot.com/2014/04/sidetrip-candido-lopez-public-market-in.html",
		"https://www.flickr.com/photos/25609128@N07/4798040027",
		"https://www.flickr.com/photos/25609128@N07/5578415545",
		"https://www.openstreetmap.org/way/465374399",
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
		"https://www.openstreetmap.org/way/157078294",
	} },
	{ id = 6, urls = {
		"https://architizer.com/projects/the-outlets-at-lipa/",
		"https://commons.wikimedia.org/wiki/Category:The_Outlets_at_Lipa",
		"https://commons.wikimedia.org/wiki/File:LIMA_Estate_as_of_2025.jpg",
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
	{ id = 10, urls = {
		"https://www.google.com/maps",
	} },
}

-- Project-level credit lines (not tied to one url): the City Hall photo source and the blueprint note. ASCII only.
CreditsData.projectLines = {
	"City Hall reference photos: Google Street View.",
	"Site blueprints: AI-assisted concept drawings prepared by the group; used for massing only.",
}

-- The 25 numbered References from the group's tour-script PDF (Detail Reference/more details.pdf), in the PDF's order and as
-- printed (publisher, "title", date when given), with the url on its own field. TourContent's pdfRef numbers point at these refs.
CreditsData.tourSources = {
	{ ref = 1, text = "Daily Tribune. \"Lipa inaugurates new City Hall in Areza.\" April 13, 2026.", url = "https://tribune.net.ph/2026/04/13/lipa-inaugurates-new-city-hall-in-areza" },
	{ ref = 2, text = "Ayala Land. \"Areza in New City Center Lipa.\"", url = "https://ayalaland.com/estates/areza" },
	{ ref = 3, text = "Inquirer.net (advertorial). \"ALI welcomes new Lipa City Hall and trading center in Areza estate.\"", url = "https://business.inquirer.net/353940/ali-welcomes-new-lipa-city-hall-and-trading-center-in-areza-estate" },
	{ ref = 4, text = "Ayala Land. \"Ayala Land breaks ground on 92-hectare estate in Lipa.\"", url = "https://ayalaland.com/blog/ayala-land-breaks-ground-on-92-hectare-estate-in-lipa" },
	{ ref = 5, text = "Wikipedia. \"Lipa, Batangas.\"", url = "https://en.wikipedia.org/wiki/Lipa,_Batangas" },
	{ ref = 6, text = "Philippine Information Agency. \"Kape, lomi at pasyalan, tampok sa probinsya ng Batangas.\" October 25, 2022.", url = "https://mirror.pia.gov.ph/features/2022/10/25/kape-lomi-at-pasyalan-tampok-sa-probinsya-ng-batangas" },
	{ ref = 7, text = "Batangas History, Culture and Folklore. \"History and origin of Batangas lomi.\"", url = "https://www.batangashistory.date/2022/05/history-and-origin-of-batangas-lomi.html" },
	{ ref = 8, text = "Wikipedia. \"Lomi.\"", url = "https://en.wikipedia.org/wiki/Lomi" },
	{ ref = 9, text = "The Poor Traveler. \"Lomi King, Lipa City.\" 2012.", url = "https://www.thepoortraveler.net/?p=3102" },
	{ ref = 10, text = "Traveloka. \"Start the day by enjoying the scent of coffee... Lipa City.\"", url = "https://www.traveloka.com/en-ph/explore/destination/start-the-day-by-enjoying-the-scent-of-coffee-while-strolling-around-to-enjoy-the-historical-stories-of-lipa-city/302025" },
	{ ref = 11, text = "The Poor Traveler. \"Cafe de Lipa: Kapeng Barako and Batangas history.\" April 9, 2012.", url = "https://www.thepoortraveler.net/?p=1447" },
	{ ref = 12, text = "Wikipedia. \"Kapeng barako.\"", url = "https://en.wikipedia.org/wiki/Kapeng_barako" },
	{ ref = 13, text = "Batangas History, Culture and Folklore. \"What ended Lipa's coffee boom.\" 2024.", url = "https://www.batangashistory.date/2024/04/what-ended-lipas-coffee-boom.html" },
	{ ref = 14, text = "Wikivoyage. \"Lipa.\"", url = "https://en.wikivoyage.org/wiki/Lipa" },
	{ ref = 15, text = "Batangas History, Culture and Folklore. \"Photo of the completed Lipa public market, July 1914.\"", url = "https://www.batangashistory.date/2022/06/photo-of-the-completed-lipa-public-market-july-1914.html" },
	{ ref = 16, text = "Wikipedia. \"Lipa Cathedral.\"", url = "https://en.wikipedia.org/wiki/Lipa_Cathedral" },
	{ ref = 17, text = "City Government of Lipa. \"The City.\"", url = "https://lipa.gov.ph/city/" },
	{ ref = 18, text = "Aboitiz Economic Estates. \"The Outlets @ LIMA Estate.\" March 4, 2025.", url = "https://www.aboitizeconomicestates.com/outlets-at-lima-estate/" },
	{ ref = 19, text = "Marriott. \"The Farm at San Benito, Autograph Collection: Experiences.\"", url = "https://www.marriott.com/en-us/hotels/mnlfs-the-farm-at-san-benito-autograph-collection/experiences/" },
	{ ref = 20, text = "City Government of Lipa. \"Barangay Profiles.\"", url = "https://lipa.gov.ph/barangay-profiles/" },
	{ ref = 21, text = "Mount Malarayat Golf & Country Club. \"Contact.\"", url = "https://malarayat.com/contact/" },
	{ ref = 22, text = "Golf Today. \"Mount Malarayat Golf & Country Club.\"", url = "https://golftoday.co.uk/course/asia/philippines/batangas/mount-malarayat-golf-amp-country-club/" },
	{ ref = 23, text = "Discalced Carmelites. \"Lipa Carmel's 75th anniversary of foundation.\" June 24, 2021.", url = "https://www.carmelitaniscalzi.com/en/2021/06/24/lipa-carmels-75th-anniversary-of-foundation-written-by-the-sisters-of-lipa/" },
	{ ref = 24, text = "Wikipedia. \"Mary, Mediatrix of All Grace.\"", url = "https://en.wikipedia.org/wiki/Mary,_Mediatrix_of_All_Grace" },
	{ ref = 25, text = "Inquirer.net. \"Tawilis' 2-month fishing ban in Taal Lake in Batangas ends.\" May 1, 2024.", url = "https://newsinfo.inquirer.net/1935763/tawilis-2-month-fishing-ban-in-taal-lake-in-batangas-ends" },
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
