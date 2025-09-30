{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [ ../home-manager/default.nix ];

  home = {
    username = "ao";
    homeDirectory = "/home/ao";
    stateVersion = "25.05";

    shellAliases = {
      switch = "sudo nixos-rebuild switch --verbose --flake ~/.config/dotfiles/nixos";
      ehe = "fastfetch";
    };

    sessionVariables = {
      GOPATH = "${config.xdg.dataHome}/go";
    };

    packages =
      with pkgs;
      [
        # Desktop
        # authenticator
        bitwarden-desktop
        # dbeaver-bin
        discord
        firefox
        # gnome-extension-manager
        # heroic
        # kdePackages.kdenlive
        # libreoffice
        obs-studio
        # planify
        # pika-backup
        postman
        spotify
        tor-browser

        # CLI
        # android-tools
        # ansible
        # bitwarden-cli
        # borgbackup
        bottom
        # claude-code
        copyparty
        distrobox
        duf
        fastfetch
        # ffmpeg
        gemini-cli
        gnumake
        gocryptfs
        htop
        hugo
        immich-go
        jq
        nix-tree
        nmap
        # ollama
        # nvtopPackages.intel
        # podman-compose
        restic
        rustic
        # s3fs
        # superfile
        # steam-run
        # umu-launcher
        # winePackages.wayland
        wl-clipboard
        # zathura #  Document viewer

        # Editor
        # android-studio
        arduino-ide
        # netbeans
        obsidian
        vscode

        # Gaming
        # rpcs3
        # gpu-viewer
        # mangohud
        lutris
        vulkan-tools

        # ventoy-full # https://github.com/NixOS/nixpkgs/issues/404663

        # idk
        # s3fs

        # Programming
        gcc
        go
        # jdk
        # maven
        nixfmt-rfc-style # nix formatter
        nodejs
        php84
        php84Packages.composer
        (python3.withPackages (
          ps: with ps; [
            pip
            virtualenv
          ]
        ))
      ]
      ++ (with nerd-fonts; [
        _0xproto
        caskaydia-cove
      ]);
  };

  programs = {
  	password-store.enable = true;
    home-manager.enable = true;
    bash.enable = true;
    clamav.enable = true;
    gpg.enable = true;
    mycli.enable = true;
    ssh.control = true;
    tmux.enable = true;
    yt-dlp.enable = true;
    yt-dlp.downloader = "wget";
    yt-dlp.path = "${config.home.homeDirectory}/Videos/YouTube";
    git.extraConfig.core.editor = "${pkgs.vscode}/bin/code --wait";
  };

  services = {
    podman.enable = false;

    home-manager.autoExpire = {
      enable = true;
      frequency = "weekly";
      store.cleanup = true;
    };

    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentry.package = pkgs.pinentry-tty;
    };
  };
}