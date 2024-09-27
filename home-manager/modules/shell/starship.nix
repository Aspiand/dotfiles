{ config, pkgs, lib, ... }:

with lib; let cfg = config.shell.starship; in

{
  options.shell.starship.enable = mkEnableOption "Starship";

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings = {
        add_newline = false;
        character.error_symbol = "[✗](bold red)";

        cmd_duration = {
          min_time = 1000;
          format = "[$duration](bold yellow)";
        };

        nix_shell = {
          disabled = false;
          impure_msg = "[impure shell](bold red)";
          pure_msg = "[pure shell](bold green)";
          unknown_msg = "[unknown shell](bold yellow)";
          format = "via [$state( \($name\))](bold blue) ";
        };

        sudo = {
          disabled = true;
          style = "bold red";
          # symbol = 	"🧙 ";
        };
      };
    }; #https://starship.rs/config/
  };
}