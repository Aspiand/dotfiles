{ config, pkgs, ... }:

{
  imports = [
    ../modules/init.nix
    ../core.nix
  ];

  # Nix Channel
  # https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  # https://nixos.org/channels/nixpkgs-unstable nixpkgs

  nix.package = pkgs.nix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  shell = {
    ohmyposh.enable = true;

    nu.enable = true;
    zsh.enable = true;
    bash.enable = true;
  };

  home = {
    username = "aspian";
    homeDirectory = "/home/${config.home.username}";
    stateVersion = "24.11";

    shellAliases = {
      hmbs = "home-manager build switch";
      hmg = "home-manager generations";
      sql = "PYTHONWARNINGS='ignore' mycli mysql://root:'uh'@localhost/tugas_dbs_aspian";
    };

    sessionVariables = {
      MYCLI_HISTFILE="~/.local/share/mycli/history.txt";
    };

    file = {
      ".myclirc".source = ../../.myclirc;
    };

    packages = with pkgs; [
      # Network
      dnsutils
      ipcalc
      ngrok
      nmap
      proxychains
      speedtest-cli
      tor
      torsocks

      # Programming
      nodejs
      jdk_headless
      jre_headless
      php
      phpPackages.composer
      phpExtensions.pdo
      phpExtensions.sqlite3
      phpExtensions.pdo_mysql
      phpExtensions.pdo_sqlite
      python3
      python3Packages.pip
      python3Packages.virtualenv
      # python3Packages.face-recognition
      # python3Packages.insightface

      # Utils
      android-tools
      dirb
      distrobox
      duf
      glow
      gnumake
      litecli
      mkp224o
      mycli
      podman-compose
      qemu
      scrcpy
      sqlite
      wavemon
      zenith
    ];
  };

  programs = {
    ssh.control = true;
    home-manager.enable = true;
    git.extraConfig.core.editor = "nvim";

    utils = {
      additional = true;
      clamav.enable = true;
      librewolf.enable = true;
      neovim.enable = true;
      pass.enable = true;
      tmux.enable = true;
      vscode.enable = true;
      yt-dlp.downloader = "aria2c";
    };
  };

  services.syncthing.enable = false;
  services.glance.enable = true;
  services.glance.settings.pages = [
    {
      name = "Home";
      columns = [
        {
          size = "small";
          widgets = [
            { type = "calendar"; }

            {
              type = "monitor";
              title = "Sites";
              cache = "10m";
              sites = [
                {
                  title = "Github";
                  url = "https://github.com/";
                }

                {
                  title = "Google";
                  url = "https://google.com/";
                }
              ];
            }
          ];
        }

        {
          size = "full";
          widgets = [
            { # https://commentpicker.com/youtube-channel-id.php
              title = "YouTube";
              type = "videos";
              channels = [
                "UCxxnxya_32jcKj4yN1_kD7A" # Muse Indonesia
                "UCUn0hEbVJc273anl_0ozDMQ" # Ani One ID
                "UCL_D8_Oqnb_Icr3zRn9pVNw" # Guru Gembul
                "UC14ZKB9XsDZbnHVmr4AmUpQ" # Programmer Zaman Now
              ];
            }

            { type = "hacker-news"; }
          ];
        }
      ];
    }

    {
      name = "Anime";
      columns = [
        {
          size = "full";
          widgets = [
            { # Muse Indonesia
              type = "videos";
              style = "grid-cards";
              title = "Muse Indonesia";
              collapse-after-rows = 1;
              channels = [ "UCxxnxya_32jcKj4yN1_kD7A" ];
            }

            { # Ani-One ID
              type = "videos";
              style = "grid-cards";
              title = "Ani-One Indonesia";
              collapse-after-rows = 1;
              channels = [ "UCUn0hEbVJc273anl_0ozDMQ" ];
            }

            { # Ani-One Asia
              type = "videos";
              style = "grid-cards";
              title = "Ani-One Asia";
              collapse-after-rows = 1;
              channels = [ "UCUn0hEbVJc273anl_0ozDMQ" ];
            }
          ];
        }
      ];
    }
  ];
  # xfconf.settings
}