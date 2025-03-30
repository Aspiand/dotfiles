{ config, pkgs, lib, ... }:

{
  imports = [
    ../config/default.nix
    ../modules/default.nix
  ];

  home.shellAliases = {
    durl = "curl -O --progress-bar";
    l = "ls -lh";
    la = "ls -lAh --octal-permissions";
    ld = "ls --only-dirs";
    ll = "ls -lh --total-size";
    ncu = "nix-channel --update";
    ncl = "nix-channel --list";
    nclg = "nix-channel --list-generations";
    rm = "${pkgs.trash-cli}/bin/trash-put"; # don't change this line
    remove = "${pkgs.coreutils}/bin/rm";
    tree = "${pkgs.eza}/bin/eza --tree";
  };

  home.packages = with pkgs; [
    # Archive
    unzip
    gnutar
    gzip
    xz
    zip

    # CLI
    bat
    coreutils
    gitui
    nano
    ncdu
    rsync
    trash-cli

    # Network
    aria2
    curl
    wget
    sshfs
  ];

  programs = with lib; {
    gpg.homedir = mkDefault "${config.xdg.dataHome}/gnupg";
    password-store.enable = mkDefault true;
    home-manager.enable = true;

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
      enableBashIntegration = true;
      tmux.enableShellIntegration = true;
      defaultOptions = [
        "--border"
        "--height 100%"
      ];
    };

    git = {
      enable = mkDefault true;
      userName = "Aspian";
      userEmail = "p.aspian1738@gmail.com";

      extraConfig = {
        pull.rebase = true;
        init.defaultBranch = "main";

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
          diffFilter = "${pkgs.delta}/bin/delta --color-only";
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
      matchBlocks.github = {
        host = "github.com";
        user = "git";
        forwardAgent = true;
        identityFile = [
          "~/.ssh/id_rsa"
          "~/.ssh/id_ed25519"
        ];
      };
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      options = [];
    };
  };
}