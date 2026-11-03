# Hindsight

Self-hosted agent memory. Two services plus PostgreSQL:

- API `hindsight-api`, default `127.0.0.1:8888`
- UI `hindsight-control-plane`, default `127.0.0.1:9999`
- Storage: PostgreSQL + pgvector
- Default package is full `hindsight-api` with local embedding/reranker models

## Turn it on

```nix
services.hindsight.enable = true;
```

What happens:

- creates `hindsight-api.service` and `hindsight-control-plane.service`
  as user `hindsight` (`/var/lib/hindsight`, cache `/var/cache/hindsight/hf`)
- manages local PostgreSQL: installs pgvector, creates database/role,
  creates `vector`/`pg_trgm`/`btree_gin` before the API starts
- composes `HINDSIGHT_API_DATABASE_URL` for the Unix socket, runs
  migrations on API startup
- the API unit is `PartOf=postgresql.target`, so it restarts together
  with PostgreSQL

Disable with `services.hindsight.enable = false`. This stops the units
but keeps the database, `/var/lib/hindsight`, and `/var/cache/hindsight`.

## Database

Local (default):

```nix
services.hindsight.database = {
  enable = true;
  createDB = true;
};
```

Socket host (`/run/postgresql`) uses peer auth, no password needed.
With `createDB = false` you provide the database/role yourself; the
setup hook still installs the extensions into the existing database.

External over TCP:

```nix
services.hindsight = {
  enable = true;
  database = {
    enable = false;
    host = "db.example.com";
    port = 5432;
    name = "hindsight";
    user = "hindsight";
  };
  environmentFiles = [ config.sops.secrets."hindsight/db-env".path ];
};
```

`hindsight/db-env` must define the complete URL:

```env
HINDSIGHT_API_DATABASE_URL=postgresql://hindsight:encoded-password@db.example.com:5432/hindsight?sslmode=require
```

URL-encode the password yourself. Create the database, role, and
`CREATE EXTENSION vector` on the remote server yourself.

## LLM and providers

No LLM is configured by default. Set the provider in `environment`
and the key in `environmentFiles` (never put secrets in `environment`):

```nix
sops.secrets."hindsight/env" = {
  sopsFile = ../../secrets/hindsight.yml;
  key = "env";
  owner = "hindsight";
  mode = "0400";
};

services.hindsight = {
  enable = true;
  environmentFiles = [ config.sops.secrets."hindsight/env".path ];
  environment = {
    HINDSIGHT_API_LLM_PROVIDER = "openai";
    HINDSIGHT_API_LLM_BASE_URL = "http://127.0.0.1:20128/v1"; # 9router
    HINDSIGHT_API_LLM_MODEL = "your-model";
  };
};
```

`/run/secrets/hindsight/env` contains:

```env
HINDSIGHT_API_LLM_API_KEY=...
```

Without an LLM, retain stores chunks and recall works, but
reflect/consolidation stay disabled.

## Slim package

Small closure, no local models. You must provide remote providers:

```nix
services.hindsight = {
  enable = true;
  package = pkgs.hindsight-api-slim;
  localModels.enable = false;
  environment = {
    HINDSIGHT_API_EMBEDDINGS_PROVIDER = "openai";
    HINDSIGHT_API_RERANKER_PROVIDER = "rrf";
  };
};
```

`localModels.enable = true` is rejected with the slim package.

## UI address

```nix
services.hindsight.controlPlane.apiURL = "https://hindsight.example.com";
```

`apiURL` is used by the browser, so set the externally reachable API
URL when the UI is opened from another machine.

## Secrets

The module only passes file paths to systemd, never secret contents.

```yaml
# secrets/hindsight.yml (create with `sops secrets/hindsight.yml`)
env: |
  HINDSIGHT_API_LLM_API_KEY=...
  HINDSIGHT_API_EMBEDDINGS_OPENAI_API_KEY=...
cp-env: |
  HINDSIGHT_CP_ACCESS_KEY=...
db-env: |
  HINDSIGHT_API_DATABASE_URL=postgresql://...
```

| Secret | Used for |
|---|---|
| `hindsight/env` | API keys, remote provider keys |
| `hindsight/cp-env` | `HINDSIGHT_CP_ACCESS_KEY` |
| `hindsight/db-env` | full `HINDSIGHT_API_DATABASE_URL` for TCP |

With a local socket database no database secret is needed.

## Run and check

```sh
nix flake check --no-build
sudo nixos-rebuild switch --flake .#nova
systemctl status hindsight-api hindsight-control-plane
curl -fsS http://127.0.0.1:8888/health
journalctl -u hindsight-api -f
sudo -u postgres psql -d hindsight -c '\dx'
```

`vector`, `pg_trgm`, `btree_gin` should be listed.
Manual migration: `sudo -u hindsight hindsight-admin run-db-migration`.
Backup with normal PostgreSQL tools (`pg_dump`/`pg_restore`); the
HF model cache is disposable.

## Options

All under `services.hindsight`:

| Option | Default | Meaning |
|---|---|---|
| `enable` | `false` | enable API and UI |
| `package` | `pkgs.hindsight-api` | full package, or `pkgs.hindsight-api-slim` |
| `host` / `port` / `openFirewall` | `127.0.0.1` / `8888` / `false` | API bind address, port, firewall |
| `workers` | `1` | uvicorn `--workers` (null omits flag); not background workers |
| `logLevel` / `extraArgs` | `null` / `[]` | `--log-level`, extra API args |
| `environment` / `environmentFiles` | `{}` / `[]` | extra env (no secrets) / systemd `EnvironmentFile=` |
| `localModels.enable` | `true` | local embedding/reranker providers |
| `localModels.embeddingsModel` | `BAAI/bge-small-en-v1.5` | local embedding model |
| `localModels.rerankerModel` | `cross-encoder/ms-marco-MiniLM-L-6-v2` | local reranker model |
| `database.enable` / `database.createDB` | `true` / `true` | manage PostgreSQL / create database and role |
| `database.name` / `database.host` / `database.port` / `database.user` | `hindsight` / `/run/postgresql` / local port or `5432` / `hindsight` | socket directory or TCP host; socket needs user `hindsight` |
| `controlPlane.enable` / `controlPlane.host` / `controlPlane.port` / `controlPlane.openFirewall` | `true` / `127.0.0.1` / `9999` / `false` | UI switch, bind, port, firewall |
| `controlPlane.apiURL` | `http://127.0.0.1:<api port>` | API URL used by the browser |

## Problems

- `Configured vector extension 'pgvector' not found`: extension missing.
  Check `journalctl -u postgresql-setup`; for external DB run
  `CREATE EXTENSION IF NOT EXISTS vector;` yourself.
- Slim package embedding/reranking fails: slim has no local models,
  set remote providers or switch back to `pkgs.hindsight-api`.
- First request slow: full package downloads models to
  `/var/cache/hindsight/hf` on first use.
- UI loads but cannot reach API: `controlPlane.apiURL` is evaluated
  by the browser, use a URL reachable from the browser.
- RAM grows with `workers`: each worker is a full process loading
  torch and local models. Keep `workers = 1` unless measured.
