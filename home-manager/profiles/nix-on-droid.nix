{ config, pkgs, ... }:

{
  imports = [ ./core.nix ];

  # Nix Channel

  # Original
  # https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz home-manager
  # https://github.com/nix-community/nix-on-droid/archive/release-23.11.tar.gz nix-on-droid
  # https://nixos.org/channels/nixos-23.11 nixpkgs

  # Active
  # https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  # https://github.com/nix-community/nix-on-droid/archive/master.tar.gz nix-on-droid
  # https://nixos.org/channels/nixos-unstable nixpkgs

  nixpkgs.config.allowUnfree = true;
  shell.bash.enable = true;
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  home = {
    stateVersion = "24.11";
    packages = with pkgs; [
      php
      phpPackages.composer
      python312

      procps
      ncurses
      gnused
      gnugrep
      gawk
      gnumake
      findutils
      which
    ];

    shellAliases = {
      more = "less";
      nodg = "nix-on-droid generations";
      nodr = "nix-on-droid rollback";
      nods = "nix-on-droid build switch";
    };
  };

  programs = {
    clamav.enable = true;
    gpg.enable = true;
    yt-dlp.enable = true;
    yt-dlp.path = "/data/data/com.termux.nix/files/home/storage/Share/YouTube/";
  };

  services.sshd = {
    enable = true;
    port = 3022;
    addressFamily = "inet";
    dir = "${config.home.homeDirectory}/.ssh";
  };

  services.gpg-agent = {
    enable = false;
    enableSshSupport = true;
    enableBashIntegration = true;
    pinentryPackage = pkgs.pinentry-tty;
    defaultCacheTtl = 600;
    defaultCacheTtlSsh = 600;
  };
}
