-- site09_check: the Slice 22 fidelity spec for Site 09 (Tagbakin, Brgy. Halang), written BEFORE the rebuild.
-- Studio copy: ServerStorage.Checks.site09_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.site09_check:Clone())      -- returns JSON {passed, failed, failures}
-- Every number comes from briefs/site09.md "Revision 1 (Slice 22)": Tagbakin_Shoreline_Building_From_Lake.jpg (the generic lakeshore building;
-- never called glamping). The building is built in a local frame (the site is yawed NE), so the checks use part names, sizes, colours and materials.
local HttpService = game:GetService("HttpService")
local SITE_POS = Vector3.new(-600, 0, 550)

local results = { passed = 0, failed = 0, failures = {} }
local function check(name, cond, detail)
	if cond then
		results.passed += 1
	else
		results.failed += 1
		table.insert(results.failures, name .. (detail and (" | " .. detail) or ""))
	end
end

local site = workspace:FindFirstChild("Sites") and workspace.Sites:FindFirstChild("Site09_Tagbakin")
check("Site09_Tagbakin exists", site ~= nil)
if not site then
	return HttpService:JSONEncode(results)
end
do
	local pv = site:GetPivot()
	local s = math.sqrt(0.5)
	check("site pivot is at the SiteData pos (-600, 0, 550), facing NE",
		(pv.Position - SITE_POS).Magnitude < 0.05 and pv.LookVector:Dot(Vector3.new(s, 0, -s)) > 0.999,
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
	for _, name in ipairs({ "LocationMapPanel", "FishingActivity", "Dock", "Bancas" }) do
		check("required prop present: " .. name, site:FindFirstChild(name) ~= nil)
	end
	for _, name in ipairs({ "ShoreBody", "PavilionL", "PavilionR", "CentreDoor", "Terrace" }) do
		check("anchor exists: " .. name, #allNamed(name) == 1)
	end
end

------------------------------------------------------------------ 1: small windows (one ground, one upper per pavilion), like the photo
do
	local win = allNamed("ShoreWindow")
	check("8 lake-facade windows (4 on the pavilions, 4 on the centre bay)", #win == 8, tostring(#win))
	local big = 0
	for _, w in ipairs(win) do if w.Size.X >= 4.9 then big += 1 end end
	check("no window is the old 5-wide pane", big == 0, tostring(big))
end

------------------------------------------------------------------ 2: grey roofs, no metal sheen (it reflected the sky blue)
do
	local metal, offcolour = {}, {}
	for _, name in ipairs({ "ShoreRoofDeck", "PavilionTier1L", "PavilionTier2L", "PavilionRoofL", "PavilionTier1R", "PavilionTier2R", "PavilionRoofR", "EntryCanopy", "RearCanopy" }) do
		for _, p in ipairs(allNamed(name)) do
			if p.Material == Enum.Material.Metal then table.insert(metal, name) end
			local r, g, b = rgb(p)
			if not (math.abs(r - g) <= 8 and math.abs(g - b) <= 8 and r >= 110 and r <= 185) then table.insert(offcolour, name) end
		end
	end
	check("roofs and canopies are not Metal", #metal == 0, table.concat(metal, ","))
	check("roofs and canopies are neutral grey (r 110..185)", #offcolour == 0, table.concat(offcolour, ","))
end

------------------------------------------------------------------ 3: warm sandy yard
do
	local t = allNamed("Terrace")[1]
	if t then
		local r, g, b = rgb(t)
		check("yard is warm sand (r 205..222, g 180..196, b 138..156)", r >= 205 and r <= 222 and g >= 180 and g <= 196 and b >= 138 and b <= 156, string.format("%.0f,%.0f,%.0f", r, g, b))
	end
	local strips = allNamed("PromenadeStrip")
	local cold = 0
	for _, s in ipairs(strips) do local r, _, b = rgb(s); if b > r - 30 then cold += 1 end end
	check("promenade strips are warm too", #strips > 0 and cold == 0, cold .. " cold of " .. #strips)
end

------------------------------------------------------------------ 4: text legibility
do
	local bad = {}
	for _, g in ipairs(site:GetDescendants()) do
		-- Labels inside a Frame are scaled into a bounded box (the map board's layout), which is fine; a long label sitting directly
		-- on the SurfaceGui is the TextScaled bug of Slices 17 to 21.
		if g:IsA("TextLabel") and not isRig(g) and not isKept(g) and not g.Parent:IsA("Frame") then
			local gui = g:FindFirstAncestorOfClass("SurfaceGui")
			local part = gui and gui.Parent
			if gui and part and part:IsA("BasePart") then
				local len = #g.Text
				if g.TextScaled and len > 14 then
					table.insert(bad, part.Name .. ": TextScaled on a " .. len .. "-char line '" .. g.Text:sub(1, 20) .. "'")
				end
			end
		end
	end
	check("no long TextScaled line sits directly on a board", #bad == 0, #bad .. " bad: " .. table.concat(bad, "; ", 1, math.min(#bad, 4)))
	-- The map's 123-character description needs a wide column: at 34% of the board its type was tiny.
	local desc
	for _, g in ipairs(site:GetDescendants()) do
		if g:IsA("TextLabel") and g.Text:sub(1, 16) == "Tagbakin sits on" then desc = g end
	end
	check("map description column is at least 45% of the board wide", desc ~= nil and desc.Size.X.Scale >= 0.45, desc and tostring(desc.Size.X.Scale) or "label missing")
end

------------------------------------------------------------------ Part budget
do
	local n = 0
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") and not isRig(d) and not isKept(d) then n += 1 end
	end
	check("non-rig, non-kept part count is 250..900", n >= 250 and n <= 900, tostring(n))
end

return HttpService:JSONEncode(results)
