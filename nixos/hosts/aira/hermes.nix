# https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/configuration.md

{ pkgs, ... }:

{
  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    stateDir = "/var/lib/hermes";
    extraDependencyGroups = [
      "messaging"
      "firecrawl"
      "mcp"
      "voice"
      "edge-tts"
    ];

    container = {
      enable = true;
      image = "ubuntu:26.04";
      backend = "docker";
      hostUsers = [ "ao" ];
      extraOptions = [ ];
      extraVolumes = [
        "/home/ao/Kode:/host/Kode:rw"
        "/home/ao/.config/dotfiles:/host/dotfiles:rw"

        # TODO: later
        # "/:/host:ro"
      ];
    };

    settings = {
      model = {
        default = "main-combo";
        provider = "9router";
      };

      providers = {
        "9router" = {
          base_url = "http://127.0.0.1:20128/v1";
          api_key = "\${NINEROUTER_API_KEY}";
          default_model = "main-combo";
        };
        "openrouter" = {
          base_url = "https://openrouter.ai/api/v1";
          default_model = "google/gemini-2.5-flash";
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

        # vision.provider = "auto";
        # compression.provider = "auto";
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
        enabled = true;
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

      # TODO: configure later
      memory = {
        memory_enabled = true;
        user_profile_enabled = true;
      };

      compression = {
        enabled = true;
        threshold = 0.5;
        target_ratio = 0.2;
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

      # curator = {
      #   enabled = true;
      #   interval_hours = 168;
      # };

      # delegation = {
      #   max_concurrent_children = 5;
      #   max_iterations = 50;
      #   reasoning_effort = "medium";
      # };

      # approvals = {
      #   mode = "manual";
      #   timeout = 60;
      # };

      checkpoints = {
        enabled = false;
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

      actual-budget = {
        command = "npx";
        args = [
          "-y"
          "actual-mcp"
          "--enable-write"
        ];
        env = {
          ACTUAL_SERVER_URL = "\${ACTUAL_SERVER_URL}";
          ACTUAL_PASSWORD = "\${ACTUAL_PASSWORD}";
          ACTUAL_BUDGET_SYNC_ID = "\${ACTUAL_BUDGET_SYNC_ID}";
        };
      };
    };

    # -- CLI tools (replace ad-hoc scripts) --
    extraPackages = with pkgs; [
      # Data serialization
      yq # JSON/YAML/TOML/XML/CSV/INI -- universal processor
      jc # convert command output -> JSON
      jo # create JSON from CLI
      gron # flatten JSON into greppable format

      # HTTP / API
      xh # HTTP client with JSON support -- replace curl | python3

      # Text / file manipulation
      sd # find & replace -- replace sed for most cases
      bat # cat with syntax highlight + git markers
      ripgrep # already available via rg from Nix

      # Terminal UX
      fzf # fuzzy finder -- interactive pipe filtering
      delta # syntax-highlighted diff viewer
      glow # render markdown in terminal

      # File operations
      eza # modern ls with tree view
      entr # run commands on file change

      # Nix
      nix # nix eval, nix flake check, nix-shell for module testing

      # Tabular data
      csvkit # csvcut, csvgrep, csvstat, csvlook, csvsql
    ];
    # restart = "always";
    # restartSec = 5;
  };

  users.users.hermes.extraGroups = [ "users" ];
}
