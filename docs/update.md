# Auto-Update Guide

This document explains how automatic package updates work in this dotfiles repository.

## Overview

Packages in `nix/packages/` are automatically checked for upstream updates daily
using [nix-update](https://github.com/Mic92/nix-update). If new versions are found
and all updated packages build successfully, the changes are committed to `main`.

## How it works

```
daily 18:37 UTC (or manual trigger)
     │
     ▼
 ┌─────────┐     ┌─────────┐     ┌─────────┐
 │ update   │────▶│ build   │────▶│ promote │
 │ nix-update│     │ verify  │     │ merge   │
 │ flake up │     │ changed │     │ to main │
 └─────────┘     │ pkgs    │     └─────────┘
   │             └─────────┘
   │ no changes?    │ build fail?
   ▼                ▼
  STOP            STOP (branch abandoned)
```

1. **update** — `nix-update` runs for every `nix/packages/*.nix` (except ignored)
2. **build** — builds the packages that actually changed
3. **promote** — fast-forward merges the staging branch into `main`

If no files changed → pipeline stops. If any updated package fails to build → the
staging branch is abandoned.

`flake.lock` (nixpkgs etc.) is deliberately **not** bumped by this workflow — update it
manually when a package actually needs a newer nixpkgs.

## File structure

| File | Role |
|---|---|
| `nix/packages/*.nix` | Package derivations with inline `src` and `version`. All files here are auto-updated (except ignored). |
| `.github/workflows/update.yml` | Scheduled workflow: nix-update → build → promote to `main`. |
| `cache.yml` | `packages.ignore` lists packages excluded from auto-update and cache builds. |

## Adding a new package to auto-update

1. **Create the package derivation** in `nix/packages/<name>.nix`:

```nix
{ ... }:

let
  mkMyPackage =
    pkgs:
    pkgs.stdenv.mkDerivation rec {
      pname = "my-package";
      version = "1.0.0";

      src = pkgs.fetchFromGitHub {
        owner = "owner";
        repo = "my-package";
        rev = "v1.0.0";
        hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      };

      # ... build inputs, phases, meta
    };
in
{
  flake.overlays.my-package = final: _: {
    my-package = mkMyPackage final;
  };

  perSystem =
    { pkgs, ... }:
    {
      packages = {
        my-package = mkMyPackage pkgs;
      };
    };
}
```

That's it. The workflow auto-discovers all `*.nix` files in `nix/packages/`.

2. **Verify** the package builds:

```bash
nix build .#packages.x86_64-linux.my-package --no-link
```

## Pinning a package

To prevent a package from being auto-updated, add it to `cache.yml`
`packages.ignore` (e.g. `9router`, whose nested lockfile derivations nix-update
can't handle). The `update.yml` workflow reads that list and skips it.

Update pinned packages manually by editing `version`, `rev`/`url`, and `hash` in
the `.nix` file.

## nix-update source types

nix-update auto-detects the source type from the `src` attribute in the derivation.

### GitHub (fetchFromGitHub)

```nix
src = pkgs.fetchFromGitHub {
  owner = "owner";
  repo = "repo";
  rev = "v1.0.0";
  hash = "sha256-...";
};
```

nix-update detects the GitHub owner/repo from the fetcher args and checks for
the latest release/tag.

### URL (fetchurl)

```nix
src = pkgs.fetchurl {
  url = "https://example.com/package-${version}.tar.gz";
  hash = "sha256-...";
};
```

For URL-based sources, nix-update can update the version and hash. Some
`fetchurl` sources (e.g. fixed artifact URLs) have no detectable upstream — those
packages simply report as failed and are skipped for that run.

## The update workflow

File: `.github/workflows/update.yml`

```yaml
on:
  schedule:
    - cron: '37 18 * * *'   # Daily at 18:37 UTC
  workflow_dispatch:
    inputs:
      force:
        description: "Force test — commit empty change and run build+promote"
        type: boolean
        default: false
```

Jobs:

1. **update** — Iterates `nix/packages/*.nix`, skips `cache.yml` ignore list, runs
   `nix-update <pkg> --flake`, commits to a temporary branch
2. **build** — Builds each changed package on the staging branch
3. **promote** — If builds pass, fast-forward merges the staging branch into `main`

### Force test

If you trigger the workflow with `force: true`, it commits an empty change and
runs the full build+promote pipeline. This is useful for testing the CI without
actual package updates.
