{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kitty
  ];

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
  };

  programs = {
    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };
  };
}