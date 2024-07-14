{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.utils.ffm;
in

{
  options.utils.ffm = {
    enable = mkEnableOption "File/Folder Manager";
  };

  config = mkIf cfg.enable {    
    home.packages = [ (pkgs.writeShellScriptBin "ffm" (builtins.readFile ../../../sh/ffm.sh)) ]; # https://discourse.nixos.org/t/link-scripts-to-bin-home-manager/41774
  };
}