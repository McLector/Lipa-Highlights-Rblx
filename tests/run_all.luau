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
		site01_check = 142, -- 141 + 1: Slice 4 credits plaza (no part of the moved CreditsBoard lies within 4 studs of the Site01 bounds). Earlier 135 + 6: Slice 4 B3c-2 (the lot and the east garden strip): 6 new assertions (cars in the south lot rows and clear of the walkway and the entrance lane, bay lines, the east garden's lawn, trees and monument, its hedge and walk-in gap, lamps down the walkway, and the exact site part count 2498 with ParkedVehicles 388, LotMarkings 52, EastGarden 36); nothing replaced. Earlier 125 + 10: Slice 4 B3c-1 (the retaining wall moves from z 48 to 112, the plaza runs to the fence at z 195): 10 new assertions (nothing buried in the podium, wall and paving and fence lines, plaza and lot depth, stage, statue and Cultural Center layout, fence clear of the credits board); the old z-literal assertions were re-pointed at WALL_Z and PLAZA_S one for one, logged in briefs/site01.md. Earlier 117 + 8: Slice 4 B3c-0b (owner's second markup): 16 new checks (statue D-shape and side flights, Cultural Center west and its east face, black fence closed on the south, east and west, 19 cars and bay lines, entrance walkways and the stair-edge guard, no Welcome Arch) minus 8 retired or replaced, logged in briefs/site01.md. Earlier 115 + 2: Slice 4 B3c-0 (owner colour markup): 15 old assertions replaced where the markup contradicts them (parish wing, LongBuildingW, stage south-west, mound west-middle, plus 7 stale ones, all logged in briefs/site01.md) and 17 new ones (wing gone, iron fence and its stair/plaza gaps, ChurchAnnex box, Structure still 763 parts, mound and stage lanes, lot and west lawn). Earlier 75 + 40: Slice 4 plaza pass (church pin, parish wing, lot, plaza, stage, Cultural Center, mound, sign text size)
		site02_check = 45, site03_check = 74, site04_check = 41, site05_check = 71, site06_check = 49,
		site07_check = 34, site08_check = 29, site09_check = 26,
		sites_check = 277, -- 256 + 21: site 10 now has the SiteId/pivot/facing/Wing/Guide/InfoPanel/JeepStop/Jeepney/anchored checks, Slice 3b
		qa_check = 85, routes_check = 16, -- qa_check 75 to 85 and routes_check 15 to 16 (Slice 4 credits plaza): the CreditsBoard section went from 19 to 28 checks (the plaza box, reading aisle, nine panels with the title, identity, notices and 78 references, RichText only on the Ref labels, fixed sizes, benches, lamps, sign), the WelcomeClient pin from 1 to 2; routes_check gains Road E start (0,225) to the Credits Plaza entrance (measured 97.47 studs in Play, cap 112). Earlier: routes_check 14 to 15: Road E start (0,225) -> Cathedral Guide (measured 279 studs, cap 320), Slice 4 B3b; qa_check 44 to 75: 51 checks after the Slice 3b spawn assertions, +8 for the six-panel credits board (panels 4-6, projectLines, 25 tour sources), +16 for the ten-site PassportClient and WelcomeClient structure checks (Slice 3b step 3); routes_check 11 + 3: SpawnLocation exists, Ate Joy exists, spawn -> Ate Joy <= 40 studs, Slice 3b
		npcs_check = 237, -- 194 + 43: LocalNPCs for City Hall (4 figures, ~10 checks each) and the reserved-zone check, Slice 3b
		guides_check = 123, -- 111 + 12: Ate Joy wears the tour uniform (the 11 per-guide checks and the dressed count), Slice 3b
		site10_check = 52, -- City Hall fidelity check, Slice 3a
		placeholders_check = 30, -- placeholders({only={10}}) result on Site10_CityHall: props, reserved zones, no Block, Slice 3b; +1 real-SpawnLocation-on-forecourt check
		roads_check = 267, -- 262 + 5 (Slice 4 credits plaza): +1 the CreditsBoard keeps 4+ studs from every road body, +4 section 6c (the plaza and entry path ground is Pavement, plus two controls). Earlier 260 + 2 (Slice 4 B3c-1: section 6b, the stretched plaza's ground is Pavement at six sample points off the old Road E strip, plus a control). Earlier 207 + 53 (Slice 4 B3c-0b, owner markup: the entrance roads WEST_ENTRY and EAST_ENTRY run from the bypasses to the foot of the Cathedral side stairs at z 26; new section 7 adds 19 assertions, the rest are the existing per-road checks now also running for the two new roads; five old road rules are replaced for those two roads only, logged in briefs/site01.md). Earlier 94 + 113 (Slice 4 B3b: section 6 keeps every road segment out of the Cathedral slot z -100..215 and its 10 percent margin, E starts at the south edge, F and G join the bypass ends, WEST_LINK and EAST_LINK; the all-roads count is 13). Earlier: SPUR, WEST_BYPASS, EAST_BYPASS: margins, clearances, junctions, reachability, asphalt and forecourt ground, Slice 3b
	},
	unitRun = 241, -- 239 + 2 (Slice 4 credits plaza): CreditsData_Test pins the owner's identity and the Gemini and Ayala Land reference letters, and one pending-identity case replaced in place. Earlier 227 + 12: CreditsData_Test cases for the 78 APA 7 references (field shapes, ASCII, markup round trip, url coverage, tour refs, author order, Gemini entry, referenceLines, noticeLines), Slice 4 credits job A. Earlier 226 + 1: SiteData case pinning the Cathedral Guide (0,30), JeepStop (-20,30) and InfoPanel (12,24) world positions after the slot moved to centre (0,57.5), Slice 4 B3b. Earlier: 127 + TourContent_Test (46) + QuizKey_Test (11), Slice 2; + 5 owner-decision cases, Slice 3a; Slice 3b step 1: +25 City Hall data/layout/credits cases; Slice 3b step 3: +12 CertificateLogic.cellRects cases (226)
	-- BuildCheck per site id: { passed, parts }. Parts include each site's LocalNPCs (builders/npcs.luau, 337 parts in all for sites 1..9)
	-- and the Guide's GuideOutfit (builders/guides.luau, 8 parts per guide).
	build = {
		[1] = { 16, 2498 }, -- 2222 + 276 (Slice 4 B3c-2): 164 parts for 41 more cars (97 in all), 52 bay and aisle lines (LotMarkings), 36 for the east garden strip (EastGarden), 24 for 6 lamps; the site is 2 parts under the 2500 cap. Earlier 2184 + 38 (Slice 4 B3c-1): the west podium fence extended along the longer lot, longer plaza fences, one asphalt part (ApronPavingEast), 3 lamps, paver joints. Earlier 2121 + 63 (Slice 4 B3c-0b, owner's second markup): + 19 cars (4 parts each) and bay lines, the statue, entrance walkways, black fence runs, the moved Cultural Center and its beds, minus the Welcome Arch (46 parts). Earlier 2331 - 210 (Slice 4 B3c-0): - 342 parish wing - 107 LongBuildingW block - 3 mound flats + 153 ChurchAnnex + 66 iron fence + 23 west lawn and palms. Earlier 1683 + 648: Slice 4 plaza pass (parish wing, lot, plaza, pavilion, Cultural Center, mound)
		[2] = { 15, 1148 }, [3] = { 15, 436 }, [4] = { 14, 705 }, [5] = { 15, 514 },
		[6] = { 15, 748 }, [7] = { 14, 723 }, [8] = { 14, 703 }, [9] = { 15, 420 },
		-- Slice 3b: 1104 City Hall parts + Guide 16 + GuideOutfit 8 + InfoPanel 1 + JeepStop, pole, sign 3 + Jeepney 6 + 4 LocalNPCs 68 = 1206;
		-- 16 passed = 11 shared checks + 5 required props (Blocks, Landscape, Wing, Forecourt, JeepStop).
		[10] = { 16, 1206 },
	},
	worldParts = 9173, -- 9127 + 46 (Slice 4 credits plaza): the old 15-part credits board out, the new 61-part Credits Plaza in. Earlier 8851 + 276 (the Site01 change of Slice 4 B3c-2, see build 01); 8851 was 8813 + 38 (the Site01 change of Slice 4 B3c-1); 8813 was 8750 + 63 (the Site01 change of Slice 4 B3c-0b, see build 01); 8750 was 8960 - 210 (Site01 change of Slice 4 B3c-0, see build 01); 8960 was 8312 + 648 (Cathedral plaza pass, Slice 4); 8312 was 7100 + 1104 City Hall parts (wing 276, blocks 432, steps 57, forecourt 105, landscape 234), Slice 3a; + 102 (Ate Joy, panel, jeep stop and jeepney, 4 locals), Slice 3b; + 6 (credits board 9 to 15 parts for six panels), Slice 3b step 3 (8312)
	cells = 1794362, -- 1794162 + 200: builders/roads_extra.luau repaints the Credits Plaza ground (x 24..152, z 272..348) and its entry path (x 4..24, z 304..316) from Grass to Pavement, Slice 4 credits plaza; a second run adds 0 (measured: the repaint changes only the material, yet the count rises as it did for the earlier repaints, cause not established). Earlier 1793870 + 292: builders/roads_extra.luau repaints the stretched Cathedral plaza ground (x -100..100, z 100..200, Grass to Pavement), Slice 4 B3c-1; a second run adds 0 (measured; the count rises with the repaint as it did for the City Hall forecourt, +426 in Slice 3b, the exact cause is not otherwise established). Earlier 1793852 + 18: builders/roads_extra.luau paves WEST_ENTRY and EAST_ENTRY (two 12-wide Asphalt strips from the bypasses to the Cathedral side stairs), Slice 4 B3c-0b; a second and third run add 0. Earlier 1793696 + 156: builders/roads_extra.luau paves WEST_LINK and EAST_LINK (Asphalt FillBlock), Slice 4 B3b; a second run gives the same count. Earlier: 1793270 + 426: builders/roads_extra.luau paves the SPUR and the two bypasses (Asphalt FillBlock) and repaints the City Hall forecourt ground, Slice 3b
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
