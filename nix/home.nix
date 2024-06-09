{ config, pkgs, ... }:

let
  USER = builtins.getEnv "USER";

  yt_dest = "/home/${USER}/Share/youtube/raw/";
in

{
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

    packages = [
      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" "0xProto" ]; })

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
      pkgs.nerdfonts #x!
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

      ".config/nixpkgs/config.nix".text = "{ allowUnfree = true; }";
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
      enable = true;
      viAlias = true;
      vimAlias = true;
      withPython3 = true;

      # coc.enable = false;

      plugins = with pkgs.vimPlugins; [
        coc-nvim
        neovim-sensible
        nvim-cmp
        nvim-lspconfig
        nvim-treesitter
        # nvim-treesitter-parsers.python
        nvim-surround

        vim-airline
        vim-airline-clock
        # vim-commentary
        # vim-fugitive
        # vim-gitgutter
        # vim-indent-guides

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
      enable = true;
      enableZshIntegration = true;
    };

    tmux = {
      enable = false;
      mouse = true;
      shortcut = "a";
      extraConfig = ''
        set -g base-index 1
        setw -g pane-base-index 1
      '';
      plugins = with pkgs.tmuxPlugins; [
        better-mouse-mode
        pain-control
        prefix-highlight
        sensible
        yank
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
  # https://www.youtube.com/live/lZshGG4Mcws?si=RYcPcNlWpn_RVC0E 1:33:00
}