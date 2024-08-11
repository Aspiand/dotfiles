{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.programs.utils.tmux;
in

{
  options.programs.utils.tmux = {
    enable = mkEnableOption "Tmux";
    shell = mkOption {
      type = types.str;
      default = "${pkgs.zsh}/bin/zsh";
    };
    plugins = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      mouse = true;
      clock24 = true;
      newSession = true;
      baseIndex = 1;
      shortcut = "a";
      shell = cfg.shell;

      plugins = mkIf cfg.plugins [
        pkgs.tmuxPlugins.better-mouse-mode
        pkgs.tmuxPlugins.logging
        pkgs.tmuxPlugins.pain-control
        pkgs.tmuxPlugins.prefix-highlight
        pkgs.tmuxPlugins.sensible
        pkgs.tmuxPlugins.sidebar
        pkgs.tmuxPlugins.yank

        {
          # https://draculatheme.com/tmux
          plugin = pkgs.tmuxPlugins.dracula;
          extraConfig = ''
            set -g @dracula-plugins "git ssh-session network-bandwidth time"

            set -g @dracula-border-contrast true
            set -g @dracula-left-icon-padding 0
            set -g @dracula-refresh-rate 5
            set -g @dracula-show-battery false
            set -g @dracula-show-powerline true
            set -g @dracula-show-left-icon $

            # Device
            set -g @dracula-ram-usage-label ""

            # Network
            set -g @dracula-network-bandwidth-interval 0
            set -g @dracula-show-ssh-session-port true

            # Time
            set -g @dracula-show-timezone false
            set -g @dracula-day-month false
            set -g @dracula-military-time true
            set -g @dracula-time-format "%H:%M"

            # Git
            set -g @dracula-git-disable-status true
            set -g @dracula-git-show-current-symbol $
            set -g @dracula-git-show-diff-symbol !
            set -g @dracula-git-no-repo-message "-"
            set -g @dracula-git-no-untracked-files true
            set -g @dracula-git-show-remote-status false
          '';
        }
      ];
    };
  };
}
