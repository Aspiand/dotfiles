{ config, pkgs, lib, ... }:

with lib;

{
  options.programs.mycli.enable = mkEnableOption "MyCLI";

  config = mkIf config.programs.mycli.enable {
    home = {
      packages = [ pkgs.mycli ];
      shellAliases.sql = "PYTHONWARNINGS='ignore' mycli mysql://root:'root'@localhost/";
      file.".myclirc".source = ../../.myclirc;
    };
  };
}