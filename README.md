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
| **OpenHuman** | [tinyhumansai/openhuman](https://github.com/tinyhumansai/openhuman) | Personal AI super intelligence. |
| **9router** | [decolua/9router](https://github.com/decolua/9router) | Unlimited FREE AI coding router. |

**Using the Binary Cache:**
- Set yourself as `trusted-users` (see [docs/R2_CACHE_GUIDE.md](docs/R2_CACHE_GUIDE.md)) to use the flake's built-in Nix binary cache automatically.

## 🛠️ Setup Guides

### 9router

To run `9router`, you need to set a `JWT_SECRET` environment variable for the dashboard authentication.

```bash
# Direct run
JWT_SECRET=your_secret_here 9router

# With custom port and data directory
JWT_SECRET=your_secret_here PORT=3000 DATA_DIR=./data 9router
```

**Default Credentials:**
- **URL:** `http://localhost:20128`
- **Password:** `123456` (Change this in the dashboard immediately)

