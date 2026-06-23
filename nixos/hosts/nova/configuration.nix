{
  config,
  pkgs,
  lib,
  ...
}:

{
  system.stateVersion = "26.05";

  boot.loader = {
    systemd-boot.enable = true;
    tmp.cleanOnBoot = true;
    timeout = 0;
  };

  networking = {
    hostName = "nova";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

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
      restic = {
        group = "restic";
        isSystemUser = true;
      };
    };
    groups.restic = { };
  };

  security.wrappers.restic = {
    source = lib.getExe pkgs.restic;
    owner = "restic";
    group = "restic";
    permissions = "500";
    capabilities = "cap_dac_read_search+ep";
  };

  environment.systemPackages = with pkgs; [
    btrfs-progs
    compsize
    curl
    gitMinimal
    htop
    micro
    restic
    wget
  ];

  virtualisation.docker.enable = true;
  services = {
    tailscale.enable = false;

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
  };

  sops = {
    defaultSopsFile = ../../../secrets/hosts/nova.yml;
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
  };
}
