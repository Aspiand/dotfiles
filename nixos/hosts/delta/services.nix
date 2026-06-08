{ config, lib, pkgs, ... }:

{
  #──────────────────────────────────────────────
  #  Caddy reverse proxy
  #──────────────────────────────────────────────
  # services.caddy = {
  #   enable = true;
  #   email = "admin@example.com";
  #   virtualHosts = {
  #     "vaultwarden.example.com" = {
  #       extraConfig = ''
  #         encode gzip
  #         header {
  #           X-Content-Type-Options nosniff
  #           X-Frame-Options DENY
  #           Referrer-Policy strict-origin-when-cross-origin
  #         }
  #         reverse_proxy localhost:8000
  #       '';
  #     };
  #     "actual.example.com" = {
  #       extraConfig = ''
  #         encode gzip
  #         reverse_proxy localhost:5006
  #       '';
  #     };
  #     "wakapi.example.com" = {
  #       extraConfig = ''
  #         encode gzip
  #         reverse_proxy localhost:3000
  #       '';
  #     };
  #     "beszel.example.com" = {
  #       extraConfig = ''
  #         encode gzip
  #         reverse_proxy localhost:8080
  #       '';
  #     };
  #     "softserve.example.com" = {
  #       extraConfig = ''
  #         reverse_proxy localhost:23231
  #       '';
  #     };
  #   };
  # };

  #──────────────────────────────────────────────
  #  Vaultwarden
  #──────────────────────────────────────────────
  # services.vaultwarden = {
  #   enable = true;
  #   config = {
  #     DOMAIN = "https://vaultwarden.example.com";
  #     SIGNUPS_ALLOWED = "false";
  #     ROCKET_ADDRESS = "127.0.0.1";
  #     ROCKET_PORT = 8000;
  #   };
  # };

  #──────────────────────────────────────────────
  #  Actual Budget
  #──────────────────────────────────────────────
  # services.actual-budget-server = {
  #   enable = true;
  #   port = 5006;
  #   host = "127.0.0.1";
  # };

  #──────────────────────────────────────────────
  #  Wakapi
  #──────────────────────────────────────────────
  # services.wakapi = {
  #   enable = true;
  #   settings = {
  #     port = 3000;
  #     host = "127.0.0.1";
  #   };
  # };

  #──────────────────────────────────────────────
  #  Beszel agent
  #──────────────────────────────────────────────
  # services.beszel = {
  #   enable = true;
  #   port = 8080;
  # };

  #──────────────────────────────────────────────
  #  Soft Serve git server
  #──────────────────────────────────────────────
  # services.soft-serve = {
  #   enable = true;
  #   settings = {
  #     listen = "127.0.0.1:23231";
  #   };
  # };

  #──────────────────────────────────────────────
  #  Cloudflare Tunnel
  #──────────────────────────────────────────────
  # services.cloudflared = {
  #   enable = true;
  #   configFilePath = "/etc/cloudflared/config.yml";
  # };
}
