{
  config,
  pkgs,
  lib,
  pkgs-unstable,
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
    # snd_soc_avs (Intel AVS) blocks snd_hda_intel, leaving /dev/snd empty.
    blacklistedKernelModules = [ "snd_soc_avs" ];
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
      allowedTCPPorts = [ 3923 ];
    };
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024;
    }
  ];

  fileSystems."/mnt/adata_su650_500" = {
    device = "/dev/disk/by-uuid/d4eb84bb-fe23-418a-9cc5-82ce45b7ebad";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  systemd.mounts = [
    {
      what = "/mnt/adata_su650_500/pandora";
      where = "/mnt/copyparty/pandora";
      type = "fuse.gocryptfs";
      options = "allow_other,passfile=${config.sops.secrets."gocryptfs/pandora".path},noauto";
      wantedBy = [ "multi-user.target" ];
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
          "audio"
        ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDofwi7RvZGROLm/bm99T8xB6Tw9jg442wOi1TFudDwb ao@aira"
        ];
      };
      # restic = {
      #   group = "restic";
      #   isSystemUser = true;
      # };
      immich.extraGroups = [
        "video"
        "render"
      ];
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
    gocryptfs
    wget
    (writeShellScriptBin "rustic-services" ''
      set -a
      source <(sudo cat ${config.sops.secrets."rustic/services".path})
      set +a
      exec rustic "$@"
    '')
    (writeShellScriptBin "rustic-media" ''
      set -a
      source <(sudo cat ${config.sops.secrets."rustic/media".path})
      set +a
      exec rustic "$@"
    '')
  ];

  hardware.alsa.enablePersistence = true;
  hardware.graphics.enable = true;

  systemd = {
    network.wait-online.enable = false;
    services.tailscaled.serviceConfig.Environment = [
      "TS_DEBUG_FIREWALL_MODE=nftables"
    ];

    services.immich-server = {
      unitConfig = {
        ConditionPathIsMountPoint = "/mnt/adata_su650_500";
        RequiresMountsFor = "/mnt/adata_su650_500";
      };
      bindsTo = [ "mnt-adata_su650_500.mount" ];
    };

    services.immich-machine-learning = {
      unitConfig = {
        ConditionPathIsMountPoint = "/mnt/adata_su650_500";
        RequiresMountsFor = "/mnt/adata_su650_500";
      };
      bindsTo = [ "mnt-adata_su650_500.mount" ];
    };

    services.copyparty = {
      after = [ "mnt-copyparty-pandora.mount" ];
      requires = [ "mnt-copyparty-pandora.mount" ];
      unitConfig.RequiresMountsFor = [ "/mnt/copyparty/pandora" ];
    };
  };

  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "btrfs";
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
      daemon.settings = {
        log-driver = "journald";
        live-restore = true;
      };
    };

    oci-containers = {
      backend = "docker";
      containers = {
        # zerobyte = {
        #   image = "ghcr.io/nicotsx/zerobyte:v0.40";
        #   autoStart = true;
        #   pull = "missing";
        #   ports = [ "4096:4096" ];
        #   environment = {
        #     TZ = "Asia/Jakarta";
        #     BASE_URL = "http://nova:4096";
        #     LOG_LEVEL = "info";
        #   };
        #   environmentFiles = [ config.sops.secrets.zerobyte.path ];
        #   volumes = [
        #     "/var/lib/zerobyte:/var/lib/zerobyte"
        #     "/etc/localtime:/etc/localtime:ro"
        #   ];
        #   capabilities = {
        #     SYS_ADMIN = true;
        #   };
        #   devices = [ "/dev/fuse:/dev/fuse" ];
        # };

        tsdproxy = {
          image = "almeidapaulopt/tsdproxy:dev";
          autoStart = true;
          pull = "missing";
          environmentFiles = [ config.sops.secrets.tsdproxy.path ];
          volumes = [
            "/var/lib/tsdproxy:/data"
            "${toString ./tsdproxy.yaml}:/config/tsdproxy.yaml:ro"
            "${toString ./tsdproxy-svc.yaml}:/config/services.yaml:ro"
          ];
          extraOptions = [
            "--network=host"
          ];
        };

      };
    };
  };
}
