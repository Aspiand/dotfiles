{
  config,
  pkgs,
  lib,
  ...
}:

{
  system.stateVersion = "26.05";

  boot = {
    zswap.enable = true;
    tmp.cleanOnBoot = true;
    loader = {
      systemd-boot.enable = true;
      timeout = 0;
    };
    kernel.sysctl = {
      "vm.swappiness" = 10;
    };
    initrd.systemd.network.wait-online.enable = false;
  };

  networking = {
    hostName = "nova";
    useDHCP = true;
    useNetworkd = true;
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    interfaces.enp0s31f6 = {
      useDHCP = false;
      ipv4 = {
        addresses = [
          {
            address = "192.168.7.4";
            prefixLength = 24;
          }
        ];
        routes = [
          {
            address = "0.0.0.0";
            prefixLength = 0;
            via = "192.168.7.1";
          }
        ];
      };
    };

    nftables.enable = true;
    firewall = {
      enable = true;
      trustedInterfaces = [ config.services.tailscale.interfaceName ];
      checkReversePath = "loose"; # tailscale exit node needs loose RP filter
    };
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024;
    }
  ];

  users = {
    mutableUsers = false;
    users = {
      akira = {
        isNormalUser = true;
        hashedPassword = "$y$j9T$CwNkRULQT6TeiNfgvXvhC.$SE6BfKqYP5vrn.Aq4.yB0GCUCtTzF8RAcWnsP/GY6J/";
        extraGroups = [
          "wheel"
          "docker"
        ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDofwi7RvZGROLm/bm99T8xB6Tw9jg442wOi1TFudDwb ao@aira"
        ];
      };
      # restic = {
      #   group = "restic";
      #   isSystemUser = true;
      # };
    };
    # groups.restic = { };
  };

  # security.wrappers.restic = {
  #   source = lib.getExe pkgs.restic;
  #   owner = "restic";
  #   group = "restic";
  #   permissions = "500";
  #   capabilities = "cap_dac_read_search+ep";
  # };

  environment.systemPackages = with pkgs; [
    btrfs-progs
    compsize
    curl
    ethtool
    gitMinimal
    gitui
    htop
    micro
    python3Minimal
    restic
    rustic
    wget
  ];

  services = {
    "9router" = {
      enable = true;
    };

    tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "server";
    };

    # tailscale exit node: GRO forwarding offload avoids checksum bottleneck
    networkd-dispatcher = {
      enable = true;
      rules."50-tailscale-optimizations" = {
        onState = [ "routable" ];
        script = ''
          ${pkgs.ethtool}/bin/ethtool -K enp0s31f6 rx-udp-gro-forwarding on rx-gro-list off
        '';
      };
    };

    /*
      restic.backups.nova = {
        initialize = true;
        user = "restic";
        package = pkgs.writeShellScriptBin "restic" ''
          exec /run/wrappers/bin/restic "$@"
        '';
        repositoryFile = config.sops.secrets."restic/env".path;
        passwordFile = config.sops.secrets."restic/password".path;
        environmentFile = config.sops.secrets."restic/env".path;
        paths = [
          "/var"
          "/etc"
          "/home"
        ];
        pruneOpts = [
          "--keep-daily 14"
          "--keep-weekly 8"
          "--keep-monthly 24"
          "--keep-yearly 4"
        ];
        timerConfig = {
          OnCalendar = "*-*-* 0/2:00:00";
          Persistent = true;
        };

        # extraBackupArgs = [ "--one-file-system" ];

        serviceConfig = {
          ProtectSystem = "strict";
        };
      };

      prometheus.exporters.restic = {
        enable = true;
        repositoryFile = config.sops.secrets."restic/env".path;
        environmentFile = config.sops.secrets."restic/env".path;
        passwordFile = config.sops.secrets."restic/password".path;
        listenAddress = "127.0.0.1";
        port = 9753;
        openFirewall = false;
      };

      victoriametrics.prometheusConfig.scrape_configs = lib.mkAfter [
        {
          job_name = "restic-exporter";
          scrape_interval = "60s";
          static_configs = [
            {
              targets = [ "127.0.0.1:9753" ];
            }
          ];
        }
      ];
    */
  };

  sops.secrets = {
    /*
      "restic/password" = {
        owner = "restic";
        group = "restic";
        mode = "0400";
      };
      "restic/env" = {
        owner = "restic";
        group = "restic";
        mode = "0400";
      };
    */
  };

  systemd = {
    network.wait-online.enable = false;
    services.tailscaled.serviceConfig.Environment = [
      "TS_DEBUG_FIREWALL_MODE=nftables"
    ];
  };

  virtualisation.docker.enable = true;
}
