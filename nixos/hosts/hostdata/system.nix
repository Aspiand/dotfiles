{ pkgs, ... }:

{
  nixpkgs.hostPlatform = "x86_64-linux";

  # ── Nix settings ──
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://cache.nixos.org"
      "https://nix.aspian.my.id"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "github-ci-2:eUvIhhjHCO/kJVGcFNd/sNCGSx59tj1QAXmb477OO00="
    ];
  };

  # ── Packages ──
  environment.systemPackages = with pkgs; [
    micro
    htop
    curl
    wget
    git
    jq
  ];

  # ── SSH ──
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
      AllowGroups = [ "wheel" ];
      UseDns = false;
      UsePAM = true;
      X11Forwarding = false;
      PrintMotd = false;
      LogLevel = "VERBOSE";
      MaxAuthTries = 3;
      MaxSessions = 10;
      LoginGraceTime = 60;
    };
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };

  # ── Users ──
  users.users.hdu = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDofwi7RvZGROLm/bm99T8xB6Tw9jg442wOi1TFudDwb ao@aira"
    ];
  };

  users.mutableUsers = false;
}
