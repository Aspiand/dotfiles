# Dotfiles — NixOS Configuration Repository

## Rules

- **DO NOT DECRYPT THE SECRETS.** Never run `sops -d`, `sops exec-env`, `sops edit` unless
  asked, or any other command that opens the contents of `secrets/`. To reference a secret in
  config, use its path (`config.sops.secrets.<name>.path`), never its contents.
- **Never print secret contents** to chat, logs, new files, or commits — including anything
  already decrypted by accident. If a secret is exposed, stop and report it.
- **Never commit plaintext.** Every file under `secrets/` must be `sops` output (`.yml`,
  `.json`, `.ini`, `.env`, `.enc`). A plaintext file there is a bug — do not stage it.
- Changes to `.sops.yaml` (keys, recipients, `creation_rules`) are security changes: explain
  the impact before touching it.
- Everything else follows the repo conventions below.

## Architecture

```
./
├── flake.nix               # flake-parts + importTree + lib helpers
├── lib/                    # mkDefaults, importTree, loadCustomModules, runTests
├── nix/
│   ├── packages/           # Package derivations (auto-imported, exposed as overlays)
│   ├── wrappers/           # Wrapped CLI tools (auto-imported, `nix run .#<name>`)
│   └── modules/            # Custom module DEFINITIONS (options+services, NOT preconfigured)
├── nixos/
│   ├── modules/            # Preconfigured NixOS modules (auto-imported)
│   └── hosts/*/            # Standalone host flakes
├── home-manager/           # Standalone Home Manager flake (own inputs)
├── docs/                   # Guides: SECRETS, cache, update, rustic, ci
├── secrets/                # SOPS-encrypted secrets (see docs/SECRETS.md)
├── cache.yml               # Package list + watch list for the CI cache build
├── CACHE_REPORT.md         # Generated cache report (written by CI)
└── .github/workflows/      # CI: build, check, update
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

Wrapper outputs live in `packages.<system>` too, but they are **not** injected into
`overlays.default` — several share names with nixpkgs attrs (`git`, `tmux`, `fzf`) and would
shadow them. Add them to a host's `environment.systemPackages` explicitly, or via `my-tools`.

## Packages (nix/packages/)

Package derivations auto-import into the flake as `packages.<system>.<name>` only. The single
`overlays.default` is generated from those packages, so `pkgs.<name>` on a host is the *same
derivation* as `nix build .#<name>` — always built against the root flake's nixpkgs.

That means a package does **not** see host-local pkgs tweaks (`allowUnfree`, extra overlays,
`python3Packages` overrides). If one package genuinely needs them, give that file a `final:`
overlay of its own instead of changing the pattern for everything.

See `README.md` for consumption examples.

## Hosts (nixos/hosts/)

Each directory under `nixos/hosts/` is a **standalone flake** — its own `flake.nix` referencing
the root via `path:../../../`, plus host-local `.nix` config. Enumerate hosts: `ls nixos/hosts/`.

Hosts pin their own `nixpkgs` channel; the root flake's `nixpkgs` is independent and can drift
from it. `pkgs-unstable` is passed to hosts as a `specialArgs` extra where needed.

## Home Manager (home-manager/)

Standalone Home Manager flake with its own inputs (home-manager, sops-nix). Not wired into the
root flake. Layout: `flake.nix`, `default.nix`, `modules/`, `profiles/`.

## Secrets (secrets/ + docs/SECRETS.md)

SOPS-encrypted per-environment files referenced by modules via `sops.secrets.*`.
Recipients and `creation_rules` live in `.sops.yaml`. See [docs/SECRETS.md](docs/SECRETS.md).

Editing:

```sh
sops secrets/<file>
```

Never decrypt into the repo. See the Rules section at the top.

## CI (`.github/workflows/`)

- `build.yml` — scheduled R2 nix cache build (package list and watch list: `cache.yml`;
  output report: `CACHE_REPORT.md`)
- `check.yml` — `nix flake check` on every push
- `update.yml` — daily auto-update of watched inputs; opens/merges an `auto-update/*` branch

See [docs/cache.md](docs/cache.md) and [docs/update.md](docs/update.md).

## Testing

```sh
nix flake check --no-build        # runs `checks.lib-tests` (lib/test.nix) + validates the flake
nix build .#<package>             # build one package
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

## Adding a Package

1. Create `nix/packages/<name>.nix`:

   ```nix
   { ... }: {
     perSystem = { pkgs, ... }: {
       packages.<name> = pkgs.<builder> { ... };
     };
   }
   ```

2. No overlay, no `mkPackage` wrapper — the root overlay picks it up automatically.
3. Add the package name to `cache.yml` if CI should cache it.
