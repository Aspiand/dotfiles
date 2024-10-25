{ config, pkgs, ... }:

{
  imports = [
    ../modules/init.nix
    ../core.nix
  ];

  # Nix Channel
  # https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  # https://nixos.org/channels/nixpkgs-unstable nixpkgs

  nix.package = pkgs.nix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  shell = {
    ohmyposh.enable = false;

    nu.enable = false;
    zsh.enable = false;
    bash.enable = true;
    bash.nix-path = /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh;
  };

  home = {
    username = "aspian";
    homeDirectory = "/var/home/aspian";
    stateVersion = "24.11";

    shellAliases = {
      hmbs = "home-manager build switch";
      hmg = "home-manager generations";
      sql = "PYTHONWARNINGS='ignore' mycli mysql://root:'uh'@localhost/tugas_dbs_aspian";
    };

    sessionVariables = {
      MYCLI_HISTFILE="~/.local/share/mycli/history.txt";
    };

    file = {
      ".myclirc".source = ../../.myclirc;
      ".local/share/applications/obsidian.desktop".text = ''
        [Desktop Entry]
        Categories=Office
        Comment=Knowledge base
        Exec=${config.home.homeDirectory}/.nix-profile/bin/obsidian %u
        Icon=obsidian
        MimeType=x-scheme-handler/obsidian
        Name=Obsidian
        Type=Application
        Version=1.4
      '';
    };

    packages = with pkgs; [
      # Network
      # dnsutils
      # i2pd
      # ipcalc
      # ngrok
      # nmap
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
      # distrobox
      duf
      # glow
      # gnumake
      # mkp224o
      obsidian
      # qemu
      # scrcpy
      # wavemon
      # zenith
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
      clamav.enable = false;
      librewolf.enable = false;
      neovim.enable = true;
      pass.enable = true;
      tmux.enable = true;
      tmux.shell = "${pkgs.bash}/bin/bash";
      vscode.enable = true;
      yt-dlp.downloader = "aria2c";
    };
  };
}