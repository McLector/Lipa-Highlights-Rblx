-- placeholders: builds Workspace.Sites with one placeholder SiteNN_Key model per SiteData entry (idempotent:
-- destroys and rebuilds Workspace.Sites). Studio copy lives at ServerStorage.Builders.placeholders (ModuleScript);
-- run with: require(game.ServerStorage.Builders.placeholders:Clone())()
-- Slice 02+ replaces each placeholder's Block with the real site; Guide/InfoPanel/JeepStop contracts stay the same.
-- REBUILD ORDER: this builder wipes ALL of Workspace.Sites, including any real site already built. After running
-- it, re-run every real site builder (currently only builders/site01.luau): placeholders -> site01 -> ...
-- Y is seated by a terrain raycast (never by groundY alone) because Malarayat is on a slope.
-- ONLY MODE (Slice 3b): placeholders({ only = { 10 } }) does NOT touch Workspace.Sites as a whole. For each listed site id it finds
-- the existing model Workspace.Sites["SiteNN_Key"], sets its SiteId attribute if missing, removes ONLY the previously generated
-- Guide, InfoPanel, JeepStop, JeepSignPole, JeepSign and Jeepney children, and rebuilds them with the same helpers (placement
-- honours SiteData.guidePos / jeepStopPos / panelLocal). It builds no Block for a site that already has a Block, Structure or Wing.
-- The ground is the terrain, plus the site's own Forecourt paving when it has one (so props sit on it, not in it).
-- Terrain cannot be raycast until a task.wait() after it is written; the only-mode waits once first. The default mode (no
-- argument) is unchanged: it destroys and rebuilds all of Workspace.Sites. Spec: tests/placeholders_check.luau.
-- The Guide is rebuilt undressed: re-run builders/guides.luau afterwards (idempotent) to put the tour uniform back on.
local Players = game:GetService("Players")

local SKIN = Color3.fromRGB(224, 172, 130)
local DARK = Color3.fromRGB(50, 50, 60)
local FALLBACK = Color3.fromRGB(200, 200, 200)
local ONLY_REMOVE = { "Guide", "InfoPanel", "JeepStop", "JeepSignPole", "JeepSign", "Jeepney" }

return function(opts)
	opts = opts or {}
	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
	-- One colour table lives in SiteData (nil-safe here: a missing or unknown category falls back to grey).
	local function colorFor(category)
		return SiteData.categoryColor(category) or FALLBACK
	end

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
		local color = colorFor(s.category)
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

	-- Guide, InfoPanel and (where SiteData says so) JeepStop + sign + parked jeepney, into `model`.
	-- ground(x, z) -> surface Y. The default mode passes the terrain raycast; the only-mode adds the Forecourt paving.
	local function buildProps(s, model, ground)
		local f = SiteData.facingVector(s.facing)
		local right = Vector3.new(-f.Z, 0, f.X)
		local rot = CFrame.Angles(0, SiteData.facingToYaw(s.facing), 0)

		-- Guide, at SiteData.guidePos (30 studs in front of the centre unless the row has guideLocal).
		local gp = SiteData.guidePos(s.id)
		local gg = ground(gp.X, gp.Z)
		local guide = makeGuide(s, CFrame.new(gp.X, gg + 3, gp.Z) * rot)
		guide.Parent = model

		-- InfoPanel, left of the guide (default) or at the row's panelLocal.
		local pp
		if s.panelLocal then
			pp = SiteData.localToWorld(s.id, s.panelLocal.X, s.panelLocal.Y)
		else
			pp = s.pos + f * 24 - right * 12
		end
		local pg = ground(pp.X, pp.Z)
		local panel = part(model, "InfoPanel", Vector3.new(12, 8, 0.5), CFrame.new(pp.X, pg + 5, pp.Z) * rot, Color3.fromRGB(30, 30, 40))
		label(panel, Enum.NormalId.Front, s.name .. "\n" .. s.panelText, Color3.new(1, 1, 1), 0)

		-- JeepStop + parked jeepney (plaza, the five outer sites and City Hall).
		if SiteData.hasJeepStop(s.id) then
			local sp = SiteData.jeepStopPos(s.id)
			local sg = ground(sp.X, sp.Z)
			local stop = part(model, "JeepStop", Vector3.new(10, 0.4, 10), CFrame.new(sp.X, sg + 0.2, sp.Z) * rot, Color3.fromRGB(240, 200, 60), Enum.Material.Neon)
			stop.CanCollide = false
			prompt(stop, "JeepPrompt", "Jeep", "Ride jeepney", "Jeepney stop")
			local pole = part(model, "JeepSignPole", Vector3.new(0.6, 9, 0.6), CFrame.new(sp.X, sg + 4.5, sp.Z) * rot, DARK)
			local sign = part(model, "JeepSign", Vector3.new(7, 2, 0.4), CFrame.new(sp.X, sg + 9.5, sp.Z) * rot, Color3.fromRGB(30, 30, 40))
			label(sign, Enum.NormalId.Front, "JEEPNEY STOP", Color3.fromRGB(240, 200, 60), 0)
			label(sign, Enum.NormalId.Back, "JEEPNEY STOP", Color3.fromRGB(240, 200, 60), 0)
			pole.CanCollide = false
			local jp = sp + right * 14
			local jg = ground(jp.X, jp.Z)
			-- Body is built relative to the ground; its long axis runs along the facing direction.
			makeJeepney(model, CFrame.new(jp.X, jg, jp.Z) * rot * CFrame.Angles(0, math.rad(90), 0))
		end
	end

	-- ONLY MODE: rebuild the generated props of the listed sites inside their existing models; nothing else is touched.
	if opts.only ~= nil then
		assert(type(opts.only) == "table", "placeholders: opts.only must be an array of site ids")
		local existing = workspace:FindFirstChild("Sites")
		assert(existing, "placeholders: Workspace.Sites not found (only-mode never creates it)")
		task.wait() -- terrain cannot be raycast until a task.wait() after it was written
		local done = {}
		for _, id in ipairs(opts.only) do
			local s = SiteData.byId(id)
			assert(s, "placeholders: no SiteData row " .. tostring(id))
			local model = existing:FindFirstChild(string.format("Site%02d_%s", s.id, s.key))
			assert(model, string.format("placeholders: Site%02d_%s not found", s.id, s.key))
			if model:GetAttribute("SiteId") == nil then model:SetAttribute("SiteId", s.id) end
			for _, name in ipairs(ONLY_REMOVE) do
				while true do
					local old = model:FindFirstChild(name)
					if not old then break end
					old:Destroy()
				end
			end
			local surfaceParams = RaycastParams.new()
			surfaceParams.FilterType = Enum.RaycastFilterType.Include
			local include = { workspace.Terrain }
			local paving = model:FindFirstChild("Forecourt")
			if paving then table.insert(include, paving) end
			surfaceParams.FilterDescendantsInstances = include
			local function ground(x, z)
				local r = workspace:Raycast(Vector3.new(x, 400, z), Vector3.new(0, -800, 0), surfaceParams)
				assert(r, string.format("no ground at (%.1f, %.1f)", x, z))
				return r.Position.Y
			end
			-- A Block only for a site with no real structure (and no placeholder Block yet).
			if not (model:FindFirstChild("Block") or model:FindFirstChild("Structure") or model:FindFirstChild("Wing")) then
				local rot = CFrame.Angles(0, SiteData.facingToYaw(s.facing), 0)
				local g = groundAt(s.pos.X, s.pos.Z)
				part(model, "Block", Vector3.new(40, 20, 40), CFrame.new(s.pos.X, g + 8, s.pos.Z) * rot, colorFor(s.category))
			end
			buildProps(s, model, ground)
			table.insert(done, id)
			task.wait()
		end
		return #done
	end

	local old = workspace:FindFirstChild("Sites")
	if old then old:Destroy() end
	local sites = Instance.new("Folder")
	sites.Name = "Sites"
	sites.Parent = workspace

	for _, s in ipairs(SiteData.sites) do
		local rot = CFrame.Angles(0, SiteData.facingToYaw(s.facing), 0)
		local color = colorFor(s.category)

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

		buildProps(s, model, groundAt)

		model.Parent = sites
		task.wait()
	end
	return #sites:GetChildren()
end
