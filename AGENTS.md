# Dotfiles — NixOS Configuration Repository

## Overview

This repo manages NixOS configurations for multiple hosts using **flake-parts** with auto-module-discovery via `importTree`. Each host is a standalone flake that references this repo as a `path:` input.

## Architecture

```
/host/dotfiles/
├── flake.nix                  # Root flake: flake-parts + importTree
├── nix/                       # Flake-parts modules (auto-imported)
│   ├── hermes-agent.nix       #   hermes-agent systemd service
│   ├── 9router.nix            #   9router package + overlay
│   ├── codegraph.nix          #   Codegraph package
│   ├── hanabi.nix             #   Hanabi package
│   ├── hermes-desktop.nix     #   Hermes desktop config
│   ├── openhuman.nix          #   OpenHuman package
│   ├── pake.nix               #   Pake package
│   ├── tlauncher.nix          #   TLauncher package
│   └── _sources/              #   Locked source metadata
│
├── nixos/
│   ├── modules/               # Flake-parts modules (auto-imported via flake.nix)
│   │   ├── ssh.nix            #   Hardened SSH daemon
│   │   ├── fail2ban.nix       #   Fail2ban with SSH jail
│   │   └── caddy.nix          #   Caddy reverse proxy
│   │
│   └── hosts/                 # Per-host standalone flakes
│       ├── aira/              #   Main desktop — AMD, GNOME, Hermes, Home Manager
│       ├── azel/              #   Desktop — impermanence, disko, DMS
│       └── delta/             #   VM — Oracle ARM, disko
│
└── AGENTS.md                  # This file
```

## Module System

### Root Flake (`flake.nix`)
- Uses `flake-parts` with `importTree` for auto-discovery.
- `importTree = path` — recursively imports all `.nix` files (except `flake.nix` and files starting with `_`).
- **Import paths:** `./nix` AND `./nixos/modules` — both are auto-discovered.
- Each file must be a valid flake-parts module: `{ ... }: { flake = ...; perSystem = ...; }`.

### Adding a New NixOS Module

1. Create `nixos/modules/<name>.nix`.
2. Use flake-parts syntax: the file exports `flake.nixosModules.<name>`.
3. Host flakes import via `inputs.dotfiles.nixosModules.<name>`.
4. No manual registration needed — `importTree` auto-discovers it.

Example:
```nix
{ ... }: {
  flake.nixosModules.<name> = { lib, ... }: let
    inherit (lib) mkDefault;
  in {
    services.<name> = mkDefault {
      # All values are wrapped in one mkDefault — no per-key mkDefault
      enable = true;
      # ...
    };
  };
}
```

### Pattern Convention — mkDefault

ALL values in a module are wrapped in a single top-level `mkDefault`:

```nix
let inherit (lib) mkDefault; in {
  services.<name> = mkDefault {
    key = "value";    # not lib.mkDefault "value"
    nested = {
      deep = true;    # not lib.mkDefault true
    };
  };
}
```

This keeps modules clean and lets hosts override any leaf value.

For lists that should be appended (not replaced), the host can use:
```nix
services.<name>.someList = lib.mkBefore [ "new" ];
```

### Available Modules (from nixos/modules/)

| Export | File | Description |
|--------|------|-------------|
| `ssh` | `ssh.nix` | Hardened SSH daemon (OpenSSH 9.8+). All wrapped in mkDefault. |
| `fail2ban` | `fail2ban.nix` | Fail2ban with SSH jail in aggressive mode. Incremental bans, RFC1918 ignore. All wrapped in mkDefault. |
| `caddy` | `caddy.nix` | Caddy reverse proxy with global OCSP, security headers. Email is placeholder — host MUST set. All wrapped in mkDefault. |

### Host Flake Pattern

Each host under `nixos/hosts/<name>/` is a **separate Nix flake** with:
- `flake.nix` — defines inputs including `dotfiles.url = "path:../../../"`.
- `configuration.nix` — NixOS config module.
- `hardware-configuration.nix` — auto-generated hardware config.

To use shared modules:
```nix
# nixos/hosts/<name>/flake.nix — in modules list:
inputs.dotfiles.nixosModules.ssh
inputs.dotfiles.nixosModules.fail2ban
inputs.dotfiles.nixosModules.caddy
```

Override in `configuration.nix`:
```nix
services.openssh.ports = [ 2222 ];
services.caddy.email = "admin@domain.tld";
services.fail2ban.enable = false;
```

### When Adding to `nix/` (flake-parts modules with packages/overlays)

Files in `nix/` can export:
- `perSystem.packages.<name>` — packages per architecture.
- `perSystem.overlays.<name>` — overlays per architecture.
- `flake.nixosModules.<name>` — same pattern as above.
- `flake.overlays.<name>` — flake-level overlays.

The root flake auto-combines overlays into `overlays.default`:
```nix
overlays = flakeOutputs.overlays // {
  default = final: prev:
    lib.foldl' (acc: overlay: acc // (overlay final acc)) {} (
      lib.attrValues (lib.removeAttrs flakeOutputs.overlays [ "default" ])
    );
};
```

## Hosts Quick Reference

| Host | Arch | Key Features |
|------|------|-------------|
| aira | x86_64 | GNOME, Hermes Agent, SPICETIFY, Home Manager |
| azel | x86_64 | Impermanence (tmpfs root), Disko (LUKS + BTRFS), DMS, Home Manager |
| delta | aarch64 | Oracle ARM VM, Disko, basic config |

## SSH Module (`ssh.nix`)

**Export:** `flake.nixosModules.ssh`

All values wrapped in `services.openssh = mkDefault { ... }`.

### Hardening Summary
- **Auth:** publickey only, no password/KbdInteractive.
- **Root login:** prohibit-password (keys OK, password not).
- **KEX:** sntrup761x25519 (post-quantum hybrid) primary, Curve25519 fallback.
- **Ciphers:** ChaCha20-Poly1305, AES-GCM, AES-CTR (no CBC/3DES).
- **MACs:** EtM preferred (hmac-sha2-512-etm), SHA2 only.
- **Host keys:** ED25519 + RSA 4096 + ECDSA.
- **Rate limit:** MaxAuthTries=3, LoginGraceTime=60s, MaxStartups=10:30:100.
- **Session:** AllowTcpForwarding=yes, X11Forwarding=no.
- **Keep alive:** ClientAliveInterval=300, ClientAliveCountMax=0.
- **SFTP:** audit logging via `sftp-server -f AUTHPRIV -l INFO`.
- **OpenSSH 9.8+:** RequiredRSASize=2048.

### Impermanence Note
If host uses tmpfs root (azel), `/etc/ssh` must be persisted:
```nix
environment.persistence."/persist/system".directories = [ "/etc/ssh" ];
```

## Fail2ban Module (`fail2ban.nix`)

**Export:** `flake.nixosModules.fail2ban`

All values wrapped in `services.fail2ban = mkDefault { ... }`.

### Configuration Summary
- **SSH jail:** `mode=aggressive` (catches more auth failure patterns).
- **Threshold:** maxretry=3, findtime=600s (10 min window).
- **Ban:** bantime=3600s (1h initial), escalating via `bantime-increment`.
- **Ignore:** RFC1918 private ranges (10/8, 172.16/12, 192.168/16) never banned.
- **Firewall:** uses nftables (nftables-multiport / nftables-allports).

## Caddy Module (`caddy.nix`)

**Export:** `flake.nixosModules.caddy`

All values wrapped in `services.caddy = mkDefault { ... }`.

### Configuration Summary
- **Default email:** `admin@example.com` — host MUST override this for Let's Encrypt.
- **Data:** `/var/lib/caddy`
- **Logs:** `/var/log/caddy`
- **ACME:** Let's Encrypt production.
- **Admin API:** `localhost:2019`
- **Global config:** OCSP stapling enabled, trusted_proxies set to private ranges.

### Host Must Set
```nix
services.caddy.email = "admin@domain.tld";
```

Virtual hosts are defined per-host, not in this module.
