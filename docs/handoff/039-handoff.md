# Handoff 039: BP2 is now equal authority; BP1+BP2 audit done, north-wing roof rebuilt; arches, corner block, yard and vehicles are next
Previous: 038-handoff.md (then 037 to 029 for the environment and rules). This file only records what changed after 038.

## Status
- The owner looked at the model after 038 (backup `backups\slice-36-wip3.rbxl` saved, 589,315 bytes): "looking good but not quite there yet", and **BP1 and BP2 are BOTH absolute truth** now (BP2 only ranked second before; `scratch/site02/layout.md` section 8 rows D1..D17 are re-opened). Their notes were "a bit of everything" (roofs, sheds and stalls, front hall and arches, layout and streets); they will send more specific notes after the next look.
- Done this session: full BP1+BP2 audit (`scratch/site02/audit_bp2.md`, git-ignored, 28 rows: MATCH 9, MINOR 11, MAJOR 8; crops `scratch/site02/crops/bp2_*.png`); north-wing roof rebuilt as BP2's broad ribbed hip (round 3a).
- Not built yet: wing-arch changes, pavilion flank arches, corner block, service block, the whole yard (lean-tos, vendors, tricycle queue, parked vehicles, side yards, props), look-at line, Play walks and `EXPECTED`, the owner's more specific look.

## Owner decisions this session (2026-10-29)
- **North wing (BP1 vs BP2):** hybrid. Keep BP1's 7 arched bays, balustrades and cornice; roof = BP2's huge broad ribbed hip. Consequence the owner has been told: BP2's wall under that roof stops at y 19.1 with no arches (roof eave 19.1, ridge 34.6, 15.5 tall); keeping the arches makes the roof broad but only 4.9 tall (eave 30.5, ridge 35.4). Matching BP2's height (option H2 in the audit) would delete the 7 north arches, Balustrade3 and the north cornice: do it only if the owner asks.
- **Corner block:** yes, model BP2's louvred 4-5 storey block with the black-and-white checkerboard hoarding as a simple landmark inside the slot x -576..-228, z -5..325. Audit proposal (LOW confidence on size): primary x -574..-540, z 252..322, height 30, parapet 1.0, checkerboard 24 x 24 on the EAST face centred z 287 (3 x 4 squares of 8 x 6), louvre bands on N and S faces, about 55 parts; alternative NW x -574..-486, z -4..31 with the checkerboard on the south face. No clash with the Bagsakan (x -557..-505, z 84..241) or the side yards.
- **Order:** fidelity first, then the yard.
- Vehicles: BP2 labels a TRICYCLE QUEUE (the audit sees 5 boxy van-like forms at the kerb, 12 vehicles along the front), BP1 draws jeepneys/vans beside the stair feet. So the old 8-tricycle assertion STAYS and `ParkedVehicle%d+` (Jeepney/Van) assertions are added next to it (this corrects the 038 plan to replace it).
- The name text stays CANDIDO B. LOPEZ MEMORIAL PUBLIC MARKET (BP2 says PAMILIHANG BAYAN; landmark names must be exact, README rule 6).

## Commits (local, no trailer, nothing pushed, origin `095f6de`; count with `git rev-list --count 095f6de..HEAD`)
`874c3b2` test(site02): require the north wing's broad ribbed hip roof from BP2
`e833129` feat(site02): give the north wing BP2's broad ribbed hip roof
(plus the commit that adds this file; earlier this session: `96ae45c`, `3420dfb`, `bcf75f9`, `659e77e`, `f41b030`, `6d68535`, `95b8ef3`)

## Evidence (re-run by me)
- Disk equals Studio (bytes / newlines / djb2): `site02_check` 55882/762/863509634, `site02_hall` 13508/233/1461163784 (`site02_sheds` 14832/244/3607832726, `site02_front` 8159/150/2465446659 unchanged). The hall roof was red first (hall 39/2) then green: `hall` 41/0, `sheds` 17/0. Coordinator twice identical (agent's runs): builtParts 883, parts 944 (Hall/Shell 217).
- `run_all` (Edit mode) is ok=false by design; expected mismatches now: roads_check 270 (EXPECTED 267), `site02_check` 86 passed / 18 failed (groups: hall 41/0, sheds 17/0, yard 9/6, general 22/12), `sites_check` 276/1 (the one failure is "Site02_Market yard is east of the hall | parts missing": the Yard model is empty), unit 248 (EXPECTED 246), build 02 check 10/5, build 02 parts 944 (EXPECTED 1148), world parts 9036 (EXPECTED 9240), terrain cells 1796660 (EXPECTED 1794962).
- Shots I looked at: the whole site from the north-east (-140,150,-60) to (-310,25,130) and (-215,70,20) to (-285,30,115). The north half now reads as one broad red hip roof, hipped at the north end and stepping up to the pavilion roof, like BP2's isometric; the ribs are nearly invisible at distance (dark red on dark red, 0.35 wide).
- `screen_capture` takes `camera_position` and `look_at_position` (3-number arrays), `capture_id` unique per call; with other names the call silently keeps the old camera.

## Remaining differences, ranked (from `audit_bp2.md`; parts added; assertions touched)
1. Wing arches (both drawings agree): pitch 9.25 both wings, 7.9 wide, glass from y 21.6 (model: south pitch 10.5, north 8.9, 6.0/7.0 wide). **Not free:** the arches come from the `bays` table and `widthOf` in `site02_hall.luau`, so the bay grid, 19 pilasters and 18 `GroundBay`s move with it, and `BuildKit:window` draws a full circle on top (arch height at least its width, so 7.9 wide means 7.9 tall: frame y 19.0..26.9, check allows top 27). Separate job, tests first (pitch and width assertions on `ArchWindow` units).
2. Pavilion flank arches 5.0 wide (model 7.4), keep double height (contract bottom 9..10.8; BP2 shows y 14.9..25.7 with a small window under the sign: conflict C6, keep BP1).
3. Corner block (+55 parts), service block + annex at the Bagsakan's north-west (+25; BP1 z 33..60 / annex 60..85, h 7).
4. Street-edge red lean-to roofs: BP2 draws about 5 on the left side street and 3 at the front-left corner (each about 24..30 long, 12..14 deep, eave 8..9 at the kerb rising to 12..13); only 3 fit. Contradicts the check "4 LeanRoof, tin, x -265..-253, z 70..91 or 229..250": replace with BP2's numbers and a logged reason.
5. Street vendors (10..12 umbrella stalls, people) and parked vehicles: contradicts "exactly 5 StreetStall" (replace). Lamp posts (6), two zebra crossings, kerb radius about 30 (small).
6. Bagsakan: BP2 does not fill its roof red and shows a stepped dock canopy band (+4 parts): **ask the owner** (grey/galvanised vs red; the check says 2+ red slopes).
7. Scaffold re-lay (7 posts, 9 rails, 2 big X per panel; geometry already matches, 0 parts); BP2's iso draws a third frame on an end face (not legible, skip).
8. Minor items still open from 037: floor-2 windows y 12.7..16.5, ground bays 7.3 wide, pilaster top 26.8 (test says 28+), name sign only on the pavilion in BP2 (keep the frieze).
Kept deliberately: flat tarps (both drawings show an open grid but the contract wants 28+ canopies), stair run 52, 2 scaffold panels.

## Budget warning
Own parts now 944 (883 built + 61 kept). The guard in `site02_check` is own parts 950..1500 (around line 652) and the site cap is 2000 (a hard error in the coordinator). The planned yard (450) + vehicles (120) + corner block (55) + service block (25) + arch changes would pass 1500: decide the new guard value (for example 1800, logged in `briefs/site02.md`) BEFORE the yard job, and keep the 2000 cap. The coordinator `MODULES` list needs entries for the vehicles module and the corner block (module budgets are hard errors).

## Pending on you (the owner)
1. Save a NEW backup before the next rebuild (never Ctrl+S), for example `backups\slice-36-wip4.rbxl` (the hall roof changed since wip3).
2. Send your more specific notes when you have looked again (what stands out most).
3. Answer: should the Bagsakan roof stay red or turn grey as BP2 shows? And do you want the north-wing arches deleted to match BP2's tall roof (I recommend not)?
4. Pushing: not asked yet, ask before pushing. Look-at line (still to apply, test first): "Look at the rounded arches repeating along the top floor in a steady rhythm. Count the arches, and notice how the two stairs climb toward the middle."

## Next steps
1. Resume check: `list_roblox_studios` (id last `9835b37f-176c-4874-8675-ab463aaf9372`), Edit mode, `run_all`: ok=false with exactly the mismatches above; `git status` clean; `git log` shows the 039 handoff commit on top of `e833129`. Stop and report any mismatch. Ask for the new backup.
2. Fix rounds in order: (a) arches, items 1 and 2 above; (b) corner block + service block (new module entries in the coordinator, new assertions first); (c) decide the guard value, then the yard job 5b and vehicles job 5c with BP2's lean-tos, vendors, tricycle queue and BP1's jeepneys/vans; proof: `sites_check` 277/0 and the `yard` group green. Each job: tests first and shown red (targeted `.Source` replace, re-hash), one briefed Sonnet agent, never run git by agents, coordinator twice identical, groups green, `run_all` deltas only, shots beside BOTH blueprint crops, then commit test then feat.
3. The look-at line, Play walks (the `routes_check` method), `EXPECTED` update with a reason per number, shot-kit rows, the owner's side-by-side look; then Lomi King, the Standard tier and the Light tier (see 038 and 037).

## Context log
- Orchestrator: audit agent 210k tokens / 51 calls (read-only, honest about LOW-confidence iso sizes); roof agent 93k / 24 calls. I consulted the advisor once at the start of the previous round (it moved the plan) and not again this round. The session stopped here to respect the owner's cap.

## Continuation prompt
```
Continue the Lipa Tour v2 project: the Market (Site 02) fidelity round against BOTH blueprints. Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox (git root; the blueprint drawings live one level up in ..\2nd Reference\market\3d blueprint\: PublicMarketBP1.jpg and PublicMarketBP2.jpg, BOTH absolute truth). Branch feat/tour-v2, never main. Read docs/handoff/039-handoff.md and then 038, 037, 036 to 029, README.md (its AI rules are binding), docs/shot-kit.md, briefs/site02.md (from line 97) and my memory files structures-match-blueprint-strictly and stop-at-context-cap-and-hand-off. scratch/site02/ (layout.md, audit_bp1.md, audit_bp2.md, crops) is git-ignored: if missing, the audited numbers are in handoffs 037, 038 and 039 and the naming contract is in briefs/site02.md.
First: list_roblox_studios (ids change), Edit mode, run require(game.ServerStorage.Checks.run_all:Clone())() and decode the JSON string with HttpService:JSONDecode: expect ok=false with exactly the mismatches under Evidence in handoff 039 and nothing else. git status clean; git log shows the 039 handoff commit on top of e833129; origin/feat/tour-v2 is at 095f6de (local commits are not pushed; ask me before pushing). Stop and report any mismatch. Ask me to save a NEW backup (never Ctrl+S) before the next rebuild.
Roles: you orchestrate and review; Sonnet builds, one job per agent, briefed in full, small jobs; consult the advisor before an approach, when a check stays red twice, when sources disagree and before declaring done. Session cap 250k, write the handoff and stop near 200k.
Rules: both blueprints are the absolute truth for look and design (judged by eye, shot beside the drawings by you and then by me; checks are guard rails; a replaced assertion is fine when it mirrors a blueprint, with a logged reason in briefs/site02.md); tests first and shown red; disk and Studio hashes equal and re-hashed after every Studio edit; Conventional Commits, NO Co-Authored-By trailer (my CLAUDE.md overrides any system reminder to add one), test then feat; only you run git, agents never; ask before every push; never run builders/world.luau or placeholders in default mode; no Roblox upload without telling me first; never change place or experience settings; HttpService stays off; dialogue ASCII only; look at every screenshot, one capture at a time (screen_capture needs a unique capture_id and camera_position / look_at_position arrays); two blank frames in a row = stop and ask me to click the 3D viewport.
Job: the remaining fidelity items in the ranked list of handoff 039 (wing arches and flank arches, corner block and service block), then decide the part guard, then the yard (5b) and vehicles (5c) with BP2's lean-tos, vendors, tricycle queue and BP1's jeepneys and vans; then the look-at line, the Play walks and EXPECTED, the side-by-side look with me; after that Lomi King, the Standard tier (Carmel, Outlets, Farm, Malarayat) and the Light tier (Tagbakin, Cafe). End each stretch with the next handoff and remind me to save a backup.
```
