-- run_all: the resume battery in one call. Studio copy: ServerStorage.Checks.run_all. Run in Edit mode via execute_luau:
--   require(game.ServerStorage.Checks.run_all:Clone())()            -- returns JSON {ok, mismatches, rows}
--   require(game.ServerStorage.Checks.run_all:Clone())({ override = { qa_check = 42 } })   -- test hook: proves a wrong number goes red
-- It runs the 17 stored checks, the unit suite, BuildCheck for all ten sites, checkWorld, the pivots and the terrain cell count,
-- and compares each with EXPECTED below. EXPECTED is the ONE place the baseline numbers live (docs/baseline.md points here).
-- The integrator updates EXPECTED in the same PR/commit that legitimately changes a number (a new check, a rebuilt site).
local HttpService = game:GetService("HttpService")

local EXPECTED = {
	-- stored checks: passed count (failed must be 0)
	checks = {
		site01_check = 115, -- 75 + 40: Slice 4 blueprint pass (7-tier octagonal tower, dome, wings, forecourt walls, D mound, Cultural Centre, stage roof, palms)
		site02_check = 45, site03_check = 74, site04_check = 41, site05_check = 71, site06_check = 49,
		site07_check = 34, site08_check = 29, site09_check = 26,
		sites_check = 277, -- 256 + 21: site 10 now has the SiteId/pivot/facing/Wing/Guide/InfoPanel/JeepStop/Jeepney/anchored checks, Slice 3b
		qa_check = 75, routes_check = 14, -- qa_check 44 to 75: 51 checks after the Slice 3b spawn assertions, +8 for the six-panel credits board (panels 4-6, projectLines, 25 tour sources), +16 for the ten-site PassportClient and WelcomeClient structure checks (Slice 3b step 3); routes_check 11 + 3: SpawnLocation exists, Ate Joy exists, spawn -> Ate Joy <= 40 studs, Slice 3b
		npcs_check = 237, -- 194 + 43: LocalNPCs for City Hall (4 figures, ~10 checks each) and the reserved-zone check, Slice 3b
		guides_check = 123, -- 111 + 12: Ate Joy wears the tour uniform (the 11 per-guide checks and the dressed count), Slice 3b
		site10_check = 52, -- City Hall fidelity check, Slice 3a
		placeholders_check = 30, -- placeholders({only={10}}) result on Site10_CityHall: props, reserved zones, no Block, Slice 3b; +1 real-SpawnLocation-on-forecourt check
		roads_check = 94, -- SPUR, WEST_BYPASS, EAST_BYPASS: margins, clearances, junctions, reachability, asphalt and forecourt ground, Slice 3b
	},
	unitRun = 226, -- 127 + TourContent_Test (46) + QuizKey_Test (11), Slice 2; + 5 owner-decision cases, Slice 3a; Slice 3b step 1: +25 City Hall data/layout/credits cases; Slice 3b step 3: +12 CertificateLogic.cellRects cases (226)
	-- BuildCheck per site id: { passed, parts }. Parts include each site's LocalNPCs (builders/npcs.luau, 337 parts in all for sites 1..9)
	-- and the Guide's GuideOutfit (builders/guides.luau, 8 parts per guide).
	build = {
		[1] = { 16, 1775 }, -- 1683 + 92 parts: Slice 4 blueprint pass
		[2] = { 15, 1148 }, [3] = { 15, 436 }, [4] = { 14, 705 }, [5] = { 15, 514 },
		[6] = { 15, 748 }, [7] = { 14, 723 }, [8] = { 14, 703 }, [9] = { 15, 420 },
		-- Slice 3b: 1104 City Hall parts + Guide 16 + GuideOutfit 8 + InfoPanel 1 + JeepStop, pole, sign 3 + Jeepney 6 + 4 LocalNPCs 68 = 1206;
		-- 16 passed = 11 shared checks + 5 required props (Blocks, Landscape, Wing, Forecourt, JeepStop).
		[10] = { 16, 1206 },
	},
	worldParts = 8404, -- 8312 + 92 (Cathedral blueprint pass, Slice 4); 8312 was 7100 + 1104 City Hall parts (wing 276, blocks 432, steps 57, forecourt 105, landscape 234), Slice 3a; + 102 (Ate Joy, panel, jeep stop and jeepney, 4 locals), Slice 3b; + 6 (credits board 9 to 15 parts for six panels), Slice 3b step 3 (8312)
	cells = 1793696, -- 1793270 + 426: builders/roads_extra.luau paves the SPUR and the two bypasses (Asphalt FillBlock) and repaints the City Hall forecourt ground, Slice 3b
	pivotY = { [8] = 19.8 }, -- every other site sits at y = 0
}

local function copy(t)
	local c = {}
	for k, v in pairs(t) do c[k] = type(v) == "table" and copy(v) or v end
	return c
end

return function(opts)
	opts = opts or {}
	local E = copy(EXPECTED)
	for name, passed in pairs(opts.override or {}) do E.checks[name] = passed end

	local rows, mismatches = {}, {}
	local function row(label, actual, expected)
		local same = actual == expected
		table.insert(rows, string.format("%-22s %s (expected %s)%s", label, tostring(actual), tostring(expected), same and "" or "   <-- MISMATCH"))
		if not same then table.insert(mismatches, label .. ": got " .. tostring(actual) .. ", expected " .. tostring(expected)) end
	end

	local Checks = game.ServerStorage:WaitForChild("Checks")
	local names = {}
	for name in pairs(E.checks) do table.insert(names, name) end
	table.sort(names)
	for _, name in ipairs(names) do
		local ok, r = pcall(function() return require(Checks[name]:Clone()) end)
		if ok then
			local t = type(r) == "string" and HttpService:JSONDecode(r) or r
			row(name .. " passed", t.passed, E.checks[name])
			row(name .. " failed", t.failed, 0)
		else
			row(name, "ERROR " .. tostring(r), "a result")
		end
		task.wait()
	end

	local okU, u = pcall(function() return require(game.ServerStorage.UnitTest.RunUnitTest:Clone())() end)
	if okU and type(u) == "table" then
		row("unit run", u.run, E.unitRun)
		row("unit failed", u.failed, 0)
	else
		row("unit suite", "ERROR " .. tostring(u), "a result")
	end

	local BC = require(game.ServerStorage.BuildCheck:Clone())
	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
	for id = 1, 10 do
		local model
		for _, m in ipairs(workspace.Sites:GetChildren()) do
			if tonumber(m.Name:match("^Site(%d+)")) == id then model = m end
		end
		local sd = SiteData.byId(id)
		if model and sd then
			local res = BC.checkSite(model, sd)
			local want = E.build[id]
			row(string.format("build %02d passed", id), res.passed, want[1])
			row(string.format("build %02d failed", id), res.failed, 0)
			row(string.format("build %02d parts", id), res.parts, want[2])
			local pv = model:GetPivot().Position
			local dx, dz = pv.X - sd.pos.X, pv.Z - sd.pos.Z
			row(string.format("pivot %02d xz off", id), math.sqrt(dx * dx + dz * dz) < 0.05 and "ok" or string.format("%.2f", math.sqrt(dx * dx + dz * dz)), "ok")
			row(string.format("pivot %02d y", id), math.abs(pv.Y - (E.pivotY[id] or 0)) < 0.05 and "ok" or string.format("%.2f", pv.Y), "ok")
		else
			row(string.format("site %02d", id), "missing", "present")
		end
		task.wait()
	end

	local w = BC.checkWorld()
	row("checkWorld failed", w.failed, 0)
	row("checkWorld parts", w.parts, E.worldParts)
	row("terrain cells", workspace.Terrain:CountCells(), E.cells)

	return HttpService:JSONEncode({ ok = #mismatches == 0, mismatches = mismatches, rows = rows })
end
