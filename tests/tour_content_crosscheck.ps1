# tour_content_crosscheck: the disk-side check that content/tour_content.md and src/.../TourContent.luau carry the same
# headline, blurb and quiz question for each of the 10 sites. Run from anywhere:
#   powershell -NoProfile -File tests/tour_content_crosscheck.ps1
# Markdown format (one line per field, text is the rest of the line after the label):
#   ## Site N: name
#   Headline: ...
#   Blurb: ...
#   Quiz: <the question>
# A "## " heading that is not "## Site N:" ends the current site, so later sections are ignored.
# Module format: the module must keep ONE FIELD PER LINE, double-quoted, with \" as the only escape, e.g.
#   id = 3,
#   headline = "Some headline",
#   blurb = "A short blurb.",
#   question = "Which option is right?",
# A site starts at its `id = N,` line. Exits 1 on any mismatch, a missing file, or if either side does not have 10 sites.
$root = Split-Path -Parent $PSScriptRoot
$mdPath = Join-Path $root "content\tour_content.md"
$luaPath = Join-Path $root "src\ReplicatedStorage\LipaShared\TourContent.luau"
foreach ($p in @($mdPath, $luaPath)) {
	if (-not (Test-Path $p)) { "missing file: $p"; exit 1 }
}
$md = Get-Content $mdPath -Encoding UTF8
$lua = Get-Content $luaPath -Encoding UTF8

$fields = @("headline", "blurb", "question")
$mdSites = @{}; $cur = $null
foreach ($line in $md) {
	if ($line -match '^## Site (\d+):') { $cur = [int]$Matches[1]; $mdSites[$cur] = @{}; continue }
	if ($line -match '^## ') { $cur = $null; continue }
	if (-not $cur) { continue }
	if ($line -match '^Headline:\s*(.*?)\s*$') { $mdSites[$cur]["headline"] = $Matches[1] }
	elseif ($line -match '^Blurb:\s*(.*?)\s*$') { $mdSites[$cur]["blurb"] = $Matches[1] }
	elseif ($line -match '^Quiz:\s*(.*?)\s*$') { $mdSites[$cur]["question"] = $Matches[1] }
}
$luaSites = @{}; $cur = $null
foreach ($line in $lua) {
	if ($line -match '^\s*id = (\d+),\s*$') { $cur = [int]$Matches[1]; $luaSites[$cur] = @{}; continue }
	if (-not $cur) { continue }
	if ($line -match '^\s*(headline|blurb|question) = "((?:[^"\\]|\\.)*)",?\s*$') {
		$luaSites[$cur][$Matches[1]] = $Matches[2].Replace('\"', '"')
	}
}

$mismatch = 0
foreach ($id in 1..10) {
	foreach ($f in $fields) {
		$a = $mdSites[$id][$f]; $b = $luaSites[$id][$f]
		if ($null -eq $a -and $null -eq $b) { "site $id : $f missing on both sides"; $mismatch++ }
		elseif ($null -eq $a) { "site $id : $f only in lua : $b"; $mismatch++ }
		elseif ($null -eq $b) { "site $id : $f only in md  : $a"; $mismatch++ }
		elseif ($a -cne $b) { "site $id : $f differs"; "  md  : $a"; "  lua : $b"; $mismatch++ }
	}
}
"disk md vs TourContent: md $($mdSites.Count) sites, lua $($luaSites.Count) sites, $mismatch mismatched"
if ($mismatch -gt 0 -or $mdSites.Count -ne 10 -or $luaSites.Count -ne 10) { exit 1 }
