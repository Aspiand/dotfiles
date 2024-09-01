# https://github.com/notusknot/dotfiles-nix

{ config, pkgs, lib, ... }:

with lib; let cfg = config.programs; in

{
  imports = [
    ./browser
    ./editor
    ./shell
    ./services
    ./utils
  ];

  options.programs.ssh.control = mkEnableOption "SSH Control";

  config = mkMerge [
    (mkIf config.programs.ssh.enable {
      home.activation.ssh_setup = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -d "$HOME/.ssh" ]; then
        find "$HOME/.ssh" -type d -not -perm "700" -exec chmod -v 700 {} \;
        find "$HOME/.ssh" -type f -not -perm "600" -exec chmod -v 600 {} \;
      fi
      '';
    })

    (mkIf config.programs.ssh.control {
      programs.ssh = {
        controlMaster = "auto";
        controlPersist = "30m";
        controlPath = "~/.ssh/control/%r@%n:%p";
      };
    })
  ];
}