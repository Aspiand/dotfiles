{ config, pkgs, lib, ...}:

with lib; let cfg = config.services.sshd; in

{
  options.services.sshd = {
    enable = mkEnableOption "sshd";
    dir = mkOption {
      type = types.path;
      example = "${config.home.homeDirectory}/.ssh/sshd/";
    };

    port = mkOption {
      type = types.port;
      example = "2222";
    };

    banner = mkOption {
      type = with types; either str path;
      example = ''
  ___   _                           _    
 / _ \ | |                         | |   
/ /_\ \| |  __ _  _ __ ___    __ _ | | __
|  _  || | / _` || '_ ` _ \  / _` || |/ /
| | | || || (_| || | | | | || (_| ||   < 
\_| |_/|_| \__,_||_| |_| |_| \__,_||_|\_\
      '';
    };

    addressFamily = mkOption {
      type = types.enum [ "any" "inet" "inet6" ];
      default = "any";
    };

    passwordLogin = mkOption {
      type = types.bool;
      default = false;
    };

    rootLogin = mkOption {
      type = types.bool;
      default = false;
    };

    keyAuthentication = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.openssh ];
    home.shellAliases = {
      sshd = "$(which sshd) -f ${cfg.dir}/sshd_config";
      sshd_stop = "kill $(cat ${cfg.dir}/sshd.pid)";
    };

    home.activation.sshd_setup = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -d "${cfg.dir}" ]; then
        mkdir -pvm "700" ${cfg.dir}
      fi

      if [ ! -f "${cfg.dir}/ssh_host_rsa_key" ]; then
        ssh-keygen -t rsa -f ${cfg.dir}/ssh_host_rsa_key -N ""
      fi

      if [ ! -f "${cfg.dir}/ssh_host_rsa_key" ]; then
        ssh-keygen -t ed25519 -f ${cfg.dir}/ssh_host_ed25519_key -N ""
      fi

      cat <<EOF > ${cfg.dir}/sshd_config
        ${if cfg.banner then "Banner ${cfg.dir}/banner" else "asd"}
        PidFile ${cfg.dir}/sshd.pid
        HostKey ${cfg.dir}/ssh_host_rsa_key
        HostKey ${cfg.dir}/ssh_host_ed25519_key

        PrintMotd yes
        PrintLastLog yes

        Port ${cfg.port}
        AddressFamily ${cfg.addressFamily}
        PasswordAuthentication ${ if cfg.passwordLogin then "yes" else "no"}
        PubkeyAuthentication ${if cfg.keyAuthentication then "yes" else "no"}
        PermitRootLogin ${if cfg.rootLogin then "yes" else "no"}
        TCPKeepAlive yes
      EOF

      find ${cfg.dir} -type d -exec chmod -v 700 {} \;
      find ${cfg.dir} -type f -exec chmod -v 600 {} \;
    '';
  };
}