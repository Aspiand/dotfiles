{
  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    stateDir = "/var/lib/hermes";
    extraDependencyGroups = [ "messaging" ];

    container = {
      enable = true;
      image = "ubuntu:26.04";
      backend = "docker";
      hostUsers = [ "ao" ];
      extraVolumes = [
        "/home/ao/Kode:/host/Kode:rw"
        "/home/ao/.config/dotfiles:/host/dotfiles:rw"

        # TODO: later
        # "/:/host:ro"
      ];
    };

    configFile = /home/ao/backup-hermes/home/config.yaml;
    environmentFiles = [ "/home/ao/backup-hermes/home/.env" ];

    settings = {
      # model = {
      #   default = "combo-name";
      #   provider = "9router";
      # };

      # providers = {
      #   # TODO: use sops
      #   "9router" = {
      #     base_url = "http://127.0.0.1:20128/v1";
      #     api_key = "";
      #   };
      # };

      # fallback_providers = [
      #   {
      #     provider = "openrouter";
      #     model = "deepseek-v4-flash";
      #   }
      # ];

      # auxiliary = {
      #   vision.provider = "auto";
      #   compression.provider = "auto";
      #   web_extract.provider = "auto";
      # };

      discord = {
        require_mention = false;
        reactions = true;
        auto_thread = false;
        history_backfill = true;
        history_backfill_limit = 50;
      };

      terminal = {
        backend = "local";
        timeout = 180;
        persistent_shell = true;
      };

      toolsets = [ "all" ];

      agent = {
        max_turns = 90;
        gateway_timeout = 1800;
      };

      # security = {
      #   redact_secrets = true;
      #   tirith_enabled = true;
      # };

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
      #   max_iterations = 50;
      #   reasoning_effort = "medium";
      # };

      # approvals = {
      #   mode = "manual";
      #   timeout = 60;
      # };
    };

    # documents.USER.md = ./USER.md;

    # mcpServers.filesystem = {
    #   command = "npx";
    #   args = [ "-y" "@modelcontextprotocol/server-filesystem" "/data/workspace" ];
    # };

    # extraPackages = [ pkgs.pandoc pkgs.imagemagick ];
    # restart = "always";
    # restartSec = 5;
  };
}
