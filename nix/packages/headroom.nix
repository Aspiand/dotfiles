{ ... }:

let
  mkHeadroom =
    pkgs:
    let
      pname = "headroom-ai";
      version = "0.24.0";
      python = pkgs.python314;
      pythonPackages = pkgs.python314Packages;
    in
    pythonPackages.buildPythonApplication {
      inherit pname version;
      format = "wheel";

      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/ed/85/4a7a1c3f215b43449725583a95b7261065b808d166532549da643ed1550b/headroom_ai-${version}-cp312-cp312-manylinux_2_28_x86_64.whl";
        hash = "sha256-zqW1Hpl9bSlefCy+Z5jLRgFnVfX9DSjvc65MS5R3IWE=";
      };

      propagatedBuildInputs = with pythonPackages; [
        tiktoken
        pydantic
        litellm
        click
        rich
        opentelemetry-api
        httpx
        mcp
      ];

      buildInputs = with pkgs; [
        ast-grep
      ];

      postUnpack = ''
        cd "$sourceRoot"
        sed -i '/^Requires-Dist: ast-grep-cli/d' *.dist-info/METADATA
        cd -
      '';

      postInstall = ''
        METADATA="$out/lib/python${python.pythonVersion}/site-packages/headroom_ai-${version}.dist-info/METADATA"
        if [ -f "$METADATA" ]; then
          sed -i 's/Requires-Dist: litellm==1.82.3/Requires-Dist: litellm>=1.80.0/' "$METADATA"
        fi
      '';

      doCheck = false;

      meta = with pkgs.lib; {
        description = "Context optimization layer for LLM applications — 60-95% token reduction";
        homepage = "https://github.com/chopratejas/headroom";
        license = licenses.asl20;
        mainProgram = "headroom";
        platforms = [ "x86_64-linux" ];
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
