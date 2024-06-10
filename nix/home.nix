{ config, pkgs, ... }:

let
  USER = builtins.getEnv "USER";
  starship_session_key = builtins.getEnv "STARSHIP_SESSION_KEY";
  yt_dest = "/home/${USER}/Share/youtube/raw/";
in

{
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs.config.allowUnfree = true;

  home = {
    username = USER;
    homeDirectory = "/home/${USER}";

    stateVersion = "23.11";

    # activation = {
    #   onActivation = ''
    #     mkdir -p .local/data
    #   '';

    #   # script = ''
    #   #   mkdir -p .local/123
    #   # '';
    # };

    sessionVariables = {
      # STARSHIP_CONFIG = ".config/starship/config.toml";
      # STARSHIP_CACHE = ".cache/starship/session_${starship_session_key}.log";
      EDITOR = "nvim";
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

      # Database
      pkgs.sqlite

      # Files
      pkgs.bat
      pkgs.ffmpeg
      pkgs.rsync
      pkgs.trash-cli
      pkgs.tree

      # Monitor
      pkgs.bottom
      # pkgs.gotop
      pkgs.htop
      # pkgs.iftop
      # pkgs.iotop

      # Network
      pkgs.aria2
      pkgs.curl
      # pkgs.ngrok
      pkgs.nmap
      pkgs.speedtest-cli
      pkgs.wget
      # pkgs.zerotierone

      # Programming
      pkgs.nodejs
      pkgs.jdk_headless
      pkgs.jre_headless
      pkgs.php
      pkgs.python3
      pkgs.python3Packages.pip

      # pkgs.pyright
      # pkgs.ruff-lsp

      # pkgs.nodePackages.intelephense

      # Security
      # pkgs.gnupg
      # pkgs.pass
      # pkgs.steghide

      pkgs.neofetch
      # pkgs.nerdfonts #x!
      # pkgs.ollama
      # pkgs.ventoy-full
      # pkgs.media-downloader
    ];

    file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';

      # ".config/nixpkgs/config.nix".text = "{ allowUnfree = true; }";
    };
  };

  programs = {
    home-manager.enable = true;


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
      # https://www.youtube.com/live/lZshGG4Mcws?si=RYcPcNlWpn_RVC0E 1:33:00
      enable = true;
      viAlias = true;
      vimAlias = true;
      withPython3 = false;

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

        # {
        #   plugin = cmp-nvim-lsp;
        #   type = "lua";
        #   config = ''
        #   '';
        # }
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

      # extraPackages = with pkgs; [
      #   lua-language-server
      # ];
    };

    starship = {
      enable = false;
      enableZshIntegration = true;
      # settings = {};
      # https://starship.rs/config/
    };

    tmux = {
      enable = true;
      mouse = true;
      clock24 = true;
      baseIndex = 1;
      shortcut = "a";
      shell = "${pkgs.zsh}/bin/zsh";
      # terminal = "screen-256color";

      plugins = with pkgs.tmuxPlugins; [
        better-mouse-mode
        logging
        # net-speed
        # nord
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
            # set -g @dracula-plugins "git ssh-session network-bandwidth ram-usage time"
            set -g @dracula-plugins "git ssh-session network-bandwidth time"

            set -g @dracula-border-contrast true
            set -g @dracula-left-icon-padding 0
            set -g @dracula-refresh-rate 5
            set -g @dracula-show-battery false
            set -g @dracula-show-powerline true
            set -g @dracula-show-left-icon N

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
      extraConfig = ''
        --paths ${yt_dest}
        -o %(title)s.%(ext)s

        --sub-langs all,-live_chat

        --embed-thumbnail
        --embed-metadata
        --embed-chapters
        --embed-subs

        --no-overwrites

        -f bestvideo*+bestaudio/best

        --merge-output-format mkv

        --external-downloader "aria2c"
        --external-downloader-args "-x 16 -s 16"

        #--verbose
      '';
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      enable = true;
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
        ignoreDups = true;
        extended = true;
        path = "${config.home.homeDirectory}/.local/zsh_history";
        save = 10000000000000000;
        size = 10000000000000000;
      };

      zsh-abbr = {
        enable = true;
        abbreviations = {
          cat = "bat";
          clean = "nix-collect-garbage -d";
          hmg = "home-manager generations";
          sl = "ls";
        };
      };
    };
  };
}