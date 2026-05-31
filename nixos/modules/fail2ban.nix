{ ... }: {
  flake.nixosModules.fail2ban = { lib, ... }: {
    services.fail2ban = lib.mkDefault {
      enable = true;

      jails.sshd = {
        settings = {
          enabled = true;
          port = "ssh";
          filter = "sshd[mode=aggressive]";
          logpath = "/var/log/auth.log";
          maxretry = 3;
          findtime = 600;
          bantime = -1;   # permanent — unban via console/ssh
                           # $ fail2ban-client unban <ip>
        };
      };

      bantime-increment.enable = false;

      banaction = "nftables-multiport";
      banaction-allports = "nftables-allports";

      ignoreIP = [
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
      ];
    };
  };
}
