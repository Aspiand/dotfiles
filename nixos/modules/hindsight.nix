/*
  Preconfigured Hindsight: API, control plane, local models and a managed
  PostgreSQL database with pgvector.

  Hosts enable this with `dotfiles.nixosModules.hindsight`. Every value is
  wrapped in `lib.mkDefault`, so a host can override any leaf at normal
  priority, for example:

  services.hindsight = {
      database.name = "hindsight";
      environment.HINDSIGHT_API_LLM_PROVIDER = "none";
      controlPlane.apiURL = "https://hindsight.example.com";
  };

  The option definitions and the service implementation live in
  nix/modules/hindsight.nix. See docs/hindsight.md for the full design.
*/
{
  flake.nixosModules.hindsight =
    { lib, ... }:
    let
      mkDefaults = (import ../../lib { inherit lib; }).mkDefaults;
    in
    {
      config = mkDefaults {
        services.hindsight = {
          enable = true;

          database = {
            enable = true;
            createDB = true;
          };

          localModels.enable = true;
          controlPlane.enable = true;
        };
      };
    };
}
