{
  yt_dest = "/home/kuro/Videos/YouTube/";

  ssh.matchBlocks = {
    termux = {
      hostname = "10.10.1.2";
      host = "mytermux";
      user = "kuro";
      port = 23;
      identityFile = "~/.ssh/kuro";

      # $ ssh mytermux
    };

    github = {
      host = "github.com";
      user = "git";
      forwardAgent = true;
      identityFile = "~/.ssh/github";
    };
  };
}