{
  config,
  lib,
  pkgs,
  ...
}:
{
  disko.devices = {
    disk = {
      vda = {
        device = "/dev/vda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "256M";
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
                mountpoint = "/";
                subvolumes = {
                  "@" = {
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
            swap = {
              size = "1G";
              type = "8200";
              content = {
                type = "swap";
              };
            };
          };
        };
      };
    };
  };
}
