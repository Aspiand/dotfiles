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
    };

    packages = with pkgs; [
      nerdfix
      (nerdfonts.override { fonts = [ "FantasqueSansMono" "0xProto" ]; })

      # Database
      sqlite
      mysql

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

      # System
      android-tools
      clamav
      gnumake
      scrcpy
    ];
  };

  programs.home-manager.enable = true;
  programs.git.extraConfig.core.editor = "code --wait";

  editor.neovim.enable = true;
  editor.vscode.enable = true;

  services.syncthing.enable = true;
}

# file = { # config.lib.file.mkOutOfStoreSymlink };