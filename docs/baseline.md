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

## Working backup (Slice 3b end)
| Field | Value |
|---|---|
| File | `slice-28.rbxl`, saved 2026-10-27 00:11, 493,695 bytes |
| SHA-256 | `AF219BC7FE307434A51BA37AA42C341BC20CFF4B070BEF2F4DE01F5B3714EF36` |
| Verified | `run_all` gave `ok = true`: 17 stored checks, unit 226, 8312 world parts, 1793696 terrain cells (2026-10-27, Slice 4 start) |
| Note | Studio still lists the open place as `slice-25.rbxl`. Not treated as a mismatch. Studio was found in Play mode and was stopped before the check. |

## Working backup (handoff 062 start)
| Field | Value |
|---|---|
| File | `slice-36-wip33.rbxl`, saved 2026-10-31 09:45, 959,960 bytes |
| SHA-256 | `207C23C61D1E7046D2404EFE538BD32AB399162CC845918AA0145A9AA1A7ADD0` |
| Verified | `run_all` gave `ok = true`, 89 rows, 0 mismatches: 17 stored checks, unit 283, 22375 world parts, 1807294 terrain cells (2026-10-31, handoff 062 start, on the open place after the 6751bfd commit) |
| Note | Studio's window title still says `slice-36-wip26.rbxl`; the `.lock` is on wip33. Not treated as a mismatch. From `0aeb424` on, run_all also runs filler_check (18 stored checks, 91 rows). |

## Backup log wip17..wip33 (sizes, times and SHA-256 read from the files on 2026-10-31; only wip33 was verified with run_all here)
| File | Saved | Bytes | SHA-256 | Note |
|---|---|---|---|---|
| `slice-36-wip17.rbxl` | 2026-10-30 14:58 | 633,755 | `0B082C048D6EAEF47233BD4A7462D5BEE9674ECD598101C2F2E3753307081629` | re-save of wip16 (see the earlier working backup below) |
| `slice-36-wip18.rbxl` | 2026-10-30 17:48 | 636,331 | `38D6DA57F857638EEAE01A13BE2F3D73D8C933CAE9FD798475CA5E18A4411147` | contents not recorded |
| `slice-36-wip19.rbxl` | 2026-10-30 21:53 | 636,828 | `2D8B95A8A3889D327197B8A06114D8D83D1A4E2963B48D87B9D834E2429359A1` | contents not recorded |
| `slice-36-wip20.rbxl` | 2026-10-30 23:10 | 643,375 | `22CE26668D99FE188B4DCF33F86333119587FF490F95A1F00F3C11BF236E7B4D` | contents not recorded |
| `slice-36-wip21.rbxl` | 2026-10-30 23:45 | 650,482 | `4298EC35B78D1C0B8C469C70BF5CCDE79A15498D648132EDBD465130AD5C0818` | contents not recorded |
| `slice-36-wip22.rbxl` | 2026-10-31 00:30 | 650,855 | `7D7140252B1D6E366B02AFDC69EB41514770277F27D9B59870D98DABAA4C12D3` | contents not recorded |
| `slice-36-wip23.rbxl` | 2026-10-31 01:02 | 655,358 | `9CABD6977F5B596281A976656EDB1BD0A5682AB3C6332A76FB1D73818D893182` | contents not recorded |
| `slice-36-wip24.rbxl` | 2026-10-31 01:15 | 655,522 | `E1C06B5A454771F1690CC3E73B42B9AFC61D505968522B207BD509FC9CB5103D` | wip25 has the same bytes |
| `slice-36-wip25.rbxl` | 2026-10-31 01:23 | 655,522 | `E1C06B5A454771F1690CC3E73B42B9AFC61D505968522B207BD509FC9CB5103D` | same bytes as wip24 |
| `slice-36-wip26.rbxl` | 2026-10-31 02:53 | 668,736 | `6C32BA4340E840ABBBCB1E6F93EAE5949618F138D2E3796DD757A3FAC46EFC9D` | contents not recorded |
| `slice-36-wip27.rbxl` | 2026-10-31 03:43 | 678,678 | `818E0D1A1282CE4B92F5819A5A729E59592AE4D1AF979AF44E19ED126B065711` | contents not recorded |
| `slice-36-wip28.rbxl` | 2026-10-31 04:21 | 679,166 | `64E12E8A5C09B743D9C010EEA444AA95081A6EF484D30A772C36EF95BF4B28C8` | contents not recorded |
| `slice-36-wip29.rbxl` | 2026-10-31 04:59 | 682,170 | `049CDE5673678F8F26C4A6F1EC141D7695BF0C0B82392AF58C8AE57C3C785923` | contents not recorded |
| `slice-36-wip30.rbxl` | 2026-10-31 06:06 | 710,556 | `85E75D5AA948C4ADF5F6C4B12DB4667A930D8FB253FAB4385EF6B18316F4C3D6` | handoff 060 baseline |
| `slice-36-wip31.rbxl` | 2026-10-31 06:34 | 716,599 | `CEC9256FA40AC6FD9368884B66D88FE59A37BA65538F19BB6606A17E9146BE2B` | saved after 060 part 1 (guidance) |
| `slice-36-wip32.rbxl` | 2026-10-31 08:56 | 938,089 | `A5EA01D432516DB5E0BBC1CF15919397E8546ECD993E11AC4D41381E5F4D4A20` | handoff 061 recorded 817,146 bytes, SHA-256 2af97d3c...; the file now on disk is a later re-save under the same name |
| `slice-36-wip33.rbxl` | 2026-10-31 09:45 | 959,960 | `207C23C61D1E7046D2404EFE538BD32AB399162CC845918AA0145A9AA1A7ADD0` | after the 061 grass cleanup (6751bfd); handoff 062 resume: run_all ok=true, 89 rows, 0 mismatches |

## Earlier working backup (Slice 4 Market, street traffic R5e)
| Field | Value |
|---|---|
| File | `slice-36-wip16.rbxl`, saved 2026-10-30 13:28, 633,755 bytes |
| SHA-256 | `C7145D6A3D3FF6ED9669A203EE5E81BE54D95691EAE0BF9232FA12323C3650A3` |
| Verified | `run_all` gave `ok = true`, 89 rows, 0 mismatches: 17 stored checks, unit 250, site02_check 151, build 02 parts 2082, 10174 world parts, 1796660 terrain cells (2026-10-30, Market front street start) |
| Note | Holds the street traffic (`8d111b9`) and the `EXPECTED` update (`ee6a905`). `slice-36-wip17.rbxl` (SHA-256 `0B082C048D6EAEF47233BD4A7462D5BEE9674ECD598101C2F2E3753307081629`, saved 14:58) is a re-save of the same state before the street work. Studio's window title can lag behind the file that holds the `.lock`. Not treated as a mismatch. |

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
