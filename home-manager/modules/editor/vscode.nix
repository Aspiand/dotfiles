{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = false;
    package = pkgs.vscodium;
  };

  # https://nixos.wiki/wiki/Visual_Studio_Code
  # https://github.com/nix-community/home-manager/blob/master/modules/programs/vscode.nix
}