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
			[1] = { 0, 57.5, "S" }, [2] = { -402, 160, "E" }, [3] = { 292, 140, "W" },
			[4] = { 272, -160, "W" }, [5] = { -300, -600, "S" }, [6] = { 550, -650, "SW" },
			[7] = { 700, 240, "W" }, [8] = { 560, 720, "NW" }, [9] = { -600, 550, "NE" },
			[10] = { -270, -305, "E" }, -- Step C: the blueprint rebuild moved the slot centre (was -250, -260)
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

	-- The Market moved from -220 to -230 (Slice 06), to -330 (Slice 14), and in the BP1 rebuild (Slice 4, 2026-10-29) to a 348 x 330 slot at (-402, 160)
	-- (x -576..-228, z -5..325, facing E, east edge flush with Road F's end). REPLACED "market sits at -330,160".
	t.test("market slot is centre (-402,160), size 348 x 330, facing E: x -576..-228, z -5..325", function()
		local m = SiteData.byId(2)
		expect.near(m.pos.X, -402, 1e-6)
		expect.near(m.pos.Z, 160, 1e-6)
		expect.near(m.size.X, 348, 1e-6)
		expect.near(m.size.Y, 330, 1e-6)
		expect.equal(m.facing, "E")
		local x0, x1, z0, z1 = footprint(m)
		expect.near(x0, -576, 1e-6)
		expect.near(x1, -228, 1e-6)
		expect.near(z0, -5, 1e-6)
		expect.near(z1, 325, 1e-6)
	end)

	-- Literal world values, on purpose: the Guide and the InfoPanel move to the forecourt (guideLocal / panelLocal as for rows 1 and 10); the Market has no JeepStop.
	t.test("row 2: Guide (-241,0,160) and InfoPanel (-247,148) pinned through guideLocal and panelLocal; no JeepStop", function()
		local m = SiteData.byId(2)
		expect.equal(typeof(m.guideLocal), "Vector2")
		expect.equal(typeof(m.panelLocal), "Vector2")
		expect.equal(m.jeepLocal, nil)
		expect.near((SiteData.guidePos(2) - Vector3.new(-241, 0, 160)).Magnitude, 0, 1e-6)
		local pp = SiteData.localToWorld(2, m.panelLocal.X, m.panelLocal.Y)
		expect.near(pp.X, -247, 1e-6)
		expect.near(pp.Z, 148, 1e-6)
		expect.equal(SiteData.hasJeepStop(2), false)
		expect.equal(SiteData.jeepStopPos(2), nil)
		local x0, x1, z0, z1 = footprint(m)
		for _, v in ipairs({ SiteData.guidePos(2), pp }) do
			expect.truthy(v.X >= x0 and v.X <= x1 and v.Z >= z0 and v.Z <= z1)
		end
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

	-- Lomi King grows from 100 x 80 to 100 x 110 (Site 3): the centre stays (292,140), so the slot becomes x 242..342, z 85..195, facing W.
	t.test("Lomi King slot is centre (292,140), size 100 x 110, facing W: x 242..342, z 85..195", function()
		local l = SiteData.byId(3)
		expect.equal(l.key, "Lomi")
		expect.equal(l.size, Vector2.new(100, 110))
		expect.near(l.pos.X, 292, 1e-6)
		expect.near(l.pos.Z, 140, 1e-6)
		expect.equal(l.facing, "W")
		local x0, x1, z0, z1 = footprint(l)
		expect.near(x0, 242, 1e-6)
		expect.near(x1, 342, 1e-6)
		expect.near(z0, 85, 1e-6)
		expect.near(z1, 195, 1e-6)
	end)

	-- Lomi King text job (owner-approved 2026-10-31, handoff 057 rows 1 and 7): the 2015-photo note is replaced by the board and Street View note
	-- (shortened by the owner to keep line 1 within 220 chars), and the Street View domain joins the credits.
	t.test("Lomi line 1 carries the 2026 model note, no Lomi line mentions 2015, and credits name Primer and Google", function()
		local l = SiteData.byId(3)
		expect.truthy(string.find(l.dialogue[1], "Our model follows a 2026 Street View image and a drawn board, so details may differ.", 1, true))
		for _, line in ipairs(l.dialogue) do
			expect.falsy(string.find(line, "2015", 1, true))
		end
		local has = {}
		for _, d in ipairs(l.credits) do has[d] = true end
		expect.truthy(has["primer.com.ph"])
		expect.truthy(has["www.google.com"])
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

	-- REPLACED (Slice 4, owner approved): the facade photo is no longer the source, so the 2014 line goes. Old text: "Market text notes the 2014 photo date".
	t.test("Market first line says the model follows a plan drawing and recent street photos; no line mentions 2014", function()
		local d = SiteData.byId(2).dialogue
		expect.equal(string.sub(d[1], 1, 51), "This is the Candido B. Lopez Memorial Public Market")
		expect.truthy(string.find(d[1], "Our model follows a plan drawing and recent street photos, so some details may differ.", 1, true))
		for _, line in ipairs(d) do
			expect.falsy(string.find(line, "2014", 1, true))
			expect.falsy(string.find(line, "facade photo", 1, true))
		end
	end)

	-- Look-at line (owner approved 2026-10-30; the model follows BP1 and BP2): arches run along the top floor, and the two mirrored stairs climb toward the middle.
	t.test("Market look-at line (last dialogue line) names the top-floor arches and the two stairs climbing toward the middle", function()
		local d = SiteData.byId(2).dialogue
		expect.equal(d[#d], "Look at the rounded arches repeating along the top floor in a steady rhythm. Count the arches, and notice how the two stairs climb toward the middle.")
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

	t.test("byId(10) is New Lipa City Hall, key CityHall, Welcome, Ate Joy, size 240x286 (Step C)", function()
		local c = SiteData.byId(10)
		expect.truthy(c)
		expect.equal(c.id, 10)
		expect.equal(c.key, "CityHall")
		expect.equal(c.name, "New Lipa City Hall")
		expect.equal(c.category, "Welcome")
		expect.equal(c.guideName, "Ate Joy")
		expect.equal(c.size, Vector2.new(240, 286))
		expect.near(c.pos.X, -270, 1e-6)
		expect.near(c.pos.Z, -305, 1e-6)
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
	-- Slice 4 (Market rebuild): row 2 now carries guideLocal / panelLocal (pinned by "row 2: Guide ..." above), so this loop starts at row 3.
	t.test("rows 3 to 9 keep the old guidePos and jeepStopPos formulas", function()
		for id = 3, 9 do
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
		expect.near((SiteData.guidePos(7) - Vector3.new(670, 0, 240)).Magnitude, 0, 1e-6)
	end)

	-- Local frame of a site: lx along the facing (forward), lz to the right of the facing (-f.Z, 0, f.X), origin = site pos.
	t.test("localToWorld follows the documented frame (+x forward, lz right)", function()
		local p = SiteData.localToWorld(10, 47, 45) -- facing E: forward +X, right +Z; origin (-270, -305) since Step C
		expect.near(p.X, -270 + 47, 1e-6)
		expect.near(p.Z, -305 + 45, 1e-6)
		local q = SiteData.localToWorld(1, 30, 0) -- facing S: forward +Z, origin (0, 57.5) since Cathedral south growth
		expect.near((q - Vector3.new(0, 0, 87.5)).Magnitude, 0, 1e-6)
		expect.equal(SiteData.localToWorld(11, 0, 0), nil)
	end)

	-- Cathedral south growth (Slice 4 B3b): the slot centre moved to (0, 57.5) and grew to 240 x 315 (z -100..215); the Guide, the
	-- jeep stop and the InfoPanel keep their world positions through guideLocal / panelLocal. Literal values, on purpose.
	t.test("row 1: slot (0,57.5) 240 x 315, Guide (0,30), JeepStop (-20,30), InfoPanel (12,24) stay put", function()
		local c = SiteData.byId(1)
		expect.near(c.pos.X, 0, 1e-6)
		expect.near(c.pos.Z, 57.5, 1e-6)
		expect.near(c.size.X, 240, 1e-6)
		expect.near(c.size.Y, 315, 1e-6)
		expect.equal(c.facing, "S")
		expect.equal(typeof(c.guideLocal), "Vector2")
		expect.equal(c.jeepLocal, nil)
		expect.equal(typeof(c.panelLocal), "Vector2")
		expect.near((SiteData.guidePos(1) - Vector3.new(0, 0, 30)).Magnitude, 0, 1e-6)
		expect.near((SiteData.jeepStopPos(1) - Vector3.new(-20, 0, 30)).Magnitude, 0, 1e-6)
		local pp = SiteData.localToWorld(1, c.panelLocal.X, c.panelLocal.Y)
		expect.near((pp - Vector3.new(12, 0, 24)).Magnitude, 0, 1e-6)
		-- the slot reaches z 215 (south) and still starts at z -100 (Road A's start)
		expect.near(c.pos.Z - c.size.Y / 2, -100, 1e-6)
		expect.near(c.pos.Z + c.size.Y / 2, 215, 1e-6)
	end)

	-- Reserved zones in City Hall's local frame (origin (-270, -305) since Step C; the same WORLD boxes as before):
	-- spawn pad lx 56..68 / lz 39..51 (world -214..-202, -266..-254), InfoPanel lx 48..58 / lz 15..30, jeep curb lx 110..120 / lz 65..85.
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
		expect.truthy(inBox(c.jeepLocal, 110, 120, 65, 85))
		expect.truthy(inBox(c.panelLocal, 48, 58, 15, 30))
		expect.falsy(inBox(c.guideLocal, 56, 68, 39, 51)) -- not on the spawn pad
		expect.truthy(c.guideLocal.X >= 44 and c.guideLocal.X <= 50) -- 6..12 studs west of the pad edge (lx 56)
	end)

	-- Literal values, on purpose: the local offsets changed with the slot so the WORLD positions stay put. If both sides of the
	-- localToWorld comparison drifted together, only these pinned numbers would catch it.
	t.test("row 10 local offsets are (47,45), (115,75), (53,23) and the world positions stay put", function()
		local c = SiteData.byId(10)
		expect.equal(c.guideLocal, Vector2.new(47, 45))
		expect.equal(c.jeepLocal, Vector2.new(115, 75))
		expect.equal(c.panelLocal, Vector2.new(53, 23))
		expect.near((SiteData.guidePos(10) - Vector3.new(-223, 0, -260)).Magnitude, 0, 1e-6)
		expect.near((SiteData.jeepStopPos(10) - Vector3.new(-155, 0, -230)).Magnitude, 0, 1e-6)
		local pp = SiteData.localToWorld(10, c.panelLocal.X, c.panelLocal.Y)
		expect.near((pp - Vector3.new(-217, 0, -282)).Magnitude, 0, 1e-6)
		-- the slot still holds all three and the spawn pad (-214..-202, -266..-254)
		local x0, x1, z0, z1 = footprint(c)
		expect.near(x0, -390, 1e-6)
		expect.near(x1, -150, 1e-6)
		expect.near(z0, -448, 1e-6)
		expect.near(z1, -162, 1e-6)
		for _, v in ipairs({ SiteData.guidePos(10), SiteData.jeepStopPos(10), pp, Vector3.new(-214, 0, -266), Vector3.new(-202, 0, -254) }) do
			expect.truthy(v.X >= x0 and v.X <= x1 and v.Z >= z0 and v.Z <= z1)
		end
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
		-- BuildCheck matches requiredProps against DIRECT children of the site model, so they are the City Hall model names
		-- (Blocks = the staggered white-brick boxes, Landscape = pocket gardens, Wing = open lobby, Forecourt = front plaza,
		-- JeepStop = the jeepney stop), not the PDF display words (those stay in TourContent displayProps).
		expect.truthy(string.find(joined, "Blocks", 1, true))
		expect.truthy(string.find(joined, "JeepStop", 1, true))
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
