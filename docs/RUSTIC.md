# Rustic

Module for automated encrypted backups to S3 via [rustic](https://github.com/rustic-rs/rustic).

Module: `nix/modules/rustic.nix` — loaded via `dotfiles.modules`.

## Usage

```nix
services.rustic = {
  enable = true;
  prometheus.enable = true;

  backups.<name> = {
    enable = true;
    sources = [ "/path/to/backup" ];
    environmentFile = config.sops.secrets."rustic/<name>".path;
    settings = {
      # free-form → rendered as TOML sections
      global.check-index = true;
      backup.skip-if-unchanged = true;
      backup."exclude-if-present" = [ ".nobackup" ];
      forget."keep-daily" = 14;
      forget."keep-weekly" = 8;
      forget."keep-monthly" = 24;
      snapshot = { }; # optional extra fields (label auto-injected)
    };
  };
};
```

Each profile creates `rustic-<name>.service` + `rustic-<name>.timer`.

Set `timerConfig` to override default. Set profile's `timerConfig = {}` to disable timer.

## Secrets

`secrets/rustic.yml` — sops YAML multi-doc, one section per profile:

```yaml
<profile>:
    RUSTIC_REPOSITORY: "opendal:s3"
    RUSTIC_PASSWORD: "..."
    RUSTIC_REPOSITORY_OPTIONS_ACCESS_KEY_ID: "..."
    RUSTIC_REPOSITORY_OPTIONS_SECRET_ACCESS_KEY: "..."
    RUSTIC_REPOSITORY_OPTIONS_ENDPOINT: "..."
    RUSTIC_REPOSITORY_OPTIONS_BUCKET: "..."
    RUSTIC_REPOSITORY_OPTIONS_ROOT: "/data"
    RUSTIC_REPOSITORY_OPTIONS_REGION: "auto"
```

Encrypt: `sops encrypt --in-place secrets/rustic.yml`

In `configuration.nix`:

```nix
sops.secrets."rustic/<name>" = {
  sopsFile = ../../../secrets/rustic.yml;
  format = "dotenv";
  mode = "0400";
};
```

## Metrics

`--prometheus` flag pushes to VictoriaMetrics. Enabled by default at `http://127.0.0.1:8428/api/v1/import/prometheus`.

## Useful commands

```bash
systemctl start rustic-<name>
systemctl list-timers | grep rustic
systemctl status rustic-<name>
journalctl -u rustic-<name>
rustic -P <name> snapshots
rustic -P <name> restore <snapshot-id> /tmp/restore
```
