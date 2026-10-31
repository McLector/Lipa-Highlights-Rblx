-- npcs_check: the spec for builders/npcs.luau (professor's feedback: NPCs that match their location), written BEFORE the build.
-- Studio copy: ServerStorage.Checks.npcs_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.npcs_check:Clone())      -- returns JSON {passed, failed, failures}
-- Every site gets a LocalNPCs folder whose figures fit the place (a cook at Lomi King, a pilgrim at Carmel, a golfer at
-- Malarayat, ...). Figures are posed R15 rigs with every part anchored; clothing and props are parts inside the rig.
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

-- Site key -> { role = { pose, props... } }. pose is "stand", "sit" or "kneel".
local SPEC = {
	Cathedral = { ParishionerVeil = { "stand", "Veil", "Rosary" }, Parishioner = { "stand" } },
	Market = { ShopperBayong1 = { "stand", "Bayong" }, ShopperBayong2 = { "stand", "Bayong" } },
	Lomi = { Cook = { "stand", "Apron", "Cap", "Ladle" }, Diner1 = { "sit" }, Diner2 = { "sit" } },
	Cafe = { Customer1 = { "sit", "Cup" }, Customer2 = { "sit", "Cup" } },
	Carmel = { PilgrimKneeling = { "kneel" }, PilgrimSeated = { "sit", "Rosary" } },
	Outlets = { Shopper1 = { "stand", "ShoppingBag" }, Shopper2 = { "stand", "ShoppingBag" }, FootballPlayer = { "stand", "Ball" } },
	Farm = { YogaGuest = { "sit", "YogaMat" }, FarmStaff = { "stand" } },
	Malarayat = { Golfer = { "stand", "GolfClub", "Visor" }, Caddie = { "stand", "GolfBag" } },
	Tagbakin = { Fisher = { "sit", "Rod", "Salakot" } },
	-- City Hall (Slice 3b): casual locals on the forecourt, outside the reserved zones (spawn pad, Ate Joy, jeep curb, panel, steps).
	CityHall = { ResidentWalking = { "stand" }, ResidentBayong = { "stand", "Bayong" }, Student = { "stand", "ShoppingBag" }, OfficeStaff = { "stand" } },
}

local sites = workspace:FindFirstChild("Sites")
check("Workspace.Sites exists", sites ~= nil)
if not sites then
	return HttpService:JSONEncode(results)
end

local exclude = {}
for _, d in ipairs(workspace:GetDescendants()) do
	if d:IsA("Model") and d:FindFirstChildOfClass("Humanoid") then table.insert(exclude, d) end
end
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
params.FilterDescendantsInstances = exclude

local total = 0
for _, row in ipairs(SiteData.sites) do
	local spec = SPEC[row.key]
	local site
	for _, m in ipairs(sites:GetChildren()) do
		if m:GetAttribute("SiteId") == row.id then site = m end
	end
	local folder = site and site:FindFirstChild("LocalNPCs")
	check(row.key .. ": LocalNPCs folder is a direct child of the site", folder ~= nil and folder:IsA("Folder"))
	if folder then
		local x0, x1 = row.pos.X - row.size.X / 2, row.pos.X + row.size.X / 2
		local z0, z1 = row.pos.Z - row.size.Y / 2, row.pos.Z + row.size.Y / 2
		local guide = SiteData.guidePos(row.id)
		local jeep = SiteData.jeepStopPos(row.id)
		local seen = {}
		for _, rig in ipairs(folder:GetChildren()) do
			local role = rig:GetAttribute("Role")
			local hum = rig:FindFirstChildOfClass("Humanoid")
			local hrp = rig:FindFirstChild("HumanoidRootPart")
			local label = row.key .. "/" .. rig.Name
			total += 1
			check(label .. " is a figure with a Humanoid and a root part, not named Guide",
				rig:IsA("Model") and hum ~= nil and hrp ~= nil and rig.Name ~= "Guide")
			check(label .. " has a Role from the spec and the right SiteId", role ~= nil and spec[role] ~= nil and rig:GetAttribute("SiteId") == row.id,
				tostring(role))
			if role and spec[role] and hum and hrp then
				seen[role] = true
				local want = spec[role]
				local unanchored = 0
				for _, p in ipairs(rig:GetDescendants()) do
					if p:IsA("BasePart") and not p.Anchored then unanchored += 1 end
				end
				check(label .. " every part is anchored (the pose holds in Play)", unanchored == 0, unanchored .. " unanchored")
				local pos = hrp.Position
				check(label .. " stands inside the site footprint", pos.X >= x0 and pos.X <= x1 and pos.Z >= z0 and pos.Z <= z1,
					fmt(pos.X) .. ", " .. fmt(pos.Z))
				local dg = (Vector3.new(pos.X, 0, pos.Z) - Vector3.new(guide.X, 0, guide.Z)).Magnitude
				check(label .. " keeps 12+ studs from the guide (the talk prompt stays clear)", dg >= 12, fmt(dg))
				if jeep then
					local dj = (Vector3.new(pos.X, 0, pos.Z) - Vector3.new(jeep.X, 0, jeep.Z)).Magnitude
					check(label .. " keeps 8+ studs from the jeepney stop", dj >= 8, fmt(dj))
				end
				-- Resting on something: the root part sits 0.8 to 3.5 studs above the first surface below it.
				local hit = workspace:Raycast(pos, Vector3.new(0, -20, 0), params)
				local gap = hit and (pos.Y - hit.Position.Y) or math.huge
				check(label .. " rests on a surface (root 0.8 to 3.5 studs above it)", gap >= 0.8 and gap <= 3.5, hit and fmt(gap) or "nothing below")
				local thigh, shin = rig:FindFirstChild("LeftUpperLeg"), rig:FindFirstChild("LeftLowerLeg")
				if want[1] == "sit" then
					check(label .. " is seated (thighs level)", thigh ~= nil and math.abs(thigh.CFrame.UpVector.Y) < 0.2,
						thigh and fmt(thigh.CFrame.UpVector.Y) or "no thigh")
				elseif want[1] == "kneel" then
					local back = (thigh and shin) and (shin.Position - thigh.Position) or nil
					check(label .. " kneels (thighs upright, shins level and behind the knees)",
						back ~= nil and thigh.CFrame.UpVector.Y > 0.9 and math.abs(shin.CFrame.UpVector.Y) < 0.2
							and back:Dot(hrp.CFrame.LookVector) < 0,
						thigh and shin and (fmt(thigh.CFrame.UpVector.Y) .. " / " .. fmt(shin.CFrame.UpVector.Y)) or "no legs")
				else
					check(label .. " is upright (thighs vertical)", thigh ~= nil and thigh.CFrame.UpVector.Y > 0.9,
						thigh and fmt(thigh.CFrame.UpVector.Y) or "no thigh")
				end
				for i = 2, #want do
					local p = rig:FindFirstChild(want[i], true)
					check(label .. " has its " .. want[i], p ~= nil and p:IsA("BasePart"))
				end
			end
		end
		for role in pairs(spec) do
			check(row.key .. ": a " .. role .. " is present", seen[role] == true)
		end
		-- Reserved zones (local frame of the row, only City Hall defines them): no figure stands in the spawn pad, Ate Joy's spot,
		-- the jeep curb, the billboard / tour map spot or on the steps.
		if row.key == "CityHall" then
			local ZONES = {
				{ "spawn pad", 30, 50, -10, 10 }, { "Ate Joy spot", 22, 32, -5, 5 }, { "jeep curb", 90, 100, 20, 40 },
				{ "panel spot", 28, 38, -30, -15 }, { "steps", 5, 25, -60, 60 },
			}
			for _, rig in ipairs(folder:GetChildren()) do
				local hrp = rig:FindFirstChild("HumanoidRootPart")
				if hrp then
					local lx, lz = hrp.Position.X - row.pos.X, hrp.Position.Z - row.pos.Z -- facing E: local x = world x, local z = world z
					local clash = {}
					for _, z in ipairs(ZONES) do
						if lx >= z[2] - 1.5 and lx <= z[3] + 1.5 and lz >= z[4] - 1.5 and lz <= z[5] + 1.5 then table.insert(clash, z[1]) end
					end
					check(row.key .. "/" .. rig.Name .. " is outside the reserved zones (1.5 studs clear)", #clash == 0,
						fmt(lx) .. ", " .. fmt(lz) .. " in " .. table.concat(clash, ", "))
				end
			end
			-- Fixes 062: the Student stood 1.3 studs into TerraceS2 (and in the TerraceS3Wall riser). It must stand on a terrace tread:
			-- the first surface under its root is a Terrace[SN]n tread, the lowest foot corner is within 0.05 of that tread top, and no
			-- rig part (shrunk by 0.05 a side) overlaps any non-figure part of the site.
			local student = folder:FindFirstChild("Student")
			local shrp = student and student:FindFirstChild("HumanoidRootPart")
			local detail, ok = "no Student", false
			if shrp then
				local hit = workspace:Raycast(shrp.Position, Vector3.new(0, -20, 0), params)
				local low = math.huge
				for _, n in ipairs({ "LeftFoot", "RightFoot" }) do
					local f = student:FindFirstChild(n)
					if f then
						for _, sx in ipairs({ -0.5, 0.5 }) do for _, sy in ipairs({ -0.5, 0.5 }) do for _, sz in ipairs({ -0.5, 0.5 }) do
							low = math.min(low, (f.CFrame * Vector3.new(sx * f.Size.X, sy * f.Size.Y, sz * f.Size.Z)).Y)
						end end end
					end
				end
				local sp = OverlapParams.new()
				sp.FilterType = Enum.RaycastFilterType.Include
				sp.FilterDescendantsInstances = { site }
				local clips = {}
				for _, p in ipairs(student:GetDescendants()) do
					if p:IsA("BasePart") and p.Size.X > 0.1 and p.Size.Y > 0.1 and p.Size.Z > 0.1 then
						for _, h in ipairs(workspace:GetPartBoundsInBox(p.CFrame, p.Size - Vector3.new(0.1, 0.1, 0.1), sp)) do
							local fig = h:FindFirstAncestorWhichIsA("Model")
							local isFigure = false
							while fig and fig ~= site do
								if fig:FindFirstChildOfClass("Humanoid") then isFigure = true break end
								fig = fig.Parent and fig.Parent:FindFirstAncestorWhichIsA("Model") or nil
							end
							if not isFigure then table.insert(clips, p.Name .. ">" .. h.Name) end
						end
					end
				end
				local onTread = hit ~= nil and string.match(hit.Instance.Name, "^Terrace[SN]%d+$") ~= nil
				local gap = hit and (low - hit.Position.Y) or math.huge
				ok = onTread and math.abs(gap) <= 0.05 and #clips == 0
				detail = (hit and hit.Instance.Name or "nothing") .. " gap " .. fmt(gap) .. "; " .. #clips .. " clips " .. table.concat(clips, ", ", 1, math.min(#clips, 4))
			end
			check(row.key .. "/Student stands on a terrace tread (feet within 0.05 of it, no part inside the terrace)", ok, detail)
		end
	end
end
check("23 location NPCs in all", total == 23, tostring(total)) -- 19 + 4 at City Hall (Slice 3b)

return HttpService:JSONEncode(results)
