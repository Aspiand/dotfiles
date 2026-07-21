{ config, pkgs, ... }:

{
  programs.claude-code = {
    enableMcpIntegration = true;
    configDir = "${config.xdg.configHome}/claude";

    settings = {
      agentDefaultModel = "oc/deepseek-v4-flash-free";
      model = "oc/deepseek-v4-flash-free";
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
      hooks = {
        SessionStart = [
          {
            hooks = [
              {
                type = "command";
                command = "mempalace hook run --hook session-start --harness claude-code";
              }
            ];
          }
        ];
        Stop = [
          {
            hooks = [
              {
                type = "command";
                command = "mempalace hook run --hook stop --harness claude-code";
              }
            ];
          }
        ];
        SessionEnd = [
          {
            hooks = [
              {
                type = "command";
                command = "mempalace hook run --hook session-end --harness claude-code";
              }
            ];
          }
        ];
        PreCompact = [
          {
            hooks = [
              {
                type = "command";
                command = "mempalace hook run --hook precompact --harness claude-code";
              }
            ];
          }
        ];
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
      };
      effortLevel = "low";
      skipWorkflowUsageWarning = true;
      # statusLine = {
      #   command = "bun x ccstatusline";
      # };

      theme = "dark";
      editorMode = "normal";
      preferredNotifChannel = "notifications_disabled";
    };
  };
}
