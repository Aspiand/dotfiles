{ ... }:

let
  mkNirimod =
    pkgs:
    pkgs.python3Packages.callPackage (
      {
        lib,
        fetchFromGitHub,
        wrapGAppsHook4,
        gtk4,
        libadwaita,
        gdk-pixbuf,
        gobject-introspection,
        hicolor-icon-theme,
        desktop-file-utils,
        hatchling,
        pygobject3,
        buildPythonApplication,
      }:
      buildPythonApplication rec {
        pname = "nirimod";
        version = "0.1.0";

        src = fetchFromGitHub {
          owner = "srinivasr";
          repo = "nirimod";
          rev = "699483e1f809ac48402cfc200b9c0fee22a11cf1";
          sha256 = "sha256-hnTZCUABp9ruM3PWJUtfDCjOlgojd65JzflSWhZZ7IE=";
        };

        pyproject = true;

        nativeBuildInputs = [
          wrapGAppsHook4
          gobject-introspection
          desktop-file-utils
        ];

        build-system = [
          hatchling
        ];

        buildInputs = [
          gtk4
          libadwaita
          gdk-pixbuf
          hicolor-icon-theme
        ];

        dependencies = [
          pygobject3
        ];

        postInstall = ''
          install -Dm644 data/nirimod.svg $out/share/icons/hicolor/scalable/apps/nirimod.svg

          mkdir -p $out/share/applications
          cat > $out/share/applications/io.github.nirimod.desktop << EOF
          [Desktop Entry]
          Version=1.0
          Name=NiriMod
          GenericName=Compositor Settings
          Comment=GUI Configuration Manager for the Niri Wayland Compositor
          Exec=nirimod
          Icon=nirimod
          Terminal=false
          Type=Application
          Categories=Utility;Settings;DesktopSettings;
          Keywords=compositor;windowmanager;wayland;niri;settings;config;
          StartupNotify=true
          StartupWMClass=nirimod
          EOF
        '';

        meta = with lib; {
          description = "A polished GTK4/libadwaita GUI configurator for the niri Wayland compositor";
          homepage = "https://github.com/srinivasr/nirimod";
          license = licenses.mit;
          mainProgram = "nirimod";
          platforms = platforms.linux;
        };
      }
    ) { };
in
{
  flake.lib.nirimod.mkPackage = mkNirimod;

  flake.overlays.nirimod = final: _: {
    nirimod = mkNirimod final;
  };

  perSystem =
    { pkgs, ... }:
    let
      nirimod = mkNirimod pkgs;
    in
    {
      packages = {
        inherit nirimod;
      };
    };
}
