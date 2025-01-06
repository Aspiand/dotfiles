{ config, pkgs, ... }:

{
  imports = [
    ../modules/init.nix
    ../core.nix
  ];

  # Nix Channel

  # Original
  # https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz home-manager
  # https://github.com/nix-community/nix-on-droid/archive/release-23.11.tar.gz nix-on-droid
  # https://nixos.org/channels/nixos-23.11 nixpkgs

  # Active
  # https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  # https://github.com/nix-community/nix-on-droid/archive/master.tar.gz nix-on-droid
  # https://nixos.org/channels/nixos-unstable nixpkgs

  nix.package = pkgs.nix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  shell.bash.enable = true;

  home = {
    stateVersion = "24.11";
    packages = with pkgs; [
      # Network
      dnsutils
      ngrok
      tor
      torsocks

      # Programming
      nodejs
      jdk_headless
      jre_headless
      php
      phpPackages.composer
      phpExtensions.pdo
      python312
      python312Packages.pip
      python312Packages.virtualenv

      procps
      ncurses
      gnused
      gnugrep
      gawk
      gnumake
      findutils
    ];

    shellAliases = {
      more = "less";
      nodg = "nix-on-droid generations";
      nodr = "nix-on-droid rollback";
      nods = "nix-on-droid build switch";
    };
  };

  programs = {
    home-manager.enable = true;
    git.extraConfig.core.editor = "nvim";

    utils = {
      general = true;
      clamav.enable = true;
      neovim.enable = true;
      yt-dlp.path = "/data/data/com.termux.nix/files/home/storage/Share/YouTube/";
    };
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
    enableZshIntegration = true;
    enableBashIntegration = true;
    pinentryPackage = pkgs.pinentry-tty;
    defaultCacheTtl = 600;
    defaultCacheTtlSsh = 600;
  };
}
