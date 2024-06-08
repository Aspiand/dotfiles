{ config, pkgs, ... }:

let
  USER = builtins.getEnv "USER";
in

{
  # nixpkgs.config.allowUnfree = true;

  home = {
    username = USER;
    homeDirectory = "/home/${USER}";

    stateVersion = "23.11";

    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages = [
      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
      
      # Programming Language
      pkgs.python3
      pkgs.python3Packages.pip

      # Tool
      # pkgs.aria2
      pkgs.bottom
      # pkgs.curl
      pkgs.htop
      pkgs.neofetch
      # pkgs.pass
      pkgs.tree
      pkgs.rsync
      pkgs.speedtest-cli
      pkgs.wget
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
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
    };
  };

  programs = {
    home-manager.enable = true;

    # Programming Language
    java.enable = false;

    # Tool
    neovim.enable = true;
    # ssh.enable = true;

    git = {
      enable = true;
      userName = "Aspian";
      extraConfig = {
        init.defaultBranch = "main";
      };
    };

    tmux = {
      enable = true;
      extraConfig = ''
        set -g prefix C-a
        set -g base-index 1
        set -g mouse on
        setw -g pane-base-index 1
      '';
    };

    zsh = {
      enable = false;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
      };

      history = {
        ignoreDups = true;
        extended = true;
        path = "${config.home.homeDirectory}/.local/zsh_history";
        save = -1;
        size = -1;
      };
    };
  };
}