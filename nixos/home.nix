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
        gnome-tweaks
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
        winePackages.wayland
        wl-clipboard
        # zathura #  Document viewer

        # Editor
        # android-studio
        # arduino-ide
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
      ++ (with gnomeExtensions; [
        blur-my-shell
        launch-new-instance
        # fly-pie
        pano
        status-icons
        system-monitor
        # window-list
      ])
      ++ (with nerd-fonts; [
        _0xproto
        caskaydia-cove
      ]);

    activation.backup = lib.hm.dag.entryBefore [ "preActivation" ] ''
      DIR="$HOME/.local/share/backups/gnome"
      [ ! -f "$DIR" ]; mkdir -vp "$DIR"

      dest="$DIR/$(date +%Y%m%d%H%M%S).conf"
      ${pkgs.dconf}/bin/dconf dump / > $dest

      ln -sf $dest $DIR/latest.conf
    '';

    pointerCursor = {
      gtk.enable = true;
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };
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

  gtk = {
    enable = true;

    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome-themes-extra;
    };

    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  dconf.settings = {
    "org/gnome/Console" = {
      font-scale = 1.5;
      last-window-maximised = false;
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      show-battery-percentage = true;
      toolkit-accessibility = false;
      # gtk-theme = "Adwaita-dark";
      # icon-theme = "Adwaita";
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
      focus-mode = "click";
      resize-with-right-button = false;
    };

    "org/gnome/evolution-data-server" = {
      migrated = true;
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Alt>Return";
      command = "kgx";
      name = "Terminal";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Alt>e";
      command = "nautilus";
      name = "File Manager";
    };

    "org/gnome/settings-daemon/plugins/power" = {
      power-saver-profile-on-low-battery = true;
      sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        blur-my-shell.extensionUuid
        launch-new-instance.extensionUuid
        pano.extensionUuid
        status-icons.extensionUuid
        system-monitor.extensionUuid
        # window-list.extensionUuid
      ];
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      show-hidden = false;
    };

    "org/gtk/settings/file-chooser" = {
      sort-directories-first = true;
    };
  };
}
