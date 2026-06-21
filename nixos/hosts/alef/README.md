# alef — NixOS for Amlogic S905X (P212 TV Box)

## Layout (/dev/sda)

| Offset   | Size   | Purpose                 |
|----------|--------|-------------------------|
| 0–1M     | 1M     | GPT header              |
| 1M–8M    | 7M     | **U-Boot gap**          |
| 8M–520M  | 512M   | `/boot` (vfat)          |
| 520M–…   | rest   | btrfs → @root @nix @var |

## Install

### 1. Format + mount
```bash
sudo nix run github:nix-community/disko -- --mode destroy,format,mount ./nixos/hosts/alef/disko.nix
```

### 2. Flash U-Boot (required after disko)
```bash
sudo dd if=./nixos/hosts/alef/files/u-boot.ext of=/dev/sda bs=1 seek=1 conv=fsync
```

### 3. Install
```bash
sudo nixos-install --flake ".#alef" --root /mnt
```

### 4. Boot
- Plug USB flash into TV Box
- U-Boot in eMMC should scan USB automatically
- Serial console: `115200 8n1`

## Using nixos-anywhere (recommended)
```bash
nixos-anywhere --flake ".#alef" root@<ip> \
  --extra-files ./nixos/hosts/alef/files/ \
  --post-install-command "dd if=/mnt/boot/u-boot.ext of=/dev/sda bs=1 seek=1 conv=fsync"
```

## Files
- `files/u-boot.ext` — U-Boot binary for S905X (copy from `/boot/u-boot.ext` on Armbian)
