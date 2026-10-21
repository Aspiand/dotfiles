{ ... }:

{
  perSystem =
    { pkgs, ... }:
    let
      pythonPackages = pkgs.python313Packages;
    in
    {
      packages.headroom = pythonPackages.buildPythonPackage rec {
        pname = "headroom-ai";
        version = "0.41.0";
        pyproject = true;
        src = pkgs.fetchFromGitHub {
          owner = "headroomlabs-ai";
          repo = "headroom";
          tag = "v${version}";
          hash = "sha256-ITVrw5ruGnNI9t7pq+0Z6gsnqDDAB/5v7I3oOQM5AtE=";
        };
        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          inherit pname version src;
          hash = "sha256-RF1b24TIV3EASGfXKUHSrGgQGBUmJLYxzDEjb4fvKPo=";
        };
        nativeBuildInputs = [
          pkgs.pkg-config
          pkgs.rustPlatform.cargoSetupHook
          pkgs.rustPlatform.maturinBuildHook
          pkgs.makeWrapper
        ];
        dependencies = with pythonPackages; [
          # Base dependencies.
          tiktoken
          pydantic
          litellm
          click
          rich
          opentelemetry-api
          pyyaml
          tomlkit
          truststore
          # `[proxy]` dependencies. Keep this list in sync with upstream's
          # proxy extra; `headroom proxy` validates these imports at startup.
          fastapi
          uvicorn
          orjson
          httpx
          h2
          openai
          mcp
          magika
          zstandard
          websockets
          onnxruntime
          transformers
        ];
        postFixup = ''
          wrapProgram $out/bin/headroom \
            --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.ast-grep ]}
        '';
        doCheck = false;
        pythonImportsCheck = [
          "headroom"
          "headroom.proxy"
          "headroom.proxy.server"
        ];
        meta = with pkgs.lib; {
          description = "Context optimization layer for LLM applications — 60-95% token reduction";
          homepage = "https://github.com/headroomlabs-ai/headroom";
          license = licenses.asl20;
          mainProgram = "headroom";
          platforms = platforms.linux;
        };
      };
    };
}
