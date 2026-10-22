# Slice 23 (Ship): automated playtest on the reworked sites

Date: 2026-10-22. Studio `68aceec4-73fa-4e06-8b5c-4e4b73538e37` (open file `slice-14.rbxl` title, content = `slice-22.rbxl` saved 12:03). Edit-mode battery matched handoff 023 before and after this pass. All numbers below are real tool output from this session. Not done here: public publish, game settings, live-server check, the credits identity (user), thumbnail captures (viewport blank, see the end).

## Resume check (Edit mode)
```
site03 74/0 · site04 41/0 · site07 34/0 · site08 29/0 · site09 26/0 · sites 256/0 · qa 42/0 · routes 11/0 · site01 75/0 · site02 45/0 · site05 71/0 · site06 49/0
unit {"failed":0,"run":127,"passed":127}
BuildCheck 01 16/0 1639 | 02 15/0 1104 | 03 15/0 375 | 04 14/0 663 | 05 15/0 472 | 06 15/0 687 | 07 14/0 682 | 08 14/0 657 | 09 15/0 392
checkWorld 1/0 parts=6691 · cells 1793270 · pivots as SiteData (Site08 y 19.8)
```

## Full walk (Play, default viewport, real input)
- Spawn: SpawnLocation (0, 0.5, 70) look (0,0,-1). `LoadCharacter` lands at (-1.2, 70.3) look (0,0,-1). **The first character of a Play session was at (4.0, 58.8) look (0.71,0,-0.71)**: Studio's Play placement, not our code (nothing in src moves the character).
- Guides 1 to 4 on foot with `character_navigation` + E: HUD `Passport 1/9` ... `4/9`.
- Jeepney from the Cathedral stop (-20, 30) to 5, 6, 7, 8, 9 (menu clicked, `LastJeepResult=ok:n`), each guide stamped by E: `5/9` ... `9/9`. The certificate opened by itself at 9/9 ("Lipa Passport Complete", local date).
- Streaming after each ride: client part counts equal BuildCheck (Site05 472, Site06 687, Site07 682, Site08 657, Site09 392).
- Return ride Tagbakin -> Cathedral stop: arrived (-20, 8.1, 30).
- Mute: volume 0.25 -> 0.00 ('Sound: Off') -> 0.25 ('Sound: On'). `AmbientTown` IsLoaded, IsPlaying, TimeLength 67.7, Looped.
- Note: the first explicit-coordinate click on the jeep menu did nothing; the `instance_path` click worked (the stale dialogue was open then).

## Negatives
- Invalid ids (0, -1, 3.5, "9", NaN, inf, {}, "x", nil), spaced 0.7 s apart: all `invalid_id`, `new=false`; 99: `invalid_id`.
- Far: ids 5 to 9 from the Cathedral stop: all `too_far`.
- Burst: 20 same-instant requests: `{"true/nil/new=false":1,"false/rate_limited/new=false":19}`.
- Jeep from the stop: "NOPE", 999, -1, 3.5, nil, {}, 2 (no stop), 1 (same stop): all 0.00 studs moved.
- Jeep from 45 studs off a stop: two reproduced runs gave `not_at_stop`, 0.00 studs (server confirmed 45.1 studs). **One earlier run moved the player 692 studs to Carmel from a +45 stud client teleport. I did not read the server position in that run and could not reproduce it** (STOP_RADIUS is 20, the rule reads the server's `HumanoidRootPart`). Likeliest cause: the client-set CFrame had not replicated, so the server still saw the player at the stop. Unproven.
- Not re-run in this pass: the "1 new stamp out of a burst" count on a fresh passport (the passport was full); handoff 023 recorded exactly 1.

## Device pass (setters before Play; measured on the client; real position = AbsolutePosition + GuiInset)
```
Galaxy A06 landscape 705x338:  HUD, dialogue box 564x150 (y 176-326), jeep box 420x291 (y 24-314), certificate 580x304 (y 17-321): 0 issues
iPad 10th gen 1179x819:        Welcome, HUD, dialogue 680x132, jeep box 420x480 (y 170-650), certificate 580x500: 0 issues
iPhone 17 Pro portrait 401x778: Welcome, HUD, dialogue 321x202 (y 564-766), jeep box 361x480 (y 149-629), certificate 345x500: 0 issues
```
Checks per object: off-screen, buttons under 44 px, TextBounds beyond the box. Screenshots looked at: A06 certificate, iPhone jeep menu (after Start) and iPhone certificate.
- To reach 9/9 for the certificate on each device I stamped through the real `StampRequest` after moving next to each guide (script), not by walking.
- My first measuring script reported the Welcome screen off-screen: a bug in the script (IgnoreGuiInset gui still needs the inset added). Real Dim (0,0)-(705,338), Panel (82,49)-(622,289).
- iPhone portrait certificate: cell 1 ("1. Plaza Independencia & Metropolitan Cathedral") renders at about 12 px (4 lines, 59 px of 109); short names about 17 px. Legible, small. The cells are 96 px wide and "Independencia" only fits at about 12 px, so a fixed `TextSize` would break the word; a fix needs a different portrait layout (not changed).
- Welcome vanished by itself once in the A06 run (only Start destroys it; probably a stale mouse position). It was present in the other runs.

## Scene and console
- Server: 6713 parts = 6691 world + 22 character parts; unanchored non-rig parts 0; ServerScriptService: UnitTestRunner (disabled), PassportServer, JeepneyServer, NpcIdle.
- Log history: server errors/warnings other than UIBlox 0; client 0 from game scripts (one entry was my own probe, `MinTextSize`). Console is otherwise the UIBlox `FoundationProvider` warning.
- I did not run SceneAnalysisService itself.

## Defect found and fixed: stale guide dialogue
The Tagbakin dialogue stayed on screen (with Next/Close) after riding to the Cathedral and showed under the jeep menu and certificate; the JeepMenu (DisplayOrder 11) is above it, so taps were not blocked.
- Red first: `qa_check` 42 passed / 2 failed (`LEAVE_DISTANCE` 0; no `openedAt`).
- Fix: `GuideClient` records the player's position when the dialogue opens and closes it on Heartbeat once the player is more than `LEAVE_DISTANCE = 30` studs away.
- Green: `qa_check` 44/0; Studio vs disk hashes (djb2, LF): qa_check 10558/184/2256716189, GuideClient 7669/231/435231543, identical.
- Behaviour in Play: opened (Enabled=true) -> +10 studs still open -> +60 studs closed (DialogueOpen false); reopened with E (site 1); after a jeep ride to Carmel closed.
- Full battery after the fix: all 12 stored checks as above except qa 44/0; unit 127/127; BuildCheck, parts 6691, cells 1793270, pivots unchanged.

## Thumbnail captures
Two `screen_capture` calls in a row came back blank (only the axis gizmo) after the Play sessions: the known viewport issue. Stopped per the rule. Needs Studio brought to the foreground before more captures.
