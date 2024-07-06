{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.utils.fzf;
in

{
  options.utils.fzf = {
    enable = mkEnableOption "fzf";
  };

  config = mkIf cfg.enable {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      tmux.enableShellIntegration = true;
      defaultOptions = [
        "--border"
        "--height 60%"
      ];
    };
  };
}