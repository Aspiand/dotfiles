{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.programs.password-store;
in

{
  options.programs.password-store.dir = mkOption {
    type = types.path;
    default = "${config.xdg.dataHome}/password_store";
  };

  config = mkIf cfg.enable {
    programs.password-store = {
      package = pkgs.pass.withExtensions (
        exts: with exts; [
          pass-import
          # pass-otp
        ]
      );

      settings = {
        PASSWORD_STORE_CLIP_TIME = mkDefault "120";
        PASSWORD_STORE_GENERATED_LENGTH = mkDefault "24";
        PASSWORD_STORE_DIR = cfg.dir;
      };
    };

    home.activation.passSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -d '${cfg.dir}' ]; then
        find ${cfg.dir} -type d -not -perm "700" -exec chmod -v 700 {} \;
        find ${cfg.dir} -type f -not -perm "600" -exec chmod -v 600 {} \;
      fi
    '';
  };
}
