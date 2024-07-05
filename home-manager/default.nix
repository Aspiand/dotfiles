{ config, pkgs, ... }:

{
  imports = [
    ./app/full.nix
    ./app/shell/all.nix
    ./app/editor/all.nix
    ../../files.private/home-manager/private.nix
  ];

  home = {
    username = "sinon";
    homeDirectory = "/home/${config.home.username}";
    stateVersion = "24.11";

    # file = { # config.lib.file.mkOutOfStoreSymlink };

    packages = with pkgs; [
      (writeShellScriptBin "ffm" (builtins.readFile ../sh/ffm.sh)) # https://discourse.nixos.org/t/link-scripts-to-bin-home-manager/41774
    ];
  };

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;
}