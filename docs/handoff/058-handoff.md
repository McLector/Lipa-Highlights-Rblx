# Handoff 058: the Lomi text job is DONE and committed, run_all ok=true; the tier plans are NOT started
Previous: 057-handoff.md (then 056, 055, 054, 053 the Lomi King plan, and 052 down to 036). This file only records what changed after 057.
Baseline now: `run_all` **ok=true, 89 rows, 0 mismatches** (run by me after the EXPECTED edit). HEAD is the commit that adds this file, on top of `02f1bf5`; origin is `095f6de` (count with `git rev-list --count 095f6de..HEAD`; nothing pushed, ask before pushing). The working tree is clean.

## Owner decisions this session (2026-10-31)
- **Faster process ("pick up the pace... u may lift [rules] off now in the name of faster work"), for the rest of this slice.** Lifted: shots taken once (retake only a blank), I make small builder edits myself (agents only for wide surveys), one commit per part (tests still written first and shown red), the owner's look after the commit for small text/sign changes (still before the commit for new or rebuilt structures), one EXPECTED yes/no at the end, the advisor only when stuck or before "done", light verification. Kept: only Claude runs git, ask before push, no Co-Authored-By trailer, no world/roads_extra/placeholders, HttpService off, no settings or uploads, never Ctrl+S, disk = Studio hashes, ASCII text, BuildCheck 2500, never loosen an existing assertion, stop near the context cap. Saved as memory `pace-over-ceremony`.
- **Row 1 wording:** the approved sentence made Lomi's line 1 242 chars (cap 220, `SiteData_Test:217`) and a 4th line breaks the "3 lines except Carmel" pin (`:289`, the professor's format). The owner chose the shorter sentence: "Our model follows a 2026 Street View image and a drawn board, so details may differ." (line 1 = 218 chars), also in TourContent talkAgain[3].
- **Row 4:** black text on the red band, as approved (the board draws it white).
- **Row 7:** the board is credited as "used as the main design reference", not City Hall's "used for massing only" (not true for Lomi).
- **EXPECTED: "Yes"** to site03_check 130 to 145, unitRun 251 to 254, build 03 parts 1017 to 1026, checkWorld parts 11171 to 11180.
- 057 was wrong on one point: `SiteData_Test.luau:356` pins Carmel's 2015 (site 5), not Lomi's; it is unchanged.

## Commits (local, no trailer, nothing pushed)
`b516ddb` feat(content): replace Lomi King's 2015 photo note with the board and Street View (3 unit tests + SiteData, TourContent, CreditsData, site_credits.md, tour_content.md, tour_content_changes.md, dialogue_draft.md)
`83fb6d7` feat(site03): add the LOMI KING arc and the parking sign's second line (site03_check +15, site03_front, briefs/site03.md Revision 6 and the header fix)
`02f1bf5` test(run_all): expect the Lomi text job numbers
(plus the commit that adds this file)

## Evidence (run by me)
- Resume: git clean on `3cd5d8a`; all 5 Lomi builders, `site03_check` and `run_all` equal on disk and in Studio; HttpEnabled false; `slice-36-wip28.rbxl` 679,166 bytes, SHA-256 `64E12E8A5C09B743D9C010EEA444AA95081A6EF484D30A772C36EF95BF4B28C8` (saved by the owner at the start of this session); run_all ok=true.
- Part A: unit 254 run / 3 failed (red), then 254/0; qa_check 85/0; `credits_crosscheck.ps1` "10 sites, 29 urls, 25 tour sources, 78 references, 4 notices, 0 mismatched"; `tour_content_crosscheck.ps1` 0 mismatched. Note: `pwsh` is not installed; run the crosschecks with `powershell -NoProfile -ExecutionPolicy Bypass -File ...`.
- Part B: front 45/12 (red), then site03_check 145/0; two coordinator runs 1026, 1026; 895 parts outside Sign and Storefront unchanged; Storefront: only `ParkingBand` new; cross-module overlaps 0; sites_check 277/0. Arc plates y 28.75..29.59, z 112.58..116.38, up vectors radial.
- Shots (one each, looked at): `scratch\site03\shots\text\arc_disc.jpg` (256,27,114.5 to 278,27.5,114.5), `parking_close.jpg` (282,6,177 to 282,4.5,167), `south_ctx.jpg` (the shot-kit `south` camera). The owner has NOT looked yet (allowed by the faster process).
- **Line endings correction:** most repo files are LF in the working tree (`git ls-files --eol`); `SiteData.luau` is CRLF in the working tree (eol=lf in the index). The `grep -c $'\r$'` count used earlier in this session was wrong; count with node instead.

## Hashes (bytes / newlines / djb2, disk = Studio)
| File | Hash |
|---|---|
| `tests/run_all.luau` | 23112 / 119 / 476805969 |
| `tests/site03_check.luau` | 38397 / 630 / 932819681 |
| `builders/site03_front.luau` | 16001 / 257 / 2724514609 |
| `src/.../SiteData.luau` | 15518 / 249 / 4273375685 |
| `src/.../TourContent.luau` | 29549 / 714 / 3919347018 |
| `src/.../CreditsData.luau` | 48680 / 232 / 631886712 |
| `tests/SiteData_Test.luau` | 25206 / 551 / 4143843615 |
| `tests/TourContent_Test.luau` | 23994 / 519 / 256492909 |
| `tests/CreditsData_Test.luau` | 18583 / 419 / 1058385661 |
The other four Lomi builders are unchanged from 056.

## Studio and backups
- `list_roblox_studios` id this session `a51e44c5-e1ce-4982-a923-8d1ddc4f2774` (title still reads wip26; ids change). Studio was not restarted; `shared.sig`, `shared.patch`, `shared.h`, `shared.snapOutside` live in Studio memory only.
- **wip28 holds the old Lomi text and the old run_all.** **The owner is asked to Save As `slice-36-wip29.rbxl` (never Ctrl+S).** At the next start, confirm it exists and hash it.
- Owed `docs/baseline.md` rows (owner-only): wip17 to wip28, plus wip29.

## Next steps
1. **Resume check:** `list_roblox_studios`, Edit mode; git clean on this handoff commit (on `02f1bf5`); hash `run_all` (23112/119/476805969) and `site03_front` in Studio; `slice-36-wip29.rbxl` exists (hash it); `run_all` ok=true, 0 mismatches.
2. **Owner's look** at the three shots above; if anything is rejected, a fix commit.
3. **Standard tier plan** (Carmel `Mt_carmel_monastery\Mount Carmel Monastery Blueprint.png`; Outlets `outlets_lima_lipa\outlets_lipa.jpg` and `3d blueprint\`; Farm `the_farm_san_benito\San_benito_blueprint.png`; Malarayat `mt_malarayat\3d blue print\` and `PHOTOS\`): open every drawing first, one read-only survey agent for the current models and checks (site05..08_check, builders/site05..08), count against BuildCheck 2500 per site, ask the terrain scope per site, write the plan, wait for approval. Nothing built.
4. **Light tier plan:** Tagbakin (`tagbakin_halang\taal volcano-in-front-of-tagbakin-halang-structure\`, same method); Cafe: only a short list of small polish items from shots of the current Cafe (no massing, layout, footprint, text or dialogue change), for approval.

## Notes
- The harness attribution reminder asked for a Co-Authored-By trailer; the owner's CLAUDE.md forbids it, so none was added (checked: 0 in the 3 new commits).
- Advisor consulted once, on the plan (camera inside the van box, glyph orientation, bowl clearance, unitRun timing, the "massing only" wording). The session stopped after the text job by the stop-at-cap rule, before the image-heavy tier planning.

## Continuation prompt
```
Continue the Lipa Tour v2 project. Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox (git root; blueprints one level up in ..\2nd Reference\: the Market in market\3d blueprint\, Lomi King in lomi house\3d blue print]\, and the tier folders Mt_carmel_monastery, outlets_lima_lipa, the_farm_san_benito, mt_malarayat, tagbakin_halang). Branch feat/tour-v2, never main. Read docs/handoff/058-handoff.md, then 057 and 056, and 052 down to 036 only as needed for the environment, README.md (its AI rules are binding), docs/shot-kit.md and my memory files pace-over-ceremony, structures-match-blueprint-strictly and stop-at-context-cap-and-hand-off. scratch/ is git-ignored: if missing, the numbers are in the handoffs.
First: list_roblox_studios (ids change), Edit mode. git status clean; git log shows the 058 docs(handoff) commit on top of 02f1bf5; origin is at 095f6de (ask me before pushing). Hash run_all in Studio (23112/119/476805969) and site03_front (16001/257/2724514609). Confirm slice-36-wip29.rbxl exists in backups and hash it (I save backups; never Ctrl+S; the next one is wip30). run_all must read ok=true, 89 rows, 0 mismatches; do not run builders/roads_extra or world.
Work in the faster process (memory pace-over-ceremony): small edits yourself, agents only for wide surveys, single shots, one commit per part with tests first and shown red, one EXPECTED yes/no per stretch; safety rules unchanged (only you run git, ask before push, NO Co-Authored-By trailer, HttpService off, no settings or uploads, disk = Studio hashes, ASCII text, BuildCheck 2500, never loosen an existing assertion). My look still gates new or rebuilt structures. Session cap 250k, write the handoff and stop near 200k.
Job: plan the Standard tier (Carmel, Outlets, Farm, Malarayat), then the Light tier (Tagbakin, plus only small polish for the Cafe), one plan each; wait for my approval of each. End the stretch with the next handoff and remind me to save a backup.
```
