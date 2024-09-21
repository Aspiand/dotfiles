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

  shell.starship.enable = true;
  shell.bash.enable = true;
  shell.zsh.enable = true;

  home = {
    username = "aspian";
    homeDirectory = "/home/${config.home.username}";
    stateVersion = "24.11";

    shellAliases = {
      hmbs = "home-manager build switch";
      hmg = "home-manager generations";
      sql = "PYTHONWARNINGS='ignore' mycli mysql://root:'uh'@localhost";
    };

    sessionVariables = {
      MYCLI_HISTFILE="~/.local/share/mycli/history.txt";
    };

    file = {
      ".myclirc".source = ../../.myclirc;
    };

    packages = with pkgs; [
      # Network
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
      phpExtensions.pdo
      phpExtensions.sqlite3
      phpExtensions.pdo_mysql
      phpExtensions.pdo_sqlite
      python3
      python3Packages.pip
      python3Packages.virtualenv
      # python3Packages.face-recognition
      # python3Packages.insightface

      # Utils
      android-tools
      distrobox
      glow
      gnumake
      litecli
      mkp224o
      mycli
      podman-compose
      qemu
      scrcpy
      sqlite
    ];
  };

  programs = {
    ssh.control = true;
    home-manager.enable = true;
    gpg.package = pkgs.gnupg22;
    git.extraConfig.core.editor = "nvim";

    utils = {
      additional = true;
      clamav.enable = true;
      librewolf.enable = true;
      neovim.enable = true;
      pass.enable = true;
      tmux.enable = true;
      vscode.enable = true;
      yt-dlp.downloader = "aria2c";
    };

    yambar.enable = false;
    yambar.settings.bar = {
      location = "top";
      height = 26;
      background = "00000066";
      right = [
        {
          clock.content = [
            { string.text = "{time}"; }
          ];
        }
      ];
    };
  };

  services.syncthing.enable = false;
  services.glance.enable = false;
  # xfconf.settings
}

# file = { # config.lib.file.mkOutOfStoreSymlink };