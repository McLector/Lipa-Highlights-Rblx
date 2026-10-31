-- guides_check: the spec for builders/guides.luau (a tour-guide uniform only the ten site guides wear), written BEFORE the build.
-- Studio copy: ServerStorage.Checks.guides_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.guides_check:Clone())      -- returns JSON {passed, failed, failures}
-- Each Guide wears the teal LIPA TOUR polo (a Shirt, short sleeves over skin-coloured arms), a cap and a tour flag in its
-- category colour, a lanyard ID, and a floating GUIDE sign. No other figure wears any of it, and the talk prompt is unchanged.
local HttpService = game:GetService("HttpService")
local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())

local POLO = "rbxassetid://71550766060779" -- tools/guide_shirt.py, uploaded 2026-10-22
local SKIN = Color3.fromRGB(224, 172, 130)
local OUTFIT = { "Cap", "CapBrim", "LanyardL", "LanyardR", "LanyardCard", "FlagPole", "Flag" }

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
local function same(a, b) return math.abs(a.R - b.R) + math.abs(a.G - b.G) + math.abs(a.B - b.B) < 0.02 end

local sites = workspace:FindFirstChild("Sites")
check("Workspace.Sites exists", sites ~= nil)
if not sites then
	return HttpService:JSONEncode(results)
end

-- Fixes 062: the Guides stood 0.19..0.49 in the floor (City Hall's floated 0.11). The probe below is the same rule builders/guides.luau
-- seats with: cast 30 studs down from the root part, every Humanoid figure excluded; the lowest foot corner must be within 0.05 of the hit.
local figures = {}
for _, d in ipairs(workspace:GetDescendants()) do
	if d:IsA("Model") and d:FindFirstChildOfClass("Humanoid") then table.insert(figures, d) end
end
local seatParams = RaycastParams.new()
seatParams.FilterType = Enum.RaycastFilterType.Exclude
seatParams.FilterDescendantsInstances = figures
local function footBottom(guide)
	local m = math.huge
	for _, name in ipairs({ "LeftFoot", "RightFoot" }) do
		local f = guide:FindFirstChild(name)
		if f then
			for _, sx in ipairs({ -0.5, 0.5 }) do
				for _, sy in ipairs({ -0.5, 0.5 }) do
					for _, sz in ipairs({ -0.5, 0.5 }) do
						m = math.min(m, (f.CFrame * Vector3.new(sx * f.Size.X, sy * f.Size.Y, sz * f.Size.Z)).Y)
					end
				end
			end
		end
	end
	return m
end

local dressed = 0
for _, row in ipairs(SiteData.sites) do
	local site
	for _, m in ipairs(sites:GetChildren()) do
		if m:GetAttribute("SiteId") == row.id then site = m end
	end
	local guide = site and site:FindFirstChild("Guide")
	local label = row.key .. " Guide"
	check(label .. " exists", guide ~= nil and guide:FindFirstChildOfClass("Humanoid") ~= nil)
	if guide and guide:FindFirstChildOfClass("Humanoid") then
		local shirt = guide:FindFirstChildOfClass("Shirt")
		check(label .. " wears the LIPA TOUR polo", shirt ~= nil and shirt.ShirtTemplate == POLO, shirt and shirt.ShirtTemplate or "no Shirt")
		check(label .. " has skin-coloured arms under the short sleeves",
			guide:FindFirstChild("LeftLowerArm") ~= nil and same(guide.LeftLowerArm.Color, SKIN) and same(guide.RightLowerArm.Color, SKIN))
		local outfit = guide:FindFirstChild("GuideOutfit")
		check(label .. " has a GuideOutfit model", outfit ~= nil and outfit:IsA("Model"))
		if outfit then
			local missing = {}
			for _, name in ipairs(OUTFIT) do
				if not outfit:FindFirstChild(name) then table.insert(missing, name) end
			end
			check(label .. " outfit has cap, brim, lanyard, ID card, flag pole and flag", #missing == 0, table.concat(missing, ", "))
			-- The category colour table lives in SiteData (Eat / Pray / Love / Welcome); nil for an unknown category fails the check.
			local cat = SiteData.categoryColor(row.category)
			local cap, flag = outfit:FindFirstChild("Cap"), outfit:FindFirstChild("Flag")
			check(label .. " cap and flag are the " .. row.category .. " colour", cat ~= nil and cap ~= nil and flag ~= nil and same(cap.Color, cat) and same(flag.Color, cat))
			local loose = {}
			for _, p in ipairs(outfit:GetDescendants()) do
				if p:IsA("BasePart") then
					local welded = false
					for _, w in ipairs(p:GetChildren()) do
						if w:IsA("WeldConstraint") and w.Part0 and w.Part1 and w.Part0:IsDescendantOf(guide) and w.Part1:IsDescendantOf(guide) then welded = true end
					end
					if p.CanCollide or not welded then table.insert(loose, p.Name) end
				end
			end
			check(label .. " outfit parts are welded to the body and never collide", #loose == 0, table.concat(loose, ", "))
			-- The idle animation sways the arms in Play; a flag welded to the hand swung across the guide's face.
			local rootWelded = 0
			for _, name in ipairs({ "FlagPole", "Flag" }) do
				local p = outfit:FindFirstChild(name)
				local w = p and p:FindFirstChildOfClass("WeldConstraint")
				if w and (w.Part0 == guide:FindFirstChild("HumanoidRootPart") or w.Part1 == guide:FindFirstChild("HumanoidRootPart")) then rootWelded += 1 end
			end
			check(label .. " flag and pole are fixed to the anchored root, not the swaying arm", rootWelded == 2, rootWelded .. " of 2")
			local card, torso = outfit:FindFirstChild("LanyardCard"), guide:FindFirstChild("UpperTorso")
			check(label .. " ID card hangs below the placket (lower half of the chest)", card ~= nil and torso ~= nil and card.Position.Y < torso.Position.Y,
				card and torso and fmt(card.Position.Y - torso.Position.Y) or "missing")
			local sign = outfit:FindFirstChild("GuideSign")
			local text = sign and sign:FindFirstChildWhichIsA("TextLabel", true)
			check(label .. " has a GUIDE sign over the head (BillboardGui, 60-100 studs, not through walls)",
				sign ~= nil and sign:IsA("BillboardGui") and sign.Adornee == guide:FindFirstChild("Head") and text ~= nil and text.Text == "GUIDE"
					and sign.MaxDistance >= 60 and sign.MaxDistance <= 100 and not sign.AlwaysOnTop)
			if sign and flag and guide:FindFirstChild("Head") then
				local signBottom = guide.Head.Position.Y + sign.StudsOffsetWorldSpace.Y - sign.Size.Y.Scale / 2
				local flagTop = flag.Position.Y + flag.Size.Y / 2
				check(label .. " flag stays below the GUIDE sign", flagTop < signBottom, fmt(flagTop) .. " vs " .. fmt(signBottom))
			end
			dressed += 1
		end
		local hrp = guide:FindFirstChild("HumanoidRootPart")
		local hit = hrp and workspace:Raycast(hrp.Position, Vector3.new(0, -30, 0), seatParams)
		local gap = hit and (footBottom(guide) - hit.Position.Y) or math.huge
		check(label .. " stands on the surface below (lowest foot within 0.05 of it)", math.abs(gap) <= 0.05,
			hit and (hit.Instance.Name .. " gap " .. fmt(gap)) or "nothing below")
		local prompt = guide:FindFirstChild("GuidePrompt", true)
		check(label .. " talk prompt is unchanged (Guide kind, 12 studs)", prompt ~= nil and prompt:IsA("ProximityPrompt")
			and prompt:GetAttribute("PromptKind") == "Guide" and prompt.MaxActivationDistance == 12)
	end
end
check("all 10 guides are dressed", dressed == 10, tostring(dressed))

-- Only the guides wear it.
local others = {}
for _, d in ipairs(workspace:GetDescendants()) do
	if d:IsA("Model") and d.Name ~= "Guide" and d:FindFirstChildOfClass("Humanoid") then
		local s = d:FindFirstChildOfClass("Shirt")
		if d:FindFirstChild("GuideOutfit") or (s and s.ShirtTemplate == POLO) then table.insert(others, d:GetFullName()) end
	end
end
check("no other figure wears the guide uniform", #others == 0, table.concat(others, ", "))

return HttpService:JSONEncode(results)
