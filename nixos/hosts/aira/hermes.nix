# https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/configuration.md

{ pkgs, ... }:

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

    container = {
      enable = true;
      image = "ubuntu:26.04";
      backend = "docker";
      hostUsers = [ "ao" ];
      extraOptions = [
        "--env" # Prepend Nix per-user profile to PATH so extraPackages are available inside container
        "PATH=/nix-user-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
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

      markitdown = {
        command = "markitdown-mcp";
        args = [ ];
      };

      nixos = {
        command = "mcp-nixos";
        args = [ ];
      };

      headroom = {
        command = "headroom";
        args = [ "mcp" "serve" ];
      };

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

      context7 = {
        command = "context7-mcp";
        args = [ ];
        env = {
          CONTEXT7_API_KEY = "\${CONTEXT7_API_KEY}";
        };
      };
    };

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

      # Document processing
      mcp-nixos # MCP server: NixOS packages, options, flakes, wiki, noogle, nixhub — 2 tools (nix, nix_versions)
      python314Packages.markitdown # convert PDF/Office/HTML/audio -> Markdown (nixpkgs)
      markitdown-mcp # MCP server wrapping markitdown — exposes convert_to_markdown
      context7-mcp
      headroom # context compression: 60-95% token reduction, MCP server

      gh
      git
      gitui
      nodejs-slim
    ];
    # restart = "always";
    # restartSec = 5;
  };

  users.users.hermes.extraGroups = [ "users" ];
  security.sudo.extraRules = [
    {
      users = [ "hermes" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/docker";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
