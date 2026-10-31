-- BuildCheck: structural checks for a built site, run after every site builder (Edit mode, via execute_luau).
--   BuildCheck.checkSite(model, siteRow) -> { passed, failed, failures = { "<check name> | <detail>" }, parts }
--   BuildCheck.checkWorld(root?, limit?) -> same shape; root defaults to workspace, limit to 25,000 parts (BuildCheck.WORLD_PART_BUDGET).
-- Terrain-dependent checks (Guide on terrain, JeepStop on dry land) stay in tests/sites_check.luau.
-- A rig is any Model that contains a Humanoid: its parts are exempt from the anchored check, but they
-- still count towards the part budget. Bounds are compared in world axes, so diagonal sites work too.
-- Load with require(module:Clone()) so edits take effect.
local Players = game:GetService("Players")
local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData)

local SITE_PART_BUDGET = 2500
local WORLD_PART_BUDGET = 25000 -- 20000 until 2026-10-31 (owner: raised for the Outlets, Farm and Malarayat rebuilds; StreamingEnabled is on)
local BOUNDS_MARGIN = 1.1

local BuildCheck = {}

local function newResults()
	return { passed = 0, failed = 0, failures = {}, parts = 0 }
end

local function record(res, name, cond, detail)
	if cond then
		res.passed += 1
	else
		res.failed += 1
		table.insert(res.failures, name .. (detail and (" | " .. detail) or ""))
	end
end

local function isRig(inst)
	return inst:IsA("Model") and inst:FindFirstChildOfClass("Humanoid") ~= nil
end

-- True when the part sits under a rig somewhere between itself and `root`.
local function insideRig(part, root)
	local p = part.Parent
	while p and p ~= root do
		if isRig(p) then
			return true
		end
		p = p.Parent
	end
	return false
end

local function hasPart(inst)
	if inst:IsA("BasePart") then
		return true
	end
	for _, d in ipairs(inst:GetDescendants()) do
		if d:IsA("BasePart") then
			return true
		end
	end
	return false
end

local function fmt(v)
	return string.format("%.1f", v)
end

function BuildCheck.checkSite(model, row)
	local res = newResults()
	if type(row) ~= "table" or row.pos == nil then
		record(res, "site row known", false, "no site row given")
		return res
	end
	record(res, "model exists", model ~= nil and typeof(model) == "Instance" and model:IsA("Model"), tostring(model))
	if res.failed > 0 then
		return res
	end

	-- Pivot and facing.
	local pivot = model:GetPivot()
	local off = (pivot.Position - row.pos).Magnitude
	record(res, "pivot within 1 stud of pos", off <= 1, string.format("%s studs off, pivot %s", fmt(off), tostring(pivot.Position)))
	local dot = pivot.LookVector:Dot(SiteData.facingVector(row.facing))
	record(res, "facing dot > 0.99", dot > 0.99, string.format("dot %.3f", dot))

	-- Counts, anchoring.
	local parts, loose = 0, 0
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") then
			parts += 1
			if not d.Anchored and not insideRig(d, model) then
				loose += 1
			end
		end
	end
	res.parts = parts

	-- Bounds: the world-aligned XZ extent of every part's own 8 corners, compared with footprint +10%.
	-- (The corners of Model:GetBoundingBox are not usable: that box is oriented to the pivot, so on a 45 degree
	-- site its corners overshoot the real extent.)
	if parts == 0 then
		record(res, "bounds within footprint +10%", false, "model has no parts")
	else
		local minX, maxX, minZ, maxZ = math.huge, -math.huge, math.huge, -math.huge
		for _, d in ipairs(model:GetDescendants()) do
			if d:IsA("BasePart") then
				local half = d.Size / 2
				for _, sx in ipairs({ -1, 1 }) do
					for _, sy in ipairs({ -1, 1 }) do
						for _, sz in ipairs({ -1, 1 }) do
							local w = d.CFrame:PointToWorldSpace(Vector3.new(sx * half.X, sy * half.Y, sz * half.Z))
							minX, maxX = math.min(minX, w.X), math.max(maxX, w.X)
							minZ, maxZ = math.min(minZ, w.Z), math.max(maxZ, w.Z)
						end
					end
				end
			end
		end
		local halfX = row.size.X / 2 * BOUNDS_MARGIN
		local halfZ = row.size.Y / 2 * BOUNDS_MARGIN
		local inside = minX >= row.pos.X - halfX - 0.01 and maxX <= row.pos.X + halfX + 0.01
			and minZ >= row.pos.Z - halfZ - 0.01 and maxZ <= row.pos.Z + halfZ + 0.01
		record(res, "bounds within footprint +10%", inside, string.format(
			"x %s..%s (limit %s..%s), z %s..%s (limit %s..%s)",
			fmt(minX), fmt(maxX), fmt(row.pos.X - halfX), fmt(row.pos.X + halfX),
			fmt(minZ), fmt(maxZ), fmt(row.pos.Z - halfZ), fmt(row.pos.Z + halfZ)))
	end

	-- Guide.
	local guide = model:FindFirstChild("Guide")
	local hrp = guide and guide:FindFirstChild("HumanoidRootPart")
	record(res, "Guide present", guide ~= nil and guide:IsA("Model") and guide:FindFirstChildOfClass("Humanoid") ~= nil and hrp ~= nil)
	local gp = hrp and hrp:FindFirstChild("GuidePrompt")
	record(res, "GuidePrompt present", gp ~= nil and gp:IsA("ProximityPrompt") and gp:GetAttribute("PromptKind") == "Guide")

	-- InfoPanel with text.
	local panel = model:FindFirstChild("InfoPanel")
	local gui = panel and panel:FindFirstChildOfClass("SurfaceGui")
	local label = gui and gui:FindFirstChildWhichIsA("TextLabel", true)
	record(res, "InfoPanel with text", label ~= nil and #label.Text > 0)

	-- JeepStop exactly where SiteData says so.
	local stop = model:FindFirstChild("JeepStop")
	if SiteData.hasJeepStop(row.id) then
		record(res, "JeepStop present", stop ~= nil and stop:IsA("BasePart"))
		local jp = stop and stop:FindFirstChild("JeepPrompt")
		record(res, "JeepPrompt present", jp ~= nil and jp:IsA("ProximityPrompt") and jp:GetAttribute("PromptKind") == "Jeep")
	else
		record(res, "has no JeepStop", stop == nil)
	end

	-- Required display props: a direct child that holds at least one part.
	for _, name in ipairs(row.requiredProps or {}) do
		local child = model:FindFirstChild(name)
		record(res, "required prop " .. name, child ~= nil and hasPart(child), child == nil and "missing" or "holds no parts")
	end

	record(res, "part budget <= " .. SITE_PART_BUDGET, parts <= SITE_PART_BUDGET, parts .. " parts")
	record(res, "all non-rig parts anchored", loose == 0, "unanchored: " .. loose)
	return res
end

function BuildCheck.checkWorld(root, limit)
	local res = newResults()
	root = root or workspace
	limit = limit or WORLD_PART_BUDGET
	local characters = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character then
			table.insert(characters, plr.Character)
		end
	end
	local parts = 0
	for _, d in ipairs(root:GetDescendants()) do
		if d:IsA("BasePart") and not d:IsA("Terrain") then
			local isCharacter = false
			for _, c in ipairs(characters) do
				if d:IsDescendantOf(c) then
					isCharacter = true
					break
				end
			end
			if not isCharacter then
				parts += 1
			end
		end
	end
	res.parts = parts
	record(res, "world part budget <= " .. limit, parts <= limit, parts .. " parts")
	return res
end

BuildCheck.WORLD_PART_BUDGET = WORLD_PART_BUDGET

return BuildCheck
