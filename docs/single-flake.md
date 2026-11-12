# One flake for every host

Hosts and Home Manager profiles now live in the root flake as
`nixosConfigurations.<name>` and `homeConfigurations.<username>`. The per-host
flakes are gone.

Input isolation is not lost — it moved from the *lockfile* level to the
*specialArgs* level. A host only sees the inputs explicitly handed to it.

## Layout

```
flake.nix                       # the only flake + lockfile
flake.lock
nixos/
├── hosts/
│   ├── default.nix             # mkHost
│   ├── aira/{default,configuration,home,gnome,hardware-configuration}.nix
│   ├── alef/{default,configuration,disko,hardware}.nix
│   ├── azel/                   # DEAD — broken, its own flake (docs/azel-scripts.md)
│   ├── delta/{default,configuration,disko,hardware,services}.nix
│   ├── elasticlabs/            # not migrated yet
│   └── nova/{default,configuration,disko,hardware,hermes,secrets,services}.nix
└── vm/                         # not migrated yet
home-manager/
├── default.nix                 # → flake `homeModules.default`
├── modules/                    # shared modules
└── profiles/                   # → flake `homeConfigurations.<username>`
```

`nixos/hosts/<h>/flake.nix` and `flake.lock` are deleted for aira, alef, delta
and nova. No more `dotfiles.url = "path:../../../"`.

## Usage

```sh
nixos-rebuild switch --flake ~/.config/dotfiles#aira
home-manager switch --flake ~/.config/dotfiles#aspian
nix build .#nixosConfigurations.nova.config.system.build.toplevel
```

Username = profile. `homeConfigurations` is keyed by username
(`kuro`/`aspian`/`pc`/`yuki`), so you never have to remember which machine name
belongs to which person.

## `nixos/hosts/default.nix`

```nix
{ self }:
{
  modules,
  system ? "x86_64-linux",
  nixpkgs ? self.inputs.nixpkgs,
  inputs ? { },
  extraSpecialArgs ? { },
}:
nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit self inputs; } // extraSpecialArgs;

  modules = [
    {
      nixpkgs.overlays = [ self.overlays.default ];
      system.nixos.revision = nixpkgs.lib.mkDefault (
        self.rev or self.dirtyRev or "Unknown"
      );
    }
    { imports = self.modules.imports; }
  ] ++ modules;
}
```

`inputs` is that host's own slice of the root flake inputs. A name that was not
handed over is not in scope, so evaluation fails loudly
(`attribute 'sops-nix' missing`) instead of silently borrowing another host's
input.

`self.modules.imports` carries every custom module from `nix/modules/`; the host
still has to set `services.<name>.enable = true` itself.

## nixpkgs channel

The root flake follows the `nixos-unstable` branch:

```nix
nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
```

The exact commit is pinned in `flake.lock`, so builds are reproducible without a
rev in `flake.nix` — a rev there would be redundant. Bump with
`nix flake update nixpkgs`.

Why this is safe to leave on the branch: `python3Packages.fastmcp-slim` carries
`broken = lib.versionAtLeast mcp.version "2"`, and `mcp` is now 2.3.0 while
`fastmcp` has not ported yet. `hindsight-api` depends on it.
`nix/packages/hindsight.nix` handles that itself — it scopes `mcp` back to the
1.x line, guarded on `fastmcp-slim` actually being broken so the override
retires by itself once nixpkgs moves to mcp 2 (NixOS/nixpkgs#563493).

What still guards against a bad nixpkgs bump is CI: `.github/workflows/check.yml`
evaluates every `nixosConfigurations` and `homeConfigurations` entry on push.

A host that needs a different channel picks `nixpkgs` per host — a whole-eval
choice, so lib, the module set and packages all come from that same nixpkgs:

```nix
delta = mkHost {
  nixpkgs = inputs.nixpkgs-26-05;
  ...
};
```

Do **not** use `nixpkgs.pkgs = import <other-nixpkgs> {}`. That mixes NixOS
modules from one nixpkgs with packages from another and fails at eval time
(`attribute 'buildDTBs' missing`). Tested.

All four hosts use the root `nixpkgs` **except** where a host overrides it:
`aira` and `alef` use the root `nixpkgs` (verified: `pkgs.path` is the same store
path for both), while `nova` and `delta` use `nixpkgs-26-05` (also the same store
path as each other), matching what they were on before the migration.

## Home Manager

`homeModules.default` is `home-manager/default.nix` (autoloads `modules/` plus
`profiles/default.nix`). NixOS hosts use it via `self.homeModules.default`.

```nix
# nixos/hosts/aira/default.nix
{
  home-manager = {
    extraSpecialArgs = { inherit inputs self; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.ao = ./home.nix;
    backupFileExtension = "bak";
  };
}
```

```nix
# nixos/hosts/aira/home.nix
{
  self,
  inputs,
  ...
}:
{
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
    self.homeModules.default
    inputs.sops-nix.homeManagerModules.sops
  ];
}
```

`homeConfigurations` for non-NixOS machines is built with the root flake's
overlay, because `modules/mcp.nix` uses `pkgs.mempalace`. Profiles are discovered
from `home-manager/profiles/` and keyed by the `home.username` each one declares,
so there is no second username→profile map to keep in sync:

```nix
homeConfigurations =
  let
    mkHome = profile: inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        overlays = [ inputs.self.overlays.default ];
      };
      modules = [ profile ];
    };

    profiles = map
      (name: mkHome (./home-manager/profiles + "/${name}"))
      (builtins.attrNames (
        lib.filterAttrs
          (name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix")
          (builtins.readDir ./home-manager/profiles)
      ));
  in
  builtins.listToAttrs (
    map (config: lib.nameValuePair config.config.home.username config) profiles
  );
```

The keys come from the profiles themselves (`manjaro.nix` → `kuro`, `mint.nix` →
`aspian`, `work.nix` → `pc`, `yuki.nix` → `yuki`). Rename a user inside a profile
and the flake attribute follows; there is nothing else to update.

## Isolation: verified

| Case | Result |
|---|---|
| host without `sops-nix`, module uses `inputs.sops-nix` | `error: attribute 'sops-nix' missing` ✓ |
| host with `sops-nix` | evaluates ✓ |
| `nixpkgs.pkgs` = a different nixpkgs, modules from root | `error: attribute 'buildDTBs' missing` ✗ |

## Overlay caveat

`nix/packages` is exposed through `overlays.default`, and that overlay builds
from the **root** flake's package set — not from the host's `prev`.

So nova and delta (on `nixpkgs-26-05`, python 3.13) receive `hindsight-api` and
the rest of `nix/packages` built against the root pin (python 3.14). They eval
and build, but the closure mixes two nixpkgs.

This is **pre-existing**, not introduced by the migration: before this change,
`nixos/hosts/nova/flake.nix` also pulled a different nixpkgs for `dotfiles` than
for the system (26.05 host, an unstable overlay).

Building the overlay from `prev` is the correct fix, but it fails today: nixpkgs
26.05 has neither `mcp_1` nor `fastmcp-slim`, and its `markitdown` carries no
optional dependency groups (`pdf`/`docx`/`pptx`/`xlsx`/`xls`), all of which
`nix/packages/hindsight.nix` needs. Making it work means either packaging
hindsight per-channel or dropping hindsight from the 26.05 hosts.

## Verification

```sh
for h in alef delta nova aira; do
  nix eval --raw ".#nixosConfigurations.$h.config.system.build.toplevel.drvPath" >/dev/null && echo "$h OK"
done

for u in kuro aspian pc yuki; do
  nix eval --raw ".#homeConfigurations.$u.activationPackage.drvPath" >/dev/null && echo "hm:$u OK"
done
```

Note: `nix eval .#...` reads the *git tree*, so an un-`git add`ed file is not
visible. Use `nix eval path:$PWD#...` when you have unstaged changes.

## CI

- `check.yml` — the `find . -name flake.nix` pass still applies (azel,
  elasticlabs, vm, home-manager, nix-on-droid), plus a new step that evaluates
  every `nixosConfigurations` and `homeConfigurations` entry (drvPath only, no
  builds).
- `build.yml` — `lock:<host>` was removed entirely: with hosts on different
  channels the root lock holds one nixpkgs node per channel, so an owner/repo
  match was ambiguous. Watched inputs now pin with `branch:` / `tag:` / `rev:`.
- `docs/cache.md` — the `lock:<host>` table row is gone.

## Remaining work

0. **`azel` — DEAD config.** Does not evaluate, and did not before the migration
   either. `home-manager/modules/opencode.nix` sets `programs.opencode.cli`, but
   current home-manager renamed that option to `programs.opencode.tui`:

   ```
   error: The option `home-manager.users.aka.programs.opencode.cli' does not exist.
          Did you mean ...programs.opencode.tui'?
   ```

   It is skipped in `check.yml` via `DEAD_FLAKES=(./nixos/hosts/azel)`. Remove
   that entry once fixed. It still has its own flake (`flake.lock` intact), so
   nothing here is blocking a fix.

1. **`elasticlabs`** — still its own flake, not migrated.
2. **`nixos/vm` + `nixos/vm/myvm`** — two microvm flakes with near-identical
   contents. Check which one is still used before merging.
3. **`nix-on-droid/`** — needs `nixos-unstable-small` as a separate input. Could
   become `nixOnDroidConfigurations` in the root flake, or be dropped if unused.

## Fixes that came with the migration

- `home-manager/modules/ssh.nix`: `programs.ssh.controlMaster/controlPersist/
  controlPath` → `programs.ssh.settings."*".*` (the old options no longer take
  effect).
- `home-manager/profiles/*.nix`: `programs.git.extraConfig` →
  `programs.git.settings`.
- `home-manager/profiles/manjaro.nix`: `services.gpg-agent.pinentryPackage` →
  `services.gpg-agent.pinentry.package`; `neofetch` → `fastfetch` (`neofetch`
  was removed from nixpkgs).
- `.myclirc` restored from `20f0359^`; `modules/mycli.nix` still references
  `../../.myclirc`.
- `nixos/hosts/aira/home.nix`: `prismlauncher` from nixpkgs (the
  `elyprismlauncher` input was dropped); `inputs.home-config.homeModules.default`
  → `self.homeModules.default`.
