{ config, pkgs, ... }:

{
  imports = [
    ../modules/init.nix
    ../core.nix
  ];

  nixpkgs.config.allowUnfree = true;

  shell.bash.enable = true;

  home = {
    username = "kuro";
    homeDirectory = "/home/kuro";
    stateVersion = "25.05";

    shellAliases = {
      hmbs = "home-manager build switch";
      hmg = "home-manager generations";
      sql = "PYTHONWARNINGS='ignore' mycli mysql://root:'root'@localhost/";
    };

    sessionVariables = {
      MYCLI_HISTFILE = "~/.local/share/mycli/history.txt";
    };

    file.".myclirc".source = ../../.myclirc;

    packages = with pkgs; [
      # Browser
      firefox
      tor-browser

      # Editor
      android-studio
      vscode
      
      # Network
      # ngrok
      nmap
      # tor
      # torsocks

      # Programming
      nodejs
      jdk_headless
      jre_headless
      php84
      frankenphp
      phpPackages.composer
      phpExtensions.pdo
      phpExtensions.sqlite3
      phpExtensions.pdo_mysql
      phpExtensions.pdo_sqlite
      python312
      python312Packages.pip
      python312Packages.virtualenv

      # Utils
      android-tools
      # caddy
      distrobox
      duf
      mycli
      mkp224o
      neofetch
      nix-bash-completions
      # ollama
      # qemu
      xfce.xfce4-terminal

      # Rofi https://github.com/adi1090x/rofi
      maim
      calc
    ];
  };

  programs = {
    ssh.control = true;
    home-manager.enable = true;
    git.extraConfig.core.editor = "nvim";
    git.extraConfig.delta = {
      hyperlinks = true;
      hyperlinks-file-link-format = "vscode://file/{path}:{line}";
    };

    utils = {
      general = true;
      clamav.enable = true;
      neovim.enable = true;
      pass.enable = true;
      tmux.enable = true;
      yt-dlp.downloader = "aria2c";
    };
  };

  services.podman = {
    enable = true;
    autoUpdate.enable = true;
  };
}