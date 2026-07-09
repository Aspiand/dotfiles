{ config, pkgs, lib, ... }:

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
    rm = "${pkgs.trash-cli}/bin/trash-put";
    remove = "${pkgs.coreutils}/bin/rm";
    tree = "${pkgs.eza}/bin/eza --tree";
  };

  home.packages = with pkgs; [
    # Archive
    gnutar
    gzip
    unzip
    xz
    zip

    # Network
    aria2
    curl
    sshfs
    wget

    # Base Utils
    coreutils
    rsync
    trash-cli
  ];

  programs = with lib; {
    home-manager.enable = true;
    bash.enable = mkDefault true;
    git.enable = mkDefault true;
    tmux.enable = mkDefault true;
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
