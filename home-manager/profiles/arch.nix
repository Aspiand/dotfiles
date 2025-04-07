{ config, pkgs, ... }:

{
  imports = [ ./core.nix ];
  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  home = {
    stateVersion = "25.05";
    packages = with pkgs; [
      # Main
      kitty
      dolphin
      ark
      nwg-displays
      fastfetch
      emote

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

    ];
  };
}