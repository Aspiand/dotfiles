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
      sql = "PYTHONWARNINGS='ignore' MYCLI_HISTFILE='~/.local/share/mycli/history.txt' mycli mysql://root:'uh'@localhost";
    };

    # sessionVariables.MYCLI_HISTFILE="~/.local/share/mycli/history.txt";

    file.".myclirc".source = ../../.myclirc;

    packages = with pkgs; [
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
      php82Extensions.pdo
      php82Extensions.sqlite3
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
      gnupg.enable = false;
      librewolf.enable = true;
      neovim.enable = true;
      pass.enable = true;
      pass.dir = "${config.home.homeDirectory}/.local/share/password_store";
      tmux.enable = true;
      vscode.enable = true;
      yt-dlp.downloader = "aria2c";
    };
  };

  services.syncthing.enable = false;
  services.glance.enable = false;
  # xfconf.settings
}

# file = { # config.lib.file.mkOutOfStoreSymlink };
