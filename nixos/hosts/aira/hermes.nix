# https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/configuration.md

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.hermes-agent;
in

{
  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    stateDir = "/var/lib/hermes";

    extraDependencyGroups = [
      "messaging"
      "mcp"
      # "voice"
      # "edge-tts"
    ];

    environmentFiles = [
      config.sops.secrets."hermes".path
    ];

    environment = {
      SEARXNG_URL = "http://${config.services.searx.settings.server.bind_address or "127.0.0.1"}:${
        toString (config.services.searx.settings.server.port or 8000)
      }";
    };

    container = {
      enable = true;
      image = "ubuntu:26.04";
      backend = "docker";
      hostUsers = [ "ao" ];
      extraOptions = [
        "--env" # Prepend Nix per-user profile to PATH so extraPackages are available inside container
        "PATH=/nix-user-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        "--env-file" # TODO: switch to Docker secrets (file mount) — env vars visible in `docker inspect` and /proc/*/environ
        "${config.sops.secrets.hermes.path}"
      ];
      extraVolumes = [
        "/home/ao/Kode:/host/Kode:rw"
        "/home/ao/.config/dotfiles:/host/dotfiles:rw"

        "/etc/profiles/per-user/hermes:/nix-user-profile:ro"
      ];
    };

    settings = {
      model = {
        default = "deepseek-flash";
        provider = "9router";
      };

      providers = {
        "9router" = {
          base_url = "http://127.0.0.1:20128/v1";
          api_key = "\${NINEROUTER_API_KEY}";
          default_model = "deepseek-flash";

          "deepseek-flash".context_length = 1000000;
          "sp/deepseek-v4-pro".context_length = 1000000;
        };

        "openrouter" = {
          base_url = "https://openrouter.ai/api/v1";
          default_model = "google/gemini-2.5-flash";
        };
      };

      model_aliases = {
        "deepseek-pro" = {
          model = "sp/deepseek-v4-pro";
          provider = "9router";
        };
      };

      # fallback_providers = [
      #   {
      #     provider = "openrouter";
      #     model = "deepseek-v4-flash";
      #   }
      # ];

      auxiliary = {
        web_extract = {
          provider = "9router";
          model = "web-extract";
        };

        vision = {
          provider = "9router";
          model = "vision";
        };

        compression = {
          provider = "9router";
          model = "deepseek-flash";
        };

        curator = {
          provider = "9router";
          model = "deepseek-flash";
          timeout = 600;
        };
      };

      discord = {
        require_mention = true;
        reactions = true;
        auto_thread = false;
        history_backfill = true;
        history_backfill_limit = 50;

        free_response_channels = [
          1507732195115012146 # general
          1508034432320409670 # financial
          1511874665939730563 # longrun
        ];
      };

      terminal = {
        backend = "local";
        timeout = 180;
        persistent_shell = true;
      };

      toolsets = [ "all" ];

      api_server = {
        enabled = false;
        host = "0.0.0.0";
        port = 8642;
      };

      # TODO: configure later
      agent = {
        max_turns = 90;
        gateway_timeout = 1800;
        api_max_retries = 3;
      };

      # security = {
      #   redact_secrets = true;
      #   tirith_enabled = true;
      # };

      memory = {
        memory_enabled = true;
        user_profile_enabled = true;
        provider = "holographic";
      };

      plugins = {
        hermes-memory-store = {
          auto_extract = true;
        };
      };

      compression = {
        enabled = true;
        threshold = 0.7;
        target_ratio = 0.5;
      };

      # display = {
      #   personality = "kawaii";
      #   skin = "default";
      #   streaming = false;
      # };

      # stt = {
      #   enabled = true;
      #   provider = "local";
      #   local.model = "base";
      # };

      # tts = {
      #   provider = "edge";
      #   edge.voice = "en-US-AriaNeural";
      # };

      curator = {
        enabled = true;
        interval_hours = 168; # 7 days
        min_idle_hours = 2; # wait 2h idle before running
        stale_after_days = 30; # unused 30 days → stale
        archive_after_days = 90; # unused 90 days → archive
        consolidate = false; # no LLM pass (prune-only)
        prune_builtins = true; # clean unused built-in skills
        backup = {
          enabled = true;
          keep = 5; # keep 5 recent backups
        };
      };

      delegation = {
        max_concurrent_children = 3;
        max_iterations = 50;
        reasoning_effort = "low";
      };

      # approvals = {
      #   mode = "manual";
      #   timeout = 60;
      # };

      checkpoints = {
        enabled = true;
        max_snapshots = 20;
        max_total_size_mb = 500;
        max_file_size_mb = 10;
        auto_prune = true;
        retention_days = 7;
        delete_orphans = true;
        min_interval_hours = 24;
      };

      session_reset = {
        mode = "idle";
        idle_minutes = 1440;
      };

      # TODO: configure later
      web = {
        # search_backend = "ddgs";
        search_backend = "searxng";
        searxng_url = "http://127.0.0.1:8888";
      };
    };

    # documents.USER.md = ./USER.md;

    mcpServers = {
      #   filesystem = {
      #     command = "npx";
      #     args = [
      #       "-y"
      #       "@modelcontextprotocol/server-filesystem"
      #       "/data/workspace"
      #     ];
      #   };

      markitdown = {
        command = "markitdown-mcp";
        args = [ ];
      };

      nixos = {
        command = "mcp-nixos";
        args = [ ];
      };

      # headroom = {
      #   command = "headroom";
      #   args = [
      #     "mcp"
      #     "serve"
      #   ];
      # };

      actual-budget = {
        command = "actual-mcp";
        args = [
          "--enable-write"
        ];
        env = {
          ACTUAL_SERVER_URL = "\${ACTUAL_SERVER_URL}";
          ACTUAL_PASSWORD = "\${ACTUAL_PASSWORD}";
          ACTUAL_BUDGET_SYNC_ID = "\${ACTUAL_BUDGET_SYNC_ID}";
        };
      };

      # context7 = {
      #   command = "context7-mcp";
      #   args = [ ];
      #   env = {
      #     CONTEXT7_API_KEY = "\\${CONTEXT7_API_KEY}";
      #   };
      # };

      trello = {
        command = "mcp-server-trello";
        args = [ ];
        env = {
          TRELLO_API_KEY = "\${TRELLO_API_KEY}";
          TRELLO_TOKEN = "\${TRELLO_TOKEN}";
        };
      };

      github = {
        command = "github-mcp-server";
        args = [ "stdio" "--read-only" ];
        env = {
          GITHUB_PERSONAL_ACCESS_TOKEN = "\${GITHUB_PERSONAL_ACCESS_TOKEN}";
        };
      };
    };

    extraPackages = with pkgs; [
      # Shell & CLI
      bat # cat with syntax highlight
      eza # modern ls with tree view
      ripgrep # recursive grep
      sd # find & replace (sed replacement)
      fzf # fuzzy finder
      delta # syntax-highlighted diff
      entr # run commands on file change

      # Data processing
      yq # YAML/JSON/TOML/XML/CSV processor
      jc # command output → JSON
      jo # create JSON from CLI
      gron # flatten JSON into greppable lines
      csvkit # CSV tools (cut, grep, stat, look, sql)

      # HTTP
      xh # HTTP client (curl | python3 replacement)

      # Version control
      gh
      git
      gitui

      # Nix
      nix # nix eval, flake check, nix-shell

      # Runtime
      nodejs-slim
      bun

      # MCP servers
      mcp-nixos
      markitdown-mcp
      # context7-mcp
      # headroom # context compression MCP server
      actual-mcp # Actual Budget MCP server
      mcp-server-trello # Trello MCP server
      github-mcp-server # GitHub MCP server

      # Python
      python314Packages.markitdown # document conversion
      python313Packages.youtube-transcript-api # fetch video transcripts

      # OSINT
      sherlock # username 400+ platforms
      maigret # username 3000+ sites + profile parsing
      instaloader # IG download + metadata
      holehe # email check across sites
      h8mail # email breach hunting
      bbot # OSINT automation
      exiftool # EXIF metadata read/write
    ];
    # restart = "always";
    # restartSec = 5;
  };

  # users.users.hermes.extraGroups = lib.mkIf cfg.enable [ "users" ];
  # security.sudo.extraRules = lib.mkIf cfg.enable [
  #   {
  #     users = [ "hermes" ];
  #     commands = [
  #       {
  #         command = "/run/current-system/sw/bin/docker";
  #         options = [ "NOPASSWD" ];
  #       }
  #     ];
  #   }
  # ];

  sops.secrets.hermes = {
    sopsFile = ../../../secrets/hermes.yml;
    owner = "hermes";
    group = "hermes";
    mode = "0400";
  };
}
