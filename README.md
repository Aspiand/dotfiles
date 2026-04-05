# dotfiles

## Hanabi

### Flake

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    hanabi = {
      url = "github:aspiand/dotfiles";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

### Use the package directly

```nix
{ pkgs, inputs, ... }:
let
  hanabi = inputs.hanabi.packages.${pkgs.system}.hanabi;
in
{
  home.packages = [ hanabi ];

  dconf.settings."org/gnome/shell".enabled-extensions = [
    hanabi.extensionUuid
  ];
}
```

### Use the overlay

```nix
{
  nixpkgs.overlays = [ inputs.hanabi.overlays.default ];

  environment.systemPackages = [
    pkgs.hanabi
  ];
}
```
