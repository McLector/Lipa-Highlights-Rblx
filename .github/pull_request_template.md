## What and why
<!-- One or two sentences. Link the issue: Closes #N -->

## Area
- [ ] Site build (site NN)  - [ ] Dialogue / content  - [ ] Scripts / UI  - [ ] Docs  - [ ] Other

## Evidence (paste real output, not "it passes")
- [ ] The new or changed check was written first and **shown failing** before the change (paste the red line):
```
```
- [ ] Final output of `require(game.ServerStorage.Checks.run_all:Clone())()` in Edit mode (`ok`, mismatches):
```
```
- [ ] If a number legitimately changed, `EXPECTED` in `tests/run_all.luau` is updated in this PR and the reason is written here:
- [ ] Studio vs disk hashes are identical for every script I touched (`node tools/hash.js <file>` against the Studio copy):
```
```
- [ ] Screenshots of what changed (looked at for text and scale bugs; long labels use a fixed `TextSize`):

## Checklist
- [ ] I touched only the files of my area (see CONTRIBUTING.md); I did **not** run `builders/world.luau`
- [ ] Dialogue and panel text are ASCII only, with no invented facts (unverified claims marked `[VERIFY]` with a source)
- [ ] `CreditsData.luau` and `content/site_credits.md` agree if I added or changed a photo source (`tests/credits_crosscheck.ps1`)
- [ ] No `.rbxl`, photos, course grading documents, decks, `.env`, tokens or passwords in this PR
- [ ] Commits use Conventional Commits and my own name and email
