-- placeholders_check: the spec for builders/placeholders.luau opts.only (Slice 3b), written BEFORE the change.
-- Studio copy: ServerStorage.Checks.placeholders_check. Run in Edit via execute_luau:
--   local r = require(game.ServerStorage.Checks.placeholders_check:Clone())   -- a table {passed, failed, failures, proveOnly}
-- run_all reads r.passed / r.failed. Requiring it is READ-ONLY: it checks the state that placeholders({ only = { 10 } }) leaves
-- Site10_CityHall in (Guide with GuidePrompt, InfoPanel, JeepStop with JeepPrompt, JeepSignPole, JeepSign, Jeepney, no Block),
-- and that those props honour the reserved zones (local frame: lx along the facing E = world +X, lz = world +Z; origin = the
-- site pos (-270, 0, -305) since Step C; the zones are the same WORLD boxes as before, re-expressed in this frame).
-- r.proveOnly() is the MUTATING proof, run by hand only after the builder has opts.only: it snapshots the other nine site models
-- and Site10's Wing / Blocks / Steps / Forecourt / Landscape (part counts + sorted name lists), calls placeholders({ only = { 10 } }),
-- compares, calls it a second time (idempotent) and compares again. It leaves the Guide undressed: re-run builders/guides.luau.
-- Spawn-pad distance: measured against the REAL Workspace.SpawnLocation (builders/spawn.luau puts it at world x -214..-202,
-- z -266..-254) and the Guide at local (47, 45) = world (-223, -260), 9 studs west of the pad edge. The check requires >= 6.
-- (Slice 3b first loosened this to 2.9 against the reserved zone lx 30..50; the smaller 12 x 12 pad restored the 6 studs.)
local HttpService = game:GetService("HttpService")
local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())

local results = { passed = 0, failed = 0, failures = {} }
local function check(name, cond, detail)
	if cond then
		results.passed += 1
	else
		results.failed += 1
		table.insert(results.failures, name .. (detail and (" | " .. detail) or ""))
	end
end
local function fmt(n) return string.format("%.2f", n) end

local spawnPart = workspace:FindFirstChild("SpawnLocation")
local PAD = { x0 = -214, x1 = -202, z0 = -266, z1 = -254 }
if spawnPart then
	PAD = { x0 = spawnPart.Position.X - spawnPart.Size.X / 2, x1 = spawnPart.Position.X + spawnPart.Size.X / 2,
		z0 = spawnPart.Position.Z - spawnPart.Size.Z / 2, z1 = spawnPart.Position.Z + spawnPart.Size.Z / 2 }
end
local ORIGIN = Vector3.new(-270, 0, -305) -- Step C frame (SiteData row 10 pos); the world positions of the pins did not move
local function toLocal(p) return p.X - ORIGIN.X, p.Z - ORIGIN.Z end -- facing E: lx = dx, lz = dz
local function padDistance(p)
	local dx = math.max(PAD.x0 - p.X, 0, p.X - PAD.x1)
	local dz = math.max(PAD.z0 - p.Z, 0, p.Z - PAD.z1)
	return math.sqrt(dx * dx + dz * dz)
end
local STRUCT = { "Wing", "Blocks", "Steps", "Forecourt", "Landscape" }

local function placeholdersFn()
	return require(game.ServerStorage.Builders.placeholders:Clone())
end

check("placeholders.luau still returns a function (default mode kept)", type(placeholdersFn()) == "function")

local sites = workspace:FindFirstChild("Sites")
local m = sites and sites:FindFirstChild("Site10_CityHall")
check("Site10_CityHall exists", m ~= nil)
if m then
	check("Site10_CityHall has the SiteId attribute 10", m:GetAttribute("SiteId") == 10, tostring(m:GetAttribute("SiteId")))
	check("Site10_CityHall has no Block (real structure)", m:FindFirstChild("Block") == nil)
	for _, n in ipairs(STRUCT) do
		check("Site10_CityHall keeps " .. n, m:FindFirstChild(n) ~= nil)
	end
	local function only(name)
		local c = 0
		for _, ch in ipairs(m:GetChildren()) do
			if ch.Name == name then c += 1 end
		end
		return c
	end

	local guide = m:FindFirstChild("Guide")
	check("Guide is a Model with a Humanoid", guide ~= nil and guide:IsA("Model") and guide:FindFirstChildOfClass("Humanoid") ~= nil)
	local hrp = guide and guide:FindFirstChild("HumanoidRootPart")
	local gp = hrp and hrp:FindFirstChild("GuidePrompt")
	check("Guide has a GuidePrompt with PromptKind Guide", gp ~= nil and gp:IsA("ProximityPrompt") and gp:GetAttribute("PromptKind") == "Guide")
	check("Guide has the SiteId attribute 10", guide ~= nil and guide:GetAttribute("SiteId") == 10)
	check("exactly one Guide", only("Guide") == 1, tostring(only("Guide")))

	local panel = m:FindFirstChild("InfoPanel")
	check("InfoPanel exists", panel ~= nil and panel:IsA("BasePart"))
	local stop = m:FindFirstChild("JeepStop")
	check("JeepStop exists with a JeepPrompt", stop ~= nil and stop:IsA("BasePart") and stop:FindFirstChild("JeepPrompt") ~= nil
		and stop.JeepPrompt:GetAttribute("PromptKind") == "Jeep")
	check("JeepSignPole exists", m:FindFirstChild("JeepSignPole") ~= nil)
	check("JeepSign exists", m:FindFirstChild("JeepSign") ~= nil)
	check("Jeepney exists", m:FindFirstChild("Jeepney") ~= nil)
	for _, n in ipairs({ "InfoPanel", "JeepStop", "JeepSignPole", "JeepSign", "Jeepney" }) do
		check("exactly one " .. n, only(n) == 1, tostring(only(n)))
	end

	local structure = {}
	for _, n in ipairs(STRUCT) do
		if m:FindFirstChild(n) then table.insert(structure, m[n]) end
	end
	local op = OverlapParams.new()
	op.FilterType = Enum.RaycastFilterType.Include
	op.FilterDescendantsInstances = structure

	if hrp then
		local p = hrp.Position
		check("Guide is at least 6 studs from the spawn pad rectangle", padDistance(p) >= 6, fmt(padDistance(p)))
		check("the real SpawnLocation is on the City Hall forecourt (pad centre within 20 studs of the Guide)",
			spawnPart ~= nil and (Vector3.new(spawnPart.Position.X - p.X, 0, spawnPart.Position.Z - p.Z)).Magnitude <= 20,
			spawnPart and tostring(spawnPart.Position) or "no SpawnLocation")
		local ex = workspace:Raycast(Vector3.new(p.X, 80, p.Z), Vector3.new(0, -200, 0), (function()
			local rp = RaycastParams.new()
			rp.FilterType = Enum.RaycastFilterType.Include
			rp.FilterDescendantsInstances = { workspace.Terrain }
			return rp
		end)())
		local gy = ex and ex.Position.Y or p.Y - 3
		-- The Guide's cell: 3 x 5 x 3 from 1 stud above the ground (the paving is under that), no City Hall part inside.
		local hits = workspace:GetPartBoundsInBox(CFrame.new(p.X, gy + 3.5, p.Z), Vector3.new(3, 5, 3), op)
		local names = {}
		for _, h in ipairs(hits) do table.insert(names, h:GetFullName()) end
		check("Guide cell is free of City Hall parts", #hits == 0, #hits .. ": " .. table.concat(names, ", ", 1, math.min(#names, 3)))
		local lx, lz = toLocal(p)
		local g = SiteData.guidePos(10)
		check("Guide stands at SiteData.guidePos", Vector3.new(p.X - g.X, 0, p.Z - g.Z).Magnitude <= 1, fmt(lx) .. ", " .. fmt(lz))
	end
	if stop then
		local lx, lz = toLocal(stop.Position)
		check("JeepStop is inside the curb zone (lx 110..120, lz 65..85 = world x -160..-150, z -240..-220, tolerance 2)",
			lx >= 108 and lx <= 122 and lz >= 63 and lz <= 87, fmt(lx) .. ", " .. fmt(lz))
		check("JeepStop is at world (-155, -230) within 2 studs", Vector3.new(stop.Position.X + 155, 0, stop.Position.Z + 230).Magnitude <= 2,
			tostring(stop.Position))
	end
	if panel then
		local lx, lz = toLocal(panel.Position)
		check("InfoPanel is inside its zone (lx 48..58, lz 15..30 = world x -222..-212, z -290..-275)", lx >= 48 and lx <= 58 and lz >= 15 and lz <= 30,
			fmt(lx) .. ", " .. fmt(lz))
		check("InfoPanel is at world (-217, -282) within 2 studs", Vector3.new(panel.Position.X + 217, 0, panel.Position.Z + 282).Magnitude <= 2,
			tostring(panel.Position))
		local hits = workspace:GetPartBoundsInBox(panel.CFrame, panel.Size, op)
		local solid = {}
		for _, h in ipairs(hits) do
			if h.Name ~= "ForecourtPaving" then table.insert(solid, h:GetFullName()) end
		end
		check("InfoPanel does not overlap City Hall parts", #solid == 0, table.concat(solid, ", ", 1, math.min(#solid, 3)))
	end
end

-- The MUTATING proof (by hand, after the change). Returns {passed, failed, failures}.
local function snapshot()
	local snap = { models = {}, struct = {} }
	for _, c in ipairs(sites:GetChildren()) do
		if c.Name ~= "Site10_CityHall" then
			local names, parts = {}, 0
			for _, d in ipairs(c:GetDescendants()) do
				table.insert(names, d.Name)
				if d:IsA("BasePart") then parts += 1 end
			end
			table.sort(names)
			snap.models[c.Name] = { parts = parts, names = table.concat(names, "|"), inst = c }
		end
	end
	local city = sites.Site10_CityHall
	for _, n in ipairs(STRUCT) do
		local ch = city:FindFirstChild(n)
		local names, parts = {}, 0
		for _, d in ipairs(ch and ch:GetDescendants() or {}) do
			table.insert(names, d.Name)
			if d:IsA("BasePart") then parts += 1 end
		end
		table.sort(names)
		snap.struct[n] = { parts = parts, names = table.concat(names, "|"), inst = ch }
	end
	local gen = {}
	for _, n in ipairs({ "Guide", "InfoPanel", "JeepStop", "JeepSignPole", "JeepSign", "Jeepney" }) do
		local cnt, parts = 0, 0
		for _, ch in ipairs(city:GetChildren()) do
			if ch.Name == n then
				cnt += 1
				parts += ch:IsA("BasePart") and 1 or 0
				for _, d in ipairs(ch:GetDescendants()) do
					if d:IsA("BasePart") then parts += 1 end
				end
			end
		end
		gen[n] = cnt .. "/" .. parts
	end
	snap.gen = gen
	snap.count = #sites:GetChildren()
	return snap
end

results.proveOnly = function()
	local proof = { passed = 0, failed = 0, failures = {} }
	local function pcheck(name, cond, detail)
		if cond then proof.passed += 1 else
			proof.failed += 1
			table.insert(proof.failures, name .. (detail and (" | " .. detail) or ""))
		end
	end
	local src = game.ServerStorage.Builders.placeholders
	local okSrc, text = pcall(function() return src.Source end)
	if okSrc and not string.find(text, "opts.only", 1, true) then
		return { passed = 0, failed = 1, failures = { "placeholders.luau has no opts.only yet: refusing to call it (the default mode destroys Workspace.Sites)" } }
	end
	local before = snapshot()
	local function compare(tag, a, b)
		pcheck(tag .. ": Sites child count unchanged", a.count == b.count, a.count .. " vs " .. b.count)
		for name, v in pairs(a.models) do
			local w = b.models[name]
			pcheck(tag .. ": " .. name .. " untouched (same instance, parts, names)", w ~= nil and w.inst == v.inst and w.parts == v.parts and w.names == v.names,
				w and (v.parts .. " vs " .. w.parts) or "missing")
		end
		for n, v in pairs(a.struct) do
			local w = b.struct[n]
			pcheck(tag .. ": Site10/" .. n .. " untouched", w ~= nil and w.inst == v.inst and w.parts == v.parts and w.names == v.names,
				w and (v.parts .. " vs " .. w.parts) or "missing")
		end
	end
	local ok1, err1 = pcall(function() return placeholdersFn()({ only = { 10 } }) end)
	pcheck("placeholders({only={10}}) runs", ok1, tostring(err1))
	local after1 = snapshot()
	compare("run 1", before, after1)
	local ok2, err2 = pcall(function() return placeholdersFn()({ only = { 10 } }) end)
	pcheck("second placeholders({only={10}}) runs", ok2, tostring(err2))
	local after2 = snapshot()
	compare("run 2", before, after2)
	for n, v in pairs(after1.gen) do
		pcheck("idempotent: " .. n .. " count/parts stable between runs", after2.gen[n] == v, v .. " vs " .. tostring(after2.gen[n]))
	end
	proof.gen = after2.gen
	return proof
end

local out = { passed = results.passed, failed = results.failed, failures = results.failures, proveOnly = results.proveOnly }
-- A table (not a JSON string) so the proof function survives; run_all and callers read .passed / .failed.
return setmetatable(out, { __tostring = function() return HttpService:JSONEncode({ passed = out.passed, failed = out.failed, failures = out.failures }) end })
