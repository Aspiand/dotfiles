{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.utils.ffm;
in

{
  options.utils.ffm = {
    enable = mkEnableOption "File/Folder Manager";
    folder = mkOption {
      type = with types; listOf (submodule {
        options = {
          path = mkOption {
            type = str;
          };

          permission = mkOption {
            type = int;
          };
        };
      });

      default = [];
      example = [
        { path = "~/.config"; permission = 755; }
        { path = "~/.local"; permission = 700; }
      ];
    }; # https://nlewo.github.io/nixos-manual-sphinx/development/option-types.xml.html#declaration-of-a-list-of-submodules
  };

  config = mkIf cfg.enable {    
    home.packages = [ (pkgs.writeShellScriptBin "ffm" (builtins.readFile ../../../sh/ffm.sh)) ]; # https://discourse.nixos.org/t/link-scripts-to-bin-home-manager/41774
    # home.file.".config/ffm/config.sh".text = '''';
  };
}