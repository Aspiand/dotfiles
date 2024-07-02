{ config, pkgs, ... }:

{
  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [ "ignoreboth" ];
      historyFile = "${config.home.homeDirectory}/.local/history/bash";

      shellAliases = {
        rm = "trash-put";
        reload = "source ~/.bashrc";
        hmbs = "home-manager build switch";
      };

      bashrcExtra = ''
        . ${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh

        case "$TERM" in
            xterm-color|*-256color) color_prompt=yes;;
        esac

        if [ -n "$force_color_prompt" ]; then
            if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
                color_prompt=yes
            else
                color_prompt=
            fi
        fi

        if [ -x /usr/bin/dircolors ]; then
            test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
            alias ls='ls --color=auto'

            alias grep='grep --color=auto'
            alias fgrep='fgrep --color=auto'
            alias egrep='egrep --color=auto'
        fi

        if ! shopt -oq posix; then
          if [ -f /usr/share/bash-completion/bash_completion ]; then
            . /usr/share/bash-completion/bash_completion
          elif [ -f /etc/bash_completion ]; then
            . /etc/bash_completion
          fi
        fi
      '';
    };

    zsh = {
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
        t-smart-tmux-session-manager
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