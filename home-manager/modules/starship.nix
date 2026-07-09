{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.starship = {
    enable = lib.mkDefault config.programs.bash.enable;
    enableBashIntegration = lib.mkDefault true;
    settings = {
      add_newline = false;
      character.error_symbol = "[✗](bold red)";

      cmd_duration = {
        min_time = 1000;
        format = "[$duration ](bold yellow)";
      };

      git_branch = {
        format = "[$symbol$branch(:$remote_branch)]($style) ";
      };

      memory_usage = {
        disabled = false;
        threshold = 80;
        symbol = "󰍛 ";
      };

      nix_shell = {
        disabled = false;
        symbol = "󰼪 ";
        impure_msg = "[impure](bold red)";
        pure_msg = "[pure](bold green)";
        unknown_msg = "[unknown](bold yellow)";
      };

      hostname = {
        format = "[$ssh_symbol$hostname]($style) ";
      };

      username = {
        style_user = "white bold";
        style_root = "black bold";
        format = "[$user]($style) ";
      };

      sudo = {
        disabled = false;
        format = "[ɫ ](bold red)";
      };
    };
  };
}
