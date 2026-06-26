{
  config,
  pkgs,
  lib,
  ...
}:

{
  system.stateVersion = "26.05";

  boot.loader = {
    systemd-boot.enable = true;
    timeout = 0;
  };

  networking = {
    hostName = "elasticlabs";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  users = {
    mutableUsers = false;
    users = {
      akira = {
        isNormalUser = true;
        hashedPassword = "$6$s2d3KnSfIdptHL6P$DcNEN52wyIFVn1p1d4ygXsjV.BqujVmU/xjvmRO66kU9nEl8OPF1GwkFtqnsk1mwTcjapBD/tTMPKEsZ1nDwX/";
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDofwi7RvZGROLm/bm99T8xB6Tw9jg442wOi1TFudDwb ao@aira"
        ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    curl
    gitMinimal
    htop
    vim
    wget
  ];
}
