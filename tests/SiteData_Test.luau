-- Tests for ReplicatedStorage.LipaShared.SiteData.
-- Contract source: structure_model_positioning.png + the approved plan (Market shifted to -230,160).
return function(t)
	-- :Clone() so an edited SiteData is never shadowed by the require cache of an earlier run in the same Studio session.
	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
	local expect = t.expect

	local FACINGS = { N = true, S = true, E = true, W = true, NE = true, NW = true, SE = true, SW = true }

	local function footprint(s)
		return s.pos.X - s.size.X / 2, s.pos.X + s.size.X / 2, s.pos.Z - s.size.Y / 2, s.pos.Z + s.size.Y / 2
	end

	-- The world has exactly ten sites (Slice 3b added New Lipa City Hall as id 10) with unique ids.
	t.test("has ten sites with unique ids", function()
		expect.equal(#SiteData.sites, 10)
		local seen = {}
		for _, s in ipairs(SiteData.sites) do
			expect.falsy(seen[s.id])
			seen[s.id] = true
		end
	end)

	-- Layout legend: Eat 3, Pray 2, Love 4, plus the Welcome gateway (City Hall) 1.
	t.test("category split is Welcome 1 / Eat 3 / Pray 2 / Love 4", function()
		local c = { Welcome = 0, Eat = 0, Pray = 0, Love = 0 }
		for _, s in ipairs(SiteData.sites) do
			expect.truthy(c[s.category] ~= nil)
			c[s.category] += 1
		end
		expect.equal(c.Welcome, 1)
		expect.equal(c.Eat, 3)
		expect.equal(c.Pray, 2)
		expect.equal(c.Love, 4)
	end)

	-- Exact assignment from the layout png legend (counts alone would let a wrong split pass).
	t.test("categories match the layout legend per site", function()
		local expected = { [1] = "Pray", [2] = "Eat", [3] = "Eat", [4] = "Eat", [5] = "Pray",
			[6] = "Love", [7] = "Love", [8] = "Love", [9] = "Love", [10] = "Welcome" }
		for id, cat in pairs(expected) do
			expect.equal(SiteData.byId(id).category, cat)
		end
	end)

	-- Positions and facings from the layout table, except the three core shops, which Slice 14 pushed out from the Cathedral
	-- (Market -230 -> -330, Lomi 180 -> 292, Cafe 160 -> 272; the user's call after seeing the town core crowded).
	t.test("positions and facings match the layout", function()
		local expected = {
			[1] = { 0, 0, "S" }, [2] = { -330, 160, "E" }, [3] = { 292, 140, "W" },
			[4] = { 272, -160, "W" }, [5] = { -300, -600, "S" }, [6] = { 550, -650, "SW" },
			[7] = { 700, 240, "W" }, [8] = { 560, 720, "NW" }, [9] = { -600, 550, "NE" },
			[10] = { -250, -260, "E" },
		}
		for id, e in pairs(expected) do
			local s = SiteData.byId(id)
			expect.equal(s.pos.X, e[1])
			expect.equal(s.pos.Z, e[2])
			expect.equal(s.facing, e[3])
		end
	end)

	-- groundY is a number, and pos.Y equals it (the site pivot sits at groundY).
	t.test("groundY is numeric and matches pos.Y; flat sites sit at 0", function()
		for _, s in ipairs(SiteData.sites) do
			expect.equal(type(s.groundY), "number")
			expect.near(s.pos.Y, s.groundY, 1e-4) -- Vector3 stores float32
			if s.id ~= 8 then expect.equal(s.groundY, 0) end
		end
		expect.truthy(SiteData.byId(8).groundY > 5)
	end)

	-- Display fields are arrays of non-empty strings (BuildCheck later matches props by name).
	t.test("credits and requiredProps are arrays of non-empty strings", function()
		for _, s in ipairs(SiteData.sites) do
			for _, field in ipairs({ s.credits, s.requiredProps }) do
				for _, v in ipairs(field) do
					expect.equal(type(v), "string")
					expect.truthy(#v > 0)
				end
			end
			expect.equal(type(s.panelText), "string")
			expect.truthy(#s.panelText > 0)
			expect.equal(type(s.name), "string")
			expect.equal(type(s.guideName), "string")
		end
	end)

	-- Every facing maps to the expected world-space look direction (diagonals included).
	t.test("facingToYaw gives the right look vector for all eight facings", function()
		local r = 1 / math.sqrt(2)
		local dirs = {
			N = Vector3.new(0, 0, -1), S = Vector3.new(0, 0, 1), E = Vector3.new(1, 0, 0), W = Vector3.new(-1, 0, 0),
			NE = Vector3.new(r, 0, -r), NW = Vector3.new(-r, 0, -r), SE = Vector3.new(r, 0, r), SW = Vector3.new(-r, 0, r),
		}
		for f, v in pairs(dirs) do
			local look = CFrame.Angles(0, SiteData.facingToYaw(f), 0).LookVector
			expect.near(look.X, v.X, 1e-4)
			expect.near(look.Z, v.Z, 1e-4)
		end
	end)

	-- Unknown facings are an error, not a silent default.
	t.test("facingToYaw throws on unknown facing", function()
		expect.throws(function() SiteData.facingToYaw("UP") end)
		expect.throws(function() SiteData.facingToYaw(nil) end)
	end)

	-- Every footprint stays inside the 2000x2000 world.
	t.test("footprints are inside +/-1000", function()
		for _, s in ipairs(SiteData.sites) do
			local x0, x1, z0, z1 = footprint(s)
			expect.truthy(x0 >= -1000 and x1 <= 1000 and z0 >= -1000 and z1 <= 1000)
		end
	end)

	-- No two footprints overlap, and each pair keeps at least a 10-stud gap.
	t.test("pairwise footprint gap is at least 10 studs", function()
		for i = 1, #SiteData.sites do
			for j = i + 1, #SiteData.sites do
				local a0, a1, az0, az1 = footprint(SiteData.sites[i])
				local b0, b1, bz0, bz1 = footprint(SiteData.sites[j])
				local gap = math.max(b0 - a1, a0 - b1, bz0 - az1, az0 - bz1)
				expect.truthy(gap >= 10)
			end
		end
	end)

	-- The Market moved from -220 to -230 (Slice 06) and then to -330 (Slice 14) to give the town core room.
	t.test("market sits at -330,160", function()
		local m = SiteData.byId(2)
		expect.equal(m.pos.X, -330)
		expect.equal(m.pos.Z, 160)
	end)

	-- Slice 14: the Market, Lomi King and Cafe were 10-20 studs from the Cathedral compound, which looked crowded. The town core
	-- keeps at least 100 studs of clear space between any two of the four footprints.
	t.test("core shops keep 100+ studs from the Cathedral footprint and from each other", function()
		local core = { 1, 2, 3, 4 }
		for i = 1, #core do
			for j = i + 1, #core do
				local a0, a1, az0, az1 = footprint(SiteData.byId(core[i]))
				local b0, b1, bz0, bz1 = footprint(SiteData.byId(core[j]))
				local gap = math.max(b0 - a1, a0 - b1, bz0 - az1, az0 - bz1)
				expect.truthy(gap >= 100)
			end
		end
	end)

	-- Facing must be one of the eight compass values.
	t.test("facing is a valid compass value", function()
		for _, s in ipairs(SiteData.sites) do
			expect.truthy(FACINGS[s.facing])
		end
	end)

	-- North is -Z, East is +X.
	t.test("facingToYaw maps N to -Z and E to +X", function()
		local n = CFrame.Angles(0, SiteData.facingToYaw("N"), 0).LookVector
		local e = CFrame.Angles(0, SiteData.facingToYaw("E"), 0).LookVector
		expect.near(n.Z, -1, 1e-4)
		expect.near(e.X, 1, 1e-4)
	end)

	-- Per-site scale is bounded so human-scale parts stay sane.
	t.test("massScale is between 1.5 and 4", function()
		for _, s in ipairs(SiteData.sites) do
			expect.truthy(s.massScale >= 1.5 and s.massScale <= 4)
		end
	end)

	-- Guides need 2+ non-empty lines, each short enough for the dialogue box.
	t.test("dialogue has at least 2 lines of at most 220 chars", function()
		for _, s in ipairs(SiteData.sites) do
			expect.truthy(#s.dialogue >= 2)
			for _, line in ipairs(s.dialogue) do
				expect.truthy(#line > 0 and #line <= 220)
			end
		end
	end)

	-- Credits and required display props are mandatory content.
	t.test("every site has credits and required props", function()
		for _, s in ipairs(SiteData.sites) do
			expect.truthy(#s.credits > 0)
			expect.truthy(#s.requiredProps > 0)
		end
	end)

	-- Unknown ids are rejected, not silently defaulted.
	t.test("byId returns nil for unknown ids", function()
		expect.equal(SiteData.byId(0), nil)
		expect.equal(SiteData.byId(11), nil)
		expect.equal(SiteData.byId(-1), nil)
		expect.equal(SiteData.byId(1.5), nil)
		expect.equal(SiteData.byId(0 / 0), nil)
		expect.equal(SiteData.byId("2"), nil)
		expect.equal(SiteData.byId(nil), nil)
	end)

	-- Jeep stops exist for the plaza, the five outer sites and City Hall, inside their footprint.
	t.test("jeepStopPos is inside the footprint for sites 1, 5-9 and 10", function()
		for _, id in ipairs({ 1, 5, 6, 7, 8, 9, 10 }) do
			local s = SiteData.byId(id)
			local p = SiteData.jeepStopPos(id)
			local x0, x1, z0, z1 = footprint(s)
			expect.truthy(p.X >= x0 and p.X <= x1 and p.Z >= z0 and p.Z <= z1)
		end
		expect.equal(SiteData.jeepStopPos(2), nil)
	end)

	-- ---- Slice 12 content gate: the approved guide text ----

	local function joined(s)
		return table.concat(s.dialogue, "\n") .. "\n" .. s.panelText
	end

	-- The typewriter in GuideClient slices lines by byte, so a multibyte character would be cut mid-glyph.
	t.test("dialogue lines are pure ASCII", function()
		for _, s in ipairs(SiteData.sites) do
			for i, line in ipairs(s.dialogue) do
				for p = 1, #line do
					expect.truthy(string.byte(line, p) <= 127)
				end
			end
		end
	end)

	-- No draft tags or placeholders may reach the player.
	t.test("no dialogue or panel text carries draft markers", function()
		for _, s in ipairs(SiteData.sites) do
			for _, line in ipairs(s.dialogue) do
				expect.falsy(string.find(line, "[", 1, true))
				expect.falsy(string.find(string.upper(line), "VERIFY", 1, true))
				expect.falsy(string.find(string.upper(line), "PLACEHOLDER", 1, true))
			end
			expect.falsy(string.find(s.panelText, "[", 1, true))
			expect.falsy(string.find(string.upper(s.panelText), "PLACEHOLDER", 1, true))
		end
	end)

	-- Professor's feedback: short descriptions plus one sourced trivia line. Every guide gets three lines (what it is and why
	-- it matters, "Did you know?", then the "Look" line). Carmel gets five so each reported event stays next to the Church
	-- ruling on it.
	t.test("line counts are 5 for Carmel and 3 elsewhere", function()
		for _, s in ipairs(SiteData.sites) do
			expect.equal(#s.dialogue, s.id == 5 and 5 or 3)
		end
	end)

	-- The trivia line comes just before the last line, and the last line points the player at the model.
	t.test("every guide ends with a Did you know? line and then a Look prompt", function()
		for _, s in ipairs(SiteData.sites) do
			expect.equal(string.sub(s.dialogue[#s.dialogue - 1], 1, 14), "Did you know? ")
			expect.equal(string.sub(s.dialogue[#s.dialogue], 1, 4), "Look")
		end
	end)

	-- Tagbakin: the shoreline building is described generically; glamping is not sourced anywhere we opened.
	t.test("no text mentions glamping", function()
		for _, s in ipairs(SiteData.sites) do
			expect.falsy(string.find(string.lower(joined(s)), "glamp", 1, true))
		end
	end)

	t.test("Cafe interior is labelled representative", function()
		expect.truthy(string.find(joined(SiteData.byId(4)), "representative", 1, true))
	end)

	t.test("Market text notes the 2014 photo date", function()
		expect.truthy(string.find(table.concat(SiteData.byId(2).dialogue, " "), "2014", 1, true))
	end)

	-- Slice 14: the Cathedral model has paired round columns (not pilasters), butter-yellow walls, and the guide stands on the
	-- forecourt above Plaza Independencia, down a flight of steps.
	t.test("Cathedral dialogue describes the reworked model: columns, yellow walls, the steps down to the plaza", function()
		local c = SiteData.byId(1)
		local text = table.concat(c.dialogue, " ")
		expect.truthy(string.find(text, "columns", 1, true))
		expect.falsy(string.find(string.lower(text), "pilaster", 1, true))
		expect.falsy(string.find(text, "cream walls", 1, true))
		expect.truthy(string.find(text, "yellow", 1, true))
		expect.truthy(string.find(c.dialogue[1], "steps", 1, true))
		expect.truthy(string.find(c.dialogue[1], "Plaza Independencia", 1, true))
	end)

	t.test("Carmel guide says she is not a nun and the founding date is exact", function()
		local c = SiteData.byId(5)
		expect.truthy(string.find(c.dialogue[1], "not a nun", 1, true))
		expect.truthy(string.find(c.dialogue[1], "May 31, 1946", 1, true))
		expect.truthy(string.find(c.panelText, "May 31, 1946", 1, true))
	end)

	-- Carmel's rulings stay as reported: the 1948 reports share a line with the 1951 finding, and the 2015 declaration
	-- shares a line with the Holy See's rejection, so no claim is shown without its ruling.
	t.test("Carmel dialogue covers 1948, 1951 and 2015 in order", function()
		local d = SiteData.byId(5).dialogue
		local at1948 = string.find(d[2], "1948", 1, true)
		local at1951 = string.find(d[2], "1951", 1, true)
		expect.truthy(at1948 and at1951 and at1948 < at1951)
		expect.truthy(string.find(d[3], "2015", 1, true))
		expect.truthy(string.find(d[3], "rejected", 1, true))
	end)

	-- ---- Slice 3b: New Lipa City Hall (id 10) ----

	t.test("byId(10) is New Lipa City Hall, key CityHall, Welcome, Ate Joy, size 200x140", function()
		local c = SiteData.byId(10)
		expect.truthy(c)
		expect.equal(c.id, 10)
		expect.equal(c.key, "CityHall")
		expect.equal(c.name, "New Lipa City Hall")
		expect.equal(c.category, "Welcome")
		expect.equal(c.guideName, "Ate Joy")
		expect.equal(c.size, Vector2.new(200, 140))
		expect.equal(c.facing, "E")
		expect.equal(c.groundY, 0)
	end)

	t.test("hasJeepStop is true for 10 and false for 11, 0 and junk", function()
		expect.equal(SiteData.hasJeepStop(10), true)
		expect.equal(SiteData.hasJeepStop(11), false)
		expect.equal(SiteData.hasJeepStop(0), false)
		expect.equal(SiteData.hasJeepStop(nil), false)
		expect.equal(SiteData.hasJeepStop("10"), false)
		expect.equal(SiteData.jeepStopPos(11), nil)
		expect.equal(SiteData.guidePos(11), nil)
		expect.equal(SiteData.guidePos(0), nil)
	end)

	-- The old formulas, restated independently: guide 30 studs ahead, jeep stop 20 studs to the right of the guide.
	t.test("the other nine rows keep the old guidePos and jeepStopPos formulas", function()
		for id = 1, 9 do
			local s = SiteData.byId(id)
			expect.equal(s.guideLocal, nil)
			expect.equal(s.jeepLocal, nil)
			expect.equal(s.panelLocal, nil)
			local f = SiteData.facingVector(s.facing)
			local guide = s.pos + f * 30
			expect.near((SiteData.guidePos(id) - guide).Magnitude, 0, 1e-6)
			if SiteData.hasJeepStop(id) then
				local jeep = guide + Vector3.new(-f.Z, 0, f.X) * 20
				expect.near((SiteData.jeepStopPos(id) - jeep).Magnitude, 0, 1e-6)
			else
				expect.equal(SiteData.jeepStopPos(id), nil)
			end
		end
		-- Pinned values so a change to both sides of the comparison cannot hide a regression.
		expect.near((SiteData.guidePos(1) - Vector3.new(0, 0, 30)).Magnitude, 0, 1e-6)
		expect.near((SiteData.jeepStopPos(1) - Vector3.new(-20, 0, 30)).Magnitude, 0, 1e-6)
		expect.near((SiteData.guidePos(7) - Vector3.new(670, 0, 240)).Magnitude, 0, 1e-6)
	end)

	-- Local frame of a site: lx along the facing (forward), lz to the right of the facing (-f.Z, 0, f.X), origin = site pos.
	t.test("localToWorld follows the documented frame (+x forward, lz right)", function()
		local p = SiteData.localToWorld(10, 27, 5) -- facing E: forward +X, right +Z
		expect.near(p.X, -250 + 27, 1e-6)
		expect.near(p.Z, -260 + 5, 1e-6)
		local q = SiteData.localToWorld(1, 30, 0) -- facing S: forward +Z
		expect.near((q - Vector3.new(0, 0, 30)).Magnitude, 0, 1e-6)
		expect.equal(SiteData.localToWorld(11, 0, 0), nil)
	end)

	-- Reserved zones in City Hall's local frame: steps lx 5..25, spawn pad lx 30..50 / lz -10..10,
	-- InfoPanel lx 28..38 / lz -30..-15, jeep curb lx 90..100 / lz 20..40.
	local function inBox(v, x0, x1, z0, z1)
		return v.X >= x0 and v.X <= x1 and v.Y >= z0 and v.Y <= z1
	end

	t.test("row 10 carries guideLocal, jeepLocal and panelLocal as Vector2", function()
		local c = SiteData.byId(10)
		expect.equal(typeof(c.guideLocal), "Vector2")
		expect.equal(typeof(c.jeepLocal), "Vector2")
		expect.equal(typeof(c.panelLocal), "Vector2")
	end)

	t.test("row 10 jeep stop and panel sit inside their reserved zones; guide clears steps and spawn pad", function()
		local c = SiteData.byId(10)
		expect.truthy(inBox(c.jeepLocal, 90, 100, 20, 40))
		expect.truthy(inBox(c.panelLocal, 28, 38, -30, -15))
		expect.falsy(inBox(c.guideLocal, 30, 50, -10, 10)) -- not on the spawn pad
		expect.truthy(c.guideLocal.X > 25 and c.guideLocal.X < 30) -- between the steps and the pad
	end)

	t.test("row 10 guidePos and jeepStopPos honour the local offsets", function()
		local c = SiteData.byId(10)
		local g = SiteData.localToWorld(10, c.guideLocal.X, c.guideLocal.Y)
		local j = SiteData.localToWorld(10, c.jeepLocal.X, c.jeepLocal.Y)
		expect.near((SiteData.guidePos(10) - g).Magnitude, 0, 1e-6)
		expect.near((SiteData.jeepStopPos(10) - j).Magnitude, 0, 1e-6)
		-- The default formula would put Ate Joy on the spawn pad; the offset must differ from it.
		expect.truthy((SiteData.guidePos(10) - (c.pos + SiteData.facingVector("E") * 30)).Magnitude > 1)
	end)

	t.test("row 10 jeep stop is well outside the guide prompt radius (12)", function()
		expect.truthy((SiteData.jeepStopPos(10) - SiteData.guidePos(10)).Magnitude > 12)
	end)

	t.test("row 10 dialogue is 3 lines of ASCII, 220 chars or less, Did you know then Look", function()
		local d = SiteData.byId(10).dialogue
		expect.equal(#d, 3)
		expect.equal(string.sub(d[2], 1, 14), "Did you know? ")
		expect.equal(string.sub(d[3], 1, 5), "Look ")
		for _, line in ipairs(d) do
			expect.truthy(#line > 0 and #line <= 220)
			for p = 1, #line do
				expect.truthy(string.byte(line, p) <= 127)
			end
		end
	end)

	t.test("row 10 has credits, panel text and the City Hall display props as required props", function()
		local c = SiteData.byId(10)
		expect.truthy(#c.credits >= 1)
		expect.truthy(#c.panelText > 0)
		local joined = table.concat(c.requiredProps, "|")
		expect.truthy(string.find(joined, "raised walk-under blocks", 1, true))
		expect.truthy(string.find(joined, "jeepney stop", 1, true))
	end)

	t.test("categoryColor returns the four category colours and nil for unknown or non-string input", function()
		expect.equal(SiteData.categoryColor("Eat"), Color3.fromRGB(232, 150, 70))
		expect.equal(SiteData.categoryColor("Pray"), Color3.fromRGB(90, 150, 230))
		expect.equal(SiteData.categoryColor("Love"), Color3.fromRGB(100, 190, 110))
		expect.equal(SiteData.categoryColor("Welcome"), Color3.fromRGB(230, 190, 80))
		expect.equal(SiteData.categoryColor(nil), nil)
		expect.equal(SiteData.categoryColor("Nope"), nil)
		expect.equal(SiteData.categoryColor("eat"), nil)
		expect.equal(SiteData.categoryColor(5), nil)
		expect.equal(SiteData.categoryColor({}), nil)
		for _, s in ipairs(SiteData.sites) do
			expect.truthy(SiteData.categoryColor(s.category)) -- every row's category has a colour
		end
	end)
end
