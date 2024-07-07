{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.shell;
in

{
  options.shell = {
    variable = mkOption {
      type = types.attrs;
      default = {};
      example = { POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=["dir" "vcs"]; };
      description = ''
        Extra local variables defined at the top of {file}`{.zshrc|.bashrc}`.
      '';
    };
  };

  config = {
    programs.zsh.localVariables = cfg.variable;
    programs.bash.sessionVariables = cfg.variable;
    # programs.bash.profileExtra = "${config.lib.shell.exportAll cfg.variable}";
  };
}