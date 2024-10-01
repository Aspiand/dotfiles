{ config, pkgs, ... }:

{
  imports = [
    ../modules/init.nix
    ../core.nix
  ];

  shell.starship.enable = true;
  shell.bash.enable = true;
  shell.zsh.enable = true;

  home = {
    username = "aspian";
    homeDirectory = "/home/${config.home.username}";
    stateVersion = "24.11";

    shellAliases = {
      code = "codium";
      hmbs = "home-manager build switch";
      hmg = "home-manager generations";
      rm = "trash-put";
      rmas = "rm ~/.var/app/com.google.AndroidStudio/config/Google/AndroidStudio2024.1/.lock";
    };

    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FantasqueSansMono" "0xProto" ]; })

      # Database
      sqlite
      mysql

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
      jdk_headless
      jre_headless
      php
      phpPackages.composer
      # python3
      # python3Packages.pip
      # python3Packages.virtualenv
      # python3Packages.face-recognition
      # python3Packages.insightface
      podman-compose

      # System
      gnumake
      scrcpy
      ollama
    ];
  };

  programs.home-manager.enable = true;
  programs.git.extraConfig.core.editor = "code --wait";
  programs.ssh.control = true;

  programs = {
    utils = {
      enable = true;
      additional = true;
      gnupg.enable = true;
      pass.enable = true;
      tmux.enable = true;
      yt-dlp.downloader = "aria2c";
    };
  };

  editor.neovim.enable = true;
  editor.vscode.enable = true;

  services = {
    syncthing.enable = true;
    sshd.enable = true;
    sshd.dir = "${config.home.homeDirectory}/.ssh";
  };
}