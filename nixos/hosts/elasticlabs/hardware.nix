{
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
  ];

  boot.loader.grub.devices = [ "/dev/sda" ];
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ ];

  fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
}
