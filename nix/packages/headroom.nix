{ lib, ... }:

let
  mkHeadroom =
    pkgs:
    let
      pname = "headroom-ai";
      version = "0.23.0";
    in
    pkgs.python312Packages.buildPythonApplication {
      inherit pname version;
      format = "pyproject";

      src = pkgs.fetchPypi {
        inherit pname version;
        hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      };

      # Core runtime dependencies
      propagatedBuildInputs = with pkgs.python312Packages; [
        tiktoken
        pydantic
        litellm
        click
        rich
        opentelemetry-api
        fastapi
        uvicorn
        httpx
        mcp
        websockets
        magika
        pillow
      ];

      # System-level tools needed at runtime
      buildInputs = with pkgs; [
        ast-grep # AST-aware code slicing (CodeCompressor)
      ];

      nativeBuildInputs = with pkgs.python312Packages; [
        setuptools
        wheel
      ];

      # Skip tests — complex dependency tree with pinned versions
      doCheck = false;

      # Fix litellm version pin (headroom pins ==1.82.3)
      postPatch = ''
        substituteInPlace pyproject.toml \
          --replace-fail 'litellm==1.82.3' 'litellm>=1.80.0'
      '';

      meta = with pkgs.lib; {
        description = "Context optimization layer for LLM applications — 60-95% token reduction";
        homepage = "https://github.com/chopratejas/headroom";
        license = licenses.asl20;
        mainProgram = "headroom";
        platforms = platforms.linux ++ platforms.darwin;
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
