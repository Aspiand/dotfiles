{ ... }:
{
  flake.nixosModules.searxng =
    { lib, ... }:
    let
      mkDefaults = (import ../../lib { inherit lib; }).mkDefaults;
    in
    {
      config = mkDefaults {
        services.searx = {
          enable = true;
          redisCreateLocally = true;

          limiterSettings = {
            real_ip = {
              x_for = 1;
              ipv4_prefix = 32;
              ipv6_prefix = 56;
            };
            botdetection.ip_lists.pass_ip = [ "loopback" ];
          };

          settings = {
            server = {
              bind_address = "127.0.0.1";
              port = 8888;
              secret_key = "@SEARXNG_SECRET@";
              limiter = true;
            };

            search = {
              safe_search = 0;
              autocomplete = "";
              language = "en-US";
              formats = [
                "html"
                "json"
              ];
            };

            ui = {
              static_use_hash = true;
              default_theme = "simple";
              default_locale = "en";
            };

            engines = [
              {
                name = "google";
                disabled = false;
              }
              {
                name = "duckduckgo";
                disabled = false;
              }
              {
                name = "bing";
                disabled = false;
              }
              {
                name = "brave";
                disabled = false;
              }
              {
                name = "wikipedia";
                disabled = false;
              }
              {
                name = "github";
                disabled = false;
              }
              {
                name = "stackoverflow";
                disabled = false;
              }
              {
                name = "arxiv";
                disabled = false;
              }
            ];

            outgoing = {
              request_timeout = 10.0;
              max_request_timeout = 15.0;
              useragent_suffix = "";
              enable_http2 = true;
            };
          };
        };
      };
    };
}
