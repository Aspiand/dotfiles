{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.sessionVariables = {
    EDITOR = "${pkgs.micro}/bin/micro";
  };

  home.shellAliases = {
    durl = "curl -O --progress-bar";
    l = "ls -lh";
    la = "ls -lAh --octal-permissions";
    ld = "ls --only-dirs";
    ll = "ls -lh --total-size";
    ncu = "nix-channel --update";
    ncl = "nix-channel --list";
    nclg = "nix-channel --list-generations";
    news = "${pkgs.home-manager}/bin/home-manager news";
    rm = "${pkgs.trash-cli}/bin/trash-put"; # don't change this line
    remove = "${pkgs.coreutils}/bin/rm";
    tree = "${pkgs.eza}/bin/eza --tree";
  };

  programs = with lib; {
    home-manager.enable = true;
    fastfetch.enable = mkDefault true;
    micro.enable = mkDefault true;
    modern-utils.enable = mkDefault true;
    password-store.enable = mkDefault false;

    gpg = {
      enable = mkDefault true;
      homedir = mkDefault "${config.xdg.dataHome}/gnupg";
    };
  };
}
