{ ... }:

let
  mkPake =
    pkgs:
    pkgs.stdenv.mkDerivation (finalAttrs: {
      pname = "pake";
      version = "3.11.7";

      src = pkgs.fetchFromGitHub {
        owner = "tw93";
        repo = "Pake";
        rev = "9783d7ef3927494c79f8eb8ad9320645f182e39f";
        hash = "sha256-kAh6y+y04POPBqpx8TEdXqc3inOuQkr3Mu5kFQODC7o=";
      };

      nativeBuildInputs = [
        pkgs.nodejs
        pkgs.pnpm_10_29_2
        pkgs.pnpmConfigHook
        pkgs.jq
      ];

      pnpmDeps = pkgs.fetchPnpmDeps {
        inherit (finalAttrs) pname version src;
        hash = "sha256-YZZTzZQe2U/Uxu90yWHdamfKPByl8kl72/gata0LQpA=";
        pnpm = pkgs.pnpm_10_29_2;
        fetcherVersion = 3;
      };

      prePatch = ''
        # Remove overrides that cause issues and packageManager field that triggers pnpm self-downloads
        jq 'del(.pnpm.overrides, .overrides, .packageManager)' package.json > package.json.tmp
        mv package.json.tmp package.json
      '';

      # Fix for pnpm 10+ trying to download itself based on packageManager field
      PNPM_MANAGE_PACKAGE_MANAGER_VERSIONS = "false";

      buildPhase = ''
        runHook preBuild
        pnpm run cli:build
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        cp dist/cli.js $out/bin/pake
        chmod +x $out/bin/pake
        runHook postInstall
      '';

      meta = with pkgs.lib; {
        description = "Turn any webpage into a desktop app with Rust";
        homepage = "https://github.com/tw93/Pake";
        license = licenses.mit;
        mainProgram = "pake";
        platforms = platforms.linux ++ platforms.darwin;
      };
    });
in
{
  flake.lib.pake.mkPackage = mkPake;

  flake.overlays.pake = final: _: {
    pake = mkPake final;
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.pake = mkPake pkgs;
    };
}
