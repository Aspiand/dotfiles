# source: https://discourse.nixos.org/t/how-to-have-libgtk-4-media-gstreamer-on-nixos/

{
  pkgs,
  stdenv,
  fetchFromGitHub,
}:

{
  hanabi = stdenv.mkDerivation rec {
    pname = "gnome-ext-hanabi";
    version = "1.0.0";
    dontBuild = false;
    nativeBuildInputs = with pkgs; [
      meson
      ninja
      glib
      nodejs
      wrapGAppsHook4
      appstream-glib
      gobject-introspection
      shared-mime-info
    ];

    buildInputs = with pkgs; [
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-ugly
      gst_all_1.gst-libav
      gst_all_1.gst-vaapi
      clapper
      gjs
      gtk4
      glib
      wayland
      wayland-protocols
    ];

    dontWrapGApps = true;

    postPatch = ''
      patchShebangs build-aux/meson-postinstall.sh 
    '';

    postFixup = ''
      wrapGApp "$out/share/gnome-shell/extensions/hanabi-extension@jeffshee.github.io/renderer/renderer.js"

      ln -s "$out/share/gsettings-schemas/${pname}-${version}/glib-2.0/schemas" \
        "$out/share/gnome-shell/extensions/hanabi-extension@jeffshee.github.io/schemas"
    '';

    # git ls-remote https://github.com/jeffshee/gnome-ext-hanabi for rev
    src = fetchFromGitHub {
      owner = "jeffshee";
      repo = "gnome-ext-hanabi";
      rev = "b02101014a34ba053edaa64e2ec142d0d2f0f6f9";
      sha256 = "sha256-vhHSiQq2POHgs9wVZTWiot5PkDUlaKKrH4pOvN0v9Mg=";
    };
  };
}
