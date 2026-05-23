# dotfiles

## Get Started

Add to your `flake.nix`:

```nix
inputs.dotfiles.url = "github:aspiand/dotfiles";
```

### 1. Using Overlays

All packages at once:

```nix
{
  nixpkgs.overlays = [ inputs.dotfiles.overlays.default ];
  environment.systemPackages = with pkgs; [ codegraph hanabi 9router openhuman ];
}
```

Or individually:

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
| **OpenHuman** | [tinyhumansai/openhuman](https://github.com/tinyhumansai/openhuman) | Personal AI super intelligence. |
| **9router** | [decolua/9router](https://github.com/decolua/9router) | Unlimited FREE AI coding router. |

**Using the Binary Cache:**

- Set yourself as `trusted-users` (see [docs/R2_CACHE_GUIDE.md](docs/R2_CACHE_GUIDE.md)) to use the flake's built-in Nix binary cache automatically.
- Cache operations: [CACHE_REPORT.md](CACHE_REPORT.md) — generate report, clean packages, run GC.
