{ config, pkgs, ... }:

{
  imports = [
    ./app/full.nix
    ../../files.private/nix/atlas/private.nix
  ];

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs.config.allowUnfree = true;

  home = {
    username = "sinon";
    homeDirectory = "/home/${config.home.username}";

    stateVersion = "23.11";

    file = {
      # config.lib.file.mkOutOfStoreSymlink
      ".config/nixpkgs/config.nix".text = "{ allowUnfree = true; }";
    };
  };

  programs.home-manager.enable = true;
}