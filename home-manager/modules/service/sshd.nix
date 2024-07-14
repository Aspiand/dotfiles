{ config, pkgs, lib, ... }:

with lib; let cfg = config.service.sshd; in

{
  options.service.sshd = {
    enable = mkEnableOption "sshd";

    port = mkOption {
      type = types.port;
      default = 2222;
    };

    banner = mkOption {
      type = types.nullOr types.path;
      example = "/etc/banner";
    };

    addressFamily = mkOption {
      type = types.enum [ "any" "inet" "inet6" ];
      default = "any";
    };
  };
}