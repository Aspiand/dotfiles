{ config, pkgs, lib, ... }:

with lib; let cfg = config.shell.bash; in

{
  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = false;
      enableBashIntegration = true;
      enableNushellIntegration = false;
      settings = {
        add_newline = false;
        character.error_symbol = "[✗](bold red)";

        cmd_duration = {
          min_time = 1000;
          format = "[$duration](bold yellow)";
        };

        bun.disabled = true;
        gradle.format = "[$symbol]($style)";
        java.format = "[$symbol]($style)";
        kotlin.format = "[$symbol]($style)";

        nix_shell = {
          disabled = false;
          impure_msg = "[impure shell](bold red)";
          pure_msg = "[pure shell](bold green)";
          unknown_msg = "[unknown shell](bold yellow)";
          format = "❄️ [$state( \($name\))](bold blue)";
        };

        php.format = "[$symbol]($style)"; # 🔹
        nodejs.format = "[$symbol]($style)";
        sudo.format = "[ɫ ](bold red)";
      };
    }; #https://starship.rs/config/
  };
}