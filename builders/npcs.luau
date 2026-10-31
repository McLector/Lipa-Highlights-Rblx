-- npcs: location NPCs for the ten sites (professor's feedback: NPCs that match their location). Studio copy:
-- ServerStorage.Builders.npcs; run with
--   require(game.ServerStorage.Builders.npcs:Clone())()                    -- all ten sites
--   require(game.ServerStorage.Builders.npcs:Clone())({ only = { 10 } })   -- just those sites' LocalNPCs (Slice 3b: City Hall)
-- Run AFTER the site builders. IDEMPOTENT: replaces only the LocalNPCs folder of each site; every other child is left alone,
-- and the site builders leave LocalNPCs alone (they only replace the children they own). Spec: tests/npcs_check.luau.
-- Figures are R15 rigs from a HumanoidDescription, like site01 buildPeople. These rigs join their limbs with AnimationConstraints,
-- not Motor6Ds, so a pose is set by placing every limb from its joint attachments and then anchoring every part: the pose holds
-- in Edit and in Play. Clothing and props are plain coloured parts inside the rig model (no catalog assets, no textures), which
-- the site checks and BuildCheck treat as rig parts.
-- Fail-safe order: all figures are built unparented first; only then is each old LocalNPCs folder replaced.
return function(opts)
	local Players = game:GetService("Players")
	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())

	local V, CF, ANG = Vector3.new, CFrame.new, CFrame.Angles
	local R = math.rad
	local sites = workspace:FindFirstChild("Sites")
	assert(sites, "npcs: Workspace.Sites not found")

	local function siteModel(id)
		for _, m in ipairs(sites:GetChildren()) do
			if m:GetAttribute("SiteId") == id then return m end
		end
		error("npcs: no site model with SiteId " .. id)
	end

	------------------------------------------------------------------ Colours
	local SKIN = { Color3.fromRGB(224, 172, 130), Color3.fromRGB(198, 134, 92), Color3.fromRGB(141, 85, 60), Color3.fromRGB(241, 194, 125) }
	local WHITE = Color3.fromRGB(245, 245, 240)
	local CREAM = Color3.fromRGB(240, 232, 210)
	local DARK = Color3.fromRGB(50, 50, 70)
	local KHAKI = Color3.fromRGB(190, 170, 130)
	local BROWN = Color3.fromRGB(95, 60, 35)

	------------------------------------------------------------------ Poses (joint name -> rotation in the joint frame)
	-- Signs found in Studio: +X on a hip swings the leg forward, -X on a knee folds the shin back, +X on a shoulder raises the arm forward.
	local function rx(d) return ANG(R(d), 0, 0) end
	local POSES = {
		stand = {},
		walk = { LeftHip = rx(20), RightHip = rx(-20), RightKnee = rx(-15), LeftShoulder = rx(-20), RightShoulder = rx(20) },
		carry = { LeftHip = rx(15), RightHip = rx(-15), LeftShoulder = rx(-15) },
		sit = { LeftHip = rx(90), RightHip = rx(90), LeftKnee = rx(-90), RightKnee = rx(-90), LeftShoulder = rx(25), RightShoulder = rx(25) },
		sitCup = { LeftHip = rx(90), RightHip = rx(90), LeftKnee = rx(-90), RightKnee = rx(-90), LeftShoulder = rx(25), RightShoulder = rx(60) },
		sitRod = { LeftHip = rx(90), RightHip = rx(90), LeftKnee = rx(-90), RightKnee = rx(-90), LeftShoulder = rx(20), RightShoulder = rx(55) },
		kneelPray = { LeftKnee = rx(-90), RightKnee = rx(-90), LeftShoulder = rx(75), RightShoulder = rx(75) },
		yoga = { LeftHip = rx(90), RightHip = rx(90), LeftShoulder = rx(170), RightShoulder = rx(170) },
		golf = { LeftShoulder = rx(25), RightShoulder = rx(25) },
		kick = { RightHip = rx(35), LeftShoulder = rx(25), RightShoulder = rx(-25) },
		ladle = { RightShoulder = rx(50) },
	}
	-- Parents before children, so each limb is placed from an already placed parent.
	local ORDER = { "Root", "Waist", "Neck", "LeftShoulder", "LeftElbow", "LeftWrist", "RightShoulder", "RightElbow", "RightWrist",
		"LeftHip", "LeftKnee", "LeftAnkle", "RightHip", "RightKnee", "RightAnkle" }

	local function applyPose(rig, rots)
		local joints = {}
		for _, d in ipairs(rig:GetDescendants()) do
			if d:IsA("AnimationConstraint") or d:IsA("Motor6D") then joints[d.Name] = d end
		end
		for _, name in ipairs(ORDER) do
			local j = joints[name]
			assert(j, "npcs: rig has no joint " .. name)
			local T = rots[name] or CFrame.identity
			if j:IsA("Motor6D") then
				j.Part1.CFrame = j.Part0.CFrame * j.C0 * T * j.C1:Inverse()
			else
				j.Attachment1.Parent.CFrame = j.Attachment0.Parent.CFrame * j.Attachment0.CFrame * T * j.Attachment1.CFrame:Inverse()
			end
			j.Transform = T
		end
		for _, d in ipairs(rig:GetDescendants()) do
			if d:IsA("BasePart") then d.Anchored = true end
		end
	end

	-- Lowest world Y of a set of parts (world-axis bounding box of each rotated part).
	local function bottomOf(parts)
		local m = math.huge
		for _, p in ipairs(parts) do
			local c, s = p.CFrame, p.Size
			local hy = math.abs(c.RightVector.Y) * s.X / 2 + math.abs(c.UpVector.Y) * s.Y / 2 + math.abs(c.LookVector.Y) * s.Z / 2
			m = math.min(m, c.Position.Y - hy)
		end
		return m
	end
	local function bodyParts(rig)
		local list = {}
		for _, d in ipairs(rig:GetChildren()) do
			if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then table.insert(list, d) end
		end
		return list
	end

	------------------------------------------------------------------ Props (anchored, non-colliding parts inside the rig)
	local function part(rig, name, size, cframe, color, shape, material)
		local p = Instance.new("Part")
		p.Name = name
		if shape then p.Shape = shape end
		p.Size = size
		p.CFrame = cframe
		p.Color = color
		p.Material = material or Enum.Material.SmoothPlastic
		p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
		p.Anchored = true
		p.CanCollide = false
		p.Parent = rig
		return p
	end
	local UPRIGHT = ANG(0, 0, math.pi / 2) -- Roblox cylinders run along local X; this stands them up

	local WEAR = {
		Apron = function(rig, c)
			local t, l = rig.UpperTorso, rig.LowerTorso
			part(rig, "Apron", V(t.Size.X * 0.8, t.Size.Y * 0.8, 0.1), t.CFrame * CF(0, -0.1, -(t.Size.Z / 2 + 0.05)), c)
			part(rig, "ApronLower", V(l.Size.X * 0.85, l.Size.Y + 0.2, 0.1), l.CFrame * CF(0, -0.1, -(l.Size.Z / 2 + 0.05)), c)
		end,
		Cap = function(rig, c)
			local h = rig.Head
			part(rig, "Cap", V(0.8, h.Size.X * 0.95, h.Size.X * 0.95), h.CFrame * CF(0, h.Size.Y / 2 + 0.35, 0) * UPRIGHT, c, Enum.PartType.Cylinder)
		end,
		Visor = function(rig, c)
			local h = rig.Head
			part(rig, "Visor", V(h.Size.X + 0.1, 0.3, h.Size.Z + 0.1), h.CFrame * CF(0, h.Size.Y / 2, 0), c)
			part(rig, "VisorBrim", V(h.Size.X * 0.8, 0.1, 0.7), h.CFrame * CF(0, h.Size.Y / 2 - 0.1, -(h.Size.Z / 2 + 0.3)), c)
		end,
		Veil = function(rig, c)
			local h = rig.Head
			part(rig, "Veil", V(h.Size.X + 0.15, 0.12, h.Size.Z + 0.15), h.CFrame * CF(0, h.Size.Y / 2 + 0.05, 0), c, nil, Enum.Material.Fabric)
			part(rig, "VeilBack", V(h.Size.X + 0.15, h.Size.Y + 0.6, 0.1), h.CFrame * CF(0, -0.3, h.Size.Z / 2 + 0.07), c, nil, Enum.Material.Fabric)
		end,
		Salakot = function(rig, c)
			local h = rig.Head
			part(rig, "Salakot", V(0.2, 2.6, 2.6), h.CFrame * CF(0, h.Size.Y / 2 + 0.15, 0) * UPRIGHT, c, Enum.PartType.Cylinder, Enum.Material.WoodPlanks)
			part(rig, "SalakotTop", V(0.5, 1.2, 1.2), h.CFrame * CF(0, h.Size.Y / 2 + 0.45, 0) * UPRIGHT, c, Enum.PartType.Cylinder, Enum.Material.WoodPlanks)
		end,
		Rosary = function(rig)
			local hand = rig.LeftHand
			part(rig, "Rosary", V(0.12, 0.9, 0.12), hand.CFrame * CF(0, -hand.Size.Y / 2 - 0.4, 0), BROWN)
			part(rig, "RosaryCross", V(0.35, 0.1, 0.1), hand.CFrame * CF(0, -hand.Size.Y / 2 - 0.7, 0), BROWN)
		end,
		Bayong = function(rig)
			local hand = rig.RightHand
			part(rig, "Bayong", V(1.3, 1.1, 0.7), hand.CFrame * CF(0, -hand.Size.Y / 2 - 0.6, 0), Color3.fromRGB(186, 150, 96), nil, Enum.Material.Fabric)
			part(rig, "BayongHandle", V(0.1, 0.5, 0.5), hand.CFrame * CF(0, -0.1, 0), Color3.fromRGB(150, 115, 70))
		end,
		ShoppingBag = function(rig, c)
			local hand = rig.RightHand
			part(rig, "ShoppingBag", V(1.2, 1.3, 0.5), hand.CFrame * CF(0, -hand.Size.Y / 2 - 0.7, 0), c)
			part(rig, "ShoppingBagHandle", V(0.1, 0.5, 0.4), hand.CFrame * CF(0, -0.1, 0), WHITE)
		end,
		Cup = function(rig)
			local hand = rig.RightHand
			part(rig, "Cup", V(0.55, 0.45, 0.45), hand.CFrame * CF(0, -hand.Size.Y / 2 - 0.15, 0) * UPRIGHT, WHITE, Enum.PartType.Cylinder)
		end,
		Ladle = function(rig)
			local hand = rig.RightHand
			part(rig, "Ladle", V(0.15, 2.2, 0.15), hand.CFrame * CF(0, -hand.Size.Y / 2 - 0.9, 0), Color3.fromRGB(180, 180, 185), nil, Enum.Material.Metal)
			part(rig, "LadleBowl", V(0.4, 0.7, 0.7), hand.CFrame * CF(0, -hand.Size.Y / 2 - 2.0, 0) * UPRIGHT, Color3.fromRGB(180, 180, 185), Enum.PartType.Cylinder, Enum.Material.Metal)
		end,
	}

	-- Props that rest on the ground or seat, placed after the figure is set down. g = the surface height under the figure.
	local GROUND = {
		Ball = function(rig, g)
			local hrp = rig.HumanoidRootPart.CFrame
			local p = hrp.Position + hrp.LookVector * 1.8 + hrp.RightVector * 0.5
			part(rig, "Ball", V(1.1, 1.1, 1.1), CF(p.X, g + 0.55, p.Z), WHITE, Enum.PartType.Ball)
		end,
		GolfBag = function(rig, g)
			local hrp = rig.HumanoidRootPart.CFrame
			local p = hrp.Position + hrp.RightVector * 1.8
			part(rig, "GolfBag", V(3.2, 1.1, 1.1), CF(p.X, g + 1.6, p.Z) * UPRIGHT, Color3.fromRGB(40, 60, 120), Enum.PartType.Cylinder)
			part(rig, "GolfBagClubs", V(0.8, 0.8, 0.8), CF(p.X, g + 3.5, p.Z), Color3.fromRGB(180, 180, 185), nil, Enum.Material.Metal)
		end,
		GolfClub = function(rig, g)
			local hrp = rig.HumanoidRootPart.CFrame
			local grip = (rig.LeftHand.Position + rig.RightHand.Position) / 2
			local foot = hrp.Position + hrp.LookVector * 2.2
			local toe = V(foot.X, g + 0.2, foot.Z)
			local len = (grip - toe).Magnitude
			part(rig, "GolfClub", V(0.12, 0.12, len), CFrame.lookAt((grip + toe) / 2, toe), Color3.fromRGB(180, 180, 185), nil, Enum.Material.Metal)
			part(rig, "ClubHead", V(0.8, 0.3, 0.35), CF(toe.X, g + 0.15, toe.Z) * hrp.Rotation, Color3.fromRGB(60, 60, 60))
		end,
		Rod = function(rig)
			-- 9 studs from the right hand, raised 35 degrees over the water ahead; the line drops to just above the lake (y 0.2).
			local look = rig.HumanoidRootPart.CFrame.LookVector
			local dir = (look * math.cos(R(35)) + V(0, math.sin(R(35)), 0)).Unit
			local base = rig.RightHand.Position
			local tip = base + dir * 9
			part(rig, "Rod", V(0.15, 0.15, 9), CFrame.lookAt((base + tip) / 2, tip), BROWN)
			part(rig, "RodLine", V(0.05, tip.Y - 0.2, 0.05), CF(tip.X, (tip.Y + 0.2) / 2, tip.Z), Color3.fromRGB(230, 230, 230))
		end,
		YogaMat = function(rig, g)
			local hrp = rig.HumanoidRootPart.CFrame
			local p = hrp.Position + hrp.LookVector * 1.0
			part(rig, "YogaMat", V(2.6, 0.1, 6), CF(p.X, g + 0.05, p.Z) * hrp.Rotation, Color3.fromRGB(120, 70, 150), nil, Enum.Material.Fabric)
		end,
	}

	------------------------------------------------------------------ One figure
	-- spec: { role, x, z, face = Vector3 direction, pose, top = colour, legs = colour, skin = index,
	--         seat = height of the seat top (sitting figures; thighs rest on it), probe = Y to cast down from (others),
	--         wear = { name = colour or true }, ground = { names } }
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local function buildFigure(row, s)
		local desc = Instance.new("HumanoidDescription")
		desc.HeadColor = SKIN[s.skin or 1]
		desc.TorsoColor, desc.LeftArmColor, desc.RightArmColor = s.top, s.arms or s.top, s.arms or s.top
		desc.LeftLegColor, desc.RightLegColor = s.legs or DARK, s.legs or DARK
		local rig = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
		desc:Destroy()
		rig.Name = s.role
		rig:SetAttribute("Role", s.role)
		rig:SetAttribute("SiteId", row.id)
		rig.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
		local hum = rig:FindFirstChildOfClass("Humanoid")
		hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		hum.WalkSpeed = 0
		local animate = rig:FindFirstChild("Animate")
		if animate then animate:Destroy() end

		local start = V(s.x, 100, s.z)
		rig:PivotTo(CFrame.lookAt(start, start + V(s.face.X, 0, s.face.Z)))
		applyPose(rig, POSES[s.pose])
		for name, colour in pairs(s.wear or {}) do
			WEAR[name](rig, colour)
		end

		-- Set the figure down: thighs on the seat top, or the lowest body part on the surface below.
		local surface
		local dy
		if s.seat then
			surface = s.seat
			dy = s.seat - bottomOf({ rig.LeftUpperLeg, rig.RightUpperLeg })
		else
			local hit = workspace:Raycast(V(s.x, s.probe, s.z), V(0, -60, 0), rayParams)
			assert(hit, string.format("npcs: no ground under %s at (%.1f, %.1f)", s.role, s.x, s.z))
			surface = hit.Position.Y
			dy = surface - bottomOf(bodyParts(rig))
		end
		rig:PivotTo(rig:GetPivot() + V(0, dy, 0))
		for _, name in ipairs(s.ground or {}) do
			GROUND[name](rig, surface)
		end
		return rig
	end

	------------------------------------------------------------------ The cast, per site (world coordinates, measured in Studio)
	local SW, NE = V(-1, 0, 1), V(1, 0, -1)
	local CAST = {
		[1] = { -- Cathedral: parishioners on the forecourt, walking to the door at (0, 4)
			{ role = "ParishionerVeil", x = -6, z = 15, face = V(6, 0, -11), pose = "walk", top = Color3.fromRGB(120, 160, 200), legs = Color3.fromRGB(70, 70, 100), skin = 2,
				probe = 30, wear = { Veil = WHITE, Rosary = true } },
			{ role = "Parishioner", x = 7, z = 16, face = V(-7, 0, -12), pose = "walk", top = CREAM, skin = 3, probe = 30 },
		},
		[2] = { -- Market (BP1 rebuild, Slice 4): shoppers in the south side-yard aisle at (-380, 255) and (-372, 258) (scratch/site02/layout.md 3.3), facing west
			{ role = "ShopperBayong1", x = -380, z = 255, face = V(-1, 0, 0), pose = "carry", top = Color3.fromRGB(220, 120, 150), skin = 1, probe = 8, wear = { Bayong = true } },
			{ role = "ShopperBayong2", x = -372, z = 258, face = V(-1, 0, 0), pose = "carry", top = Color3.fromRGB(110, 150, 90), skin = 4, probe = 8, wear = { Bayong = true } },
		},
		[3] = { -- Lomi King: a cook in the kitchen strip (x 320..326) beside the stove (z 127..131), facing it; two diners at the table at (292, 147.5)
			{ role = "Cook", x = 323, z = 134.2, face = V(0, 0, -1), pose = "ladle", top = WHITE, legs = Color3.fromRGB(40, 40, 45), skin = 2, probe = 5,
				wear = { Apron = Color3.fromRGB(230, 230, 225), Cap = WHITE, Ladle = true } },
			{ role = "Diner1", x = 289.7, z = 147.5, face = V(1, 0, 0), pose = "sit", top = Color3.fromRGB(60, 100, 170), skin = 3, seat = 2.0 },
			{ role = "Diner2", x = 294.3, z = 147.5, face = V(-1, 0, 0), pose = "sit", top = Color3.fromRGB(230, 200, 80), skin = 1, seat = 2.0 },
		},
		[4] = { -- Cafe: two customers at the outdoor table at (262, -148); 0.4 back from the chair centres (259.7 / 264.3) so the legs clear the table (C4, 061)
			{ role = "Customer1", x = 259.3, z = -148, face = V(1, 0, 0), pose = "sitCup", top = Color3.fromRGB(150, 60, 60), skin = 4, seat = 2.0, wear = { Cup = true } },
			{ role = "Customer2", x = 264.7, z = -148, face = V(-1, 0, 0), pose = "sitCup", top = Color3.fromRGB(70, 120, 120), skin = 2, seat = 2.0, wear = { Cup = true } },
		},
		[5] = { -- Carmel: a pilgrim kneeling at the outdoor shrine (z -651), one seated in a pew facing the kneeler
			{ role = "PilgrimKneeling", x = -220, z = -643.5, face = V(0, 0, -1), pose = "kneelPray", top = WHITE, legs = Color3.fromRGB(60, 60, 80), skin = 2, probe = 10 },
			{ role = "PilgrimSeated", x = -225, z = -568, face = V(0, 0, -1), pose = "sit", top = Color3.fromRGB(150, 130, 170), skin = 1, seat = 2.2, wear = { Rosary = true } },
		},
		[6] = { -- Outlets: shoppers at the ShopBlock's covered walkway, a player on the Aboitiz Pitch kicking toward the west goal
			-- (board rebuild 2026-10-31: the pitch moved and its goals are now at the E and W ends; the player was at (671, -690) facing N)
			{ role = "Shopper1", x = 575, z = -645, face = NE, pose = "walk", top = Color3.fromRGB(240, 240, 240), legs = Color3.fromRGB(40, 70, 130), skin = 1, probe = 10,
				wear = { ShoppingBag = Color3.fromRGB(200, 50, 50) } },
			{ role = "Shopper2", x = 566, z = -652, face = SW, pose = "walk", top = Color3.fromRGB(90, 90, 90), skin = 3, probe = 10,
				wear = { ShoppingBag = Color3.fromRGB(240, 170, 40) } },
			{ role = "FootballPlayer", x = 650, z = -660, face = V(-1, 0, 0), pose = "kick", top = Color3.fromRGB(230, 120, 30), legs = WHITE, skin = 2, probe = 10, ground = { "Ball" } },
		},
		[7] = { -- Farm: a guest on a mat on the round pavilion's floor (top y 1.0, board rebuild 2026-10-31; was the lagoon deck at (736, 300)),
			-- a staff member in white on the plaza beside it (was (726, 293))
			{ role = "YogaGuest", x = 756, z = 206, face = V(-1, 0, 0), pose = "yoga", top = Color3.fromRGB(240, 200, 210), legs = Color3.fromRGB(70, 70, 90), skin = 4, seat = 1.15,
				ground = { "YogaMat" } },
			{ role = "FarmStaff", x = 745, z = 214, face = V(1, 0, -0.7), pose = "stand", top = WHITE, legs = WHITE, skin = 2, probe = 10 },
		},
		[8] = { -- Malarayat: a golfer and a caddie on the forecourt by the carts
			{ role = "Golfer", x = 578, z = 748, face = SW, pose = "golf", top = Color3.fromRGB(240, 240, 240), legs = KHAKI, skin = 1, probe = 40,
				wear = { Visor = Color3.fromRGB(30, 50, 100) }, ground = { "GolfClub" } },
			{ role = "Caddie", x = 581.5, z = 744.5, face = SW, pose = "stand", top = Color3.fromRGB(230, 200, 60), legs = DARK, skin = 3, probe = 40, ground = { "GolfBag" } },
		},
		[9] = { -- Tagbakin: a fisher on a banca thwart, rod out over the lake (SW)
			{ role = "Fisher", x = -697.4, z = 615.6, face = SW, pose = "sitRod", top = Color3.fromRGB(70, 110, 150), skin = 3, seat = 1.75,
				wear = { Salakot = Color3.fromRGB(200, 170, 110) }, ground = { "Rod" } },
		},
		[10] = { -- City Hall (pivot -250, 0, -260, facing E; local lx = world x + 250, lz = world z + 260): casual locals on the forecourt
			-- paving, walking toward the steps (-X), clear of the spawn pad (lx 30..50, lz -10..10), Ate Joy (lx 22..32), the panel spot
			-- (lx 28..38, lz -30..-15), the jeep curb (lx 90..100, lz 20..40) and the steps (lx 5..25).
			{ role = "ResidentWalking", x = -204, z = -234, face = V(-1, 0, -0.3), pose = "walk", top = Color3.fromRGB(110, 150, 190), legs = Color3.fromRGB(60, 70, 100), skin = 2, probe = 30 },
			{ role = "ResidentBayong", x = -188, z = -290, face = V(-1, 0, 0.3), pose = "carry", top = Color3.fromRGB(215, 120, 140), skin = 1, probe = 30, wear = { Bayong = true } },
			{ role = "Student", x = -206, z = -298, face = V(-1, 0, 0.5), pose = "carry", top = WHITE, legs = Color3.fromRGB(40, 60, 110), skin = 4, probe = 30,
				wear = { ShoppingBag = Color3.fromRGB(70, 140, 100) } },
			{ role = "OfficeStaff", x = -184, z = -230, face = V(-1, 0, -0.3), pose = "stand", top = CREAM, legs = DARK, skin = 3, probe = 30 },
		},
	}

	------------------------------------------------------------------ Build everything unparented, then swap per site
	local exclude = {}
	for _, d in ipairs(workspace:GetDescendants()) do
		if d:IsA("Model") and d:FindFirstChildOfClass("Humanoid") then table.insert(exclude, d) end
	end
	rayParams.FilterDescendantsInstances = exclude

	-- Which sites: all ten, or opts.only (an array of site ids) to rebuild just those LocalNPCs folders.
	local ids = {}
	if opts and opts.only then
		for _, id in ipairs(opts.only) do table.insert(ids, id) end
	else
		for id = 1, 10 do table.insert(ids, id) end
	end

	local built = {}
	for _, id in ipairs(ids) do
		local row = SiteData.byId(id)
		local folder = Instance.new("Folder")
		folder.Name = "LocalNPCs"
		for _, s in ipairs(CAST[id]) do
			s.face = s.face.Unit
			buildFigure(row, s).Parent = folder
		end
		built[id] = folder
		task.wait()
	end

	local counts = {}
	for _, id in ipairs(ids) do
		local site = siteModel(id)
		local old = site:FindFirstChild("LocalNPCs")
		if old then old:Destroy() end
		built[id].Parent = site
		table.insert(counts, string.format("%d:%d", id, #built[id]:GetChildren()))
		task.wait()
	end
	return "npcs: built " .. table.concat(counts, " ")
end
