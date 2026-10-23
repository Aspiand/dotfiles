{ ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      nodejs = pkgs.nodejs_22;
      runtimePath = pkgs.lib.makeBinPath [
        nodejs
        pkgs.coreutils
        pkgs.findutils
        pkgs.gnugrep
        pkgs.lsof
        pkgs.procps
        pkgs.util-linux
        pkgs.xdg-utils
      ];
    in
    {
      packages."9router" = pkgs.stdenv.mkDerivation rec {
        pname = "9router";
        version = "0.5.104";

        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/9router/-/9router-${version}.tgz";
          hash = "sha256-96CLtldJk9zxVySZhYutnojJNUJiWNh1Hs47/XDzKKc=";
        };

        nativeBuildInputs = [ pkgs.makeWrapper ];

        # Use Node's built-in node:sqlite so the CLI never npm-installs
        # better-sqlite3 into ~/.9router/runtime on first start.
        postPatch = ''
          substituteInPlace hooks/sqliteRuntime.js \
            --replace-fail \
            '  const needBetterSqlite = !hasModule("better-sqlite3") || !isBetterSqliteBinaryValid();' \
            '  const [nodeMajor, nodeMinor] = process.versions.node.split(".").map(Number);
              const hasNodeSqlite = nodeMajor > 22 || (nodeMajor == 22 && nodeMinor >= 5);
              if (hasNodeSqlite) {
                if (!silent) console.log("✓ SQLite engine ready (node:sqlite)");
                return { betterSqlite: false };
              }
              const needBetterSqlite = !hasModule("better-sqlite3") || !isBetterSqliteBinaryValid();'
        '';

        dontBuild = true;

        installPhase = ''
          runHook preInstall

          mkdir -p "$out/libexec/9router" "$out/bin"
          cp -r . "$out/libexec/9router"

          # Upstream leaks its macOS build HOME (dummy jwt-secret, machine-id, db).
          rm -rf "$out/libexec/9router/app/cli/.build-home"

          patchShebangs "$out/libexec/9router/cli.js" "$out/libexec/9router/hooks"

          # --skip-update: otherwise the CLI tries `npm i -g 9router@latest`
          # against the read-only store path.
          makeWrapper ${nodejs}/bin/node "$out/bin/9router" \
            --add-flags "$out/libexec/9router/cli.js --skip-update" \
            --prefix PATH : "${runtimePath}" \
            --set NEXT_TELEMETRY_DISABLED 1

          runHook postInstall
        '';

        meta = with pkgs.lib; {
          description = "AI router and dashboard for coding tools (official npm release)";
          homepage = "https://github.com/decolua/9router";
          license = licenses.mit;
          mainProgram = "9router";
          platforms = platforms.linux ++ platforms.darwin;
        };
      };
    };
}
