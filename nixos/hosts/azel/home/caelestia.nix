{ inputs, pkgs, ... }:

{
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    hyprland
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    hyprpicker
    wl-clipboard
    cliphist
    inotify-tools
    app2unit
    wireplumber
    trash-cli
    foot
    fish
    fastfetch
    starship
    btop
    jq
    eza
    adw-gtk3
    papirus-icon-theme
    # libsForQt5.qt5.qtwebengine
    kdePackages.qtwebengine
    nerd-fonts.jetbrains-mono
    awww
  ];

  programs.caelestia = {
    enable = true;
    cli.enable = true;
  };
}
