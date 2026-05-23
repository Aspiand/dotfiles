# R2 Cache Report

## Overview

Public cache: `https://nix.aspian.my.id`
Signing key: `github-ci-2:eUvIhhjHCO/kJVGcFNd/sNCGSx59tj1QAXmb477OO00=`

## Generate live report

Run [cache-report.yml](https://github.com/aspiand/dotfiles/actions/workflows/cache-report.yml) to get a fresh table of all cached packages with sizes, hashes, and timestamps.

## Clean a package

Run [clean-package.yml](https://github.com/aspiand/dotfiles/actions/workflows/clean-package.yml) with a package name to remove all but the latest version from the cache.

| Package | Clean |
|---|---|
| codegraph | [Clean →](https://github.com/aspiand/dotfiles/actions/workflows/clean-package.yml) |
| hanabi | [Clean →](https://github.com/aspiand/dotfiles/actions/workflows/clean-package.yml) |
| openhuman | [Clean →](https://github.com/aspiand/dotfiles/actions/workflows/clean-package.yml) |
| tlauncher | [Clean →](https://github.com/aspiand/dotfiles/actions/workflows/clean-package.yml) |

## Full GC

Run [gc.yml](https://github.com/aspiand/dotfiles/actions/workflows/gc.yml) — use `dry-run: true` first to preview.

Pruning phases:
- **Orphan NARs** — NAR files with no matching narinfo
- **Stale packages** — Store paths not in current flake
- **Age-based** — Objects older than 30 days
- **Keep latest 2** — Per package, keep newest 2 versions
