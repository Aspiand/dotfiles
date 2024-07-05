{
  programs = {
    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      tmux.enableShellIntegration = true;
      defaultOptions = [
        "--border"
        "--height 60%"
      ];
    };

    yt-dlp = {
      enable = true;
      settings = {
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

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
  };
}