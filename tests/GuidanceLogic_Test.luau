-- Tests for ReplicatedStorage.LipaShared.GuidanceLogic (pure; plain Vector3s, positions from SiteData, no Instances).
-- Why (playtest 2026-10-31): a first-time player had nothing telling them where to go after Ate Joy, and the Market, Lomi King
-- and Cafe (no jeep stop, not in the jeep menu, no sign) could not be found at all.
-- Contract: ORDER = { 10, 1, 2, 3, 4, 5, 6, 7, 8, 9 }. nextSite(stampedIds) -> the first id of ORDER not stamped, or nil when all
-- ten are; anything that is not a valid site id is ignored. compass(from, to) -> one of 8 words (north = -Z, east = +X).
-- plain(s) -> ASCII only (e-acute folded to e, other non-ASCII dropped). jeepTarget(id) -> the stop to ride to for that site
-- (1, the Plaza, for the walk-only shops 2, 3, 4; the site itself if it has a stop; nil otherwise).
-- hint(stampedIds, playerPos) -> { siteId, mode, point, text } with mode "talk", "walk", "stairs", "jeep" or "done".
return function(t)
	local GuidanceLogic = require(game.ReplicatedStorage.LipaShared.GuidanceLogic:Clone())
	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
	local expect = t.expect

	local SPAWN = Vector3.new(-208, 3, -260) -- the City Hall pad
	local PLAZA_STOP = Vector3.new(-20, 5, 30) -- where the jeepney leaves you at the Cathedral
	local ALL = { 10, 1, 2, 3, 4, 5, 6, 7, 8, 9 }

	local function has(text, piece)
		return type(text) == "string" and string.find(text, piece, 1, true) ~= nil
	end
	local function near(a, b, tol)
		return a ~= nil and b ~= nil and (Vector3.new(a.X, 0, a.Z) - Vector3.new(b.X, 0, b.Z)).Magnitude <= (tol or 0.01)
	end

	t.test("ORDER starts at City Hall, then the Plaza, the three shops and the far sites, every site once", function()
		expect.deepEqual(GuidanceLogic.ORDER, ALL)
		local seen = {}
		for _, id in ipairs(GuidanceLogic.ORDER) do
			expect.truthy(SiteData.byId(id))
			expect.falsy(seen[id])
			seen[id] = true
		end
		expect.equal(#GuidanceLogic.ORDER, #SiteData.sites)
	end)

	t.test("nextSite: nothing stamped (or nil) sends the player to City Hall", function()
		expect.equal(GuidanceLogic.nextSite(nil), 10)
		expect.equal(GuidanceLogic.nextSite({}), 10)
	end)

	t.test("nextSite follows ORDER and skips stamps collected out of order", function()
		expect.equal(GuidanceLogic.nextSite({ 10 }), 1)
		expect.equal(GuidanceLogic.nextSite({ 10, 1, 2 }), 3)
		expect.equal(GuidanceLogic.nextSite({ 1, 10, 3 }), 2)
		expect.equal(GuidanceLogic.nextSite({ 10, 1, 2, 3, 4, 6, 7 }), 5)
	end)

	t.test("nextSite ignores invalid ids, duplicates and non-numbers", function()
		expect.equal(GuidanceLogic.nextSite({ 10, 99, -1, 2.5, "1", 0 / 0, 10, 10 }), 1)
		expect.equal(GuidanceLogic.nextSite("10,1"), 10)
	end)

	t.test("nextSite is nil when all ten are stamped", function()
		expect.equal(GuidanceLogic.nextSite(ALL), nil)
	end)

	t.test("compass names all eight directions with north = -Z and east = +X", function()
		local o = Vector3.new(0, 0, 0)
		expect.equal(GuidanceLogic.compass(o, Vector3.new(0, 0, -10)), "north")
		expect.equal(GuidanceLogic.compass(o, Vector3.new(10, 0, -10)), "north-east")
		expect.equal(GuidanceLogic.compass(o, Vector3.new(10, 0, 0)), "east")
		expect.equal(GuidanceLogic.compass(o, Vector3.new(10, 0, 10)), "south-east")
		expect.equal(GuidanceLogic.compass(o, Vector3.new(0, 0, 10)), "south")
		expect.equal(GuidanceLogic.compass(o, Vector3.new(-10, 0, 10)), "south-west")
		expect.equal(GuidanceLogic.compass(o, Vector3.new(-10, 0, 0)), "west")
		expect.equal(GuidanceLogic.compass(o, Vector3.new(-10, 0, -10)), "north-west")
		expect.equal(GuidanceLogic.compass(o, Vector3.new(0, 50, -10)), "north") -- height is ignored
	end)

	t.test("plain folds e-acute to e and drops other non-ASCII", function()
		expect.equal(GuidanceLogic.plain("Caf\u{E9} de Lipa"), "Cafe de Lipa")
		expect.equal(GuidanceLogic.plain("a\u{2014}b"), "ab")
		expect.equal(GuidanceLogic.plain(SiteData.byId(4).name), "Cafe de Lipa")
		expect.equal(GuidanceLogic.plain(nil), "")
	end)

	t.test("jeepTarget sends the walk-only shops to the Plaza stop and the others to their own stop", function()
		expect.equal(GuidanceLogic.jeepTarget(2), 1)
		expect.equal(GuidanceLogic.jeepTarget(3), 1)
		expect.equal(GuidanceLogic.jeepTarget(4), 1)
		for _, id in ipairs({ 1, 5, 6, 7, 8, 9, 10 }) do
			expect.equal(GuidanceLogic.jeepTarget(id), id)
		end
		expect.equal(GuidanceLogic.jeepTarget(nil), nil)
		expect.equal(GuidanceLogic.jeepTarget(11), nil)
	end)

	t.test("hint at the spawn with no stamps: walk to Ate Joy at City Hall, pin on her", function()
		local h = GuidanceLogic.hint({}, SPAWN)
		expect.equal(h.siteId, 10)
		expect.truthy(h.mode == "walk" or h.mode == "talk")
		expect.truthy(near(h.point, SiteData.guidePos(10)))
		expect.truthy(has(h.text, "New Lipa City Hall"))
	end)

	t.test("hint right beside a guide says talk to the guide", function()
		local g = SiteData.guidePos(10)
		local h = GuidanceLogic.hint({}, g + Vector3.new(3, 0, 3))
		expect.equal(h.mode, "talk")
		expect.equal(h.text, "Next: Talk to the guide at New Lipa City Hall.")
	end)

	t.test("hint after Ate Joy: ride the jeepney to the Plaza, pin on the City Hall stop", function()
		local h = GuidanceLogic.hint({ 10 }, SPAWN)
		expect.equal(h.siteId, 1)
		expect.equal(h.mode, "jeep")
		expect.truthy(near(h.point, SiteData.jeepStopPos(10)))
		expect.equal(h.text, "Next: Ride the jeepney to Plaza Independencia & Metropolitan Cathedral.")
	end)

	t.test("hint at the Plaza stop with the Plaza next: walk to its guide", function()
		local h = GuidanceLogic.hint({ 10 }, PLAZA_STOP)
		expect.equal(h.siteId, 1)
		expect.truthy(h.mode == "walk" or h.mode == "talk")
		expect.truthy(near(h.point, SiteData.guidePos(1)))
	end)

	t.test("hint inside the fenced Plaza with the Market next: the west side stairs first", function()
		local h = GuidanceLogic.hint({ 10, 1 }, PLAZA_STOP)
		expect.equal(h.siteId, 2)
		expect.equal(h.mode, "stairs")
		expect.truthy(h.point.X < -120)
		expect.equal(h.text, "Next: Leave the Plaza by the west side stairs, then walk to Candido B. Lopez Memorial Public Market.")
	end)

	t.test("hint inside the Plaza with Lomi King or the Cafe next: the east side stairs first", function()
		local h3 = GuidanceLogic.hint({ 10, 1, 2 }, PLAZA_STOP)
		expect.equal(h3.mode, "stairs")
		expect.truthy(h3.point.X > 120)
		expect.truthy(has(h3.text, "east side stairs") and has(h3.text, "Lomi King"))
		local h4 = GuidanceLogic.hint({ 10, 1, 2, 3 }, PLAZA_STOP)
		expect.truthy(h4.point.X > 120)
		expect.truthy(has(h4.text, "Cafe de Lipa"))
	end)

	t.test("hint outside the Plaza near a shop: walk with a compass word, pin on the shop guide", function()
		local from = Vector3.new(-160, 1, 100)
		local h = GuidanceLogic.hint({ 10, 1 }, from)
		expect.equal(h.mode, "walk")
		expect.truthy(near(h.point, SiteData.guidePos(2)))
		local dir = GuidanceLogic.compass(from, SiteData.guidePos(2))
		expect.equal(h.text, "Next: Walk " .. dir .. " to the guide at Candido B. Lopez Memorial Public Market.")
	end)

	t.test("hint far from a shop: ride to the Plaza, then walk, pin on the nearest stop", function()
		local h = GuidanceLogic.hint({ 10, 1, 2 }, SPAWN)
		expect.equal(h.siteId, 3)
		expect.equal(h.mode, "jeep")
		expect.truthy(near(h.point, SiteData.jeepStopPos(10)))
		expect.equal(h.text, "Next: Ride the jeepney to the Plaza, then walk east to Lomi King.")
	end)

	t.test("hint for a far site from the Plaza: ride the jeepney, pin on the Plaza stop", function()
		local h = GuidanceLogic.hint({ 10, 1, 2, 3, 4 }, PLAZA_STOP)
		expect.equal(h.siteId, 5)
		expect.equal(h.mode, "jeep")
		expect.truthy(near(h.point, SiteData.jeepStopPos(1)))
		expect.equal(h.text, "Next: Ride the jeepney to Monastery of Our Lady of Mount Carmel.")
	end)

	t.test("hint pins sit on the site's ground height (Malarayat is at 19.8)", function()
		local stamps = { 10, 1, 2, 3, 4, 5, 6, 7 }
		local h = GuidanceLogic.hint(stamps, SiteData.guidePos(8) + Vector3.new(30, 0, 0))
		expect.equal(h.siteId, 8)
		expect.near(h.point.Y, 19.8, 0.01)
	end)

	t.test("hint with all ten stamped points to the certificate and has no pin", function()
		local h = GuidanceLogic.hint(ALL, SPAWN)
		expect.equal(h.mode, "done")
		expect.equal(h.siteId, nil)
		expect.equal(h.point, nil)
		expect.equal(h.text, "All 10 stamps! Open your Certificate.")
	end)

	t.test("hint without a player position still names the next site and pins its guide", function()
		local h = GuidanceLogic.hint({ 10 }, nil)
		expect.equal(h.siteId, 1)
		expect.truthy(near(h.point, SiteData.guidePos(1)))
		expect.equal(h.text, "Next: Find the guide at Plaza Independencia & Metropolitan Cathedral.")
	end)

	t.test("every hint text is plain ASCII and at most 120 characters", function()
		local spots = { SPAWN, PLAZA_STOP, Vector3.new(700, 0, 240), Vector3.new(-600, 0, 550), Vector3.new(250, 0, 0) }
		for n = 0, #ALL do
			local stamps = table.move(ALL, 1, n, 1, {})
			for _, p in ipairs(spots) do
				local h = GuidanceLogic.hint(stamps, p)
				expect.truthy(type(h.text) == "string" and #h.text > 0 and #h.text <= 120)
				expect.equal(string.find(h.text, "[\128-\255]"), nil)
			end
		end
	end)
end
