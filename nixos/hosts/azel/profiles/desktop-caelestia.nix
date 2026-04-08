{ pkgs, ... }:

{
  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    systemPackages = with pkgs; [
      material-symbols
      nerd-fonts.caskaydia-cove
      rubik
    ];
  };
}
