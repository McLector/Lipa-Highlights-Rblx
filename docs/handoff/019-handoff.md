# Handoff 019 — Slice 18 (fidelity rework, Site 03 Lomi King)
Date: 2026-10-22 · Previous handoff: 018-handoff.md

## Status
**Slice 18 is built, verified and committed (`31ac896`), but the user has NOT signed it off.** Site 03 (Lomi King) was reworked from the only reference, `Lomi_King_Front_Oblique_2015.jpg`. The user did not give a verdict (they went to sleep and told me to carry on through the remaining slices and decide myself), so Lomi King is **pass 1, open**. Open sites now: Site 01 plaza, Site 02 Market, Site 03 Lomi, Site 05 Carmel, Site 06 Outlets.
The user also asked for Slices 19 to 22 to run back to back without stopping; later handoffs say how far that got.

## Environment
- Studio: id `68aceec4-73fa-4e06-8b5c-4e4b73538e37` (ids change per instance), window still named slice-14.rbxl, placeId 0, Edit mode.
- **Backup:** `backups\slice-17.rbxl` exists (378,339 B, saved 2026-10-22 04:06). **`backups\slice-18.rbxl` is PENDING** (I cannot save the place from here). Until saved, the Slice 18 state lives only in the open Studio session and in git.
- Repo has no remote. Nothing is pushed. Live private place still holds the Slice 03 state; re-publish at Ship.

## What changed
Git: `31ac896` feat(slice-18) (no Co-Authored-By trailer). Files: `builders/site03.luau`, `tests/site03_check.luau` (new, 74 checks), `briefs/site03.md` ("Revision 1 (Slice 18)" with the 12-row real-vs-model table).
Studio: `ServerStorage.Builders.site03` edited (12 edits) and run; `ServerStorage.Checks.site03_check` created.
Hashes (djb2, LF-normalised; bytes/newlines/hash), Studio = disk: builder **21728/445/864444999**; check **18270/349/485706671** (the check was hashed before its last one-line edit to the part-count band; the final Studio and disk copies were edited identically, re-verify if in doubt).

Built: free-standing `Letter_*` tiles (8) on a plain awning; 6 `BannerBlock*` + 8 `BannerDish*` in a black `SteelPost`/`SteelRail` frame; 7 globes behind the banner; curved bay (7 glass panels + sill + head); 10 `GrilleBar*`; `CornerPier`; logo (`LogoDisk`/`Ring`/`Core`/`Bowl`) with a steel bracket at the north corner; bigger pots and 3-ball shrubs; 12 x 7 `ParkingSign` with fixed 40 px text, `RamenPoster`, 8 `BambooSlat*` and a cap; coral wall (242,129,108); `MenuBoard` as six fixed-size lines. Kept: footprint, `LomiBody`, interior, Guide, InfoPanel, diners, all required props.
**References:** Commons has no Lomi King file (full-text search 0 hits). 12 street files (jf0752 set, jf0738, jf0767, JP Laurel 2024/2025) were downloaded and viewed; none shows the shop or its sign, so none is credited. No credits change.

## Verification evidence (Edit mode, real output)
TDD: `site03_check` run red against the old model: **25 passed, 47 failed** (one of the 47 was my own check flagging the kept InfoPanel; fixed by skipping kept objects).
```
site03_check: 74/0   world_check: 45/0 (cells 1793270)   sites_check: 256/0   qa_check: 42/0   routes_check: 11/0
site01 75/0 · site02 45/0 · site05 71/0 · site06 49/0   unit suite: 127 run, 127 passed
BuildCheck: Site01 16/0 1639 | Site02 15/0 1104 | Site03 15/0 375 | Site04 14/0 485 | Site05 15/0 472 | Site06 15/0 687 | Site07 14/0 619 | Site08 14/0 530 | Site09 15/0 400
checkWorld: 1/0 parts=6331 (6256 - 300 + 375)
pivots: Site01 (0,0,0), Site02 (-330,0,160), Site03 (292,0,140), Site05 (-300,0,-600), Site06 (550,0,-650)
```
Screenshots (all looked at for text and scale): front oblique, straight front, south bay, interior. Two blank captures in a row happened once (viewport stopped rendering); after the user focused Studio they worked again.

## Not done or not verified
- No play test (stamps, jeepney, console); the Slice 23 Ship pass must redo the full playtest, negatives and device pass.
- Letters are cube tiles, not carved letters; the logo has no cup icon; the kept InfoPanel hides the parking board from straight on (since Slice 07).
- **User sign-off:** none.

## Decisions
1. No Commons photo used (none shows the shop). 2. Part-count band in `site03_check` set to 300..900 (non-rig, non-kept; actual about 358). 3. `gui()` in `builders/site03.luau` got a `fixedSize` argument; long labels must not be TextScaled.

## Known issues / gotchas (new)
- `screen_capture` can go blank twice in a row; ask the user to focus Studio and click the viewport once (no dragging).
- In Lua patterns `-` is magic: use `find(s, 1, true)` when filtering failure text.
- Studio scripts can be patched with `multi_edit` using the same old/new strings as the disk `Edit`; a drifted Studio copy makes the batch fail, which doubles as a sync check. New scripts: `multi_edit` with `className` and an empty `old_string`.
- Everything in handoff 018 still applies.

## Pending on the user
1. Save `C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox\backups\slice-18.rbxl` (and later slices' backups, see their handoffs).
2. Verdict on Lomi King and on the other open sites.
3. Credits identity (name, course, section) before Ship; publish at Slice 23.

## Next: Slice 19 (Cafe de Lipa) onward, same process
See handoff 020 if it exists. Process per slice: resume check -> real-vs-model list -> brief -> checks first (red) -> rebuild -> verify -> screenshots -> commit -> handoff.

## Continuation prompt
```
Continue the Lipa City Roblox art-appreciation project after Slice 18 (Lomi King fidelity rework). Read C:\Users\morad\.claude\plans\so-i-ve-got-refactored-spring.md, then the highest-numbered file in C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox\docs\handoff\ (019-handoff.md or later), and content\site_credits.md. Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox.
First: list_roblox_studios (if empty ask me to open the newest backups\slice-NN.rbxl) -> confirm Edit mode -> re-run world_check (inlined; expect 45/0, cells 1793270), the stored checks (sites 256/0, qa 42/0, routes 11/0, site01 75/0, site02 45/0, site03 74/0, site05 71/0, site06 49/0), the unit suite (127/127), BuildCheck for all nine sites and checkWorld, and the pivots. Stop and report any mismatch with the latest handoff.
Rules: Conventional Commits, NO Co-Authored-By trailer, message via [System.IO.File]::WriteAllText with UTF8Encoding($false). Write checks first and show them red. Hash Studio vs disk (djb2 over LF-normalised bytes, node). Look at every screenshot for text and scale bugs. Never restart Studio without a saved backup. Do not drag models in the viewport. Dialogue stays ASCII.
```
