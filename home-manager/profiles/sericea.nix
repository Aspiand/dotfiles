{ config, pkgs, ... }:

{
  imports = [ ../default.nix ];

  fonts.fontconfig.enable = true;
  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  home = {
    # username = "";
    homeDirectory = "/home/${config.home.username}";
    stateVersion = "25.05";

    shellAliases = {
      hmbs = "home-manager build switch --flake ~/.config/dofiles/home-manager#sericea";
      hmg = "home-manager generations";
    };

    packages = with pkgs; [
      nerd-fonts._0xproto
      nerd-fonts.caskaydia-cove

      # Desktop
      # authenticator
      bitwarden-desktop
      # dbeaver-bin
      discord
      # firefox
      # libreoffice
      # obs-studio
      # planify
      # pika-backup
      # postman
      spotify
      # tor-browser

      # CLI
      android-tools
      # bitwarden-cli
      borgbackup
      bottom
      cava
      distrobox
      duf
      fastfetch
      # ffmpeg
      gocryptfs
      htop
      hugo
      nix-tree
      nmap
      podman-compose
      # steam-run
      # umu-launcher
      # winePackages.wayland

      # Editor
      android-studio
      # arduino-ide
      netbeans
      obsidian
      vscode

      # Gaming
      # rpcs3
      # gpu-viewer
      # mangohud
      # lutris
      # vulkan-tools

      # ventoy-full # https://github.com/NixOS/nixpkgs/issues/404663

      # Programming
      gcc
      go
      maven
      php84
      php84Packages.composer
      nodejs
      jdk
      nixfmt-rfc-style # nix formatter
      (python3.withPackages (
        ps: with ps; [
          pip
          virtualenv
        ]
      ))
    ];
  };

  programs = {
    home-manager.enable = true;
    bash.enable = true;
    clamav.enable = true;
    gpg.enable = true;
    mycli.enable = true;
    ssh.control = true;
    tmux.enable = true;
    yt-dlp.enable = true;
    yt-dlp.downloader = "aria2c";
    yt-dlp.path = "${config.home.homeDirectory}/Videos/YouTube";
    git.extraConfig.core.editor = "${pkgs.vscode}/bin/code --wait";
  };

  services = {
    home-manager.autoExpire = {
      enable = true;
      frequency = "weekly";
      store.cleanup = true;
    };
  };
}
