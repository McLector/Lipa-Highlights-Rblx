# credits_crosscheck: the disk-side check that content/site_credits.md and src/.../CreditsData.luau list the same source urls
# per site (the Studio-side CreditsData_Test is structural only). Run from the repo root or anywhere:
#   powershell -NoProfile -File tests/credits_crosscheck.ps1
# Reads the "- https://..." bullets under each "## Site N:" heading (stopping at the next "## " heading, so the later attribution
# section is ignored) and the url strings of each `{ id = N, urls = { ... } }` entry. Exits 1 on any mismatch.
$root = Split-Path -Parent $PSScriptRoot
$md = Get-Content (Join-Path $root "content\site_credits.md") -Encoding UTF8
$lua = Get-Content (Join-Path $root "src\ReplicatedStorage\LipaShared\CreditsData.luau") -Encoding UTF8

$mdSites = @{}; $cur = $null
foreach ($line in $md) {
	if ($line -match '^## Site (\d+):') { $cur = [int]$Matches[1]; $mdSites[$cur] = @(); continue }
	if ($line -match '^## ') { $cur = $null; continue }
	if ($cur -and $line -match '^- (https://\S+)\s*$') { $mdSites[$cur] += $Matches[1] }
}
$luaSites = @{}; $cur = $null
foreach ($line in $lua) {
	if ($line -match '\{ id = (\d+), urls = \{') { $cur = [int]$Matches[1]; $luaSites[$cur] = @(); continue }
	if ($cur -and $line -match '^\s*"(https://[^"]+)",\s*$') { $luaSites[$cur] += $Matches[1] }
	if ($cur -and $line -match '^\s*\} \},?\s*$') { $cur = $null }
}

$mismatch = 0; $total = 0
foreach ($id in 1..10) {
	$a = @($mdSites[$id]); $b = @($luaSites[$id])
	$total += $a.Count
	$onlyMd = $a | Where-Object { $_ -notin $b }
	$onlyLua = $b | Where-Object { $_ -notin $a }
	foreach ($u in $onlyMd) { "site $id : only in md  : $u"; $mismatch++ }
	foreach ($u in $onlyLua) { "site $id : only in lua : $u"; $mismatch++ }
	if ($a.Count -ne $b.Count) { "site $id : url count differs (md $($a.Count), lua $($b.Count))"; $mismatch++ }
}
# Tour sources: the 25 numbered references (md "N. text url" lines under "## Tour sources" vs CreditsData.tourSources rows).
$mdSrc = @{}; $inSrc = $false
foreach ($line in $md) {
	if ($line -match '^## Tour sources') { $inSrc = $true; continue }
	if ($line -match '^## ') { $inSrc = $false; continue }
	if ($inSrc -and $line -match '^(\d+)\. (.*) (https://\S+)\s*$') { $mdSrc[[int]$Matches[1]] = @($Matches[2], $Matches[3]) }
}
$luaSrc = @{}
foreach ($line in $lua) {
	if ($line -match '^\s*\{ ref = (\d+), text = "((?:[^"\\]|\\.)*)", url = "(https://[^"]+)" \},?\s*$') {
		$luaSrc[[int]$Matches[1]] = @(($Matches[2] -replace '\\"', '"'), $Matches[3])
	}
}
foreach ($n in 1..25) {
	if (-not $mdSrc.ContainsKey($n)) { "tour source $n : missing in md"; $mismatch++; continue }
	if (-not $luaSrc.ContainsKey($n)) { "tour source $n : missing in lua"; $mismatch++; continue }
	if ($mdSrc[$n][0] -ne $luaSrc[$n][0] -or $mdSrc[$n][1] -ne $luaSrc[$n][1]) { "tour source $n : text or url differs"; $mismatch++ }
}
if ($mdSrc.Count -ne 25 -or $luaSrc.Count -ne 25) { "tour sources: md $($mdSrc.Count), lua $($luaSrc.Count), expected 25"; $mismatch++ }
"disk md vs CreditsData: $($mdSites.Count) sites, $total urls, $mismatch mismatched"
if ($mismatch -gt 0 -or $mdSites.Count -ne 10 -or $luaSites.Count -ne 10) { exit 1 }
