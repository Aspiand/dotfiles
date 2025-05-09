{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [ ../home-manager/default.nix ];

  # fonts.fontconfig.enable = true;

  home = {
    username = "ao";
    homeDirectory = "/home/ao";
    stateVersion = "25.05";

    shellAliases = {
      switch = "sudo nixos-rebuild switch --flake ~/.config/dotfiles/nixos";
      code = "NIXOS_OZONE_WL=1 code";
      ehe = "fastfetch";
      brave = "HOME=\"$HOME/.local/share/brave\" brave";
      debian = "${pkgs.distrobox}/bin/distrobox enter debian";
    };

    sessionVariables = {
      GOPATH = "${config.xdg.dataHome}/go";
    };

    packages = with pkgs; [
      nerd-fonts._0xproto
      nerd-fonts.caskaydia-cove

      # Desktop
      discord
      firefox
      kdePackages.kdenlive
      libreoffice
      obs-studio
      osu-lazer
      postman
      spotify
      tor-browser
      umu-launcher

      # CLI
      android-tools
      bottom
      cava
      distrobox
      duf
      fastfetch
      gcc
      htop
      maven
      nix-tree
      nmap
      nvtopPackages.intel
      # ollama
      podman-compose
      superfile
      steam-run
      winePackages.wayland
      wl-clipboard

      # Editor
      android-studio
      arduino-ide
      netbeans
      obsidian
      vscode

      # Gaming
      # rpcs3
      vulkan-tools
      gpu-viewer

      # Programming
      go
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

    activation.backup = lib.hm.dag.entryBefore [ "preActivation" ] ''
      DIR="$HOME/.local/share/backups/gnome"
      [ ! -f "$DIR" ]; mkdir -vp "$DIR"

      ${pkgs.dconf}/bin/dconf dump / > $DIR/$(date +%Y%m%d%H%M%S).conf
    '';

    pointerCursor = {
      gtk.enable = true;
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };
  };

  programs = {
    bash.enable = true;
    clamav.enable = true;
    gpg.enable = true;
    mycli.enable = true;
    neovim.enable = true;
    ssh.control = true;
    tmux.enable = true;
    yt-dlp.enable = true;
    yt-dlp.downloader = "aria2c";
  };

  services = {
    podman.enable = true;

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
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      gtk-theme = "Adwaita-dark";
      icon-theme = "Adwaita";
      show-battery-percentage = true;
      toolkit-accessibility = false;
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

    "org/gnome/settings-daemon/plugins/power" = {
      power-saver-profile-on-low-battery = true;
      sleep-inactive-ac-type = "nothing";
    };
  };
}
