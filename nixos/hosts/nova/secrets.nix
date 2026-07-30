{ ... }:

{
  sops.secrets = {
    zerobyte = {
      sopsFile = ../../../secrets/zerobyte.env;
      format = "dotenv";
    };

    tsdproxy = {
      sopsFile = ../../../secrets/tsdproxy.env;
      format = "dotenv";
    };

    "copyparty/as" = {
      sopsFile = ../../../secrets/hosts/nova.yml;
      format = "yaml";
      owner = "copyparty";
      group = "copyparty";
      mode = "0400";
    };

    "gocryptfs/pandora" = {
      sopsFile = ../../../secrets/hosts/nova.yml;
      format = "yaml";
    };

    couchdb = {
      sopsFile = ../../../secrets/couchdb.ini;
      format = "ini";
      owner = "couchdb";
      group = "couchdb";
      mode = "0400";
    };

    cloudflared = {
      sopsFile = ../../../secrets/cloudflared.json;
      format = "binary";
    };

    "rustic/services" = {
      sopsFile = ../../../secrets/rustic.yml;
      format = "yaml";
      key = "services";
      mode = "0400";
    };

    "rustic/media" = {
      sopsFile = ../../../secrets/rustic.yml;
      format = "yaml";
      key = "media";
      mode = "0400";
    };
  };
}
