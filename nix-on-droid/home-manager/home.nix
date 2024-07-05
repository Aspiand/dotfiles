{ config, pkgs, ... }:

{
  imports = [
    ./../../home-manager/app/core.nix
    ./../../home-manager/app/other.nix
    ./../../home-manager/app/shell/bash.nix
    ./../../home-manager/app/shell/starship.nix
    ./../../home-manager/app/editor/neovim.nix

    ./reconfigure.nix
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

      # Database
      sqlite

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
      gawk
      gnumake
      gnused
      procps
      which

      # Other
      ncurses
      ollama
    ];

    file = {
      ".config/nixpkgs/config.nix".text = "{ allowUnfree = true; }";

      ".nix-channels".text = ''
        # https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz home-manager
        # https://github.com/nix-community/nix-on-droid/archive/release-23.11.tar.gz nix-on-droid
        # https://nixos.org/channels/nixos-23.11 nixpkgs

        https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
        https://github.com/nix-community/nix-on-droid/archive/master.tar.gz nix-on-droid
        https://nixos.org/channels/nixos-unstable nixpkgs
      '';

      ".ssh/sshd_config".text = ''
        Port 3022
        PrintMotd yes
        PasswordAuthentication no
        HostKey /data/data/com.termux.nix/files/home/.ssh/ssh_host_rsa_key
      '';
    };
  };

  programs.home-manager.enable = true;

  # lib.mkForce
}
