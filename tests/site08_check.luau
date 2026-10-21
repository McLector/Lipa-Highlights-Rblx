-- site08_check: the Slice 21 fidelity spec for Site 08 (Mount Malarayat Golf & Country Club), written BEFORE the rebuild.
-- Studio copy: ServerStorage.Checks.site08_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.site08_check:Clone())      -- returns JSON {passed, failed, failures}
-- Every number comes from briefs/site08.md "Revision 1 (Slice 21)": Malarayat_Clubhouse_Aerial.jpg, the cart-side exterior photo and the
-- across-lake photo. The clubhouse is built in a local frame, so the checks use part names, counts, colours and sizes rather than coordinates.
local HttpService = game:GetService("HttpService")
local SITE_POS = Vector3.new(560, 19.8, 720)

local results = { passed = 0, failed = 0, failures = {} }
local function check(name, cond, detail)
	if cond then
		results.passed += 1
	else
		results.failed += 1
		table.insert(results.failures, name .. (detail and (" | " .. detail) or ""))
	end
end

local site = workspace:FindFirstChild("Sites") and workspace.Sites:FindFirstChild("Site08_Malarayat")
check("Site08_Malarayat exists", site ~= nil)
if not site then
	return HttpService:JSONEncode(results)
end
do
	local pv = site:GetPivot()
	local s = math.sqrt(0.5)
	check("site pivot is at the SiteData pos (560, 19.8, 720), facing NW",
		(pv.Position - SITE_POS).Magnitude < 0.05 and pv.LookVector:Dot(Vector3.new(-s, 0, -s)) > 0.999,
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
local function extent(d, axis)
	local cf, sz = d.CFrame, d.Size
	return (math.abs(cf.RightVector[axis]) * sz.X + math.abs(cf.UpVector[axis]) * sz.Y + math.abs(cf.LookVector[axis]) * sz.Z)
end
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

------------------------------------------------------------------ Kept objects and required props
do
	for name in pairs(KEPT) do check("kept object still present: " .. name, site:FindFirstChild(name) ~= nil) end
	for _, name in ipairs({ "Clubhouse", "MountainBackdrop", "LeisureSpacesPanel" }) do
		check("required prop present: " .. name, site:FindFirstChild(name) ~= nil)
	end
	for _, name in ipairs({ "ClubhouseRoofMain", "ClubhouseEntryGable", "PorteCochere" }) do
		check("anchor exists: " .. name, #allNamed(name) == 1)
	end
end

------------------------------------------------------------------ 1: bright terracotta roof
do
	local tiers = {}
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") and d.Name:sub(1, 8) == "RoofTier" then table.insert(tiers, d) end
	end
	local bad = 0
	for _, p in ipairs(tiers) do
		local r, g, b = rgb(p)
		if not (r >= 190 and r <= 212 and g >= 76 and g <= 95 and b >= 44 and b <= 60) then bad += 1 end
	end
	check("main roof tiers are bright terracotta (about 200,84,52)", #tiers == 5 and bad == 0, #tiers .. " tiers, " .. bad .. " off colour")
	local cap = allNamed("ClubhouseRoofMain")[1]
	if cap then
		local r, g, b = rgb(cap)
		check("ridge cap is a darker terracotta (r 150..185)", r >= 150 and r <= 185 and g <= 75, string.format("%.0f,%.0f,%.0f", r, g, b))
	end
end

------------------------------------------------------------------ 2-3: mint window surrounds and cut-stone courses
do
	local trim = allNamed("WindowTrim")
	check("ground-floor windows have 24 mint trim strips", #trim == 24, tostring(#trim))
	local notMint = 0
	for _, p in ipairs(trim) do
		local r, g, b = rgb(p)
		if not (g > r and g > b - 10 and g >= 180) then notMint += 1 end
	end
	check("trim is mint green", #trim > 0 and notMint == 0, notMint .. " off colour")
	check("cladding has 4 stone courses", #allNamed("StoneCourse") == 4, tostring(#allNamed("StoneCourse")))
end

------------------------------------------------------------------ 4: three rows of carts
do
	local carts = allNamed("CartBody")
	check("12 golf carts on the forecourt", #carts == 12, tostring(#carts))
end

------------------------------------------------------------------ 5: tall slender Norfolk pines
do
	local trunks, tiers = allNamed("PineTrunk"), allNamed("PineTier")
	check("16 pines", #trunks == 16, tostring(#trunks))
	local short = 0
	for _, t in ipairs(trunks) do if extent(t, "Y") < 33 then short += 1 end end
	check("every pine trunk is at least 33 tall", #trunks > 0 and short == 0, short .. " short")
	check("each pine has 8 tiers (128)", #tiers == 128, tostring(#tiers))
	local wide = 0
	for _, t in ipairs(tiers) do if math.max(t.Size.Y, t.Size.Z) > 9.6 then wide += 1 end end
	check("pine tiers are slender (widest <= 9.6)", #tiers > 0 and wide == 0, tostring(wide))
end

------------------------------------------------------------------ 6: tall palms with long fronds
do
	local fronds, trunks = allNamed("PalmFrond"), allNamed("PalmTrunk")
	local byPalm = {}
	for _, t in ipairs(trunks) do
		local key = string.format("%.0f,%.0f", t.Position.X, t.Position.Z)
		byPalm[key] = (byPalm[key] or 0) + extent(t, "Y")
	end
	local palms, short = 0, 0
	for _, h in pairs(byPalm) do palms += 1; if h < 17.5 then short += 1 end end
	check("palms are at least 17.5 tall", palms > 0 and short == 0, short .. " short of " .. palms)
	check("8 long fronds per palm", palms > 0 and #fronds == palms * 8, #fronds .. " fronds, " .. palms .. " palms")
	local small = 0
	for _, f in ipairs(fronds) do if math.max(f.Size.X, f.Size.Z) < 8.5 then small += 1 end end
	check("fronds are at least 8.5 long", #fronds > 0 and small == 0, tostring(small))
end

------------------------------------------------------------------ 7: text legibility
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
	check("non-rig, non-kept part count is 560..1800", n >= 560 and n <= 1800, tostring(n))
end

return HttpService:JSONEncode(results)
