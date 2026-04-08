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
sudo nix run .#rebuild
```

### 1. Enter the host directory

```bash
cd nixos/hosts/azel
```

### 2. Identify the portable SSD

```bash
lsblk -o NAME,SIZE,MODEL,FSTYPE,MOUNTPOINTS
ls -l /dev/disk/by-id
```

Then edit [`disko.nix`](./disko.nix) and replace:

```nix
device = "/dev/disk/by-id/CHANGE-ME";
```

Use the portable SSD `by-id` path, not `/dev/sdX`, unless you have no stable alternative.

### 3. Review the defaults you care about

Files to check before install:

- [`modules/base/core.nix`](./modules/base/core.nix)
- [`modules/base/networking.nix`](./modules/base/networking.nix)
- [`home/base.nix`](./home/base.nix)
- [`configuration.nix`](./configuration.nix)

Important defaults right now:

- username: `aka`
- initial password: `nixos`
- hostname: `azel`

### 4. Partition, encrypt, format, and mount the SSD

This destroys the target portable SSD.

```bash
sudo nix run .#format
```

After this finishes, the new system tree should be mounted under `/mnt`.

### 5. Generate hardware configuration for the target machine

```bash
tmpdir="$(mktemp -d)"
sudo nixos-generate-config --root /mnt --dir "$tmpdir"
cp "$tmpdir/hardware-configuration.nix" ./hardware-configuration.nix
rm -rf "$tmpdir"
```

Then open [`hardware-configuration.nix`](./hardware-configuration.nix) and remove:

- `fileSystems`
- `swapDevices`

Those are already handled by [`disko.nix`](./disko.nix).

### 6. Install `azel`

```bash
sudo nix run .#install
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
cd nixos/hosts/azel
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
sudo nix run .#install
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
sudo nix run .#rebuild
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

The `azel` flake provides several operational helpers to manage the system from a host OS. All apps require `sudo`.

| Command | Description | Flags |
| :--- | :--- | :--- |
| `nix run .#mount` | Mounts `azel` partitions to `/mnt`. | `--with-swap` |
| `nix run .#umount` | Unmounts everything from `/mnt` and closes LUKS. | - |
| `nix run .#build` | Builds the system closure (results in `./result`). | - |
| `nix run .#format` | Partitions and formats disks via Disko (**Destructive**). | `-y`, `--yes` |
| `nix run .#install` | Performs a full `nixos-install`. | `--format`, `--no-build`, `-y` |
| `nix run .#rebuild` | Full offline update: Mount -> Build -> Activate. | `-y`, `--yes` |

---

## Installation

This is the fastest path to install `azel` onto a portable drive.

1. **Identify the Target Disk:** Find your drive's `by-id` path and update `disko.nix`.
2. **One-Step Install:**

   ```bash
   sudo nix run .#install -- --format
   ```

   *Note: This will prompt for confirmation before wiping the disk.*

---

## Offline Rebuild Workflow

Use this when you are booted into your internal OS and want to update the external `azel` drive.

1. **Automatic Rebuild:**

   ```bash
   sudo nix run .#rebuild
   ```

   This handles mounting, building, and bootloader updates in one go.

2. **Manual Granular Path:**
   If you prefer to check the build first:

   ```bash
   nix run .#build
   sudo nix run .#install -- --no-build
   ```

3. **Cleanup:**

   ```bash
   sudo nix run .#umount
   ```

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

The actual declarative partition layout remains in [`disko.nix`](./disko.nix).

### `modules/ops/*`

These files hold operational capabilities that are useful after the machine is already alive:

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

### `profiles/desktop-caelestia.nix`

This is the higher-level UX layer:

- Caelestia support fonts
- Wayland-oriented session variables

Actual Home Manager Caelestia enablement lives in [`home/caelestia.nix`](./home/caelestia.nix).

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

[`disko.nix`](./disko.nix) defines:

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

Edit [`disko.nix`](./disko.nix):

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

- [`modules/base/core.nix`](./modules/base/core.nix)
- [`home/base.nix`](./home/base.nix)
- [`flake.nix`](./flake.nix)

Current defaults:

- username: `aka`
- initial password: `nixos`
- hostname: `azel`
- timezone: `Asia/Makassar`
- Tailscale service: enabled

## External-drive installation from a running NixOS machine

Assumptions:

- this repo is available locally
- installation is being performed from another running NixOS system
- the target is an external drive
- you want UEFI boot only

### 1. Enter the host directory

```bash
cd nixos/hosts/azel
```

### 2. Identify the correct target disk

```bash
lsblk -o NAME,SIZE,MODEL,FSTYPE,MOUNTPOINTS
ls -l /dev/disk/by-id
```

Then edit [`disko.nix`](./disko.nix).

### 3. Partition, format, encrypt, and mount with `disko`

This destroys the target drive.

```bash
sudo nix run .#format
```

After this, the target filesystem tree should be mounted under `/mnt`.

### 4. Generate hardware configuration for the actual target machine

The checked-in [`hardware-configuration.nix`](./hardware-configuration.nix) is intentionally generic.

Generate a fresh one:

```bash
tmpdir="$(mktemp -d)"
sudo nixos-generate-config --root /mnt --dir "$tmpdir"
cp "$tmpdir/hardware-configuration.nix" ./hardware-configuration.nix
rm -rf "$tmpdir"
```

Then review the generated file and remove `fileSystems` and `swapDevices`, because those are already managed by [`disko.nix`](./disko.nix).

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
sudo nix run .#install
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
- hardware portability follow-up work is tracked in [`TODO.md`](./TODO.md)

## References

- https://wiki.nixos.org/wiki/Btrfs
- https://nixos.org/manual/nixos/stable/#sec-installation-manual
- https://github.com/caelestia-dots/shell
