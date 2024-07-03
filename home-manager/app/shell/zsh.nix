{ config, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
    };

    shellAliases = {
      hmbs = "home-manager build switch";
      reload = "source ~/.zshrc";
      rm = "trash-put";
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
        sl = "ls";
        hmg = "home-manager generations";
        clean = "nix-collect-garbage -d";
        cbright="xrandr --output VGA-1 --brightness";
      };
    };
  };
}