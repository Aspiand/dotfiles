{ ... }:

{
  perSystem =
    { pkgs, ... }:
    {
      packages.actual-mcp = pkgs.buildNpmPackage rec {
        pname = "actual-mcp";
        version = "1.15.0";
        src = pkgs.fetchFromGitHub {
          owner = "s-stefanov";
          repo = "actual-mcp";
          rev = "eea266fd0c2d48628a0d9fe50e2568f9c82e779f";
          hash = "sha256-1cqwWEBpwlY0lI+e6ao5lPBsOk7eEbJvf/tmt4ulhfA=";
        };
        npmDepsHash = "sha256-OSTLW6dTG/7136GiU6xNR010sg73MOxsqTLgE4wvdtY=";
        nativeBuildInputs = with pkgs; [
          python3
          pkg-config
        ];
        buildInputs = with pkgs; [
          sqlite
        ];
        # better-sqlite3 (transitive via @actual-app/api) must compile from source
        npmFlags = [ "--build-from-source" ];
        makeCacheWritable = true;
        meta = with pkgs.lib; {
          description = "MCP server for Actual Budget — bridge @actual-app/api to MCP protocol";
          homepage = "https://github.com/s-stefanov/actual-mcp";
          license = licenses.mit;
          mainProgram = "actual-mcp";
          platforms = platforms.linux ++ platforms.darwin;
        };
      };
    };
}
