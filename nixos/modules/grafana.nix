{ ... }:
{
  flake.nixosModules.grafana =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      hasVM = config.services.victoriametrics.enable or false;
      hasVL = config.services.victorialogs.enable or false;
      hasPrometheus = config.services.prometheus.enable or false;
      hasNodeExporter = config.services.prometheus.exporters.node.enable or false;
    in
    {
      config = {
        services.grafana = {
          enable = true;
          settings = {
            server = {
              enable_gzip = true;
              # enforce_domain = true;
              http_addr = "0.0.0.0";
              http_port = 3000;
              domain = "localhost";

              # Alternatively, if you want to serve Grafana from a subpath:
              # domain = "your.domain";
              # root_url = "https://your.domain/grafana/";
              # serve_from_sub_path = true;
            };

            database = {
              type = "sqlite3";
              path = "/var/lib/grafana/grafana.db";
            };

            security = {
              admin_user = "admin";
              admin_password = "admin"; # change after first login # TODO: sops?
              secret_key = "mana-sprei-gratis-yang-kau-janjikan-itu-wok";
              disable_gravatar = true;
            };

            users = {
              allow_sign_up = false;
              auto_assign_org = true;
              auto_assign_org_role = "Viewer";
            };

            auth = {
              disable_login_form = false;
            };

            log = {
              mode = "console";
              level = "info";
            };

            analytics = {
              reporting_enabled = false;
              check_for_updates = false;
            };

            panels = {
              disable_sanitize_html = false;
            };
          };

          provision = {
            enable = true;
            datasources.settings = {
              apiVersion = 1;
              datasources =
                lib.optional hasPrometheus {
                  name = "Prometheus";
                  type = "prometheus";
                  url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
                  isDefault = !hasVM; # handle bentrok
                  editable = false;
                }
                ++ lib.optional hasVM {
                  name = "VictoriaMetrics";
                  type = "prometheus";
                  access = "proxy";
                  url = "http://${config.services.victoriametrics.listenAddress}";
                  isDefault = true; # handle bentrok
                  editable = false;
                }
                ++ lib.optional hasVL {
                  name = "VictoriaLogs";
                  type = "victoriametrics-logs-datasource";
                  url = "http://${config.services.victorialogs.listenAddress}";
                  access = "proxy";
                  editable = false;
                  jsonData = {
                    victoriametrics.datasource = {
                      type = "prometheus";
                      uid = "VictoriaMetrics";
                    };
                  };
                };
            };
          };

          declarativePlugins =
            lib.optionals hasVM [ pkgs.grafanaPlugins.victoriametrics-metrics-datasource ]
            ++ lib.optionals hasVL [ pkgs.grafanaPlugins.victoriametrics-logs-datasource ];
        };

        environment.etc."grafana-dashboards/node-exporter.json".source =
          pkgs.fetchurl {
            url = "https://grafana.com/api/dashboards/1860/revisions/45/download";
            hash = "sha256-GExrdAnzBtp1Ul13cvcZRbEM6iOtFrXXjEaY6g6lGYY=";
          };

        systemd.tmpfiles.rules =
          lib.optionals hasNodeExporter [
            "d /var/lib/grafana/dashboards/ready 0755 grafana grafana -"
          ];
      };
    };
}
