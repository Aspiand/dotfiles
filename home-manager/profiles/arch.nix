{ config, pkgs, ... }:

# nix run home-manager/master -- switch --flake /home/kuro/.config/dotfiles#arch

{
  imports = [ ./core.nix ];
  nixpkgs.config.allowUnfree = true;
  # nix = {
  #   package = pkgs.nix;
  #   settings.experimental-features = [ "nix-command" "flakes" ];
  # };

  home = {
    username = "ao";
    homeDirectory = "/home/ao";
    stateVersion = "25.05";
    packages = with pkgs; [
      # Main
      fastfetch
      mpv
      mpvScripts.mpris
      # emote

      # Other
      obs-studio
      bottles
      kdePackages.kdenlive
      discord
      steam
      spotify
      nmap

      # Browser
      firefox
      tor-browser

      # Editor
      android-studio
      netbeans
      obsidian
      vscode

      # Programming
      (python3.withPackages (ps: with ps; [
        aiohttp
        pip
        pydantic
        virtualenv
      ]))

      php84
      nodejs
      jdk_headless
      jre_headless
    ];
  };

  programs = {
    git.extraConfig.core.editor = "${pkgs.vscode}/bin/code --wait";
    bash.enable = true;
    clamav.enable = true;
    neovim.enable = true;
    password-store.enable = true;
    ssh.control = true;
    tmux.enable = true;
    yt-dlp.enable = true;
    yt-dlp.downloader = "aria2c";
  };

  services.podman.enable = true;
}
