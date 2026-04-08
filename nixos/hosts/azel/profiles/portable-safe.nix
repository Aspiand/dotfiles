{ pkgs, ... }:

{
  environment.variables = {
    EDITOR = "micro";
    VISUAL = "micro";
  };

  environment.systemPackages = with pkgs; [
    btrfs-progs
    cryptsetup
    git
    home-manager
    micro
    tmux
  ];
}
