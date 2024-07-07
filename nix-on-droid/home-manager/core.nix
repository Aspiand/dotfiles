{ pkgs, ... }:

{
  home.packages = with pkgs; [
    findutils
    gawk
    gnugrep
    gnused
    ncurses
    which
  ];
}