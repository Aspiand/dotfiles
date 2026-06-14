{
  flake.nixosModules.caddy =
    { lib, ... }:
    let
      mkDefaults = (import ../../lib { inherit lib; }).mkDefaults;
    in
    {
      config = mkDefaults {
        services.caddy = {
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
            log {
              output file /var/log/caddy/access.log {
                roll_disabled false
                roll_size 100mb
                roll_keep 7
                roll_keep_for 720h
              }
            }
          '';
        };
      };
    };
}
