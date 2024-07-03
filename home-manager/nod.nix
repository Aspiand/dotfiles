{ config, pkgs, ... }:

{
  imports = [
    ./full.nix
    ./app/shell/ts.nix
    ./app/shell/zsh.nix
    ./app/editor/neovim.nix
  ];
}