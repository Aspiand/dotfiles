{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [ ./modules/default.nix ];

  home = {
    shellAliases = {
      durl = "curl -O --progress-bar";
      l = "ls -lh";
      la = "ls -lAh --octal-permissions";
      ld = "ls --only-dirs";
      ll = "ls -lh --total-size";
      nano = "micro";
      ncu = "nix-channel --update";
      ncl = "nix-channel --list";
      nclg = "nix-channel --list-generations";
      news = "${pkgs.home-manager}/bin/home-manager news";
      rm = "${pkgs.trash-cli}/bin/trash-put"; # don't change this line
      remove = "${pkgs.coreutils}/bin/rm";
      tree = "${pkgs.eza}/bin/eza --tree";
    };

    sessionVariables = {
      EDITOR = "${pkgs.micro}/bin/micro";
    };
  };

  home.packages = with pkgs; [
    # Archive
    unzip
    gnutar
    gzip
    xz
    zip

    # Network
    aria2
    curl
    wget
    sshfs

    # Utils
    bat
    coreutils
    gitui
    ncdu
    rsync
    trash-cli
  ];

  programs = with lib; {
    gpg.homedir = mkDefault "${config.xdg.dataHome}/gnupg";
    home-manager.enable = true;
    micro.enable = mkDefault true;
    password-store.enable = mkDefault false;

    eza = {
      enable = mkDefault true;
      git = true;
      icons = "always";
      enableBashIntegration = true;
      extraOptions = [
        "--git-repos"
        "--group"
        "--group-directories-first"
        "--mounts"
        "--no-quotes"
      ];
    };

    fzf = {
      enable = mkDefault true;
      enableBashIntegration = mkDefault true;
      tmux.enableShellIntegration = mkDefault true;
      defaultOptions = [
        "--border"
        "--height 100%"
        "--multi"
      ];
    };

    git = {
      enable = mkDefault true;
      settings = {
      	pull.rebase = true;
      	init.defaultBranch = "main";
        user = {
          name = "Aspian";
          email = "muhammad.aspian.d@gmail.com";
        };
        core = {
          fileMode = mkDefault true;
          pager = "${pkgs.delta}/bin/delta";
        };
        delta = {
          enable = mkDefault true;
          line-numbers = true;
          side-by-side = false;
        };
        interactive = {
          diffFilter = mkIf config.programs.git.settings.delta.enable "${pkgs.delta}/bin/delta --color-only";
        };
      };
      ignores = [
        "tmp/"
        "vendor/"
        "node_modules/"
        ".venv/"
        ".vscode/"
        "__pycache__/"
        "*.pyc"
      ];
    };

    ssh = {
      enable = mkDefault true;
      enableDefaultConfig = false;
      matchBlocks = {
        self = {
          hostname = "agarta";
          port = 23231;
          identityFile = [
            "~/.ssh/id_ed25519"
          ];
        };
        github = {
          hostname = "github.com";
          user = "git";
          forwardAgent = true;
          identityFile = [
            "~/.ssh/id_ed25519"
          ];
        };
      };
    };

    zoxide = {
      enable = mkDefault true;
      enableBashIntegration = true;
      options = [ ];
    };
  };
}
