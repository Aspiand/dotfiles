{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    programs = {
      ssh.control = mkEnableOption "SSH Control";

      yt-dlp = {
        path = mkOption {
          type = types.str;
          default = "${config.home.homeDirectory}/Downloads/";
          description = "The paths where the files should be downloaded";
        };

        downloader = mkOption {
          type = with types; nullOr str;
          default = null;
        };
      };
    };

    shell.nix-path = mkOption {
      type = types.path;
      default = "${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh";
      example = "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh";
    };
  };

  config = let
    cfg = config.programs;
  in mkMerge [

    (mkIf cfg.ssh.control {
      programs.ssh = {
        controlMaster = "auto";
        controlPersist = "30m";
        controlPath = "~/.ssh/control/%r@%n:%p";
      };
    })

    # Shell
    (let path = config.shell.nix-path; in {
      programs.bash.bashrcExtra = ''
        source ${path}
      '';

      programs.zsh.initExtraFirst = mkIf cfg.zsh.enable ''
        source ${path}
      '';
    })

    # Password Store
    (mkIf cfg.password-store.enable {
      programs.password-store.settings = {
        PASSWORD_STORE_CLIP_TIME = "120";
        PASSWORD_STORE_GENERATED_LENGTH = "12";
        PASSWORD_STORE_DIR = "${config.xdg.dataHome}/password_store";
      };

      home.activation.passSetup = let
        pass_dir = cfg.password-store.settings.PASSWORD_STORE_DIR;
      in lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ -d '${pass_dir}' ]; then
          find ${pass_dir} -type d -not -perm "700" -exec chmod -v 700 {} \;
          find ${pass_dir} -type f -not -perm "600" -exec chmod -v 600 {} \;
        fi
      '';
    })

    (mkIf cfg.ssh.enable {
      home.activation.sshSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ -d "$HOME/.ssh" ]; then
          find "$HOME/.ssh" -type d -not -perm "700" -exec chmod -v 700 {} \;
          find "$HOME/.ssh" -type f -not -perm "600" -exec chmod -v 600 {} \;
        fi
      '';
    })

    (mkIf true {
      home.packages = with pkgs; [
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

        # Monitor
        bottom
        gotop
        # nyx

        # Multimedia
        # exiftool
        ffmpeg

        # Network
        aria2
        sshfs
        wget

        # Utils
        bat
        gitui
        ncdu
      ];
    })

    # General
    {
      programs = {
        eza = {
          git = true;
          icons = "always";
          enableZshIntegration = true;
          enableBashIntegration = true;
          extraOptions = [
            "--group"
            "--group-directories-first"
            "--mounts"
            "--no-quotes"
          ];
        };

        fzf = {
          enableZshIntegration = true;
          enableBashIntegration = true;
          tmux.enableShellIntegration = true;
          defaultOptions = [
            "--border"
            "--height 100%"
          ];

          tmux.shellIntegrationOptions = [];
        };

        yazi = {
          enableBashIntegration = true;
          enableZshIntegration = true;
          settings = {
            log.enable = true;
            manager = {
              show_hidden = true;
              sort_by = "alphabetical";
              sort_dir_first = true;
              sort_reverse = false;
              show_symlink = true;
            };
          };
        };

        yt-dlp = {
          settings = mkMerge [
            {
              paths = cfg.yt-dlp.path;
              output = "%(title)s.%(ext)s";

              embed-chapters = true;
              embed-metadata = true;
              embed-subs = true;
              embed-thumbnail = true;

              format = "bestvideo*+bestaudio/best";
              merge-output-format = "mkv/mp4";
            }

            (mkIf (cfg.yt-dlp.downloader == "aria2c") {
              downloader = "aria2c";
              downloader-args = "aria2c:'-x8 -s8 -c'";
            })

            (mkIf (cfg.yt-dlp.downloader == "wget") {
              downloader = "wget";
              downloader-args = "wget:'--retry-connrefused --continue'";
            })
          ];

          extraConfig = ''
            --sub-langs all,-live_chat
          '';
        };

        zoxide = {
          enableBashIntegration = true;
          enableZshIntegration = true;
        };
      };
    }
  ];
}