#

{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.programs.mysql;
  dir = "${config.xdg.dataHome}/mysql";
in

{
  options = {
    programs.mysql = {
      enable = mkEnableOption "MySQL Server";

      package = mkOption {
        type = types.package;
        default = pkgs.percona-server;
      };

      dir = mkOption {
        type = types.path;
        default = dir;
        example = "/var/lib/mysql";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = [ cfg.package ];

      shellAliases = {
        mysql = "${cfg.package}/bin/mysql --defaults-file=${dir}/my.cnf";
        mysqld = "${cfg.package}/bin/mysqld --defaults-file=${dir}/my.cnf";
        mysqld_setup = "${cfg.package}/bin/mysqld --user ${config.home.username} --initialize-insecure --basedir=${dir} --datadir=${dir}/data --init-file=${dir}/init.sql";
      };

      file."${dir}/my.cnf".text = ''
        [mysqld]
        port=3306
        bind-address=127.0.0.1
        user=${config.home.username}

        basedir=${dir}
        datadir=${dir}/data
        socket=${dir}/mysql.sock
        pid-file=${dir}/mysql.pid
        log-error=${dir}/error.log
        general_log_file=${dir}/general.log


        [client]
        port=3306
        user=root
        password=root
        socket=${dir}/mysql.sock
      '';

      file."${dir}/init.sql".text = ''
        ALTER USER `root`@`localhost` IDENTIFIED BY `root`;
      '';
    };
  };
}