{ pkgs }:
let
  inherit (builtins) fromJSON readFile;
  json = fromJSON (readFile ./_generated.json);

  mkSrc =
    { type, sha256, ... }@args:
    if type == "github" then
      pkgs.fetchFromGitHub {
        owner = args.owner;
        repo = args.repo;
        rev = args.rev;
        hash = sha256;
        fetchSubmodules = args.fetchSubmodules or false;
      }
    else if type == "url" then
      pkgs.fetchurl {
        url = args.url;
        hash = sha256;
      }
    else
      throw "unknown source type: ${type}";
in
builtins.mapAttrs (_: v: {
  inherit (v) version;
  src = mkSrc v.src;
}) json
