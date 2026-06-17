{ ... }:
{
  flake.nixosModules.grafana =
    { lib, ... }:
    let
      mkDefaults = (import ../../lib { inherit lib; }).mkDefaults;
    in
    {
      config = mkDefaults {
        services.grafana = {
          enable = true;

          settings = {
            server = {
              http_addr = "127.0.0.1";
              http_port = 3000;
              domain = "localhost";
              root_url = "http://localhost:3000";
              serve_from_sub_path = false;
            };

            database = {
              type = "sqlite3";
              path = "/var/lib/grafana/grafana.db";
            };

            security = {
              admin_user = "admin";
              admin_password = "admin"; # change after first login
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
            settings.datasources = [
              {
                name = "Prometheus";
                type = "prometheus";
                access = "proxy";
                url = "http://127.0.0.1:9090";
                isDefault = true;
                editable = true;
              }
            ];
            settings.providers = [
              {
                name = "default";
                orgId = 1;
                folder = "";
                type = "file";
                disableDeletion = false;
                updateIntervalSeconds = 30;
                options = {
                  path = "/var/lib/grafana/dashboards/ready";
                  foldersFromFilesStructure = false;
                };
              }
            ];
          };
        };

        systemd.tmpfiles.rules = [
          "d /var/lib/grafana/dashboards/ready 0755 grafana grafana -"
        ];
      };
    };
}
