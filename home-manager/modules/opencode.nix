{ config, pkgs, ... }:

{
  programs.opencode = {
    enableMcpIntegration = true;

    settings = {
      permissions = {
        allow = [
          "Bash(nix build *)"
          "Bash(nix eval *)"
          "Read"
          "WebSearch"
          "mcp__plugin_claude-code-home-manager_codegraph__codegraph_explore"
          "mcp__plugin_claude-code-home-manager_codegraph__codegraph_files"
          "mcp__plugin_claude-code-home-manager_nixos__nix"
          "mcp__plugin_claude-code-home-manager_deepwiki__read_wiki_structure"
          "mcp__plugin_claude-code-home-manager_deepwiki__read_wiki_contents"
          "mcp__plugin_claude-code-home-manager_deepwiki__ask_question"
          "mcp__plugin_claude-code-home-manager_fetch__fetch"
          "mcp__plugin_mempalace_mempalace__mempalace_status"
          "mcp__plugin_mempalace_mempalace__mempalace_list_rooms"
        ];
        defaultMode = "default";
      };
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
      effortLevel = "low";
      skipWorkflowUsageWarning = true;
    };

    tui = {
      theme = "dark";
      editorMode = "normal";
      preferredNotifChannel = "notifications_disabled";
    };

    extraPackages = with pkgs; [
      mempalace
    ];

    context = ''
      You are Aspian's opencode agent.
    '';
  };
}
