{ ... }:

{
  networking = {
    hostName = "azel";
    networkmanager.enable = true;
  };

  services.tailscale.enable = true;
}
