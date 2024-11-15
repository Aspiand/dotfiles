{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.shell.zsh;
  dir = config.programs.zsh.dotDir;
  home = config.home.homeDirectory;
in

{
  options.shell.zsh.enable = mkEnableOption "Z Shell";

  config = mkIf cfg.enable {

    home.file."${dir}/.p10k.zsh".source = ../../../zsh/p10k;

    programs.zsh = {
      enable = true;
      autocd = true;
      enableCompletion = true;
      autosuggestion.enable = false;
      syntaxHighlighting.enable = true;
      dotDir = ".config/zsh";
      shellAliases.reload = "source ${dir}/.zshrc";

      initExtra = mkIf config.programs.zsh.zplug.enable ''
        [[ -f ${dir}/.p10k.zsh ]] && source ${dir}/.p10k.zsh
      '';

      oh-my-zsh = {
        enable = false;
        theme = "robbyrussell";
      };

      zplug = {
        enable = true;
        zplugHome = "${home}/.config/zsh/zplug";
        plugins = [
          { name = "zsh-users/zsh-autosuggestions"; }
          { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; }
        ];
      };

      history = {
        share = true;
        extended = true;
        ignoreDups = true;
        ignorePatterns = [];
        save = 100000;
        size = config.programs.zsh.history.save;
        path = "${home}/.local/history/zsh";
      };

      zsh-abbr = {
        enable = true;
        abbreviations = {
          clean = "nix-collect-garbage -d";
          cbright="xrandr --output VGA-1 --brightness";
        };
      };
    };
  };
}