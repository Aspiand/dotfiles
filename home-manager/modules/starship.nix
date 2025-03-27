{ config, pkgs, lib, ... }:

with lib;

{
  programs.starship = {
    enable = mkDefault true;
    enableBashIntegration = true;
    enableFishIntegration = mkDefault true;
    settings = {
      add_newline = false;
      character.error_symbol = "[✗](bold red)";

      cmd_duration = {
        min_time = 1000;
        format = "[$duration ](bold yellow)";
      };

      nix_shell = {
        disabled = false;
        impure_msg = "[impure shell](bold red)";
        pure_msg = "[pure shell](bold green)";
        unknown_msg = "[unknown shell](bold yellow)";
        format = "❄️ [$state( \($name\))](bold blue)";
      };

      sudo = {
        disabled = false;
        format = "[ɫ ](bold red)";
      };
    };
  };
}