{
  pkgs,
  osConfig ? null,
  ...
}:

{
  programs.lutris = {
    steamPackage =
      if osConfig != null && osConfig ? programs.steam.package then
        osConfig.programs.steam.package
      else
        pkgs.steam;

    protonPackages = with pkgs; [
      # proton-ge-bin
    ];
  };
}
