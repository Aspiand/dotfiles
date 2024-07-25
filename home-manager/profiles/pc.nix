{ config, pkgs, ... }:

{
  imports = [
    ../modules/init.nix

    ../core.nix
    ../../private/home-manager/private.nix
  ];

  # Nix Channel
  # https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  # https://nixos.org/channels/nixpkgs-unstable nixpkgs

  nix.package = pkgs.nix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  shell.bash.enable = true;
  shell.zsh.enable = true;

  home = {
    username = "sinon";
    homeDirectory = "/home/${config.home.username}";
    stateVersion = "24.11";

    shellAliases = {
      hmbs = "home-manager build switch";
      hmg = "home-manager generations";
      rm = "trash-put";
    };

    sessionVariables = {
      TORSOCKS_CONF_FILE = ../tor/torsocks.conf;
    };

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
      proxychains
      speedtest-cli
      tor
      torsocks

      # Programming
      nodejs
      jdk_headless
      jre_headless
      php
      phpPackages.composer
      python3
      python3Packages.pip
      python3Packages.virtualenv
      # python3Packages.face-recognition
      # python3Packages.insightface
      podman-compose

      # Security
      steghide

      # System
      android-tools
      clamav
      gnumake
      scrcpy

      # Other
      ollama
      # media-downloader
    ];
  };

  programs.home-manager.enable = true;
  programs.git.extraConfig.core.editor = "code --wait";

  editor.neovim.enable = true;

  utils = {
    ffm.enable = true;
    fzf.enable = true;
    starship.enable = true;
    ssh.enable = true;
    tmux.enable = true;
    yt-dlp.enable = true;
    yt-dlp.path = "${config.home.homeDirectory}/Downloads/";
    zoxide.enable = true;
  };

  services.syncthing = {
    enable = true;

    tray = {
      enable = true;
    };
  };
}

# file = { # config.lib.file.mkOutOfStoreSymlink };