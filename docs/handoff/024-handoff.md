# Handoff 024 — Slice 23 (Ship), automated part finished; user steps still open
Date: 2026-10-22 · Previous: 023-handoff.md

## Status
- **The automated part of Slice 23 is done and committed. Slice 23 is NOT complete:** the credits identity, thumbnail/icon, public publish, game settings and live-server check need the user. The user asked to finish without further questions, so this handoff records exactly what is left. Site rework is paused: the user is looking for better references and will ask for a second pass later.
- This pass re-ran the full playtest on the reworked geometry (9/9 by walking and jeepney, negatives, three-device UI pass, scene and console) and fixed one defect: a stale guide dialogue left on screen after walking or riding away. Evidence: `docs/ship/slice-23-playtest.md`.

## Environment
Studio id `68aceec4-73fa-4e06-8b5c-4e4b73538e37`, Edit mode, device simulator reset to default. **Backup: `backups\slice-23.rbxl` saved 12:31 (394,178 B), includes the dialogue fix.** Earlier: `slice-22.rbxl`. The live private place (138036647354961) still holds the Slice 03 state; nothing pushed, no git remote.
**The 3D viewport is not rendering** (screen_capture returns only the axis gizmo in Edit, and a black world behind the UI in Play), even after the user brought Studio to the foreground. UI captures work. Thumbnail candidates were therefore not taken.

## Commits this slice (no Co-Authored-By trailer)
`19545f8` fix(slice-23): close the guide dialogue when the player walks or rides away · `23aaa78` docs(ship): record the slice-23 playtest on the reworked sites · plus this handoff.

## Verification evidence (final state, Edit mode)
```
site03 74/0 · site04 41/0 · site07 34/0 · site08 29/0 · site09 26/0 · sites 256/0 · qa 44/0 (was 42; +2 checks, shown red 42/2 first) · routes 11/0 · site01 75/0 · site02 45/0 · site05 71/0 · site06 49/0
unit {"failed":0,"run":127,"passed":127}
BuildCheck 01 16/0 1639 | 02 15/0 1104 | 03 15/0 375 | 04 14/0 663 | 05 15/0 472 | 06 15/0 687 | 07 14/0 682 | 08 14/0 657 | 09 15/0 392
checkWorld 1/0 parts=6691 · cells 1793270 · pivots unchanged (Site08 y 19.8)
hashes Studio = disk (djb2, LF): qa_check 10558/184/2256716189 · GuideClient 7669/231/435231543
```
Playtest highlights: HUD 1/9 to 9/9, certificate at 9/9, client part counts equal BuildCheck after every ride, burst of 20 gives 1 accepted and 19 rate-limited, bad ids all `invalid_id`, far stamps `too_far`, bad jeep requests 0.00 studs, mute 0.25 -> 0 -> 0.25. Device pass 0 issues on Galaxy A06 landscape, iPad 10th gen, iPhone 17 Pro portrait.

## Decisions & deviations
1. Only the dialogue defect was fixed. The iPhone-portrait certificate cell 1 (long name) renders at about 12 px; a fixed TextSize would break "Independencia", so it needs a different portrait layout (not done).
2. Source-string checks in `qa_check` cover the fix; behaviour was verified in Play (+10 studs stays open, +60 closes, reopen works, closes after a jeep ride).
3. TourCamera stays cut (first cut in the plan).

## Known issues / gotchas
- **Unexplained once:** a jeep request after a +45 stud client teleport moved the player 692 studs (accepted). Two exact reruns were refused (`not_at_stop`, server saw 45.1 studs). Server position was not read in the accepted run. Likely the teleport had not replicated. If it matters, re-test while reading the server `HumanoidRootPart` before firing.
- A Play session's first character is placed by Studio (4.0, 58.8) facing NE; `LoadCharacter` gives the real spawn (-1, 70) facing -Z.
- `user_mouse_input` with `instance_path` missed the Welcome Start button (IgnoreGuiInset gui); explicit x,y worked. The `AbsolutePosition + GuiInset` rule holds for every ScreenGui, including IgnoreGuiInset ones.
- Device simulator: set the device first, then the orientation (orientation errors before a phone is active); setters error in Play.
- Not tested: SceneAnalysisService itself, real touch hardware, audio audibility on a live server, streaming on a live server.

## Pending on the user
1. **Credits identity** (name, course, section) -> `CreditsData.identity`, `pending=false`; then re-run `builders/credits.luau`, `tests/credits_crosscheck.ps1`, the unit suite.
2. **Studio viewport:** get the 3D view rendering again (restart Studio from `backups\slice-23.rbxl` only after confirming the backup opens), then icon and thumbnail screenshots (Cathedral plaza, an overview, Tagbakin lakeshore).
3. **Publish** to place 138036647354961 (File > Publish), set Public, Maturity & Compliance questionnaire, experience icon + thumbnail, description, genre, Max Players about 40.
4. **Live-server check** with me: scripts current (hash a live script), audio audible, streaming during jeep travel.
5. Better reference photos for any site (second rework pass, per site: brief diff list -> red check -> rebuild -> BuildCheck + screenshots -> sign-off).

## Next steps (when the user is back)
1. Resume check: `list_roblox_studios`, Edit mode, the battery above (qa is 44/0 now), `backups\slice-23.rbxl` exists.
2. Do whichever of the pending items the user has ready; Ship is done only when 1, 3 and 4 are done. Then write handoff 025.

## Continuation prompt
```
Continue the Lipa City Roblox art-appreciation project: Slice 23 (Ship) is half done (automated playtest finished and committed; publish, credits identity, thumbnails and the live-server check are open). Read C:\Users\morad\.claude\plans\so-i-ve-got-refactored-spring.md, then C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox\docs\handoff\024-handoff.md and docs\ship\slice-23-playtest.md. Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox.
First: list_roblox_studios (if empty, ask me to open backups\slice-23.rbxl) -> Edit mode -> re-run the stored checks (site03 74/0, site04 41/0, site07 34/0, site08 29/0, site09 26/0, sites 256/0, qa 44/0, routes 11/0, site01 75/0, site02 45/0, site05 71/0, site06 49/0), the unit suite (127/127), BuildCheck for all nine sites and checkWorld (6691 parts), the pivots and the cell count (1793270). Stop and report any mismatch.
Then ask me which Ship items are ready (credits identity, thumbnails, publish) or which site to rework with new references. Rules: Conventional Commits with NO Co-Authored-By trailer; checks first and shown red; hash Studio vs disk (djb2, LF-normalised, node); look at every screenshot for text and scale bugs (use a fixed TextSize for long labels); never restart Studio without a saved backup; do not drag models in the viewport; dialogue stays ASCII.
```
