{ pkgs, ... }:

{
  home.shellAliases = {
    rm = "trash-put";
    sl = "ls";
  };

  home.packages = with pkgs; [
    coreutils
    curl
    htop
    nano
    neofetch
    nettools
    openssh
    rsync
    trash-cli
    tree
    wget
  ];

  programs = {
    git = {
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

    ssh = {
      enable = true;
      controlMaster = "auto";
      controlPersist = "30m";
      controlPath = "~/.ssh/control/%r@%n:%p";
      # programs.ssh.addKeysToAgent = [];
    };
  };
}