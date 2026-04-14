# azel

Portable, Elegant, and Simple NixOS-Based Setup.

## System Stack

- **Boot**: UEFI only, `systemd-boot` (ESP at `/boot`).
- **Disk**: GPT, `disko` for partitioning.
- **Security**: `LUKS2` (`cryptroot`) with `randomEncryption` for swap.
- **Filesystem**: `Btrfs` with subvolumes for `@root`, `@home`, `@nix`, `@log`, and `@persist`.
- **Memory**: `zram` as primary swap, encrypted disk swap as fallback.
- **Persistence**: Declarative via `impermanence` at `/persist`.

---

## Flake Apps

The repository is the interface. Use these helpers from `nixos/hosts/azel`.

| Command | Description | Key Flags |
| :--- | :--- | :--- |
| `nix run .#mount` | Mounts system to `/mnt` | `--with-swap` |
| `nix run .#umount` | Unmounts everything & closes LUKS | - |
| `nix run .#build` | Evaluates & builds system closure | - |
| `nix run .#format` | Partitions/Formats target disk (**Destructive**) | `-y` |
| `nix run .#install` | Performs full `nixos-install` | `--format`, `--no-build`, `-y` |
| `nix run .#rebuild` | Offline update: Mount -> Build -> Activate | `-y` |

---

## Installation Flow

This is the standard path to deploy `azel` onto a new drive.

1. **Prepare**: Identify target drive `by-id` and update `device` in `./disko.nix`.
2. **Execute**: Run the consolidated installer:

   ```bash
   sudo nix run .#install -- --format
   ```

3. **Hardware Config**: After installation, generate and prune `./hardware-configuration.nix`:

   ```bash
   sudo nixos-generate-config --root /mnt --no-filesystems
   ```

4. **Boot**: Reboot and select the external UEFI entry.

---

## Maintenance

Use these commands when managing `azel` from an internal/host OS.

### Offline Rebuild

Update the external drive without booting into it:

```bash
sudo nix run .#rebuild
```

### Manual Inspection

Mount the tree for direct file access:

```bash
sudo nix run .#mount
# ... do work in /mnt ...
sudo nix run .#umount
```

---

## Layered Architecture

- **`modules/base`**: Core system, user, and networking (Tailscale).
- **`modules/storage`**: EFI, zram, and persistence policies.
- **`profiles/portable-safe`**: Baseline CLI tools and recovery environment.
- **`profiles/desktop-*`**: Graphical session layers (Hyprland, Caelestia).
- **`profiles/recovery`**: A TTY-only `specialisation` for troubleshooting.

---

## Verification

Post-boot checks to ensure environment integrity:

```bash
[ -d /sys/firmware/efi ] && echo "UEFI Active"
findmnt /             # Should be Btrfs
swapon --show         # zram should be priority 100
cryptsetup status cryptroot
```

## Directory Structure

```text
.
├── configuration.nix      # Host-specific overrides
├── disko.nix              # Partition layout
├── flake.nix              # Apps & Inputs
├── modules/               # Component logic
├── profiles/              # System variants
└── home/                  # User-space (Home Manager)
```
