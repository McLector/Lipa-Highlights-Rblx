-- site02_crowd: the shopper crowd of Site 02 (Candido B. Lopez Memorial Public Market), job R6b: 11 R15 rigs Shopper1..Shopper11 in the Folder Crowd (directly under Site02_Market).
-- Studio copy: ServerStorage.Builders.site02_crowd. Assembler: builders/site02.luau. Check: tests/site02_check.luau, group "crowd".
-- Owns Crowd only, budget 0: the rigs are outside the module budget and the container rule (env.addRig(rig, "Crowd")); their BaseParts (16 each, 176 in all) count toward the site cap and rigParts.
-- Players:CreateHumanoidModelFromDescription yields, so this module is only run from a yielding coordinator. The recipe is the vendor recipe of builders/site02_props.luau:
--   no Accessory, no Animate, no extra parts, anchored root, DisplayDistanceType None, SiteId 2.
-- Positions are WORLD (x east, z south, y up). y0 = the ground height under the figure (0.3 on the apron slab, 0 in the yards); the HumanoidRootPart centre is y0 + 3.0.
-- Clusters: the foot of the north stair (apron, z 76..108) and of the south stair (apron, z 214..242), the north yard walkway (between the kerb vehicles and the booths)
--   and the south yard shoppers' aisle. Pairs face each other or the booths, never a wall. Everything stays west of x -243 on the apron (the zebra crossings, the Guide, the InfoPanel,
--   the Road F mouth and the band rows stay empty) and clear of every built part and every other rig (probed in Studio; an R15 box grown by 0.5 meets nothing).
-- Snaps from the first free-space probe (kept in step with the check): Shopper1 x -247 -> -246.5 (LeanPost8 at x -249.6, z 80.8); Shopper7 moved off z 232..237 to z 214
--   (the parked jeepney SJ2 and LampPost5 fill the apron there); Shopper8 x -415 -> -411 (the kerb tricycle STri6 at x -418, z 45.5).
--   A second figure of the south pair was dropped to keep the Market at 2498 parts under BuildCheck's 2500 cap (owner-approved 2026-10-30).
return function(env)
	local V = env.V
	local C3 = Color3.fromRGB
	local Players = game:GetService("Players")
	local SKINS = { C3(224, 172, 130), C3(198, 134, 92), C3(141, 85, 60), C3(241, 194, 125) }
	local SHIRTS = {
		C3(200, 60, 60), C3(60, 100, 170), C3(230, 200, 80), C3(90, 150, 100),
		C3(170, 90, 150), C3(235, 140, 60), C3(70, 160, 170), C3(120, 120, 130),
	}
	local LEGS = C3(50, 50, 70)
	-- { x, z, y0, face = { dx, dz } }: world position, ground height, the direction the figure looks along
	local SHOPPERS = {
		{ -246.5, 82, 0.3, { 1.5, 5 } }, { -245, 87, 0.3, { -1.5, -5 } }, -- north stair foot, a pair facing each other
		{ -247, 98, 0.3, { 2, 5 } }, { -245, 103, 0.3, { -2, -5 } }, -- north stair foot, a second pair
		{ -248, 220, 0.3, { 2, 5 } }, { -246, 225, 0.3, { -2, -5 } }, -- south stair foot, a pair
		{ -248, 214, 0.3, { 2, 11 } }, -- south stair foot, one figure beside the pair
		{ -411, 46, 0, { 0, 1 } }, { -370, 46, 0, { 0, 1 } }, -- north yard walkway, both looking at the booths
		{ -420, 252, 0, { 0, -1 } }, { -335, 251, 0, { 0, -1 } }, -- south yard shoppers' aisle, looking at the shed-row booths
	}
	for n, s in ipairs(SHOPPERS) do
		local pos = V(s[1], s[3] + 3.0, s[2])
		local dir = V(s[4][1], 0, s[4][2])
		local desc = Instance.new("HumanoidDescription")
		desc.HeadColor = SKINS[(n * 3 - 2) % #SKINS + 1]
		local shirt = SHIRTS[(n * 3) % #SHIRTS + 1]
		desc.TorsoColor, desc.LeftArmColor, desc.RightArmColor = shirt, shirt, shirt
		desc.LeftLegColor, desc.RightLegColor = LEGS, LEGS
		local rig = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
		desc:Destroy()
		rig.Name = "Shopper" .. n
		for _, d in ipairs(rig:GetDescendants()) do
			if d:IsA("BasePart") then d.Anchored = false end
		end
		local hrp = rig:WaitForChild("HumanoidRootPart")
		local hum = rig:FindFirstChildOfClass("Humanoid")
		hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		hum.WalkSpeed = 0
		rig.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
		rig:SetAttribute("SiteId", 2)
		local animate = rig:FindFirstChild("Animate")
		if animate then animate:Destroy() end
		rig:PivotTo(CFrame.lookAt(pos, pos + dir))
		hrp.Anchored = true
		env.addRig(rig, "Crowd")
	end
end
