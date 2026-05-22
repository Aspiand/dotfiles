{ ... }:

let
  mkOpenHuman =
    pkgs:
    let
      cefVersion = "146.0.9";
      cefPlatform = "linux64";
      cefArchDir = "cef_linux_x86_64";
      cefArchiveName =
        "cef_binary_${cefVersion}+g3ca6a87+chromium-146.0.7680.165_${cefPlatform}_minimal.tar.bz2";
      cefArchive = pkgs.fetchurl {
        url =
          "https://cef-builds.spotifycdn.com/${
            builtins.replaceStrings [ "+" ] [ "%2B" ] cefArchiveName
          }";
        hash = "sha1-3UyP+mmM0JO6jcmho6yPH6zZcuw=";
      };
      cefRpath = pkgs.lib.makeLibraryPath [
        pkgs.stdenv.cc.cc
        pkgs.glib
        pkgs.nss
        pkgs.nspr
        pkgs.atk
        pkgs.at-spi2-atk
        pkgs.libdrm
        pkgs.libglvnd
        pkgs.expat
        pkgs.libxcb
        pkgs.libxkbcommon
        pkgs.libX11
        pkgs.libXcomposite
        pkgs.libXdamage
        pkgs.libXext
        pkgs.libXfixes
        pkgs.libXrandr
        pkgs.gtk3
        pkgs.pango
        pkgs.cairo
        pkgs.alsa-lib
        pkgs.dbus
        pkgs.at-spi2-core
        pkgs.cups
        pkgs.libxshmfence
        pkgs.udev
        pkgs.libgbm
      ];
      cefRoot = pkgs.runCommand "openhuman-cef-${cefVersion}" {
        nativeBuildInputs = with pkgs; [
          gnutar
          bzip2
          patchelf
        ];
      } ''
        archive_dir="$TMPDIR/${builtins.replaceStrings [ ".tar.bz2" ] [ "" ] cefArchiveName}"
        dest="$out/${cefVersion}/${cefArchDir}"

        mkdir -p "$dest"
        tar -xjf ${cefArchive} -C "$TMPDIR"

        mv "$archive_dir/Release/"* "$dest/"
        mv "$archive_dir/Resources/"* "$dest/"
        mv "$archive_dir/CMakeLists.txt" "$dest/"
        mv "$archive_dir/cmake" "$dest/"
        mv "$archive_dir/include" "$dest/"
        mv "$archive_dir/libcef_dll" "$dest/"
        mv "$archive_dir/CREDITS.html" "$dest/"

        cat > "$dest/archive.json" <<EOF
        {
          "type": "minimal",
          "name": "${cefArchiveName}",
          "sha1": "dd4c8ffa698cd093ba8dc9a1a3ac8f1facd972ec"
        }
        EOF

        chmod -R u+w "$dest"
        patchelf --set-rpath "${cefRpath}" --add-needed libudev.so "$dest/libcef.so"
        patchelf --set-rpath "${cefRpath}" --add-needed libGL.so.1 "$dest/libGLESv2.so"
        patchelf --set-rpath "${cefRpath}" "$dest/libEGL.so"
        if [ -f "$dest/chrome-sandbox" ]; then
          patchelf --set-interpreter "$(cat $NIX_BINTOOLS/nix-support/dynamic-linker)" "$dest/chrome-sandbox"
        fi
      '';
    in
    pkgs.rustPlatform.buildRustPackage rec {
      pname = "openhuman";
      version = "0.54.0";

      src = pkgs.fetchFromGitHub {
        owner = "tinyhumansai";
        repo = "openhuman";
        rev = "v${version}";
        hash = "sha256-c/JTnBs1ZyZ4B+5QTSTl9dPKc859Z67/RFBNnKmVYOY=";
        fetchSubmodules = true;
      };

      cargoLock = {
        lockFile = "${src}/app/src-tauri/Cargo.lock";
        outputHashes = {
          "tauri-plugin-deep-link-2.4.7" = "sha256-JirDEsgPg+i/CosrEn0seVsTuBX18MtX/wcNLgS69eQ=";
          "whisper-rs-sys-0.15.0" = "sha256-gGKXecAgStesHnW6+BcX/1wig1cZqd4iNEhIGmYCohE=";
        };
      };

      cargoHash = pkgs.lib.fakeHash;

      nativeBuildInputs = with pkgs; [
        pkg-config
        cmake
        ninja
        nodejs
        pnpm_9
        pnpmConfigHook
        wrapGAppsHook3
        copyDesktopItems
        clang
        makeWrapper
      ];

      buildInputs = with pkgs; [
        openssl
        webkitgtk_4_1
        gtk3
        libsoup_3
        librsvg
        libxkbcommon
        wayland
        libX11
        libXcursor
        libXrandr
        libXi
        libXtst
        libXinerama
        libXext
        xdotool
        libevdev
        udev
        alsa-lib
        dbus
        at-spi2-core
        llvmPackages.libclang.lib
        pango
        cairo
        gdk-pixbuf
        glib
        libglvnd
        libgbm
      ];

      LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
      CEF_PATH = cefRoot;

      pnpmDeps = pkgs.fetchPnpmDeps {
        inherit pname version src;
        hash = "sha256-qu7TALipxOVxqeqHZecyVTX2URDoFLWYSFmGXnoq1oA=";
        fetcherVersion = 3;
        pnpm = pkgs.pnpm_9;
      };

      doCheck = false;

      cargoRoot = "app/src-tauri";
      buildAndTestSubdir = cargoRoot;

      dontUseCmakeConfigure = true;
      dontUseNinjaBuild = true;
      dontUseNinjaInstall = true;
      dontUseNinjaCheck = true;

      preBuild = ''
        pnpm build --filter openhuman-app
      '';

      postInstall = ''
        app_dir="$out/lib/openhuman"
        mkdir -p "$app_dir"

        if [ -f "$out/bin/OpenHuman" ]; then
          mv "$out/bin/OpenHuman" "$app_dir/OpenHuman"
        elif [ -f "$out/bin/openhuman" ]; then
          mv "$out/bin/openhuman" "$app_dir/OpenHuman"
        fi

        ln -s ${cefRoot}/${cefVersion}/${cefArchDir}/* "$app_dir/"

        makeWrapper "$app_dir/OpenHuman" "$out/bin/openhuman" \
          --prefix LD_LIBRARY_PATH : "$app_dir:${pkgs.lib.makeLibraryPath buildInputs}" \
          --prefix PATH : "${pkgs.lib.makeBinPath [ pkgs.xdg-utils pkgs.desktop-file-utils ]}" \
          --chdir "$app_dir"
      '';

      meta = with pkgs.lib; {
        description = "Your Personal AI super intelligence";
        homepage = "https://github.com/tinyhumansai/openhuman";
        license = licenses.gpl3;
        platforms = platforms.linux;
        mainProgram = "openhuman";
      };
    };
in
{
  flake.lib.openhuman.mkPackage = mkOpenHuman;

  flake.overlays.openhuman = final: _: {
    openhuman = mkOpenHuman final;
  };

  perSystem =
    { pkgs, ... }:
    let
      openhuman = mkOpenHuman pkgs;
    in
    {
      packages = {
        inherit openhuman;
      };
    };
}
