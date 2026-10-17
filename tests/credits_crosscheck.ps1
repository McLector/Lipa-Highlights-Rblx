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
foreach ($id in 1..9) {
	$a = @($mdSites[$id]); $b = @($luaSites[$id])
	$total += $a.Count
	$onlyMd = $a | Where-Object { $_ -notin $b }
	$onlyLua = $b | Where-Object { $_ -notin $a }
	foreach ($u in $onlyMd) { "site $id : only in md  : $u"; $mismatch++ }
	foreach ($u in $onlyLua) { "site $id : only in lua : $u"; $mismatch++ }
	if ($a.Count -ne $b.Count) { "site $id : url count differs (md $($a.Count), lua $($b.Count))"; $mismatch++ }
}
"disk md vs CreditsData: $($mdSites.Count) sites, $total urls, $mismatch mismatched"
if ($mismatch -gt 0 -or $mdSites.Count -ne 9 -or $luaSites.Count -ne 9) { exit 1 }
