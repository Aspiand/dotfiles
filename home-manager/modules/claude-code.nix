{ config, pkgs, ... }:

{
  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    configDir = "${config.xdg.configHome}/claude";

    settings = {
      model = "oc/deepseek-v4-flash-free";
      permissions = {
        allow = [
          "Bash(nix build *)"
          "Bash(nix eval *)"
          "WebSearch"
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
        "context7@claude-plugins-official" = true;
        "ponytail@ponytail" = true;
        "mempalace@mempalace" = true;
        "understand-anything@understand-anything" = true;
      };
      extraKnownMarketplaces = {
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
      };
      effortLevel = "low";
      skipWorkflowUsageWarning = true;
      theme = "dark";
      editorMode = "normal";
      preferredNotifChannel = "notifications_disabled";
    };
  };
}
