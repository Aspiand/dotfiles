{ config, pkgs, lib, ...}:

with lib; let cfg = config.services.sshd; in

{
  options.services.sshd = {
    enable = mkEnableOption "sshd";
    dir = mkOption {
      type = types.path;
      default = "${config.home.homeDirectory}/.ssh/sshd";
      example = "${config.home.homeDirectory}/.ssh";
    };

    port = mkOption {
      type = types.port;
      default = 2222;
    };

    banner = mkOption {
      type = types.path;
      default = "${cfg.dir}/banner";
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

    extraConfig = mkOption {
      type = types.str;
      default = "";
      example = ''
        ListenAddress 0.0.0.0
      '';
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
        ${pkgs.openssh}/bin/ssh-keygen -t rsa -f ${cfg.dir}/ssh_host_rsa_key -N ""
      fi

      if [ ! -f "${cfg.dir}/ssh_host_ed25519_key" ]; then
        ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f ${cfg.dir}/ssh_host_ed25519_key -N ""
      fi

      if [ ! -f "${cfg.dir}/banner" ]; then
        echo "Welcome!" > ${cfg.dir}/banner
      fi

      cat <<EOF > ${cfg.dir}/sshd_config
      PidFile ${cfg.dir}/sshd.pid
      HostKey ${cfg.dir}/ssh_host_rsa_key
      HostKey ${cfg.dir}/ssh_host_ed25519_key
      Banner ${cfg.banner}

      PrintMotd yes
      PrintLastLog yes

      Port ${toString cfg.port}
      AddressFamily ${cfg.addressFamily}
      PasswordAuthentication ${ if cfg.passwordLogin then "yes" else "no"}
      PubkeyAuthentication ${if cfg.keyAuthentication then "yes" else "no"}
      PermitRootLogin ${if cfg.rootLogin then "yes" else "no"}
      TCPKeepAlive yes
      ${if cfg.extraConfig != "" then cfg.extraConfig else ""}
      EOF

      find ${cfg.dir} -type d -not -perm "700" -exec chmod -v 700 {} \;
      find ${cfg.dir} -type f -not -perm "600" -exec chmod -v 600 {} \;
    '';
  };
}