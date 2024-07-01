{ config, pkgs, ... }:

{

  imports = [
    ../../../files.private/nix/atlas/private.nix
  ];

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs.config.allowUnfree = true;

  home = {
    username = "sinon";
    homeDirectory = "/home/${config.home.username}";

    stateVersion = "23.11";

    sessionVariables = {
      EDITOR = "nvim";
      HM = "${config.home.homeDirectory}/.config/home-manager/home.nix";
    };

    packages = [
      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" "0xProto" ]; })

      # Archive
      pkgs.bzip2
      pkgs.bzip3
      pkgs.gzip
      pkgs.unrar
      pkgs.unzip
      pkgs.xz
      pkgs.zip
      pkgs.zstd

      # Database
      pkgs.sqlite

      # Files
      pkgs.bat
      pkgs.ffmpeg
      pkgs.fzf
      pkgs.rsync
      pkgs.trash-cli
      pkgs.tree

      # Monitor
      pkgs.bottom
      # pkgs.gotop
      pkgs.htop
      # pkgs.iftop
      # pkgs.iotop
      # pkgs.nyx

      # Network
      pkgs.aria2
      pkgs.curl
      pkgs.ngrok
      pkgs.nmap
      pkgs.onionshare
      pkgs.proxychains
      pkgs.speedtest-cli
      pkgs.tor
      pkgs.wget
      # pkgs.zerotierone

      # Programming
      pkgs.nodejs
      # pkgs.jdk_headless
      # pkgs.jre_headless
      pkgs.php
      pkgs.phpPackages.composer
      pkgs.python312
      pkgs.python312Packages.face-recognition
      pkgs.python312Packages.insightface
      pkgs.python312Packages.virtualenv
      pkgs.podman-compose

      # Security
      # pkgs.gnupg
      # pkgs.pass
      pkgs.steghide

      pkgs.android-tools
      pkgs.neofetch
      pkgs.onioncircuits
      # pkgs.opensnitch
      # pkgs.nerdfonts #x!
      # pkgs.media-downloader
      pkgs.ollama
      pkgs.scrcpy
      pkgs.xorg.xrandr
    ];

    file = {
      # config.lib.file.mkOutOfStoreSymlink

      ".config/nixpkgs/config.nix".text = "{ allowUnfree = true; }";

      # Network
      ".config/ngrok/ngrok.yml".source = ../../ngrok/ngrok.yml;
    };
  };

  programs.home-manager.enable = true;

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

    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      tmux.enableShellIntegration = true;
      defaultOptions = [
        "--border"
        "--height 60%"
      ];
    };

    git = {
      enable = true;
      userName = "Aspian";
      extraConfig.init.defaultBranch = "main";

      ignores = [
        ".venv/"
        ".vscode/"
        "__pycache__/"
        "*.pyc"
      ];

      # includes = [];
    };

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;

      plugins = with pkgs.vimPlugins; [
        coc-nvim
        neovim-sensible
        nvim-cmp
        nvim-lspconfig
        nvim-treesitter
        nvim-surround

        vim-airline
        vim-airline-clock
        vim-commentary
        vim-fugitive
        vim-gitgutter
        vim-indent-guides

        {
          plugin = dracula-nvim;
          config = ''
            colorscheme dracula
            syntax enable
          '';
        } {
          plugin = lazy-lsp-nvim;
          type = "lua";
          config = ''
            require("lazy-lsp").setup {
              excluded_servers = {
                "ccls", "zk",
              },
              -- preferred_servers = {
              --   markdown = {},
              --   python = { "pyright", "ruff_lsp" },
              -- }

            }
          '';
        } {
          plugin = vim-airline-themes;
          config = "let g:airline_theme='wombat'";
        }
      ];

      extraConfig = ''
        set cursorline
        set scrolloff=5
      '';

      # https://www.youtube.com/live/lZshGG4Mcws?si=RYcPcNlWpn_RVC0E 1:33:00
    };

    ssh = {
      enable = true;
      controlMaster = "auto";
      controlPersist = "30m";
      controlPath = "~/.ssh/control/%r@%n:%p";
      # programs.ssh.addKeysToAgent = [];
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

    yt-dlp = {
      enable = true;
      settings = {
        output = "%(title)s.%(ext)s";

        embed-chapters = true;
        embed-metadata = true;
        embed-subs = true;
        embed-thumbnail = true;

        format = "bestvideo*+bestaudio/best";
        merge-output-format = "mkv";

        downloader = "aria2c";
        downloader-args = "aria2c:'-x16 -s16 -c'";
      };

      # extraConfig = "--sub-langs all, -live_chat";
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
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

      # loginShellInit = ''
      #   echo "Login"
      # '';

      # shellInit = ''
      #   echo "Init!"
      # '';

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
  };
}
