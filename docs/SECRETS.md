# Secrets Setup

## Cloudflared

```bash
cloudflared login
```

Click the link, authorize your domain. Browser downloads `cert.pem`.

```bash
# Copy cert to cloudflared config dir
cp ~/Downloads/cert.pem ~/.cloudflared/

# Create tunnel
cloudflared tunnel create mytunnel
# → credentials saved to ~/.cloudflared/<uuid>.json
```

Move credential to secrets dir (must match sops `path_regex`):

```bash
mv ~/.cloudflared/<uuid>.json ~/dotfiles/secrets/cloudflared.json
```

Encrypt:

```bash
sops encrypt --input-type binary --output-type binary \
  --output secrets/cloudflared.json.enc secrets/cloudflared.json
```

### NixOS config example

```nix
services.cloudflared = {
  enable = true;
  tunnels."<uuid>" = {
    credentialsFile = config.sops.secrets.cloudflared.path;
    ingress = {
      "sub.domain.com" = "http://localhost:80";
    };
    default = "http_status:404";
  };
};

sops.secrets.cloudflared = {
  sopsFile = ../../../secrets/cloudflared.json.enc;
  format = "binary";
};
```
