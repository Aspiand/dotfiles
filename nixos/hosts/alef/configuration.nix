{ config, lib, pkgs, ... }:

{
  system.stateVersion = "26.05";

  networking = {
    hostName = "alef";
    useDHCP = true;
    interfaces.eth0.useDHCP = true;
    interfaces.wlan0.useDHCP = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = lib.mkDefault 10;
    "vm.vfs_cache_pressure" = lib.mkDefault 50;
  };

  users.mutableUsers = false;
  users.users.root.initialPassword = "root";
  users.users.yoru = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDofwi7RvZGROLm/bm99T8xB6Tw9jg442wOi1TFudDwb ao@aira"
    ];
  };

  environment.systemPackages = with pkgs; [
    # micro
    # htop
    # curl
    # wget
    # git
    # btrfs-progs
  ];
}
