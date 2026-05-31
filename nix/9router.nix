{ ... }:

let
  mk9router =
    pkgs:
    let
      pname = "9router";
      version = "0.4.59";
      rev = "e1b821dd531b476d92b06ed11020dc465322b2f6";
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

      src = pkgs.fetchFromGitHub {
        owner = "decolua";
        repo = "9router";
        inherit rev;
        hash = "sha256-cbgmoHwDJEQ/I9N6vyFPOqY4M2DRQFD6hh7Ci3QJXjM=";
      };

      mkPackageLock =
        {
          name,
          sourceRoot ? "source",
          outputHash ? "sha256-PghmKnWL11A1LAFfuGsN7+egrMrDmdUPGiSTRdyaIEg=",
        }:
        pkgs.stdenv.mkDerivation {
          inherit name src sourceRoot;
          nativeBuildInputs = [
            nodejs
            pkgs.cacert
          ];
          outputHashAlgo = "sha256";
          outputHashMode = "flat";
          inherit outputHash;
          SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
          GODEBUG = "http2client=0";
          buildPhase = ''
            export HOME="$TMPDIR"
            npm install \
              --package-lock-only \
              --ignore-scripts \
              --no-audit \
              --no-fund \
              --loglevel=warn \
              --registry=https://registry.npmjs.org/
          '';
          installPhase = ''
            cp package-lock.json "$out"
          '';
        };

      appPackageLock = mkPackageLock {
        name = "${pname}-app-package-lock-${version}";
      };

      cliPackageLock = mkPackageLock {
        name = "${pname}-cli-package-lock-${version}";
        sourceRoot = "source/cli";
        outputHash = "sha256-fMuxy+0tfqnoXrL1G3c36mtlOJZH76MWi+b4hKErD0U=";
      };

      appNpmDeps = pkgs.fetchNpmDeps {
        inherit src;
        name = "${pname}-app-npm-deps-${version}";
        hash = "sha256-sVp5w0efPljvcHb8s1stXHdSUVWBMGxpduM5d+PyzcI=";
        postPatch = ''
          cp ${appPackageLock} package-lock.json
        '';
        env = {
          GODEBUG = "http2client=0";
        };
      };

      cliNpmDeps = pkgs.fetchNpmDeps {
        inherit src;
        name = "${pname}-cli-npm-deps-${version}";
        sourceRoot = "source/cli";
        hash = "sha256-RK0r/7inecjLM8vvGEaeNKoYoUNxhI74PGLD6K/HrRE=";
        postPatch = ''
          cp ${cliPackageLock} package-lock.json
        '';
        env = {
          GODEBUG = "http2client=0";
        };
      };
    in
    pkgs.stdenv.mkDerivation {
      inherit pname version src;

      nativeBuildInputs = with pkgs; [
        nodejs
        python3
        pkg-config
        makeWrapper
      ];

      # Upstream prefers better-sqlite3 when available, then node:sqlite on
      # Node >= 22.5, then sql.js. Using Node 22 avoids runtime network installs.
      buildInputs = [ pkgs.sqlite ];

      postPatch = ''
        cp ${appPackageLock} package-lock.json
        cp ${cliPackageLock} cli/package-lock.json

        substituteInPlace src/app/layout.js \
          --replace-fail \
          'import { Inter } from "next/font/google";' \
          'const inter = { variable: "" };' \
          --replace-fail \
          '
const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
});
' \
          ""

        substituteInPlace cli/scripts/build-cli.js \
          --replace-fail \
          'const standaloneApp = fs.existsSync(path.join(standaloneRootToUse, "server.js"))
  ? standaloneRootToUse
  : path.join(standaloneRootToUse, "app");' \
          'const standaloneCandidates = [
  standaloneRootToUse,
  path.join(standaloneRootToUse, "app"),
  path.join(standaloneRootToUse, path.basename(appDir)),
];
const standaloneApp = standaloneCandidates.find((candidate) =>
  fs.existsSync(path.join(candidate, "server.js"))
);'

        substituteInPlace cli/hooks/sqliteRuntime.js \
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

      buildPhase = ''
        runHook preBuild

        export HOME="$TMPDIR"
        export NEXT_TELEMETRY_DISABLED=1
        export npm_config_nodedir="${nodejs}"

        mkdir -p "$TMPDIR/npm-cache-app" "$TMPDIR/npm-cache-cli"
        cp -r ${appNpmDeps}/. "$TMPDIR/npm-cache-app"
        cp -r ${cliNpmDeps}/. "$TMPDIR/npm-cache-cli"
        chmod -R u+w "$TMPDIR/npm-cache-app" "$TMPDIR/npm-cache-cli"

        npm_config_cache="$TMPDIR/npm-cache-app" npm ci --offline --ignore-scripts
        patchShebangs node_modules
        (
          cd cli
          npm_config_cache="$TMPDIR/npm-cache-cli" npm ci --offline --ignore-scripts
          patchShebangs node_modules
          npm run build
        )

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        install -d "$out/libexec/9router" "$out/bin"

        cp cli/cli.js "$out/libexec/9router/"
        cp cli/package.json "$out/libexec/9router/"
        cp -r cli/app "$out/libexec/9router/"
        cp -r cli/hooks "$out/libexec/9router/"
        cp -r cli/node_modules "$out/libexec/9router/"
        cp -r cli/src "$out/libexec/9router/"

        if [ -f LICENSE ]; then
          cp LICENSE "$out/libexec/9router/"
        fi
        if [ -f README.md ]; then
          cp README.md "$out/libexec/9router/"
        fi

        patchShebangs "$out/libexec/9router"

        makeWrapper ${nodejs}/bin/node "$out/bin/9router" \
          --add-flags "$out/libexec/9router/cli.js --skip-update" \
          --prefix PATH : "${runtimePath}" \
          --set NEXT_TELEMETRY_DISABLED 1

        runHook postInstall
      '';

      passthru = {
        inherit
          appPackageLock
          cliPackageLock
          appNpmDeps
          cliNpmDeps
          ;
      };

      meta = with pkgs.lib; {
        description = "AI router and dashboard for coding tools, packaged from the upstream repository";
        homepage = "https://github.com/decolua/9router";
        license = licenses.mit;
        mainProgram = "9router";
        platforms = platforms.linux ++ platforms.darwin;
      };
    };
in
{
  flake.overlays."9router" = final: _: {
    "9router" = mk9router final;
  };

  perSystem =
    { pkgs, ... }:
    {
      packages."9router" = mk9router pkgs;
    };

  flake.nixosModules."9router" =
    { config, lib, pkgs, ... }:
    let
      cfg = config.services._9router;
      pname = "9router";
    in
    {
      options.services._9router = {
        enable = lib.mkEnableOption "9router — AI router and dashboard";

        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.${pname};
          defaultText = lib.literalExpression "pkgs.${pname}";
          description = "9router package to use.";
        };

        host = lib.mkOption {
          type = lib.types.str;
          default = "127.0.0.1";
          description = "Bind address for web UI and API.";
        };

        port = lib.mkOption {
          type = lib.types.port;
          default = 20128;
          description = "Port for web UI and API.";
        };

        dataDir = lib.mkOption {
          type = lib.types.path;
          default = "/var/lib/9router";
          description = "Data directory for logs, sessions, and state.";
        };

        environment = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          example = {
            OPENAI_API_KEY = "...";
            DATA_DIR = "/custom/path";
          };
          description = "Extra environment variables for 9router.";
        };

        openFirewall = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Open port in firewall.";
        };
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [ cfg.package ];

        systemd.tmpfiles.rules = [
          "d '${cfg.dataDir}' 0700 ${pname} ${pname} - -"
        ];

        users.users.${pname} = {
          isSystemUser = true;
          group = pname;
          home = cfg.dataDir;
          createHome = true;
        };
        users.groups.${pname} = { };

        systemd.services.${pname} = {
          description = "9router — AI router and dashboard";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            Type = "simple";
            User = pname;
            Group = pname;
            WorkingDirectory = cfg.dataDir;
            ExecStart = lib.getExe cfg.package;
            Restart = "on-failure";
            RestartSec = 5;
            StateDirectory = pname;
            StateDirectoryMode = "0700";
            NoNewPrivileges = true;
            PrivateTmp = true;
            ProtectHome = true;
            ProtectSystem = "strict";
          };

          environment = lib.recursiveUpdate {
            DATA_DIR = cfg.dataDir;
            HOST = cfg.host;
            PORT = toString cfg.port;
            NEXT_TELEMETRY_DISABLED = "1";
          } cfg.environment;
        };

        networking.firewall = lib.mkIf cfg.openFirewall {
          allowedTCPPorts = [ cfg.port ];
        };
      };
    };
}
