{
  config,
  lib,
  pkgs,
  ...
}:
{
  disko.devices = {
    disk = {
      sda = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              start = "8M";  # gap for U-Boot (written manually via dd)
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              type = "8300";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@root" = {
                    mountpoint = "/";
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@var" = {
                    mountpoint = "/var";
                    mountOptions = [ "compress=zstd" ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
