-- sites_check: verifies Workspace.Sites against SiteData. Run in Edit via execute_luau; returns JSON {passed, failed, failures}.
-- Early skeleton of BuildCheck (full version in Slice 02).
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

local terrainParams = RaycastParams.new()
terrainParams.FilterType = Enum.RaycastFilterType.Include
terrainParams.FilterDescendantsInstances = { workspace.Terrain }
local function ground(x, z)
	local r = workspace:Raycast(Vector3.new(x, 400, z), Vector3.new(0, -800, 0), terrainParams)
	if r then return r.Position.Y, r.Material end
	return nil, nil
end
local function xzDist(a, b)
	return Vector3.new(a.X - b.X, 0, a.Z - b.Z).Magnitude
end

-- Sites whose real builder has run (the rest are still placeholder Blocks).
local BUILT = { [1] = true, [5] = true }

local sites = workspace:FindFirstChild("Sites")
check("Workspace.Sites exists", sites ~= nil)
if sites then
	check("Sites holds exactly 9 children", #sites:GetChildren() == 9, tostring(#sites:GetChildren()))
	for _, s in ipairs(SiteData.sites) do
		local label = string.format("Site%02d_%s", s.id, s.key)
		local m = sites:FindFirstChild(label)
		check(label .. " exists", m ~= nil)
		if m then
			check(label .. " SiteId attribute", m:GetAttribute("SiteId") == s.id)
			local pivot = m:GetPivot()
			check(label .. " pivot within 1 stud of pos", (pivot.Position - s.pos).Magnitude <= 1, tostring(pivot.Position))
			check(label .. " facing dot > 0.99", pivot.LookVector:Dot(SiteData.facingVector(s.facing)) > 0.99, tostring(pivot.LookVector))
			if BUILT[s.id] then
				-- Built sites (1: Slice 02, 5: Slice 04): the builder replaced the placeholder Block with Structure.
				check(label .. " Structure present and Block absent", m:FindFirstChild("Structure") ~= nil and m:FindFirstChild("Block") == nil)
				if s.id == 5 then
					-- Orientation guard (Slice 04): the pivot is yawed 180 degrees, so a build that used the pivot as its origin is
					-- mirrored yet still passes the symmetric bounds check. The facade must be south (+Z) of the nave, and the east
					-- wing must be east (+X) of it.
					local st = m:FindFirstChild("Structure")
					local podium = st and st:FindFirstChild("Podium", true)
					local nave = st and st:FindFirstChild("NaveBlock", true)
					local wing = st and st:FindFirstChild("EastWingBlock", true)
					check(label .. " facade is south of the nave", podium ~= nil and nave ~= nil and podium.Position.Z > nave.Position.Z + 20,
						podium and nave and (podium.Position.Z .. " vs " .. nave.Position.Z) or "parts missing")
					check(label .. " east wing is east of the nave", wing ~= nil and nave ~= nil and wing.Position.X > nave.Position.X + 15,
						wing and nave and (wing.Position.X .. " vs " .. nave.Position.X) or "parts missing")
				end
			else
				check(label .. " Block present", m:FindFirstChild("Block") ~= nil and m.Block:IsA("BasePart"))
			end

			-- Guide
			local guide = m:FindFirstChild("Guide")
			check(label .. " Guide present", guide ~= nil and guide:IsA("Model"))
			local gHrp
			if guide then
				gHrp = guide:FindFirstChild("HumanoidRootPart")
				check(label .. " Guide has Humanoid + HRP", guide:FindFirstChildOfClass("Humanoid") ~= nil and gHrp ~= nil)
				check(label .. " Guide Atomic streaming", guide.ModelStreamingMode == Enum.ModelStreamingMode.Atomic)
				local anchoredOthers = 0
				for _, d in ipairs(guide:GetDescendants()) do
					if d:IsA("BasePart") and d ~= gHrp and d.Anchored then anchoredOthers += 1 end
				end
				check(label .. " only the Guide HRP is anchored", gHrp ~= nil and gHrp.Anchored and anchoredOthers == 0, "others anchored: " .. anchoredOthers)
				if gHrp then
					local target = SiteData.guidePos(s.id)
					check(label .. " Guide XZ at guidePos", xzDist(gHrp.Position, target) <= 1, tostring(gHrp.Position))
					local gy = ground(gHrp.Position.X, gHrp.Position.Z)
					check(label .. " Guide stands on terrain", gy ~= nil and gHrp.Position.Y - gy >= 2 and gHrp.Position.Y - gy <= 5,
						"hrpY=" .. gHrp.Position.Y .. " groundY=" .. tostring(gy))
					local prompt = gHrp:FindFirstChild("GuidePrompt")
					check(label .. " GuidePrompt", prompt ~= nil and prompt:IsA("ProximityPrompt")
						and prompt.RequiresLineOfSight == false and prompt.HoldDuration == 0
						and prompt:GetAttribute("PromptKind") == "Guide")
				end
			end

			-- InfoPanel
			local panel = m:FindFirstChild("InfoPanel")
			local gui = panel and panel:FindFirstChildOfClass("SurfaceGui")
			local label1 = gui and gui:FindFirstChildWhichIsA("TextLabel", true)
			check(label .. " InfoPanel with SurfaceGui text", panel ~= nil and label1 ~= nil and #label1.Text > 0)

			-- JeepStop only where SiteData says so
			local stop = m:FindFirstChild("JeepStop")
			if SiteData.hasJeepStop(s.id) then
				check(label .. " JeepStop present", stop ~= nil and stop:IsA("BasePart"))
				check(label .. " Jeepney prop present", m:FindFirstChild("Jeepney") ~= nil)
				if stop then
					check(label .. " JeepStop XZ at jeepStopPos", xzDist(stop.Position, SiteData.jeepStopPos(s.id)) <= 1, tostring(stop.Position))
					local _, mat = ground(stop.Position.X, stop.Position.Z)
					check(label .. " JeepStop on dry land", mat ~= nil and mat ~= Enum.Material.Water, tostring(mat))
					if gHrp then
						local d = xzDist(stop.Position, gHrp.Position)
						check(label .. " JeepStop 15-25 studs from Guide", d >= 15 and d <= 25, tostring(d))
					end
					local jp = stop:FindFirstChild("JeepPrompt")
					check(label .. " JeepPrompt", jp ~= nil and jp:IsA("ProximityPrompt") and jp:GetAttribute("PromptKind") == "Jeep")
				end
			else
				check(label .. " has no JeepStop", stop == nil)
			end
			if gHrp then
				local _, mat = ground(gHrp.Position.X, gHrp.Position.Z)
				check(label .. " Guide on dry land", mat ~= nil and mat ~= Enum.Material.Water, tostring(mat))
			end

			-- Everything that is not part of a rig (any Model with a Humanoid: the Guide, plaza people) is anchored.
			local function insideRig(part)
				local p = part.Parent
				while p and p ~= m do
					if p:IsA("Model") and p:FindFirstChildOfClass("Humanoid") then return true end
					p = p.Parent
				end
				return false
			end
			local loose = 0
			for _, d in ipairs(m:GetDescendants()) do
				if d:IsA("BasePart") and not insideRig(d) and not d.Anchored then loose += 1 end
			end
			check(label .. " all non-rig parts anchored", loose == 0, "unanchored: " .. loose)
		end
	end
end

return HttpService:JSONEncode(results)
