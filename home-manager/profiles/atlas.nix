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
      db = "distrobox";
    };

    packages = with pkgs; [
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

      # Utils
      android-tools
      distrobox
      gnumake
      scrcpy
      wine
    ];
  };

  programs.ssh.control = true;
  programs = {
    home-manager.enable = true;
    git.extraConfig.core.editor = "codium --wait";
    gpg.package = pkgs.gnupg22;
    utils = {
      enable = true;
      additional = true;
      clamav.enable = false;
      gnupg.enable = false;
      pass.enable = true;
      pass.dir = "${config.home.homeDirectory}/.local/share/password_store";
      tmux.enable = true;
      yt-dlp.downloader = "aria2c";
    };

    librewolf = {
      enable = true;
      settings = {
        "browser.safebrowsing.malware.enabled" = true;
        "browser.safebrowsing.phishing.enabled" = true;
        "browser.safebrowsing.blockedURIs.enabled" = true;
        "browser.safebrowsing.downloads.enabled" = true;
        "browser.sessionstore.resume_from_crash" = true;

        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.downloads" = false;
        "privacy.resistFingerprinting" = true;
        "privacy.resistFingerprinting.letterboxing" = true;

        "identity.fxaccounts.enabled" = false;

        "security.OCSP.require" = true;
      };
    };
  };

  editor.neovim.enable = true;
  editor.vscode.enable = true;
  services.syncthing.enable = true;
}

# file = { # config.lib.file.mkOutOfStoreSymlink };
