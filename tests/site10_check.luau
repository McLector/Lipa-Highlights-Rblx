-- site10_check: the Slice 3a fidelity spec for Site 10 (New Lipa City Hall), written BEFORE the build.
-- Studio copy: ServerStorage.Checks.site10_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.site10_check:Clone())      -- returns JSON {passed, failed, failures}
-- Every number comes from briefs/site10.md. The model is built in a world-aligned frame (ORIGIN below), facing +X (East).
-- Checks are grouped by builder module; set shared.site10_only = "blocks" (or wing, forecourt, landscape, general) to run one group.
local HttpService = game:GetService("HttpService")
local ORIGIN = Vector3.new(-250, 0, -260)
local SLOT_MIN, SLOT_MAX = Vector3.new(-350, 0, -330), Vector3.new(-150, math.huge, -190)

local function run(opts)
	opts = opts or {}
	local only = opts.only
	local results = { passed = 0, failed = 0, failures = {} }
	local function check(name, cond, detail)
		if cond then
			results.passed += 1
		else
			results.failed += 1
			table.insert(results.failures, name .. (detail and (" | " .. detail) or ""))
		end
	end
	local function want(group)
		return only == nil or only == group
	end

	-- The model lives in Workspace.Sites or, if the gate says so, Workspace.Staging.
	local site
	for _, parent in ipairs({ workspace:FindFirstChild("Sites"), workspace:FindFirstChild("Staging") }) do
		if parent and parent:FindFirstChild("Site10_CityHall") then site = parent.Site10_CityHall end
	end
	check("Site10_CityHall exists", site ~= nil)
	if not site then
		return HttpService:JSONEncode(results)
	end

	local function isRig(inst)
		local p = inst
		while p and p ~= site do
			if p:FindFirstChildOfClass("Humanoid") then return true end
			p = p.Parent
		end
		return false
	end
	local KEPT = { Guide = true, InfoPanel = true, JeepStop = true, JeepSignPole = true, JeepSign = true, Jeepney = true }
	local function isKept(inst)
		local p = inst
		while p and p ~= site do
			if KEPT[p.Name] and p.Parent == site then return true end
			p = p.Parent
		end
		return false
	end
	local function allNamed(name)
		local list = {}
		for _, d in ipairs(site:GetDescendants()) do
			if d.Name == name and d:IsA("BasePart") and not isRig(d) then table.insert(list, d) end
		end
		return list
	end
	local function ownParts()
		local list = {}
		for _, d in ipairs(site:GetDescendants()) do
			if d:IsA("BasePart") and not isRig(d) and not isKept(d) then table.insert(list, d) end
		end
		return list
	end
	local function rgb(p) return p.Color.R * 255, p.Color.G * 255, p.Color.B * 255 end
	local function top(p) return p.Position.Y + p.Size.Y / 2 end
	local function bottom(p) return p.Position.Y - p.Size.Y / 2 end
	-- Axis-aligned world box of a part (the builder uses unrotated boxes for the checked names).
	local function overlaps(p, minV, maxV)
		local h = p.Size / 2
		local a, b = p.Position - h, p.Position + h
		return a.X < maxV.X and b.X > minV.X and a.Y < maxV.Y and b.Y > minV.Y and a.Z < maxV.Z and b.Z > minV.Z
	end

	------------------------------------------------------------------ general
	if want("general") then
		local pv = site:GetPivot()
		check("pivot is at (-250, 0, -260), facing East (+X)",
			(pv.Position - ORIGIN).Magnitude < 0.05 and pv.LookVector:Dot(Vector3.new(1, 0, 0)) > 0.999,
			string.format("(%.2f, %.2f, %.2f) look %s", pv.X, pv.Y, pv.Z, tostring(pv.LookVector)))

		local parts = ownParts()
		local n = #parts
		check("own part count is 1000..2500", n >= 1000 and n <= 2500, tostring(n))

		local lo, hi = Vector3.new(math.huge, math.huge, math.huge), Vector3.new(-math.huge, -math.huge, -math.huge)
		local unanchored, outside = 0, {}
		for _, p in ipairs(parts) do
			local h = p.Size / 2
			lo = Vector3.new(math.min(lo.X, p.Position.X - h.X), math.min(lo.Y, p.Position.Y - h.Y), math.min(lo.Z, p.Position.Z - h.Z))
			hi = Vector3.new(math.max(hi.X, p.Position.X + h.X), math.max(hi.Y, p.Position.Y + h.Y), math.max(hi.Z, p.Position.Z + h.Z))
			if not p.Anchored then unanchored += 1 end
		end
		-- real bounds, not an assumed footprint: the largest corner extents must stay in the slot (0.5 stud tolerance)
		check("real bounds stay inside the slot x -350..-150, z -330..-190",
			n > 0 and lo.X >= SLOT_MIN.X - 0.5 and hi.X <= SLOT_MAX.X + 0.5 and lo.Z >= SLOT_MIN.Z - 0.5 and hi.Z <= SLOT_MAX.Z + 0.5,
			string.format("x %.1f..%.1f, z %.1f..%.1f", lo.X, hi.X, lo.Z, hi.Z))
		check("nothing builds below the ground", n > 0 and lo.Y >= -0.5, string.format("min y %.2f", lo.Y))
		check("every part is anchored", n > 0 and unanchored == 0, unanchored .. " unanchored")

		for _, name in ipairs({ "Wing", "Blocks", "Steps", "Forecourt", "Landscape" }) do
			local c = site:FindFirstChild(name)
			local cnt = 0
			if c then for _, d in ipairs(c:GetDescendants()) do if d:IsA("BasePart") then cnt += 1 end end end
			check("container " .. name .. " holds parts", c ~= nil and cnt > 0, c and (cnt .. " parts") or "missing")
		end

		local images = 0
		for _, d in ipairs(site:GetDescendants()) do
			if not isKept(d) and (d:IsA("Decal") or d:IsA("Texture") or d:IsA("ImageLabel") or d:IsA("ImageButton")) then images += 1 end
		end
		check("zero image instances (signs are text only: no seal, no logo)", images == 0, tostring(images))

		local badText = {}
		for _, g in ipairs(site:GetDescendants()) do
			if g:IsA("TextLabel") and not isKept(g) and g.TextScaled and #g.Text > 14 and not g.Parent:IsA("Frame") then
				table.insert(badText, g.Text:sub(1, 20))
			end
		end
		check("no long TextScaled line sits directly on a board", #badText == 0, table.concat(badText, "; "))

		local logoWords = {}
		for _, d in ipairs(site:GetDescendants()) do
			local t = (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text or ""
			local u = t:upper()
			if not isKept(d) and (u:find("BAGONG") or u:find("SEAL") or u:find("KOPI") or u:find("ABOITIZ")) then table.insert(logoWords, t) end
		end
		check("no seal or brand text", #logoWords == 0, table.concat(logoWords, "; "))

		-- Reserved empty zones (Slices 3b, 8, 9): nothing of ours inside them.
		local zones = {
			SpawnPad = { Vector3.new(30, 0, -10), Vector3.new(50, 40, 10) },
			JeepCurb = { Vector3.new(90, 0, 20), Vector3.new(100, 40, 40) },
			BillboardSpot = { Vector3.new(28, 0, -30), Vector3.new(38, 40, -15) },
		}
		for zname, z in pairs(zones) do
			local lo2, hi2 = ORIGIN + z[1], ORIGIN + z[2]
			local hit = {}
			for _, p in ipairs(parts) do
				-- flat ground paving (thin slabs under 0.6) is allowed; anything taller is not
				if overlaps(p, lo2, hi2) and top(p) > 0.6 then table.insert(hit, p.Name) end
			end
			check("reserved zone " .. zname .. " is clear", #hit == 0, #hit .. " parts: " .. table.concat(hit, ",", 1, math.min(#hit, 4)))
		end
	end

	------------------------------------------------------------------ blocks (72, 6 x 12, walk-under)
	if want("blocks") then
		local blocks = allNamed("ElevatedBlock")
		check("exactly 72 ElevatedBlock", #blocks == 72, tostring(#blocks))
		local rows, cols = {}, {}
		local lowest, badSize = math.huge, 0
		for _, b in ipairs(blocks) do
			local rx, rz = math.floor((b.Position.X - ORIGIN.X) / 5 + 0.5), math.floor((b.Position.Z - ORIGIN.Z) / 5 + 0.5)
			rows[rx] = true
			cols[rz] = true
			lowest = math.min(lowest, bottom(b))
			if b.Size.X < 6 or b.Size.X > 8 or b.Size.Z < 6 or b.Size.Z > 8 or b.Size.Y < 5 or b.Size.Y > 7 then badSize += 1 end
		end
		local nr, nc = 0, 0
		for _ in pairs(rows) do nr += 1 end
		for _ in pairs(cols) do nc += 1 end
		check("blocks form 6 rows (along x)", nr == 6, tostring(nr))
		check("blocks form 12 columns (along z)", nc == 12, tostring(nc))
		check("every block underside is at least 9 studs up", #blocks > 0 and lowest >= 9 - 0.05, string.format("lowest %.2f", lowest))
		check("every block is about 7 x 6 x 7", #blocks > 0 and badSize == 0, badSize .. " off-size")
		local brick = 0
		for _, b in ipairs(blocks) do if b.Material == Enum.Material.Brick then brick += 1 end end
		check("blocks are brick clad", #blocks > 0 and brick == #blocks, brick .. " of " .. #blocks)

		-- Walk-under: a ground-level 4-wide, 6-tall box at each block's centre overlaps no part of ours.
		local others = {}
		for _, p in ipairs(ownParts()) do table.insert(others, p) end
		local blocked = 0
		for _, b in ipairs(blocks) do
			local lo2 = Vector3.new(b.Position.X - 2, 0.05, b.Position.Z - 2)
			local hi2 = Vector3.new(b.Position.X + 2, 6, b.Position.Z + 2)
			for _, p in ipairs(others) do
				if p ~= b and overlaps(p, lo2, hi2) and top(p) > 0.6 then blocked += 1 break end
			end
		end
		check("a 4 x 6 stud clearance under every block centre is empty", #blocks > 0 and blocked == 0, blocked .. " blocked")
		local pil = allNamed("BlockPilotis")
		check("each block stands on 4 pilotis (288)", #pil == 288, tostring(#pil))
	end

	------------------------------------------------------------------ wing, atrium, canopy
	if want("wing") then
		local floors = allNamed("WingFloor")
		check("wing has 4 floor slabs", #floors == 4, tostring(#floors))
		table.sort(floors, function(a, b) return a.Position.Y < b.Position.Y end)
		local pitchOk = #floors == 4
		for i = 2, #floors do
			local dy = floors[i].Position.Y - floors[i - 1].Position.Y
			if dy < 13 - 0.05 or dy > 15 + 0.05 then pitchOk = false end
		end
		check("floor-to-floor is 13..15 studs", pitchOk)
		check("ground level of the wing is open on pilotis (first floor at least 9 up)", #floors > 0 and bottom(floors[1]) >= 9 - 0.05,
			#floors > 0 and string.format("%.2f", bottom(floors[1])) or "no floors")
		check("wing has pilotis", #allNamed("WingPilotis") >= 6, tostring(#allNamed("WingPilotis")))
		local glass = 0
		for _, g in ipairs(allNamed("GlazedBay")) do if g.Material == Enum.Material.Glass then glass += 1 end end
		check("at least 6 glazed bays, all Glass", glass >= 6 and glass == #allNamed("GlazedBay"), glass .. " glass of " .. #allNamed("GlazedBay"))
		check("brick-clad projecting volumes (at least 6 WingBrick)", #allNamed("WingBrick") >= 6, tostring(#allNamed("WingBrick")))
		check("wing balconies with railings (at least 6 WingRailing, 3 tall)", (function()
			local r = allNamed("WingRailing")
			if #r < 6 then return false end
			for _, p in ipairs(r) do if p.Size.Y < 3 - 0.05 then return false end end
			return true
		end)(), tostring(#allNamed("WingRailing")))

		local atrium = allNamed("OpenLobby")
		check("open-air atrium floor exists (OpenLobby)", #atrium >= 1)
		local canopy = allNamed("AtriumCanopy")
		check("AtriumCanopy exists", #canopy >= 1)
		local supports = allNamed("CanopySupport")
		check("canopy has supports", #supports >= 4, tostring(#supports))
		if #canopy >= 1 and #supports >= 4 then
			local maxCanopyX, maxSupportX = -math.huge, -math.huge
			for _, c in ipairs(canopy) do maxCanopyX = math.max(maxCanopyX, c.Position.X + c.Size.X / 2) end
			for _, s in ipairs(supports) do maxSupportX = math.max(maxSupportX, s.Position.X + s.Size.X / 2) end
			check("canopy overhangs its supports by at least 10 studs", maxCanopyX - maxSupportX >= 10, string.format("%.1f", maxCanopyX - maxSupportX))
		end
		-- The atrium stays open to the sky: no roof part over the OpenLobby floor except the canopy and its supports.
		if #atrium >= 1 then
			local a = atrium[1]
			local lo2 = Vector3.new(a.Position.X - a.Size.X / 2 + 1, top(a) + 1, a.Position.Z - a.Size.Z / 2 + 1)
			local hi2 = Vector3.new(a.Position.X + a.Size.X / 2 - 1, 200, a.Position.Z + a.Size.Z / 2 - 1)
			local covered = 0
			for _, p in ipairs(ownParts()) do
				if overlaps(p, lo2, hi2) and p.Name ~= "AtriumCanopy" and p.Name ~= "CanopySupport" and not p.Name:find("^Canopy") then covered += 1 end
			end
			check("atrium is open to the sky apart from the canopy", covered == 0, covered .. " parts overhead")
		end
		local doors = allNamed("EntranceDoor")
		local doorsOk = #doors >= 2
		for _, d in ipairs(doors) do if d.Size.Y < 8 - 0.05 then doorsOk = false end end
		check("at least 2 entrance doors, each 8 or more tall", doorsOk, tostring(#doors))
	end

	------------------------------------------------------------------ steps and forecourt
	if want("forecourt") then
		local risers, treads = allNamed("StepRiser"), allNamed("StepTread")
		check("terraced steps exist (at least 6 risers and treads)", #risers >= 6 and #treads >= 6, #risers .. " risers, " .. #treads .. " treads")
		local bad = 0
		for _, r in ipairs(risers) do if r.Size.Y > 1.2 + 0.001 then bad += 1 end end
		for _, t in ipairs(treads) do if t.Size.X < 2 - 0.001 then bad += 1 end end
		check("every riser is at most 1.2 and every tread at least 2", bad == 0, bad .. " off")
		check("planted terraces (at least 6 TerraceLawn)", #allNamed("TerraceLawn") >= 6, tostring(#allNamed("TerraceLawn")))

		local pole = allNamed("Flagpole")
		check("one Flagpole at least 30 tall", #pole == 1 and pole[1].Size.Y >= 30 - 0.05, #pole == 1 and string.format("%.1f", pole[1].Size.Y) or tostring(#pole))
		check("vehicle loop (at least 8 LoopRoad segments) and an island", #allNamed("LoopRoad") >= 8 and #allNamed("LoopIsland") >= 1, #allNamed("LoopRoad") .. " segments")
		check("forecourt paving exists", #allNamed("ForecourtPaving") >= 1)
		check("parking bay lines (at least 12 BayLine)", #allNamed("BayLine") >= 12, tostring(#allNamed("BayLine")))
		-- The pole stands on the loop island, near the middle of the forecourt.
		if #pole == 1 then
			local lx = pole[1].Position.X - ORIGIN.X
			check("flagpole is on the forecourt (lx 25..100)", lx >= 25 and lx <= 100, string.format("lx %.1f", lx))
		end
	end

	------------------------------------------------------------------ landscape
	if want("landscape") then
		check("at least 12 trees", #allNamed("TreeCanopy") >= 12, tostring(#allNamed("TreeCanopy")))
		check("trees have trunks", #allNamed("TreeTrunk") >= 12, tostring(#allNamed("TreeTrunk")))
		check("at least 3 pocket gardens", (function()
			local g = site:FindFirstChild("Landscape") and site.Landscape:FindFirstChild("PocketGardens")
			return g ~= nil and #g:GetChildren() >= 3
		end)(), "Landscape.PocketGardens with 3+ children")
		check("at least 8 parked cars (CarBody)", #allNamed("CarBody") >= 8, tostring(#allNamed("CarBody")))
		local wheels = allNamed("CarWheel")
		check("cars have wheels (4 per car)", #wheels >= 4 * #allNamed("CarBody") and #wheels > 0, tostring(#wheels))
		-- Cars must not sit on the loop island or in the reserved zones (the general check covers the zones).
		local pole = allNamed("Flagpole")[1]
		if pole then
			local near = 0
			for _, c in ipairs(allNamed("CarBody")) do
				local d = Vector3.new(c.Position.X - pole.Position.X, 0, c.Position.Z - pole.Position.Z).Magnitude
				if d < 8 then near += 1 end
			end
			check("no car parked on the flag island", near == 0, tostring(near))
		end
	end

	return HttpService:JSONEncode(results)
end

-- Like the other stored checks this returns the JSON string when required. A builder agent runs one group with
-- shared.site10_only = "blocks" (wing, forecourt, landscape, general) set first; run_all leaves it nil and runs everything.
return run({ only = shared.site10_only })
