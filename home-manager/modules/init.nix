# https://github.com/notusknot/dotfiles-nix

{ config, pkgs, lib, ... }:

with lib; let cfg = config.programs; in

{
  imports = [
    ./core.nix
    ./center.nix

    ./bash.nix
    ./zsh.nix
    ./starship.nix
    ./tmux.nix

    ./clamav.nix
    ./neovim.nix

    ./sshd.nix

    ./librewolf.nix
  ];
}