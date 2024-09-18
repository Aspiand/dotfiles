{ pkgs, ... }:

{
  home.shellAliases = {
    l = "ls -lah";
    la = "ls -lAh";
    ll = "ls -lh";
    ncu = "nix-channel --update";
    ncl = "nix-channel --list";
    nclg = "nix-channel --list-generations";
    dh = "du -h";
    dt = "df -Th";
    rm = "${pkgs.trash-cli}/bin/trash-put"; # don't change this line
    remove = "${pkgs.coreutils}/bin/rm";
  };

  home.packages = with pkgs; [
    coreutils
    curl
    gnupg
    htop
    nano
    neofetch
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
    extraConfig.core.fileMode = true;

    ignores = [
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