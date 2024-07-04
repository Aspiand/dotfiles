{ config, pkgs }:

{
  home.packages = [
    # Files
    pkgs.rsync
    pkgs.trash-cli
    pkgs.tree

    # Monitor
    pkgs.htop

    # Network
    pkgs.curl
    pkgs.wget

    # System
    pkgs.coreutils
    pkgs.neofetch
    pkgs.usbutils
  ];

  programs = {
    git = {
      enable = true;
      userName = "Aspian";
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
  }
}