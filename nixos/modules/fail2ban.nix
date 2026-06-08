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

          # ── Increment bantime for repeat offenders ──
          bantime-increment = {
            enable = true;
            maxtime = "24h"; # max after increments
            overalljails = true; # track across all jails
          };

          # ── Internal nets never banned ──
          ignoreIP = [
            "10.0.0.0/8"
            "172.16.0.0/12"
            "192.168.0.0/16"
          ];

          jails = {
            # ── SSH ──
            sshd = {
              settings = {
                enabled = true;
                port = "ssh";
                filter = "sshd[mode=aggressive]";
                logpath = "/var/log/auth.log";
                maxretry = 3;
                findtime = 600;
                bantime = "-1"; # permanent — unban via f2b-client
              };
            };

            # ── Recidive — IP that was banned before and re-offends ──
            recidive = {
              settings = {
                enabled = true;
                logpath = "/var/log/fail2ban.log";
                maxretry = 3;
                findtime = 86400; # 1 day window
                bantime = "604800"; # 1 week (86400*7)
              };
            };

            # ── Port scan detection ──
            portscan = {
              settings = {
                enabled = true;
                filter = "portscan";
                logpath = "/var/log/fail2ban.log";
                maxretry = 5;
                findtime = 3600; # 1 hour
                bantime = "86400"; # 1 day
              };
            };
          };
        };
      };
    };
}
