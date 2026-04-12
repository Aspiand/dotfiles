{ pkgs, ... }:

{
  services = {
    displayManager.defaultSession = "hyprland";

    greetd = {
      enable = true;
      settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
    };
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };
}
