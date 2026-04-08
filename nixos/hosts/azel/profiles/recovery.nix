{ lib, pkgs, ... }:

{
  specialisation.recovery.configuration = {
    system.nixos.tags = [ "recovery" ];

    services = {
      displayManager.defaultSession = lib.mkForce null;
      greetd.enable = lib.mkForce false;
    };

    programs.hyprland = {
      enable = lib.mkForce false;
      xwayland.enable = lib.mkForce false;
    };

    xdg.portal = {
      enable = lib.mkForce false;
      extraPortals = lib.mkForce [ ];
    };

    environment = {
      sessionVariables = {
        NIXOS_OZONE_WL = lib.mkForce "0";
      };

      systemPackages = with pkgs; [
        rsync
        tmux
      ];
    };
  };
}
