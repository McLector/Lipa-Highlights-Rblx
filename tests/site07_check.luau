-- site07_check: the Slice 20 fidelity spec for Site 07 (The Farm at San Benito), written BEFORE the rebuild.
-- Studio copy: ServerStorage.Checks.site07_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.site07_check:Clone())      -- returns JSON {passed, failed, failures}
-- Every number comes from briefs/site07.md "Revision 1 (Slice 20)": Farm_Villa_Pool_Front.jpg (villa + pool) and
-- Farm_Big_Lagoon_and_Pavilion.jpg (pavilion, palms). The builder uses WORLD coordinates for this site, so no shift applies.
local HttpService = game:GetService("HttpService")
local SITE_POS = Vector3.new(700, 0, 240)

local results = { passed = 0, failed = 0, failures = {} }
local function check(name, cond, detail)
	if cond then
		results.passed += 1
	else
		results.failed += 1
		table.insert(results.failures, name .. (detail and (" | " .. detail) or ""))
	end
end

local site = workspace:FindFirstChild("Sites") and workspace.Sites:FindFirstChild("Site07_Farm")
check("Site07_Farm exists", site ~= nil)
if not site then
	return HttpService:JSONEncode(results)
end
do
	local pv = site:GetPivot()
	check("site pivot is at the SiteData pos (700, 0, 240), facing W",
		(pv.Position - SITE_POS).Magnitude < 0.01 and pv.LookVector:Dot(Vector3.new(-1, 0, 0)) > 0.999,
		string.format("(%.2f, %.2f, %.2f) look %s", pv.X, pv.Y, pv.Z, tostring(pv.LookVector)))
end

local function isRig(inst)
	local p = inst
	while p and p ~= site do
		if p:FindFirstChildOfClass("Humanoid") then return true end
		p = p.Parent
	end
	return false
end
local function allNamed(name)
	local list = {}
	for _, d in ipairs(site:GetDescendants()) do
		if d.Name == name and d:IsA("BasePart") and not isRig(d) then table.insert(list, d) end
	end
	return list
end
local function anchor(name) return allNamed(name)[1] end
local function extent(d, axis)
	local cf, sz = d.CFrame, d.Size
	return (math.abs(cf.RightVector[axis]) * sz.X + math.abs(cf.UpVector[axis]) * sz.Y + math.abs(cf.LookVector[axis]) * sz.Z)
end
local function lo(d, axis) return d.Position[axis] - extent(d, axis) / 2 end
local function hi(d, axis) return d.Position[axis] + extent(d, axis) / 2 end
local function fmt(v) return v and string.format("%.2f", v) or "nil" end
local function rgb(p) return p.Color.R * 255, p.Color.G * 255, p.Color.B * 255 end

local KEPT = { Guide = true, InfoPanel = true, JeepStop = true, JeepSignPole = true, JeepSign = true, Jeepney = true }
local function isKept(inst)
	local p = inst
	while p and p ~= site do
		if KEPT[p.Name] and p.Parent == site then return true end
		p = p.Parent
	end
	return false
end

------------------------------------------------------------------ Kept objects, required props, anchors
do
	for name in pairs(KEPT) do check("kept object still present: " .. name, site:FindFirstChild(name) ~= nil) end
	for _, name in ipairs({ "GardenPavilion", "LandscapedPath", "WellnessPanel" }) do
		check("required prop present: " .. name, site:FindFirstChild(name) ~= nil)
	end
	for _, name in ipairs({ "VillaBody", "VillaRoof", "PoolWater", "PavilionDeck", "PathStart", "WellnessBoard" }) do
		check("anchor exists: " .. name, anchor(name) ~= nil)
	end
end

------------------------------------------------------------------ 1-2: dark teal pool, cut-stone wall
do
	local water = anchor("PoolWater")
	if water then
		local r, g, b = rgb(water)
		check("pool water is dark teal (r <= 40, g <= 115, b <= 112)", r <= 40 and g <= 115 and b <= 112, string.format("%.0f,%.0f,%.0f", r, g, b))
		check("pool water stays see-through (transparency <= 0.3)", water.Transparency <= 0.3, fmt(water.Transparency))
	else
		check("pool water exists", false)
	end
	check("pool wall has >= 10 stone-block joints", #allNamed("CopingJoint") >= 10, tostring(#allNamed("CopingJoint")))
end

------------------------------------------------------------------ 3: smooth round thatched cone (12 tiers)
do
	local tiers = allNamed("PavilionThatch")
	table.sort(tiers, function(a, b) return a.Position.Y < b.Position.Y end)
	check("thatched cone has 12 tiers", #tiers == 12, tostring(#tiers))
	local mono, maxd, mind = true, 0, math.huge
	for i, t in ipairs(tiers) do
		local d = math.max(t.Size.Y, t.Size.Z)
		maxd, mind = math.max(maxd, d), math.min(mind, d)
		if i > 1 then
			local prev = math.max(tiers[i - 1].Size.Y, tiers[i - 1].Size.Z)
			if d > prev + 0.01 then mono = false end
		end
	end
	check("cone narrows from the eave (widest >= 17, narrowest <= 2.5)", #tiers > 0 and maxd >= 17 and mind <= 2.5, fmt(maxd) .. " / " .. fmt(mind))
	check("every tier is narrower than the one below", mono)
	local steps = 0
	for i = 2, #tiers do
		local d, prev = math.max(tiers[i].Size.Y, tiers[i].Size.Z), math.max(tiers[i - 1].Size.Y, tiers[i - 1].Size.Z)
		if prev - d > 2.2 then steps += 1 end
	end
	check("no step between tiers is wider than 2.2 studs (smooth profile)", #tiers > 0 and steps == 0, tostring(steps))
	check("a finial caps the cone", anchor("PavilionFinial") ~= nil)
end

------------------------------------------------------------------ 4: tall palms with long drooping fronds
do
	local trunks, fronds = allNamed("PalmTrunk"), allNamed("PalmFrond")
	local byPalm = {}
	for _, t in ipairs(trunks) do
		local key = string.format("%.0f,%.0f", t.Position.X, t.Position.Z)
		byPalm[key] = math.max(byPalm[key] or 0, hi(t, "Y"))
	end
	local palms, tall = 0, 0
	for _, h in pairs(byPalm) do palms += 1; if h >= 15.5 then tall += 1 end end
	check("19 palms", palms == 19, tostring(palms))
	check("every palm is at least 15.5 tall", palms > 0 and tall == palms, tall .. "/" .. palms)
	check("8 fronds per palm (152)", #fronds == 152, tostring(#fronds))
	local long = 0
	for _, f in ipairs(fronds) do if math.max(f.Size.X, f.Size.Z) >= 8.5 then long += 1 end end
	check("fronds are at least 8.5 long", #fronds > 0 and long == #fronds, long .. "/" .. #fronds)
	local collide = 0
	for _, f in ipairs(fronds) do if f.CanCollide then collide += 1 end end
	check("fronds do not collide", collide == 0, tostring(collide))
end

------------------------------------------------------------------ 5: timber posts frame the wing screens
do
	local posts = allNamed("WingPost")
	check("wings have 6 timber posts", #posts == 6, tostring(#posts))
	local bad = 0
	for _, p in ipairs(posts) do if hi(p, "Y") < 10 or lo(p, "X") > 765 then bad += 1 end end
	check("posts stand ground to eave on the screen line", #posts > 0 and bad == 0, tostring(bad))
end

------------------------------------------------------------------ 6: text legibility
do
	local bad = {}
	for _, g in ipairs(site:GetDescendants()) do
		if g:IsA("TextLabel") and not isRig(g) and not isKept(g) then
			local gui = g:FindFirstAncestorOfClass("SurfaceGui")
			local part = gui and gui.Parent
			if gui and part and part:IsA("BasePart") then
				local len = #g.Text
				if g.TextScaled and len > 14 then
					table.insert(bad, part.Name .. ": TextScaled on a " .. len .. "-char line")
				elseif not g.TextScaled and gui.SizingMode == Enum.SurfaceGuiSizingMode.PixelsPerStud then
					local face = gui.Face
					local wStuds, hStuds
					if face == Enum.NormalId.Back or face == Enum.NormalId.Front then wStuds, hStuds = part.Size.X, part.Size.Y
					elseif face == Enum.NormalId.Left or face == Enum.NormalId.Right then wStuds, hStuds = part.Size.Z, part.Size.Y
					else wStuds, hStuds = part.Size.X, part.Size.Z end
					local wPx, hPx = wStuds * gui.PixelsPerStud * g.Size.X.Scale, hStuds * gui.PixelsPerStud * g.Size.Y.Scale
					local textPx = len * g.TextSize * 0.6
					local lines = g.TextWrapped and math.ceil(textPx / math.max(wPx, 1)) or 1
					if (not g.TextWrapped and textPx > wPx) or lines * g.TextSize * 1.2 > hPx then
						table.insert(bad, string.format("%s: '%s' needs %.0fx%.0f px, has %.0fx%.0f", part.Name, g.Text, textPx, lines * g.TextSize * 1.2, wPx, hPx))
					end
				end
			end
		end
	end
	check("every label is fixed-size and fits its part (no long TextScaled line)", #bad == 0, #bad .. " bad: " .. table.concat(bad, "; ", 1, math.min(#bad, 4)))
end

------------------------------------------------------------------ Part budget
do
	local n = 0
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") and not isRig(d) and not isKept(d) then n += 1 end
	end
	check("non-rig, non-kept part count is 600..1500", n >= 600 and n <= 1500, tostring(n))
end

return HttpService:JSONEncode(results)
