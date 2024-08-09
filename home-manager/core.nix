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

    # includes = [];
  };
}
