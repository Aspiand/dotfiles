{ config, pkgs, ... }:

{
  system.stateVersion = "26.05";

  boot.loader = {
    systemd-boot.enable = true;
    tmp.cleanOnBoot = true;
    timeout = 0;
  };

  networking = {
    hostName = "nova";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  users = {
    mutableUsers = false;
    users.akira = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "docker"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDofwi7RvZGROLm/bm99T8xB6Tw9jg442wOi1TFudDwb ao@aira"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    btrfs-progs
    compsize
    curl
    git
    htop
    micro
    wget
  ];

  virtualisation.docker.enable = true;

  services = {
    tailscale.enable = false;
  };
}
