# credits_crosscheck: the disk-side check that content/site_credits.md and src/.../CreditsData.luau list the same source urls
# per site (the Studio-side CreditsData_Test is structural only). Run from the repo root or anywhere:
#   powershell -NoProfile -File tests/credits_crosscheck.ps1
# Reads the "- https://..." bullets under each "## Site N:" heading (stopping at the next "## " heading, so the later attribution
# section is ignored) and the url strings of each `{ id = N, urls = { ... } }` entry. It also compares the 25 tour sources, the 78 APA 7
# lines under "## References (APA 7)" with CreditsData.references[].text, and the 4 lines under "## Notices" with CreditsData.noticeLines
# (in order, case-sensitive), and the lines under "## Audio" with CreditsData.audio[].text. Exits 1 on any mismatch.
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
# APA 7 references: the md lines under "## References (APA 7)" (every line that ends in an https url; the one-line intro does not)
# against CreditsData.references[].text, in order and text for text. Comparisons use -cne, so a change of case alone is a mismatch.
$mdRefs = @(); $inRefs = $false
foreach ($line in $md) {
	if ($line -match '^## References \(APA 7\)') { $inRefs = $true; continue }
	if ($line -match '^## ') { $inRefs = $false; continue }
	if ($inRefs -and $line -match ' https://\S+\s*$') { $mdRefs += $line.TrimEnd() }
}
$luaRefs = @(); $inLuaRefs = $false
foreach ($line in $lua) {
	if ($line -match '^CreditsData\.references = \{') { $inLuaRefs = $true; continue }
	if ($inLuaRefs -and $line -match '^\}') { $inLuaRefs = $false; continue }
	if ($inLuaRefs -and $line -match '^\s*\{ text = "((?:[^"\\]|\\.)*)"') {
		$luaRefs += (($Matches[1] -replace '\\"', '"') -replace '\\\\', '\')
	}
}
if ($mdRefs.Count -ne $luaRefs.Count -or $mdRefs.Count -ne 78) { "references: md $($mdRefs.Count), lua $($luaRefs.Count), expected 78"; $mismatch++ }
for ($i = 0; $i -lt [Math]::Min($mdRefs.Count, $luaRefs.Count); $i++) {
	if ($mdRefs[$i] -cne $luaRefs[$i]) { "reference $($i + 1) : text differs"; "  md  : $($mdRefs[$i])"; "  lua : $($luaRefs[$i])"; $mismatch++ }
}
# Notices: the non-blank md lines under "## Notices" against CreditsData.noticeLines.
$mdNotes = @(); $inNotes = $false
foreach ($line in $md) {
	if ($line -match '^## Notices\s*$') { $inNotes = $true; continue }
	if ($line -match '^## ') { $inNotes = $false; continue }
	if ($inNotes -and $line.Trim().Length -gt 0) { $mdNotes += $line.TrimEnd() }
}
$luaNotes = @(); $inLuaNotes = $false
foreach ($line in $lua) {
	if ($line -match '^CreditsData\.noticeLines = \{') { $inLuaNotes = $true; continue }
	if ($inLuaNotes -and $line -match '^\}') { $inLuaNotes = $false; continue }
	if ($inLuaNotes -and $line -match '^\s*"((?:[^"\\]|\\.)*)",?\s*$') {
		$luaNotes += (($Matches[1] -replace '\\"', '"') -replace '\\\\', '\')
	}
}
if ($mdNotes.Count -ne $luaNotes.Count -or $mdNotes.Count -ne 4) { "notices: md $($mdNotes.Count), lua $($luaNotes.Count), expected 4"; $mismatch++ }
for ($i = 0; $i -lt [Math]::Min($mdNotes.Count, $luaNotes.Count); $i++) {
	if ($mdNotes[$i] -cne $luaNotes[$i]) { "notice $($i + 1) : text differs"; "  md  : $($mdNotes[$i])"; "  lua : $($luaNotes[$i])"; $mismatch++ }
}
# Audio (polish pass, 2026-10-31): the md lines under "## Audio" that end in an https url against CreditsData.audio[].text, in order and
# text for text; at least 2 (the music loop and the stamp sound).
$mdAudio = @(); $inAudio = $false
foreach ($line in $md) {
	if ($line -match '^## Audio\s*$') { $inAudio = $true; continue }
	if ($line -match '^## ') { $inAudio = $false; continue }
	if ($inAudio -and $line -match ' https://\S+\s*$') { $mdAudio += $line.TrimEnd() }
}
$luaAudio = @(); $inLuaAudio = $false
foreach ($line in $lua) {
	if ($line -match '^CreditsData\.audio = \{') { $inLuaAudio = $true; continue }
	if ($inLuaAudio -and $line -match '^\}') { $inLuaAudio = $false; continue }
	if ($inLuaAudio -and $line -match '^\s*\{ text = "((?:[^"\\]|\\.)*)"') {
		$luaAudio += (($Matches[1] -replace '\\"', '"') -replace '\\\\', '\')
	}
}
if ($mdAudio.Count -ne $luaAudio.Count -or $mdAudio.Count -lt 2) { "audio: md $($mdAudio.Count), lua $($luaAudio.Count), expected the same count and at least 2"; $mismatch++ }
for ($i = 0; $i -lt [Math]::Min($mdAudio.Count, $luaAudio.Count); $i++) {
	if ($mdAudio[$i] -cne $luaAudio[$i]) { "audio $($i + 1) : text differs"; "  md  : $($mdAudio[$i])"; "  lua : $($luaAudio[$i])"; $mismatch++ }
}
"disk md vs CreditsData: $($mdSites.Count) sites, $total urls, $($mdSrc.Count) tour sources, $($mdRefs.Count) references, $($mdNotes.Count) notices, $($mdAudio.Count) audio, $mismatch mismatched"
if ($mismatch -gt 0 -or $mdSites.Count -ne 10 -or $luaSites.Count -ne 10) { exit 1 }
