-- Tests for ReplicatedStorage.LipaShared.CreditsData (static credits board data).
-- Structural only: the photo set and the student identity are both going to change before Ship, so these tests do not
-- pin a URL count or the identity text. The md-to-module equality is checked by a disk-side script, not here.
-- Contract: sites = { { id, urls = { "https://..." } } } ids 1..9 in order, >= 1 url each, no duplicate within a site, no spaces;
-- identity = { name, course, section, pending }; identityText() reads "TO BE ADDED" while pending, else name - course - section;
-- boardLines() returns the printable lines for the board (title, 9 site blocks, identity slot).
return function(t)
	local CreditsData = require(game.ReplicatedStorage.LipaShared.CreditsData:Clone())
	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
	local expect = t.expect

	t.test("there is one credits entry per site, ids 1..9 in order", function()
		expect.equal(#CreditsData.sites, 9)
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
end
