{ ... }:

{
  networking = {
    hostName = "azel";
    networkmanager.enable = true;
  };

  hardware.bluetooth.enable = true;

  services = {
    tailscale.enable = true;
    power-profiles-daemon.enable = true;
    upower.enable = true;
  };
}
