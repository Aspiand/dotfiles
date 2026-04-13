{ pkgs, ... }:

{
  home = {
    username = "aka";
    homeDirectory = "/home/aka";
    stateVersion = "26.05";

    packages = with pkgs; [
      wl-clipboard
      firefox
    ];
  };
}
