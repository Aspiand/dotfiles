{ config, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    dotDir = ".config/zsh";

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

    shellAliases = {
      reload = "source ${config.programs.zsh.dotDir}/.zshrc";
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