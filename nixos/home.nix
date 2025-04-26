{ pkgs, ... }:

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
    };

    sessionVariables = {};

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
      bottom
      cava
      duf
      fastfetch
      htop
      nix-tree
      nmap
      nvtopPackages.intel
      # ollama
      podman-compose
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
      nodejs
      jdk
      (python3.withPackages (ps: with ps; [
        aiohttp
        pip
        pydantic
        virtualenv
      ]))
    ];
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

  # gtk = {
  #   enable = true;
  #   theme.name = "Adwaita";
  #   iconTheme.name = "Adwaita";
  # };

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
      pinentryPackage = pkgs.pinentry-tty;
    };
  };

  # wayland.windowManager.hyprland = {
  #   enable = true;
  #   hypridle.enable = true;
  #   hyprlock.enable = true;
  #   hyprpaper.enable = true;
  #   xwayland.enable = true;
  #   systemd.enable = true;
  # };
}
