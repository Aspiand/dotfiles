{ config, pkgs, ... }:

{
  imports = [
    ./shell/ts.nix
    ./shell/bash.nix
    ./editor/neovim.nix
  ];

  home.packages = with pkgs; [
    apt
    busybox
    dpkg
    nano
  ];
}