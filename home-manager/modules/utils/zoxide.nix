{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.utils.zoxide;
in

{
  options.utils.zoxide = {
    enable = mkEnableOption "Zoxide";
  };

  config = mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
  };
}