{ config, pkgs, ... }:

{
  programs.opencode = {
    mutableSettings = false;
    enableMcpIntegration = true;
    extraPackages = with pkgs; [
      yq
    ];

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
            modelInfoFormat = "openrouter";
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

          "cat *" = "allow";

          "git branch *" = "allow";
          "git diff *" = "allow";
          "git ls-files *" = "allow";
          "git log *" = "allow";
          "git remote -v" = "allow";
          "git rev-parse *" = "allow";
          "git show *" = "allow";
          "git status *" = "allow";

          "gpg *" = "deny";

          "nix diff *" = "allow";
          "nix eval *" = "allow";
          "nix flake check *" = "allow";
          "nix flake metadata *" = "allow";
          "nix flake show *" = "allow";
          "nix fmt *" = "allow";
          "nix hash *" = "allow";
          "nix log *" = "allow";
          "nix path *" = "allow";
          "nix print-dev *" = "allow";

          "rg *" = "allow";

          "yq *" = "allow";

          "git add *" = "deny";
          "git commit *" = "deny";
          "git push *" = "deny";
          "rm *" = "deny";
          "ssh *" = "deny";
        };

        read = {
          "*" = "allow";
          "*.env" = "deny";
          "*.env.*" = "deny";
          "*.env.example" = "allow";
        };

        "codegraph_*" = "allow";
        "context7_*" = "allow";
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

      ## Code comments
      - Write inline comments in English.
      - Only comment where the code genuinely needs it. Prefer no comment over a
        redundant one.

      ## Shell tools
      - yq is available for JSON/YAML processing. Prefer it over jq/python one-liners.

      ## External knowledge
      - context7 is the default for library, framework and API documentation.
      - For anything nixpkgs / NixOS / home-manager / flakes related, use the
        nixos tools instead of guessing from memory (nixpkgs moves fast).
      - deepwiki is the fastest way to understand a specific GitHub repository:
        call read_wiki_structure first to see available topics, then use
        read_wiki_contents or ask_wiki_question.
      - A deepwiki page is an index-time snapshot, not the live repo. Always
        check when that index was last updated (the date shown by the wiki /
        repo metadata) and compare it with today's date. If the index is old,
        or the repo has clearly moved on since then, say so explicitly and
        verify the answer against the actual source (read files via codegraph /
        github tools, or fetch the upstream page) before relying on it.
      - Never present stale deepwiki-derived facts as current without that
        freshness caveat.

      ## Questions
      - When the user asks a question, answer it FIRST. Do not skip ahead
        and continue previous work before answering. After answering, only
        continue work if the user's intent is to continue; otherwise stop
        and wait.
    '';
  };
}
