{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.azel.backup.restic;
in
{
  options.azel.backup.restic = {
    enable = lib.mkEnableOption "restic backups for important azel data";

    repository = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "sftp:backup@example.com:/srv/restic/azel";
      description = "Restic repository URL or local path.";
    };

    passwordFile = lib.mkOption {
      type = lib.types.str;
      default = "/persist/secrets/restic/password";
      description = "Path to the restic repository password file.";
    };

    initialize = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Initialize the repository automatically if it is still empty.";
    };

    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "/persist"
        "/home/aka/Documents"
        "/home/aka/Projects"
        "/home/aka/.ssh"
        "/home/aka/.gnupg"
        "/home/aka/.password-store"
      ];
      description = "Important paths to back up.";
    };

    exclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "/persist/secrets/restic"
        "/home/aka/.cache"
        "/home/aka/.local/share/Trash"
      ];
      description = "Paths excluded from backup.";
    };

    timer = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      description = "OnCalendar expression for the backup timer.";
    };

    pruneOpts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
      ];
      description = "Retention arguments passed to restic forget/prune after backup.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.repository != null;
        message = "Set `azel.backup.restic.repository` before enabling restic backups.";
      }
    ];

    environment.systemPackages = [ pkgs.restic ];

    systemd.tmpfiles.rules = [
      "d /persist/secrets 0700 root root -"
      "d /persist/secrets/restic 0700 root root -"
    ];

    services.restic.backups.important = {
      initialize = cfg.initialize;
      repository = lib.mkForce cfg.repository;
      passwordFile = cfg.passwordFile;
      paths = cfg.paths;
      exclude = cfg.exclude;
      pruneOpts = cfg.pruneOpts;
      timerConfig = {
        OnCalendar = cfg.timer;
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
    };
  };
}
