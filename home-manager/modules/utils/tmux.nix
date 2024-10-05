{ config, pkgs, lib, ... }:

with lib; let cfg = config.programs.utils.tmux; in

{
  options.programs.utils.tmux = {
    enable = mkEnableOption "Tmux";
    shell = mkOption {
      type = types.str;
      default = "${pkgs.zsh}/bin/zsh";
    };
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      mouse = true;
      clock24 = true;
      newSession = true;
      aggressiveResize = true;
      baseIndex = 1;
      shortcut = "a";
      terminal = "screen-256color";
      shell = cfg.shell;

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
          # https://draculatheme.com/tmux
          plugin = dracula;
          extraConfig = ''
            set -g @dracula-plugins "ssh-session network-bandwidth time"

            set -g @dracula-border-contrast true
            set -g @dracula-left-icon-padding 0
            set -g @dracula-refresh-rate 5
            set -g @dracula-show-battery false
            set -g @dracula-show-powerline true
            set -g @dracula-show-left-icon ☪

            # Device
            set -g @dracula-ram-usage-label ""

            # Network
            # set -g @dracula-network-bandwidth eth0
            set -g @dracula-network-bandwidth-interval 0.5
            set -g @dracula-show-ssh-session-port true

            # Time
            set -g @dracula-show-timezone false
            set -g @dracula-day-month false
            set -g @dracula-military-time true
            set -g @dracula-time-format "%H:%M"

            # Git
            set -g @dracula-git-disable-status true
            set -g @dracula-git-show-current-symbol ✓
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