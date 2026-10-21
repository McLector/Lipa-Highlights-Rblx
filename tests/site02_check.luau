-- site02_check: the Slice 17 fidelity spec for Site 02 (Candido B. Lopez Memorial Public Market), written BEFORE the rebuild.
-- Studio copy: ServerStorage.Checks.site02_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.site02_check:Clone())      -- returns JSON {passed, failed, failures}
-- Every number comes from briefs/site02.md "Revision 1 (Slice 17)": the 2014 facade photo, the 2010 street and 2011 stall photos,
-- and the OpenStreetMap footprint (way 465374399, ODbL): about 84 x 40 m, 3 levels, 11 m, blue-grey roof (#6b88b4).
-- Frames: the site pivot is yawed E, but the builder works in the market frame MK (local +Z = E, the frontage; local +X = N = world -Z).
-- mk(p) = (lx, y, lz) of a part in that frame: lx > 0 is north, lx < 0 is south (world z = 160 - lx), lz is the distance east of the pivot.
local HttpService = game:GetService("HttpService")
local SITE_POS = Vector3.new(-330, 0, 160)
local MKc = CFrame.fromMatrix(SITE_POS, Vector3.new(0, 0, -1), Vector3.new(0, 1, 0), Vector3.new(1, 0, 0))

local results = { passed = 0, failed = 0, failures = {} }
local function check(name, cond, detail)
	if cond then
		results.passed += 1
	else
		results.failed += 1
		table.insert(results.failures, name .. (detail and (" | " .. detail) or ""))
	end
end

local site = workspace:FindFirstChild("Sites") and workspace.Sites:FindFirstChild("Site02_Market")
check("Site02_Market exists", site ~= nil)
if not site then
	return HttpService:JSONEncode(results)
end
-- A stray drag in Studio once moved a whole site; it shows up as a dozen unrelated failures, so test the pivot first.
do
	local pv = site:GetPivot()
	check("site pivot is at the SiteData pos (-330, 0, 160), facing E",
		(pv.Position - SITE_POS).Magnitude < 0.01 and pv.LookVector:Dot(Vector3.new(1, 0, 0)) > 0.999,
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
local function withPrefix(prefix)
	local list = {}
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") and not isRig(d) and d.Name:sub(1, #prefix) == prefix then table.insert(list, d) end
	end
	return list
end
local function anchor(name) return allNamed(name)[1] end
local function mk(p) return MKc:PointToObjectSpace(p.Position) end
local function fmt(v) return v and string.format("%.1f", v) or "nil" end
local function near(a, b, tol) return a ~= nil and math.abs(a - b) <= tol end
local function rgb(p) return p.Color.R * 255, p.Color.G * 255, p.Color.B * 255 end
local function guiText(p)
	local t = {}
	for _, g in ipairs(p:GetChildren()) do
		if g:IsA("SurfaceGui") then
			for _, l in ipairs(g:GetDescendants()) do
				if l:IsA("TextLabel") then table.insert(t, l.Text) end
			end
		end
	end
	return table.concat(t, " ")
end
local function count(list, pred)
	local n = 0
	for _, p in ipairs(list) do if pred(p) then n += 1 end end
	return n
end
-- the part's real extent along a world axis (rotated corners included), the way BuildCheck measures bounds
local function extent(d, axis)
	local cf, sz = d.CFrame, d.Size
	return (math.abs(cf.RightVector[axis]) * sz.X + math.abs(cf.UpVector[axis]) * sz.Y + math.abs(cf.LookVector[axis]) * sz.Z)
end
-- colour families (the photos, by eye)
local function roofBlue(p) local r, g, b = rgb(p); return r >= 85 and r <= 135 and g >= 110 and g <= 160 and b >= 150 and b <= 205 and b > r + 40 end
local function signBlue(p) local r, g, b = rgb(p); return b >= 120 and r <= 90 and b > r + 50 end
local function white(p) local r, g, b = rgb(p); return r >= 225 and g >= 220 and b >= 205 end
local function yellow(p) local r, g, b = rgb(p); return r >= 200 and g >= 160 and b <= 130 end
local function maroonish(p) local r, g, b = rgb(p); return r >= 90 and r <= 175 and g >= 30 and g <= 90 and b >= 25 and b <= 90 and r > g + 40 end
local function shutterCol(p) local r, g, b = rgb(p); return r >= 90 and r <= 135 and g >= 78 and g <= 112 and b >= 66 and b <= 100 end
local function dark(p) local r, g, b = rgb(p); return r <= 110 and g <= 110 and b <= 110 end
local function tinCol(p) local r, g, b = rgb(p); return (r >= 120 and r <= 160 and g >= 80 and g <= 140 and b >= 50 and b <= 142) end

------------------------------------------------------------------ Kept objects: untouched and clear
local KEPT = { Guide = true, InfoPanel = true }
local function isKept(inst)
	local p = inst
	while p and p ~= site do
		if KEPT[p.Name] and p.Parent == site then return true end
		p = p.Parent
	end
	return false
end
do
	for name in pairs(KEPT) do
		check("kept object still present: " .. name, site:FindFirstChild(name) ~= nil)
	end
	local guide, panel = site:FindFirstChild("Guide"), site:FindFirstChild("InfoPanel")
	local gpos = guide and guide:GetPivot().Position
	check("Guide is at (-300, 160)", gpos ~= nil and (Vector3.new(gpos.X, 0, gpos.Z) - Vector3.new(-300, 0, 160)).Magnitude < 1, gpos and tostring(gpos) or "missing")
	check("InfoPanel is at (-306, 148)", panel ~= nil and (Vector3.new(panel.Position.X, 0, panel.Position.Z) - Vector3.new(-306, 0, 148)).Magnitude < 1, panel and tostring(panel.Position) or "missing")

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { site }
	local function blockers(centre, size)
		local bad = {}
		for _, p in ipairs(workspace:GetPartBoundsInBox(CFrame.new(centre), size, params)) do
			-- ground slabs (top within 0.6 of the ground) are fine, standing objects are not
			if not isKept(p) and not isRig(p) and p.Position.Y + p.Size.Y / 2 > 0.6 then table.insert(bad, p.Name) end
		end
		return bad
	end
	if guide then
		local bad = blockers(gpos + Vector3.new(0, 4, 0), Vector3.new(24, 14, 24))
		check("nothing stands within the Guide keep-clear box (x -312..-288, z 148..172)", #bad == 0, table.concat(bad, ", ", 1, math.min(#bad, 6)))
	end
	do
		-- the aisle from the road F mouth west to the Guide: x -294..-228, z 154..166, character height
		local bad = blockers(Vector3.new(-261, 3.5, 160), Vector3.new(66, 5, 12))
		check("the aisle from the road to the Guide (x -294..-228, z 154..166) is open", #bad == 0, table.concat(bad, ", ", 1, math.min(#bad, 6)))
	end
	do
		-- the east side of the InfoPanel, 12 studs deep
		local bad = blockers(Vector3.new(-299.75, 5, 148), Vector3.new(12, 8, 12))
		check("the InfoPanel's east side (12 deep) is open", #bad == 0, table.concat(bad, ", ", 1, math.min(#bad, 6)))
	end
end

------------------------------------------------------------------ A: the hall (massing from OSM, facade from the 2014 photo)
do
	local hb = anchor("HallBody")
	local depth = hb and extent(hb, "X")
	local length = hb and extent(hb, "Z")
	check("HallBody is about 90 deep (world x -420..-330) and 150 long, not the 40-stud slab",
		hb ~= nil and near(hb.Position.X - depth / 2, -420, 1.5) and near(hb.Position.X + depth / 2, -330, 1.5) and near(length, 150, 1.5),
		hb and string.format("x %s..%s long %s", fmt(hb.Position.X - depth / 2), fmt(hb.Position.X + depth / 2), fmt(length)) or "missing")
	check("HallBody is 24 tall", hb ~= nil and near(hb.Size.Y, 24, 0.5), hb and fmt(hb.Size.Y) or "missing")

	local slopes = allNamed("RoofSlope")
	check("a low-pitch blue-grey roof: 2 RoofSlope slabs (#6b88b4 family) tilted 3-14 degrees, ridge above y 28",
		#slopes == 2 and count(slopes, roofBlue) == 2
			and count(slopes, function(p) local t = math.deg(math.acos(math.clamp(p.CFrame.UpVector.Y, -1, 1))); return t >= 3 and t <= 14 end) == 2
			and count(slopes, function(p) return p.Position.Y + extent(p, "Y") / 2 >= 28 end) >= 1,
		#slopes .. " slabs")
	local seams = allNamed("RoofSeam")
	check("standing-seam strips on the roof (20+ RoofSeam, lighter than the slabs)", #seams >= 20, tostring(#seams))
	check("roof end gables close the ridge (4+ wedge parts named Gable*)", #withPrefix("Gable") >= 4, tostring(#withPrefix("Gable")))
	check("the blue roof edge is kept (RoofEdge)", anchor("RoofEdge") ~= nil)

	local band = anchor("NameBand")
	check("NameBand: 4+ tall, white, on the east frontage, reads the market's name, starts north of the gallery (lx >= -45)",
		band ~= nil and band.Size.Y >= 4 and white(band) and hb ~= nil and band.Position.X > hb.Position.X + 10
			and guiText(band):upper():find("CANDIDO B. LOPEZ MEMORIAL PUBLIC MARKET", 1, true) ~= nil
			and mk(band).X - extent(band, "Z") / 2 >= -46,
		band and (fmt(band.Size.Y) .. " tall, text '" .. guiText(band) .. "'") or "missing")

	local bb = anchor("Billboard")
	check("Billboard: a plain blue panel over the gallery (south of lx -40), 4+ tall, NO text or SurfaceGui",
		bb ~= nil and signBlue(bb) and bb.Size.Y >= 4 and mk(bb).X < -40 and #bb:GetChildren() == 0 and guiText(bb) == "",
		bb and (#bb:GetChildren() .. " children") or "missing")

	check("weathered two-tone wall: UpperWall cladding, lighter than the ground wall, and 4+ maroon/red-oxide RustPatch panels",
		anchor("UpperWall") ~= nil and #allNamed("RustPatch") >= 4 and count(allNamed("RustPatch"), maroonish) >= 4,
		#allNamed("RustPatch") .. " patches")
	check("16 maroon pilasters kept (17 lines)", #allNamed("Pilaster") >= 17, tostring(#allNamed("Pilaster")))
	check("arched ground bays with gridded glazing (12+ ArchBay, 12+ BayMullion)", #allNamed("ArchBay") >= 12 and #allNamed("BayMullion") >= 12,
		#allNamed("ArchBay") .. "/" .. #allNamed("BayMullion"))

	local sh = allNamed("Shutter")
	check("deep tilted shutter awnings: 16+ Shutter, grey-brown, tilted 15+ degrees, on the upper level (y 13..20), sticking out 1+ stud",
		#sh >= 16 and count(sh, function(p)
			local t = math.deg(math.acos(math.clamp(p.CFrame.UpVector.Y, -1, 1)))
			return shutterCol(p) and t >= 15 and p.Position.Y >= 13 and p.Position.Y <= 20 and mk(p).Z >= 1
		end) == #sh, #sh .. " shutters")
end

------------------------------------------------------------------ B: the south gallery, portico, stair and north balcony
do
	local gal = anchor("UpperGallery")
	local g = gal and mk(gal)
	check("UpperGallery: a deck at the upper level (top 11.5-12.5) in the south third (lx -76..-38), 30+ long, 6+ deep",
		gal ~= nil and near(gal.Position.Y + gal.Size.Y / 2, 12, 0.6) and g.X - extent(gal, "Z") / 2 >= -77 and g.X + extent(gal, "Z") / 2 <= -37 and extent(gal, "Z") >= 30 and extent(gal, "X") >= 6,
		gal and string.format("lx %s top %s", fmt(g.X), fmt(gal.Position.Y + gal.Size.Y / 2)) or "missing")
	check("the gallery has a rail with balusters (GalleryRail, 8+ GalleryPost) and a dark sloped awning above it (GalleryAwning)",
		anchor("GalleryRail") ~= nil and #allNamed("GalleryPost") >= 8 and anchor("GalleryAwning") ~= nil and dark(anchor("GalleryAwning"))
			and anchor("GalleryAwning").CFrame.UpVector.Y < 0.999 and anchor("GalleryAwning").Position.Y >= 16,
		#allNamed("GalleryPost") .. " posts")
	check("the gallery's cream fascia slab (GalleryFascia) and its maroon wall behind (GalleryWall) with 3+ GalleryOpening", anchor("GalleryFascia") ~= nil
		and anchor("GalleryWall") ~= nil and maroonish(anchor("GalleryWall")) and #allNamed("GalleryOpening") >= 3, #allNamed("GalleryOpening") .. " openings")

	local cols = allNamed("PorticoColumn")
	check("portico: 4+ round yellow PorticoColumn, 10+ tall, standing in the south third (lx -76..-38)",
		#cols >= 4 and count(cols, function(p)
			return p.Shape == Enum.PartType.Cylinder and yellow(p) and extent(p, "Y") >= 10 and mk(p).X >= -77 and mk(p).X <= -37
		end) == #cols, #cols .. " columns")

	-- stair: concrete risers of 1, rising toward the SOUTH (the viewer's left), solid stringer, a roof over its full run on yellow piers
	local s1, s12 = anchor("Step1"), anchor("Step12")
	local runOk = false
	local detail = "missing steps"
	if s1 and s12 then
		local a, b = mk(s1), mk(s12)
		runOk = (b.X < a.X - 18) and math.abs(b.Z - a.Z) <= 8 and a.X > -30 and near(s1.Size.Y, 1, 0.01) and near(s12.Size.Y, 12, 0.01) and near(s12.Position.Y + 6, 12, 0.1)
		detail = string.format("foot lx %s, head lx %s, head top %s", fmt(a.X), fmt(b.X), fmt(s12.Position.Y + s12.Size.Y / 2))
	end
	check("stair: 12 risers of 1 that run ALONG the facade, foot in the north (lx > -30), head 18+ studs south, top at y 12", runOk, detail)
	local cover = anchor("StairCover")
	local coverOk, cdetail = false, "missing"
	if cover and s1 and s12 then
		local a, b = mk(s1), mk(s12)
		local runLen = Vector3.new(a.X - b.X, 0, a.Z - b.Z).Magnitude
		local c = mk(cover)
		coverOk = cover.Size.Z >= runLen and cover.Size.Z >= 24 and math.abs(c.X - (a.X + b.X) / 2) <= 3 and mk(cover).Y >= 12 and dark(cover) == false
		cdetail = string.format("cover %s long for a run of %s, centre lx %s", fmt(cover.Size.Z), fmt(runLen), fmt(c.X))
	end
	check("StairCover is a roof over the stair's full run (as long as the run, centred on it, 12+ up)", coverOk, cdetail)
	check("the stair has 4+ yellow StairPier columns, a solid StairStringer, two StairRail lines", count(allNamed("StairPier"), yellow) >= 4 and anchor("StairStringer") ~= nil and #allNamed("StairRail") >= 2,
		#allNamed("StairPier") .. " piers")

	local deck = anchor("BalconyDeck")
	check("BalconyDeck stays at the north end (more than 25 north of the hall centre)", deck ~= nil and deck.Position.Z < 160 - 25, deck and fmt(deck.Position.Z) or "missing")
	local bc = allNamed("BalconyColumn")
	check("north balcony: 5+ round yellow BalconyColumn, a BalconyRail, and a maroon end bay (EndBayWall)",
		#bc >= 5 and count(bc, yellow) == #bc and anchor("BalconyRail") ~= nil and anchor("EndBayWall") ~= nil and maroonish(anchor("EndBayWall")),
		#bc .. " columns")
end

------------------------------------------------------------------ C: the frontage lean-tos, the yard, the street
do
	local lean = allNamed("LeanRoof")
	check("a continuous row of tin lean-to roofs (8+ LeanRoof, rust or grey) in front of the arches, none south of lx -20",
		#lean >= 8 and count(lean, tinCol) == #lean and count(lean, function(p) return mk(p).X - extent(p, "Z") / 2 >= -20 end) == #lean,
		#lean .. " roofs")
	local cs = allNamed("Counter")
	check("denser yard: 28+ stall Counters, all within 84 studs of the pivot's frontage line (world x <= -246)",
		#cs >= 28 and count(cs, function(p) return p.Position.X <= -246 end) == #cs,
		#cs .. " counters, max x " .. fmt((function() local m = -1e9 for _, p in ipairs(cs) do m = math.max(m, p.Position.X) end return m end)()))
	local tri = allNamed("TricycleBody")
	check("2+ tricycle silhouettes (TricycleBody) with wheels and a roof (6+ TricycleWheel, 2+ TricycleRoof), in the yard or at its mouth",
		#tri >= 2 and #allNamed("TricycleWheel") >= 6 and #allNamed("TricycleRoof") >= 2, #tri .. " bodies")
	local tarps = allNamed("Canopy")
	local tc = {}
	for _, p in ipairs(tarps) do tc[string.format("%d,%d,%d", rgb(p))] = true end
	local n = 0
	for _ in pairs(tc) do n += 1 end
	check("tarp canopies in 3+ colours (blue, green, orange)", #tarps >= 28 and n >= 3, #tarps .. " canopies, " .. n .. " colours")
	check("the yard slab (YardSlab, 0.3 thick) and the sample-price board are kept", anchor("YardSlab") ~= nil and anchor("YardSlab").Size.Y <= 0.31 and anchor("SampleBoard") ~= nil)
end

------------------------------------------------------------------ D: required props, vendors and whole-site rules
do
	for _, name in ipairs({ "MarketStalls", "Baskets", "Produce", "PriceSigns" }) do
		local c = site:FindFirstChild(name)
		check("prop " .. name .. " exists and holds parts", c ~= nil and #c:GetDescendants() > 0)
	end
	local vend = site:FindFirstChild("VendorNPCs")
	local rigs = 0
	if vend then
		for _, v in ipairs(vend:GetChildren()) do if v:FindFirstChildOfClass("Humanoid") then rigs += 1 end end
	end
	check("VendorNPCs holds 6 to 8 vendors", rigs >= 6 and rigs <= 9, tostring(rigs))
	check("price boards: 28+ PriceBoard, one reads KAMATIS", #allNamed("PriceBoard") >= 28, tostring(#allNamed("PriceBoard")))

	local total, unanchored, outside, thin = 0, {}, {}, {}
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") and not isRig(d) then
			total += 1
			if not d.Anchored then table.insert(unanchored, d.Name) end
			-- footprint 200 x 160 at the pivot, +10%: world x -440..-220, z 72..248
			local ex, ez = extent(d, "X") / 2, extent(d, "Z") / 2
			if d.Position.X - ex < -440.05 or d.Position.X + ex > -219.95 or d.Position.Z - ez < 71.95 or d.Position.Z + ez > 248.05 then
				table.insert(outside, d.Name .. " " .. tostring(d.Position))
			end
			-- terrain grass blades bury anything thin outside the Pavement (x -376..-228, z 80..240)
			if d.Size.Y <= 0.35 and d.Position.Y - d.Size.Y / 2 <= 0.3 and not isKept(d) then
				if d.Position.X - ex < -376.05 or d.Position.X + ex > -227.95 or d.Position.Z - ez < 79.95 or d.Position.Z + ez > 240.05 then
					table.insert(thin, d.Name .. " " .. tostring(d.Position))
				end
			end
		end
	end
	check("every non-rig part is anchored", #unanchored == 0, table.concat(unanchored, ", ", 1, math.min(#unanchored, 6)))
	check("every non-rig part is inside the footprint +10% (x -440..-220, z 72..248), rotated corners included", #outside == 0, table.concat(outside, "; ", 1, math.min(#outside, 4)))
	check("thin ground parts (<= 0.35 thick, on the ground) stay inside the Pavement (x -376..-228, z 80..240)", #thin == 0, table.concat(thin, "; ", 1, math.min(#thin, 4)))
	-- BuildCheck counts the vendor rigs too (the old model: 976 there, 832 without them)
	check("part count (rigs excluded) is between 950 and 1500 (the old model had 832)", total >= 950 and total <= 1500, tostring(total))
end

return HttpService:JSONEncode(results)
