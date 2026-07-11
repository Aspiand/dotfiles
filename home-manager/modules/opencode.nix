{ config, pkgs, ... }:

{
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;

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
      worktree = {
        baseRef = "fresh";
      };
      enabledPlugins = {
        "agent-skills@addy-agent-skills" = true;
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
        addy-agent-skills = {
          source = {
            source = "github";
            repo = "addyosmani/agent-skills";
          };
        };
      };
      effortLevel = "low";
      skipWorkflowUsageWarning = true;
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
