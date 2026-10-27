-- Tests for ReplicatedStorage.LipaShared.CreditsData (static credits board data).
-- Structural only: the photo set and the student identity are both going to change before Ship, so these tests do not
-- pin a URL count or the identity text. The md-to-module equality is checked by a disk-side script, not here.
-- Contract: sites = { { id, urls = { "https://..." } } } ids 1..10 in order, >= 1 url each, no duplicate within a site, no spaces;
-- projectLines = ASCII strings (City Hall photo source, blueprint note); tourSources = 25 { ref, text, url? } in ref order;
-- identity = { name, course, section, pending }; identityText() reads "TO BE ADDED" while pending, else name - course - section;
-- boardLines() returns the printable lines for the board (title, 10 site blocks, identity slot).
return function(t)
	local CreditsData = require(game.ReplicatedStorage.LipaShared.CreditsData:Clone())
	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
	local expect = t.expect

	t.test("there is one credits entry per site, ids 1..10 in order", function()
		expect.equal(#CreditsData.sites, 10)
		expect.equal(#CreditsData.sites, #SiteData.sites)
		for i, entry in ipairs(CreditsData.sites) do
			expect.equal(entry.id, i)
		end
	end)

	t.test("every site has at least one source url", function()
		for _, entry in ipairs(CreditsData.sites) do
			expect.truthy(type(entry.urls) == "table" and #entry.urls >= 1)
		end
	end)

	t.test("every url is https, has no whitespace and no markup characters", function()
		for _, entry in ipairs(CreditsData.sites) do
			for _, url in ipairs(entry.urls) do
				expect.truthy(string.sub(url, 1, 8) == "https://")
				expect.falsy(string.find(url, "%s"))
				expect.falsy(string.find(url, "[<>\"]"))
			end
		end
	end)

	t.test("no site lists the same url twice", function()
		for _, entry in ipairs(CreditsData.sites) do
			local seen = {}
			for _, url in ipairs(entry.urls) do
				expect.falsy(seen[url])
				seen[url] = true
			end
		end
	end)

	t.test("site 1 credits OpenStreetMap, whose footprints sized the Slice 14 rework (ODbL asks for attribution)", function()
		local found = false
		for _, url in ipairs(CreditsData.sites[1].urls) do
			if string.find(url, "https://www.openstreetmap.org/", 1, true) then found = true end
		end
		expect.truthy(found)
	end)

	t.test("site 5 credits OpenStreetMap, whose church footprint sized the Slice 15 Carmel rework (ODbL asks for attribution)", function()
		local found = false
		for _, url in ipairs(CreditsData.sites[5].urls) do
			if string.find(url, "https://www.openstreetmap.org/", 1, true) then found = true end
		end
		expect.truthy(found)
	end)

	t.test("site 2 credits the OpenStreetMap market way (465374399), whose footprint, height and roof colour sized the Slice 17 Market rework (ODbL)", function()
		local found = false
		for _, url in ipairs(CreditsData.sites[2].urls) do
			if url == "https://www.openstreetmap.org/way/465374399" then found = true end
		end
		expect.truthy(found)
	end)

	t.test("site 6 credits the Commons category and the LIMA Estate drone file that the Slice 16 Outlets rework drew on", function()
		local category, drone = false, false
		for _, url in ipairs(CreditsData.sites[6].urls) do
			if url == "https://commons.wikimedia.org/wiki/Category:The_Outlets_at_Lipa" then category = true end
			if url == "https://commons.wikimedia.org/wiki/File:LIMA_Estate_as_of_2025.jpg" then drone = true end
		end
		expect.truthy(category)
		expect.truthy(drone)
	end)

	t.test("credits are ASCII so the board and the typewriter-safe rules hold", function()
		for _, entry in ipairs(CreditsData.sites) do
			for _, url in ipairs(entry.urls) do
				expect.falsy(string.find(url, "[\128-\255]"))
			end
		end
	end)

	t.test("identity has name, course, section and a pending flag", function()
		local id = CreditsData.identity
		expect.truthy(type(id) == "table")
		expect.equal(type(id.pending), "boolean")
		expect.equal(type(id.name), "string")
		expect.equal(type(id.course), "string")
		expect.equal(type(id.section), "string")
	end)

	t.test("identityText says TO BE ADDED while pending", function()
		local saved = CreditsData.identity.pending
		CreditsData.identity.pending = true
		expect.truthy(string.find(CreditsData.identityText(), "TO BE ADDED", 1, true))
		CreditsData.identity.pending = saved
	end)

	t.test("identityText shows the three values once not pending", function()
		local id = CreditsData.identity
		local saved = { id.pending, id.name, id.course, id.section }
		id.pending, id.name, id.course, id.section = false, "Ana Santos", "ART 101", "BSCS 4A"
		local text = CreditsData.identityText()
		expect.truthy(string.find(text, "Ana Santos", 1, true))
		expect.truthy(string.find(text, "ART 101", 1, true))
		expect.truthy(string.find(text, "BSCS 4A", 1, true))
		expect.falsy(string.find(text, "TO BE ADDED", 1, true))
		id.pending, id.name, id.course, id.section = saved[1], saved[2], saved[3], saved[4]
	end)

	t.test("identityText cannot show a half-filled identity as final", function()
		local id = CreditsData.identity
		local saved = { id.pending, id.name, id.course, id.section }
		id.pending, id.name, id.course, id.section = false, "Ana Santos", "", "BSCS 4A" -- a blank field means still pending
		expect.truthy(string.find(CreditsData.identityText(), "TO BE ADDED", 1, true))
		id.pending, id.name, id.course, id.section = saved[1], saved[2], saved[3], saved[4]
	end)

	t.test("boardLines names every site and carries every url verbatim", function()
		local joined = table.concat(CreditsData.boardLines(SiteData.sites), "\n")
		for _, entry in ipairs(CreditsData.sites) do
			expect.truthy(string.find(joined, SiteData.byId(entry.id).name, 1, true))
			for _, url in ipairs(entry.urls) do
				expect.truthy(string.find(joined, url, 1, true)) -- plain find: urls contain pattern characters
			end
		end
		expect.truthy(string.find(joined, CreditsData.identityText(), 1, true))
	end)

	t.test("boardLines tolerates a sites list missing an entry without throwing", function()
		local partial = { SiteData.sites[1] }
		local lines = CreditsData.boardLines(partial)
		expect.truthy(type(lines) == "table" and #lines > 0)
	end)

	local function ascii(s)
		return type(s) == "string" and not string.find(s, "[\128-\255]")
	end

	t.test("site 10 credits the Google Street View reference", function()
		local urls = CreditsData.sites[10].urls
		local found = false
		for _, url in ipairs(urls) do
			if string.find(url, "https://www.google.com/maps", 1, true) == 1 then found = true end
		end
		expect.truthy(found)
	end)

	t.test("projectLines has the City Hall photo line and the blueprint line, exactly, in ASCII", function()
		local lines = CreditsData.projectLines
		expect.equal(type(lines), "table")
		expect.equal(#lines, 2)
		expect.equal(lines[1], "City Hall reference photos: Google Street View.")
		expect.equal(lines[2], "Site blueprints: AI-assisted concept drawings prepared by the group; used for massing only.")
		for _, line in ipairs(lines) do
			expect.truthy(ascii(line))
		end
	end)

	t.test("tourSources has the 25 PDF references, refs 1..25 in order", function()
		local src = CreditsData.tourSources
		expect.equal(type(src), "table")
		expect.equal(#src, 25)
		for i, entry in ipairs(src) do
			expect.equal(entry.ref, i)
		end
	end)

	t.test("every tour source has non-empty ASCII text and, when present, an https url without spaces", function()
		for _, entry in ipairs(CreditsData.tourSources) do
			expect.truthy(ascii(entry.text) and #entry.text > 0)
			if entry.url ~= nil then
				expect.truthy(ascii(entry.url))
				expect.equal(string.sub(entry.url, 1, 8), "https://")
				expect.falsy(string.find(entry.url, "%s"))
			end
		end
	end)

	t.test("no tour source is a [VERIFY] placeholder and none repeats a ref", function()
		local seen = {}
		for _, entry in ipairs(CreditsData.tourSources) do
			expect.falsy(string.find(entry.text, "VERIFY", 1, true))
			expect.falsy(seen[entry.ref])
			seen[entry.ref] = true
		end
	end)

	t.test("all credits strings (urls, project lines, sources) are ASCII", function()
		for _, entry in ipairs(CreditsData.sites) do
			for _, url in ipairs(entry.urls) do expect.truthy(ascii(url)) end
		end
		for _, line in ipairs(CreditsData.projectLines) do expect.truthy(ascii(line)) end
		for _, entry in ipairs(CreditsData.tourSources) do
			expect.truthy(ascii(entry.text))
			expect.truthy(entry.url == nil or ascii(entry.url))
		end
	end)

	-- APA 7 references (job credits-a): CreditsData.references = 78 { text, marked, url, aliases, sites, tour } in author order;
	-- `text` is the plain APA line, `marked` the same line with <i>..</i> around italic titles and &amp; &lt; &gt; escapes;
	-- referenceLines(marked) lists the `marked` (true) or `text` (false/nil) strings in order; noticeLines = 4 licence/notice lines.
	local REFERENCE_COUNT = 78
	local function refs()
		expect.equal(type(CreditsData.references), "table")
		return CreditsData.references
	end

	local function unmark(s)
		s = string.gsub(s, "<i>", "")
		s = string.gsub(s, "</i>", "")
		return s
	end

	t.test("references holds the 78 APA 7 entries as tables", function()
		local list = refs()
		expect.equal(#list, REFERENCE_COUNT)
		for _, ref in ipairs(list) do
			expect.equal(type(ref), "table")
		end
	end)

	t.test("every reference has non-empty text and marked, an https url, and aliases, sites and tour tables", function()
		for _, ref in ipairs(refs()) do
			expect.truthy(type(ref.text) == "string" and #ref.text > 0)
			expect.truthy(type(ref.marked) == "string" and #ref.marked > 0)
			expect.truthy(type(ref.url) == "string" and string.sub(ref.url, 1, 8) == "https://")
			expect.falsy(string.find(ref.url, "%s"))
			expect.equal(type(ref.aliases), "table")
			expect.equal(type(ref.sites), "table")
			expect.equal(type(ref.tour), "table")
			for _, alias in ipairs(ref.aliases) do
				expect.truthy(type(alias) == "string" and string.sub(alias, 1, 8) == "https://")
			end
		end
	end)

	t.test("reference text, marked and the notice lines are ASCII, and text carries no angle brackets", function()
		for _, ref in ipairs(refs()) do
			expect.truthy(ascii(ref.text))
			expect.truthy(ascii(ref.marked))
			expect.truthy(ascii(ref.url))
			expect.falsy(string.find(ref.text, "[<>]"))
		end
		expect.equal(type(CreditsData.noticeLines), "table")
		for _, line in ipairs(CreditsData.noticeLines) do
			expect.truthy(ascii(line))
		end
	end)

	t.test("marked equals text once <i> tags are removed and &amp; &lt; &gt; are unescaped, with no other markup characters", function()
		for _, ref in ipairs(refs()) do
			local bare = unmark(ref.marked)
			expect.falsy(string.find(bare, "[<>]"))
			local noEntities = string.gsub(string.gsub(string.gsub(bare, "&amp;", ""), "&lt;", ""), "&gt;", "")
			expect.falsy(string.find(noEntities, "&", 1, true))
			local plain = string.gsub(string.gsub(string.gsub(bare, "&lt;", "<"), "&gt;", ">"), "&amp;", "&")
			expect.equal(plain, ref.text)
		end
	end)

	t.test("every board url and every tour source url is the url or an alias of exactly one reference", function()
		local count = {}
		for _, ref in ipairs(refs()) do
			count[ref.url] = (count[ref.url] or 0) + 1
			for _, alias in ipairs(ref.aliases) do
				count[alias] = (count[alias] or 0) + 1
			end
		end
		for _, n in pairs(count) do
			expect.equal(n, 1) -- no url or alias is claimed by two references (or twice by one)
		end
		for _, entry in ipairs(CreditsData.sites) do
			for _, url in ipairs(entry.urls) do
				expect.equal(count[url], 1)
			end
		end
		for _, source in ipairs(CreditsData.tourSources) do
			if source.url ~= nil then
				expect.equal(count[source.url], 1)
			end
		end
	end)

	t.test("every tour source ref 1..25 appears in exactly one reference's tour list", function()
		local count = {}
		for _, ref in ipairs(refs()) do
			for _, n in ipairs(ref.tour) do
				count[n] = (count[n] or 0) + 1
			end
		end
		for _, source in ipairs(CreditsData.tourSources) do
			expect.equal(count[source.ref], 1)
		end
		for n in pairs(count) do
			expect.truthy(n >= 1 and n <= #CreditsData.tourSources) -- no tour number outside the 25 sources
		end
	end)

	t.test("every site id 1..10 owns at least one reference, and only valid site ids are used", function()
		local owned = {}
		for _, ref in ipairs(refs()) do
			for _, id in ipairs(ref.sites) do
				owned[id] = true
				expect.truthy(id >= 1 and id <= #CreditsData.sites)
			end
		end
		for _, entry in ipairs(CreditsData.sites) do
			expect.truthy(owned[entry.id])
		end
	end)

	t.test("references follow the APA 7 order: author part letter by letter (lower case letters and digits only), nondecreasing, and n.d. before dated for one author; no trailing-period workaround", function()
		local function author(text)
			local cut = string.find(text, " (", 1, true)
			expect.truthy(cut ~= nil) -- every APA line has "Author. (year"
			return (string.gsub(string.lower(string.sub(text, 1, cut - 1)), "[^%l%d]", ""))
		end
		local prevName, prevUndated = nil, false
		for _, ref in ipairs(refs()) do
			local name = author(ref.text)
			local undated = string.find(ref.text, " (n.d.", 1, true) ~= nil
			if prevName ~= nil then
				expect.truthy(prevName <= name)
				if prevName == name and undated then
					expect.truthy(prevUndated) -- an undated work must not follow a dated one by the same author
				end
			end
			prevName, prevUndated = name, undated
		end
	end)

	t.test("one reference is the Gemini entry, written exactly", function()
		local found = 0
		for _, ref in ipairs(refs()) do
			if ref.text == "Google. (n.d.-a). Gemini [Large language model]. https://gemini.google.com/" then found += 1 end
		end
		expect.equal(found, 1)
	end)

	t.test("referenceLines(true) and referenceLines(false) each list the 78 references in order", function()
		local list = refs()
		expect.equal(type(CreditsData.referenceLines), "function")
		local marked = CreditsData.referenceLines(true)
		local plain = CreditsData.referenceLines(false)
		expect.equal(#marked, REFERENCE_COUNT)
		expect.equal(#plain, REFERENCE_COUNT)
		for i, ref in ipairs(list) do
			expect.equal(marked[i], ref.marked)
			expect.equal(plain[i], ref.text)
		end
	end)

	t.test("referenceLines with no argument gives the plain text, and returns a fresh list each call", function()
		local first = CreditsData.referenceLines()
		expect.equal(#first, REFERENCE_COUNT)
		expect.equal(first[1], refs()[1].text)
		first[1] = "changed"
		expect.equal(CreditsData.referenceLines()[1], refs()[1].text) -- editing a returned list must not touch the data
		expect.equal(CreditsData.references[1].text, refs()[1].text)
	end)

	t.test("noticeLines has the four notice lines, exactly", function()
		local lines = CreditsData.noticeLines
		expect.equal(type(lines), "table")
		expect.equal(#lines, 4)
		expect.equal(lines[1], "Map data (c) OpenStreetMap contributors, available under the Open Database License (ODbL 1.0): https://www.openstreetmap.org/copyright")
		expect.equal(lines[2], "Imagery and map data from Google Maps, Google Earth and Street View belong to Google and its data providers.")
		expect.equal(lines[3], "Wikimedia Commons photographs keep the licence named in their reference (CC BY-SA 3.0, CC BY-SA 4.0 or CC0).")
		expect.equal(lines[4], "Reference photos also come from the sites themselves and public web pages; they were used only as visual reference and no photo is used as a texture in the experience.")
	end)
end
