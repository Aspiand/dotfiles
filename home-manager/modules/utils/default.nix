{ config, pkgs, lib, ... }:

with lib; let cfg = config.programs.utils; in

{
  options.programs.utils = {
    general = mkEnableOption "General package";

    gnupg = {
      enable = mkEnableOption "GnuPG";
      dir = mkOption {
        type = types.str;
        default = "${config.home.homeDirectory}/.local/share/gnupg";
        example = "${config.home.homeDirectory}/.gnupg";
      };
    };
  };
}