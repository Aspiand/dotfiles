{ config, pkgs, ... }:

{
  imports = [ ./core.nix ];

  nix.package = pkgs.nix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  shell = {
    zsh.enable = true;
    bash.enable = true;
  };

  fonts.fontconfig.enable = true;

  home = {
    username = "aspian";
    homeDirectory = "/home/${config.home.username}";
    stateVersion = "25.05";

    shellAliases = {
      hmbs = "home-manager build switch";
      hmg = "home-manager generations";
    };

    sessionVariables = {
      DOCKER_HOST = "unix:///var/run/podman/podman.sock";
    };

    file = {
      ".local/share/applications/obsidian.desktop".text = ''
        [Desktop Entry]
        Categories=Office
        Comment=Knowledge base
        Exec=${config.home.homeDirectory}/.nix-profile/bin/obsidian %u
        Icon=obsidian
        MimeType=x-scheme-handler/obsidian
        Name=Obsidian
        Type=Application
        Version=1.4
      '';
      ".local/share/icons/candy-icons".source = "${pkgs.candy-icons}/share/icons/candy-icons";
    };

    packages = with pkgs; [
      nerd-fonts._0xproto
      nerd-fonts.caskaydia-cove
      candy-icons

      # Network
      dnsutils
      # i2pd
      # ipcalc
      # ngrok
      nmap
      speedtest-cli
      # tor
      # torsocks

      # Programming
      nodejs
      jdk_headless
      jre_headless
      php84
      phpPackages.composer
      phpExtensions.pdo
      phpExtensions.sqlite3
      phpExtensions.pdo_mysql
      phpExtensions.pdo_sqlite
      python313
      python313Packages.pip
      python313Packages.virtualenv

      # Utils
      android-tools
      # caddy
      distrobox
      duf
      # glow
      gnumake
      # ioping
      immich-cli
      # mkp224o
      obsidian
      # qemu
      # scrcpy
      # wavemon
      # zenith
      tor-browser

      android-studio
      vscode
    ];
  };

  programs = {
    git.extraConfig.core.editor = "${pkgs.vscode}/bin/code --wait";

    clamav.enable = true;
    mycli.enable = true;
    neovim.enable = true;
    ssh.control = true;
    tmux.enable = true;
    yt-dlp.enable = true;
    yt-dlp.downloader = "aria2c";

    librewolf.enable = true;

    bash.bashrcExtra = ''
      [ -f ~/.profile ] && source ~/.profile

      case "$TERM" in
          xterm-color|*-256color) color_prompt=yes;;
      esac

      if [ -n "$force_color_prompt" ]; then
          if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
              color_prompt=yes
          else
              color_prompt=
          fi
      fi

      if [ -x "$(command -v dircolors)" ]; then
          test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
          alias ls='ls --color=auto'

          alias grep='grep --color=auto'
          alias fgrep='fgrep --color=auto'
          alias egrep='egrep --color=auto'
      fi

      if ! shopt -oq posix; then
        if [ -f /usr/share/bash-completion/bash_completion ]; then
          . /usr/share/bash-completion/bash_completion
        elif [ -f /etc/bash_completion ]; then
          . /etc/bash_completion
        fi
      fi
    '';
  };
}