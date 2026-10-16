-- Tests for ReplicatedStorage.LipaShared.CertificateLogic (pure; no Instances).
-- Contract: cleanName(raw) -> a display name safe to print: non-strings, empty and whitespace-only input give "Traveler";
-- control characters are dropped; the result is at most 40 UTF-8 characters (cut on a character boundary, never mid-glyph).
-- build(state, displayName, sites) -> nil unless the passport state is complete (9/9); otherwise
-- { title, player, places = { "1. <name>", ... in id order }, count } where sites is SiteData.sites.
return function(t)
	local CertificateLogic = require(game.ReplicatedStorage.LipaShared.CertificateLogic:Clone())
	local PassportLogic = require(game.ReplicatedStorage.LipaShared.PassportLogic)
	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
	local expect = t.expect

	local function stamped(ids)
		local s = PassportLogic.new()
		for _, id in ipairs(ids) do PassportLogic.stamp(s, id) end
		return s
	end
	local function full() return stamped({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }) end

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
	t.test("build returns nil below 9/9", function()
		expect.equal(CertificateLogic.build(PassportLogic.new(), "Ana", SiteData.sites), nil)
		expect.equal(CertificateLogic.build(stamped({ 1, 2, 3, 4, 5, 6, 7, 8 }), "Ana", SiteData.sites), nil)
	end)

	t.test("build returns nil for nil, non-table and malformed state", function()
		expect.equal(CertificateLogic.build(nil, "Ana", SiteData.sites), nil)
		expect.equal(CertificateLogic.build("done", "Ana", SiteData.sites), nil)
		expect.equal(CertificateLogic.build(9, "Ana", SiteData.sites), nil)
		expect.equal(CertificateLogic.build({}, "Ana", SiteData.sites), nil)
		expect.equal(CertificateLogic.build({ n = 9, total = 9 }, "Ana", SiteData.sites), nil) -- not a real passport state
	end)

	t.test("build at 9/9 lists the nine places in id order", function()
		local cert = CertificateLogic.build(full(), "Ana", SiteData.sites)
		expect.truthy(cert)
		expect.equal(cert.count, 9)
		expect.equal(#cert.places, 9)
		for i, s in ipairs(SiteData.sites) do
			expect.equal(cert.places[i], i .. ". " .. s.name)
		end
	end)

	t.test("build at 9/9 has a title and a player line carrying the cleaned name", function()
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

	t.test("build with a sites list that is not nine entries returns nil", function()
		expect.equal(CertificateLogic.build(full(), "Ana", {}), nil)
		expect.equal(CertificateLogic.build(full(), "Ana", nil), nil)
	end)
end
