# Setup Guide: Nix Binary Cache with Cloudflare R2

This guide explains how to set up a Nix binary cache using Cloudflare R2 and integrate it with GitHub Actions.

## 1. Cloudflare R2 Setup

1. **Create a Bucket**: Go to Cloudflare Dashboard -> R2 -> Create bucket. Name it (e.g., `nix-cache`).
2. **Get Credentials**:
   - Go to R2 -> Manage R2 API Tokens.
   - Create API token with **Edit** permissions for your bucket.
   - Save the `Access Key ID` and `Secret Access Key`.
   - Note your `Account ID` (found on the R2 overview page).
3. **Bucket Endpoint**: Your endpoint will be `https://<ACCOUNT_ID>.r2.cloudflarestorage.com`.

## 2. Generate Nix Signing Key

Nix needs a key pair to sign and verify packages in the cache.

```bash
# Generate private key
nix key generate-secret --key-name mycache-1 > cache-priv-key.pem

# Derive public key from it
nix key convert-secret-to-public < cache-priv-key.pem
```

- `cache-priv-key.pem`: Keep this secret! You will add it to `NIX_SECRET_KEY` GitHub secret.
- Public key output: This is shared with users of your cache via `trusted-public-keys`.

## 3. GitHub Secrets Setup

In your GitHub repository, go to **Settings -> Secrets and variables -> Actions** and add the following secrets:

| Secret | Value |
|---|---|
| `R2_ACCESS_KEY_ID` | Your R2 Access Key ID |
| `R2_SECRET_ACCESS_KEY` | Your R2 Secret Access Key |
| `R2_BUCKET` | Your R2 bucket name (e.g., `nix-cache`) |
| `R2_ENDPOINT` | `https://<ACCOUNT_ID>.r2.cloudflarestorage.com` |
| `NIX_SECRET_KEY` | Content of `cache-priv-key.pem` generated above |

## 4. Setup Public Access (Custom Domain)

R2 supports custom domains for public read-only access — this is what consumers use.

1. **Make bucket public**: Go to R2 Dashboard -> Your bucket -> **Settings** -> **Public Access** -> Enable.
2. **Connect domain**: Go to **R2 -> Your bucket -> Settings -> Custom Domains** -> add `nix.aspian.my.id`.
3. Cloudflare will auto-provision SSL. Wait \~1 minute.

The upload URL (S3 API) and public URL (HTTP read-only) are separate:

- **Upload** (GitHub Actions): `R2_ENDPOINT` — the S3 endpoint.
- **Download** (consumers): `https://nix.aspian.my.id`.

## 5. Workflow

The workflow at `.github/workflows/build.yml` is already active. It:

1. Builds the package.
2. Signs it with `NIX_SECRET_KEY`.
3. Copies to R2 via S3 API using the configured secrets.

## 6. Using the Cache

Add to your `nix.conf` or `flake.nix` on any machine that should consume the cache:

```conf
substituters = https://nix.aspian.my.id
trusted-public-keys = "github-ci-1:qjsecsjhdp0svqh6aXFEaaYtsTh5U+Ca6Jzmk46wXOY="
```
