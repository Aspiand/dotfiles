{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kitty
    wofi
  ];

  programs.hyprland = {
    enable = true;
    withUWSM = false; #
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
  };

  home-manager.users.ao = {
    wayland.windowManager.hyprland = {
      enable = false;
      xwayland.enable = true;
    };
  };
}
