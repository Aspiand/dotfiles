{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
    ../../../home-manager/default.nix
  ];

  home = {
    username = "ao";
    homeDirectory = "/home/ao";
    stateVersion = "26.05";

    shellAliases = {
      switch = "sudo nixos-rebuild switch --verbose --flake ~/.config/dotfiles/nixos/hosts/aira";
      self = "ssh self";
    };

    sessionVariables = {
      GOPATH = "${config.xdg.dataHome}/go";
      QT_QPA_PLATFORM = "wayland";
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
        # obs-studio
        # onlyoffice-desktopeditors
        # planify
        postman
        protonplus
        spotify
        tor-browser
        winboat

        # CLI
        act
        # android-tools
        # ansible
        # bitwarden-cli
        codex
        copyparty-most
        delta
        distrobox
        gallery-dl
        gemini-cli
        # gnumake
        gocryptfs
        hugo
        immich-go
        nmap
        opencode
        # nvtopPackages.intel
        restic
        rustic
        # s3fs
        # sqlmap
        # steam-run
        # umu-launcher
        # winePackages.wayland
        wl-clipboard
        # zathura #  Document viewer

        # Editor
        # android-studio
        antigravity
        # arduino-ide
        # netbeans
        obsidian
        vscode

        # Gaming
        # rpcs3
        # gpu-viewer
        mangohud
        # lutris
        vulkan-tools

        # ventoy-full # https://github.com/NixOS/nixpkgs/issues/404663

        # idk
        # s3fs

        # Programming
        bun
        gcc
        go
        # jdk
        # maven
        nixfmt # nix formatter
        nodejs
        # rustc
        php84
        php84Packages.composer
        (python3.withPackages (
          ps: with ps; [
            pip
            virtualenv
            pyyaml
          ]
        ))

        hanabi
      ]
      ++ (with gnomeExtensions; [
        blur-my-shell
        clipboard-indicator
        # fly-pie
        gsconnect
        launch-new-instance
        appindicator
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
    modern-utils.enable = true;
    password-store.enable = true;
    home-manager.enable = true;
    bash.enable = true;
    clamav.enable = true;
    gpg.enable = true;
    git.lfs.enable = true;
    lutris.enable = true;
    mycli.enable = false;
    # ssh.control = true;
    # ssh.enableDefaultConfig = false; # later
    tmux.enable = true;
    vscode-fzf.enable = true;
    vscode-fzf.dirs = [ "$HOME/Kode/workspaces" ];
    yt-dlp.enable = true;
    yt-dlp.downloader = "wget";
    yt-dlp.path = "${config.home.homeDirectory}/Videos/YouTube";
    git.settings.core.editor = "${pkgs.vscode}/bin/code --wait";

    spicetify =
      let
        spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
      in
      {
        enable = false;
        theme = spicePkgs.themes.bloom;
        colorScheme = "comfy";

        enabledExtensions = with spicePkgs.extensions; [
          adblock
          hidePodcasts
          shuffle
        ];
      };
  };

  services = {
    kdeconnect = {
      enable = false;
      indicator = true;
      # package = pkgs.gnomeExtensions.gsconnect;
    };

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
        clipboard-indicator.extensionUuid
        # gsconnect.extensionUuid
        launch-new-instance.extensionUuid
        appindicator.extensionUuid
        system-monitor.extensionUuid
        "hanabi-extension@jeffshee.github.io"
        # window-list.extensionUuid
        # wakapanel.extensionUuid
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
