{ config, lib, pkgs, ... }:

{
  #──────────────────────────────────────────────
  #  Caddy reverse proxy
  #──────────────────────────────────────────────
  # services.caddy = {
  #   enable = true;
  #   email = "admin@example.com";
  #   virtualHosts = {
  #     "example.com" = {
  #       extraConfig = ''
  #         encode gzip
  #         reverse_proxy localhost:8080
  #       '';
  #     };
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
