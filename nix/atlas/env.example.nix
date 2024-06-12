{
  yt_dest = "/home/kuro/Videos/YouTube/";

  ngrok.config = ''
    #~/.config/ngrok/ngrok.yml

    version: "2"
    authtoken: My123Token

    tunnels:
      koneksi-php:
        proto: http
        addr: 8000
  '';


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