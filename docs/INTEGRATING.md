# Integrating a pull request (owner's checklist)

Written so a second person could do it. The canonical Studio place is the owner's. Groupmates' places are scratch copies.

## Before merging
1. Open the PR and read it against the template: red output shown first, `run_all` output pasted, hashes identical, screenshots, no private files, ASCII dialogue.
2. Check the changed files stay inside the author's area (see the README table). Anything in `world.luau`, `docs/handoff/*`, `docs/baseline.md`, `EXPECTED` or `CreditsData.identity` that is not yours: stop and ask.
3. Dialogue or panel text changed? You approve the wording and the sources (`[VERIFY]` until sourced).

## Applying it (always on a COPY first)
1. Save the canonical place as `backups/slice-NN.rbxl` (the previous state) and keep it.
2. Open a copy of the canonical place. Pull `main` after merging.
3. For each changed file, update the matching Studio script: builders under `ServerStorage.Builders`, checks under `ServerStorage.Checks`, unit tests under `ServerStorage.UnitTest.Cases`, runtime scripts as in `src/**`. Compare `node tools/hash.js <file>` with the Studio script's hash: identical.
4. Run the builder if there is one: `require(game.ServerStorage.Builders.siteNN:Clone())()` (never `world.luau`).
5. Run the battery: `require(game.ServerStorage.Checks.run_all:Clone())()`. Expected result `ok = true`. If a number changed on purpose, `EXPECTED` in `tests/run_all.luau` was updated in the PR and the reason is written there.
6. Look at screenshots of the changed site (capture one at a time, twice, with a wait).

## If it is green
1. Do the same steps on the canonical place, save `backups/slice-NN.rbxl`, share it in the private folder.
2. Update `docs/baseline.md` (version, date, anything new that exists only inside the place).
3. Write the next handoff in `docs/handoff/0NN-handoff.md` (sequential, never overwritten) and its continuation prompt.

## If it is not green
Revert the merge (`git revert -m 1 <merge commit>`), tell the author what failed with the real output, and do not patch it in a hurry. The previous backup is still the valid state.

## Playtest before Ship
After the last merge: full playtest (9 of 9 by walking and the jeepney, certificate), the negatives, the device pass (phone landscape, tablet, phone portrait), scene and console checks. The earlier results are in `docs/ship/slice-23-playtest.md`.
