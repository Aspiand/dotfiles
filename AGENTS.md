# Dotfiles — NixOS Configuration Repository

## Architecture

```
/host/dotfiles/
├── flake.nix                # flake-parts + importTree
├── nix/                     # Packages & overlays (auto-imported)
├── nixos/
│   ├── modules/             # Shared NixOS modules (auto-imported)
│   └── hosts/{aira,azel,delta}/  # Standalone host flakes
└── AGENTS.md
```

Root flake auto-imports `./nix` + `./nixos/modules` via `importTree`.

## Modules (nixos/modules/)

Each `.nix` file is a **bare flake-parts attrset** that exports `flake.nixosModules.<name>`.
The NixOS module inside imports `mkDefaults` directly — no `_module.args`, no injector.

**Canonical pattern:**

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

## Custom Module Definitions (nix/modules/)

Files under `nix/modules/` define NixOS module **options and services**, not preconfigured
config. They export `flake.customModules.<name>` and are aggregated into `dotfiles.modules`
— a single NixOS module that imports all custom definitions at once.

**Canonical pattern:**

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

| Export | File | What it configures | Needs `config` arg? |
|--------|------|-------------------|:---:|
| `base` | `base.nix` | timezone, nix GC/settings, networkmanager, zramSwap, i18n locale | No |
| `ssh` | `ssh.nix` | Hardened OpenSSH: PQ KEX, AEAD ciphers, ED25519 host keys, rate limiting | No |
| `fail2ban` | `fail2ban.nix` | SSH jail, aggressive mode, permanent bans, nftables backend | No |
| `caddy` | `caddy.nix` | Reverse proxy, OCSP, trusted_proxies. Email placeholder — host MUST set. | No |
| `desktop` | `desktop.nix` | Pipewire only. Redundant with base. Kept as pattern. | No |

| Export | File | What it defines | Source |
|--------|------|----------------|--------|
| `9router` | `9router.nix` | `services.9router` — AI router systemd service + firewall | `nix/modules/` |
| `hermes-agent` | `hermes-agent.nix` | `services.hermes-agent.gateway` — Hermes gateway user service | `nix/modules/` |

See skill: `nixos-flake-module-patterns` for full docs, history, and pitfalls.

## Hosts

| Host | Arch | Key features | Imports base? |
|------|------|-------------|:---:|
| aira | x86_64 | GNOME, Hermes Agent, Intel GPU, grub | ✓ |
| azel | x86_64 | Impermanence, Disko (LUKS+BTRFS), DMS, systemd-boot | ✓ |
| delta | aarch64 | Oracle ARM VM, Disko | — |

## Host Flake Pattern

```nix
# nixos/hosts/<host>/flake.nix
inputs.dotfiles.url = "path:../../../";
# in modules list: dotfiles.nixosModules.base
```

## Nix Module Testing

```sh
cd /host/dotfiles && nix flake check --no-build
```

## Adding a New Module

### Preconfigured (nixos/modules/)

1. Create `nixos/modules/<name>.nix` using canonical pattern above.
2. Import in host flake: `dotfiles.nixosModules.<name>`.
3. Update this table and skill `nixos-flake-module-patterns`.
4. Write access: files owned by `ubuntu` — use `sudo tee`.

### Custom definition (nix/modules/)

1. Create `nix/modules/<name>.nix` using the custom definition pattern above.
2. Hosts get it automatically via `dotfiles.modules`; enable with `services.<name>.enable = true`.
3. Individual access: `dotfiles.customModules.<name>`.
4. Write access: files owned by `ubuntu` — use `sudo tee`.
