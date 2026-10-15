-- BuildKit: shared helpers for the site builders (Slice 02). Load with require(module:Clone()).
--   local ctx = BuildKit.new(target, origin, opts?)
--     target  Model that flush() parents the chunk models into
--     origin  CFrame that every local CFrame is multiplied by
--     opts    { budget = parts allowed from this ctx (default unlimited), chunkSize = 400, forceCsgFail = false }
-- Everything is built into unparented chunk Models (<= chunkSize parts each) and only reaches the DataModel in
-- flush(), one chunk at a time with task.wait() between them. That keeps each .Parent write small (Studio freezes
-- and the MCP drops if one giant model is parented at once).
-- Every part is anchored with smooth surfaces. Parts are placed via local CFrames: world = origin * localCF.
-- Orientation notes (verified by probe, 2026-10-15): a WedgePart's slope falls toward -Z, so its right angle sits
-- at +Z bottom; a Cylinder part's axis is its local X.
local BuildKit = {}
BuildKit.__index = BuildKit

local SCRATCH_NAME = "BuildKitScratch"
local SMOOTH = Enum.SurfaceType.Smooth

function BuildKit.new(target, origin, opts)
	opts = opts or {}
	return setmetatable({
		_target = target,
		_origin = origin or CFrame.new(),
		_budget = opts.budget or math.huge,
		_chunkSize = opts.chunkSize or 400,
		_forceCsgFail = opts.forceCsgFail == true,
		_parts = {},
		_chunks = {},
		_inChunk = 0,
		_chunkSerial = 0,
		_count = 0,
	}, BuildKit)
end

function BuildKit:count()
	return self._count
end

function BuildKit:parts()
	return self._parts
end

function BuildKit:_reserve(n)
	if self._count + n > self._budget then
		error(string.format("BuildKit: part budget of %d exceeded (%d built, %d more requested)", self._budget, self._count, n), 3)
	end
end

-- Holds an already-styled part (world CFrame) in the current chunk. Callers must have reserved budget.
function BuildKit:_place(p)
	local chunk = self._chunks[#self._chunks]
	if chunk == nil or self._inChunk >= self._chunkSize then
		self._chunkSerial += 1
		chunk = Instance.new("Model")
		chunk.Name = "Chunk" .. self._chunkSerial
		table.insert(self._chunks, chunk)
		self._inChunk = 0
	end
	p.Parent = chunk
	self._inChunk += 1
	self._count += 1
	table.insert(self._parts, p)
	return p
end

local function style(p, name, size, color, material)
	p.Name = name
	p.Size = size
	p.Anchored = true
	p.TopSurface, p.BottomSurface, p.LeftSurface = SMOOTH, SMOOTH, SMOOTH
	p.RightSurface, p.FrontSurface, p.BackSurface = SMOOTH, SMOOTH, SMOOTH
	if color then p.Color = color end
	if material then p.Material = material end
	return p
end

function BuildKit:_make(className, name, size, localCF, color, material, shape)
	self:_reserve(1)
	local p = Instance.new(className)
	if shape then p.Shape = shape end
	style(p, name, size, color, material)
	p.CFrame = self._origin * localCF
	return self:_place(p)
end

function BuildKit:part(name, size, localCF, color, material)
	return self:_make("Part", name, size, localCF, color, material)
end

function BuildKit:wedge(name, size, localCF, color, material)
	return self:_make("WedgePart", name, size, localCF, color, material)
end

-- Raw cylinder part: size = (length along the axis, diameter, diameter); the axis is local X.
function BuildKit:cyl(name, size, localCF, color, material)
	return self:_make("Part", name, size, localCF, color, material, Enum.PartType.Cylinder)
end

function BuildKit:ball(name, diameter, localCF, color, material)
	return self:_make("Part", name, Vector3.new(diameter, diameter, diameter), localCF, color, material, Enum.PartType.Ball)
end

-- fn(i, pos) for i = 1..n at startPos + step * (i - 1). n must be a non-negative integer.
function BuildKit:repeatAlong(n, startPos, step, fn)
	if type(n) ~= "number" or n < 0 or n ~= math.floor(n) then
		error("BuildKit.repeatAlong: n must be a non-negative integer, got " .. tostring(n), 2)
	end
	for i = 1, n do
		fn(i, startPos + step * (i - 1))
	end
end

-- Eight wall segments around the local Y axis. `radius` is the distance from the axis to each segment's
-- centre; segments are 45 degrees apart and tile edge to edge. `centreCF` (optional) moves the axis; the ring's
-- faces then still point along the local axes of centreCF (flat faces toward +X/-X/+Z/-Z).
function BuildKit:octagonRing(name, radius, height, baseY, thickness, color, material, centreCF)
	local side = 2 * radius * math.tan(math.pi / 8)
	local base = centreCF or CFrame.new()
	local ring = {}
	for k = 1, 8 do
		local theta = (k - 1) * math.pi / 4
		local pos = Vector3.new(radius * math.cos(theta), baseY + height / 2, radius * math.sin(theta))
		local cf = base * CFrame.lookAt(pos, Vector3.new(0, pos.Y, 0))
		table.insert(ring, self:part(name .. k, Vector3.new(side, height, thickness), cf, color, material))
	end
	return ring
end

-- A wall with an arched opening whose bottom sits on the wall's bottom edge.
-- spec = { width, height (opening incl. the round top), depth, wallWidth, wallHeight, cframe (wall centre),
--          color, material }. Returns { path = "csg" | "fallback", parts = {...} }.
function BuildKit:arch(name, spec)
	local w, h, d = spec.width, spec.height, spec.depth
	local wallW, wallH = spec.wallWidth, spec.wallHeight
	local yBottom = -wallH / 2
	local yRect = yBottom + h - w / 2 -- where the straight sides end and the round top begins
	local wallCF = self._origin * spec.cframe

	-- CSG path: cut a rectangle and a cylinder out of a wall slab inside a scratch folder under Workspace.
	self:_reserve(1)
	local scratch = Instance.new("Folder")
	scratch.Name = SCRATCH_NAME
	scratch.Parent = workspace
	local ok, result = pcall(function()
		local wall = Instance.new("Part")
		style(wall, name, Vector3.new(wallW, wallH, d), spec.color, spec.material)
		wall.CFrame = wallCF
		wall.Parent = scratch
		local cut1 = Instance.new("Part")
		style(cut1, "CutRect", Vector3.new(w, yRect - yBottom + 0.02, d + 0.4), nil, nil)
		cut1.CFrame = wallCF * CFrame.new(0, (yBottom + yRect) / 2 - 0.01, 0)
		cut1.Parent = scratch
		local cut2 = Instance.new("Part")
		style(cut2, "CutRound", Vector3.new(d + 0.4, w, w), nil, nil)
		cut2.Shape = Enum.PartType.Cylinder
		cut2.CFrame = wallCF * CFrame.new(0, yRect, 0) * CFrame.Angles(0, math.pi / 2, 0)
		cut2.Parent = scratch
		if self._forceCsgFail then
			error("forced CSG failure")
		end
		return wall:SubtractAsync({ cut1, cut2 })
	end)
	pcall(function() scratch:Destroy() end)

	if ok and result then
		result.Name = name
		result.Anchored = true
		result.UsePartColor = true
		if spec.color then result.Color = spec.color end
		if spec.material then result.Material = spec.material end
		self:_place(result)
		return { path = "csg", parts = { result } }
	end

	-- Fallback: two piers, a header block over the opening, and two wedges that turn the top corners of the
	-- opening into a pointed arch. 5 parts.
	local parts = {}
	local pierW = (wallW - w) / 2
	local yTop = yRect + w / 2
	local function at(x, y)
		return spec.cframe * CFrame.new(x, y, 0)
	end
	table.insert(parts, self:part(name .. "_PierL", Vector3.new(pierW, wallH, d), at(-(w / 2 + pierW / 2), 0), spec.color, spec.material))
	table.insert(parts, self:part(name .. "_PierR", Vector3.new(pierW, wallH, d), at(w / 2 + pierW / 2, 0), spec.color, spec.material))
	local headerH = wallH / 2 - yTop
	if headerH > 0 then
		table.insert(parts, self:part(name .. "_Header", Vector3.new(w, headerH, d), at(0, yTop + headerH / 2), spec.color, spec.material))
	end
	local legs = Vector3.new(d, w / 2, w / 2)
	-- Right angle at the top outer corner of each triangle; hypotenuse rising toward the centre line.
	local left = spec.cframe * CFrame.fromMatrix(Vector3.new(-w / 4, yRect + w / 4, 0), Vector3.new(0, 0, -1), Vector3.new(0, -1, 0), Vector3.new(-1, 0, 0))
	local right = spec.cframe * CFrame.fromMatrix(Vector3.new(w / 4, yRect + w / 4, 0), Vector3.new(0, 0, 1), Vector3.new(0, -1, 0), Vector3.new(1, 0, 0))
	table.insert(parts, self:wedge(name .. "_SpandrelL", legs, left, spec.color, spec.material))
	table.insert(parts, self:wedge(name .. "_SpandrelR", legs, right, spec.color, spec.material))
	return { path = "fallback", parts = parts }
end

-- Triangular pediment, apex up, built from two wedges. Returns { left, right }.
function BuildKit:gable(name, width, height, depth, localCF, color, material)
	local legs = Vector3.new(depth, height, width / 2)
	local left = localCF * CFrame.fromMatrix(Vector3.new(-width / 4, height / 2, 0), Vector3.new(0, 0, -1), Vector3.new(0, 1, 0), Vector3.new(1, 0, 0))
	local right = localCF * CFrame.fromMatrix(Vector3.new(width / 4, height / 2, 0), Vector3.new(0, 0, 1), Vector3.new(0, 1, 0), Vector3.new(-1, 0, 0))
	return {
		self:wedge(name .. "L", legs, left, color, material),
		self:wedge(name .. "R", legs, right, color, material),
	}
end

-- A ribbed dome: a ball centred on the local origin (its lower half is meant to be hidden inside the drum) plus
-- `ribs` meridian strips made of short blocks lying just outside the surface. Returns every part created.
function BuildKit:dome(name, radius, ribs, localCF, color, ribColor, material)
	local made = { self:ball(name, radius * 2, localCF, color, material) }
	local steps = 6
	local t0, t1 = math.rad(8), math.rad(86)
	local dTheta = (t1 - t0) / steps
	local rr = radius + 0.25
	for k = 1, ribs do
		local phi = (k - 1) * 2 * math.pi / ribs
		for j = 1, steps do
			local theta = t0 + (j - 0.5) * dTheta
			local out = Vector3.new(math.sin(theta) * math.cos(phi), math.cos(theta), math.sin(theta) * math.sin(phi))
			local along = Vector3.new(math.cos(theta) * math.cos(phi), -math.sin(theta), math.cos(theta) * math.sin(phi))
			local xVec = along:Cross(out)
			local cf = localCF * CFrame.fromMatrix(out * rr, xVec, along, out)
			local seg = rr * dTheta * 1.15
			table.insert(made, self:part(name .. "_Rib" .. k .. "_" .. j, Vector3.new(radius * 0.18, seg, 0.5), cf, ribColor, material))
		end
	end
	return made
end

-- An arched window: a rectangle with a round top, standing on localCF (bottom centre). Glass by default; pass a
-- material to use the same shape as a surround or relief. Returns { rect, top }.
function BuildKit:window(name, width, height, depth, localCF, color, material)
	material = material or Enum.Material.Glass
	local rectH = height - width / 2
	local rect = self:part(name .. "_Pane", Vector3.new(width, rectH, depth), localCF * CFrame.new(0, rectH / 2, 0), color, material)
	local top = self:cyl(name .. "_Top", Vector3.new(depth, width, width), localCF * CFrame.new(0, rectH, 0) * CFrame.Angles(0, math.pi / 2, 0), color, material)
	return { rect, top }
end

-- Parents the held chunks into the target, one chunk per task.wait(). Returns the number of parts parented.
function BuildKit:flush()
	local total = 0
	for _, chunk in ipairs(self._chunks) do
		total += #chunk:GetChildren()
		chunk.Parent = self._target
		task.wait()
	end
	self._chunks = {}
	self._inChunk = 0
	return total
end

return BuildKit
