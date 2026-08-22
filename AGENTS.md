# Dotfiles — NixOS Configuration Repository

## Architecture

```
./
├── flake.nix               # flake-parts + importTree + lib helpers
├── lib/                    # lib helpers: mkDefaults, importTree, loadCustomModules, mkDefaultOverlay, runTests
├── nix/
│   ├── packages/           # Package derivations (auto-imported, exposed as overlays)
│   ├── wrappers/           # Wrapped CLI tools (auto-imported, `nix run .#<name>`)
│   └── modules/            # Custom module DEFINITIONS (options+services, NOT preconfigured)
├── nixos/
│   ├── modules/            # Preconfigured NixOS modules (auto-imported)
│   └── hosts/*/            # Standalone host flakes
├── home-manager/           # Standalone Home Manager flake (own inputs)
├── docs/                   # Guides: secrets, cache, auto-update, rustic, cache-report
├── secrets/                # SOPS-encrypted secrets (see docs/SECRETS.md)
└── .github/workflows/      # CI: cache build, flake check, cache report
```

Root flake auto-imports `./nix/packages` + `./nix/wrappers` + `./nixos/modules` via `importTree`.
`./nix/modules` is merged separately via `loadCustomModules` into `dotfiles.modules`.

## Conventions (read these before adding anything)

- **One module/package = one `.nix` file**, named after its export. New files are auto-picked-up
  by `importTree` (skips `flake.nix` and `_`-prefixed files) — no registration needed.
- **Module docs live in the file header** (`/* ... */` at the top).
- **No hardcoding** — never list modules/hosts/wrappers individually in this file or in docs.
  Enumerate them live: `ls nixos/modules/ nix/modules/ nix/wrappers/ nix/packages/`.
- **Refer to `docs/`** for runnable setup guides.

## Two kinds of modules

| Kind | Location | Semantics | How hosts consume |
|------|----------|-----------|-------------------|
| **Preconfigured** | `nixos/modules/` | Exports `flake.nixosModules.<name>`; preconfigures real config via `mkDefaults` | `dotfiles.nixosModules.<name>` in host module list |
| **Custom definition** | `nix/modules/` | Exports `flake.customModules.<name>`; defines options/services only (no preconfigured config) | Auto via `dotfiles.modules`; enable with `services.<name>.enable = true` |

### Preconfigured module pattern (`nixos/modules/`)

```nix
# nixos/modules/<name>.nix
{
  flake.nixosModules.<name> =
    { lib, ... }:
    let
      mkDefaults = (import ../../lib { inherit lib; }).mkDefaults;
    in
    {
      config = mkDefaults {
        services.<name>.enable = true;
        # all leaf values recursively wrapped with lib.mkDefault
      };
    };
}
```

`lib/default.nix` provides `mkDefaults` — a pure function that recursively wraps
every non-attrs leaf with `lib.mkDefault`. Hosts override any leaf at normal priority.

### Custom module pattern (`nix/modules/`)

```nix
# nix/modules/<name>.nix
{ ... }: {
  flake.customModules.<name> = { config, lib, pkgs, ... }: {
    options.services.<name> = { ... };
    config = mkIf cfg.enable { ... };
  };
}
```

**Usage in host flake:**

```nix
modules = [
  dotfiles.modules          # ← imports all custom definitions
  # then enable what you need:
  # services.<name>.enable = true
];
```

Individual access still available via `dotfiles.customModules.<name>`.

## Wrapped CLI Tools (nix/wrappers/)

Bundle a CLI tool with its config via `wrapPackage` from the **`wrappers` flake input**
(`inputs.wrappers.lib.wrapPackage`, github:Lassulus/wrappers). Auto-imported into the flake,
exposed as `nix run .#<name>`.

```nix
# nix/wrappers/<name>.nix
{ ... }: {
  perSystem = { pkgs, lib, inputs, ... }: let
    wrapPackage = inputs.wrappers.lib.wrapPackage;
    conf = pkgs.writeText "<name>.conf" '' ... '';
  in {
    packages.<name> = wrapPackage {
      inherit pkgs;
      package = pkgs.<name>;
      env.SOME_VAR = conf;
      flags."-f" = conf;
    };
  };
}
```

See `nix/wrappers/` for the current list of wrapped tools.

## Packages (nix/packages/)

Package derivations auto-import into the flake and are exposed as `nixpkgs.overlays.<name>`
(plus a combined `overlays.default`). See `README.md` for consumption examples.

## Hosts (nixos/hosts/)

Each directory under `nixos/hosts/` is a **standalone flake** — its own `flake.nix` referencing
the root via `path:../../../`, plus host-local `.nix` config. Enumerate hosts: `ls nixos/hosts/`.

## Home Manager (home-manager/)

Standalone Home Manager flake with its own inputs (home-manager, sops-nix). Not wired into the
root flake.

## Secrets (secrets/ + docs/SECRETS.md)

SOPS-encrypted per-environment files referenced by modules via `sops.secrets.*`.
See [docs/SECRETS.md](docs/SECRETS.md) for setup.

## CI (`.github/workflows/`) WIP

- `build.yml` — scheduled R2 nix cache build (config: `cache.yml`, report: `docs/cache-report.md`)
- `check.yml` — flake check on push

See [docs/R2_CACHE_GUIDE.md](docs/R2_CACHE_GUIDE.md) and [docs/AUTO_UPDATE.md](docs/AUTO_UPDATE.md).

## Testing

```sh
nix flake check --no-build        # runs `checks.lib-tests` (lib/test.nix) + validates the flake
```

`lib/test.nix` unit-tests `mkDefaults` (flat/nested/deep attrs, lists, empty). Failures surface as
a failing derivation.

## Adding a Module

1. Create `nixos/modules/<name>.nix` (preconfigured) or `nix/modules/<name>.nix` (custom def) using
   the canonical pattern above.
2. Add a `/* */` header documenting behavior.
3. Hosts consume per the table above — preconfigured: add `dotfiles.nixosModules.<name>` to the host
   module list; custom def: enabled automatically via `dotfiles.modules`.
4. Run `nix flake check --no-build` to validate.
