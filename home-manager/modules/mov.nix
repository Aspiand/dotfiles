# https://wiki.nixos.org/wiki/Python#
# https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/python.section.md
# https://discourse.nixos.org/t/add-python-package-via-overlay/19783/3

{ config, lib, pkgs, ...}:

with lib;

let
  cfg = config.programs.mov;
  python = pkgs.python312.override {
    # postFixup = ''
    #   rm -f $out/bin/pydoc
    # '';
    packageOverrides = python-final: python-prev: {
      mov-cli-youtube = python-final.callPackage ../packages/mov-cli-youtube.nix {};
    };
  };
in

{
  options.programs.mov = {
    enable = mkEnableOption "Mov";
    player = mkOption {
      type = types.package;
      default = pkgs.vlc;
      description = "The media player package to use for playing videos.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      cfg.player
      chafa
      # ffmpeg
      # fzf
      mov-cli
      # yt-dlp

      (python.withPackages (ps: [
        # (lib.mkForce ps.mov-cli-youtube)
        ps.mov-cli-youtube
      ]))
    ];

    home.file.".config/mov-cli/config.toml".text = ''
      # Confused?
      # Check out the WIKI on configuration: https://github.com/mov-cli/mov-cli/wiki/Configuration

      [mov-cli]
      version = 1
      debug = false
      player = "mpv"
      quality = "auto"
      # parser = "lxml"
      editor = "nano"
      skip_update_checker = false
      auto_try_next_scraper = false
      hide_ip = true

      # [mov-cli.quality]
      # resolution = 720

      [mov-cli.ui]
      fzf = true
      limit = 20
      preview = true
      watch_options = true
      display_quality = true # false

      [mov-cli.plugins] # E.g: namespace = "package-name"
      youtube = "mov-cli-youtube"
      test = "mov-cli-test"

      [mov-cli.scrapers]
      default = "youtube"
      yt = "youtube.DEFAULT"
      test = "test.DEFAULT"

      [mov-cli.http] # Don't mess with it if you don't know what you are doing!
      timeout = 15
      # headers = { User-Agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/117.0" }

      # [mov-cli.downloads] # Do not use backslashes use forward slashes
      save_path = "~/Downloads"
      yt_dlp = true

      # [mov-cli.subtitles] # See this page: https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes
      # language = "en"
    '';
  };
}