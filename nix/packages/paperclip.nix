{ ... }:

let
  mkPaperclip =
    pkgs:
    let
      pname = "paperclip";
      version = "0.3.1";
      src = pkgs.fetchFromGitHub {
        owner = "paperclipai";
        repo = "paperclip";
        rev = "ef6061a5e6e7e5ccac6cbf5bfea73aac554a95d1";
        hash = "sha256-Umlxo3tcZdP6qQjOIIBMVk0MXGajoPEcAQm3OLHzOSc=";
      };

      nodejs = pkgs.nodejs_22;
      pnpm = pkgs.pnpm_9;

      prePnpmInstall = ''
        echo "shamefully-hoist=true" >> .npmrc
      '';
    in
    pkgs.stdenv.mkDerivation {
      inherit pname version src;

      nativeBuildInputs = [
        nodejs
        pnpm
        pkgs.pnpmConfigHook
        pkgs.makeWrapper
        pkgs.python3
        pkgs.pkg-config
      ];

      buildInputs = [
        pkgs.vips
        pkgs.postgresql
      ];

      pnpmDeps = pkgs.fetchPnpmDeps {
        inherit pname version src prePnpmInstall;
        inherit pnpm;
        fetcherVersion = 3;
        hash = "sha256-dGyijgYTKJ+hb0kI1RyvR93sBOGM37FmiWEYdz+xW44=";
      };

      buildPhase = ''
        runHook preBuild
        pnpm --filter @paperclipai/shared build
        pnpm --filter @paperclipai/db build
        pnpm --filter @paperclipai/adapter-utils build
        pnpm --filter @paperclipai/plugin-sdk build
        pnpm --filter @paperclipai/ui build
        pnpm --filter @paperclipai/server build
        pnpm --filter paperclipai build
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/lib/paperclip
        cp -r node_modules package.json pnpm-workspace.yaml $out/lib/paperclip/
        for dir in cli server ui packages; do
          cp -r $dir $out/lib/paperclip/
        done

        mkdir -p $out/bin
        makeWrapper ${nodejs}/bin/node $out/bin/paperclip \
          --add-flags "$out/lib/paperclip/cli/dist/index.js" \
          --set NODE_ENV production

        makeWrapper ${nodejs}/bin/node $out/bin/paperclip-server \
          --add-flags "--import $out/lib/paperclip/server/node_modules/tsx/dist/loader.mjs" \
          --add-flags "$out/lib/paperclip/server/dist/index.js" \
          --set-default NODE_ENV production \
          --set-default SERVE_UI true \
          --set-default HOST 0.0.0.0 \
          --set-default PORT 3100 \
          --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.git pkgs.gh pkgs.ripgrep ]}

        runHook postInstall
      '';

      meta = with pkgs.lib; {
        description = "AI agent orchestration platform — orchestrate AI agent teams";
        homepage = "https://github.com/paperclipai/paperclip";
        license = licenses.mit;
        mainProgram = "paperclip";
        platforms = platforms.linux;
      };
    };
in
{
  flake.overlays.paperclip = final: _: {
    paperclip = mkPaperclip final;
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.paperclip = mkPaperclip pkgs;
    };
}
