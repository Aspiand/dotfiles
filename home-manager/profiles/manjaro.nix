{ config, pkgs, ... }:

{
  imports = [ ./core.nix ];

  fonts.fontconfig.enable = true;
  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  home = {
    username = "kuro";
    homeDirectory = "/home/kuro";
    stateVersion = "25.05";

    shellAliases = {
      hmbs = "home-manager build switch";
      hmg = "home-manager generations";
      pc = "podman-compose";
      pps = "podman ps";
      podman-sock = "podman system service --time=0 unix://$XDG_RUNTIME_DIR/podman/podman.sock";
    };

    sessionVariables = {
      DOCKER_HOST = "unix:///$($XDG_RUNTIME_DIR)/podman.sock";
    };

    file = {
      ".local/share/icons/candy-icons".source = "${pkgs.candy-icons}/share/icons/candy-icons";
      ".config/i3/config".source = ../../manjaro/i3/config;
    };

    packages = with pkgs; [
      #
      nerd-fonts._0xproto
      nerd-fonts.caskaydia-cove
      candy-icons

      # Archive
      bzip2
      bzip3
      unrar
      zstd

      # Browser
      firefox
      tor-browser

      # Editor
      android-studio
      netbeans
      obsidian
      vscode

      # Network
      # ngrok
      nmap
      # sqlmap
      tor
      torsocks

      # Programming
      nodejs
      jdk_headless
      jre_headless
      mysql_jdbc
      php84
      # frankenphp
      php84Packages.composer
      # phpExtensions.pdo
      # phpExtensions.sqlite3
      # phpExtensions.pdo_mysql
      # phpExtensions.pdo_sqlite
      python312
      python312Packages.pip
      python312Packages.virtualenv

      # Utils
      android-tools
      # caddy
      distrobox
      duf
      exiftool
      # immich-cli
      # immich-go
      # mkp224o
      neofetch
      nix-bash-completions
      # ollama
      # qemu
      podman-compose

      ###
      rofi
      polybar
      xfce.xfce4-terminal
      maim
      calc
      vlc
      podman-tui
    ];
  };

  programs = {
    git.extraConfig.core.editor = "${pkgs.vscode}/bin/code --wait";

    bash.enable = true;
    clamav.enable = true;
    gpg.enable = true;
    mycli.enable = true;
    # mysql.enable = true;
    neovim.enable = true;
    ssh.control = true;
    tmux.enable = true;
    yt-dlp.enable = true;
    yt-dlp.downloader = "aria2c";
  };

  services = {
    podman.enable = true;

    home-manager.autoExpire = {
      enable = true;
      frequency = "weekly";
    };

    gpg-agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-tty;
    };
  };
}
