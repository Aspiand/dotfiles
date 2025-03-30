{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.programs.yt-dlp;
in

{
  options.programs = {
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

  config.programs.yt-dlp = {
    settings = mkMerge [
      {
        paths = cfg.path;
        output = "%(title)s.%(ext)s";

        embed-chapters = true;
        embed-metadata = true;
        embed-subs = true;
        embed-thumbnail = true;

        format = "bestvideo*+bestaudio/best";
        merge-output-format = "mkv/mp4";
      }

      (mkIf (cfg.downloader == "aria2c") {
        downloader = "aria2c";
        downloader-args = "aria2c:'-x8 -s8 -c'";
      })

      (mkIf (cfg.downloader == "wget") {
        downloader = "wget";
        downloader-args = "wget:'--retry-connrefused --continue'";
      })
    ];

    extraConfig = ''
      --sub-langs all,-live_chat
    '';
  };
}