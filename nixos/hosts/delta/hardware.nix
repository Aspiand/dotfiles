{ config, lib, pkgs, ... }:

{
  # Oracle Cloud ARM VM
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.device = "nodev";

  # File systems
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ROOT_UUID";
    fsType = "btrfs";
    options = [ "defaults" "noatime" "compress=zstd" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/BOOT_UUID";
    fsType = "vfat";
  };

  # Swap
  swapDevices = [
    { device = "/dev/disk/by-uuid/SWAP_UUID"; }
  ];

  # Network
  networking.hostName = "delta";

  # Kernel modules for Oracle Cloud
  boot.kernelModules = [ "virtio_net" "virtio_blk" "virtio_pci" ];

  # Enable cloud-init
  services.cloud-init = {
    enable = true;
  };
}
