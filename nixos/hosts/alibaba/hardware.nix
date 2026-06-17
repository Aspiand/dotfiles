{ config, lib, pkgs, ... }:

{
  # Alibaba Cloud ECS
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.device = "nodev";

  # Network
  networking.hostName = "alibaba";

  # Kernel modules for Alibaba Cloud
  boot.kernelModules = [ "virtio_net" "virtio_blk" "virtio_pci" ];

  # Enable cloud-init
  services.cloud-init = {
    enable = true;
  };
}
