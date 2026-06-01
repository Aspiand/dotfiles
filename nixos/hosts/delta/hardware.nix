{ config, lib, pkgs, ... }:

{
  # Oracle Cloud ARM VM
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.device = "nodev";

  # Network
  networking.hostName = "delta";

  # Kernel modules for Oracle Cloud
  boot.kernelModules = [ "virtio_net" "virtio_blk" "virtio_pci" ];

  # Enable cloud-init
  services.cloud-init = {
    enable = true;
  };
}
