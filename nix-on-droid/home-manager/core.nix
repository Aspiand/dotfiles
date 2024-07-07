{ pkgs, ... }:

{
  home.packages = with pkgs; [
    findutils
    gawk
    gnugrep
    gnupg
    gnused
    ncurses
    which
  ];

  programs.gpg.enable = true;
}