{ ... }:

{
  boot = {
    loader = {
      grub.enable = false;
      systemd-boot.enable = true;

      efi = {
        canTouchEfiVariables = false;
        efiSysMountPoint = "/boot";
      };
    };

    tmp.useTmpfs = false;
    supportedFilesystems = [ "btrfs" ];
  };
}
