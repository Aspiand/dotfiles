{
  flake.nixosModules.fail2ban =
    { lib, ... }:
    let
      mkDefaults = (import ../../lib { inherit lib; }).mkDefaults;
    in
    {
      config = mkDefaults {
        services.fail2ban = {
          enable = true;

          # ── Default ban action ──
          banaction = "nftables-multiport";
          banaction-allports = "nftables-allports";

          # ── Global defaults (DEFAULT jail) ──
          bantime = "1h";        # 1h, escalated by bantime-increment
          maxretry = 5;
          findtime = "10m";      # sliding window

          # ── Escalating bans for repeat offenders ──
          # multipliers: 1h → 2h → 4h → 8h → 16h → 32h → 64h → 168h cap
          bantime-increment = {
            enable = true;
            maxtime = "168h";      # 1 week cap
            overalljails = true;   # count offenses across all jails
            multipliers = "1 2 4 8 16 32 64";
            rndtime = "10m";       # jitter — prevent botnet timing sync
          };

          # ── Internal nets never banned ──
          ignoreIP = [
            "10.0.0.0/8"
            "172.16.0.0/12"
            "192.168.0.0/16"
          ];

          jails = {
            # ── SSH brute force ──
            sshd = {
              settings = {
                enabled = true;
                port = "ssh";
                filter = "sshd[mode=aggressive]";
                logpath = "/var/log/auth.log";
                maxretry = 3;
                findtime = 600;     # 10 min window
                bantime = "-1";     # permanent — unban via fail2ban-client
              };
            };

            # ── Recidive — IP yg banned then re-offend in 1 day ──
            recidive = {
              settings = {
                enabled = true;
                logpath = "/var/log/fail2ban.log";
                maxretry = 3;
                findtime = 86400;      # 1 day
                bantime = "2592000";   # 30 days — these are persistent abusers
              };
            };

            # ── Portscan / connection flood ──
            portscan = {
              settings = {
                enabled = true;
                filter = "portscan";
                logpath = "/var/log/fail2ban.log";
                maxretry = 5;
                findtime = 3600;      # 1 hour
                bantime = "86400";    # 1 day
              };
            };

            # ── Caddy HTTP basic auth brute force ──
            # Enable only if you use Caddy's `basicauth` directive.
            # `/var/log/caddy/` must exist — Caddy logs to journald by default.
            caddy-auth = {
              settings = {
                enabled = false;
                filter = "caddy-auth";
                logpath = "/var/log/caddy/*.log";
                maxretry = 5;
                findtime = 600;       # 10 min
                bantime = "24h";
              };
            };

            # ── Caddy URL probe — scanner / bot / crawler detection ──
            caddy-probe = {
              settings = {
                enabled = true;
                filter = "caddy-probe";
                logpath = "/var/log/caddy/*.log";
                maxretry = 5;
                findtime = 600;       # 10 min
                bantime = "86400";    # 1 day
              };
            };

            # ── SearXNG abuse — too many queries in short window ──
            # Logs from Caddy access log (SearXNG listens on 127.0.0.1)
            searxng = {
              settings = {
                enabled = true;
                filter = "searxng";
                logpath = "/var/log/caddy/*.log";
                maxretry = 60;        # ~1 req/min in 1h is OK
                findtime = 3600;      # 1 hour window
                bantime = "3600";     # 1h cooldown
              };
            };
          };
        };

        # ── Custom fail2ban filters ──

        # Caddy URL probe: catch scanner tools & admin panel probes
        environment.etc."fail2ban/filter.d/caddy-probe.local".text = ''
          # Caddy probe scanner detection
          # Blocks known scanner UA strings and common exploit paths
          [Definition]
          failregex = ^<HOST> - - \[.*\] "(?:GET|POST|HEAD) \/(?:wp-|wp-content|wp-includes|admin|boaform|phpmyadmin|pma|\.env|\.git|\.svn|config\.json|backup|dump|sql|db|admin\.php|xmlrpc\.php|setup|install|shell|cmd|debug|api\/v[12]\/(?:browse|search))[\s\/?]
                      ^<HOST> - - \[.*\] "(?:GET|POST|HEAD) .* (?:404|403|400) \d+ "-" "(?:python-requests|curl|wget|Go-http-client|masscan|nmap|zgrab|ruby|perl|nikto|scanner|Maui|Java\/|libwww|Netcraft|WordPress) [^"]*"
          ignoreregex =
        '';

        # SearXNG rate limit: too many queries (from Caddy access log)
        environment.etc."fail2ban/filter.d/searxng.local".text = ''
          # SearXNG query flood detection via Caddy logs
          # Caddy log format: <HOST> - - [ts] "GET /search?q=... HTTP/1.1" ...
          [Definition]
          failregex = ^<HOST> - - \[.*\] "GET \/search\?q=
          ignoreregex =
        '';
      };
    };
}
