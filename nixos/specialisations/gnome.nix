{ pkgs, ... }:
{
  home-manager.users.ao.imports = [ ./gnome-home.nix ];

  environment.gnome.excludePackages = with pkgs; [
    geary
    gnome-tour
    gnome-user-docs
    epiphany # Browser
    gnome-text-editor
    gnome-characters
    gnome-maps
    gnome-music
    gnome-connections
    yelp
  ];

  programs.kdeconnect = {
    enable = false;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # KDE Connect
  # networking.firewall.allowedTCPPorts = [{ from = 1714; to = 1764; }];
  # networking.firewall.allowedUDPPorts = [{ from = 1714; to = 1764; }];
}
