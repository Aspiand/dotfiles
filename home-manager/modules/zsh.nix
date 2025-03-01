{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.shell.zsh;
  dir = config.programs.zsh.dotDir;
  home = config.home.homeDirectory;
  zplug = config.programs.zsh.zplug;
in

{
  options.shell.zsh.enable = mkEnableOption "Z Shell";

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      autocd = true;
      enableCompletion = true;
      autosuggestion.enable = false;
      syntaxHighlighting.enable = true;
      dotDir = ".config/zsh";
      shellAliases.reload = "source ${dir}/.zshrc";

      initExtra = mkIf zplug.enable ''
        [[ -f ${dir}/.p10k.zsh ]] && source ${dir}/.p10k.zsh
      '';

      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
      };

      zplug = {
        enable = false;
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

    # home.file."${dir}/.p10k.zsh".source = mkIf zplug.enable ../../../zsh/p10k;
  };
}