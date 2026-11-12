{
  description = "dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-26-05.url = "github:NixOS/nixpkgs/nixos-26.05";

    flake-parts.url = "github:hercules-ci/flake-parts";
    wrappers.url = "github:Lassulus/wrappers";
    wrappers.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    grub2-themes = {
      url = "github:vinceliuice/grub2-themes";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hermes-agent.url = "github:NousResearch/hermes-agent";

    copyparty = {
      url = "github:9001/copyparty/hovudstraum";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    substituters = [
      "https://nix.aspian.my.id"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "github-ci-2:eUvIhhjHCO/kJVGcFNd/sNCGSx59tj1QAXmb477OO00="
    ];
  };

  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs) lib;
      flakeLib = import ./lib { inherit lib; };
      mkFlake = inputs.flake-parts.lib.mkFlake { inherit inputs; };
      mkHost = import ./nixos/hosts { self = inputs.self; };

      mergedCustomModules = flakeLib.loadCustomModules ./nix/modules;
      packageFiles = flakeLib.importTree ./nix/packages;

      # Names exported by nix/packages only — nix/wrappers exports must not be
      # overlaid, or they would shadow nixpkgs attrs (git, tmux, fzf, ...).
      packageNames = lib.unique (
        lib.concatMap (
          f: builtins.attrNames ((import f { }).perSystem { pkgs = null; }).packages
        ) packageFiles
      );

      flakeOutputs = mkFlake {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        imports =
          packageFiles ++ (flakeLib.importTree ./nixos/modules) ++ (flakeLib.importTree ./nix/wrappers);

        perSystem = { pkgs, lib, ... }: {
          formatter = pkgs.nixfmt;

          checks.lib-tests = flakeLib.runTests {
            inherit pkgs;
            mylib = import ./lib { inherit lib; };
          };
        };
      };
    in
    flakeOutputs
    // {
      nixosConfigurations = {
        aira = mkHost {
          inputs = {
            inherit (inputs)
              home-manager
              sops-nix
              grub2-themes
              spicetify-nix
              hermes-agent
              ;
          };
          modules = [ ./nixos/hosts/aira ];
        };

        nova = mkHost {
          nixpkgs = inputs.nixpkgs-26-05;
          inputs = {
            inherit (inputs)
              sops-nix
              disko
              hermes-agent
              copyparty
              ;
          };
          extraSpecialArgs.pkgs-unstable = import inputs.nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          modules = [ ./nixos/hosts/nova ];
        };

        alef = mkHost {
          system = "aarch64-linux";
          inputs = { inherit (inputs) disko; };
          modules = [ ./nixos/hosts/alef ];
        };

        # azel is still its own flake: it carries ~500 lines of disko/backup
        # shell helpers in packages.<system>. Moving those is tracked in
        # docs/azel-scripts.md.
        # azel = mkHost { ... };

        delta = mkHost {
          nixpkgs = inputs.nixpkgs-26-05;
          system = "aarch64-linux";
          inputs = { inherit (inputs) disko; };
          modules = [ ./nixos/hosts/delta ];
        };
      };

      nixosModules = (flakeOutputs.nixosModules or { }) // {
        default = { ... }: { };
      };

      # Shared Home Manager modules (home-manager/modules + profiles/default).
      # Hosts use `self.homeModules.default` instead of a separate flake input.
      homeModules.default = import ./home-manager;

      # Standalone Home Manager profiles for machines this flake does not manage
      # as NixOS hosts. Profiles are discovered from home-manager/profiles/ and
      # keyed by the `home.username` each one declares, so
      # `home-manager switch --flake ~/.config/dotfiles#<username>` works without
      # a second hand-maintained map that could drift from the profiles.
      homeConfigurations =
        let
          mkHome =
            profile:
            inputs.home-manager.lib.homeManagerConfiguration {
              pkgs = import inputs.nixpkgs {
                system = "x86_64-linux";
                overlays = [ inputs.self.overlays.default ];
              };
              modules = [ profile ];
            };

          profiles = map (name: mkHome (./home-manager/profiles + "/${name}")) (
            builtins.attrNames (
              lib.filterAttrs (
                name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix"
              ) (builtins.readDir ./home-manager/profiles)
            )
          );
        in
        builtins.listToAttrs (map (config: lib.nameValuePair config.config.home.username config) profiles);

      customModules = mergedCustomModules;
      modules.imports = builtins.attrValues mergedCustomModules;

      # Single overlay: every `nix build .#<name>` is also `pkgs.<name>` on any
      # host.
      #
      # This builds from the ROOT flake's nixpkgs, so a host on a different
      # channel (nova, delta on 26.05) gets packages built against the root
      # pin. That is a pre-existing mixed-closure: it predates the single-flake
      # migration (nova's own flake already pulled a different nixpkgs for
      # `dotfiles`), so it is preserved here rather than changed silently.
      # Fixing it means building from `prev` — but that fails today because
      # nixpkgs 26.05 has neither `mcp_1` nor `fastmcp-slim`, which
      # nix/packages/hindsight.nix needs.
      overlays.default =
        final: prev:
        let
          packages = flakeOutputs.packages.${prev.stdenv.hostPlatform.system} or { };
        in
        lib.genAttrs packageNames (name: packages.${name})
        // {
          lib = prev.lib.extend (_: super: { my = import ./lib { lib = super; }; });
        };
    };
}
