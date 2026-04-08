{ pkgs, ... }:

{
  specialisation.recovery.configuration = {
    system.nixos.tags = [ "recovery" ];

    services = {
      displayManager.defaultSession = null;
      greetd.enable = false;
    };

    programs.hyprland.enable = false;

    xdg.portal = {
      enable = false;
      extraPortals = [ ];
    };

    environment = {
      sessionVariables = {
        NIXOS_OZONE_WL = "0";
      };

      systemPackages = with pkgs; [
        rsync
        tmux
      ];
    };
  };
}
