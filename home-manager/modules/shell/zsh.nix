{ config, pkgs, lib, ... }:

with lib; let cfg = config.shell.zsh; in

{
  options.shell.zsh.enable = mkEnableOption "Z Shell";

  config = mkIf cfg.enable {

    programs.zsh = {
      enable = true;
      autocd = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      dotDir = ".config/zsh";
      shellAliases.reload = "source ${config.programs.zsh.dotDir}/.zshrc";
      initExtra = "source ${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh";

      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
      };

      zplug = {
        enable = false;
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
        path = "${config.home.homeDirectory}/.local/history/zsh";
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