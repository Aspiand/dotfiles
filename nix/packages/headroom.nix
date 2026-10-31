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
        version = "0.42.0";
        pyproject = true;
        src = pkgs.fetchFromGitHub {
          owner = "headroomlabs-ai";
          repo = "headroom";
          tag = "v${version}";
          hash = "sha256-QtC+51i9SOH/Ny87yaO1glI0VM1ryeBKysDV2lnwcUw=";
        };
        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          inherit pname version src;
          hash = "sha256-BaKBsURxgXkdkIr9OwObm6J10Rd7YjhTXA4D9QHNLpE=";
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
          # Declared in the wheel's Requires-Dist; pythonRuntimeDepsCheckHook fails without it.
          ast-grep-cli
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
