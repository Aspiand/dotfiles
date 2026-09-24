{ ... }:

let
  mkPackage =
    pkgs:
    let
      pname = "presenton";
      version = "0.9.11-beta";
      src = pkgs.fetchurl {
        url = "https://github.com/presenton/presenton/releases/download/electron-v${version}/Presenton-${version}.AppImage";
        hash = "sha256-fpxymHItF8TVZYwAKhfVOzZebPoTZvdxzHSv9OWXZVQ=";
      };

      appimageContents = pkgs.appimageTools.extractType2 {
        inherit pname version src;
      };
    in
    pkgs.appimageTools.wrapType2 {
      inherit pname version src;

      extraInstallCommands = ''
        mkdir -p $out/share/applications
        cp ${appimageContents}/*.desktop $out/share/applications/ 2>/dev/null || true
        for f in $out/share/applications/*.desktop; do
          sed -i "s|Exec=.*|Exec=$out/bin/presenton %U|" "$f" 2>/dev/null || true
        done

        mkdir -p $out/share/icons/hicolor
        cp -r ${appimageContents}/usr/share/icons/hicolor/* $out/share/icons/hicolor/ 2>/dev/null || true
      '';

      meta = with pkgs.lib; {
        description = "Open-source AI presentation generator";
        homepage = "https://github.com/presenton/presenton";
        license = licenses.asl20;
        platforms = [ "x86_64-linux" ];
        mainProgram = "presenton";
      };
    };
in
{
  flake.overlays.presenton = final: _: {
    presenton = mkPackage final;
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.presenton = mkPackage pkgs;
    };
}
