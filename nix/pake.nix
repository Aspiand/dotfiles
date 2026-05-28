{ lib, ... }:

let
  mkPake =
    pkgs:
    let
      inherit (pkgs) stdenv nodejs fetchFromGitHub;
      pnpm = pkgs.pnpm_10_29_2;
      src = fetchFromGitHub {
        owner = "tw93";
        repo = "Pake";
        rev = "9783d7ef3927494c79f8eb8ad9320645f182e39f";
        hash = "sha256-kAh6y+y04POPBqpx8TEdXqc3inOuQkr3Mu5kFQODC7o=";
      };
    in
    stdenv.mkDerivation {
      pname = "pake";
      version = "3.11.7";
      inherit src;

      nativeBuildInputs = [
        nodejs
        pnpm
      ];

      pnpmDeps = pkgs.fetchPnpmDeps {
        pname = "pake";
        version = "3.11.7";
        inherit src;
        fetcherVersion = 3;
        nodejs = nodejs;
        prePnpmInstall = ''
          yq -y 'del(.overrides)' pnpm-lock.yaml > pnpm-lock.yaml.tmp
          mv pnpm-lock.yaml.tmp pnpm-lock.yaml
          pnpm config set fetch-timeout 300000
          pnpm config set fetch-retries 10
          pnpm config set network-concurrency 4
        '';
        pnpmInstallFlags = [
          "--network-concurrency"
          "4"
        ];
        hash = "sha256-m18kLGJeRHFDFbXnAur0s25089P9yF/0Lg84V4S3Afs=";
      };

      buildPhase = ''
        export HOME=$(mktemp -d)
        export COREPACK_ENABLE_STRICT=0
        pnpm install --offline --frozen-lockfile --ignore-scripts
        pnpm run cli:build
      '';

      installPhase = ''
        mkdir -p $out/bin
        cp dist/cli.js $out/bin/pake
        chmod +x $out/bin/pake
      '';

      meta = with lib; {
        description = "Turn any webpage into a desktop app with Rust";
        homepage = "https://github.com/tw93/Pake";
        license = licenses.mit;
        mainProgram = "pake";
        platforms = platforms.linux ++ platforms.darwin;
      };
    };
in
{
  flake.lib.pake.mkPackage = mkPake;

  flake.overlays.pake = final: _: {
    pake = mkPake final;
  };

  perSystem =
    { pkgs, ... }:
    let
      pake = mkPake pkgs;
    in
    {
      packages = {
        inherit pake;
      };
    };
}
