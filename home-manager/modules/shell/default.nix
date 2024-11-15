{ config, pkgs, lib, ... }:

with lib; let cfg = config.shell; in

{
  imports = [
    ./starship.nix
    ./ohmyposh.nix

    ./bash.nix
    ./nu.nix
    ./zsh.nix
  ];

  options.shell.nix-path = mkOption {
    type = types.path;
    default = "${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh";
    example = "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh";
  };

  config = {
    programs.bash.bashrcExtra = mkIf cfg.bash.enable ''
      source ${cfg.nix-path}
    '';

    programs.zsh.initExtraFirst = mkIf cfg.zsh.enable ''
      source ${cfg.nix-path}
    '';

  };
}