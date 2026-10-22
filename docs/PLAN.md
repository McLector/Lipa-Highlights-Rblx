# Project plan (adapted from the original master plan for team use)

The original plan was written for one author and lived outside the repo. This is the team version: same design, with the working process replaced by the one in the README. Status as of 2026-10-22.

## What it is
A Roblox experience where players visit 9 structures that represent modern Lipa City, Batangas. At each site an NPC guide introduces the place. Lipa Passport (x of 9) plus jeepney fast travel. Interiors only for Lomi King and Cafe de Lipa. Presented published (public) and as a recorded video. English dialogue. Built from scripted parts (no photo textures).

Inputs (kept outside the repo, shared privately): the world layout image (authoritative), the highlights and requirements document (its "What You Could Display" column is a requirement), and the reference photos with notes. Every site brief (`briefs/siteNN.md`) lists the photos it used and what is approximated.

## Status by slice
| Slice | What | State |
|---|---|---|
| 00 | Foundation (terrain, roads, lake, boundary, spawn) | done |
| 01 | Systems and placeholder sites | done |
| 02 to 11 | BuildCheck, kit, nine site builds | done |
| 12 | Content gate (dialogue approved, loaded into `SiteData`) | done |
| 13 | Polish and QA (credits board, welcome, certificate, audio, device pass) | done |
| 14 to 22 | Fidelity rework, one pass per site from new photos | done once for all nine; **second passes wait for better references** |
| 23 | Ship | automated playtest done (`docs/ship/slice-23-playtest.md`); open: credits identity, thumbnails and icon, publish and settings, live-server check |

If time runs short, cut in this order: TourCamera (already cut), certificate, ambient audio, interior detail. Never cut the 9 guides or their art-observation dialogue.

## Coordinates and scale
- North is -Z, East is +X, Y is up. Footprints are world-aligned X by Z. Site pivot Y equals `groundY`.
- Spawn at (0, y, 70) facing -Z at the Cathedral. Boundary walls at +-1000. Backdrops (Malarayat range, Taal Lake with the volcano) are Persistent models.
- `massScale` per site in `SiteData`. Human-scale parts are fixed everywhere: doors at least 8 studs, risers 1, railings 3, counters 3.5, chairs 2, storey at least 12. Compress by dropping repeats, never by shrinking those.
- Malarayat sits on a slope rising 0 to about 40 toward the east; Tagbakin's footprint contains the shoreline (water surface flush at y = 0).

## The nine sites
| # | Site | Pos X,Z | Faces | Notes |
|---|---|---|---|---|
| 1 | Plaza Independencia and Metropolitan Cathedral of San Sebastian | 0,0 | S | spawn, jeep hub, plaza people, stage |
| 2 | Candido B. Lopez Memorial Public Market | -330,160 | E | stalls, vendors (moved from -230 to avoid overlap) |
| 3 | Lomi King | 292,140 | W | interior counter and tables |
| 4 | Cafe de Lipa (Tibig/STAR branch only) | 272,-160 | W | interior labelled representative |
| 5 | Monastery of Our Lady of Mount Carmel | -300,-600 | S | prayer space, history panels (neutral, sourced wording) |
| 6 | The Outlets at LIMA Estate and Aboitiz Pitch | 550,-650 | SW | model pedestal, Lipa-Malvar map panel |
| 7 | The Farm at San Benito | 700,240 | W | villa, pavilion, wellness panel |
| 8 | Mount Malarayat Golf and Country Club | 560,720 | NW | clubhouse, pool, holes, leisure panel |
| 9 | Tagbakin, Brgy. Halang | -600,550 | NE | lakeshore building (not called glamping), dock, location map, fishing |

Naming: "The Outlets at LIMA Estate" (renamed 2025). Café: the interior is representative. Market: use its proper name and note the 2014 photos. Tagbakin: no glamping claims beyond "the city records a glamping development". Every landmark name needs a source; misnaming a landmark is the easiest way to lose points.

## Architecture (all text, mirrored on disk)
- `ReplicatedStorage/LipaShared`: `SiteData` (nine entries, `facingToYaw`, `jeepStopPos`), `PassportLogic`, `DialogueLogic`, `CertificateLogic`, `CreditsData`, `Remotes` (`StampRequest`, `JeepRequest`).
- `ServerStorage`: `BuildKit`, `BuildCheck`, `Builders/*`, `Checks/*`, `UnitTest/*`, `LipaServer/{StampRules,JeepRules}`.
- `ServerScriptService`: `PassportServer` (validates site and distance, 0.5 s rate limit), `JeepneyServer` (validates, 3 s cooldown, moves the player), `NpcIdle`.
- `StarterPlayerScripts`: `GuideClient`, `PassportClient`, `JeepneyClient`, `WelcomeClient`.
- `Workspace/World` (terrain, plaza, boundary, backdrops, CreditsBoard) and `Workspace/Sites/SiteNN_*` (pivot at pos and facing; Guide rig, InfoPanel, JeepStop, parked jeepney).
- Disk layout: `builders/` (idempotent builders), `src/` (script mirrors), `tests/` (checks and unit tests), `briefs/`, `content/`, `docs/`. Sync is one way: **disk to Studio**.

## Testing
- Unit tests run with the built-in harness (`ServerStorage.UnitTest.RunUnitTest`); the checks under `ServerStorage.Checks` verify the model of each site and the whole world.
- `tests/run_all.luau` runs everything and compares with `EXPECTED` (the one place the baseline numbers live).
- BuildCheck: model exists, pivot within 1 stud, facing dot greater than 0.99, bounds inside the footprint plus 10 percent, required children and props present, at most 2,500 parts per site and 20,000 for the world, all non-rig parts anchored.
- Playtest negatives: a stamp from far away is rejected, a fake id is rejected, 20 rapid requests give 1 stamp, a bad jeep id moves nobody.

## Roblox Studio facts learned the hard way
- `execute_luau` cannot read some legacy properties (for example `Lighting.Technology`); `LightingStyle` is set by hand to Realistic.
- There is no programmatic undo in the MCP context: roll back by re-running the idempotent builder or restoring a backup.
- Terrain is not raycast-queryable until a `task.wait()` after the write; a fill topping out at y = T gives a surface at T + 2; water surface snaps to multiples of 4 studs.
- Build in batches of about 400 parts, parent each batch, then `task.wait()`. One giant parent freezes Studio and drops the connection.
- Load shared modules with `require(module:Clone())`; the require cache hides edits.
- Capture screenshots one at a time. A blank viewport after Play sessions sometimes needs Studio restarted (only with a saved backup).
- `TextSize` reads 8 for scaled text; judge by `TextBounds`. `AbsolutePosition` plus the GUI inset is the real position for every ScreenGui.
- Device simulator: set the device first, then the orientation, and do both before pressing Play.

## Content rules
Every guide has 4 to 6 lines: what the place is, what it represents today, one art or architecture observation (form, color, rhythm, balance, emphasis), and a "look at" prompt. No invented facts. Carmel states the 1948 apparition reports and the Church's sourced rulings neutrally. Photos are reference only: all signage is text, and the credits board lists every source.

## Ship checklist (what is left)
Credits identity (name, course, section for the group) into `CreditsData.identity`; icon and thumbnail; description, genre, Max Players about 40; maturity questionnaire; set Public; live-server check (scripts current, audio audible, streaming during jeep travel); record the video.
