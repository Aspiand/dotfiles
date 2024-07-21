{ config, pkgs, ... }:

{
  imports = [
    ../modules/init.nix
    ../core.nix
  ];

  shell.bash.enable = true;
  shell.zsh.enable = true;

  home = {
    username = "aspian";
    homeDirectory = "/home/${config.home.username}";
    stateVersion = "24.11";

    shellAliases = {
      hmbs = "home-manager build switch";
      hmg = "home-manager generations";
      rm = "trash-put";
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
      speedtest-cli
      tor
      torsocks

      # Programming
      nodejs
      # jdk_headless
      # jre_headless
      php
      phpPackages.composer
      # python3
      # python3Packages.pip
      # python3Packages.virtualenv
      # python3Packages.face-recognition
      # python3Packages.insightface
      podman-compose

      # Security
      steghide

      # System
      clamav
      gnumake
      scrcpy

      # Other
      ollama
    ];
  };

  programs.home-manager.enable = true;
  programs.git.extraConfig.core.editor = "code --wait";

  utils = {
    ffm.enable = true;
    fzf.enable = true;
    neovim.enable = true;
    starship.enable = true;
    ssh.enable = true;
    tmux.enable = true;
    yt-dlp.enable = true;
    yt-dlp.path = "${config.home.homeDirectory}/Downloads/";
    zoxide.enable = true;
  };
}