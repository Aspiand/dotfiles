{ config, pkgs, lib, ... }:

{
  programs.tmux = {
    mouse = true;
    clock24 = true;
    newSession = true;
    aggressiveResize = true;
    baseIndex = 1;
    shortcut = "a";
    terminal = "screen-256color";

    extraConfig = ''
      set-option -g status-position top
    '';

    plugins = with pkgs.tmuxPlugins; [
      better-mouse-mode
      continuum
      copycat
      logging
      pain-control
      prefix-highlight
      resurrect
      sensible
      sidebar
      yank

      {
        plugin = nord;
        extraConfig = ''
          set -g @nord_tmux_show_status_content "d"
        '';
      }
    ];
  };
}
