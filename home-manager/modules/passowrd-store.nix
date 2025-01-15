{ config, pkgs, lib, ... }:

with lib;

{
  options.programs.password-store.dir = mkOption {
    type = types.path;
    default = "${config.xdg.dataHome}/password_store";
  };

  config = mkIf config.programs.password-store.enable {
    programs.password-store.settings = {
      PASSWORD_STORE_CLIP_TIME = "120";
      PASSWORD_STORE_GENERATED_LENGTH = "12";
      PASSWORD_STORE_DIR = cfg.dir;
    };

    home.activation.passSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -d '${dir}' ]; then
        find ${dir} -type d -not -perm "700" -exec chmod -v 700 {} \;
        find ${dir} -type f -not -perm "600" -exec chmod -v 600 {} \;
      fi
    '';
  };
}