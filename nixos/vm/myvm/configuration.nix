{ config, lib, pkgs, modulesPath, ... }:

{
  system.stateVersion = "26.05";

  networking.hostName = "myvm";

  users.users.my = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "wife";
  };
  security.sudo.wheelNeedsPassword = false;

  # disable nix gc/optimise — conflict writableStoreOverlay
  nix.gc.automatic = lib.mkForce false;
  nix.settings.auto-optimise-store = lib.mkForce false;

  microvm = {
    hypervisor = "qemu";

    # share host /nix/store — ga rebuild semua
    shares = [{
      proto = "9p";
      tag = "ro-store";
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
    }];

    # writable overlay — biar bisa nix build/nixos-rebuild di dalam VM
    writableStoreOverlay = "/nix/.rw-store";

    volumes = [{
      image = "nix-store-overlay.img";
      mountPoint = config.microvm.writableStoreOverlay;
      size = 2048;
    }];

    socket = "control.socket";
  };

  environment.systemPackages = with pkgs; [
    curl
    git
    htop
    micro
  ];
}
