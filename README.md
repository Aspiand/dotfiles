# dotfiles

## Quick Action
[Build](https://github.com/Aspiand/dotfiles/actions/workflows/build.yml)

## Get Started

Add to your `flake.nix`:

```nix
inputs.dotfiles.url = "github:aspiand/dotfiles";
```

### 1. Using the overlay

`overlays.default` exposes every package, so `pkgs.<name>` is the same derivation as
`nix build .#<name>` — both built against this flake's nixpkgs.

```nix
{
  nixpkgs.overlays = [ inputs.dotfiles.overlays.default ];
  environment.systemPackages = with pkgs; [ hanabi 9router headroom ];
}
```

### 2. Direct Install

```nix
{
  home.packages = [ inputs.dotfiles.packages.${pkgs.stdenv.hostPlatform.system}.hanabi ];
}
```
