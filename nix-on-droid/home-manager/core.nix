{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gawk
    gnugrep
    gnused
    ncurses
    which
  ];
}