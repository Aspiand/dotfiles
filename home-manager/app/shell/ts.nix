{ pkgs, ... }:

{
  programs = {
    starship = {
      enable = true;
      enableZshIntegration = false;
      enableBashIntegration = true;
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
          format = "via [☃️ $state( \($name\))](bold blue) ";
        };

        sudo = {
          disabled = true;
          style = "bold red";
          # symbol = 	"🧙 ";
        };
      };
    }; #https://starship.rs/config/

    tmux = {
      enable = true;
      mouse = true;
      clock24 = true;
      baseIndex = 1;
      shortcut = "a";
      shell = "${pkgs.zsh}/bin/zsh";

      plugins = with pkgs.tmuxPlugins; [
        better-mouse-mode
        logging
        pain-control
        prefix-highlight
        sensible
        sidebar
        # t-smart-tmux-session-manager
        yank

        {
          # https://draculatheme.com/tmux
          plugin = dracula;
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
