{ config, pkgs, ... }:

{
  imports = [
    ../modules/init.nix
    ../core.nix
  ];

  nixpkgs.config.allowUnfree = true;

  shell = {
    bash.enable = true;
    nix-path = /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh;
  };

  home = {
    username = "aspian";
    homeDirectory = "/var/home/aspian";
    stateVersion = "24.11";

    shellAliases = {
      hmbs = "home-manager build switch";
      hmg = "home-manager generations";
      sql = "PYTHONWARNINGS='ignore' mycli mysql://root:'uh'@localhost/";
    };

    sessionVariables = {
      MYCLI_HISTFILE="~/.local/share/mycli/history.txt";
    };

    file.".myclirc".source = ../../.myclirc;

    packages = with pkgs; [
      pkgs.gnome-tweaks

      # Network
      # ngrok
      nmap
      # tor
      # torsocks

      # Programming
      nodejs
      jdk_headless
      jre_headless
      php
      phpPackages.composer
      phpExtensions.pdo
      phpExtensions.sqlite3
      phpExtensions.pdo_mysql
      phpExtensions.pdo_sqlite
      python3
      python3Packages.pip
      python3Packages.virtualenv

      # Utils
      # android-tools
      # caddy
      duf
      mycli
      ollama
      # qemu
    ];
  };

  programs = {
    ssh.control = true;
    home-manager.enable = true;
    git.extraConfig.core.editor = "nvim";
    git.extraConfig.delta = {
      hyperlinks = true;
      hyperlinks-file-link-format = "vscode://file/{path}:{line}";
    };

    utils = {
      general = true;
      neovim.enable = true;
      pass.enable = true;
      tmux.enable = true;
      tmux.shell = "${pkgs.bash}/bin/bash";
      yt-dlp.downloader = "aria2c";
    };
  };
}