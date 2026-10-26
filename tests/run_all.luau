-- run_all: the resume battery in one call. Studio copy: ServerStorage.Checks.run_all. Run in Edit mode via execute_luau:
--   require(game.ServerStorage.Checks.run_all:Clone())()            -- returns JSON {ok, mismatches, rows}
--   require(game.ServerStorage.Checks.run_all:Clone())({ override = { qa_check = 42 } })   -- test hook: proves a wrong number goes red
-- It runs the 14 stored checks, the unit suite, BuildCheck for all nine sites, checkWorld, the pivots and the terrain cell count,
-- and compares each with EXPECTED below. EXPECTED is the ONE place the baseline numbers live (docs/baseline.md points here).
-- The integrator updates EXPECTED in the same PR/commit that legitimately changes a number (a new check, a rebuilt site).
local HttpService = game:GetService("HttpService")

local EXPECTED = {
	-- stored checks: passed count (failed must be 0)
	checks = {
		site01_check = 75, site02_check = 45, site03_check = 74, site04_check = 41, site05_check = 71, site06_check = 49,
		site07_check = 34, site08_check = 29, site09_check = 26, sites_check = 256, qa_check = 44, routes_check = 11,
		npcs_check = 194, guides_check = 111,
	},
	unitRun = 127,
	-- BuildCheck per site id: { passed, parts }. Parts include each site's LocalNPCs (builders/npcs.luau, 337 parts in all)
	-- and the Guide's GuideOutfit (builders/guides.luau, 8 parts per guide).
	build = {
		[1] = { 16, 1683 }, [2] = { 15, 1148 }, [3] = { 15, 436 }, [4] = { 14, 705 }, [5] = { 15, 514 },
		[6] = { 15, 748 }, [7] = { 14, 723 }, [8] = { 14, 703 }, [9] = { 15, 420 },
	},
	worldParts = 7100,
	cells = 1793270,
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
	for id = 1, 9 do
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
