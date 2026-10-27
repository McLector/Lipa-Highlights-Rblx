# Plan v2: sunset tour, City Hall start, self-guiding, real jeepney

Team version of the second-pass plan. Status is recorded in `docs/handoff/` (025 onward). Same rules as `README.md`.

## Goal
New Lipa City Hall as the start with a welcoming guide; structures rebuilt from the 3D blueprints and reference photos; a golden-hour sunset mood with relaxing music; a game that guides itself without taking away freedom; casual, short NPC dialogue and better billboards; one trivia question per site; barong and baro't saya outfits; a jeepney that really drives (most trips 5 to 13 s, never over 18 s); Filipino filler buildings instead of the template grass.

## Decisions
- City Hall is site 10 (Welcome category), 10 stamps, spawn at its forecourt. Jeep stops at all 10 sites.
- Outfit is chosen on the Welcome screen. Music is Roblox-owned audio, tested in Play.
- NPCs wear persona outfits with a name tag; only the City Hall guide keeps the tour uniform.
- Each guide keeps one short "look at" line about the art of the building.
- Structures follow the blueprints and reference pictures strictly (owner rule, 2026-10-27). The blueprint decides massing, layout and proportion; the reference pictures decide visible detail; where a site has a detail drawing (the Cathedral's `CathedralBP.jpg`) it decides the building itself. Blueprint label text is never a fact and never becomes signage. Signs are text only, no logos or seals.
- Footprints grow to fit the blueprint when it needs more room (owner, 2026-10-27): a footprint study checks neighbours, roads and the world edge first, and the owner approves it. Human-scale parts stay fixed. The 20,000 world part cap is raised only deliberately, with a reason.
- A structure is done when its blueprint-view shot matches the blueprint by eye, not when checks pass. Checks are guard rails (placeholders, required props, human scale, roads, idempotence, part budget); builders may add assertions but never loosen existing ones.
- Words in the game that depend on a feature the drawings do not show go to the owner as a change table, never into the model.
- Never run `builders/world.luau`. Quiz answer key stays server-side.

## Slices (one session each, ending with a handoff, a continuation prompt and a stop)
1. Sync Studio-only work to disk, branch, probes
2. Tour content (ASCII data, art lines, outfit textures); owner approves the content table
3a. City Hall building. 3b. City Hall integration, roads, spawn, 10 stamps
4. Structures wave 1: Cathedral and plaza, Market, Lomi King
5. Structures wave 2: Carmel, Outlets, Farm
6. Structures wave 3: Malarayat, Tagbakin, Cafe de Lipa
7. Sunset, weather, music
8. Billboard redesign
9. Self-guiding navigation (HUD hint, signposts, optional path beam, tour map)
10. Moving jeepney
11. Dialogue, art lines, trivia quiz
12. Barong, baro't saya, NPC persona outfits
13. Filler building kit. 14. Filler placement and ground zones
15. New-player test, polish, ship

## Per-slice loop
Branch `feat/tour-v2`; tests first and shown red, then green; `run_all` ok (update `EXPECTED` on purpose only); Studio and disk hashes equal; screenshots looked at; owner saves `backups/slice-NN.rbxl`; commit locally; write the next handoff; stop.

Structure slices (4 to 6) add a visual loop: a blueprint-view camera and a top-down camera per site, a builder (Sonnet) that compares its shots with the drawing and fixes the five biggest differences each round, an orchestrator review of every shot, and an owner look at the final blueprint-versus-model pair before the commit. A blank viewport stops the work until it renders; nobody builds blind.

The advisor can be consulted at any time by the orchestrator and by every subagent, especially before committing to an approach, before a footprint, road or part-cap change, when a check stays red after two attempts, when sources disagree, and before declaring work done. An agent without an advisor tool returns `NEEDS_ADVICE` plus its question. Each consultation is noted in the journal and the handoff context log.
