# dotfiles

## Get Started

Add to your `flake.nix`:

```nix
inputs.dotfiles.url = "github:aspiand/dotfiles";
```

### 1. Using Overlays

```nix
{
  nixpkgs.overlays = [ inputs.dotfiles.overlays.codegraph ];
  environment.systemPackages = [ pkgs.codegraph ];
}
```

### 2. Direct Install

```nix
{
  home.packages = [ inputs.dotfiles.packages.${pkgs.system}.codegraph ];
}
```

## 📦 Available Packages

| Package | Source Repository | Note |
| :--- | :--- | :--- |
| **Codegraph** | [colbymchenry/codegraph](https://github.com/colbymchenry/codegraph) | Pre-indexed code knowledge graph. |
| **Hanabi** | [jeffshee/gnome-ext-hanabi](https://github.com/jeffshee/gnome-ext-hanabi) | GNOME Video Wallpaper. |
