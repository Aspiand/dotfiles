{ config, pkgs, ... }:

{
  home.packages = [
    (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" "0xProto" ]; })

    # Archive
    pkgs.bzip2
    pkgs.bzip3
    pkgs.gzip
    pkgs.unrar
    pkgs.unzip
    pkgs.gnutar
    pkgs.xz
    pkgs.zip
    pkgs.zstd

    # Database
    pkgs.sqlite

    # Files
    pkgs.bat
    pkgs.ffmpeg
    pkgs.rsync
    pkgs.trash-cli
    pkgs.tree

    # Monitor
    pkgs.bottom
    # pkgs.gotop
    pkgs.htop
    # pkgs.iftop
    # pkgs.iotop
    # pkgs.nyx

    # Network
    pkgs.aria2
    pkgs.curl
    pkgs.dnsutils
    pkgs.nettools
    pkgs.ngrok
    pkgs.nmap
    pkgs.onionshare
    pkgs.proxychains
    pkgs.speedtest-cli
    pkgs.tor
    pkgs.wget

    # Programming
    pkgs.nodejs
    pkgs.jdk_headless
    pkgs.jre_headless
    pkgs.php
    pkgs.phpPackages.composer
    pkgs.python312
    # pkgs.python312Packages.face-recognition
    # pkgs.python312Packages.insightface
    pkgs.python312Packages.pip
    pkgs.python312Packages.virtualenv
    pkgs.podman-compose

    # Security
    # pkgs.gnupg
    # pkgs.pass
    pkgs.steghide

    # System
    pkgs.android-tools
    pkgs.clamav
    pkgs.coreutils
    pkgs.gnumake
    # pkgs.media-downloader
    pkgs.neofetch
    pkgs.onioncircuits
    pkgs.ollama
    pkgs.scrcpy
    pkgs.usbutils
    pkgs.xorg.xrandr
  ];

  programs = {
    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      tmux.enableShellIntegration = true;
      defaultOptions = [
        "--border"
        "--height 60%"
      ];
    };

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

    yt-dlp = {
      enable = true;
      settings = {
        output = "%(title)s.%(ext)s";

        embed-chapters = true;
        embed-metadata = true;
        embed-subs = true;
        embed-thumbnail = true;

        format = "bestvideo*+bestaudio/best";
        merge-output-format = "mkv";

        downloader = "aria2c";
        downloader-args = "aria2c:'-x16 -s16 -c'";
      };

      extraConfig = "--sub-langs all,-live_chat";
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
  };
}