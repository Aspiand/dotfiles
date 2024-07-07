{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.utils.yt-dlp;
in

{
  options.utils.yt-dlp = {
    enable = mkEnableOption "yt-dlp";
    path = mkOption {
      type = types.str;
      default = "$HOME/Downloads";
      description = "The paths where the files should be downloaded";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.aria2 ];

    programs.yt-dlp = {
      enable = true;
      settings = {
        paths = cfg.path;
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
  };
}