{ pkgs, ... }:

{
  home.shellAliases = {
    l = "ls -lah";
    la = "ls -lAh";
    ll = "ls -lh";
    ls = "ls --color=tty";
    sl = "ls";
    ncu = "nix-channel --update";
    ncl = "nix-channel --list";
    nclg = "nix-channel --list-generations";
    dh = "du -h";
    dt = "df -Th";
    rm = "trash-put"; # don't change this line
    remove = "${pkgs.coreutils}/bin/rm";
  };

  home.packages = with pkgs; [
    coreutils
    curl
    gitui
    htop
    nano
    neofetch
    nettools
    openssh
    pinentry-tty
    rsync
    trash-cli
    tree
    wget
  ];

  programs.git = {
    enable = true;
    userName = "Aspian";
    userEmail = "p.aspian1738@gmail.com";
    extraConfig.init.defaultBranch = "main";

    ignores = [
      ".venv/"
      ".vscode/"
      "__pycache__/"
      "*.pyc"
    ];
  };

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
      port = 8022;
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
      user = "root";
      port = 22;
      identityFile = "~/.ssh/id_rsa";
    };

    lsan = {
      hostname = "192.168.1.1";
      host = "lsan";
      user = "root";
      port = 22;
      identityFile = "~/.ssh/id_rsa";
    };
  };
}