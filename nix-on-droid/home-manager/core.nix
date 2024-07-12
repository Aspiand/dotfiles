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

  programs.gpg = {
    enable = true;
    homedir = "${config.home.homeDirectory}/.local/data/gnupg";
  };

  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_CLIP_TIME = 120;
      PASSWORD_STORE_GENERATED_LENGTH = 30;
      PASSWORD_STORE_DIR = "$HOME/.local/data/password_store/";
    };
  };
}