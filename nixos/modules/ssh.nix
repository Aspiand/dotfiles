{
  flake.nixosModules.ssh =
    { lib, ... }:
    {
      config = lib.my.mkDefaults {
        services.openssh = {
          enable = true;

          settings = {
            # ── Auth ──
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            ChallengeResponseAuthentication = false;
            AuthenticationMethods = "publickey";
            PubkeyAuthentication = true;
            PermitEmptyPasswords = false;
            AllowUsers = [ ];
            AllowGroups = [ "wheel" ];

            # ── Root ──
            PermitRootLogin = "no";

            # ── Session ──
            AllowTcpForwarding = "yes";
            AllowAgentForwarding = "yes";
            X11Forwarding = false;
            PrintMotd = false;
            PrintLastLog = true;
            StreamLocalBindUnlink = true;
            UseDns = false;
            UsePam = true;

            # ── Keep alive ──
            ClientAliveInterval = 300;
            ClientAliveCountMax = 2;
            TCPKeepAlive = true;
            RekeyLimit = "1G 3600";

            # ── Rate limiting ──
            MaxAuthTries = 3;
            MaxSessions = 10;
            MaxStartups = "10:30:100";
            LoginGraceTime = 60;

            # ── Logging ──
            LogLevel = "VERBOSE";
            SyslogFacility = "AUTH";

            # ── Key exchange — PQ hybrid + Curve25519 ──
            KexAlgorithms = [
              "sntrup761x25519-sha512"
              "curve25519-sha256"
              "curve25519-sha256@libssh.org"
              "diffie-hellman-group-exchange-sha256"
              "diffie-hellman-group16-sha512"
              "diffie-hellman-group18-sha512"
            ];

            # ── Ciphers — AEAD preferred ──
            Ciphers = [
              "chacha20-poly1305@openssh.com"
              "aes256-gcm@openssh.com"
              "aes128-gcm@openssh.com"
              "aes256-ctr"
              "aes192-ctr"
              "aes128-ctr"
            ];

            # ── MACs — Encrypt-then-MAC preferred ──
            Macs = [
              "hmac-sha2-512-etm@openssh.com"
              "hmac-sha2-256-etm@openssh.com"
              "hmac-sha2-512"
              "hmac-sha2-256"
            ];

            # ── Host key algorithms ──
            HostKeyAlgorithms = [
              "ssh-ed25519"
              "ssh-ed25519-cert-v01@openssh.com"
              "***@openssh.com"
              "rsa-sha2-512"
              "rsa-sha2-512-cert-v01@openssh.com"
              "rsa-sha2-256"
              "rsa-sha2-256-cert-v01@openssh.com"
            ];

            # ── Public key accepted algorithms ──
            PubkeyAcceptedAlgorithms = [
              "ssh-ed25519"
              "***@openssh.com"
              "rsa-sha2-512"
              "rsa-sha2-512-cert-v01@openssh.com"
              "rsa-sha2-256"
              "rsa-sha2-256-cert-v01@openssh.com"
            ];

            # ── OpenSSH 9.8+ ──
            RequiredRSASize = 4096;
          };

          hostKeys = [
            {
              path = "/etc/ssh/ssh_host_ed25519_key";
              type = "ed25519";
            }
            {
              path = "/etc/ssh/ssh_host_rsa_key";
              type = "rsa";
              bits = 4096;
            }
            {
              path = "/etc/ssh/ssh_host_ecdsa_key";
              type = "ecdsa";
            }
          ];

          ports = [ 22 ];
          startWhenNeeded = false;
        };
      };
    };
}
