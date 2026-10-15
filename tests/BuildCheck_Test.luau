-- Tests for ServerStorage.BuildCheck (Slice 02). Fixtures are built unparented, so no terrain or Studio state is needed.
-- Contract:
--   BuildCheck.checkSite(model, siteRow) -> { passed, failed, failures = { "<check name> | <detail>" }, parts }
--   BuildCheck.checkWorld(root?, limit?) -> same shape; root defaults to workspace, limit to 20000 BaseParts
--     (Terrain and player characters are excluded).
-- Check names (a failure string starts with its name): "model exists", "site row known",
--   "pivot within 1 stud of pos", "facing dot > 0.99", "bounds within footprint +10%", "Guide present",
--   "GuidePrompt present", "InfoPanel with text", "JeepStop present", "JeepPrompt present", "has no JeepStop",
--   "required prop <Name>", "part budget <= 2500", "all non-rig parts anchored", "world part budget".
-- A rig is any Model that contains a Humanoid; its parts are exempt from the anchored check but still count
-- towards the budget. Bounds are compared in world axes (the 8 corners of GetBoundingBox projected to XZ).
-- Modules are required inside each test so a missing module fails every case by name (not as one load error).
return function(t)
	local expect = t.expect

	local function loadBuildCheck()
		return require(game.ServerStorage.BuildCheck:Clone())
	end
	local function SiteData()
		return require(game.ReplicatedStorage.LipaShared.SiteData)
	end

	local function newPart(parent, name, size, pos, anchored)
		local p = Instance.new("Part")
		p.Name = name
		p.Size = size
		p.Position = pos
		p.Anchored = anchored ~= false
		p.Parent = parent
		return p
	end

	local function countParts(model)
		local n = 0
		for _, d in ipairs(model:GetDescendants()) do
			if d:IsA("BasePart") then n += 1 end
		end
		return n
	end

	local function failed(res, prefix)
		for _, f in ipairs(res.failures) do
			if string.sub(f, 1, #prefix) == prefix then return true end
		end
		return false
	end
	local function describe(res)
		return table.concat(res.failures, "; ")
	end

	-- A model that satisfies every check for `row`. opts.pre(model) runs before the pivot is set (add or remove
	-- content there); opts.post(model) runs after (change the pivot there).
	local function makeFixture(row, opts)
		opts = opts or {}
		local SD = SiteData()
		local model = Instance.new("Model")
		model.Name = string.format("Site%02d_%s", row.id, row.key)

		local guidePos = SD.guidePos(row.id)
		local guide = Instance.new("Model")
		guide.Name = "Guide"
		local hrp = newPart(guide, "HumanoidRootPart", Vector3.new(2, 2, 1), guidePos + Vector3.new(0, 3, 0), true)
		newPart(guide, "Torso", Vector3.new(2, 2, 1), guidePos + Vector3.new(0, 3, 1), false) -- rig limbs may be unanchored
		Instance.new("Humanoid", guide)
		local gp = Instance.new("ProximityPrompt")
		gp.Name = "GuidePrompt"
		gp:SetAttribute("PromptKind", "Guide")
		gp.Parent = hrp
		guide.Parent = model

		local panel = newPart(model, "InfoPanel", Vector3.new(12, 8, 0.5), row.pos + Vector3.new(12, 5, 30), true)
		local gui = Instance.new("SurfaceGui", panel)
		local label = Instance.new("TextLabel", gui)
		label.Text = "Info"

		if SD.hasJeepStop(row.id) then
			local stop = newPart(model, "JeepStop", Vector3.new(12, 0.4, 12), SD.jeepStopPos(row.id) + Vector3.new(0, 0.2, 0), true)
			local jp = Instance.new("ProximityPrompt")
			jp.Name = "JeepPrompt"
			jp:SetAttribute("PromptKind", "Jeep")
			jp.Parent = stop
		end

		for _, name in ipairs(row.requiredProps) do
			local folder = Instance.new("Folder")
			folder.Name = name
			newPart(folder, name .. "Part", Vector3.new(2, 2, 2), row.pos + Vector3.new(0, 1, -20), true)
			folder.Parent = model
		end

		local structure = Instance.new("Folder")
		structure.Name = "Structure"
		newPart(structure, "Wall", Vector3.new(40, 20, 10), row.pos + Vector3.new(0, 10, -20), true)
		structure.Parent = model

		if opts.pre then opts.pre(model) end
		model.WorldPivot = CFrame.new(row.pos) * CFrame.Angles(0, SD.facingToYaw(row.facing), 0)
		if opts.post then opts.post(model) end
		return model
	end

	t.test("a valid site 1 fixture passes with no failures", function()
		local BC = loadBuildCheck()
		local row = SiteData().byId(1)
		local model = makeFixture(row)
		local res = BC.checkSite(model, row)
		expect.equal(describe(res), "")
		expect.equal(res.failed, 0)
		expect.truthy(res.passed > 0)
		expect.equal(res.parts, countParts(model))
	end)

	t.test("an unanchored non-rig part fails the anchored check", function()
		local BC = loadBuildCheck()
		local row = SiteData().byId(1)
		local model = makeFixture(row, { pre = function(m)
			newPart(m.Structure, "Loose", Vector3.new(2, 2, 2), row.pos + Vector3.new(5, 1, -20), false)
		end })
		local res = BC.checkSite(model, row)
		expect.truthy(failed(res, "all non-rig parts anchored"))
		expect.equal(res.failed, 1)
	end)

	t.test("a part outside the footprint +10% fails the bounds check", function()
		local BC = loadBuildCheck()
		local row = SiteData().byId(1) -- half-width 120, so the limit is x = 132
		local inside = makeFixture(row, { pre = function(m)
			newPart(m.Structure, "Edge", Vector3.new(4, 4, 4), row.pos + Vector3.new(128, 2, 0), true)
		end })
		expect.equal(describe(BC.checkSite(inside, row)), "")
		local outside = makeFixture(row, { pre = function(m)
			newPart(m.Structure, "Stray", Vector3.new(4, 4, 4), row.pos + Vector3.new(200, 2, 0), true)
		end })
		local res = BC.checkSite(outside, row)
		expect.truthy(failed(res, "bounds within footprint +10%"))
		expect.equal(res.failed, 1)
	end)

	t.test("a missing required prop fails by name", function()
		local BC = loadBuildCheck()
		local row = SiteData().byId(1)
		local model = makeFixture(row, { pre = function(m) m.Benches:Destroy() end })
		local res = BC.checkSite(model, row)
		expect.truthy(failed(res, "required prop Benches"))
		expect.equal(res.failed, 1)
	end)

	t.test("a required prop folder with no parts fails", function()
		local BC = loadBuildCheck()
		local row = SiteData().byId(1)
		local model = makeFixture(row, { pre = function(m) m.Lamps:ClearAllChildren() end })
		local res = BC.checkSite(model, row)
		expect.truthy(failed(res, "required prop Lamps"))
		expect.equal(res.failed, 1)
	end)

	t.test("2,501 parts fails the budget and exactly 2,500 passes", function()
		local BC = loadBuildCheck()
		local row = SiteData().byId(1)
		local atLimit = makeFixture(row, { pre = function(m)
			local filler = Instance.new("Folder")
			filler.Name = "Filler"
			local need = 2500 - countParts(m)
			for i = 1, need do
				local p = Instance.new("Part")
				p.Anchored = true
				p.Size = Vector3.new(1, 1, 1)
				p.Position = row.pos + Vector3.new(0, 1, -30)
				p.Parent = filler
			end
			filler.Parent = m
		end })
		expect.equal(countParts(atLimit), 2500)
		expect.equal(describe(BC.checkSite(atLimit, row)), "")

		local over = makeFixture(row, { pre = function(m)
			local filler = Instance.new("Folder")
			filler.Name = "Filler"
			for i = 1, 2501 - countParts(m) do
				local p = Instance.new("Part")
				p.Anchored = true
				p.Size = Vector3.new(1, 1, 1)
				p.Position = row.pos + Vector3.new(0, 1, -30)
				p.Parent = filler
			end
			filler.Parent = m
		end })
		expect.equal(countParts(over), 2501)
		local res = BC.checkSite(over, row)
		expect.truthy(failed(res, "part budget <= 2500"))
		expect.equal(res.failed, 1)
	end)

	t.test("a missing Guide fails", function()
		local BC = loadBuildCheck()
		local row = SiteData().byId(1)
		local model = makeFixture(row, { pre = function(m) m.Guide:Destroy() end })
		local res = BC.checkSite(model, row)
		expect.truthy(failed(res, "Guide present"))
	end)

	t.test("a missing GuidePrompt fails", function()
		local BC = loadBuildCheck()
		local row = SiteData().byId(1)
		local model = makeFixture(row, { pre = function(m) m.Guide.HumanoidRootPart.GuidePrompt:Destroy() end })
		local res = BC.checkSite(model, row)
		expect.truthy(failed(res, "GuidePrompt present"))
		expect.equal(res.failed, 1)
	end)

	t.test("a missing or empty InfoPanel fails", function()
		local BC = loadBuildCheck()
		local row = SiteData().byId(1)
		local missing = makeFixture(row, { pre = function(m) m.InfoPanel:Destroy() end })
		expect.truthy(failed(BC.checkSite(missing, row), "InfoPanel with text"))
		local empty = makeFixture(row, { pre = function(m) m.InfoPanel.SurfaceGui.TextLabel.Text = "" end })
		expect.truthy(failed(BC.checkSite(empty, row), "InfoPanel with text"))
	end)

	t.test("site 1 needs a JeepStop", function()
		local BC = loadBuildCheck()
		local row = SiteData().byId(1)
		local model = makeFixture(row, { pre = function(m) m.JeepStop:Destroy() end })
		local res = BC.checkSite(model, row)
		expect.truthy(failed(res, "JeepStop present"))
	end)

	t.test("a pivot 2 studs off fails the pivot check", function()
		local BC = loadBuildCheck()
		local row = SiteData().byId(1)
		local model = makeFixture(row, { post = function(m) m.WorldPivot = m.WorldPivot + Vector3.new(2, 0, 0) end })
		local res = BC.checkSite(model, row)
		expect.truthy(failed(res, "pivot within 1 stud of pos"))
		expect.equal(res.failed, 1)
	end)

	t.test("a facing rotated 90 degrees fails the facing check", function()
		local BC = loadBuildCheck()
		local row = SiteData().byId(1)
		local model = makeFixture(row, { post = function(m) m.WorldPivot = m.WorldPivot * CFrame.Angles(0, math.rad(90), 0) end })
		local res = BC.checkSite(model, row)
		expect.truthy(failed(res, "facing dot > 0.99"))
		expect.equal(res.failed, 1)
	end)

	t.test("rig parts may be unanchored, including rigs inside a prop folder", function()
		local BC = loadBuildCheck()
		local row = SiteData().byId(1)
		local model = makeFixture(row, { pre = function(m)
			local person = Instance.new("Model")
			person.Name = "Person1"
			newPart(person, "HumanoidRootPart", Vector3.new(2, 2, 1), row.pos + Vector3.new(30, 3, 40), true)
			newPart(person, "LeftArm", Vector3.new(1, 2, 1), row.pos + Vector3.new(31, 3, 40), false)
			newPart(person, "RightArm", Vector3.new(1, 2, 1), row.pos + Vector3.new(29, 3, 40), false)
			Instance.new("Humanoid", person)
			person.Parent = m.PlazaPeople
		end })
		local res = BC.checkSite(model, row)
		expect.equal(describe(res), "")
	end)

	t.test("a prop whose only part is inside a nested Model passes", function()
		local BC = loadBuildCheck()
		local row = SiteData().byId(1)
		local model = makeFixture(row, { pre = function(m)
			m.Benches:ClearAllChildren()
			local bench = Instance.new("Model")
			bench.Name = "Bench1"
			newPart(bench, "Seat", Vector3.new(6, 1, 2), row.pos + Vector3.new(20, 1, 50), true)
			bench.Parent = m.Benches
		end })
		local res = BC.checkSite(model, row)
		expect.equal(describe(res), "")
	end)

	t.test("bounds are measured in world axes for a diagonal (45 degree) site", function()
		local BC = loadBuildCheck()
		local row = SiteData().byId(6) -- facing SW, footprint 300 x 200: limits x +-165, z +-110
		local ok = makeFixture(row, { pre = function(m)
			newPart(m.Structure, "LongX", Vector3.new(280, 2, 2), row.pos + Vector3.new(0, 1, 0), true)
		end })
		expect.equal(describe(BC.checkSite(ok, row)), "")
		local bad = makeFixture(row, { pre = function(m)
			newPart(m.Structure, "LongZ", Vector3.new(2, 2, 230), row.pos + Vector3.new(0, 1, 0), true)
		end })
		local res = BC.checkSite(bad, row)
		expect.truthy(failed(res, "bounds within footprint +10%"))
		expect.equal(res.failed, 1)
	end)

	t.test("nil model or unknown site row reports a failure instead of erroring", function()
		local BC = loadBuildCheck()
		local row = SiteData().byId(1)
		local noModel = BC.checkSite(nil, row)
		expect.truthy(failed(noModel, "model exists"))
		expect.truthy(noModel.failed >= 1)
		local noRow = BC.checkSite(makeFixture(row), nil)
		expect.truthy(failed(noRow, "site row known"))
		expect.truthy(noRow.failed >= 1)
	end)

	t.test("checkWorld counts parts under a root and enforces the limit", function()
		local BC = loadBuildCheck()
		local root = Instance.new("Folder")
		for i = 1, 3 do
			newPart(root, "P" .. i, Vector3.new(1, 1, 1), Vector3.new(i, 1, 0), true)
		end
		local ok = BC.checkWorld(root)
		expect.equal(describe(ok), "")
		expect.equal(ok.parts, 3)
		local over = BC.checkWorld(root, 2)
		expect.truthy(failed(over, "world part budget"))
		expect.equal(over.failed, 1)
	end)
end
