{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in

{
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
    inputs.home-config.homeModules.default
  ];

  home = {
    username = "ao";
    homeDirectory = "/home/ao";
    stateVersion = "26.11";

    shellAliases = {
      switch = "sudo nixos-rebuild switch --print-build-logs --accept-flake-config --flake ~/.config/dotfiles/nixos/hosts/aira";
      self = "ssh self";
    };

    sessionVariables = {
      GOPATH = "${config.xdg.dataHome}/go";
      QT_QPA_PLATFORM = "wayland";
      ANTHROPIC_BASE_URL = "https://9router.astrapia-kokanue.ts.net/v1";
      ANTHROPIC_API_KEY = "sk-dc180c793b48d514-wiipho-392f44a7"; # TODO: sops
    };

    packages =
      (with pkgs; [
        # Desktop
        # authenticator
        # bitwarden-desktop
        # dbeaver-bin
        # cc-switch
        discord
        firefox
        gnome-tweaks
        # gnome-extension-manager
        gradia
        # heroic
        kdePackages.kdenlive
        # libreoffice
        obs-studio
        # onlyoffice-desktopeditors
        # planify
        # postman
        protonplus
        # spotify
        tor-browser

        # CLI
        python314Packages.markitdown
        # act
        # android-tools
        # ansible
        # bitwarden-cli
        codex
        copyparty-most
        delta
        # distrobox
        # gallery-dl
        gemini-cli
        gh
        # gnumake
        # gocryptfs
        # hugo
        # immich-go
        # kando
        lazydocker
        nmap
        nvtopPackages.intel
        restic
        rustic
        # s3fs
        # sqlmap
        # steam-run
        sops
        # umu-launcher
        # winePackages.wayland
        wl-clipboard
        # zathura #  Document viewer

        # Editor
        # android-studio
        # antigravity
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

        # Programming
        # bun
        # gcc
        # go
        # jdk
        # maven
        nixfmt # nix formatter
        # deploy-rs # deploy nixos to remote hosts
        nodejs
        # rustc
        # php85
        # php85Packages.composer
        # (python3.withPackages (
        #   ps: with ps; [
        #     pip
        #     virtualenv
        #     pyyaml
        #   ]
        # ))

        # Fonts
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif

        hanabi
        codegraph
        mcp-nixos
        mempalace
        # inputs.hermes-agent.packages.${pkgs.system}.desktop
      ])
      ++ (with pkgs.gnomeExtensions; [
        blur-my-shell
        clipboard-indicator
        # kando-integration
        gsconnect
        launch-new-instance
        # quick-settings-tweaker
        appindicator
        system-monitor
      ])
      ++ (with pkgs.nerd-fonts; [
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
      enable = true;
      gtk.enable = true;
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };
  };

  programs = {
    modern-utils.enable = true;
    password-store.enable = true;
    claude-code.enable = true;
    mcp.enable = true;
    home-manager.enable = true;
    bash.enable = true;
    clamav.enable = true;
    fresh-editor.enable = true;
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

    spicetify = {
      enable = true;
      colorScheme = "mocha";
      theme = spicePkgs.themes.catppuccin // {
        injectCss = true;
        injectThemeJs = true;
        replaceColors = true;
        overwriteAssets = true;
      };

      enabledExtensions = with spicePkgs.extensions; [
        adblock
        hidePodcasts
        shuffle
      ];

      enabledCustomApps = with spicePkgs.apps; [
        newReleases
        ncsVisualizer
        marketplace
        lyricsPlus
      ];
    };

    browserpass = {
      enable = true;
      browsers = [ "firefox" ];
    };
  };

  # xdg.configFile."autostart/kando.desktop".text = ''
  #   [Desktop Entry]
  #   Type=Application
  #   Version=1.0
  #   Name=Kando
  #   Comment=Start Kando on login
  #   Exec=${lib.getExe pkgs.kando}
  #   TryExec=${lib.getExe pkgs.kando}
  #   Terminal=false
  #   X-GNOME-Autostart-enabled=true
  # '';

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
      enableSshSupport = false;
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

    "org/gnome/desktop/input-sources" = {
      xkb-options = [
        "terminate:ctrl_alt_bksp"
        # "lv3:ralt_switch"
      ];
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      show-battery-percentage = true;
      toolkit-accessibility = false;
      # gtk-theme = "Adwaita-dark";
      # icon-theme = "Adwaita";
    };

    "org/gnome/desktop/media-handling" = {
      automount = false;
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

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
      ];
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
        # kando-integration.extensionUuid
        launch-new-instance.extensionUuid
        appindicator.extensionUuid
        system-monitor.extensionUuid
        pkgs.hanabi.extensionUuid
        # quick-settings-tweaker.extensionUuid
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
