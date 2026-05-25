{ config, lib, pkgs, ... }:
{
  disko.devices = {
    disk = {
      device = "/dev/vda";
      type = "gpt";
      partitions = {
        boot = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        root = {
          size = "rest-inodes";
          type = "8300";
          content = {
            type = "btrfs";
            mountpoint = "/";
            subvolumes = {
              "@" = {
                mountpoint = "/";
              };
              "@home" = {
                mountpoint = "/home";
              };
              "@persist" = {
                mountpoint = "/persist";
              };
            };
          };
        };
        swap = {
          size = "4G";
          type = "8200";
          content = {
            type = "swap";
          };
        };
      };
    };
  };
}
