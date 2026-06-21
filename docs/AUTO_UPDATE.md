# Auto-Update Guide

This document explains how automatic package updates work in this dotfiles repository.

## Overview

Packages in `nix/packages/` are automatically checked for upstream updates daily
using [nix-update](https://github.com/berberman/nix-update). If new versions are found
and all packages build successfully, the updated sources are committed to `main`.

## How it works

```
daily 18:00 UTC (or manual trigger)
     │
     ▼
 ┌─────────┐     ┌─────────┐     ┌─────────┐
 │ update   │────▶│ build   │────▶│ promote │
 │ nix-update│     │ verify  │     │ merge   │
 │ flake up │     │ all pkg │     │ to main │
 └─────────┘     └─────────┘     └─────────┘
   │                │
   │ no changes?    │ build fail?
   ▼                ▼
  STOP            STOP
```

1. **update** — `nix-update` runs for every `nix/packages/*.nix`, then `nix flake update`
2. **build** — `build.yml` verifies all packages build on the staging branch
3. **promote** — fast-forward merges staging branch into `main`

If no files changed → pipeline stops. If any build fails → staging branch is abandoned.

## File structure

| File | Role |
|---|---|
| `nix/packages/*.nix` | Package derivations with inline `src` and `version`. All files here are auto-updated. |
| `.github/workflows/update.yml` | Scheduled workflow: nix-update → staging branch → calls `build.yml` → merges on success. |
| `.github/workflows/build.yml` | Build workflow: reusable via `workflow_call`, also triggered on push to `main`. |

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

To prevent a package from being auto-updated, **exclude it from the glob** in the
workflow. Currently the loop iterates `nix/packages/*.nix`. Options:

- **Move the file** out of `nix/packages/` (e.g. `nix/legacy/my-package.nix`) and import it manually
- **Add a comment/marker** and filter in the loop (not implemented yet)

Update pinned packages manually by editing `version`, `rev`/`url`, and `hash` in the `.nix` file.

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

For URL-based sources, nix-update can update the version and hash. You may need
to provide a custom `--override-filename` or update the URL pattern manually.

## The update workflow

File: `.github/workflows/update.yml`

```yaml
on:
  schedule:
    - cron: '0 18 * * *'   # Daily at 18:00 UTC
  workflow_dispatch:
    inputs:
      force:
        description: "Force test — commit empty change and run build+promote"
        type: boolean
        default: false
```

Jobs:

1. **update** — Iterates `nix/packages/*.nix`, runs `nix-update` per package, runs `nix flake update`, commits to a temporary branch
2. **build** — Calls `build.yml` to verify the staging branch builds
3. **promote** — If builds pass, merges the staging branch into `main`

### Force test

If you trigger the workflow with `force: true`, it commits an empty change and
runs the full build+promote pipeline. This is useful for testing the CI without
actual package updates.
