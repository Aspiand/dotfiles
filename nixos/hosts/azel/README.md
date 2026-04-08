# azel

`azel` is an independent flake-based NixOS host intended to become a portable external-drive operating system:

- UEFI-only, never legacy BIOS
- GPT + EFI System Partition mounted at `/boot`
- `systemd-boot`
- `disko`
- `LUKS2`
- `Btrfs`
- `zram` as the primary swap layer
- encrypted on-disk swap as lower-priority fallback
- declarative persistence via `/persist`
- modular host layout with a built-in recovery specialisation

## Get Started

This is the shortest safe path to install `azel` onto a portable SSD from an already running NixOS machine.

For repeated offline rebuilds from your internal laptop OS after `azel` is already installed, you can mount the whole installed system to `/mnt` with:

```bash
sudo nix run .#mount
```

Optional disk swap activation:

```bash
sudo nix run .#mount -- --with-swap
```

To cleanly detach it again:

```bash
sudo nix run .#umount
```

For the normal offline rebuild path, the shortest command is:

```bash
sudo nix run .#deploy
```

### 1. Enter the host directory

```bash
cd /home/ao/.config/dotfiles/nixos/hosts/azel
```

### 2. Identify the portable SSD

```bash
lsblk -o NAME,SIZE,MODEL,FSTYPE,MOUNTPOINTS
ls -l /dev/disk/by-id
```

Then edit [`disko.nix`](/home/ao/.config/dotfiles/nixos/hosts/azel/disko.nix) and replace:

```nix
device = "/dev/disk/by-id/CHANGE-ME";
```

Use the portable SSD `by-id` path, not `/dev/sdX`, unless you have no stable alternative.

### 3. Review the defaults you care about

Files to check before install:

- [`modules/base/core.nix`](/home/ao/.config/dotfiles/nixos/hosts/azel/modules/base/core.nix)
- [`modules/base/networking.nix`](/home/ao/.config/dotfiles/nixos/hosts/azel/modules/base/networking.nix)
- [`home/base.nix`](/home/ao/.config/dotfiles/nixos/hosts/azel/home/base.nix)
- [`configuration.nix`](/home/ao/.config/dotfiles/nixos/hosts/azel/configuration.nix)

Important defaults right now:

- username: `aka`
- initial password: `nixos`
- hostname: `azel`
- timezone: `Asia/Makassar`
- editor: `micro`
- Tailscale service: enabled
- backup module: imported but disabled

### 4. Partition, encrypt, format, and mount the SSD

This destroys the target portable SSD.

```bash
sudo nix --experimental-features 'nix-command flakes' \
  run github:nix-community/disko -- \
  --mode disko ./disko.nix
```

After this finishes, the new system tree should be mounted under `/mnt`.

### 5. Generate hardware configuration for the target machine

```bash
tmpdir="$(mktemp -d)"
sudo nixos-generate-config --root /mnt --dir "$tmpdir"
cp "$tmpdir/hardware-configuration.nix" ./hardware-configuration.nix
rm -rf "$tmpdir"
```

Then open [`hardware-configuration.nix`](/home/ao/.config/dotfiles/nixos/hosts/azel/hardware-configuration.nix) and remove:

- `fileSystems`
- `swapDevices`

Those are already handled by [`disko.nix`](/home/ao/.config/dotfiles/nixos/hosts/azel/disko.nix).

### 6. Install `azel`

```bash
sudo nixos-install --root /mnt --flake .#azel
```

This stays UEFI-only:

- the EFI System Partition is mounted at `/boot`
- `systemd-boot` is used
- `boot.loader.efi.canTouchEfiVariables = false` avoids modifying the installer machine's NVRAM

### 7. Reboot and boot the portable SSD in UEFI mode

```bash
sudo reboot
```

Use the firmware boot picker and choose the external UEFI entry from the portable SSD.

### 8. Verify the installed system

```bash
[ -d /sys/firmware/efi ] && echo EFI || echo Legacy
findmnt -no FSTYPE /
sudo cryptsetup status cryptroot
swapon --show
tailscale status || true
```

What you want to see:

- `EFI`, not `Legacy`
- root on `btrfs`
- `cryptroot` active
- `zram` with higher priority than disk swap
- Tailscale service available after first boot

## Offline Rebuild Workflow From The Internal Laptop OS

Use this workflow when:

- you boot into the internal laptop NixOS
- the `azel` repo lives there
- the external `azel` SSD is plugged in
- you want to update the external target without booting into it first

### 1. Mount the installed `azel` system

```bash
cd /home/ao/.config/dotfiles/nixos/hosts/azel
sudo nix run .#mount
```

This mounts:

- `/mnt`
- `/mnt/home`
- `/mnt/nix`
- `/mnt/var/log`
- `/mnt/persist`
- `/mnt/boot`

### 2. Build the new system closure on the laptop

```bash
sudo nix run .#build
```

### 3. Install the built result into the mounted target

```bash
sudo nix-env -p /mnt/nix/var/nix/profiles/system --set ./result
sudo nixos-enter --root /mnt -c 'NIXOS_INSTALL_BOOTLOADER=1 /nix/var/nix/profiles/system/bin/switch-to-configuration boot'
```

Do not use:

```bash
sudo nixos-rebuild switch --flake .#azel
```

when you are booted into the internal laptop OS, because that activates the current running host instead of the mounted external target.

### 4. Unmount when done

```bash
sudo nix run .#umount
```

Or do the whole offline rebuild workflow in one command:

```bash
sudo nix run .#deploy
```

## Goals

The design is intentionally split into two concerns:

- a base system that should remain easy to boot, repair, and move across machines
- an opinionated desktop layer that can fail without taking away the whole OS

This means `azel` is no longer a single monolithic config. It is now layered.

## Directory layout

```text
nixos/hosts/azel
├── flake.nix
├── configuration.nix
├── disko.nix
├── hardware-configuration.nix
├── home.nix
├── README.md
├── TODO.md
├── modules
│   ├── base
│   │   ├── core.nix
│   │   └── networking.nix
│   ├── ops
│   │   └── backup-restic.nix
│   └── storage
│       ├── boot-efi.nix
│       ├── persistence.nix
│       └── swap.nix
├── profiles
│   ├── portable-safe.nix
│   ├── desktop-hyprland.nix
│   ├── desktop-caelestia.nix
│   └── recovery.nix
└── home
    ├── base.nix
    ├── hyprland.nix
    └── caelestia.nix
```

## Layer model

## Flake Apps

The host flake exports three operational helpers:

- `nix run .#mount`
- `nix run .#umount`
- `nix run .#build`
- `nix run .#deploy`

These are implemented directly in `flake.nix`, so the repo itself is the interface.

### `modules/base/*`

These files hold the lowest-risk system defaults:

- user account
- locale and timezone
- Nix settings
- baseline networking, including Tailscale
- basic security and audio services
- shell and non-desktop system behavior

Rule of thumb:

- if the desktop breaks, these modules should still make the system usable

### `modules/storage/*`

These files define storage/runtime behavior that must stay coherent with the disk layout:

- EFI boot policy
- zram policy
- persistence via `/persist`

The actual declarative partition layout remains in [`disko.nix`](/home/ao/.config/dotfiles/nixos/hosts/azel/disko.nix).

### `modules/ops/*`

These files hold operational capabilities that are useful after the machine is already alive:

- backups
- maintenance jobs
- future sync tasks
- future monitoring hooks

This keeps operational policy separate from both the storage layer and the desktop layer.

### `profiles/portable-safe.nix`

This is the conservative runtime baseline. It adds tools that make the system recoverable and practical on unknown hardware:

- `btrfs-progs`
- `cryptsetup`
- `git`
- `home-manager`
- `micro`
- `tmux`

It also sets:

- `EDITOR=micro`
- `VISUAL=micro`

This profile is intentionally boring. That is its job.

### `profiles/desktop-hyprland.nix`

This is the graphical session layer:

- `Hyprland`
- `greetd`
- `tuigreet`
- `xdg-desktop-portal-hyprland`

If this profile is disabled, the base OS should still boot and remain repairable.

### `modules/ops/backup-restic.nix`

This is the backup module for important files.

It uses `restic` instead of `rustic` because:

- NixOS already ships a mature `services.restic.backups` module
- service and timer integration are simpler
- the result is easier to maintain for a portable machine

The module is imported by default, but it stays inactive until you explicitly enable it in [`configuration.nix`](/home/ao/.config/dotfiles/nixos/hosts/azel/configuration.nix).

### `profiles/desktop-caelestia.nix`

This is the higher-level UX layer:

- Caelestia support fonts
- Wayland-oriented session variables

Actual Home Manager Caelestia enablement lives in [`home/caelestia.nix`](/home/ao/.config/dotfiles/nixos/hosts/azel/home/caelestia.nix).

### `profiles/recovery.nix`

This file defines a `specialisation.recovery` variant of the same host.

The recovery specialisation:

- disables `greetd`
- disables `Hyprland`
- disables desktop portals
- keeps the system on a simpler, TTY-first path
- adds extra recovery tools like `rsync` and `tmux`

This is the safety net for cases where the normal desktop path is the problem.

## How the recovery specialisation works

`specialisation` in NixOS creates an alternate bootable variant from the same host configuration.

For `azel`, that means:

- the normal boot path is still the full desktop system
- an additional `recovery` entry is generated from the same host
- that recovery entry turns off the more fragile desktop parts

Why this is useful:

- if `Hyprland` fails on a machine
- if GPU or portal behavior is weird
- if a desktop-layer change makes login unreliable
- if you need a safer environment to inspect Btrfs, LUKS, logs, or persistence

Important limitation:

- `specialisation` is a fallback mechanism, not the main architecture tool
- the main structure still comes from `modules/*` and `profiles/*`

## Disk scheme

[`disko.nix`](/home/ao/.config/dotfiles/nixos/hosts/azel/disko.nix) defines:

- one GPT disk
- one `ESP` partition, 1G, `vfat`, mounted at `/boot`
- one on-disk swap partition, 8G, lower priority, encrypted with `randomEncryption = true`
- one `LUKS` container named `cryptroot`
- one `Btrfs` filesystem inside `cryptroot`

Btrfs subvolumes:

- `@root` mounted at `/`
- `@home` mounted at `/home`
- `@nix` mounted at `/nix`
- `@log` mounted at `/var/log`
- `@persist` mounted at `/persist`

Why `/boot` and not `/boot/efi`:

- this host uses `systemd-boot`
- for `systemd-boot`, mounting the ESP directly at `/boot` is the cleanest NixOS layout
- it avoids maintaining a separate `/boot` plus nested `/boot/efi` scheme

## Persistence model

`/persist` is active now. It is not just a placeholder.

The system persists these paths into `/persist/system`:

- `/etc/ssh`
- `/etc/machine-id`
- `/var/lib/nixos`
- `/var/lib/NetworkManager`
- `/var/lib/bluetooth`
- `/var/lib/systemd/coredump`

Why `/var/log` is not inside `/persist/system`:

- logs already live on their own Btrfs subvolume, `@log`
- logs have different churn and retention behavior from persistence-critical state
- separating them makes future cleanup and snapshot policy cleaner

## Swap model

There are two swap layers:

1. `zram`
2. encrypted on-disk swap

Current policy:

- `zramSwap.memoryPercent = 50`
- `zramSwap.priority = 100`
- disk swap priority = `10`

Meaning:

- compressed RAM swap is used first
- physical swap partition is fallback only

## What to edit before install

### 1. Set the target disk

Edit [`disko.nix`](/home/ao/.config/dotfiles/nixos/hosts/azel/disko.nix):

```nix
device = "/dev/disk/by-id/CHANGE-ME";
```

Use a stable `by-id` path whenever possible.

### 2. Adjust swap size if needed

Default:

```nix
swap = {
  size = "8G";
};
```

### 3. Change user defaults if needed

Relevant files:

- [`modules/base/core.nix`](/home/ao/.config/dotfiles/nixos/hosts/azel/modules/base/core.nix)
- [`home/base.nix`](/home/ao/.config/dotfiles/nixos/hosts/azel/home/base.nix)
- [`flake.nix`](/home/ao/.config/dotfiles/nixos/hosts/azel/flake.nix)

Current defaults:

- username: `aka`
- initial password: `nixos`
- hostname: `azel`
- timezone: `Asia/Makassar`
- Tailscale service: enabled

### 4. Configure backups if you want them enabled immediately

Relevant file:

- [`configuration.nix`](/home/ao/.config/dotfiles/nixos/hosts/azel/configuration.nix)

Current placeholder block:

```nix
azel.backup.restic = {
  enable = false;
  repository = null;
};
```

If you leave it as-is, the backup layer stays installed but inactive.

## External-drive installation from a running NixOS machine

Assumptions:

- this repo is available locally
- installation is being performed from another running NixOS system
- the target is an external drive
- you want UEFI boot only

### 1. Enter the host directory

```bash
cd /home/ao/.config/dotfiles/nixos/hosts/azel
```

### 2. Identify the correct target disk

```bash
lsblk -o NAME,SIZE,MODEL,FSTYPE,MOUNTPOINTS
ls -l /dev/disk/by-id
```

Then edit [`disko.nix`](/home/ao/.config/dotfiles/nixos/hosts/azel/disko.nix).

### 3. Partition, format, encrypt, and mount with `disko`

This destroys the target drive.

```bash
sudo nix --experimental-features 'nix-command flakes' \
  run github:nix-community/disko -- \
  --mode disko ./disko.nix
```

After this, the target filesystem tree should be mounted under `/mnt`.

### 4. Generate hardware configuration for the actual target machine

The checked-in [`hardware-configuration.nix`](/home/ao/.config/dotfiles/nixos/hosts/azel/hardware-configuration.nix) is intentionally generic.

Generate a fresh one:

```bash
tmpdir="$(mktemp -d)"
sudo nixos-generate-config --root /mnt --dir "$tmpdir"
cp "$tmpdir/hardware-configuration.nix" ./hardware-configuration.nix
rm -rf "$tmpdir"
```

Then review the generated file and remove `fileSystems` and `swapDevices`, because those are already managed by [`disko.nix`](/home/ao/.config/dotfiles/nixos/hosts/azel/disko.nix).

Usually you want to keep:

- `imports`
- `boot.initrd.availableKernelModules`
- `boot.initrd.kernelModules`
- `boot.kernelModules`
- `boot.extraModulePackages`
- `nixpkgs.hostPlatform`
- any firmware or microcode defaults that were detected

### 5. Install the system

```bash
sudo nixos-install --root /mnt --flake .#azel
```

Why this remains safe for an external installer host:

- `boot.loader.efi.canTouchEfiVariables = false`
- this prevents `nixos-install` from modifying the current machine's NVRAM
- the installed drive is still EFI-based
- you select it from the firmware boot menu of the target machine

### 6. Reboot and choose the external UEFI entry

```bash
sudo reboot
```

Use the machine's firmware boot picker and choose the UEFI entry from the external drive.

## How to use recovery mode

After the system has been installed and rebuilt successfully, the boot menu will include the normal system path plus a recovery specialisation entry.

Use the recovery entry when:

- the graphical login path is broken
- `Hyprland` starts unreliably on a machine
- you need a simpler environment for investigation
- you want to inspect storage, persistence, or logs without the full desktop stack

Expected behavior of recovery mode:

- no `greetd`
- no automatic graphical session
- no `Hyprland`
- no Wayland portal layer
- terminal-first troubleshooting workflow

This is not a separate host. It is a safer boot variant of the same host.

## Backup model

`azel` now includes a prepared backup module for important files.

Default backup scope:

- `/persist`
- `/home/aka/Documents`
- `/home/aka/Projects`
- `/home/aka/.ssh`
- `/home/aka/.gnupg`
- `/home/aka/.password-store`

Default excludes:

- `/persist/secrets/restic`
- `/home/aka/.cache`
- `/home/aka/.local/share/Trash`

Retention policy:

- keep 7 daily snapshots
- keep 5 weekly snapshots
- keep 12 monthly snapshots

Timer policy:

- `daily`

### Why `restic` here

You said `restic/rustic` is acceptable. I chose `restic` because it is the better fit for NixOS automation right now:

- less custom glue
- easier systemd integration
- easier to keep declarative

If you later want `rustic` specifically, the backup scope and retention policy here are still a good blueprint.

## How to enable backups

### 1. Create the password file

```bash
sudo install -d -m 0700 /persist/secrets/restic
sudo sh -c 'umask 077 && printf "%s" "CHANGE-ME-RESTIC-PASSWORD" > /persist/secrets/restic/password'
```

### 2. Edit the backup block in `configuration.nix`

Set at least:

```nix
azel.backup.restic = {
  enable = true;
  repository = "sftp:backup@example.com:/srv/restic/azel";
};
```

Repository examples:

- local disk path:
  `/mnt/backup-drive/restic/azel`
- SFTP:
  `sftp:backup@example.com:/srv/restic/azel`
- rest server:
  `rest:https://backup.example.com/azel`

### 3. Rebuild the system

```bash
sudo nixos-rebuild switch --flake .#azel
```

### 4. Trigger the first backup manually

```bash
sudo systemctl start restic-backups-important.service
```

### 5. Inspect the result

```bash
sudo systemctl status restic-backups-important.service
sudo journalctl -u restic-backups-important.service -n 100 --no-pager
```

### 6. Verify the timer

```bash
systemctl list-timers 'restic-backups-*'
```

## How to customize backup scope

You can override the default path list directly in [`configuration.nix`](/home/ao/.config/dotfiles/nixos/hosts/azel/configuration.nix):

```nix
azel.backup.restic = {
  enable = true;
  repository = "sftp:backup@example.com:/srv/restic/azel";
  paths = [
    "/persist"
    "/home/aka/Documents"
    "/home/aka/Projects"
    "/home/aka/Pictures"
  ];
  exclude = [
    "/persist/secrets/restic"
    "/home/aka/.cache"
  ];
  timer = "hourly";
};
```

Practical advice:

- keep `/persist` in the backup set
- do not back up the restic password file into the same repository
- avoid backing up the entire home directory unless you really want cache and application noise
- start with a small, high-value path set and widen it later

## Verification after boot

```bash
[ -d /sys/firmware/efi ] && echo EFI || echo Legacy
findmnt -no SOURCE /
findmnt -no FSTYPE /
sudo cryptsetup status cryptroot
sudo btrfs subvolume list /
swapon --show
```

Expected results:

- EFI should print, not Legacy
- root filesystem should be `btrfs`
- `cryptroot` should be active
- Btrfs subvolumes should be visible
- `zram` should have higher priority than disk swap

## Operational notes

- disk swap uses `randomEncryption = true`, so it is appropriate for swap fallback but not for hibernation / resume
- the current recovery story is boot-menu-based, not Secure Boot based
- hardware portability follow-up work is tracked in [`TODO.md`](/home/ao/.config/dotfiles/nixos/hosts/azel/TODO.md)

## References

- https://wiki.nixos.org/wiki/Btrfs
- https://nixos.org/manual/nixos/stable/#sec-installation-manual
- https://github.com/caelestia-dots/shell
