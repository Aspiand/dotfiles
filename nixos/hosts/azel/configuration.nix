{ ... }:

{
  imports = [
    ./modules/base/core.nix
    ./modules/base/networking.nix
    ./modules/storage/boot-efi.nix
    ./modules/storage/persistence.nix
    ./modules/storage/swap.nix
    ./profiles/portable-safe.nix
    ./profiles/desktop-hyprland.nix
    ./profiles/desktop-caelestia.nix
    ./profiles/recovery.nix
  ];

  nixpkgs.overlays = [
    (_: prev: {
      material-symbols = prev.material-symbols.overrideAttrs (_: {
        postInstall = ''
          ln -sf "$out/share/fonts/TTF/MaterialSymbolsRounded.ttf" "$out/share/fonts/TTF/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf"
          ln -sf "$out/share/fonts/TTF/MaterialSymbolsOutlined.ttf" "$out/share/fonts/TTF/MaterialSymbolsOutlined[FILL,GRAD,opsz,wght].ttf"
          ln -sf "$out/share/fonts/TTF/MaterialSymbolsSharp.ttf" "$out/share/fonts/TTF/MaterialSymbolsSharp[FILL,GRAD,opsz,wght].ttf"
        '';
      });
    })
  ];
}
