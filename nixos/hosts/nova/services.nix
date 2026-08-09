{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  services = {
    "9router" = {
      enable = true;
    };

    couchdb = {
      enable = true;
      bindAddress = "127.0.0.1";
      extraConfigFiles = [ config.sops.secrets.couchdb.path ];
      extraConfig = {
        httpd = {
          WWW-Authenticate = ''Basic realm="couchdb"'';
          enable_cors = true;
        };
        chttpd = {
          require_valid_user = true;
          enable_cors = true;
          max_http_request_size = "4294967296";
        };
        chttpd_auth.require_valid_user = true;
        couchdb.max_document_size = "50000000";
        cors = {
          credentials = true;
          origins = "app://obsidian.md,capacitor://localhost,http://localhost";
        };
      };
    };

    logrotate = {
      enable = true;
      settings."${config.services.couchdb.logFile}" = {
        rotate = 4;
        size = "100M";
        compress = true;
        postrotate = "systemctl kill -s HUP couchdb.service";
      };
    };

    cloudflared = {
      enable = true;
      tunnels."50687d84-87ea-4d7c-a635-548cb7dec14c" = {
        credentialsFile = config.sops.secrets.cloudflared.path;
        ingress = {
          "gallery.aspian.my.id" = "http://localhost:2283";
          "couchdb.aspian.my.id" = "http://localhost:5984";
        };
        default = "http_status:404";
      };
    };

    tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "server";
      extraUpFlags = [ "--advertise-exit-node" ];
    };

    pipewire = {
      enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    copyparty = {
      enable = true;
      package = pkgs-unstable.copyparty;
      settings = {
        i = "0.0.0.0";
        p = 3923;
        usernames = true;
        e2dsa = true;
        e2ts = true;
        grid = true;
      };
      accounts.as.passwordFile = config.sops.secrets."copyparty/as".path;
      volumes = {
        "/corn" = {
          path = "/mnt/copyparty/pandora";
          access = {
            "rwmd." = "as";
          };
        };
        "/shared" = {
          path = "/mnt/adata_su650_500/data/shared";
          access = {
            "rwmd." = "as";
          };
        };
      };
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

    postgresql = {
      enable = true;
      package = pkgs.postgresql_17;
      initdbArgs = [ "--data-checksums" ];
      settings = {
        wal_level = "replica";
        wal_compression = "on";
      };
    };

    prometheus.exporters.postgres = {
      enable = true;
      runAsLocalSuperUser = true;
      openFirewall = false;
    };

    immich = {
      enable = true;
      package = pkgs-unstable.immich;
      host = "0.0.0.0";
      port = 2283;
      openFirewall = true;
      accelerationDevices = null; # all devices for HW transcoding
      redis.enable = true;
      database.enable = true;
      machine-learning.enable = true;
      mediaLocation = "/mnt/adata_su650_500/data/immich";
      environment = {
        IMMICH_LOG_LEVEL = "log";
        IMMICH_TELEMETRY_INCLUDE = "all";
        THUMB_LOCATION = "/var/cache/immich/thumbs";
        ENCODED_VIDEO_LOCATION = "/var/cache/immich/encoded-video";
      };
    };

    redis.servers.immich.logLevel = "warning";

    swapspace = {
      enable = true;
      settings = {
        min_swapsize = "100m";
        max_swapsize = "1g";
      };
    };

    rustic = {
      enable = true;
      prometheus = {
        enable = true;
        address = "http://127.0.0.1:9091";
      };
      backups.services = {
        enable = true;
        timerConfig = {
          OnCalendar = "*:00:00";
          Persistent = true;
        };
        sources = [
          "/var/lib/9router"
          "/var/lib/hermes"
          "/var/lib/tsdproxy"
          "/var/lib/victoriametrics"
          "/var/lib/victorialogs"
        ];
        environmentFile = config.sops.secrets."rustic/services".path;
        settings = {
          global.check-index = true;
          backup.skip-if-unchanged = true;
          backup."exclude-if-present" = [ ".nobackup" ];
          forget."keep-daily" = 14;
          forget."keep-weekly" = 8;
          forget."keep-monthly" = 24;
        };
      };
      backups.media = {
        enable = true;
        environmentFile = config.sops.secrets."rustic/media".path;
        timerConfig = {
          OnCalendar = "*:30:00";
          Persistent = true;
        };
        sources = [
          "/mnt/adata_su650_500/data/immich"
        ];
        settings = {
          backup = {
            skip-if-unchanged = true;
            exclude-if-present = [ ".nobackup" ];
            globs = [
              "!encoded-video"
              "!thumbs"
              # "!backups"
            ];
          };
          forget."keep-daily" = 14;
          forget."keep-weekly" = 8;
          forget."keep-monthly" = 24;
        };
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/cache/immich 0755 immich immich -"
    "d /var/cache/immich/thumbs 0755 immich immich -"
    "d /var/cache/immich/encoded-video 0755 immich immich -"
    "f /var/cache/immich/thumbs/.immich 0644 immich immich -"
    "f /var/cache/immich/encoded-video/.immich 0644 immich immich -"
  ];
}

# TODO:
# jika disk tidak di mount apa yang terjadi
# immich jalan? (tidak)
# boot (yes)
# gocryptfs dan copyparty juga sama
