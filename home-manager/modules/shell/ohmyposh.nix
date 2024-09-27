{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.shell.ohmyposh;
in # https://ohmyposh.dev/

{
  options.shell.ohmyposh = {
    enable = mkEnableOption "Oh My Posh";
  };

  config = mkIf cfg.enable {
    programs.oh-my-posh = {
      enable = true;
      useTheme = "night-owl";
    };
  };
}