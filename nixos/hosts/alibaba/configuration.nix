{
  config,
  lib,
  pkgs,
  ...
}:

{
  # System
  system.stateVersion = "26.04";

  zramSwap.memoryMax = 2048;

  boot.kernel.sysctl."vm.swappiness" = lib.mkDefault 10;
  boot.kernel.sysctl."vm.vfs_cache_pressure" = lib.mkDefault 50;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      80
      443
    ];
  };

  # ── Users ──
  users.mutableUsers = false;

  users.users.ali = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDofwi7RvZGROLm/bm99T8xB6Tw9jg442wOi1TFudDwb ao@aira"
    ];
  };

  environment.systemPackages = with pkgs; [
    fresh-editor
    micro
    htop
    curl
    wget
    git
  ];
}
