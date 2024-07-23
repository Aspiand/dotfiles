{ config, pkgs, ... }:

{
  imports = [
    ../modules/init.nix
    ../core.nix
  ];

  # Nix Channel

  # Original
  # https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz home-manager
  # https://github.com/nix-community/nix-on-droid/archive/release-23.11.tar.gz nix-on-droid
  # https://nixos.org/channels/nixos-23.11 nixpkgs

  # Active
  # https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  # https://github.com/nix-community/nix-on-droid/archive/master.tar.gz nix-on-droid
  # https://nixos.org/channels/nixos-unstable nixpkgs

  nix.package = pkgs.nix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.home-manager.enable = true;

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
      gnupg
      steghide

      # Utils
      bat
      clamav
      findutils
      ffmpeg
      gnumake
      gawk
      gnugrep
      gnused
      ncurses
      pinentry-tty
      procps
      which

      # Other
      ollama
    ];

    file = {
      ".config/nixpkgs/config.nix".text = "{ allowUnfree = true; }";

      ".local/data/gnupg/gpg-agent.conf".source = ../../nix-on-droid/gnupg/gpg-agent.conf;

      ".local/share/clamav/clamd.conf".source = ../../nix-on-droid/clamav/clamd.conf;
      ".local/share/clamav/freshclam.conf".source = ../../nix-on-droid/clamav/freshclam.conf;

      ".ssh/banner".source = ../../nix-on-droid/ssh/banner;
      ".ssh/sshd_config".source = ../../nix-on-droid/ssh/sshd_config;
    };

    shellAliases = {
      tp = "trash-put";
      more = "less";
      nodg = "nix-on-droid generations";
      nodr = "nix-on-droid rollback";
      nods = "nix-on-droid build switch";
      sshd = "$(which sshd) -4f ~/.ssh/sshd_config";
      clamd = "clamd --config-file ~/.local/share/clamav/clamd.conf";
      clamscan = "clamscan --database ~/.local/share/clamav/database/";
      freshclam = "freshclam --config-file ~/.local/share/clamav/freshclam.conf";
    };
  };

  programs = {
    gpg = {
      enable = true;
      homedir = "${config.home.homeDirectory}/.local/data/gnupg";
    };

    password-store = {
      enable = true;
      settings = {
        PASSWORD_STORE_CLIP_TIME = "120";
        PASSWORD_STORE_GENERATED_LENGTH = "30";
        PASSWORD_STORE_DIR = "$HOME/.local/data/password_store/";
      };
    };
  };

  shell.bash.enable = true;
  editor.neovim.enable = true;
  utils = {
    ffm.enable = true;
    starship.enable = true;
    ssh.enable = true;
    ssh.control = false;
    yt-dlp.enable = true;
    yt-dlp.path = "/data/data/com.termux.nix/files/home/storage/Share/YouTube/";
  };
}