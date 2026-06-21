{ config, lib, pkgs, ... }:

{
  nixpkgs.hostPlatform = "aarch64-linux";

  # ── Bootloader: extlinux ──
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # ── Kernel modules ──
  boot.kernelModules = [ "meson-gxl" ];
  boot.initrd.availableKernelModules = [
    "usb_storage"
    "sd_mod"
    "uas"
    "usbhid"
  ];

  # ── Console ──
  boot.kernelParams = [
    "console=ttyAML0,115200n8"
    "console=tty0"
    "net.ifnames=0"
    "no_console_suspend"
  ];

  # ── DTB ──
  hardware.deviceTree = {
    enable = true;
    filter = "meson-gxl-s905x-p212.dtb";
  };

  hardware.enableRedistributableFirmware = true;
}
