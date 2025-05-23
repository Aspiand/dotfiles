{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [ ./modules/default.nix ];

  home.shellAliases = {
    df = "${pkgs.duf}/bin/duf";
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
    password-store.enable = mkDefault true;

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
      userEmail = "muhammad.aspian.d@gmail.com";

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
          diffFilter = mkIf config.programs.git.extraConfig.delta.enable "${pkgs.delta}/bin/delta --color-only";
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
      enable = mkDefault true;
      enableBashIntegration = true;
      options = [ ];
    };
  };
}
