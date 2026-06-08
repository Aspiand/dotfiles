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

  boot.kernel.sysctl."vm.swappiness" = mkDefault 10;
  boot.kernel.sysctl."vm.vfs_cache_pressure" = mkDefault 50;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      80
      443
    ];
  };

  # ── Users ──
  users.mutableUsers = false;    # NixOS fully manages user state; no stray
                                 # `/etc/shadow` edits from cloud-init or manual
                                 # `passwd`. Authorized SSH keys go via
                                 # `users.users.<name>.openssh.authorizedKeys.keys`
                                 # (or cloud-init's first-boot provisioning).

  users.users.delta = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
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
