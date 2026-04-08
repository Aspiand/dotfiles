{ ... }:

{
  imports = [
    ./modules/base/core.nix
    ./modules/base/networking.nix
    ./modules/ops/backup-restic.nix
    ./modules/storage/boot-efi.nix
    ./modules/storage/persistence.nix
    ./modules/storage/swap.nix
    ./profiles/portable-safe.nix
    ./profiles/desktop-hyprland.nix
    ./profiles/desktop-caelestia.nix
    ./profiles/recovery.nix
  ];

  azel.backup.restic = {
    enable = false;
    repository = null;
  };
}
