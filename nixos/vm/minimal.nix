{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  system.stateVersion = "26.05";

  networking.hostName = "myvm";

  users.users.my = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "wife";
  };
  security.sudo.wheelNeedsPassword = false;

  nix.gc.automatic = lib.mkForce false;
  nix.settings.auto-optimise-store = lib.mkForce false;

  services.getty.autologinUser = "my"; # autologin tty1

  environment.systemPackages = with pkgs; [
    curl
    git
    htop
    micro
    dbus
  ];

  microvm = {
    hypervisor = "qemu";

    shares = [
      {
        proto = "9p";
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
      }
    ];

    writableStoreOverlay = "/nix/.rw-store";

    volumes = [
      {
        image = "nix-store-overlay.img";
        mountPoint = config.microvm.writableStoreOverlay;
        size = 2048;
      }
    ];

    socket = "control.socket";
  };
}
