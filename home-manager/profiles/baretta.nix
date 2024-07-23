{ config, pkgs, ... }:

{
  imports = [
    ../../private/home-manager/private.nix

    ../modules/init.nix
    ../core.nix
  ];

  shell.bash.enable = true;
  shell.zsh.enable = true;

  home = {
    username = "aspian";
    homeDirectory = "/home/${config.home.username}";
    stateVersion = "24.11";

    shellAliases = {
      code = "codium";
      hmbs = "home-manager build switch";
      hmg = "home-manager generations";
      rm = "trash-put";
    };

    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FantasqueSansMono" "0xProto" ]; })

      # Archive
      bzip2
      bzip3
      gzip
      unrar
      unzip
      gnutar
      xz
      zip
      zstd

      # Database
      sqlite
      mysql

      # Files
      bat
      ffmpeg

      # Monitor
      bottom
      # gotop
      # iftop
      # iotop
      # nyx

      # Network
      aria2
      dnsutils
      ngrok
      nmap
      speedtest-cli
      tor
      torsocks

      # Programming
      nodejs
      jdk_headless
      jre_headless
      php
      phpPackages.composer
      # python3
      # python3Packages.pip
      # python3Packages.virtualenv
      # python3Packages.face-recognition
      # python3Packages.insightface
      podman-compose

      # Security
      steghide

      # System
      clamav
      gnumake
      scrcpy

      # Other
      ollama
    ];

    sessionVariables = {
      GNUPGHOME = "${config.home.homeDirectory}/.local/data/gnupg.old";
    };
  };

  programs.home-manager.enable = true;
  programs.git.extraConfig.core.editor = "code --wait";

  programs = {
    password-store = {
      enable = true;
      settings = {
        PASSWORD_STORE_CLIP_TIME = "120";
        PASSWORD_STORE_GENERATED_LENGTH = "30";
        PASSWORD_STORE_DIR = "$HOME/.local/data/password_store/";
      };
    };
  };

  editor.neovim.enable = true;
  editor.vscode.enable = true;

  utils = {
    ffm.enable = true;
    fzf.enable = true;
    gpg.enable = true;
    starship.enable = true;
    ssh.enable = true;
    tmux.enable = true;
    yt-dlp.enable = true;
    yt-dlp.path = "${config.home.homeDirectory}/Downloads/";
    zoxide.enable = true;
  };
}
