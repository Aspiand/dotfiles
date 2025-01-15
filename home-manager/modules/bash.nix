{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.shell.bash;
in

{
  options.shell.bash.enable = mkEnableOption "Bash Shell";

  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [ "ignoreboth" ];
      historyFile = "${config.home.homeDirectory}/.local/history/bash";
      shellAliases.reload = "source ~/.bashrc";

      sessionVariables = {
        PROMPT_COMMAND="history -a; history -n";
      };

      shellOptions = [
        "histappend"
        "autocd"
      ];

      historyIgnore = [
        "clear"
        "hmbs"
        "ncu"
        "code"
        "history"
        "ls"
      ];
    };

    # https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
  };
}