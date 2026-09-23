# Nix Binary Cache

Builds Nix packages in GitHub Actions and pushes them to an S3-compatible binary
cache (Cloudflare R2 or Backblaze B2). Config lives in [`cache.yml`](../cache.yml);
the workflow is [`.github/workflows/build.yml`](../.github/workflows/build.yml).

## How it works

```
cache.yml ──► generate-matrix ──► build each ──► sign ──► nix copy --to s3://
              (eval flake       (matrix job)   (nix store   (R2/B2 via S3 API)
               packages)                        sign)
```

`generate-matrix` evaluates `packages.<arch>` for two kinds of target:

- **this repo** — `.#packages.<arch>.*` (the overlay packages)
- **each `watch` entry** — an external flake's `packages.<arch>.*`

Each package becomes one matrix job that builds, signs, and uploads the store path.
`--accept-flake-config` is used only for the local repo; external flakes' `nixConfig`
is never trusted.

## Configuration (`cache.yml`)

```yaml
packages:
  arch:
    - x86_64-linux
  ignore:
    - 9router               # skipped when building the local repo's packages

watch:
  - url: github:NousResearch/hermes-agent
    package: all            # build every packages.<arch> key
  - url: github:Mic92/sops-nix
    ref: latest-tag         # optional — see ref types below
    package: [foo, bar]     # list form; also accepts "pkg1,pkg2"
```

### `url`

`github:<owner>/<repo>` or plain `<owner>/<repo>`. A local path (`.`, `/abs`) is also
accepted but has no GitHub API (so `latest-*` / `lock:` are unavailable).

### `ref` (optional — default `HEAD` / default branch)

| `ref:`            | meaning                       |
|-------------------|-------------------------------|
| *(omitted)*       | default branch HEAD           |
| `branch:<name>`   | track a branch                |
| `tag:<name>`      | pin a tag                     |
| `rev:<sha>`       | pin a commit                  |
| `latest-tag`      | newest tag (by date)          |
| `latest-release`  | latest GitHub release tag     |
| `lock:<host>`     | follow `nixos/hosts/<host>/flake.lock` rev |

`latest-tag` / `latest-release` / `lock:<host>` are resolved to an immutable rev in
`generate-matrix`, so the actual build is always pinned. `latest-tag` = newest by
date (GitHub tags API order), not highest semver.

### `package` (optional — default `all`)

`"all"` (every key), a list `[a, b]`, or a comma string `"a,b"`.

## Secrets

CI-only secrets (never mounted on hosts), stored as GitHub repo secrets:

| Secret                  | Value                                            |
| ----------------------- | ------------------------------------------------ |
| `AWS_ACCESS_KEY_ID`     | S3-compatible access key id (R2 / B2)            |
| `AWS_SECRET_ACCESS_KEY` | S3-compatible secret access key                  |
| `AWS_S3_BUCKET`         | bucket name                                      |
| `AWS_ENDPOINT_URL`      | S3 endpoint (`https://<account>.r2.cloudflarestorage.com` or B2 endpoint) |
| `NIX_SECRET_KEY`        | Nix signing private key (see below)              |

## Signing key

Generate once:

```bash
nix key generate-secret --key-name github-ci-2 > cache-priv-key.pem
nix key convert-secret-to-public < cache-priv-key.pem   # → trusted-public-keys
```

Store `cache-priv-key.pem` as the `NIX_SECRET_KEY` GitHub secret. **Its public half
must match the key already in `flake.nix`'s `trusted-public-keys`:**

```
github-ci-2:eUvIhhjHCO/kJVGcFNd/sNCGSx59tj1QAXmb477OO00=
```



## Using the cache

```conf
substituters = https://nix.aspian.my.id
trusted-public-keys = github-ci-2:eUvIhhjHCO/kJVGcFNd/sNCGSx59tj1QAXmb477OO00=
```

