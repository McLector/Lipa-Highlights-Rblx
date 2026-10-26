-- Tests for ReplicatedStorage.LipaShared.CertificateLogic (pure; no Instances).
-- Contract: cleanName(raw) -> a display name safe to print: non-strings, empty and whitespace-only input give "Traveler";
-- control characters are dropped; the result is at most 40 UTF-8 characters (cut on a character boundary, never mid-glyph).
-- build(state, displayName, sites) -> nil unless the passport state is complete (10/10); otherwise
-- { title, player, places = { "1. <name>", ... in id order }, count } where sites is SiteData.sites.
return function(t)
	local CertificateLogic = require(game.ReplicatedStorage.LipaShared.CertificateLogic:Clone())
	local PassportLogic = require(game.ReplicatedStorage.LipaShared.PassportLogic:Clone())
	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
	local expect = t.expect

	local function stamped(ids)
		local s = PassportLogic.new()
		for _, id in ipairs(ids) do PassportLogic.stamp(s, id) end
		return s
	end
	local function full() return stamped({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }) end

	-- cleanName -------------------------------------------------------------
	t.test("cleanName keeps an ordinary name", function()
		expect.equal(CertificateLogic.cleanName("Maria Santos"), "Maria Santos")
	end)

	t.test("cleanName falls back to Traveler for nil, numbers, tables, empty and whitespace-only", function()
		expect.equal(CertificateLogic.cleanName(nil), "Traveler")
		expect.equal(CertificateLogic.cleanName(42), "Traveler")
		expect.equal(CertificateLogic.cleanName({}), "Traveler")
		expect.equal(CertificateLogic.cleanName(""), "Traveler")
		expect.equal(CertificateLogic.cleanName("   \t  "), "Traveler")
	end)

	t.test("cleanName trims surrounding whitespace", function()
		expect.equal(CertificateLogic.cleanName("  Ana  "), "Ana")
	end)

	t.test("cleanName drops control characters", function()
		expect.equal(CertificateLogic.cleanName("A\0b\1c\n"), "Abc")
		expect.equal(CertificateLogic.cleanName("\0\1\2"), "Traveler")
	end)

	t.test("cleanName caps at 40 characters", function()
		local out = CertificateLogic.cleanName(string.rep("a", 80))
		expect.equal(utf8.len(out), 40)
		expect.equal(CertificateLogic.cleanName(string.rep("a", 40)), string.rep("a", 40))
	end)

	t.test("cleanName cuts multibyte names on a character boundary", function()
		local out = CertificateLogic.cleanName(string.rep("\u{00E9}", 50)) -- 50 x e-acute = 100 bytes
		expect.equal(utf8.len(out), 40) -- utf8.len is nil if a glyph was cut in half
		expect.equal(#out, 80)
		local emoji = CertificateLogic.cleanName(string.rep("\u{1F600}", 45)) -- 4-byte characters
		expect.equal(utf8.len(emoji), 40)
	end)

	t.test("cleanName on invalid UTF-8 gives Traveler instead of throwing", function()
		expect.equal(CertificateLogic.cleanName("\255\254bad"), "Traveler")
	end)

	-- build -----------------------------------------------------------------
	t.test("build returns nil below 10/10", function()
		expect.equal(CertificateLogic.build(PassportLogic.new(), "Ana", SiteData.sites), nil)
		expect.equal(CertificateLogic.build(stamped({ 1, 2, 3, 4, 5, 6, 7, 8 }), "Ana", SiteData.sites), nil)
		expect.equal(CertificateLogic.build(stamped({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }), "Ana", SiteData.sites), nil) -- the old 9/9
	end)

	t.test("build returns nil for nil, non-table and malformed state", function()
		expect.equal(CertificateLogic.build(nil, "Ana", SiteData.sites), nil)
		expect.equal(CertificateLogic.build("done", "Ana", SiteData.sites), nil)
		expect.equal(CertificateLogic.build(10, "Ana", SiteData.sites), nil)
		expect.equal(CertificateLogic.build({}, "Ana", SiteData.sites), nil)
		expect.equal(CertificateLogic.build({ n = 10, total = 10 }, "Ana", SiteData.sites), nil) -- not a real passport state
	end)

	t.test("build at 10/10 lists the ten places in id order, City Hall last", function()
		local cert = CertificateLogic.build(full(), "Ana", SiteData.sites)
		expect.truthy(cert)
		expect.equal(cert.count, 10)
		expect.equal(#cert.places, 10)
		expect.equal(cert.places[10], "10. New Lipa City Hall")
		for i, s in ipairs(SiteData.sites) do
			expect.equal(cert.places[i], i .. ". " .. s.name)
		end
	end)

	t.test("build at 10/10 has a title and a player line carrying the cleaned name", function()
		local cert = CertificateLogic.build(full(), "  Ana  ", SiteData.sites)
		expect.truthy(type(cert.title) == "string" and #cert.title > 0)
		expect.truthy(string.find(cert.player, "Ana", 1, true))
		expect.falsy(string.find(cert.player, "  Ana", 1, true))
	end)

	t.test("build falls back to Traveler for a missing or blank name", function()
		expect.truthy(string.find(CertificateLogic.build(full(), nil, SiteData.sites).player, "Traveler", 1, true))
		expect.truthy(string.find(CertificateLogic.build(full(), "   ", SiteData.sites).player, "Traveler", 1, true))
	end)

	t.test("build does not alias the sites table", function()
		local cert = CertificateLogic.build(full(), "Ana", SiteData.sites)
		cert.places[1] = "changed"
		expect.equal(SiteData.sites[1].name, SiteData.byId(1).name)
		expect.truthy(CertificateLogic.build(full(), "Ana", SiteData.sites).places[1] ~= "changed")
	end)

	t.test("build ignores display names that are plain text with markup characters", function()
		local cert = CertificateLogic.build(full(), "<b>Ana</b>", SiteData.sites)
		expect.truthy(cert.player) -- kept verbatim; the label must have RichText off (checked in qa_check)
	end)

	t.test("build with a sites list that is not ten entries returns nil", function()
		expect.equal(CertificateLogic.build(full(), "Ana", {}), nil)
		local nine = {}
		for i = 1, 9 do nine[i] = SiteData.sites[i] end
		expect.equal(CertificateLogic.build(full(), "Ana", nine), nil)
		expect.equal(CertificateLogic.build(full(), "Ana", nil), nil)
	end)

	-- layout(w, h): the certificate grid. Portrait (taller than wide) gets 2 columns so long names stay readable;
	-- landscape and square get 3; anything that is not a positive finite size gets the safe default of 3.
	t.test("layout gives 3 columns for landscape and square", function()
		expect.equal(CertificateLogic.layout(1920, 1080).columns, 3)
		expect.equal(CertificateLogic.layout(800, 800).columns, 3)
		expect.equal(CertificateLogic.layout(801, 800).columns, 3)
	end)

	t.test("layout gives 2 columns when taller than wide", function()
		expect.equal(CertificateLogic.layout(390, 844).columns, 2)
		expect.equal(CertificateLogic.layout(800, 801).columns, 2)
	end)

	t.test("layout returns the safe default for bad input", function()
		local bad = { { nil, nil }, { 0, 0 }, { 0, 100 }, { 100, 0 }, { -100, 200 }, { 100, -200 }, { 0 / 0, 100 },
			{ 100, 0 / 0 }, { math.huge, 100 }, { "800", "600" }, { {}, {} }, { true, false } }
		for _, c in ipairs(bad) do
			local r = CertificateLogic.layout(c[1], c[2])
			expect.equal(type(r), "table")
			expect.equal(r.columns, 3)
		end
		expect.equal(CertificateLogic.layout().columns, 3)
		expect.equal(CertificateLogic.layout(500).columns, 3)
	end)

	t.test("layout returns a fresh table each call", function()
		local a = CertificateLogic.layout(100, 200)
		a.columns = 99
		expect.equal(CertificateLogic.layout(100, 200).columns, 2)
	end)

	-- cellRects(w, h, count, columns, places): where each place cell goes inside the certificate's places area (w x h pixels), and
	-- the fixed text size to use. The LAST place (the Welcome site, City Hall) is a full-width row on top; the rest fill `columns`
	-- columns below it. Returns nil for bad input. textSize is estimated (no Instances), so a Studio test measures it with TextService.
	local PLACES = {}
	for i, s in ipairs(SiteData.sites) do PLACES[i] = s.id .. ". " .. s.name end

	local function inside(r, w, h)
		return r.x >= -0.001 and r.y >= -0.001 and r.x + r.w <= w + 0.001 and r.y + r.h <= h + 0.001 and r.w > 0 and r.h > 0
	end
	local function overlap(a, b)
		return a.x < b.x + b.w - 0.001 and b.x < a.x + a.w - 0.001 and a.y < b.y + b.h - 0.001 and b.y < a.y + a.h - 0.001
	end
	local function checkGeometry(g, w, h, count)
		expect.equal(#g.rects, count)
		for i = 1, count do
			expect.truthy(inside(g.rects[i], w, h))
			for j = i + 1, count do
				expect.falsy(overlap(g.rects[i], g.rects[j]))
			end
		end
	end

	t.test("cellRects on a 401x778 portrait phone: 2 columns, Welcome row on top, everything inside and apart", function()
		local g = CertificateLogic.cellRects(313, 352, 10, CertificateLogic.layout(401, 778).columns, PLACES)
		expect.equal(g.columns, 2)
		expect.equal(g.rows, 5)
		checkGeometry(g, 313, 352, 10)
		expect.equal(g.welcomeIndex, 10)
		expect.near(g.rects[10].x, 0, 0.001)
		expect.near(g.rects[10].y, 0, 0.001)
		expect.near(g.rects[10].w, 313, 0.001)
		for i = 1, #PLACES - 1 do
			expect.truthy(g.rects[i].y > g.rects[10].y + g.rects[10].h - 0.001) -- grid cells sit below the Welcome row
		end
		expect.near(g.rects[1].x, 0, 0.001)
		expect.truthy(g.rects[2].x > g.rects[1].x) -- second cell is in the second column
		expect.near(g.rects[3].x, 0, 0.001) -- third wraps to the next row
		expect.truthy(g.rects[3].y > g.rects[1].y)
		expect.equal(g.fits, true)
		expect.truthy(g.textSize >= 12 and g.textSize <= 20)
		expect.equal(g.textSize, math.floor(g.textSize)) -- a whole pixel size
	end)

	t.test("cellRects keeps the longest word on one line: Independencia never wraps mid-word", function()
		local g = CertificateLogic.cellRects(313, 352, 10, 2, PLACES)
		-- 13 characters at the estimated width per character must fit the cell minus its padding
		expect.truthy(13 * CertificateLogic.CHAR_EM * g.textSize <= g.rects[1].w - CertificateLogic.CELL_PAD)
	end)

	t.test("cellRects on a landscape phone area gives 3 columns of cells, all inside", function()
		local g = CertificateLogic.cellRects(548, 156, 10, CertificateLogic.layout(705, 338).columns, PLACES)
		expect.equal(g.columns, 3)
		expect.equal(g.rows, 3)
		checkGeometry(g, 548, 156, 10)
		expect.equal(g.fits, true)
		expect.truthy(g.textSize >= 12)
	end)

	t.test("cellRects on a big area uses the maximum text size", function()
		local g = CertificateLogic.cellRects(560, 400, 10, 3, PLACES)
		expect.equal(g.textSize, CertificateLogic.MAX_TEXT)
		checkGeometry(g, 560, 400, 10)
	end)

	t.test("cellRects works without a places list (defaults) and with a single place", function()
		local g = CertificateLogic.cellRects(313, 352, 10, 2)
		expect.equal(#g.rects, 10)
		local one = CertificateLogic.cellRects(300, 100, 1, 2)
		expect.equal(#one.rects, 1)
		expect.equal(one.rows, 0)
		expect.near(one.rects[1].w, 300, 0.001)
		expect.truthy(inside(one.rects[1], 300, 100))
	end)

	t.test("cellRects falls back to layout columns when columns is missing or invalid", function()
		expect.equal(CertificateLogic.cellRects(313, 480, 10).columns, 2) -- taller than wide
		expect.equal(CertificateLogic.cellRects(548, 156, 10, 0).columns, 3)
		expect.equal(CertificateLogic.cellRects(548, 156, 10, 2.5).columns, 3)
		expect.equal(CertificateLogic.cellRects(548, 156, 10, "3").columns, 3)
		expect.equal(CertificateLogic.cellRects(548, 156, 10, 99).columns, 3)
	end)

	t.test("cellRects reports a squeeze: a tiny area gives the minimum size and fits = false", function()
		local g = CertificateLogic.cellRects(150, 60, 10, 2, PLACES)
		expect.equal(g.textSize, CertificateLogic.MIN_TEXT)
		expect.equal(g.fits, false)
	end)

	t.test("cellRects shrinks the text for a longer word", function()
		local base = CertificateLogic.cellRects(313, 352, 10, 2, PLACES)
		local long = {}
		for i, p in ipairs(PLACES) do long[i] = p end
		long[1] = "1. Supercalifragilisticexpialidocious Cathedral"
		local g = CertificateLogic.cellRects(313, 352, 10, 2, long)
		expect.truthy(g.textSize < base.textSize)
	end)

	t.test("cellRects returns nil for bad input", function()
		local bad = { { nil, nil, nil }, { 0, 100, 10 }, { 100, 0, 10 }, { -5, 100, 10 }, { 100, -5, 10 }, { 0 / 0, 100, 10 },
			{ 100, math.huge, 10 }, { "313", "352", 10 }, { 313, 352, 0 }, { 313, 352, -1 }, { 313, 352, 2.5 }, { 313, 352, "10" },
			{ 313, 352, 0 / 0 }, { 313, 352, math.huge }, { 313, 352, 1001 }, { 313, 352, nil }, { {}, {}, {} } }
		for _, c in ipairs(bad) do
			expect.equal(CertificateLogic.cellRects(c[1], c[2], c[3], 2, PLACES), nil)
		end
		expect.equal(CertificateLogic.cellRects(), nil)
		expect.equal(CertificateLogic.cellRects(313, 352), nil)
	end)

	t.test("cellRects ignores a malformed places list instead of erroring", function()
		local g = CertificateLogic.cellRects(313, 352, 10, 2, { 1, {}, false })
		expect.equal(#g.rects, 10)
		local g2 = CertificateLogic.cellRects(313, 352, 10, 2, "not a table")
		expect.equal(#g2.rects, 10)
	end)

	t.test("cellRects returns fresh tables each call", function()
		local a = CertificateLogic.cellRects(313, 352, 10, 2, PLACES)
		a.rects[1].w = 1
		a.columns = 99
		local b = CertificateLogic.cellRects(313, 352, 10, 2, PLACES)
		expect.truthy(b.rects[1].w > 10)
		expect.equal(b.columns, 2)
	end)

	t.test("cellRects estimate holds against the real font: Independencia and the longest label fit at the chosen size", function()
		local TextService = game:GetService("TextService")
		local function measure(text, size, width)
			local p = Instance.new("GetTextBoundsParams")
			p.Text, p.Font, p.Size, p.Width = text, Font.fromEnum(Enum.Font.Gotham), size, width
			return TextService:GetTextBoundsAsync(p)
		end
		for _, case in ipairs({ { 313, 352, 2 }, { 548, 156, 3 }, { 480, 300, 3 } }) do
			local g = CertificateLogic.cellRects(case[1], case[2], 10, case[3], PLACES)
			local cell = g.rects[1]
			local inner = cell.w - CertificateLogic.CELL_PAD
			expect.truthy(measure("Independencia", g.textSize, 10000).X <= inner)
			expect.truthy(measure(PLACES[1], g.textSize, inner).Y <= cell.h - CertificateLogic.CELL_PAD + 0.5)
			expect.truthy(measure(PLACES[10], g.textSize, g.rects[10].w - CertificateLogic.CELL_PAD).Y <= g.rects[10].h - CertificateLogic.CELL_PAD + 0.5)
		end
	end)
end
