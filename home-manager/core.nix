{ pkgs, ... }:

{
  home.shellAliases = {
    sl = "ls";
    ncu = "nix-channel --update";
    ncl = "nix-channel --list";
    nclg = "nix-channel --list-generations";
  };

  home.packages = with pkgs; [
    coreutils
    curl
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