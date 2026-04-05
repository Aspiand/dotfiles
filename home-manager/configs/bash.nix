{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.programs.bash;
in

{
  config = mkIf cfg.enable {
    home.packages = [ pkgs.nerd-fonts.caskaydia-cove ];
    programs.bash = {
      enableCompletion = true;
      historyControl = [ "ignoreboth" ];
      historyFile = "${config.home.homeDirectory}/.local/history/bash";
      bashrcExtra = ''
        if [[ -f "${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh" ]]; then
          source ${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh
        elif [[ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
          source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        fi
      '';

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

      shellAliases = {
        reload = "source ~/.bashrc";
      };

      sessionVariables = {
        PROMPT_COMMAND = "history -a; history -n";
      };
    };

    # https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
  };
}
