-- NpcIdle: plays the default R15 idle animation on every rig under Workspace.Sites (the Guides and the plaza
-- people) at runtime, since animations don't run in Edit. Watches for Humanoids rather than for models named
-- "Guide", and marks each rig with an IdleStarted attribute so no rig ever gets a second track.
-- Failure is non-fatal: the rigs simply stand still.
local IDLE_ANIMATION_ID = "rbxassetid://507766666" -- default R15 idle

local function animate(hum)
	local rig = hum.Parent
	if not rig or rig:GetAttribute("IdleStarted") then
		return
	end
	rig:SetAttribute("IdleStarted", true)
	local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
	local anim = Instance.new("Animation")
	anim.AnimationId = IDLE_ANIMATION_ID
	local ok, err = pcall(function()
		local track = animator:LoadAnimation(anim)
		track.Looped = true
		track:Play()
	end)
	if not ok then
		warn("[NpcIdle] could not play idle on " .. rig:GetFullName() .. ": " .. tostring(err))
	end
end

local function watch(sites)
	for _, d in ipairs(sites:GetDescendants()) do
		if d:IsA("Humanoid") then
			animate(d)
		end
	end
	sites.DescendantAdded:Connect(function(d)
		if d:IsA("Humanoid") then
			task.defer(animate, d)
		end
	end)
end

watch(workspace:WaitForChild("Sites"))
