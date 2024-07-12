{ config, pkgs, ... }:

{
  imports = [
    ./../../home-manager/modules/init.nix
    ./../../home-manager/core.nix

    ./core.nix
  ];

  # Nix Channel

  # Original
  # https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz home-manager
  # https://github.com/nix-community/nix-on-droid/archive/release-23.11.tar.gz nix-on-droid
  # https://nixos.org/channels/nixos-23.11 nixpkgs

  # https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  # https://github.com/nix-community/nix-on-droid/archive/master.tar.gz nix-on-droid
  # https://nixos.org/channels/nixos-unstable nixpkgs

  # Active
  # https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
  # https://github.com/nix-community/nix-on-droid/archive/release-24.05.tar.gz nix-on-droid
  # https://nixos.org/channels/nixos-24.05-small nixpkgs

  home = {
    stateVersion = "24.05";
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
      torsocks

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
      pass
      steghide

      # System
      clamav
      gnumake
      procps
      # proot

      # Other
      ollama
    ];

    file = {
      ".config/ffm/config.sh".source = ../ffm/config.sh;
      ".config/nixpkgs/config.nix".source = ../nixpkgs/config.nix;

      ".gnupg/gpg-agent.conf".source = ../gnupg/gpg-agent.conf;

      ".local/share/clamav/clamd.conf".source = ../clamav/clamd.conf;
      ".local/share/clamav/freshclam.conf".source = ../clamav/freshclam.conf;

      ".ssh/banner".source = ../ssh/banner;
      ".ssh/sshd_config".source = ../ssh/sshd_config;
    };

    shellAliases = {
      tp = "trash-put";
      nods = "nix-on-droid build switch";
      sshd = "$(which sshd) -4f ~/.ssh/sshd_config";
      clamd = "clamd --config-file ~/.local/share/clamav/clamd.conf";
      clamscan = "clamscan --database ~/.local/share/clamav/database/";
      freshclam = "freshclam --config-file ~/.local/share/clamav/freshclam.conf";
    };
  };

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  programs.home-manager.enable = true;

  shell.bash.enable = true;

  utils = {
    ffm.enable = true;
    neovim.enable = true;
    starship.enable = true;
    yt-dlp.enable = true;
    yt-dlp.path = "/data/data/com.termux.nix/files/home/storage/Share/YouTube/";
  };
}