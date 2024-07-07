{ config, pkgs, ... }:

{
  imports = [
    ./../../home-manager/modules/init.nix
    ./../../home-manager/core.nix

    ./core.nix
  ];

  home = {
    stateVersion = "24.11";
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FantasqueSansMono" "0xProto" ]; })

      # Archive
      bzip2
      bzip3
      gzip
      unrar
      unzip
      gnutar
      xz
      zip
      zstd

      # Files
      bat
      ffmpeg

      # Monitor
      nyx

      # Network
      aria2
      dnsutils
      ngrok
      nmap
      proxychains
      speedtest-cli
      tor

      # Programming
      nodejs
      # jdk_headless
      # jre_headless
      php
      phpPackages.composer
      python312
      python312Packages.pip
      python312Packages.virtualenv

      # Security
      gnupg
      pass
      steghide

      # System
      clamav
      gnumake
      procps
      # proot

      # Other
      ollama
    ];

    file = {
      ".config/nixpkgs/config.nix".source = ../nixpkgs/config.nix;

      ".nix-channels".text = ''
        # https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz home-manager
        # https://github.com/nix-community/nix-on-droid/archive/release-23.11.tar.gz nix-on-droid
        # https://nixos.org/channels/nixos-23.11 nixpkgs

        https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
        https://github.com/nix-community/nix-on-droid/archive/master.tar.gz nix-on-droid
        https://nixos.org/channels/nixos-unstable nixpkgs
      '';

      ".ssh/sshd_config".source = ../ssh/sshd_config;
    };

    shellAliases = {
      cat = "bat";
      nods = "nix-on-droid build switch";
      sshd = "$(which sshd) -f ~/.ssh/sshd_config";
    };
  };

  programs.home-manager.enable = true;

  shell.bash.enable = true;
  shell.variable = {
    SYMLINKS = [
      "/storage/emulated/0 /data/data/com.termux.nix/files/home/storage"
    ];
  };

  utils = {
    ffm.enable = true;
    neovim.enable = true;
    starship.enable = true;
    yt-dlp = {
      enable = true;
      path = "${config.home.homeDirectory}/Downloads/";
    };
  };
}