{ config, pkgs, ... }:

{
  # Live-editable config, merged over the Nix-generated one.
  # opencode merges ~/.config/opencode/opencode.json (from HM) then OPENCODE_CONFIG.
  home.sessionVariables.OPENCODE_CONFIG = "${./../../.config/opencode/opencode.json}";

  programs.opencode = {
    enableMcpIntegration = true;
    # OPENCODE_EXPERIMENTAL_LSP_TOOL=true

    settings = {
      autoupdate = false;
      lsp = true;
      formatter = true;
      compaction.auto = true;
      snapshot = true;
      snapshots = true;
      subagent_depth = 1;
      server.port = 4096;

      plugins = [
        "@firecrawl/opencode"
        "@upstash/context7-opencode"
        "opencode-wakatime"
        "opencode-models-discovery@2.0.0"
      ];

      providers."9router" = {
        name = "9router";
        package = "@opencode-ai/ai/providers/openai-compatible";
        settings = {
          baseURL = "https://9router.astrapia-kokanue.ts.net/v1";
          # apiKey = "{env:NINEROUTER_API_KEY}"; # TODO: sops
          apiKey = "sk-dc180c793b48d514-ex6dld-418a87bd";
          modelsDiscovery = {
            enabled = true;
            cache = {
              enabled = true;
              ttlSeconds = 86400;
            };
          };
        };
      };

      websearch.provider = "firecrawl";

      policies = [
        {
          action = "tool.use";
          resource = {
            shell = "sudo *";
            effect = "deny";
          };
        }
      ];

      permission = {
        "*" = "ask";

        edit = "allow";
        grep = "allow";
        glob = "allow";
        lsp = "allow";
        skill = "allow";
        webfetch = "allow";
        question = "allow";
        websearch = "allow";
        # task, doom_loop: left at "ask"

        shell = {
          "*" = "ask";
          "git *" = "allow";
          "git commit *" = "deny";
          "git push *" = "deny";
          "rm *" = "deny";
        };

        read = {
          "*" = "allow";
          "*.env" = "deny";
          "*.env.*" = "deny";
          "*.env.example" = "allow";
        };

        "codegraph_*" = "allow";
        "deepwiki_*" = "allow";
        "fetch_*" = "allow";
        "github_*" = "allow";
        "markitdown_*" = "allow";
        "mempalace_*" = "allow";
        "nixos_*" = "allow";
      };

      # permissions = [
      #   {
      #     action = "websearch";
      #     resource = "*";
      #     effect = "allow";
      #   }
      # ];
    };

    tui = {
      theme = "dark";
      editorMode = "normal";
      # preferredNotifChannel = "notifications_disabled";
    };

    context = ''
      You are Aspian's opencode agent.
    '';
  };
}
