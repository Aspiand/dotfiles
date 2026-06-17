{
  flake.nixosModules.tailscale =
    { config, lib, ... }:
    let
      mkDefaults = (import ../../lib { inherit lib; }).mkDefaults;
    in
    {
      config = mkDefaults {
        services.tailscale.enable = true;

        # Option 1: disable MagicDNS — keep upstream DNS untouched (recommended for cloud VPS)
        # https://github.com/tailscale/tailscale/issues/16053
        services.tailscale.extraSetFlags = [
          "--accept-dns=false"
        ];

        # Option 2: enable MagicDNS — Tailscale DNS + upstream fallback
        # https://tailscale.com/docs/install/nixos#using-magicdns
        # networking.nameservers = [
        #   "100.100.100.100"  # Tailscale MagicDNS
        #   "100.100.2.136"    # Alibaba Cloud
        #   "100.100.2.138"    # Alibaba Cloud
        #   "8.8.8.8"          # Google
        #   "1.1.1.1"          # Cloudflare
        # ];
        # networking.search = [ "" ];

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
