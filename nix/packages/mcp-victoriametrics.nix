/*
  ponytail: web UI skipped — only useful for HTTP mode, graceful fallback in landing.go
  ponytail: rebuild when web UI is actually needed
*/

{ ... }:

let
  mkMcpVictormetrics =
    pkgs:
    pkgs.buildGoModule rec {
      pname = "mcp-victoriametrics";
      version = "1.20.2";

      src = pkgs.fetchFromGitHub {
        owner = "VictoriaMetrics";
        repo = "mcp-victoriametrics";
        rev = "v${version}";
        hash = "sha256-7kN7qwsvTL0scfBxMO/nrvikiysUxPY8nSFkhJsgGDM=";
      };

      vendorHash = null;

      ldflags = [
        "-X main.version=v${version}"
      ];

      meta = with pkgs.lib; {
        description = "MCP server for VictoriaMetrics — query metrics, explore data, analyze alerts";
        homepage = "https://github.com/VictoriaMetrics/mcp-victoriametrics";
        license = licenses.asl20;
        mainProgram = "mcp-victoriametrics";
        platforms = platforms.linux ++ platforms.darwin;
      };
    };
in
{
  flake.overlays.mcp-victoriametrics = final: _: {
    mcp-victoriametrics = mkMcpVictormetrics final;
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.mcp-victoriametrics = mkMcpVictormetrics pkgs;
    };
}
