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
    htop
    nano
    openssh
    rsync
    trash-cli
    tree
  ];

  programs.git = {
    enable = true;
    delta.enable = true;
    userName = "Aspian";
    userEmail = "p.aspian1738@gmail.com";
    extraConfig = {
      core.fileMode = true;
      init.defaultBranch = "main";

      delta = {
        line-numbers = true;
        side-by-side = false;
      };
    };

    ignores = [
      "tmp/"
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
      identityFile = "~/.ssh/id_rsa";
    };

    dalet = {
      hostname = "192.168.100.2";
      host = "dalet";
      user = "u0_a251";
      port = 2222;
      identityFile = "~/.ssh/id_rsa";
    };

    nix-dalet = {
      hostname = "192.168.100.2";
      host = "dnod";
      user = "nix-on-droid";
      port = 3022;
      identityFile = "~/.ssh/id_rsa";
    };

    san = {
      hostname = "192.168.100.10";
      host = "san";
      user = "aspian";
      port = 22;
      identityFile = "~/.ssh/id_rsa";
    };

    lsan = {
      hostname = "192.168.1.1";
      host = "lsan";
      user = "aspian";
      port = 22;
      identityFile = "~/.ssh/id_rsa";
    };
  };
}