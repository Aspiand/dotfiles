{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.programs.mycli;
in

{
  options.programs.mycli = {
    enable = mkEnableOption "MyCLI";
    dir = mkOption {
      type = types.path;
      default = "${config.xdg.dataHome}/mycli";
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = [ pkgs.mycli ];
      file.".myclirc".source = ../../.myclirc;
      sessionVariables.MYCLI_HISTFILE = "${cfg.dir}/history.txt";
      shellAliases.sql = "PYTHONWARNINGS='ignore' mycli mysql://root:'bukankahinimy?'@localhost/";

      activation.mycliSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ ! -d "${cfg.dir}" ]; then
          mkdir -p "${cfg.dir}"
        fi
      '';
    };
  };
}
