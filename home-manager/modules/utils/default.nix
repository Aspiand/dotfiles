{ config, pkgs, lib, ... }:

with lib; let cfg = config.programs.utils; in

{
  imports = [
    ./clamav.nix
    ./tmux.nix
  ];

  options.programs.utils = {
    additional = mkEnableOption "Additional package";

    gnupg = {
      enable = mkEnableOption "GnuPG";
      dir = mkOption {
        type = types.str;
        default = "${config.home.homeDirectory}/.local/data/gnupg";
        example = "${config.home.homeDirectory}/.gnupg";
      };
    };

    pass = {
      enable = mkEnableOption "password-store";
      dir = mkOption {
        type = types.str;
        default = "$HOME/.local/share/password_store/";
      };
    };

    yt-dlp = {
      enable = mkEnableOption "yt-dlp";
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

  config = mkMerge [

    (mkIf cfg.additional {
      home.shellAliases.ls = "eza";

      home.packages = with pkgs; mkMerge [
        ## ffm
        [ (pkgs.writeShellScriptBin "ffm" (builtins.readFile ../../../sh/ffm.sh)) ]
        ## https://discourse.nixos.org/t/link-scripts-to-bin-home-manager/41774

        [
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

          # Network
          aria2
          nettools
          sshfs
          wget

          # Other          
          bat
          findutils
          ffmpeg
          gitui
          gnumake
          gawk
          gnugrep
          gnused
          ncurses
          rm-improved
          steghide
          procps
          which
        ]
      ];

      programs.eza = {
        enable = true;
        git = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
        enableNushellIntegration = true;
        extraOptions = [
          "--group"
          "--group-directories-first"
          "--mounts"
          "--no-quotes"
        ];
      };

      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
        tmux.enableShellIntegration = true;
        defaultOptions = [
          "--border"
          "--height 60%"
        ];
      };

      programs.yt-dlp = {
        enable = true;
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
            downloader-args = "aria2c:'-x16 -s16 -c'";
          })

          (mkIf (cfg.yt-dlp.downloader == "wget") {
            downloader = "wget";
            downloader-args = "wget:'--retry-connrefused --continue'";
          })
        ];

        extraConfig = "--sub-langs all,-live_chat";
      };

      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
        enableNushellIntegration = true;
      };
    })

    (mkIf cfg.gnupg.enable {
      programs.gpg = {
        enable = true;
        homedir = cfg.gnupg.dir;
      };
    })

    (mkIf cfg.pass.enable {
      programs.password-store = {
        enable = true;
        settings = {
          PASSWORD_STORE_CLIP_TIME = "120";
          PASSWORD_STORE_GENERATED_LENGTH = "12";
          PASSWORD_STORE_DIR = cfg.pass.dir;
        };
      };

      home.activation.pass_setup = lib.hm.dag.entryAfter ["writeBoundary"] ''
        find ${cfg.pass.dir} -type d -not -perm "700" -exec chmod -v 700 {} \;
        find ${cfg.pass.dir} -type f -not -perm "600" -exec chmod -v 600 {} \;
      '';
    })
  ];
}