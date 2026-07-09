{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      sops-nix,
      ...
    }:
    let
      mkHome =
        system: modules:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          modules = [ ./default.nix ] ++ modules;
          extraSpecialArgs = { inherit sops-nix; };
        };

      # Auto-discover host profiles under profiles/
      profileFiles = builtins.readDir ./profiles;
      hostProfiles = builtins.mapAttrs
        (name: _: mkHome "x86_64-linux" [ (./profiles + "/${name}") ])
        (nixpkgs.lib.filterAttrs
          (name: type: type == "regular" && nixpkgs.lib.hasSuffix ".nix" name && name != "default.nix")
          profileFiles
        );
    in
    {
      homeModules.default = ./default.nix;
      homeConfigurations = hostProfiles;
    };
}
