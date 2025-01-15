{ pkgs, ... }:

{
  home.shellAliases = {
    dh = "du -h";
    dt = "df -Th";
    durl = "curl -O --progress-bar";
    l = "ls -lah";
    la = "ls -lAh";
    ll = "ls -lh";
    ncu = "nix-channel --update";
    ncl = "nix-channel --list";
    nclg = "nix-channel --list-generations";
    rm = "${pkgs.trash-cli}/bin/trash-put"; # don't change this line
    remove = "${pkgs.coreutils}/bin/rm";
  };

  home.packages = with pkgs; [
    coreutils
    curl
    nano
    rsync
    trash-cli
    tree
  ];

  programs.git = {
    enable = true;
    userName = "Aspian";
    userEmail = "p.aspian1738@gmail.com";
    delta.enable = true;

    extraConfig = {
      pull.rebase = true;
      init.defaultBranch = "main";

      core = {
        fileMode = true;
        pager = "${pkgs.delta}/bin/delta";
      };

      delta = {
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

  programs.ssh.enable = true;
  programs.ssh.matchBlocks = {
    github = {
      host = "github.com";
      user = "git";
      forwardAgent = true;
      identityFile = [
        "~/.ssh/id_rsa"
        "~/.ssh/id_ed25519"
      ];
    };

    # dalet = {
    #   hostname = "192.168.100.2";
    #   host = "dalet";
    #   user = "u0_a251";
    #   port = 2222;
    #   identityFile = "~/.ssh/id_rsa";
    # };

    # nix-dalet = {
    #   hostname = "192.168.100.2";
    #   host = "dnod";
    #   user = "nix-on-droid";
    #   port = 3022;
    #   identityFile = "~/.ssh/id_rsa";
    # };
  };
}