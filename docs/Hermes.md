# Hermes Agent — NixOS Integration

## Architecture

```
User: "what's new in NixOS 26.05?"
        │
        ▼
┌─── Hermes Agent ──────────────────────────┐
│  web.search_backend = "searxng"            │
│  web.searxng_url = "http://127.0.0.1:8888" │
│                                            │
│  web_search tool ────────────────────┐     │
└──────────────────────────────────────│─────┘
                                       │
┌──────────────────────────────────────▼─────┐
│  SearXNG                             8888  │
│  nixos/modules/searxng.nix                 │
│                                            │
│  8 engines: google, ddg, bing, brave,      │
│  wikipedia, github, stackoverflow, arxiv   │
│  JSON API, zero logs, self-hosted          │
│                                       │    │
│  → [URL1, URL2, URL3, ...]           │    │
└──────────────────────────────────────┬─────┘
                                       │
┌──────────────────────────────────────▼─────┐
│  search-scrape                             │
│  nix/packages/search-scrape.nix            │
│                                            │
│  crawl4ai → parallel scrape → markdown     │
│  $ search-scrape "nixos 26.05"            │
│  # Search: nixos 26.05                     │
│  ## Result 1                               │
│  **URL:** https://...                      │
│  [cleaned markdown content]                │
└────────────────────────────────────────────┘
```

## Files

| File | Purpose |
|---|---|
| `nixos/modules/searxng.nix` | Preconfigured SearXNG service (wraps nixpkgs `services.searx`) |
| `nix/packages/search-scrape.nix` | crawl4ai Python package + `search-scrape` pipeline CLI |
| `nixos/hosts/aira/hermes.nix` | Hermes config: `search_backend`, `searxng_url`, extraPackages |
| `nixos/hosts/aira/flake.nix` | Host module list: `dotfiles.nixosModules.searxng` |

## Module Organization

```
nix/
├── packages/           Custom package derivations + overlays
│   ├── search-scrape.nix   crawl4ai + search→scrape pipeline
│   ├── 9router.nix
│   ├── codegraph.nix
│   └── ...
├── modules/            NixOS service modules for custom packages
│   ├── 9router.nix          systemd service for 9router
│   └── hermes-agent.nix     Hermes gateway service
└── _sources/           nvfetcher data (shared by packages/)

nixos/
├── modules/            Preconfigured nixpkgs services (mkDefaults)
│   ├── base.nix
│   ├── ssh.nix
│   ├── caddy.nix
│   ├── fail2ban.nix
│   ├── desktop.nix
│   └── searxng.nix          ← SearXNG lives here
└── hosts/
    └── aira/
        ├── flake.nix          imports dotfiles.nixosModules.searxng
        └── hermes.nix         web.search_backend = "searxng"
```

**Rule:** If a module wraps a nixpkgs `services.<name>` without needing a custom package derivation → `nixos/modules/`. If it needs a custom package from the same repo → `nix/modules/`.

## SearXNG Module (`nixos/modules/searxng.nix`)

```nix
{ ... }: {
  flake.nixosModules.searxng =
    { lib, ... }:
    let
      mkDefaults = (import ../../lib { inherit lib; }).mkDefaults;
    in
    {
      config = mkDefaults {
        services.searx = {
          enable = true;
          settings = {
            server = {
              bind_address = "127.0.0.1";
              port = 8888;
              secret_key = "@SEARXNG_SECRET@";  # MUST override in host
            };
            search.formats = [ "html" "json" ];
            engines = [
              { name = "google";     disabled = false; }
              { name = "duckduckgo"; disabled = false; }
              { name = "bing";       disabled = false; }
              { name = "brave";      disabled = false; }
              { name = "wikipedia";  disabled = false; }
              { name = "github";     disabled = false; }
              { name = "stackoverflow"; disabled = false; }
              { name = "arxiv";      disabled = false; }
            ];
          };
        };
      };
    };
}
```

All values are `lib.mkDefault` via `mkDefaults` — host overrides at normal priority.

### Required Override

```nix
# In host config:
services.searx.settings.server.secret_key = "openssl rand -hex 32 output here";
```

### API

```
GET http://127.0.0.1:8888/search?q=test&format=json
```

Returns:

```json
{
  "results": [
    {
      "title": "NixOS 26.05 Release Notes",
      "url": "https://nixos.org/manual/nixos/stable/release-notes",
      "content": "Snippet text..."
    }
  ]
}
```

## search-scrape CLI (`nix/packages/search-scrape.nix`)

Pipe SearXNG results through crawl4ai for full content extraction.

### Usage

```bash
# Search + scrape top 3 results → markdown
search-scrape "nixos 26.05 release"

# Search only (no scrape) — snippets + URLs
search-scrape "nixos 26.05" --no-scrape

# Search + scrape 5 results
search-scrape "rust async patterns" --scrape 5
```

### Environment

| Variable | Default | Purpose |
|---|---|---|
| `SEARXNG_URL` | `http://127.0.0.1:8888` | SearXNG JSON API endpoint |

### Hermes Integration

Hermes `web_search` tool auto-uses SearXNG when configured:

```nix
# nixos/hosts/aira/hermes.nix
settings = {
  web = {
    search_backend = "searxng";
    searxng_url = "http://127.0.0.1:8888";
  };
};

extraPackages = with pkgs; [
  search-scrape  # CLI: $ search-scrape "query"
];
```

Hermes calls SearXNG directly via its internal `web_search` tool. `search-scrape` is an additional standalone CLI for cases where you want full page scrapes outside the agent loop.

## Why SearXNG over DDGS

| | SearXNG | DDGS |
|---|---|---|
| Engines | 80+ (google, bing, ddg, brave...) | DuckDuckGo only |
| Hosting | Self-hosted, unlimited | External, rate-limited |
| Privacy | Zero logs | DDG backend |
| JSON API | Native | None |
| Hermes support | Native `search_backend = "searxng"` | Native `search_backend = "ddgs"` |

## Why crawl4ai alongside SearXNG

- SearXNG returns **URLs + snippets**
- crawl4ai extracts **full page content** as clean markdown
- Together: **find → scrape → answer** pipeline
- Parallel scraping: 3 URLs in ~3 seconds

## Deployment

```bash
cd ~/.config/dotfiles

# 1. Fix crawl4ai hash (first build will fail with expected hash)
nix build .#search-scrape 2>&1 | grep -o 'sha256-.*'
# paste into nix/packages/search-scrape.nix → src.hash

# 2. Generate SearXNG secret
openssl rand -hex 32
# override in host config

# 3. Build + test
nix flake check --no-build
sudo nixos-rebuild switch --flake .#aira

# 4. Verify SearXNG
curl 'http://127.0.0.1:8888/search?q=test&format=json' | jq '.results | length'

# 5. Test pipeline
search-scrape "nix package manager"
```

## Future

- **Caddy reverse proxy** for external SearXNG access
- **crawl4ai hash** — fix `lib.fakeHash` after first build
- **Engines tuning** — add/remove per use case
- **Rate limit integration** — fail2ban jail for SearXNG
