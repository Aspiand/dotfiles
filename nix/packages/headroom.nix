{ ... }:

let
  wheelUrl = "https://github.com/headroomlabs-ai/headroom/releases/download/v0.27.0/headroom_ai-0.27.0-cp310-abi3-manylinux_2_28_x86_64.whl";
  wheelHash = "sha256-ZA5npBdDJlN2WCqSaRoZKowkSO8LIWeg4UoqRYrb4t0=";
  wheelAarch64Url = "https://github.com/headroomlabs-ai/headroom/releases/download/v0.27.0/headroom_ai-0.27.0-cp310-abi3-manylinux_2_28_aarch64.whl";
  wheelAarch64Hash = "sha256-+GRVMswnAEPUP0DjFnYo2vKFC6FhCxFn30Cgy0LxQ4A=";

  mkHeadroom =
    pkgs:
    let
      python = pkgs.python313;
      pythonPackages = pkgs.python313Packages;

      isAarch64 = pkgs.stdenv.hostPlatform.isAarch64;
      selectedUrl = if isAarch64 then wheelAarch64Url else wheelUrl;
      selectedHash = if isAarch64 then wheelAarch64Hash else wheelHash;
    in
    pythonPackages.buildPythonPackage {
      pname = "headroom-ai";
      version = "0.27.0";
      format = "wheel";

      src = pkgs.fetchurl {
        url = selectedUrl;
        hash = selectedHash;
      };

      # cp310-abi3 wheel works with Python 3.10+ — including 3.13
      dontBuild = true;

      # ponytail: proxy+mcp+code base deps only. ML/memory/image skipped.
      # onnxruntime downloaded at runtime via ort-sys (permitted in Nix sandbox
      # for wheel builds — no build-time network access needed).
      propagatedBuildInputs = with pythonPackages; [
        tiktoken
        pydantic
        litellm
        click
        rich
        opentelemetry-api
        fastapi
        uvicorn
        httpx
        openai
        mcp
        websockets
        zstandard
        h2
      ];

      # ponytail: ast-grep binary provided instead of python ast-grep-cli.
      # Same CLI interface, nixpkgs pkgs.ast-grep maps to ast-grep-cli.
      postFixup = ''
        wrapProgram $out/bin/headroom \
          --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.ast-grep ]}
      '';

      doCheck = false;
      dontCheckRuntimeDeps = true;
      pythonImportsCheck = [ "headroom" ];

      meta = with pkgs.lib; {
        description = "Context optimization layer for LLM applications — 60-95% token reduction";
        homepage = "https://github.com/headroomlabs-ai/headroom";
        license = licenses.asl20;
        mainProgram = "headroom";
        platforms = platforms.linux;
      };
    };
in
{
  flake.overlays.headroom = final: _: {
    headroom = mkHeadroom final;
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.headroom = mkHeadroom pkgs;
    };
}
