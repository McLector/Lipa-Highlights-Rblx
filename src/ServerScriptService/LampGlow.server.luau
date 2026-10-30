-- LampGlow: at golden hour (Lighting ClockTime 17.5, builders/mood.luau) the street and plaza lamps look switched off. At runtime this
-- adds one soft, warm PointLight to each lamp head part in Workspace, and to lamp heads that appear later (sites get rebuilt).
-- Matched by exact name (a trailing number allowed): LampGlobe (Cathedral, Credits Plaza), LampHead (Market, Tagbakin), PoleLamp (Market),
-- CornerLampGlobe (Lomi King), StreetLampHead and CarParkLamp (Outlets), LightHead (City Hall). Poles, bases, caps and the
-- architectural cupolas are not lamp heads; a head that already holds a Light (the Cafe pendants) is left alone.
-- Nothing is built in Edit: the lights exist only while the game runs, so the site models and their checks are unchanged.
local BRIGHTNESS = 1.2
local RANGE = 14
local COLOR = Color3.fromRGB(255, 196, 128)
local MAX_LIGHTS = 300

local HEADS = {
	["LampGlobe"] = true,
	["LampHead"] = true,
	["PoleLamp"] = true,
	["CornerLampGlobe"] = true,
	["StreetLampHead"] = true,
	["CarParkLamp"] = true,
	["LightHead"] = true,
}

local count = 0

local function isHead(inst)
	if not inst:IsA("BasePart") then
		return false
	end
	local base = string.gsub(inst.Name, "%d+$", "")
	return HEADS[base] == true
end

local function addGlow(part)
	if count >= MAX_LIGHTS or not isHead(part) or part:FindFirstChildWhichIsA("Light") then
		return
	end
	local light = Instance.new("PointLight")
	light.Name = "LampGlow"
	light.Brightness = BRIGHTNESS
	light.Range = RANGE
	light.Color = COLOR
	light.Shadows = false
	light.Parent = part
	count += 1
end

-- A light removed with its part frees its slot, so rebuilt sites get theirs back.
local function watch(light)
	local conn
	conn = light.AncestryChanged:Connect(function()
		if not light:IsDescendantOf(workspace) then
			count -= 1
			conn:Disconnect()
		end
	end)
end

workspace.DescendantAdded:Connect(function(inst)
	if inst:IsA("PointLight") and inst.Name == "LampGlow" then
		watch(inst)
	elseif isHead(inst) then
		task.defer(addGlow, inst) -- the builder may still be setting the part up
	end
end)

for i, d in ipairs(workspace:GetDescendants()) do
	addGlow(d)
	if i % 2000 == 0 then
		task.wait()
	end
end
