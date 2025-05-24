{ config, lib, ... }:

with lib;
let
  cfg = config.programs;
in

{
  imports = [
    ./bash.nix
    ./clamav.nix
    ./mycli.nix
    ./micro.nix
    ./mysql.nix
    ./neovim.nix
    ./password-store.nix
    ./tmux.nix
    ./starship.nix
    ./sshd.nix
    ./yt-dlp.nix

    ./librewolf.nix
    ./zsh.nix
  ];

  options = {
    programs = {
      ssh.control = mkEnableOption "SSH Control";
    };
  };

  config = mkMerge [
    (mkIf cfg.ssh.enable {
      home.activation.sshSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ -d "$HOME/.ssh" ]; then
          find "$HOME/.ssh" -type d -not -perm "700" -exec chmod -v 700 {} \;
          find "$HOME/.ssh" -type f -not -perm "600" -exec chmod -v 600 {} \;
        fi
      '';
    })

    (mkIf cfg.ssh.control {
      programs.ssh = {
        controlMaster = "auto";
        controlPersist = "30m";
        controlPath = "~/.ssh/control/%r@%n:%p";
      };
    })
  ];
}
