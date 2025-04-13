{ pkgs, ... }:

{
  imports = [ ../home-manager/profiles/core.nix ];

  # fonts.fontconfig.enable = true;

  home = {
    username = "ao";
    homeDirectory = "/home/ao";
    stateVersion = "25.05";

    shellAliases = {
      switch = "sudo nixos-rebuild switch --flake ~/.config/dotfiles/nixos";
    };

    sessionVariables = {};

    packages = with pkgs; [
      nerd-fonts._0xproto
      nerd-fonts.caskaydia-cove

      # Desktop
      discord
      firefox
      kdePackages.kdenlive
      obs-studio
      osu-lazer
      spotify
      tor-browser

      # CLI
      duf
      fastfetch
      nmap
      nvtopPackages.intel
      ollama
      podman-compose
      wl-clipboard

      # Editor
      android-studio
      netbeans
      obsidian
      vscode

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

  services = {
    podman.enable = true;
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryPackage = pkgs.pinentry-tty;
    };
  };
}
