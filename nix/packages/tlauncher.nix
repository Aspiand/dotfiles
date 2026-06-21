{ ... }:

let
  mkTLauncher =
    pkgs:
    pkgs.callPackage (
      {
        lib,
        stdenv,
        unzip,
        makeDesktopItem,
        copyDesktopItems,
        makeWrapper,
        jre,
      }:
      stdenv.mkDerivation rec {
        pname = "tlauncher";
        version = "2.9319";

        src = pkgs.fetchurl {
          url = "https://tlauncher.org/jar";
          hash = "sha256-xht2qWiXbOi6ezHziEcSVCxN6BPKDG8yQZSvULnLRW8=";
        };

        dontUnpack = true;

        nativeBuildInputs = [
          unzip
          makeWrapper
          copyDesktopItems
        ];

        desktopItems = [
          (makeDesktopItem {
            name = "tlauncher";
            exec = "tlauncher";
            icon = "tlauncher";
            desktopName = "TLauncher";
            comment = meta.description;
            categories = [ "Game" ];
          })
        ];

        installPhase = ''
          runHook preInstall

          mkdir -p $out/share/tlauncher
          unzip -j $src "TLauncher.jar" -d $out/share/tlauncher
          mv $out/share/tlauncher/TLauncher.jar $out/share/tlauncher/tlauncher.jar

          makeWrapper ${jre}/bin/java $out/bin/tlauncher \
            --add-flags "-jar $out/share/tlauncher/tlauncher.jar"

          runHook postInstall
        '';

        meta = with lib; {
          description = "Custom Minecraft Launcher";
          homepage = "https://tlauncher.org";
          license = licenses.unfree;
          platforms = platforms.linux;
          mainProgram = "tlauncher";
        };
      }
    ) { };
in
{
  flake.overlays.tlauncher = final: _: {
    tlauncher = mkTLauncher final;
  };

  perSystem =
    { pkgs, ... }:
    let
      tlauncher = mkTLauncher pkgs;
    in
    {
      packages = {
        inherit tlauncher;
      };
    };
}
