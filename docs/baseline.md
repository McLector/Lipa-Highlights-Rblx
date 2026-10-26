# Baseline: what a correct copy of the place looks like

## The numbers
They live in **one place**: `EXPECTED` at the top of `tests/run_all.luau`. Run `require(game.ServerStorage.Checks.run_all:Clone())()` in Edit mode; `ok` must be `true`. Currently (2026-10-26, after Slice 3a): 15 stored checks (qa 44, sites 256, npcs 194, guides 111, site10 52, ...), unit suite 189, BuildCheck for the nine SiteData sites (City Hall has no row until Slice 3b), 8204 world parts (7100 plus 1104 City Hall parts), 1793270 terrain cells.

## Shared place version
| Field | Value |
|---|---|
| Latest shared baseline | `slice-23.rbxl`, saved 2026-10-22 12:51, 395,557 bytes. Includes `ServerStorage.Checks.run_all` (found in the reopened place, same hash as `tests/run_all.luau`: 4290 / 98 / 3994361621) |
| SHA-256 | `F5C96AA6A4F8EDF7FB1A18ECCB958DD5AB70D67D6463C66517260AF01B33E050` |
| Verified | opened in Studio, `run_all` gave `ok = true`, 74 rows, 0 mismatches (2026-10-22) |
| Where | private shared folder (link in the group chat), never a public GitHub release. Share only the `.rbxl`, never its `.rbxl.lock` file |
| Live place | placeId 138036647354961 (private; it still holds the Slice 03 state until the Ship publish) |

## Working backup (Slice 2 start)
| Field | Value |
|---|---|
| File | `slice-25.rbxl` (planned as `slice-25-start`; saved under this name), saved 2026-10-26 18:41, 427,800 bytes |
| SHA-256 | `0273B45CC657AC298B2007C0B6EE133DA0409BCE4ACFE6F750F71D048DA8FD73` |
| Verified | `run_all` gave `ok = true`: 14 stored checks, unit 127, 7100 world parts, 1793270 terrain cells (2026-10-26) |

## Working backup (Slice 2 end)
| Field | Value |
|---|---|
| File | `slice-26.rbxl`, saved 2026-10-26 19:48, 441,175 bytes |
| SHA-256 | `EFED967C57A439B3DF8559EFC1A6F03840E94831FCCB0F1456001CF2E43103F2` |
| Verified | `run_all` gave `ok = true`: 14 stored checks, unit 184, 7100 world parts, 1793270 terrain cells (2026-10-26, Slice 3a start) |
| Note | Studio still listed the open place as `slice-25.rbxl` after Save to File; the `.lock` sits on `slice-26.rbxl`. Not treated as a mismatch. |

## Working backup (Slice 3a end)
| Field | Value |
|---|---|
| File | `slice-27.rbxl`, saved 2026-10-26 21:24, 462,949 bytes |
| SHA-256 | `914694A98CB63A5E9AC61D7CC12CC4E2A71D9FBEA72310DF928F1E2B434A434A` |
| Verified | `run_all` gave `ok = true`: 15 stored checks, unit 189, site10_check 52, 8204 world parts, 1793270 terrain cells (2026-10-26, Slice 3b start) |
| Note | Studio still lists the open place as `slice-25.rbxl`. Not treated as a mismatch. |

Update this table every time the integrator shares a new baseline. If you save the place again, the size and SHA-256 change: refresh them before sharing.

## Check that your copy is the baseline
1. The file matches: in PowerShell run `Get-FileHash <your-file>.rbxl -Algorithm SHA256` and compare with the SHA-256 above (a copy you re-saved in Studio will differ; the next step is the real test).
2. The place passes: open it in Studio and run `require(game.ServerStorage.Checks.run_all:Clone())()`. It must say `"ok":true`.

## State that exists only inside the place (not recreated by any builder)
If a place is ever rebuilt from scratch these must be set by hand:
- `SoundService.AmbientTown`: Sound, `rbxassetid://9112833822` ("Neighborhood 3 (SFX)", Creator Store), Looped, Volume 0.25, attribute `Ambient = true`
- `Lighting`: `LightingStyle = Realistic`; `ClockTime` is set by `builders/world.luau` (15.5); Sky, Atmosphere, SunRays and Bloom come from the Baseplate template (DepthOfField disabled)
- `Workspace.SpawnLocation` at (-208, 0.8, -260), size 12 x 1 x 12, facing -X (City Hall forecourt; set by `builders/spawn.luau`, Slice 3b)
- Streaming: `StreamingEnabled = true`, Persistent backdrops (`ModelStreamingMode`), invisible boundary walls at +-1000
- Team Create **off**
- Studio copies of every script: builders under `ServerStorage.Builders`, checks under `ServerStorage.Checks`, unit tests under `ServerStorage.UnitTest.Cases`, and the mirrors of `src/**`

## Rebuild order (only if a place has to be regenerated; the integrator does this, never a groupmate)
`world.luau` -> `placeholders.luau` -> `site01` -> `site05` -> `site06` -> `site02` -> `site03` -> `site04` -> `site07` -> `site08` -> `site09` -> `credits.luau`. The builders are **not** from-scratch: each needs the placeholder children (Guide, InfoPanel, JeepStop, ...) and `ServerStorage.BuildKit` already in the place.
