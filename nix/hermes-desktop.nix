{ ... }:

let
  mkHermesDesktop =
    pkgs:
    let
      version = "0.5.1";
      src = pkgs.fetchurl {
        url = "https://github.com/fathah/hermes-desktop/releases/download/v${version}/hermes-desktop_${version}_amd64.deb";
        hash = "sha256-EbLVm74EN6/mRyHknX6R5uy7QF5p+Xoe7+9jamaKSbE=";
      };
    in
    pkgs.stdenv.mkDerivation rec {
      pname = "hermes-desktop";
      inherit version;

      inherit src;

      nativeBuildInputs = with pkgs; [
        dpkg
        makeWrapper
      ];

      buildInputs = with pkgs; [
        gtk3
        glib
        libsecret
        libxshmfence
        libgbm
        mesa
        nss
        nspr
        at-spi2-atk
        at-spi2-core
        cairo
        pango
        gdk-pixbuf
        expat
        dbus
        libdrm
        cups
        atk
        libxkbcommon
        udev
        alsa-lib
        libglvnd
        libxdamage
        libX11
        libxcb
        libxcomposite
        libxcursor
        libxext
        libxfixes
        libxi
        libxrandr
        libxrender
        libxtst
        libxscrnsaver
      ];

      unpackPhase = ''
        dpkg-deb -x $src .
      '';

      installPhase = ''
        mkdir -p $out
        cp -r usr/* $out/
        cp -r opt "$out/"
        
        # Fix desktop file
        substituteInPlace $out/share/applications/hermes-desktop.desktop \
          --replace-fail "/opt/Hermes Agent/hermes-desktop" "$out/bin/hermes-desktop"
        
        # Fix binary path
        mkdir -p $out/bin
        makeWrapper "$out/opt/Hermes Agent/hermes-desktop" "$out/bin/hermes-desktop" \
          --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath buildInputs}" \
          --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.xdg-utils ]}
      '';

      meta = with pkgs.lib; {
        description = "Desktop GUI for Hermes Agent - an open-source AI agent framework";
        homepage = "https://github.com/fathah/hermes-desktop";
        license = licenses.mit;
        maintainers = with maintainers; [ ];
        platforms = [ "x86_64-linux" ];
        mainProgram = "hermes-desktop";
      };
    };

  mkHermesDesktopFromSource =
    pkgs:
    let
      buildInputs = with pkgs; [
        gtk3
        libsecret
        nss
      ];
    in
    pkgs.electron.overrideElectronBuild pkgs (final: {
      pname = "hermes-desktop";
      version = "0.4.5"; # package.json version

      src = pkgs.fetchFromGitHub {
        owner = "fathah";
        repo = "hermes-desktop";
        rev = "main";
        hash = pkgs.lib.fakeHash;
      };

      npmDepsHash = pkgs.lib.fakeHash;

      nativeBuildInputs = with pkgs; [
        nodejs_20
        yarn
        pkg-config
        python3
      ];

      inherit buildInputs;

      buildPhase = ''
        yarn install --frozen-lockfile
        yarn build
      '';

      installPhase = ''
        mkdir -p $out/opt/hermes-desktop
        cp -r dist/linux-unpacked/* $out/opt/hermes-desktop/
        
        chmod +x $out/opt/hermes-desktop/hermes-desktop
        mkdir -p $out/bin
        makeWrapper $out/opt/hermes-desktop/hermes-desktop $out/bin/hermes-desktop \
          --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath buildInputs}"
        
        mkdir -p $out/share/applications
        cp resources/hermes-desktop.desktop $out/share/applications/
        substituteInPlace $out/share/applications/hermes-desktop.desktop \
          --replace-fail "/opt/Hermes Agent/hermes-desktop" "$out/bin/hermes-desktop"
      '';

      meta = with pkgs.lib; {
        description = "Desktop GUI for Hermes Agent - an open-source AI agent framework";
        homepage = "https://github.com/fathah/hermes-desktop";
        license = licenses.mit;
        maintainers = with maintainers; [ ];
        platforms = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        mainProgram = "hermes-desktop";
      };
    });
in
{
  flake.lib.hermes-desktop.mkPackage = mkHermesDesktop;
  flake.lib.hermes-desktop.mkPackageFromSource = mkHermesDesktopFromSource;

  flake.overlays.hermes-desktop = final: _: {
    hermes-desktop = mkHermesDesktop final;
  };

  perSystem =
    { pkgs, ... }:
    let
      hermes-desktop = mkHermesDesktop pkgs;
      hermes-desktop-source = mkHermesDesktopFromSource pkgs;
    in
    {
      packages = {
        inherit hermes-desktop;
        hermes-desktop-source = hermes-desktop-source;
      };
    };
}
