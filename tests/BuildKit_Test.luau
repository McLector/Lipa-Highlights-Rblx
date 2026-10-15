-- Tests for ServerStorage.BuildKit (Slice 02). Contract:
--   BuildKit.new(target, origin, opts?) -> ctx   target: Model that flush() parents chunk models into;
--     origin: CFrame that every local CFrame is multiplied by; opts: { budget = number (default math.huge),
--     chunkSize = number (default 400), forceCsgFail = bool }.
--   ctx:part(name, size, localCF, color, material) -> Part   anchored, smooth surfaces, held in an unparented
--     chunk until flush(); errors with "budget" in the message once count would pass opts.budget.
--   ctx:parts() -> list of every part created, in creation order.     ctx:count() -> number of parts created.
--   ctx:repeatAlong(n, startPos, step, fn)   calls fn(i, Vector3) for i = 1..n at startPos + step * (i - 1);
--     n must be a non-negative integer (n = 0 calls nothing).
--   ctx:octagonRing(name, radius, height, baseY, thickness, color, material, centreCF?) -> { Part x8 }   segment
--     centres lie `radius` from the local Y axis (moved to centreCF when given), 45 degrees apart.
--   ctx:arch(name, spec) -> { path = "csg" | "fallback", parts = { ... } }   spec = { width, height, depth,
--     wallWidth, wallHeight, cframe, color, material }: a wall with an arched opening. CSG cuts happen in a
--     scratch folder under Workspace ("BuildKitScratch") that is always destroyed afterwards. With
--     opts.forceCsgFail the CSG step raises inside the guarded section, and the arch is built from piers, a
--     header block and two wedges instead.
--   ctx:flush() -> total   parents the held chunks into target, at most chunkSize parts per chunk model, with
--     task.wait() after each chunk.
-- Modules are required inside each test so a missing module fails every case by name.
return function(t)
	local expect = t.expect

	local function newCtx(opts, origin)
		local Kit = require(game.ServerStorage.BuildKit:Clone())
		local target = Instance.new("Model")
		return Kit.new(target, origin or CFrame.new(), opts), target
	end

	local RED = Color3.fromRGB(200, 40, 40)
	local function partCount(inst)
		local n = 0
		for _, d in ipairs(inst:GetDescendants()) do
			if d:IsA("BasePart") then n += 1 end
		end
		return n
	end

	t.test("part is anchored, smooth, placed through the origin and counted", function()
		local ctx = newCtx(nil, CFrame.new(100, 0, 50))
		local p = ctx:part("Slab", Vector3.new(2, 2, 2), CFrame.new(1, 2, 3), RED, Enum.Material.Concrete)
		expect.equal(p.Name, "Slab")
		expect.equal(p.Anchored, true)
		expect.equal(p.TopSurface, Enum.SurfaceType.Smooth)
		expect.equal(p.BottomSurface, Enum.SurfaceType.Smooth)
		expect.equal(p.Material, Enum.Material.Concrete)
		expect.equal(p.Color, RED)
		expect.near(p.Position.X, 101, 1e-4)
		expect.near(p.Position.Y, 2, 1e-4)
		expect.near(p.Position.Z, 53, 1e-4)
		expect.equal(ctx:count(), 1)
		expect.equal(#ctx:parts(), 1)
	end)

	t.test("repeatAlong creates n parts at exact spacing", function()
		local ctx = newCtx()
		ctx:repeatAlong(5, Vector3.new(0, 1, 0), Vector3.new(4, 0, 0), function(i, pos)
			ctx:part("P" .. i, Vector3.new(1, 1, 1), CFrame.new(pos), RED, Enum.Material.Concrete)
		end)
		local parts = ctx:parts()
		expect.equal(#parts, 5)
		for i = 1, 5 do
			expect.near(parts[i].Position.X, (i - 1) * 4, 1e-4)
			expect.near(parts[i].Position.Y, 1, 1e-4)
		end
	end)

	t.test("repeatAlong with n = 0 creates nothing and bad n errors", function()
		local ctx = newCtx()
		local calls = 0
		ctx:repeatAlong(0, Vector3.zero, Vector3.new(1, 0, 0), function() calls += 1 end)
		expect.equal(calls, 0)
		expect.equal(ctx:count(), 0)
		expect.throws(function()
			ctx:repeatAlong(-1, Vector3.zero, Vector3.new(1, 0, 0), function() end)
		end)
		expect.throws(function()
			ctx:repeatAlong(2.5, Vector3.zero, Vector3.new(1, 0, 0), function() end)
		end)
		expect.equal(calls, 0)
	end)

	t.test("octagonRing makes 8 segments at the given radius, 45 degrees apart", function()
		local ctx = newCtx()
		local ring = ctx:octagonRing("Ring", 10, 3, 5, 1, RED, Enum.Material.Concrete)
		expect.equal(#ring, 8)
		expect.equal(ctx:count(), 8)
		local angles = {}
		for _, p in ipairs(ring) do
			expect.near(Vector3.new(p.Position.X, 0, p.Position.Z).Magnitude, 10, 1e-3)
			expect.near(p.Position.Y, 6.5, 1e-3) -- baseY + height / 2
			expect.equal(p.Anchored, true)
			table.insert(angles, math.atan2(p.Position.Z, p.Position.X))
		end
		table.sort(angles)
		for i = 2, 8 do
			expect.near(angles[i] - angles[i - 1], math.pi / 4, 1e-3)
		end
	end)

	t.test("octagonRing accepts an optional centre CFrame (axis moved, height and radius kept)", function()
		local ctx = newCtx(nil, CFrame.new(100, 0, 0))
		local ring = ctx:octagonRing("Ring", 10, 3, 5, 1, RED, Enum.Material.Concrete, CFrame.new(-30, 0, 40))
		expect.equal(#ring, 8)
		for _, p in ipairs(ring) do
			expect.near(Vector3.new(p.Position.X - 70, 0, p.Position.Z - 40).Magnitude, 10, 1e-3) -- centre = origin * (-30, 0, 40)
			expect.near(p.Position.Y, 6.5, 1e-3)
		end
	end)

	t.test("window is a pane plus a round top standing on the given CFrame; material is overridable", function()
		local ctx = newCtx()
		local w = ctx:window("W", 4, 9, 1, CFrame.new(10, 2, 3), RED)
		expect.equal(#w, 2)
		expect.equal(ctx:count(), 2)
		local rect, top = w[1], w[2]
		expect.equal(rect.Material, Enum.Material.Glass) -- default
		expect.near(rect.Size.Y, 7, 1e-3) -- 9 high overall, minus the 2-stud radius of the round top
		expect.near(rect.Position.Y, 2 + 3.5, 1e-3)
		expect.near(top.Position.Y, 2 + 7, 1e-3)
		expect.equal(top.Shape, Enum.PartType.Cylinder)
		local trim = ctx:window("T", 4, 9, 1, CFrame.new(0, 0, 0), RED, Enum.Material.Concrete)
		expect.equal(trim[1].Material, Enum.Material.Concrete)
		expect.equal(trim[2].Material, Enum.Material.Concrete)
	end)

	t.test("gable is two anchored wedges; dome is a ball plus 6 blocks per rib", function()
		local ctx = newCtx()
		local g = ctx:gable("G", 16, 6, 2, CFrame.new(0, 10, 0), RED, Enum.Material.Concrete)
		expect.equal(#g, 2)
		for _, p in ipairs(g) do
			expect.truthy(p:IsA("WedgePart"))
			expect.equal(p.Anchored, true)
		end
		local d = ctx:dome("D", 8, 5, CFrame.new(0, 0, 0), RED, RED, Enum.Material.Concrete)
		expect.equal(#d, 1 + 5 * 6)
		expect.equal(d[1].Shape, Enum.PartType.Ball)
		expect.near(d[1].Size.X, 16, 1e-3)
	end)

	local archSpec = {
		width = 8, height = 12, depth = 2, wallWidth = 16, wallHeight = 18,
		cframe = CFrame.new(0, 9, 0), color = RED, material = Enum.Material.Concrete,
	}

	t.test("arch cuts the opening with CSG when it is available", function()
		local ctx = newCtx()
		local res = ctx:arch("Arch", archSpec)
		expect.equal(res.path, "csg")
		expect.equal(#res.parts, 1)
		expect.truthy(res.parts[1]:IsA("PartOperation"))
		expect.equal(res.parts[1].Anchored, true)
		expect.equal(ctx:count(), 1) -- the cutter parts are temporary and are not counted
	end)

	t.test("arch falls back to piers, header and wedges when CSG fails", function()
		local ctx = newCtx({ forceCsgFail = true })
		local res = ctx:arch("Arch", archSpec)
		expect.equal(res.path, "fallback")
		expect.truthy(#res.parts >= 3)
		for _, p in ipairs(res.parts) do
			expect.equal(p.Anchored, true)
		end
		expect.equal(ctx:count(), #res.parts)
	end)

	t.test("count and flush: chunks hold at most chunkSize parts", function()
		local ctx, target = newCtx({ chunkSize = 4 })
		for i = 1, 10 do
			ctx:part("P" .. i, Vector3.new(1, 1, 1), CFrame.new(i, 0, 0), RED, Enum.Material.Concrete)
		end
		expect.equal(ctx:count(), 10)
		expect.equal(#target:GetChildren(), 0) -- nothing is parented before flush
		expect.equal(ctx:flush(), 10)
		local chunks = target:GetChildren()
		expect.equal(#chunks, 3)
		local total = 0
		for _, c in ipairs(chunks) do
			local n = partCount(c)
			expect.truthy(n <= 4)
			total += n
		end
		expect.equal(total, 10)
	end)

	t.test("building past the hard budget errors loudly", function()
		local ctx = newCtx({ budget = 3 })
		for i = 1, 3 do
			ctx:part("P" .. i, Vector3.new(1, 1, 1), CFrame.new(i, 0, 0), RED, Enum.Material.Concrete)
		end
		local err = expect.throws(function()
			ctx:part("P4", Vector3.new(1, 1, 1), CFrame.new(4, 0, 0), RED, Enum.Material.Concrete)
		end)
		expect.truthy(string.find(string.lower(tostring(err)), "budget", 1, true))
		expect.equal(ctx:count(), 3)
	end)

	t.test("no CSG scratch folder is left behind, on success or on forced failure", function()
		local ok = newCtx()
		ok:arch("A", archSpec)
		expect.equal(workspace:FindFirstChild("BuildKitScratch"), nil)
		local bad = newCtx({ forceCsgFail = true })
		bad:arch("B", archSpec)
		expect.equal(workspace:FindFirstChild("BuildKitScratch"), nil)
	end)
end
