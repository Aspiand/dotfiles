{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.shell;
in

{
  options.shell = {
    bash.enable = mkEnableOption "Bash Shell";
    shell.nix-path = mkOption {
      type = types.path;
      default = "${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh";
      example = "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh";
    };
  };

  config = mkIf cfg.bash.enable {
    programs.bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [ "ignoreboth" ];
      historyFile = "${config.home.homeDirectory}/.local/history/bash";
      shellAliases.reload = "source ~/.bashrc";
      bashrcExtra = ''
        source ${cfg.shell.nix-path}
      '';

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