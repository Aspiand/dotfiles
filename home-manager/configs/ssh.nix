{ lib, ... }:

{
  programs.ssh = {
    enable = lib.mkDefault true;
    enableDefaultConfig = false;

    matchBlocks = {
      self = {
        hostname = "agarta";
        port = 23231;
        identityFile = [
          "~/.ssh/id_ed25519"
        ];
      };

      github = {
        hostname = "github.com";
        user = "git";
        forwardAgent = true;
        identityFile = [
          "~/.ssh/id_ed25519"
        ];
      };
    };
  };
}
