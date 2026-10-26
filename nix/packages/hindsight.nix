/*
  TEMPORARY VENDOR: copied from numtide/llm-agents.nix at commit ea188d2
  (packages/hindsight and packages/hindsight-control-plane) until a better
  packaging design is decided. Upstream bumps are manual; re-sync when
  updating hindsight.

  Local changes:
  - single file exporting multiple packages;
  - the control-plane font patch is inlined below instead of a separate file;
  - dropped the `flake` argument and flake.lib.maintainers;
  - the control plane duplicates version/src instead of inheriting them from
      the API package (same fetch, same store path).

  The slim API deliberately has no local ML dependencies. Set
  HINDSIGHT_API_EMBEDDINGS_PROVIDER and HINDSIGHT_API_RERANKER_PROVIDER to a
  remote provider, or build the future `hindsight-api` variant (see
  docs/hindsight.md) which adds torch/sentence-transformers.
*/
{ ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      inherit (pkgs) lib;
      pythonPackages = pkgs.python3Packages;

      version = "1.1.0";
      src = pkgs.fetchFromGitHub {
        owner = "vectorize-io";
        repo = "hindsight";
        tag = "v${version}";
        hash = "sha256-0+BuUhlf3mljlo9F9cVLcnOORZhMlK1mFY7Cqem6oYs=";
      };

      # packages/hindsight-control-plane/local-fonts.patch, inlined so this
      # stays a single file while the temporary vendor lives here.
      localFontsPatch = pkgs.writeText "hindsight-local-fonts.patch" ''
        --- a/hindsight-control-plane/src/app/[locale]/layout.tsx
        +++ b/hindsight-control-plane/src/app/[locale]/layout.tsx
        @@ -1,4 +1,4 @@
        -import { Inter, JetBrains_Mono } from "next/font/google";
        +import localFont from "next/font/local";
         import { NextIntlClientProvider, hasLocale } from "next-intl";
         import { setRequestLocale } from "next-intl/server";
         import { notFound } from "next/navigation";
        @@ -12,15 +12,15 @@
         // before paint. The Google Fonts @import this replaces loaded weights lazily,
         // which made semibold headings render in the system fallback until the weight
         // arrived. --font-sans / --font-mono are consumed by globals.css.
        -const inter = Inter({
        -  subsets: ["latin"],
        -  weight: ["400", "500", "600", "700"],
        +const inter = localFont({
        +  src: "./fonts/InterVariable.ttf",
        +  weight: "100 900",
           variable: "--font-sans",
           display: "swap",
         });

        -const jetbrainsMono = JetBrains_Mono({
        -  subsets: ["latin"],
        -  weight: ["400", "500"],
        +const jetbrainsMono = localFont({
        +  src: "./fonts/JetBrainsMono-Variable.ttf",
        +  weight: "100 800",
           variable: "--font-mono",
           display: "swap",
         });
      '';

      # PyPI publishes no sdist for this one, and the version is only injected
      # at publish time.
      github-copilot-sdk = pythonPackages.buildPythonPackage rec {
        pname = "github-copilot-sdk";
        version = "1.0.13";

        format = "wheel";

        src = pkgs.fetchPypi {
          pname = "github_copilot_sdk";
          inherit version format;
          dist = "py3";
          python = "py3";
          hash = "sha256-lB3VtVzzK6Vcc8ZRBSpKUrJZtHDGi/amrD0kDCNUAsk=";
        };

        dependencies = with pythonPackages; [
          python-dateutil
          pydantic
          httpx
        ];

        pythonImportsCheck = [ "copilot" ];

        meta = with lib; {
          description = "Python SDK for GitHub Copilot CLI";
          homepage = "https://github.com/github/copilot-sdk";
          license = licenses.mit;
        };
      };

      toktok-rs = pythonPackages.buildPythonPackage rec {
        pname = "toktok-rs";
        version = "0.3.0";
        pyproject = true;

        src = pkgs.fetchPypi {
          pname = "toktok_rs";
          inherit version;
          hash = "sha256-qQEGxQgC+UuIVBa2Z73i2yPwd49+pgKgQL1usBWom5w=";
        };

        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          inherit pname version src;
          hash = "sha256-2MXam95XcTOqBgaVZep/ewmqhV/vq3kMLBGj/4PogSc=";
        };

        nativeBuildInputs = with pkgs.rustPlatform; [
          cargoSetupHook
          maturinBuildHook
        ];

        pythonImportsCheck = [ "toktok" ];

        meta = with lib; {
          description = "Fast, exact BPE tokenizer for OpenAI encodings";
          homepage = "https://github.com/vectorize-io/toktok";
          license = licenses.mit;
        };
      };

      localMlDeps = with pythonPackages; [
        sentence-transformers
        transformers
        tokenizers
        torch
        einops
        safetensors
      ];

      mkHindsight =
        localMl:
        pythonPackages.buildPythonApplication rec {
          pname = "hindsight";
          inherit version src;

          sourceRoot = "${src.name}/hindsight-api-slim";
          pyproject = true;

          build-system = [ pythonPackages.hatchling ];

          dependencies =
            with pythonPackages;
            [
              asyncpg
              python-dotenv
              openai
              pydantic
              rich
              fastapi
              uvicorn
              wsproto
              sqlalchemy
              alembic
              pgvector
              greenlet
              psycopg2
              toktok-rs
              httpx
              pyjwt
              fastmcp
              python-dateutil
              opentelemetry-api
              opentelemetry-sdk
              opentelemetry-instrumentation-fastapi
              opentelemetry-exporter-prometheus
              opentelemetry-exporter-otlp-proto-http
              opentelemetry-semantic-conventions
              dateparser
              regex
              google-genai
              google-auth
              anthropic
              typer
              cohere
              litellm
              markitdown
              obstore
              uvloop
              pyasn1
              urllib3
              protobuf
              pillow
              cryptography
              filelock
              authlib
              orjson
              python-multipart
              aiohttp
              pygments
              boto3
              json-repair
              claude-agent-sdk
              github-copilot-sdk
              croniter
              numpy
            ]
            ++ fastapi.optional-dependencies.standard
            ++ lib.concatMap (extra: markitdown.optional-dependencies.${extra}) [
              "pdf"
              "docx"
              "pptx"
              "xlsx"
              "xls"
            ]
            ++ lib.optionals localMl localMlDeps;

          # nixpkgs lags slightly behind these floors.
          pythonRelaxDeps = [
            "boto3"
            "greenlet"
            "json-repair"
            # Capped on macOS only because newer releases ship no wheels there.
            "litellm"
            "opentelemetry-api"
            "opentelemetry-exporter-otlp-proto-http"
            "opentelemetry-exporter-prometheus"
            "opentelemetry-instrumentation-fastapi"
            "opentelemetry-sdk"
            "opentelemetry-semantic-conventions"
            "regex"
          ];

          postPatch = ''
            substituteInPlace pyproject.toml \
              --replace-fail 'psycopg2-binary' 'psycopg2'
          '';

          # The tests need a PostgreSQL container.
          doCheck = false;

          pythonImportsCheck = [ "hindsight_api.main" ];

          passthru.category = "AI Assistants";

          meta = with lib; {
            description =
              "Agent memory server that learns from past interactions"
              + lib.optionalString (!localMl) " (slim, no local ML models)";
            homepage = "https://github.com/vectorize-io/hindsight";
            changelog = "https://github.com/vectorize-io/hindsight/releases/tag/v${version}";
            license = licenses.mit;
            sourceProvenance = with sourceTypes; [ fromSource ];
            mainProgram = "hindsight-api";
            platforms = platforms.unix;
          };
        };

      hindsight-api-slim = mkHindsight false;
      hindsight-api = mkHindsight true;

      hindsight-control-plane = pkgs.buildNpmPackage {
        pname = "hindsight-control-plane";
        inherit version src;

        npmDepsFetcherVersion = 2;
        npmDepsHash = "sha256-Rr4Ux7mRo0zkcnMwN3DdSg967sYhZSsy7tKwSpqZC1A=";

        nativeBuildInputs = [ pkgs.makeWrapper ];

        # next/font/google downloads the fonts at build time.
        patches = [ localFontsPatch ];

        postPatch = ''
          # npm omitted these for two nested packages, so they cannot be prefetched.
          ${lib.getExe pkgs.jq} '
            .packages["hindsight-control-plane/node_modules/@types/node"] += {
              resolved: "https://registry.npmjs.org/@types/node/-/node-24.10.1.tgz",
              integrity: "sha512-GNWcUTRBgIRJD5zj+Tq0fKOJ5XZajIiBroOF0yvj2bSU1WvNdYS/dn9UxwsujGW4JX06dnHyjV2y9rRaybH0iQ=="
            }
            | .packages["hindsight-docs/node_modules/typescript"] += {
              resolved: "https://registry.npmjs.org/typescript/-/typescript-5.6.3.tgz",
              integrity: "sha512-hjcS1mhfuyi4WW8IWtjP7brDrG2cuDZukyrYrSauoXGNgx0S7zceP07adYkJycEr56BOUTNPzbInooiN3fn1qw=="
            }
          ' package-lock.json > package-lock.json.tmp
          mv package-lock.json.tmp package-lock.json

          fonts='hindsight-control-plane/src/app/[locale]/fonts'
          install -Dm644 ${pkgs.inter}/share/fonts/truetype/InterVariable.ttf -t "$fonts"
          install -Dm644 '${pkgs.jetbrains-mono}/share/fonts/truetype/JetBrainsMono[wght].ttf' \
            "$fonts/JetBrainsMono-Variable.ttf"

          substituteInPlace hindsight-control-plane/bin/cli.js \
            --replace-fail "spawn('node'," "spawn('${lib.getExe pkgs.nodejs}',"
        '';

        # The root prepare script installs git hooks.
        npmInstallFlags = [ "--ignore-scripts" ];
        npmRebuildFlags = [ "--ignore-scripts" ];
        npmWorkspace = "hindsight-control-plane";

        env.NEXT_TELEMETRY_DISABLED = "1";

        # npmConfigHook only patches the root node_modules.
        preBuild = ''
          patchShebangs hindsight-*/node_modules hindsight-*/*/node_modules
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out/lib/hindsight-control-plane
          cp -r hindsight-control-plane/{bin,standalone} $out/lib/hindsight-control-plane/
          makeWrapper ${lib.getExe pkgs.nodejs} $out/bin/hindsight-control-plane \
            --add-flags $out/lib/hindsight-control-plane/bin/cli.js

          runHook postInstall
        '';

        passthru.category = "AI Assistants";

        meta = with lib; {
          description = "Web UI for the Hindsight agent memory server";
          homepage = "https://github.com/vectorize-io/hindsight";
          changelog = "https://github.com/vectorize-io/hindsight/releases/tag/v${version}";
          license = licenses.mit;
          sourceProvenance = with sourceTypes; [ fromSource ];
          mainProgram = "hindsight-control-plane";
          platforms = platforms.unix;
        };
      };
    in
    {
      packages = {
        inherit
          hindsight-api
          hindsight-api-slim
          hindsight-control-plane
          ;
      };
    };
}
