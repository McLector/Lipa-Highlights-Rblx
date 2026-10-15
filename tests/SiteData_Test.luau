-- Tests for ReplicatedStorage.LipaShared.SiteData.
-- Contract source: structure_model_positioning.png + the approved plan (Market shifted to -230,160).
return function(t)
	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData)
	local expect = t.expect

	local FACINGS = { N = true, S = true, E = true, W = true, NE = true, NW = true, SE = true, SW = true }

	local function footprint(s)
		return s.pos.X - s.size.X / 2, s.pos.X + s.size.X / 2, s.pos.Z - s.size.Y / 2, s.pos.Z + s.size.Y / 2
	end

	-- The world has exactly nine sites with unique ids.
	t.test("has nine sites with unique ids", function()
		expect.equal(#SiteData.sites, 9)
		local seen = {}
		for _, s in ipairs(SiteData.sites) do
			expect.falsy(seen[s.id])
			seen[s.id] = true
		end
	end)

	-- Layout legend: Eat 3, Pray 2, Love 4.
	t.test("category split is Eat 3 / Pray 2 / Love 4", function()
		local c = { Eat = 0, Pray = 0, Love = 0 }
		for _, s in ipairs(SiteData.sites) do
			expect.truthy(c[s.category] ~= nil)
			c[s.category] += 1
		end
		expect.equal(c.Eat, 3)
		expect.equal(c.Pray, 2)
		expect.equal(c.Love, 4)
	end)

	-- Exact assignment from the layout png legend (counts alone would let a wrong split pass).
	t.test("categories match the layout legend per site", function()
		local expected = { [1] = "Pray", [2] = "Eat", [3] = "Eat", [4] = "Eat", [5] = "Pray",
			[6] = "Love", [7] = "Love", [8] = "Love", [9] = "Love" }
		for id, cat in pairs(expected) do
			expect.equal(SiteData.byId(id).category, cat)
		end
	end)

	-- Positions and facings straight from the layout table (Market shifted to -230).
	t.test("positions and facings match the layout", function()
		local expected = {
			[1] = { 0, 0, "S" }, [2] = { -230, 160, "E" }, [3] = { 180, 140, "W" },
			[4] = { 160, -160, "W" }, [5] = { -300, -600, "S" }, [6] = { 550, -650, "SW" },
			[7] = { 700, 240, "W" }, [8] = { 560, 720, "NW" }, [9] = { -600, 550, "NE" },
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

	-- The Market moved from -220 to -230 to clear the Cathedral footprint.
	t.test("market sits at -230,160", function()
		local m = SiteData.byId(2)
		expect.equal(m.pos.X, -230)
		expect.equal(m.pos.Z, 160)
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

	-- Guides need 3+ non-empty lines, each short enough for the dialogue box.
	t.test("dialogue has at least 3 lines of at most 220 chars", function()
		for _, s in ipairs(SiteData.sites) do
			expect.truthy(#s.dialogue >= 3)
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
		expect.equal(SiteData.byId(10), nil)
		expect.equal(SiteData.byId("2"), nil)
		expect.equal(SiteData.byId(nil), nil)
	end)

	-- Jeep stops exist for the plaza and the five outer sites, inside their footprint.
	t.test("jeepStopPos is inside the footprint for sites 1 and 5-9", function()
		for _, id in ipairs({ 1, 5, 6, 7, 8, 9 }) do
			local s = SiteData.byId(id)
			local p = SiteData.jeepStopPos(id)
			local x0, x1, z0, z1 = footprint(s)
			expect.truthy(p.X >= x0 and p.X <= x1 and p.Z >= z0 and p.Z <= z1)
		end
		expect.equal(SiteData.jeepStopPos(2), nil)
	end)
end
