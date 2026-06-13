{ lib, ... }:

{
  programs.ssh = {
    enable = lib.mkDefault true;
    enableDefaultConfig = false;

    settings = {
      dalet = {
        HostName = "192.168.7.6";
        User = "nix-on-droid";
        Port = 3022;
        IdentityFile = [ "~/.ssh/id_ed25519" ];
      };

      self = {
        HostName = "agarta";
        Port = 23231;
        IdentityFile = [ "~/.ssh/id_ed25519" ];
      };

      github = {
        HostName = "github.com";
        User = "git";
        ForwardAgent = true;
        IdentityFile = [ "~/.ssh/id_ed25519" ];
      };
    };
  };
}
