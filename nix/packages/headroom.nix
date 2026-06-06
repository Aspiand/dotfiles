let
  mkHeadroom =
    pkgs:
    let
      version = "0.23.0";

      wheel = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/4e/43/66939800ad1f4aa52f8867d2868f80a32b8724ca95b3ff76d48d5e095d47/headroom_ai-${version}-cp312-cp312-manylinux_2_28_x86_64.whl";
        hash = "sha256-pDsHMWuhgC7g5d2LeyRsA6zPx6zMiYkefZkVHkzrQyI=";
      };

      pyDeps = with pkgs.python312Packages; [
        tiktoken
        pydantic
        click
        rich
        opentelemetry-api
        httpx
        mcp
      ];

    in
    pkgs.python312Packages.buildPythonPackage rec {
      pname = "headroom";
      inherit version;

      format = "wheel";
      src = wheel;

      propagatedBuildInputs = pyDeps;

      doCheck = false;
      dontUsePythonRuntimeDepsCheck = true;

      meta = with pkgs.lib; {
        description = "Context compression layer for AI agents — 60-95% fewer tokens";
        homepage = "https://headroom-docs.vercel.app";
        license = licenses.asl20;
        maintainers = [ ];
        platforms = [ "x86_64-linux" ];
        mainProgram = "headroom";
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
