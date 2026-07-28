{ ... }:

let
  mkMcpVictorialogs =
    pkgs:
    pkgs.buildGoModule rec {
      pname = "mcp-victorialogs";
      version = "1.9.0";

      src = pkgs.fetchFromGitHub {
        owner = "VictoriaMetrics";
        repo = "mcp-victorialogs";
        rev = "v${version}";
        hash = "sha256-esfd6Eg1j2BCgee1T5tiIdSPWVEBqhI4UGDKRFYyn3s=";
      };

      vendorHash = null;

      meta = with pkgs.lib; {
        description = "MCP server for VictoriaLogs — query, explore, and analyze logs";
        homepage = "https://github.com/VictoriaMetrics/mcp-victorialogs";
        license = licenses.asl20;
        mainProgram = "mcp-victorialogs";
        platforms = platforms.linux ++ platforms.darwin;
      };
    };
in
{
  flake.overlays.mcp-victorialogs = final: _: {
    mcp-victorialogs = mkMcpVictorialogs final;
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.mcp-victorialogs = mkMcpVictorialogs pkgs;
    };
}
