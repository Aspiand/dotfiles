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

          settings = {
            server = {
              bind_address = "127.0.0.1";
              port = 8888;
              secret_key = "@SEARXNG_SECRET@";
            };

            search = {
              safe_search = 0;
              autocomplete = "";
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
            };
          };
        };
      };
    };
}
