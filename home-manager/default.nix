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

    # file = { # config.lib.file.mkOutOfStoreSymlink };

    packages = with pkgs; [
      (writeShellScriptBin "ffm" (builtins.readFile ../sh/ffm.sh)) # https://discourse.nixos.org/t/link-scripts-to-bin-home-manager/41774
    ];
  };

  programs.home-manager.enable = true;
}