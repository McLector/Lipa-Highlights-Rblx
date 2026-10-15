-- placeholders: builds Workspace.Sites with one placeholder SiteNN_Key model per SiteData entry (idempotent:
-- destroys and rebuilds Workspace.Sites). Studio copy lives at ServerStorage.Builders.placeholders (ModuleScript);
-- run with: require(game.ServerStorage.Builders.placeholders:Clone())()
-- Slice 02+ replaces each placeholder's Block with the real site; Guide/InfoPanel/JeepStop contracts stay the same.
-- Y is seated by a terrain raycast (never by groundY alone) because Malarayat is on a slope.
local Players = game:GetService("Players")

local CATEGORY_COLORS = {
	Eat = Color3.fromRGB(232, 150, 70),
	Pray = Color3.fromRGB(90, 150, 230),
	Love = Color3.fromRGB(100, 190, 110),
}
local SKIN = Color3.fromRGB(224, 172, 130)
local DARK = Color3.fromRGB(50, 50, 60)

return function()
	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())

	local terrainParams = RaycastParams.new()
	terrainParams.FilterType = Enum.RaycastFilterType.Include
	terrainParams.FilterDescendantsInstances = { workspace.Terrain }
	local function groundAt(x, z)
		local r = workspace:Raycast(Vector3.new(x, 400, z), Vector3.new(0, -800, 0), terrainParams)
		assert(r, string.format("no terrain at (%.1f, %.1f)", x, z))
		return r.Position.Y
	end

	local function part(parent, name, size, cf, color, material)
		local p = Instance.new("Part")
		p.Name = name
		p.Size = size
		p.CFrame = cf
		p.Anchored = true
		p.Color = color
		p.Material = material or Enum.Material.SmoothPlastic
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.Parent = parent
		return p
	end

	local function label(part, face, text, textColor, bgTransparency)
		local gui = Instance.new("SurfaceGui")
		gui.Face = face
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 40
		gui.Parent = part
		local t = Instance.new("TextLabel")
		t.Size = UDim2.fromScale(1, 1)
		t.BackgroundTransparency = bgTransparency or 1
		t.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
		t.TextColor3 = textColor or Color3.new(1, 1, 1)
		t.TextScaled = true
		t.TextWrapped = true
		t.Font = Enum.Font.GothamMedium
		t.Text = text
		t.Parent = gui
		return t
	end

	local function prompt(parent, name, kind, actionText, objectText)
		local p = Instance.new("ProximityPrompt")
		p.Name = name
		p.ActionText = actionText
		p.ObjectText = objectText
		p.RequiresLineOfSight = false
		p.HoldDuration = 0
		p.MaxActivationDistance = 12
		p:SetAttribute("PromptKind", kind)
		p.Parent = parent
		return p
	end

	local function makeGuide(s, cf)
		local desc = Instance.new("HumanoidDescription")
		local color = CATEGORY_COLORS[s.category]
		desc.HeadColor, desc.TorsoColor, desc.LeftArmColor, desc.RightArmColor = SKIN, color, color, color
		desc.LeftLegColor, desc.RightLegColor = DARK, DARK
		local guide = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
		desc:Destroy()
		guide.Name = "Guide"
		for _, d in ipairs(guide:GetDescendants()) do
			if d:IsA("BasePart") then d.Anchored = false end
		end
		local hrp = guide:WaitForChild("HumanoidRootPart")
		local hum = guide:FindFirstChildOfClass("Humanoid")
		hum.DisplayName = s.guideName
		hum.WalkSpeed = 0
		guide.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
		guide:SetAttribute("SiteId", s.id)
		guide:PivotTo(cf)
		hrp.Anchored = true
		prompt(hrp, "GuidePrompt", "Guide", "Talk", s.guideName)
		return guide
	end

	local function makeJeepney(parent, cf)
		local m = Instance.new("Model")
		m.Name = "Jeepney"
		part(m, "Body", Vector3.new(8, 5, 16), cf * CFrame.new(0, 3.5, 0), Color3.fromRGB(200, 60, 60))
		part(m, "Roof", Vector3.new(8.4, 0.6, 16.4), cf * CFrame.new(0, 6.3, 0), Color3.fromRGB(240, 220, 90))
		for _, off in ipairs({ Vector3.new(-4, 1, -5), Vector3.new(4, 1, -5), Vector3.new(-4, 1, 5), Vector3.new(4, 1, 5) }) do
			local w = part(m, "Wheel", Vector3.new(2, 2, 2), cf * CFrame.new(off) * CFrame.Angles(0, 0, math.rad(90)), DARK)
			w.Shape = Enum.PartType.Cylinder
		end
		m.Parent = parent
		return m
	end

	local old = workspace:FindFirstChild("Sites")
	if old then old:Destroy() end
	local sites = Instance.new("Folder")
	sites.Name = "Sites"
	sites.Parent = workspace

	for _, s in ipairs(SiteData.sites) do
		local f = SiteData.facingVector(s.facing)
		local right = Vector3.new(-f.Z, 0, f.X)
		local yaw = SiteData.facingToYaw(s.facing)
		local rot = CFrame.Angles(0, yaw, 0)
		local color = CATEGORY_COLORS[s.category]

		local model = Instance.new("Model")
		model.Name = string.format("Site%02d_%s", s.id, s.key)
		model:SetAttribute("SiteId", s.id)
		model.WorldPivot = CFrame.new(s.pos) * rot

		-- Block (placeholder for the real structure).
		local g = groundAt(s.pos.X, s.pos.Z)
		local block = part(model, "Block", Vector3.new(40, 20, 40), CFrame.new(s.pos.X, g + 8, s.pos.Z) * rot, color)
		local bb = Instance.new("BillboardGui")
		bb.Size = UDim2.fromOffset(260, 50)
		bb.StudsOffset = Vector3.new(0, 16, 0)
		bb.AlwaysOnTop = true
		bb.Parent = block
		local bt = Instance.new("TextLabel")
		bt.Size = UDim2.fromScale(1, 1)
		bt.BackgroundTransparency = 0.3
		bt.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
		bt.TextColor3 = Color3.new(1, 1, 1)
		bt.TextScaled = true
		bt.Font = Enum.Font.GothamBold
		bt.Text = string.format("%d. %s (placeholder)", s.id, s.name)
		bt.Parent = bb

		-- Guide, 30 studs in front of the centre.
		local gp = SiteData.guidePos(s.id)
		local gg = groundAt(gp.X, gp.Z)
		local guide = makeGuide(s, CFrame.new(gp.X, gg + 3, gp.Z) * rot)
		guide.Parent = model

		-- InfoPanel, left of the guide.
		local pp = s.pos + f * 24 - right * 12
		local pg = groundAt(pp.X, pp.Z)
		local panel = part(model, "InfoPanel", Vector3.new(12, 8, 0.5), CFrame.new(pp.X, pg + 5, pp.Z) * rot, Color3.fromRGB(30, 30, 40))
		label(panel, Enum.NormalId.Front, s.name .. "\n" .. s.panelText, Color3.new(1, 1, 1), 0)

		-- JeepStop + parked jeepney (plaza and the five outer sites).
		if SiteData.hasJeepStop(s.id) then
			local sp = SiteData.jeepStopPos(s.id)
			local sg = groundAt(sp.X, sp.Z)
			local stop = part(model, "JeepStop", Vector3.new(10, 0.4, 10), CFrame.new(sp.X, sg + 0.2, sp.Z) * rot, Color3.fromRGB(240, 200, 60), Enum.Material.Neon)
			stop.CanCollide = false
			prompt(stop, "JeepPrompt", "Jeep", "Ride jeepney", "Jeepney stop")
			local pole = part(model, "JeepSignPole", Vector3.new(0.6, 9, 0.6), CFrame.new(sp.X, sg + 4.5, sp.Z) * rot, DARK)
			local sign = part(model, "JeepSign", Vector3.new(7, 2, 0.4), CFrame.new(sp.X, sg + 9.5, sp.Z) * rot, Color3.fromRGB(30, 30, 40))
			label(sign, Enum.NormalId.Front, "JEEPNEY STOP", Color3.fromRGB(240, 200, 60), 0)
			label(sign, Enum.NormalId.Back, "JEEPNEY STOP", Color3.fromRGB(240, 200, 60), 0)
			pole.CanCollide = false
			local jp = sp + right * 14
			local jg = groundAt(jp.X, jp.Z)
			-- Body is built relative to the ground; its long axis runs along the facing direction.
			makeJeepney(model, CFrame.new(jp.X, jg, jp.Z) * rot * CFrame.Angles(0, math.rad(90), 0))
		end

		model.Parent = sites
		task.wait()
	end
	return #sites:GetChildren()
end
