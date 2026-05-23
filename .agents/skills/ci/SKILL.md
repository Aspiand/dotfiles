---
name: ci
description: |
  Manage and debug CI/CD pipelines for this Nix-based dotfiles monorepo.
  Use this skill whenever the user asks about build failures, GitHub Actions
  workflows, the R2 binary cache, garbage collection, cache verification,
  auto-updates, or any CI-related issue in this project. Also consult for
  package structure, nvfetcher source management, and build commands.
---

## Companion file

`AGENTS.md` at repo root has exact commands, package table with CI status,
and cache details. Read it first when you need a quick reference.

## CI workflows

| File | What | Trigger |
|---|---|---|
| `build.yml` | Build, sign, push to R2 | Push main (nix/**, flake.*), dispatch, call |
| `verify.yml` | Check R2 cache integrity (list narinfos, parse signatures, check NAR files exist, cross-ref packages) | Dispatch, call |
| `gc.yml` | Smart prune: orphan NARs, stale packages, age-based (>30d), keep latest 2 per package | Cron Sun 06:00, dispatch (supports `dry-run`) |
| `clean-package.yml` | Remove all but latest version of a specific package | Dispatch (`package` input) |
| `cache-report.yml` | Generate package table with sizes, hashes, timestamps | Dispatch |
| `update.yml` | nvfetcher → staging branch → build.yml → promote to main | Cron Mon 06:00, dispatch |
| `check.yml` | `nix flake check` on all flakes in repo | Every push |
| `build-external.yml` | Thin wrapper calling build.yml on an external flake | Dispatch |

### secrets: inherit

Workflows calling other workflows via `workflow_call` MUST include
`secrets: inherit` to pass R2 credentials and NIX_SECRET_KEY through.
Currently used in:
- `update.yml` — calls `build.yml` after nvfetcher runs
- `build-external.yml` — calls `build.yml` for external flakes

Forgetting this is the #1 cause of "build passes but push to R2 fails silently."

### check.yml quirks

Uses `cachix/install-nix-action@v31` + `actions/checkout@v4`
(different from every other workflow which uses
`DeterminateSystems/nix-installer-action@v22` + `checkout@v5`).

## How each workflow works

### build.yml

1. `generate-matrix` job: `nix eval .#packages.x86_64-linux --json --impure` →
   filter out `EXCLUDED_PACKAGES` (`["9router"]`) → matrix JSON
2. `build` job (matrix): for each package →
   `nix build .#packages.x86_64-linux.<pkg>` →
   sign (`nix store sign`) → `nix copy` to S3 (R2)

All builds: `NIXPKGS_ALLOW_UNFREE=1`, `--impure`, `--accept-flake-config`.

Passes `repository` and `ref` for external flakes (no exclusion filter).

### verify.yml (does NOT build)

Pure R2 inspection — no package building:

1. List all `.narinfo` objects in R2 bucket (`--page-size 1000`)
2. For each narinfo: download, parse `StorePath`, `Sig`, `URL`
3. Check referenced NAR file exists via `aws s3api head-object`
4. Check public cache via `curl $PUBLIC_CACHE_URL/$KEY`
5. Cross-reference: `nix eval` flake packages → check each has a matching narinfo
6. Fail if any package (except 9router) has no narinfo in R2

### gc.yml (no build — pure inspection)

Single `prune` job with 4 phases:

1. **Orphan NARs** — NAR files with no corresponding narinfo → delete
2. **Stale packages** — Store paths not matching any current flake package → delete all
3. **Age-based** — Objects with `LastModified` older than 30 days → delete
4. **Keep latest 2** — Per package, sort by timestamp, keep newest 2 versions

Phases are cumulative. Delete list is deduplicated before execution.

`dry-run: true` — list only, no delete.

### clean-package.yml

Targeted cleanup for a single package. Takes `package` input, removes all
but the latest 1 version from R2. Useful for reclaiming space after a
package gets many updates.

### cache-report.yml

Lists every narinfo in R2, downloads each to extract `StorePath`, `Sig`,
`URL`, and cross-references with `objects.json` for file sizes. Outputs a
markdown table to `GITHUB_STEP_SUMMARY` and saves raw data as an artifact.

### update.yml

1. Save old `_generated.json`
2. `nix run github:berberman/nvfetcher` → regenerate sources
3. Rename `generated.nix` → `_generated.nix`, `generated.json` → `_generated.json`
4. Build changelog via jq diff (added/removed/updated packages)
5. Commit to `auto-update/${{ github.run_id }}` branch, push
6. Call `build.yml` via `workflow_call` — if all pass, ff-merge to main
7. If build fails: staging branch left dangling, no main commit

`force: true` dispatch input creates empty commit for end-to-end pipeline test.

## Excluded packages

`EXCLUDED_PACKAGES: '["9router"]'` in build.yml and gc.yml. 9router is
pinned in nvfetcher.toml and excluded from CI (needs credentials / won't
build in CI runner).

## Cache & secrets

- **Public URL:** `https://nix.aspian.my.id`
- **Signing key:** `github-ci-2:eUvIhhjHCO/kJVGcFNd/sNCGSx59tj1QAXmb477OO00=`
- **Secrets:** `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_BUCKET`, `R2_ENDPOINT`, `NIX_SECRET_KEY`

## Common CI tasks

### Diagnose a build failure

1. Check which package + which job in the workflow log
2. Common causes:
   - **Hash mismatch** in `_sources/_generated.json` — upstream changed archive without version bump. Re-run `nvfetcher`.
   - **Build timeout** — codegraph (Rust/Golang) or hanabi (GStreamer) can be heavy. Check runner duration.
   - **Unfree license** — ensure `NIXPKGS_ALLOW_UNFREE=1` (already set in all workflows).
   - **Missing nixpkgs dependency** — try `nix flake update` to bump nixpkgs.
   - **check.yml uses different actions** — `cachix/install-nix-action` vs `DeterminateSystems/nix-installer-action` — if one breaks, the other may still work.

### Trigger a manual build

`workflow_dispatch` on `build.yml`:
- `package: ALL` — build everything (default)
- `package: hanabi,codegraph` — specific packages (comma-separated)
- `force: true` — rebuild even if cache hit

### Verify the R2 cache

`workflow_dispatch` on `verify.yml`. No build needed — inspects bucket directly.

### Test the garbage collector safely

`workflow_dispatch` on `gc.yml` with `dry-run: true`. Lists what would be
deleted. Run again with `dry-run: false` to actually prune.

### Regenerate nvfetcher sources locally

```bash
nix run github:berberman/nvfetcher -- --build-dir nix/_sources
mv nix/_sources/generated.nix nix/_sources/_generated.nix
mv nix/_sources/generated.json nix/_sources/_generated.json
```

## When NOT to use this skill

- General Nix packaging questions (use AGENTS.md commands)
- NixOS or home-manager configuration
