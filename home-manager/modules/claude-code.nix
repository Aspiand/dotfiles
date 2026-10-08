{ config, pkgs, ... }:

{
  # home.packages = [
  #   (pkgs.python3.withPackages (ps: with ps; [
  #     pyyaml
  #     python-pptx
  #     xlsxwriter
  #     skia-pathops
  #     uharfbuzz
  #     edge-tts
  #     pymupdf
  #     mammoth
  #     markdownify
  #     ebooklib
  #     nbconvert
  #     openpyxl
  #     pillow
  #     numpy
  #     requests
  #     beautifulsoup4
  #     curl-cffi
  #     google-genai
  #     flask
  #   ]))
  # ];

  programs.claude-code = {
    enableMcpIntegration = true;
    configDir = "${config.xdg.configHome}/claude";

    settings = {
      permissions = {
        allow = [
          "Bash(nix build *)"
          "Bash(nix eval *)"
          "Bash(git diff *)"
          "Bash(git log *)"
          "Bash(git status *)"
          "Read"
          "WebFetch"
          "WebSearch"
          "mcp__codegraph__codegraph_files"
          "mcp__codegraph__codegraph_search"
          "mcp__nixos__nix"
          "mcp__plugin_hm__codegraph__codegraph_files"
          "mcp__plugin_hm__codegraph__codegraph_explore"
          "mcp__plugin_hm__deepwiki__ask_question"
          "mcp__plugin_hm__deepwiki__read_wiki_contents"
          "mcp__plugin_hm__deepwiki__read_wiki_structure"
          "mcp__plugin_hm__fetch__fetch"
          "mcp__plugin_hm__nixos__nix"
          "mcp__plugin_hm__victorialogs__documentation"
          "mcp__plugin_hm__victorialogs__field_names"
          "mcp__plugin_hm__victorialogs__hits"
          "mcp__plugin_hm__victorialogs__query"
          "mcp__plugin_hm__victorialogs__streams"
          "mcp__plugin_hm__victoriametrics__metrics"
          "mcp__plugin_hm__victoriametrics__query"
          "mcp__plugin_hm__victoriametrics__query_range"
          "mcp__plugin_hm_codegraph__codegraph_explore"
          "mcp__plugin_hm_deepwiki__ask_wiki_question"
          "mcp__plugin_hm_deepwiki__read_wiki_contents"
          "mcp__plugin_hm_deepwiki__read_wiki_structure"
          "mcp__plugin_hm_fetch__fetch"
          "mcp__plugin_hm_nixos__nix"
          "mcp__plugin_hm_nixos__nix_versions"
          "mcp__plugin_hm_victorialogs__hits"
          "mcp__plugin_hm_victorialogs__query"
          "mcp__plugin_hm_victorialogs__stats_query"
          "mcp__plugin_mempalace_mempalace__mempalace_list_rooms"
          "mcp__plugin_mempalace_mempalace__mempalace_status"
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
        "agent-skills@addy-agent-skills" = true;
        "context7@upstash" = true;
        "ecc@ecc" = true;
        "firecrawl@claude-plugins-official" = true;
        "impeccable@impeccable" = true;
        "mempalace@mempalace" = true;
        # "open-code-review@open-code-review" = true;
        "planning-with-files@planning-with-files" = true;
        "ponytail@ponytail" = true;
        "pyright-lsp@claude-plugins-official" = true;
        "superpowers@claude-plugins-official" = true;
        "understand-anything@understand-anything" = true;
        "ppt-master@ppt-master" = true;
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
        ppt-master = {
          source = {
            source = "github";
            repo = "hugohe3/ppt-master";
          };
        };
        upstash = {
          source = {
            source = "github";
            repo = "upstash/context7";
          };
        };
        ecc = {
          source = {
            source = "github";
            repo = "affaan-m/ECC";
          };
        };
        open-code-review = {
          source = {
            source = "github";
            repo = "alibaba/open-code-review";
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
