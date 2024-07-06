{ config, pkgs, ... }:

{
  imports = [
    ./modules

    ./app/core.nix
    ./app/other.nix
    ./app/shell/starship.nix
    ../../files.private/home-manager/private.nix
  ];

  home = {
    username = "sinon";
    homeDirectory = "/home/${config.home.username}";
    stateVersion = "24.11";

    shellAliases = {
      hmbs = "home-manager build switch";
    };

    # file = { # config.lib.file.mkOutOfStoreSymlink };

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

      # Database
      sqlite

      # Files
      bat
      ffmpeg

      # Monitor
      bottom
      # gotop
      # iftop
      # iotop
      # nyx

      # Network
      aria2
      dnsutils
      ngrok
      nmap
      onioncircuits
      onionshare
      proxychains
      speedtest-cli
      tor

      # Programming
      nodejs
      jdk_headless
      jre_headless
      php
      phpPackages.composer
      python312
      # python312Packages.face-recognition
      # python312Packages.insightface
      python312Packages.pip
      python312Packages.virtualenv
      podman-compose

      # Security
      # gnupg
      # pass
      steghide

      # System
      android-tools
      clamav
      gnumake
      scrcpy
      usbutils
      xorg.xrandr

      # Other
      ollama
      # media-downloader
    ];
  };

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;
  programs.git.extraConfig.core.editor = "code --wait";

  shell = {
    bash.enable = true;
    zsh.enable = true;
  };

  utils = {
    tmux.enable = true;
    neovim.enable = true;
  };
}