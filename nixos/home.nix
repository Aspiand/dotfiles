{ pkgs, ... }:

{
  imports = [ ../home-manager/profiles/core.nix ];

  home = {
    username = "ao";
    homeDirectory = "/home/ao";
    stateVersion = "25.05";

    sessionVariables = {
      #FLAKE = "$HOME/.config/dotfiles/nixos";
    };

    packages = with pkgs; [
      # Main
      fastfetch
      # mpv
      # mpvScripts.mpris

      # Other
      obs-studio
      bottles
      kdePackages.kdenlive
      discord
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
  };
}
