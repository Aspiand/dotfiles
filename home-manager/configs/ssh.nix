{ lib, ... }:

{
  programs.ssh = {
    enable = lib.mkDefault true;
    enableDefaultConfig = false;

    matchBlocks = {
      dalet = {
        hostname = "192.168.7.6";
        user = "nix-on-droid";
        port = 3022;
        identityFile = [
          "~/.ssh/id_ed25519"
        ];
      };

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
