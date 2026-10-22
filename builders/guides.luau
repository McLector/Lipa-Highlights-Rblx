-- guides: a tour-guide uniform that only the nine site guides wear, so players can pick them out. Studio copy:
-- ServerStorage.Builders.guides; run with
--   require(game.ServerStorage.Builders.guides:Clone())()
-- Run AFTER builders/placeholders.luau (which makes each Guide). IDEMPOTENT: replaces only each Guide's GuideOutfit model and
-- GuidePolo shirt; the Guide's position, prompt, name and dialogue are untouched. Spec: tests/guides_check.luau.
-- The polo is a classic Shirt drawn by tools/guide_shirt.py (teal, collar, 3-button placket, LIPA TOUR badge, short sleeves)
-- and uploaded as rbxassetid://71550766060779. The cap and tour flag carry the site's category colour (Eat/Pray/Love), the
-- lanyard ID hangs below the placket, and a GUIDE sign floats over the head. Every outfit part is welded to the body part it
-- sits on, massless and non-colliding, so the guide (anchored at its root) is unchanged in Play.
return function()
	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())

	local V, CF, ANG = Vector3.new, CFrame.new, CFrame.Angles
	local POLO = "rbxassetid://71550766060779"
	local SKIN = Color3.fromRGB(224, 172, 130)
	local TEAL = Color3.fromRGB(0, 150, 160)
	local GOLD = Color3.fromRGB(250, 200, 40)
	local WHITE = Color3.fromRGB(245, 245, 240)
	local STRAP = Color3.fromRGB(30, 30, 40)
	local CATEGORY = { Eat = Color3.fromRGB(232, 150, 70), Pray = Color3.fromRGB(90, 150, 230), Love = Color3.fromRGB(100, 190, 110) }
	local UPRIGHT = ANG(0, 0, math.pi / 2) -- Roblox cylinders run along local X; this stands them up
	local ARMS = { "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand" }

	local sites = workspace:FindFirstChild("Sites")
	assert(sites, "guides: Workspace.Sites not found")

	local function part(outfit, body, name, size, cframe, color, shape, material)
		local p = Instance.new("Part")
		p.Name = name
		if shape then p.Shape = shape end
		p.Size = size
		p.CFrame = cframe
		p.Color = color
		p.Material = material or Enum.Material.SmoothPlastic
		p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
		p.Anchored = false
		p.CanCollide = false
		p.CanTouch = false
		p.Massless = true
		local w = Instance.new("WeldConstraint")
		w.Part0, w.Part1 = body, p
		w.Parent = p
		p.Parent = outfit
		return p
	end

	local function dress(guide, color)
		local t, h, hand = guide:FindFirstChild("UpperTorso"), guide:FindFirstChild("Head"), guide:FindFirstChild("LeftHand")
		assert(t and h and hand, "guides: " .. guide:GetFullName() .. " is not an R15 figure")
		for _, name in ipairs({ "GuideOutfit", "GuidePolo" }) do
			local old = guide:FindFirstChild(name)
			if old then old:Destroy() end
		end

		-- The polo, with the torso under it teal and the arms skin-coloured below the short sleeves.
		local shirt = Instance.new("Shirt")
		shirt.Name = "GuidePolo"
		shirt.ShirtTemplate = POLO
		shirt.Parent = guide
		local bc = guide:FindFirstChildOfClass("BodyColors")
		if bc then
			bc.TorsoColor3, bc.LeftArmColor3, bc.RightArmColor3 = TEAL, SKIN, SKIN
		end
		t.Color, guide.LowerTorso.Color = TEAL, TEAL
		for _, name in ipairs(ARMS) do
			guide[name].Color = SKIN
		end

		local outfit = Instance.new("Model")
		outfit.Name = "GuideOutfit"
		local tz = t.Size.Z / 2

		-- Cap in the category colour.
		part(outfit, h, "Cap", V(0.45, h.Size.X * 1.02, h.Size.X * 1.02), h.CFrame * CF(0, h.Size.Y / 2 + 0.12, 0) * UPRIGHT, color, Enum.PartType.Cylinder)
		part(outfit, h, "CapBrim", V(h.Size.X * 0.85, 0.1, 0.75), h.CFrame * CF(0, h.Size.Y / 2 - 0.05, -(h.Size.Z / 2 + 0.3)), color)

		-- Lanyard: two straps from the collar to an ID card on the lower chest, clear of the placket.
		part(outfit, t, "LanyardL", V(0.08, 1.0, 0.06), t.CFrame * CF(-0.24, 0.05, -tz - 0.06) * ANG(0, 0, math.rad(-12)), STRAP)
		part(outfit, t, "LanyardR", V(0.08, 1.0, 0.06), t.CFrame * CF(0.24, 0.05, -tz - 0.06) * ANG(0, 0, math.rad(12)), STRAP)
		part(outfit, t, "LanyardCard", V(0.55, 0.62, 0.05), t.CFrame * CF(0, -0.62, -tz - 0.08), WHITE)
		part(outfit, t, "LanyardCardBand", V(0.55, 0.13, 0.06), t.CFrame * CF(0, -0.4, -tz - 0.085), color)

		-- Tour flag: a pole at the left hand, the flag beside the head and below the GUIDE sign. Welded to the anchored root, not
		-- the hand: the idle animation sways the arm in Play, and a hand-welded flag swung across the guide's face.
		local rootPart = guide.HumanoidRootPart
		local root = rootPart.CFrame
		local base = hand.Position
		local POLE = 5.6
		part(outfit, rootPart, "FlagPole", V(0.12, POLE, 0.12), CF(base + V(0, POLE / 2 - 0.3, 0)), Color3.fromRGB(200, 200, 205), nil, Enum.Material.Metal)
		local top = base + V(0, POLE - 0.3, 0)
		part(outfit, rootPart, "Flag", V(2.0, 1.4, 0.08), CF(top - V(0, 0.75, 0)) * root.Rotation * CF(-1.05, 0, 0), color)

		-- GUIDE sign over the head: scales with distance, hidden beyond 80 studs and behind walls.
		local sign = Instance.new("BillboardGui")
		sign.Name = "GuideSign"
		sign.Adornee = h
		sign.Size = UDim2.new(3.6, 0, 1.1, 0)
		sign.StudsOffsetWorldSpace = V(0, 3.8, 0)
		sign.MaxDistance = 80
		sign.LightInfluence = 0
		sign.AlwaysOnTop = false
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundColor3 = TEAL
		label.BorderSizePixel = 0
		label.Text = "GUIDE"
		label.TextScaled = true
		label.Font = Enum.Font.GothamBlack
		label.TextColor3 = WHITE
		label.Parent = sign
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.3, 0)
		corner.Parent = label
		local stroke = Instance.new("UIStroke")
		stroke.Color = GOLD
		stroke.Thickness = 2
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = label
		local pad = Instance.new("UIPadding")
		pad.PaddingTop, pad.PaddingBottom = UDim.new(0.12, 0), UDim.new(0.12, 0)
		pad.Parent = label
		sign.Parent = outfit

		outfit.Parent = guide
	end

	local done = {}
	for _, row in ipairs(SiteData.sites) do
		local site
		for _, m in ipairs(sites:GetChildren()) do
			if m:GetAttribute("SiteId") == row.id then site = m end
		end
		local guide = site and site:FindFirstChild("Guide")
		assert(guide, "guides: no Guide in site " .. row.id)
		dress(guide, CATEGORY[row.category])
		table.insert(done, tostring(row.id))
		task.wait()
	end
	return "guides: dressed " .. table.concat(done, ",")
end
