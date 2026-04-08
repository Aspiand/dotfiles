{ ... }:

{
  imports = [
    ./modules/base/core.nix
    ./modules/base/networking.nix
    ./modules/storage/boot-efi.nix
    ./modules/storage/persistence.nix
    ./modules/storage/swap.nix
    ./profiles/portable-safe.nix
    ./profiles/desktop-hyprland.nix
    ./profiles/desktop-caelestia.nix
    ./profiles/recovery.nix
  ];
}
