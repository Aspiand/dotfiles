{
  flake.nixosModules.caddy =
    { lib, ... }:
    {
      services.caddy = lib.mkDefault {
        enable = true;
        email = "admin@example.com";
        dataDir = "/var/lib/caddy";
        logDir = "/var/log/caddy";
        acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
        admin = "localhost:2019";

        globalConfig = ''
          ocsp_stapling on
          servers {
            trusted_proxies static private_ranges
            protocol {
              allow_h2c true
            }
          }
        '';
      };
    };
}
