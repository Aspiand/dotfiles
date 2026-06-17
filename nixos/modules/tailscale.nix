{
  flake.nixosModules.tailscale =
    { config, lib, ... }:
    let
      mkDefaults = (import ../../lib { inherit lib; }).mkDefaults;
    in
    {
      config = mkDefaults {
        services.tailscale.enable = true;

        # Allow Tailscale traffic through firewall
        networking.firewall = {
          trustedInterfaces = [ "tailscale0" ];
          allowedUDPPorts = [ config.services.tailscale.port ];
        };

        # MagicDNS / subnet routing
        boot.kernel.sysctl."net.ipv4.ip_forward" = true;
        boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = true;
      };
    };
}
