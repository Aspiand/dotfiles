{ inputs, pkgs, ... }:

{
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];

  home = {
    username = "aka";
    homeDirectory = "/home/aka";
    stateVersion = "26.05";

    packages = with pkgs; [
      foot
      wofi
      wl-clipboard
    ];
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    settings = {
      "$mod" = "SUPER";

      monitor = ",preferred,auto,1";
      exec-once = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      ];

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad.natural_scroll = false;
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        layout = "dwindle";
      };

      decoration = {
        rounding = 8;
        blur.enabled = false;
      };

      bind = [
        "$mod, Return, exec, foot"
        "$mod, Q, killactive,"
        "$mod, E, exec, wofi --show drun"
        "$mod, F, fullscreen,"
        "$mod, V, togglefloating,"
        "$mod SHIFT, E, exit,"
      ];
    };
  };

  programs.caelestia = {
    enable = true;
    cli.enable = true;
  };
}
