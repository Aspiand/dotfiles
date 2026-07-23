{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ ./minimal.nix ];

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  programs.dconf.enable = true;

  microvm.graphics.enable = true;

  environment.gnome.excludePackages = with pkgs; [ ];

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
}
