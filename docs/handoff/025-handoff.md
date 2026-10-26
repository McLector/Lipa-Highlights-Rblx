# Handoff 025: Slice 1 (sync and ground truth) done; Slice 2 next
Previous: 024-handoff.md. Plan: `docs/PLAN-v2.md` (public copy); the full plan is kept locally by the owner.

## Status
- Slice 1 is complete for what it can do without the viewport: the slice-24 work that lived only in Studio is now on disk and committed, `run_all` is green, the branch and plan docs exist.
- **Open, carried into the next sessions:** the visual ladder is not finished (the 3D viewport is still blank; the ViewportFrame fallback needs a Play session and was not tried), and the upload probe was deliberately not run (it publishes to the owner's Roblox account, so it needs the owner's OK).

## Environment
- Branch `feat/tour-v2` (from `a96d841`), nothing pushed. Studio place open: `slice-24.rbxl` (opened from `backups\`), Edit mode. Studio ids change per session: run `list_roblox_studios` first.
- **Backup: pending your save.** Save the open place with File, Save to File as `backups\slice-25-start.rbxl` (a new name; do not press Ctrl+S, that would overwrite `slice-24.rbxl`). The next session's first step checks the file exists and records its size and SHA-256 in `docs/baseline.md`.

## Commits (local, no attribution trailer)
`73d672b` chore(sync): export the slice-24 NPCs, guide outfits and checks from Studio to disk, `4967330` docs(plan): add the v2 plan and a fixed camera kit for before/after shots, plus this handoff.

## Evidence
```
disk = Studio (bytes / newlines / djb2, LF):
run_all 4481/100/2626140692 | guides 6362/140/2135418583 | npcs 18029/329/4171510757
npcs_check 6162/120/2405925150 | guides_check 6188/108/2694882579 | SiteData 11054/184/1509680011
SiteData_Test (disk only copy, from Studio) 11991/299/394625235
run_all (Edit mode): ok=true, mismatches [], 14 checks, unit 127, world parts 7100, cells 1793270
```
All other builders, checks, unit cases, server, shared and client scripts were already equal. On disk but not in Studio (expected): `builders/credits.luau`, `builders/remotes.luau`, `builders/world.luau` (never run), `tests/world_check.luau`.

## Findings
- Studio had newer `SiteData` and `SiteData_Test` than disk; Studio's versions are now the disk truth. `SiteData` contains "Café" (non-ASCII, in the site name and panel text): do not re-encode that file.
- About 30 identical default `Animate` LocalScripts sit on rigs in Workspace; they are Roblox defaults, not project sources.
- **Audio probe (Haiku agent reached Studio fine):** `search_asset` with `assetType: Audio`, free, works and returns relaxing-sounding tracks (mostly DistrokidOfficial guitar titles, plus APM and ProSoundEffects loops). None are Roblox-owned and most show no duration, so every candidate must be **tested to play in a Play session** (audio privacy) in Slice 7; if none play, the owner supplies track IDs. `audioMinDuration`/`audioMaxDuration` (60 and 300) were not yet tried.
- `upload_image` takes HTTP URLs; it needs a small local server and publishes to the owner's account.
- `screen_capture` is blank again (checked twice, with the shot-kit camera).

## Decisions and deviations
1. The Studio-to-disk export ran in a fresh Sonnet subagent and the audio probe in a Haiku agent; the orchestrator verified hashes and `run_all` itself.
2. `docs/PLAN-v2.md` is the stripped public plan (no rubric table, deck notes or personal config). `docs/shot-kit.md` holds provisional camera positions per site.

## Pending on you
1. Save `backups\slice-25-start.rbxl` (see Environment).
2. Bring Studio to the front and click the viewport once; tell me if the 3D view returns.
3. Tell groupmates to hold edits to `SiteData`, `sites_check`, `qa_check`, `CreditsData`, `PassportClient` until Slices 2 and 3b are done.
4. Source or credit for the 2nd-reference photos (City Hall `.avif` files and screenshots), or "my own screenshot".

## Next steps (Slice 2: tour content)
1. Resume check: `list_roblox_studios`, Edit mode, `run_all` ok, `backups\slice-25-start.rbxl` exists (record size and SHA-256 in `docs/baseline.md`).
2. If the viewport is back, take one shot-kit shot. If not, try the ViewportFrame capture in a Play session.
3. Slice 2 per `docs/PLAN-v2.md`: tests first, then `content/tour_content.md` and `LipaShared/TourContent.luau` from `Detail Reference/more details.pdf` (ASCII only), art "look at" lines, the change table for the owner's approval, and the outfit textures by a second Haiku agent (no upload without the owner's OK).

## Context log
Orchestrator session was very long (planning, PDF and image reads); peak was not measured and is assumed near the cap, which is why the export was delegated. Subagents: Sonnet export 135k tokens (its own context, under the 250k cap); Haiku probe 91k (under the 100k cap). No exceptions.

## Continuation prompt
```
Continue the Lipa Tour v2 project at Slice 2 (tour content). Working dir: the repo root `roblox/` of C:\Users\morad\mesvara-idle\art_appreciation_finals. Read the full local plan C:\Users\morad\.claude\plans\pasted-content-id-0ba9-so-i-abundant-sunrise.md, then docs/PLAN-v2.md and docs/handoff/025-handoff.md.
First: list_roblox_studios (ids change), Edit mode, run require(game.ServerStorage.Checks.run_all:Clone())() and expect ok=true (14 checks, unit 127, parts 7100, cells 1793270). Confirm backups\slice-25-start.rbxl exists (ask me to save it if not) and record its size and SHA-256 in docs/baseline.md. Stop and report any mismatch.
Roles: you orchestrate; Sonnet 5.5 implements; Haiku 5.5 at effort max builds (content and textures in Slice 2). Context caps: 250k Opus/Sonnet, 100k Haiku; write a continuation at about 200k.
Rules: branch feat/tour-v2, never main; Conventional Commits with NO Co-Authored-By; nothing pushed without my say; tests first and shown red; Studio vs disk hash equal (node tools/hash.js); look at every screenshot; ASCII dialogue; never run builders/world.luau; no upload to Roblox without my OK. Slice 2 ends when the content files and the change table are committed; I approve the table at the start of the next session. Then write handoff 026, give the continuation prompt, remind me to save the backup, and stop.
```
