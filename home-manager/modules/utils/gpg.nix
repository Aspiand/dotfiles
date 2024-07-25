{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.utils.gpg;
  homeDir = "${config.home.homeDirectory}/.local/data/gnupg";
in

{
  # options.utils.gpg = {
  #   enable = mkEnableOption "GnuPG";
  # };

  options.utils.gpg.enable = mkEnableOption "GnuPG";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.pinentry-tty ];

    programs.gpg = {
      enable = true;
      homedir = homeDir;
    };

    home.file."${homeDir}/gpg-agent.conf".text = ''
      pinentry-program ${config.home.homeDirectory}/.nix-profile/bin/pinentry-tty
      enable-ssh-support
    '';
  };
}
