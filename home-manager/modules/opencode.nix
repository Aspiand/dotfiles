{ config, pkgs, ... }:

{
  programs.opencode = {
    enableMcpIntegration = true;

    extraPackages = with pkgs; [
      codegraph
      mempalace
    ];

    settings = {
      autoshare = false;
      autoupdate = true;
      effortLevel = "low";
      skipWorkflowUsageWarning = true;
      # permission = {
      #   bash = true;
      #   read = true;
      #   write = true;
      #   websearch = true;
      # };
      worktree = {
        baseRef = "fresh";
      };
      enabledPlugins = {
        "impeccable@impeccable" = true;
        "agent-skills@addy-agent-skills" = true;
        "context7@claude-plugins-official" = true;
        "ponytail@ponytail" = true;
        "mempalace@mempalace" = true;
        "understand-anything@understand-anything" = true;
        "planning-with-files@planning-with-files" = true;
      };
      extraKnownMarketplaces = {
        impeccable = {
          source = {
            source = "github";
            repo = "pbakaus/impeccable";
          };
        };
        ponytail = {
          source = {
            source = "github";
            repo = "DietrichGebert/ponytail";
          };
        };
        mempalace = {
          source = {
            source = "github";
            repo = "MemPalace/mempalace";
          };
        };
        understand-anything = {
          source = {
            source = "github";
            repo = "Egonex-AI/Understand-Anything";
          };
        };
        addy-agent-skills = {
          source = {
            source = "github";
            repo = "addyosmani/agent-skills";
          };
        };
        planning-with-files = {
          source = {
            source = "github";
            repo = "OthmanAdi/planning-with-files";
          };
        };
      };

      providers = {
        "9router" = {
          npm = "@ai-sdk/openai-compatible";
          name = "My 9router";
          options = {
            baseURL = "https://9router.astrapia-kokanue.ts.net/v1";
            apiKey = "{env:NINEROUTER_API_KEY}"; # TODO: sops
          };
        };
      };
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
