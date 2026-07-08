{ ... }:
{
  flake.nixosModules.node-exporter =
    { lib, ... }:
    let
      mkDefaults = (import ../../lib { inherit lib; }).mkDefaults;
    in
    {
      config = mkDefaults {
        services.prometheus.exporters.node = {
          enable = true;
          listenAddress = "0.0.0.0";
          port = 9100;

          enabledCollectors = [
            "conntrack"
            "cpu"
            "diskstats"
            "entropy"
            "fibrechannel"
            "filefd"
            "filesystem"
            "loadavg"
            "mdadm"
            "meminfo"
            "netclass"
            "netdev"
            "netstat"
            "nfs"
            "nfsd"
            "sockstat"
            "softnet"
            "stat"
            "textfile"
            "time"
            "uname"
            "vmstat"
            "systemd"
            "logind"
            "os"
            "pressure"

          ];

          extraFlags = [
            "--collector.textfile.directory=/var/lib/node_exporter/textfile_collector"
          ];
        };

        systemd.tmpfiles.rules = [
          "d /var/lib/node_exporter/textfile_collector 0755 node_exporter node_exporter -"
        ];
      };
    };
}
