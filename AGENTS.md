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

| Export | File | What it configures |
|--------|------|-------------------|
| `base` | `base.nix` | Common across all hosts. timezone, nix GC/settings, pipewire, tailscale, docker, zramSwap, rtkit, i18n locale, btrfs-progs+gparted. All mkDefault. See skill: `nixos-flake-module-patterns`. |
| `ssh` | `ssh.nix` | Hardened OpenSSH daemon (PQ KEX, AEAD ciphers, ED25519 host keys, rate limiting). All mkDefault. |
| `fail2ban` | `fail2ban.nix` | Fail2ban SSH jail, aggressive mode, incremental bans. All mkDefault. |
| `caddy` | `caddy.nix` | Caddy reverse proxy, OCSP, trusted_proxies. Email placeholder — host MUST set. All mkDefault. |
| `desktop` | `desktop.nix` | Pipewire only. Redundant with base. Kept as pattern. |

Module pattern: `config = lib.mkDefault { ... }`. Hosts override any leaf at normal priority.

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

1. Create `nixos/modules/<name>.nix` using `config = lib.mkDefault { ... }` pattern.
2. Import in host flake: `dotfiles.nixosModules.<name>`.
3. Update this table and skill `nixos-flake-module-patterns`.
4. Write access: files owned by `ubuntu` — use `sudo tee`.
