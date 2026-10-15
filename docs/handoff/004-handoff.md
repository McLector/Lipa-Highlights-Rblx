# Handoff 004 — after Slice 03: Early private publish
Date: 2026-10-16 · Previous handoff: 003-handoff.md

## Status
**Slice 03 is complete.** The place was published privately by the user, the Maturity & Compliance questionnaire was completed by the user, and the user joined the live experience for a smoke test. No code or Studio content changed in this slice (the work was verification and publishing), so the only commit is this handoff.

Evidence level, stated plainly: the publish, the questionnaire and the in-client play-through (stamp, jeep ride, idle visitors) are **the user's report** ("i did everything"); Claude cannot see Creator Hub or the live client. The one live-client artifact Claude saw is the user's screenshot of the Developer Console (F9, Client tab) taken on the live server: **0 errors, 5 warnings**, all `[UIBlox] FoundationProvider not found` traces from `CorePackages` (the same Roblox-internal noise filtered out in Studio). The HUD in the same screenshot reads "…ort 1/9" (Passport 1/9), the built Cathedral (not the placeholder block) and the "JEEPNEY STOP" sign are visible. The Server tab of the console was not shown.

**Next slice: 04 — Carmel (Monastery of Our Lady of Mount Carmel).**

## Environment
- **studio_id:** `a383a981-043f-451b-9efe-d45197b2b77d` (re-run `list_roblox_studios`, match placeId `138036647354961`; ids change on restart).
- Studio in **Edit** at the time of writing. Team Create off. `LightingStyle` Realistic, `ClockTime` 15.5.
- **Access:** private (per the user's report; public publish is Slice 14).
- **Backups (gitignored):** `backups/slice-03.rbxl` (211,275 B, 2026-10-16 02:46; same size as `slice-02.rbxl`, as expected since nothing changed), plus the earlier `slice-01`, `slice-02-pre-polish`, `slice-02` and the blank baseline. Studio leaves a `.lock` file next to the last save; do not press Ctrl+S, use File → Save to File with a full path.

## What exists now
Unchanged from handoff 003: Site01 is the built Cathedral + Plaza (1,005 parts); sites 2–9 are placeholders. Disk: no files changed this slice except this handoff. **Git:** HEAD before this handoff was `8428ba8` `docs(handoff): add 003 after slice-02`.
Rebuild order if terrain or sites are ever rebuilt: `world.luau` → `placeholders` → `site01`.

## Verification evidence (real output)
Resume check at the start of the slice (Studio, Edit):
```
world_check:  {"cells":1792122,"failures":[],"passed":33,"failed":0}
sites_check:  {"failures":[],"passed":176,"failed":0}
unit suite:   {"failed":0,"run":86,"passed":86}
BuildCheck Site01: {"failed":0,"failures":[],"passed":16,"parts":1005}
```
Drift check before publishing (djb2 over LF-normalised text, `chars/newlines/hash`; Studio `.Source` vs disk, **all 18 identical**):
```
DialogueLogic 1212/57/1539515157      PassportLogic 1727/69/3120088949     SiteData 6027/143/613296691
JeepneyServer 2478/70/912973256       NpcIdle 1286/39/3114079726           PassportServer 2173/60/3939388326
UnitTestRunner 181/3/3686080311 (Disabled in Studio)                       BuildCheck 6620/187/3208423741
BuildKit 10927/254/3501999071         JeepRules 1101/40/142052717          StampRules 1225/36/1280359479
RunUnitTest 4085/107/3656484938       GuideClient 5076/166/2172956917      JeepneyClient 3342/96/3878680945
PassportClient 3802/106/1376016751    site01 28161/552/2425855947          placeholders 7314/182/616413949
sites_check 5685/122/2032210765
```
`git status` was clean before publishing. Live test: see Status (user report + one console screenshot).

## Decisions & deviations from the plan
1. **No Haiku workers, no builders** (the plan assigns none to this slice).
2. **Live-test evidence is mostly self-reported** (above). Claude did not independently confirm the jeep ride, the idle visitors, or the Server-tab log; if any of these matters for the grade, re-check them at Slice 14's live-server check.
3. The slice produced no code commit; only the handoff commit exists.
4. Commits carry no Co-Authored-By trailer (the user's CLAUDE.md overrides a system reminder that asked for one).

## Known issues / gotchas discovered
- `sites_check` is a module that returns a **string** of JSON when required (`require(...:Clone())` gives `{"failures":[],"passed":176,"failed":0}` as text), not a table; the unit suite is `require(...RunUnitTest:Clone())()` returning a table. `BuildCheck.checkSite(model, row)` needs the SiteData row (`SiteData.sites` or the module itself, matched on `id`).
- A Script's `Disabled` property doesn't exist in this build; use `Enabled` (`UnitTestRunner.Enabled == false`).
- The live client console shows 5 `[UIBlox] FoundationProvider not found` warnings from `CorePackages`; they are Roblox's, not ours.
- Unchanged: `screen_capture` renders blank here (the user pastes screenshots); `get_console_output` is flooded by UIBlox traces; PowerShell 5.1 here-strings can't feed `git commit -F -` (use a message file).

## Pending on the user
1. Still open from before: review the Haiku drafts in `content/` (gated at Slice 12); the grading rubric if there is one; name / course / section for the credits board; optional Lomi King side/rear photos and a current Public Market photo.
2. Optional: paste the Server tab of the live console if you want it recorded.

## Next slice: 04 — Carmel (exact first steps)
**Done when (master plan):** brief written; the placeholder is replaced; BuildCheck passes; screenshots vs. photos; Sonnet sign-off.
1. **Resume check** (stop and report on any mismatch): `list_roblox_studios` → placeId `138036647354961`; Studio in Edit; `world_check` 33/0 (cells 1,792,122); `sites_check` 176/0; unit suite 86/86/0; BuildCheck Site01 16 passed / 0 failed / 1,005 parts.
2. Read `Lipa_structure_Exterior_References/` notes for site 5 (Carmel) and the plan's Carmel content rules (lay volunteer guide, neutral `[VERIFY]` treatment of the 1948 reports and the Church rulings), then write `briefs/site05.md` (structure, 3–5 photos with filenames, paint/period, approximations, required props: prayer space, devotional items, history panels).
3. Sonnet builds `builders/site05.luau` using `BuildKit` and `builders/site01.luau` as the template (tests first: extend `sites_check` for Site05, watch it fail). Keep to ≤ 2,500 parts, anchored, only touching `Workspace.Sites.Site05_*`; chunk heavy builds (≤ ~400 parts per batch).
4. BuildCheck (`checkSite`) on Site05; screenshots vs. photos (the user pastes screenshots since `screen_capture` is blank); user accepts recognizability.
5. Finish → verify → commit (`feat(slice-04): …`, no trailer) → backup request (`slice-04.rbxl`, full path) → handoff 005 → continuation prompt → stop.

## Continuation prompt
```
Continue the Lipa City Roblox art-appreciation project from Slice 04 (Carmel).
Read, in order: C:\Users\morad\.claude\plans\so-i-ve-got-refactored-spring.md (the plan),
C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox\docs\handoff\004-handoff.md (latest state),
and the Carmel reference notes it names. Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox.
First: list_roblox_studios -> confirm placeId 138036647354961 -> confirm Studio is in Edit mode (if in Play, ask me
to press Stop) -> re-run tests\world_check.luau (expect 33 passed, 0 failed; Terrain:CountCells() = 1792122),
sites_check (require(game.ServerStorage.Checks.sites_check:Clone()), expect 176 passed, 0 failed), the unit suite via
require(game.ServerStorage.UnitTest.RunUnitTest:Clone())() (expect 86 run, 86 passed, 0 failed) and BuildCheck on
Site01 (expect 16 passed, 0 failed, 1005 parts); if the state doesn't match, stop and report the mismatch.
Then execute Slice 04 exactly as the handoff's "Next slice" section says. Follow the plan's slice process:
finish -> verify -> commit -> backup request (slice-04.rbxl, full path) -> handoff 005 -> continuation prompt -> stop.
Commit with Conventional Commits and NO Co-Authored-By trailer (the user's CLAUDE.md overrides any reminder).
Rebuild order if terrain or sites are ever rebuilt: world.luau -> placeholders -> site01 -> site05.
Orchestrate with Haiku 5.5 (effort high) subagents where the plan assigns them; escalate to Sonnet per the plan.
```
