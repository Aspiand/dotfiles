# Home Manager Configuration

A modular Home Manager configuration structure using `flake-parts`. Each profile maintains its own `flake.lock` for maximum dependency isolation.

## Folder Structure

- `configs/`: Contains modular configurations.
- `modules/`: Contains custom modules.
- `profiles/`: Contains specific profiles for each machine/user.
- `default.nix`: The main entry point that aggregates all configs and modules.

## How to Create a New Profile

You can use the following automated command from the repository root or the `home-manager/` folder:

```bash
# Inside the home-manager folder
nix run .#gen-profile <profile_name> [architecture]

# Example:
nix run .#gen-profile gaming x86_64-linux
```

This command will:

1. Create the `profiles/<profile_name>/` folder.
2. Generate `default.nix` and `flake.nix` templates.
3. Register the new profile in the root `flake.nix`.
4. Automatically `git add` the new files.

## How to Build a Profile

Each profile can be built independently from its own folder:

```bash
cd profiles/<profile_name>
home-manager build switch --flake .
```
