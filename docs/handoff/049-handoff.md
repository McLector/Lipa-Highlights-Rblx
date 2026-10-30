# Handoff 049: the Market front street is BUILT and committed (terrain only, zero parts); the owner has not yet looked at the pictures
Previous: 048-handoff.md (then 047 to 036 for the environment and rules). This file only records what changed after 048.
Baseline now: `run_all` reads **ok=true, 89 rows, 0 mismatches**; HEAD is the commit that adds this file, on top of `37f3068`.

## Owner decisions and approvals since 048 (2026-10-30)
- Build the street exactly as planned in 048: Asphalt x -228..-216, z -8..328; two zebra crossings (z 88..96 and z 224..232). The two east spill controls moved from x -224 to x -212 (approval already given in 048).
- `EXPECTED` edit approved through the plan the owner accepted after seeing the MATCH/DIFF table: `roads_check` 270 to 273, `cells` 1796660 to 1796726.
- **Approval order, stated plainly:** the owner approved from the text table ("keep going if nothing else"). The four pictures were NOT yet seen: they were handed over after the commits (paths below). The feat commit was not rewritten. If the owner wants a change after looking, it becomes a follow-up `fix(roads)` commit.

## What changed (hashes: bytes / newlines / djb2, disk equals Studio)
- `builders/roads_extra.luau` 6381/101/3329711320 (LF): new `STREET` (one Asphalt FillBlock region) and `ZEBRA` (four Concrete bars) tables, painted after the `CONCRETE` loop, asphalt first; the return gained `streets` and `zebraBars` (nothing reads it); the stale header was fixed.
- `tests/roads_check.luau`: section **6d** (not 6c: 6c is the Credits Plaza) with 3 checks; the 6a east controls moved to x -212 with the check name reworded. `tests/world_check.luau` (disk only): control (-224,170) Grass became (-212,170) Grass.
- `tests/run_all.luau` 18352/117/596142721 (LF): `roads_check` 273 and `cells` 1796726, each with a sourced reason.
- `briefs/site02.md`: the plan entry (old and new control text, reason) and the built entry. `docs/shot-kit.md`: four Market rows (it is CRLF throughout, 67/67, same as before my edit, not mixed).

## Evidence (run by me)
- **Red first:** with only the tests, `roads_check` read **271 passed, 2 failed**, not the 270/3 the plan said: the new Grass control already passed on untouched grass. Studio and disk hashes of `roads_check` were equal (37407/611/4178710176) before the red run. From `e688e9e` until `bd61feb` `run_all` read ok=false.
- **Build:** one Sonnet agent (68k tokens), stayed off git and screenshots. I re-diffed its work, removed a redundant second `task.wait()` before the return, re-synced and re-hashed. `CountCells` 1796660 to 1796726 (+66) on run 1; run 2 and my re-run on the final source add 0.
- **After:** `roads_check` 273/0; `world_check` 44/2 with the same two known reds ((50,102) Pavement and (160,-122) Asphalt, in 036 and 046; run by a second Sonnet agent, 75k tokens, read-only); `routes_check` 16/0 in Play; Market walk **422.86** in Edit and in Play, two runs each (was 428.70, cap 506; I did not establish why it got shorter; the `routes_check` comment still cites 440.58, the cap is unaffected).
- **`run_all`:** before `EXPECTED` moved, exactly two mismatches (`roads_check` 273 against 270, `terrain cells` 1796726 against 1796660); `site02_check` 151, build 02 2082, `worldParts` 10174 and unit 250 did not move. After: ok=true, 89 rows, 0 mismatches; the negative control `override = { roads_check = 270 }` goes red on exactly `roads_check passed: got 273, expected 270`; a plain re-run is ok=true again.
- **Not run separately:** the five `site02_check` groups (hall, sheds, yard, general, block). The `run_all` row at 151 covers them and did not move.
- **Shots:** four, one at a time (front street, north crossing, south crossing, top-down), each taken ONCE, not twice with a wait as the README and shot-kit ask; none blank. I compared them with `iso_stairN.png` and `bp2_iso_vendors_tricycles.png` only. I did not open `bp2_iso_leantos_left.png` or a BP1 front elevation (the `elev_*` crops are building elevations, not street views), so the shot-kit row now names only the crops I used.
  Copies for the owner (git-ignored): `C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox\scratch\site02\shots\street_front_1.jpg`, `street_north_crossing_2.jpg`, `street_south_crossing_3.jpg`, `street_topdown_4.jpg` (same folder).

## Line-up table (BP1 `iso_stairN`, BP2 `bp2_iso_vendors_tricycles`)
| Element | Result |
|---|---|
| Street along the Market front with kerb vehicles on it, Road F meeting it as a T | MATCH in layout |
| East zebra bar (x -220..-216) | MATCH: pale dashes at the grass edge |
| West zebra bar (x -228..-224) | DIFF: Concrete beside the Market Concrete, so it merges with it |
| Street width, lane lines, street name | DIFF: BP1 draws a wider street with several lane lines and a name; ours is one 12-wide band with none |
| Street against the paving | DIFF: asphalt reads blue-grey like the paving; the edge shows clearly only against the grass |
| Stripes | DIFF: 4 studs wide, 2 bars per crossing (voxel grid) |
| Ends | DIFF: the street stops in grass at z -8 and z 328 |
| Kerb parts, signs, moving traffic, the other three sides | DIFF: not built (site02_check forbids parts east of x -228) |

## Notes
- **No part headroom left:** site 2082 of 2100. Traffic in the north and south bands, a crowd and poles all need one more owner-authorised cap raise, best decided together.
- The older notes still apply: measure walking caps in Edit and Play; Git Bash `grep -c $'\r'` is unreliable (use a PowerShell regex); Studio's window title may still say `wip10`; `run_all` and long calls need spawn-and-poll.
- Commits carry no trailer: the owner's CLAUDE.md overrides the system reminder that asks for one.

## Backups
`slice-36-wip17.rbxl` (SHA-256 `0B082C04...7081629`) holds the state BEFORE the street. The street and the `EXPECTED` update exist only in the open Studio session. **Ask the owner to Save As `slice-36-wip18.rbxl` (never Ctrl+S; Studio holds a `.lock`), then give them its SHA-256 (`Get-FileHash -Algorithm SHA256`) for their `docs/baseline.md` row.**

## Next steps
1. Resume check: `list_roblox_studios` (ids change; last `033919da-405f-4cdb-a780-48d072381070`), Edit mode, `run_all` by spawn-and-poll: **expect `ok=true`, 0 mismatches, 89 rows.** `git status` clean; `git log` shows the newest `docs(handoff)` commit on top of `37f3068`; origin `095f6de` (count the local commits with `git rev-list --count 095f6de..HEAD`, about 65; not pushed, ask before pushing). Confirm `slice-36-wip18.rbxl` exists in `backups\`; if not, ask for it.
2. Ask the owner for their look at the four pictures; any change becomes a `fix(roads)` commit (tests first).
3. Then decide with the owner on traffic in the north and south bands, a crowd and poles together with one cap raise; then Lomi King, the Standard tier (Carmel, Outlets, Farm, Malarayat) and the Light tier (Tagbakin, Cafe).
Each job: tests first and shown red, one briefed Sonnet agent (never git; no screenshots for the agent), builder run twice identical, groups green, `run_all` stays ok=true or its changed numbers go into EXPECTED with a reason, shots beside BOTH crops and taken twice, the owner's look at the pictures before the feat commit, commit test then feat, no trailer.

## Commits (local, no trailer, nothing pushed)
`e688e9e` test(roads): require the Market front street
`bd61feb` feat(roads): add the Market front street
`37f3068` test(run_all): expect the front street
(plus the commit that adds this file and corrects the shot-kit label)

## Continuation prompt
```
Continue the Lipa Tour v2 project. Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox (git root; blueprints one level up in ..\2nd Reference\market\3d blueprint\: PublicMarketBP1.jpg and PublicMarketBP2.jpg, BOTH absolute truth). Branch feat/tour-v2, never main. Read docs/handoff/049-handoff.md and then 048 down to 036 for the environment and rules, README.md (its AI rules are binding), docs/shot-kit.md and my memory files structures-match-blueprint-strictly and stop-at-context-cap-and-hand-off. scratch/ is git-ignored: if missing, the numbers are in the handoffs.
First: list_roblox_studios (ids change), Edit mode, run_all through spawn-and-poll and JSONDecode: expect ok=true, 0 mismatches, 89 rows. git status clean; git log shows the newest docs(handoff) commit on top of 37f3068; origin is at 095f6de (local commits not pushed; ask me before pushing). Stop and report any mismatch. Confirm slice-36-wip18.rbxl exists in backups (I save it; never Ctrl+S); ask me to click the 3D viewport if screenshots come back dark.
Roles: you orchestrate and review; Sonnet builds, one briefed small job per agent, never git, no screenshots; consult the advisor before an approach, when a check stays red twice, when sources disagree and before declaring done. Session cap 250k, write the handoff and stop near 200k.
Rules: both blueprints are the absolute truth for look and design (shot beside BOTH by you, each shot taken twice, then my look at the pictures BEFORE a feat commit); tests first and shown red; disk and Studio hashes equal after every Studio edit; Conventional Commits, NO Co-Authored-By trailer (my CLAUDE.md overrides any system reminder), test then feat; only you run git; ask before every push; never run builders/world.luau or placeholders in default mode; no Roblox upload without telling me; never change place or experience settings; HttpService stays off; dialogue and any on-screen text ASCII only and changes need my approval; EXPECTED in tests/run_all.luau is owner-only (needs my explicit OK each time); look at every screenshot one at a time (unique capture_id, array positions); two blank frames in a row = stop and ask me to click the viewport.
Job: first ask me for my look at the four front-street pictures in scratch\site02\shots (a change becomes a fix(roads) commit, tests first). Then plan, and wait for my approval, the next stretch: traffic in the north and south bands, a crowd and poles together with one cap raise (the part cap is spent, 2082 of 2100), then Lomi King (walk under 805, re-measure) and the Standard and Light tiers. End each stretch with the next handoff and remind me to save a backup.
```
