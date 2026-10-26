# Handoff 026: Slice 2 (tour content) done; owner approves the change table next
Previous: 025-handoff.md. Plan: `docs/PLAN-v2.md` (public copy); the full plan is kept locally by the owner.

## Status
- Slice 2 is complete as defined: the content files and the change table are committed locally. All ten sites have content (billboard headline, blurb, trivia, quiz, guide lines, art "look at" line, display list), plus City Hall facts, jeep driver lines, glossary and wrap-up. The quiz answer key is server-side only.
- **Nothing is wired into the game.** No script, billboard, credit board or quiz reads `TourContent` or `QuizKey` yet (Slices 3b, 8, 11, after approval).
- Outfit textures (22 PNGs) are drawn and tested but kept in `scratch/` (gitignored) and not uploaded.
- **Open, carried forward:** the 3D viewport state was not checked this slice (no screenshots needed); the ViewportFrame fallback and the upload probe from Slice 1 are still untried.

## Environment
- Branch `feat/tour-v2`, nothing pushed. Studio place open: `slice-25.rbxl` (saved from `slice-24.rbxl`), Edit mode. Studio ids change per session: run `list_roblox_studios` first.
- **Studio holds unsaved Slice 2 work** (`TourContent`, `QuizKey`, the two new unit cases, the patched `run_all`). Backup: **pending your save.** File, Save to File as `backups\slice-26.rbxl` (a new name; do not press Ctrl+S, that would overwrite `slice-25.rbxl`). The next session's first step checks the file exists and records its size and SHA-256 in `docs/baseline.md`.
- Slice 2 started from `backups\slice-25.rbxl` (427,800 bytes, SHA-256 `0273B45CC657AC298B2007C0B6EE133DA0409BCE4ACFE6F750F71D048DA8FD73`), saved under that name instead of the planned `slice-25-start`; recorded in `docs/baseline.md`.

## Commits (local, no attribution trailer)
`32ad13b` docs(baseline): record the slice-25 place
`13c8132` test(content): add failing tests for the tour content and quiz key
`280a1f9` feat(tools): draw the barong, baro't saya and persona outfit textures
`b2f79a3` feat(content): add the tour content and quiz key as unwired data
`7f5998d` docs(content): add the change table for owner approval
(plus the handoff commit that adds this file)

## Evidence
Red first: with the skeletons only, `run_all` showed `unit run: got 184, expected 127` and `unit failed: got 10, expected 0` (9 TourContent real-content tests and the QuizKey real-answers test); the crosscheck failed with "missing file content/tour_content.md". Texture tests were red with 35 import errors before the module existed.
```
disk = Studio (bytes / newlines / djb2, LF):
TourContent 29526/714/3203777655 | QuizKey 902/19/3502098741 | run_all 4541/100/2557674770
TourContent_Test 16968/364/3542397431 | QuizKey_Test 4344/116/3859017139
run_all (Edit mode): ok=true, mismatches [], 14 stored checks, unit 184 (TourContent_Test 46 + QuizKey_Test 11 new), world parts 7100, cells 1793270
TourContent.validate: 0 errors | QuizKey.isCorrect: right/wrong true/false for ids 1..10; ids 0 and 11, choices 0, 4 and 2.5, nil and "1" all false
tests/tour_content_crosscheck.ps1: 10 sites, 0 mismatched, exit 0 | tests/credits_crosscheck.ps1: 9 sites, 27 urls, 0 mismatched
python -m unittest tests.test_outfit_textures: 35 tests OK (ran twice)
```
`EXPECTED.unitRun` changed 127 to 184 on purpose (comment in `tests/run_all.luau`). Screenshots: none taken (content only). All 22 outfit PNGs were looked at (four at full size, the rest on two contact sheets).

## Findings and fixes
- B1 (sites 6 to 9) inserted its tables inside site 5's closing braces: syntax stayed valid, indentation was one level too deep, and the Carmel "Sources:" line landed under Site 9 in `content/tour_content.md`. Fixed by a depth-based re-indent (only leading tabs changed, checked) and by moving the line back; sites 6 to 9 got their own Sources lines.
- `validate` counts "Ms." or "B." as a sentence end. Dialogue and trivia avoid them (`npc.name` may be "Ms. Grace"; the Market line "Candido B. Lopez ..." counts as two sentences, within the cap).
- Outfit textures bake skin tone `#E0AC87` into the baro't saya arms, short sleeves (Kuya Ben, Paolo, Ms. Grace, Jun), Mang Tonyo's forearms and Paolo's legs. Slice 12 must match each NPC's skin tone or make those areas transparent. The barong is opaque ivory, not sheer, and the baro't saya has flat sleeve caps; the 3D parts in Slice 12 carry the real shapes.
- `SiteData` guide names ("Plaza Guide", "Market Vendor", ...) differ from the PDF names now in `TourContent`; `SiteData` was not touched.
- `.gitignore` gained `__pycache__/`.

## Decisions and deviations
1. Display lists stay in `TourContent.displayProps`, not `SiteData.requiredProps`, so `BuildCheck` is not red for props that do not exist yet; each structure slice promotes its own site's list with the build.
2. Credits are drafted in the change table only; `CreditsData` and `site_credits.md` change in Slice 3b after approval.
3. The content agent B was split into B1 (sites 6 to 9) and B2 (City Hall and shared lists) to respect the Haiku cap. B1 stopped with `CONTEXT_LOW` before pushing; the orchestrator verified the disk files and a Sonnet agent pushed and validated everything.
4. Dialogue wording follows the PDF; edits are only ASCII, the listed fact fixes, length rules and mood (Jun's "Morning!" now "Hey there! Ready to swing?"). All are in `content/tour_content_changes.md`.
5. The README says to stop when `run_all` is not ok; during the red phase it was red on purpose (shown above), and it is ok again.

## Pending on you
1. Save `backups\slice-26.rbxl` (see Environment).
2. Approve or edit `content/tour_content_changes.md`, sections 1 to 8, with open questions in 2 (kept-but-unsourced lines, Market name, Tagbakin billboard "lakeside side"), 3 (Jun, "sunburnt"), 4 (keep ASCII or make the typewriter UTF-8 safe), 5 (guide names in `SiteData`), 7 (wrap-up reflection).
3. Blueprint credit wording and the source (or "my own screenshot") for the City Hall photos.
4. OK or not to upload the outfit textures to your Roblox account (Slice 12).
5. Bring Studio to the front and click the viewport once; tell me if the 3D view is back. Tell groupmates to hold edits to `SiteData`, `sites_check`, `qa_check`, `CreditsData` and `PassportClient` until Slice 3b is done.

## Next steps (Slice 3a: City Hall building)
1. Resume check: `list_roblox_studios`, Edit mode, `run_all` ok (14 checks, unit 184, parts 7100, cells 1793270); check `backups\slice-26.rbxl` and record its size and SHA-256 in `docs/baseline.md`.
2. Ask for the owner's decisions on the change table; apply approved edits to `content/tour_content.md` and `TourContent.luau` (crosscheck, hashes, `run_all`).
3. Slice 3a per `docs/PLAN-v2.md`: `builders/site10.luau`, `tests/site10_check.luau`, `briefs/site10.md`; tests first and red; three Haiku agents (shell, steps and forecourt, trees and cars), at most 2,500 parts. Before building, settle the visual route (viewport, ViewportFrame fallback, or pasted screenshots), because a structure is signed off only after someone looks at its shots.

## Context log
Orchestrator peak not measured; no continuation was needed before this handoff. Agent token usage as reported by the harness (it may include repeated context reads, so it is not a clean per-context peak): Sonnet tests 126k, Sonnet push-and-validate 97k, Haiku textures 338k, Haiku A 368k, Haiku B1 206k (stopped with CONTEXT_LOW), Haiku B2 234k. **Exception:** the Haiku agents exceeded the 100k cap by that measure although each worked on one module or one site; next slice, smaller tasks (one module each) and stricter journals.

## Continuation prompt
```
Continue the Lipa Tour v2 project at Slice 3a (City Hall building). Working dir: the repo root `roblox/`. Read the full local plan kept by the owner (the pasted-content plan file under the owner's .claude plans folder), then docs/PLAN-v2.md and docs/handoff/026-handoff.md.
First: list_roblox_studios (ids change), Edit mode, run require(game.ServerStorage.Checks.run_all:Clone())() and expect ok=true (14 checks, unit 184, parts 7100, cells 1793270). Confirm backups\slice-26.rbxl exists (ask me to save it if not) and record its size and SHA-256 in docs/baseline.md. Stop and report any mismatch.
Then ask me for my decisions on content/tour_content_changes.md and apply the approved edits before building.
Roles: you orchestrate; Sonnet 5.5 implements; Haiku 5.5 at effort max builds, one module or site per agent (the Haiku cap is 100k). Context caps: 250k Opus/Sonnet; write a continuation at about 200k.
Rules: branch feat/tour-v2, never main; Conventional Commits with NO Co-Authored-By; nothing pushed without my say; tests first and shown red; Studio vs disk hash equal (node tools/hash.js); look at every screenshot; ASCII dialogue; never run builders/world.luau; no upload to Roblox without my OK. Slice 3a ends with builders/site10.luau, tests/site10_check.luau and briefs/site10.md committed and checks green. Then write handoff 027, give the continuation prompt, remind me to save the backup, and stop.
```
