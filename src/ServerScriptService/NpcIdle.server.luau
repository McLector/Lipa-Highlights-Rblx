-- NpcIdle: plays the default R15 idle animation on every Guide at runtime (animations don't run in Edit).
-- Failure is non-fatal: the guides simply stand still.
local IDLE_ANIMATION_ID = "rbxassetid://507766666" -- default R15 idle

local function animate(guide)
	local hum = guide:FindFirstChildOfClass("Humanoid")
	if not hum then
		return
	end
	local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
	local anim = Instance.new("Animation")
	anim.AnimationId = IDLE_ANIMATION_ID
	local ok, err = pcall(function()
		local track = animator:LoadAnimation(anim)
		track.Looped = true
		track:Play()
	end)
	if not ok then
		warn("[NpcIdle] could not play idle on " .. guide:GetFullName() .. ": " .. tostring(err))
	end
end

local function watch(sites)
	for _, d in ipairs(sites:GetDescendants()) do
		if d.Name == "Guide" and d:IsA("Model") then
			animate(d)
		end
	end
	sites.DescendantAdded:Connect(function(d)
		if d.Name == "Guide" and d:IsA("Model") then
			task.defer(animate, d)
		end
	end)
end

watch(workspace:WaitForChild("Sites"))
