{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "usb_storage"
    "nvme"
  ];

  boot.kernelModules = [ "kvm-intel" ];

  hardware.enableRedistributableFirmware = lib.mkDefault true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
