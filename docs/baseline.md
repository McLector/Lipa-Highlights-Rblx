# Baseline: what a correct copy of the place looks like

## The numbers
They live in **one place**: `EXPECTED` at the top of `tests/run_all.luau`. Run `require(game.ServerStorage.Checks.run_all:Clone())()` in Edit mode; `ok` must be `true`. Currently (2026-10-22): 12 stored checks (qa 44, sites 256, ...), unit suite 127, BuildCheck for all nine sites, 6691 world parts, 1793270 terrain cells.

## Shared place version
| Field | Value |
|---|---|
| Latest shared baseline | `slice-23.rbxl`, saved 2026-10-22 12:51, 395,557 bytes. Includes `ServerStorage.Checks.run_all` (found in the reopened place, same hash as `tests/run_all.luau`: 4290 / 98 / 3994361621) |
| SHA-256 | `F5C96AA6A4F8EDF7FB1A18ECCB958DD5AB70D67D6463C66517260AF01B33E050` |
| Verified | opened in Studio, `run_all` gave `ok = true`, 74 rows, 0 mismatches (2026-10-22) |
| Where | private shared folder (link in the group chat), never a public GitHub release. Share only the `.rbxl`, never its `.rbxl.lock` file |
| Live place | placeId 138036647354961 (private; it still holds the Slice 03 state until the Ship publish) |

Update this table every time the integrator shares a new baseline. If you save the place again, the size and SHA-256 change: refresh them before sharing.

## Check that your copy is the baseline
1. The file matches: in PowerShell run `Get-FileHash <your-file>.rbxl -Algorithm SHA256` and compare with the SHA-256 above (a copy you re-saved in Studio will differ; the next step is the real test).
2. The place passes: open it in Studio and run `require(game.ServerStorage.Checks.run_all:Clone())()`. It must say `"ok":true`.

## State that exists only inside the place (not recreated by any builder)
If a place is ever rebuilt from scratch these must be set by hand:
- `SoundService.AmbientTown`: Sound, `rbxassetid://9112833822` ("Neighborhood 3 (SFX)", Creator Store), Looped, Volume 0.25, attribute `Ambient = true`
- `Lighting`: `LightingStyle = Realistic`; `ClockTime` is set by `builders/world.luau` (15.5); Sky, Atmosphere, SunRays and Bloom come from the Baseplate template (DepthOfField disabled)
- `Workspace.SpawnLocation` at (0, 0.5, 70) facing -Z
- Streaming: `StreamingEnabled = true`, Persistent backdrops (`ModelStreamingMode`), invisible boundary walls at +-1000
- Team Create **off**
- Studio copies of every script: builders under `ServerStorage.Builders`, checks under `ServerStorage.Checks`, unit tests under `ServerStorage.UnitTest.Cases`, and the mirrors of `src/**`

## Rebuild order (only if a place has to be regenerated; the integrator does this, never a groupmate)
`world.luau` -> `placeholders.luau` -> `site01` -> `site05` -> `site06` -> `site02` -> `site03` -> `site04` -> `site07` -> `site08` -> `site09` -> `credits.luau`. The builders are **not** from-scratch: each needs the placeholder children (Guide, InfoPanel, JeepStop, ...) and `ServerStorage.BuildKit` already in the place.
