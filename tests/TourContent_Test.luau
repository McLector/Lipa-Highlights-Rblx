-- Tests for ReplicatedStorage.LipaShared.TourContent (Lipa Tour v2 written content) and its validate function.
-- Two groups. The "real content" tests read the actual module and stay RED until the content is written.
-- The validator tests run validate on a small valid fixture that is mutated one thing at a time, so they pass from day one.
-- Contract: sites[1..10] = { id, headline, blurb, trivia (3), quiz = { question, options (3), right, wrong, pdfRef }, npc = { name, role },
-- firstTalk (2..3), talkAgain (>= 1), goodbye, lookAt, displayProps (>= 1) }; cityHallFacts (>= 5), jeepLines (>= 3),
-- glossary (>= 8 of { term, meaning }), wrapUp = { text, reflection }; validate(content) returns a list of error messages.
return function(t)
	local TourContent = require(game.ReplicatedStorage.LipaShared.TourContent:Clone())
	local expect = t.expect

	local ELEMENTS = { "line", "shape", "form", "color", "texture", "space", "rhythm", "emphasis" }
	local CARMEL = 5

	-- A minimal content table that validate accepts. Each call returns a fresh copy so tests can mutate it.
	local function fixture()
		local sites = {}
		for i = 1, 10 do
			sites[i] = {
				id = i,
				headline = "Headline " .. i,
				blurb = "A short blurb about stop number " .. i .. ".",
				trivia = { "First fact about this stop.", "Second fact about this stop.", "Third fact about this stop." },
				quiz = {
					question = "Which option is right?",
					options = { "Alpha", "Beta", "Gamma" },
					right = "Yes, that is right.",
					wrong = "Not quite, try again.",
					pdfRef = i,
				},
				npc = { name = "Guide " .. i, role = "Guide" },
				firstTalk = { "Hello there.", "Welcome to this stop." },
				talkAgain = { "Back again?" },
				goodbye = "Goodbye now.",
				lookAt = "Look at the " .. (ELEMENTS[i] or "line") .. " here.",
				displayProps = { "Display prop " .. i },
			}
		end
		sites[CARMEL].firstTalk = { "The sisters reported a quiet first year.", "Welcome." }
		local facts, jeep, glossary = {}, {}, {}
		for i = 1, 5 do facts[i] = "City hall fact " .. i .. "." end
		for i = 1, 3 do jeep[i] = "Jeep line " .. i .. "." end
		for i = 1, 8 do glossary[i] = { term = "Term " .. i, meaning = "Meaning " .. i .. "." } end
		return {
			sites = sites,
			cityHallFacts = facts,
			jeepLines = jeep,
			glossary = glossary,
			wrapUp = { text = "Thanks for visiting.", reflection = "What did you notice?" },
		}
	end

	local function errorsFor(mutate)
		local content = fixture()
		if mutate then mutate(content) end
		return TourContent.validate(content)
	end

	-- True if some message contains every needle (plain find).
	local function mentions(errs, ...)
		local needles = { ... }
		for _, message in ipairs(errs) do
			local all = true
			for _, needle in ipairs(needles) do
				if not string.find(message, needle, 1, true) then all = false break end
			end
			if all then return true end
		end
		return false
	end

	local function needTenSites()
		expect.equal(#TourContent.sites, 10)
	end

	-- ===== Real content (RED until the content is written) =====

	t.test("real content: validate reports no errors", function()
		expect.equal(table.concat(TourContent.validate(TourContent), " | "), "")
	end)

	t.test("real content: there are ten sites with ids 1..10 in order", function()
		needTenSites()
		for i, site in ipairs(TourContent.sites) do expect.equal(site.id, i) end
	end)

	t.test("real content: every blurb is at most 25 words and every trivia list has exactly 3 entries", function()
		needTenSites()
		for _, site in ipairs(TourContent.sites) do
			local words = 0
			for _ in string.gmatch(site.blurb, "%S+") do words += 1 end
			expect.truthy(words >= 1 and words <= 25)
			expect.equal(#site.trivia, 3)
		end
	end)

	t.test("real content: every quiz has 3 distinct options, a pdfRef 1..25 and no answer field", function()
		needTenSites()
		for _, site in ipairs(TourContent.sites) do
			local q = site.quiz
			expect.equal(#q.options, 3)
			expect.truthy(q.options[1] ~= q.options[2] and q.options[1] ~= q.options[3] and q.options[2] ~= q.options[3])
			expect.truthy(q.pdfRef >= 1 and q.pdfRef <= 25 and q.pdfRef == math.floor(q.pdfRef))
			for k in pairs(q) do expect.falsy(({ answer = 1, correct = 1, key = 1, index = 1 })[string.lower(tostring(k))]) end
		end
	end)

	t.test("real content: every site has 2..3 first-talk lines, a talk-again line and a display prop", function()
		needTenSites()
		for _, site in ipairs(TourContent.sites) do
			expect.truthy(#site.firstTalk >= 2 and #site.firstTalk <= 3)
			expect.truthy(#site.talkAgain >= 1)
			expect.truthy(#site.displayProps >= 1)
		end
	end)

	t.test("real content: site 10 is New Lipa City Hall with Ate Joy as the guide", function()
		needTenSites()
		expect.equal(TourContent.sites[10].npc.name, "Ate Joy")
	end)

	t.test("real content: Carmel says reported and never a bare confirmed", function()
		needTenSites()
		local site = TourContent.sites[CARMEL]
		local talk = string.lower(table.concat(site.firstTalk, " ") .. " " .. table.concat(site.talkAgain, " "))
		expect.truthy(string.find(talk, "%f[%a]reported%f[%A]"))
		expect.equal(table.concat(TourContent.validate(TourContent), " | "), "") -- the confirmed rule lives in validate
	end)

	t.test("real content: the lookAt lines cover all eight elements of art", function()
		needTenSites()
		local parts = {}
		for _, site in ipairs(TourContent.sites) do table.insert(parts, string.lower(site.lookAt)) end
		local text = table.concat(parts, " ")
		for _, word in ipairs(ELEMENTS) do
			expect.truthy(string.find(text, "%f[%a]" .. word .. "%f[%A]"))
		end
	end)

	t.test("real content: shared lists meet their minimum sizes", function()
		expect.truthy(#TourContent.cityHallFacts >= 5)
		expect.truthy(#TourContent.jeepLines >= 3)
		expect.truthy(#TourContent.glossary >= 8)
		expect.truthy(#TourContent.wrapUp.text > 0 and #TourContent.wrapUp.reflection > 0)
	end)

	-- ===== Owner decisions 2026-10-26 (RED until the wording is changed) =====

	local function containsText(value, needle)
		if type(value) == "string" then return string.find(value, needle, 1, true) ~= nil end
		if type(value) == "table" then
			for _, v in pairs(value) do
				if containsText(v, needle) then return true end
			end
		end
		return false
	end

	t.test("owner decisions: the wrap-up says sun-kissed and not sunburnt", function()
		local text = TourContent.wrapUp.text
		expect.truthy(string.find(text, "sun-kissed", 1, true))
		expect.falsy(string.find(text, "sunburnt", 1, true))
	end)

	t.test("owner decisions: no text anywhere in the content says sunburnt", function()
		expect.falsy(containsText(TourContent, "sunburnt"))
	end)

	t.test("owner decisions: the Tagbakin headline says lakeside spot and not lakeside side", function()
		needTenSites()
		local site = TourContent.sites[9]
		expect.equal(site.id, 9)
		expect.truthy(string.find(site.headline, "lakeside spot", 1, true))
		expect.falsy(string.find(site.headline, "lakeside side", 1, true))
	end)

	t.test("owner decisions: the Market guide uses the PDF name and no first-talk line says Candido", function()
		needTenSites()
		local site = TourContent.sites[2]
		expect.equal(site.id, 2)
		local named = false
		for _, line in ipairs(site.firstTalk) do
			if string.find(line, "Lipa City Public Market", 1, true) then named = true end
			expect.falsy(string.find(line, "Candido", 1, true))
		end
		expect.truthy(named)
	end)

	t.test("owner decisions: the Market headline and blurb do not take the PDF name (sign name stays Candido, [VERIFY])", function()
		needTenSites()
		local site = TourContent.sites[2]
		expect.falsy(string.find(site.headline, "Lipa City Public Market", 1, true))
		expect.falsy(string.find(site.blurb, "Lipa City Public Market", 1, true))
	end)

	-- ===== Validator behaviour (green: tests the validate function on a fixture) =====

	t.test("validate: a fully valid fixture returns an empty error list", function()
		expect.equal(table.concat(errorsFor(), " | "), "")
	end)

	t.test("validate: a non-ASCII byte is rejected and names the site and field", function()
		local errs = errorsFor(function(c) c.sites[2].headline = "Caf" .. string.char(195, 169) end)
		expect.truthy(mentions(errs, "site 2", "headline", "ASCII"))
	end)

	t.test("validate: non-ASCII is also caught in glossary, lists and wrapUp", function()
		local bad = string.char(195, 169)
		expect.truthy(mentions(errorsFor(function(c) c.glossary[3].meaning = "caf" .. bad end), "glossary"))
		expect.truthy(mentions(errorsFor(function(c) c.jeepLines[1] = "caf" .. bad end), "jeepLines"))
		expect.truthy(mentions(errorsFor(function(c) c.cityHallFacts[2] = "caf" .. bad end), "cityHallFacts"))
		expect.truthy(mentions(errorsFor(function(c) c.wrapUp.text = "caf" .. bad end), "wrapUp"))
	end)

	t.test("validate: control characters and tabs are not printable ASCII", function()
		expect.truthy(mentions(errorsFor(function(c) c.sites[1].goodbye = "Bye\tnow." end), "site 1", "goodbye"))
	end)

	t.test("validate: an empty string field is rejected", function()
		expect.truthy(mentions(errorsFor(function(c) c.sites[4].goodbye = "" end), "site 4", "goodbye"))
		expect.truthy(mentions(errorsFor(function(c) c.wrapUp.reflection = "" end), "wrapUp"))
	end)

	t.test("validate: a 25-word blurb passes and a 26-word blurb fails", function()
		local function words(n) return string.rep("word ", n):sub(1, -2) .. "." end
		expect.equal(#errorsFor(function(c) c.sites[3].blurb = words(25) end), 0)
		expect.truthy(mentions(errorsFor(function(c) c.sites[3].blurb = words(26) end), "site 3", "blurb"))
	end)

	t.test("validate: four quiz options are rejected", function()
		local errs = errorsFor(function(c) c.sites[6].quiz.options = { "A", "B", "C", "D" } end)
		expect.truthy(mentions(errs, "site 6", "options"))
	end)

	t.test("validate: two quiz options are rejected", function()
		local errs = errorsFor(function(c) c.sites[6].quiz.options = { "A", "B" } end)
		expect.truthy(mentions(errs, "site 6", "options"))
	end)

	t.test("validate: duplicate quiz options are rejected", function()
		local errs = errorsFor(function(c) c.sites[7].quiz.options = { "Same", "Other", "Same" } end)
		expect.truthy(mentions(errs, "site 7", "duplicate"))
	end)

	t.test("validate: two trivia entries are rejected", function()
		local errs = errorsFor(function(c) c.sites[8].trivia = { "One fact.", "Two facts." } end)
		expect.truthy(mentions(errs, "site 8", "trivia"))
	end)

	t.test("validate: a trivia entry with two sentences is rejected", function()
		local errs = errorsFor(function(c) c.sites[8].trivia[2] = "First part. Second part." end)
		expect.truthy(mentions(errs, "site 8", "trivia[2]", "one sentence"))
	end)

	t.test("validate: a trivia entry with no sentence end is rejected", function()
		local errs = errorsFor(function(c) c.sites[8].trivia[1] = "No full stop here" end)
		expect.truthy(mentions(errs, "site 8", "trivia[1]"))
	end)

	t.test("validate: a three-sentence dialogue line is rejected, a two-sentence line passes", function()
		expect.equal(#errorsFor(function(c) c.sites[1].firstTalk[1] = "One. Two!" end), 0)
		expect.truthy(mentions(errorsFor(function(c) c.sites[1].firstTalk[1] = "One. Two! Three?" end), "site 1", "firstTalk[1]"))
	end)

	t.test("validate: the sentence cap also covers talkAgain, goodbye, lookAt, jeepLines and cityHallFacts", function()
		local three = "One. Two. Three."
		expect.truthy(mentions(errorsFor(function(c) c.sites[2].talkAgain[1] = three end), "site 2", "talkAgain"))
		expect.truthy(mentions(errorsFor(function(c) c.sites[2].goodbye = three end), "site 2", "goodbye"))
		expect.truthy(mentions(errorsFor(function(c) c.sites[2].lookAt = "Look at the line. " .. three end), "site 2", "lookAt"))
		expect.truthy(mentions(errorsFor(function(c) c.jeepLines[2] = three end), "jeepLines[2]"))
		expect.truthy(mentions(errorsFor(function(c) c.cityHallFacts[4] = three end), "cityHallFacts[4]"))
	end)

	t.test("validate: an ellipsis or a decimal point is not counted as several sentences", function()
		expect.equal(#errorsFor(function(c) c.sites[1].firstTalk[1] = "Wait... it costs 2.5 pesos." end), 0)
	end)

	t.test("validate: firstTalk must have 2 or 3 lines", function()
		expect.truthy(mentions(errorsFor(function(c) c.sites[1].firstTalk = { "Only one." } end), "site 1", "firstTalk"))
		expect.truthy(mentions(errorsFor(function(c) c.sites[1].firstTalk = { "A.", "B.", "C.", "D." } end), "site 1", "firstTalk"))
		expect.equal(#errorsFor(function(c) c.sites[1].firstTalk = { "A.", "B.", "C." } end), 0)
	end)

	t.test("validate: talkAgain and displayProps must not be empty", function()
		expect.truthy(mentions(errorsFor(function(c) c.sites[9].talkAgain = {} end), "site 9", "talkAgain"))
		expect.truthy(mentions(errorsFor(function(c) c.sites[9].displayProps = {} end), "site 9", "displayProps"))
	end)

	t.test("validate: missing site 10 is reported", function()
		local errs = errorsFor(function(c) c.sites[10] = nil end)
		expect.truthy(mentions(errs, "site 10", "missing"))
	end)

	t.test("validate: ids must be in order", function()
		local errs = errorsFor(function(c) c.sites[2].id = 3 end)
		expect.truthy(mentions(errs, "site 2", "id"))
	end)

	t.test("validate: an eleventh site is rejected", function()
		local errs = errorsFor(function(c) c.sites[11] = c.sites[10] end)
		expect.truthy(mentions(errs, "sites"))
	end)

	t.test("validate: any answer-like field in a quiz is rejected", function()
		for _, key in ipairs({ "answer", "correct", "key", "index", "Answer" }) do
			local errs = errorsFor(function(c) c.sites[4].quiz[key] = 2 end)
			expect.truthy(mentions(errs, "site 4", key))
		end
	end)

	t.test("validate: pdfRef 0 and 26 are rejected, 1 and 25 pass", function()
		expect.truthy(mentions(errorsFor(function(c) c.sites[5].quiz.pdfRef = 0 end), "site 5", "pdfRef"))
		expect.truthy(mentions(errorsFor(function(c) c.sites[5].quiz.pdfRef = 26 end), "site 5", "pdfRef"))
		expect.equal(#errorsFor(function(c) c.sites[5].quiz.pdfRef = 1 end), 0)
		expect.equal(#errorsFor(function(c) c.sites[5].quiz.pdfRef = 25 end), 0)
	end)

	t.test("validate: pdfRef must be an integer number", function()
		expect.truthy(mentions(errorsFor(function(c) c.sites[5].quiz.pdfRef = 2.5 end), "pdfRef"))
		expect.truthy(mentions(errorsFor(function(c) c.sites[5].quiz.pdfRef = "3" end), "pdfRef"))
		expect.truthy(mentions(errorsFor(function(c) c.sites[5].quiz.pdfRef = 0 / 0 end), "pdfRef"))
		expect.truthy(mentions(errorsFor(function(c) c.sites[5].quiz.pdfRef = nil end), "pdfRef"))
	end)

	t.test("validate: Carmel saying 'confirmed miracle' is rejected", function()
		local errs = errorsFor(function(c) c.sites[CARMEL].talkAgain = { "It was a confirmed miracle." } end)
		expect.truthy(mentions(errs, "site 5", "confirmed"))
	end)

	t.test("validate: Carmel may say 'not confirmed' or 'never confirmed'", function()
		expect.equal(#errorsFor(function(c) c.sites[CARMEL].talkAgain = { "It is not confirmed." } end), 0)
		expect.equal(#errorsFor(function(c) c.sites[CARMEL].talkAgain = { "Nobody ever said never. It was never confirmed." } end), 0)
	end)

	t.test("validate: 'confirmed' is only excused by a not/never BEFORE it in the same line", function()
		local errs = errorsFor(function(c) c.sites[CARMEL].talkAgain = { "Confirmed, not rumor." } end)
		expect.truthy(mentions(errs, "site 5", "confirmed"))
	end)

	t.test("validate: the word 'confirmed' is fine outside Carmel", function()
		expect.equal(#errorsFor(function(c) c.sites[3].talkAgain = { "A confirmed fact." } end), 0)
	end)

	t.test("validate: Carmel must say 'reported' in firstTalk or talkAgain", function()
		local errs = errorsFor(function(c) c.sites[CARMEL].firstTalk = { "Hello there.", "Welcome." } end)
		expect.truthy(mentions(errs, "site 5", "reported"))
		expect.equal(#errorsFor(function(c)
			c.sites[CARMEL].firstTalk = { "Hello there.", "Welcome." }
			c.sites[CARMEL].talkAgain = { "Pilgrims reported many prayers." }
		end), 0)
	end)

	t.test("validate: a missing element word in the lookAt lines is reported", function()
		local errs = errorsFor(function(c) c.sites[7].lookAt = "Look at the line here." end) -- site 7 held "rhythm"
		expect.truthy(mentions(errs, "lookAt", "rhythm"))
	end)

	t.test("validate: 'colour' does not count as 'color' and 'lines' does not count as 'line'", function()
		expect.truthy(mentions(errorsFor(function(c) c.sites[4].lookAt = "Look at the colour here." end), "lookAt", "color"))
		expect.truthy(mentions(errorsFor(function(c)
			c.sites[1].lookAt = "Look at the lines here."
			for i = 9, 10 do c.sites[i].lookAt = "Look at the shape here." end
		end), "lookAt", "line"))
	end)

	t.test("validate: element words match case-insensitively", function()
		expect.equal(#errorsFor(function(c) c.sites[1].lookAt = "LOOK AT THE LINE HERE." end), 0)
	end)

	t.test("validate: glossary needs 8 entries with a term and meaning", function()
		expect.truthy(mentions(errorsFor(function(c) c.glossary[8] = nil end), "glossary"))
		expect.truthy(mentions(errorsFor(function(c) c.glossary[2].term = nil end), "glossary[2]", "term"))
	end)

	t.test("validate: short cityHallFacts and jeepLines are rejected", function()
		expect.truthy(mentions(errorsFor(function(c) c.cityHallFacts[5] = nil end), "cityHallFacts"))
		expect.truthy(mentions(errorsFor(function(c) c.jeepLines[3] = nil end), "jeepLines"))
	end)

	t.test("validate: a missing wrapUp is rejected", function()
		expect.truthy(mentions(errorsFor(function(c) c.wrapUp = nil end), "wrapUp"))
	end)

	t.test("validate: nil, numbers, strings and booleans return an error and do not throw", function()
		for _, junk in ipairs({ 5, "text", true }) do
			expect.truthy(#TourContent.validate(junk) >= 1)
		end
		expect.truthy(#TourContent.validate(nil) >= 1)
		expect.truthy(#TourContent.validate(0 / 0) >= 1)
	end)

	t.test("validate: malformed tables return errors and do not throw", function()
		local garbage = {
			{},
			{ sites = 5 },
			{ sites = { "x", 3, true } },
			{ sites = { {}, {}, {} } },
			{ sites = { { trivia = 4, quiz = "q", npc = 7, firstTalk = true } } },
			{ sites = { { quiz = { options = { {}, {}, {} }, pdfRef = {} } } }, glossary = { 1, "a" }, wrapUp = 3 },
		}
		for _, value in ipairs(garbage) do
			local ok, errs = pcall(TourContent.validate, value)
			expect.truthy(ok)
			expect.truthy(#errs >= 1)
		end
	end)

	t.test("validate: wrong field types inside a valid fixture return errors and do not throw", function()
		expect.truthy(mentions(errorsFor(function(c) c.sites[2].blurb = 12 end), "site 2", "blurb"))
		expect.truthy(mentions(errorsFor(function(c) c.sites[2].trivia[1] = 12 end), "site 2", "trivia"))
		expect.truthy(mentions(errorsFor(function(c) c.sites[2].quiz = nil end), "site 2", "quiz"))
		expect.truthy(mentions(errorsFor(function(c) c.sites[2].npc = nil end), "site 2", "npc"))
	end)
end
