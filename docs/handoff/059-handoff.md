# Handoff 059: presentation prep; every site checked on screen and the full tour played clean; the tier rebuilds are SHELVED
Previous: 058-handoff.md (then 057, 056). This file only records what changed after 058.
Baseline: `run_all` **ok=true, 89 rows, 0 mismatches** (run by me at the start and again after Play). No script or model changed this session. HEAD is the commit that adds this file, on top of `55b9462`; origin is `095f6de` (nothing pushed, ask before pushing).

## Owner decisions this session (2026-10-31)
- **Out of time: about 2.5 h (3 h limit) before the presentation.** The teacher plays on the owner's laptop and 2 to 8 group mates join, i.e. a live multiplayer Roblox server. The plan "presentable first" was approved: sweep, play the tour, fix only what breaks, the owner publishes.
- **The Standard tier rebuilds and the Light tier are SHELVED** until after the presentation. The draft Standard tier plan (Carmel, Malarayat, Outlets, Farm: method, budgets, pins to replace, text rows, terrain defaults) is in `scratch/standard_tier_plan.md` (git-ignored). The owner never approved it. The Malarayat rock sign and the Tagbakin volcano quick wins were dropped.

## Evidence (run by me)
- **Resume:** git clean on `55b9462`; `run_all` 23112/119/476805969 and `site03_front` 16001/257/2724514609 equal on disk and in Studio; `slice-36-wip29.rbxl` 682,170 bytes, SHA-256 `049CDE5673678F8F26C4A6F1EC141D7695BF0C0B82392AF58C8AE57C3C785923` (matches); HttpEnabled false; `UnitTestRunner` disabled; StreamingEnabled true.
- **Standard tier survey (read-only):** all four boards, `outlets_lipa.jpg`, Malarayat photos 01 to 03 and the three Tagbakin pictures opened. Current part counts: Cafe 705, Carmel 514, Outlets 748, Farm 723, Malarayat 703, Tagbakin 420. Malarayat's board gatehouse is cream, its photo dark grey (open question). The new Tagbakin folder has volcano views only, and `tagaytay-volcano.webp` is a view from Tagaytay, not from Lipa.
- **Visual sweep (one shot per site, shot-kit overview rows, looked at):** all 10 sites presentable, no floating parts, holes or clipped text. Notes: the first capture after a camera move is blank and the retake renders (every site this session); the Market overview row now sits inside the rebuilt hall's facade (needs a new row); the Cafe InfoPanel looks cut off only from the oblique overview (a straight shot at 232,6,-148 shows it whole); the Lomi arc and parking sign read fine.
- **Play (Studio solo):** spawn at the City Hall pad (-207,4,-256); Welcome shows, Start closes it; real E at the City Hall guide opened Ate Joy's dialogue and stamped 1/10; the jeep menu opens with E and lists 1, 5 to 10. The tool's mouse clicks on the menu buttons did not register (twice); the buttons are Active at the right place and `Activated` only fires `JeepRequest`, so the rides were driven by firing that remote: rides 5, 6, 7, 8, 9 and 1 all `ok:N`; stamps for all 10 sites `ok`; `StampList` 1..10; the certificate opened by itself ("Lipa Passport Complete", 10 places); `AmbientTown` playing at 0.25. Console: no errors from our scripts. After Play: `run_all` ok=true, 0 mismatches.
- **Multiplayer (read-only code review):** `PassportServer` and `JeepneyServer` key state by player and clear it on leave; no DataStore (stamps reset each visit); guides and stops use ProximityPrompt (touch and gamepad work). A real multi-client test needs the live server.
- **Text:** no `[VERIFY]` in SiteData or TourContent. Non-ASCII: "Cafe de Lipa" is spelled with an e-acute in `SiteData.luau` L80 and L87 (it renders fine; landmark names need the owner, so it was not changed).

## Owner actions
1. **Publish** the current place to placeId 138036647354961 (the live place still holds the Slice 03 state and is private), then set access so the group mates can join; Roblox may ask for the maturity questionnaire first. Publishing and settings are owner-only.
2. Live check with one group mate: both get the Welcome screen, stamps stay separate, the jeepney works, the far sites stream in.
3. No new backup is needed for this session: nothing changed, so the place still equals `slice-36-wip29.rbxl`. The next Save As is `slice-36-wip30.rbxl` (never Ctrl+S).
4. Owed `docs/baseline.md` rows: wip17 to wip29.

## Next steps (after the presentation)
1. Resume check as in 058 (wip29 hash above).
2. Decide on the Standard tier plan in `scratch/standard_tier_plan.md` (defaults: the board wins over the Malarayat photo, Outlets at 1.05 studs/m, no brand logos, terrain per site), then the Light tier plan (Tagbakin and a short Cafe polish list).
3. Small open item: a new Market overview camera row in `docs/shot-kit.md`.

## Continuation prompt
```
Continue the Lipa Tour v2 project. Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox (git root; blueprints in ..\2nd Reference\). Branch feat/tour-v2, never main. Read docs/handoff/059-handoff.md, then 058 and 057, README.md (its AI rules are binding), docs/shot-kit.md and my memory files pace-over-ceremony, structures-match-blueprint-strictly and stop-at-context-cap-and-hand-off. scratch/ is git-ignored: the draft Standard tier plan is scratch/standard_tier_plan.md.
First: list_roblox_studios (ids change), Edit mode. git status clean; git log shows the 059 docs(handoff) commit on top of 55b9462; origin is at 095f6de (ask me before pushing). Confirm the newest backup in backups (wip29 SHA-256 049CDE5673678F8F26C4A6F1EC141D7695BF0C0B82392AF58C8AE57C3C785923, or wip30 if I saved one) and run_all ok=true, 89 rows, 0 mismatches; do not run builders/roads_extra or world.
Faster process (memory pace-over-ceremony); safety rules unchanged (only you run git, ask before push, NO Co-Authored-By trailer, HttpService off, no settings or uploads, disk = Studio hashes, ASCII text, BuildCheck 2500, never loosen an existing assertion). My look gates new or rebuilt structures. Session cap 250k, write the handoff and stop near 200k.
Job: walk me through the Standard tier plan in scratch/standard_tier_plan.md for approval, then plan the Light tier (Tagbakin, plus only small polish for the Cafe). End the stretch with the next handoff and remind me to save a backup.
```
