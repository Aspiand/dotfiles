{ config, pkgs, lib, ... }:

with lib; let cfg = config.shell.bash; in

{
  options.shell.bash.enable = mkEnableOption "Bash Shell";

  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [ "ignoreboth" ];
      historyFile = "${config.home.homeDirectory}/.local/history/bash";
      shellAliases.reload = "source ~/.bashrc";
    };
  };
}