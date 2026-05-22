{ ... }:

let
  mkTLauncher =
    pkgs:
    let
      sources = import ./_sources/_default.nix { inherit pkgs; };
      tlauncher = sources.tlauncher;
    in
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
        inherit (tlauncher) version src;

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
  flake.lib.tlauncher.mkPackage = mkTLauncher;

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
