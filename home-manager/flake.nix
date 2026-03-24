{
  description = "Multi-profile Home Manager Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        { pkgs, system, ... }:
        {
          apps.gen-profile = {
            type = "app";
            program =
              (pkgs.writeShellScriptBin "gen-profile" ''
            NAME=$1
            SYSTEM=''${2:-$system}

            if [ -z "$NAME" ]; then
              echo "Usage: nix run .#gen-profile <profile_name> [system]"
              exit 1
            fi

            # Determine home-manager directory
            if [ -f "flake.nix" ] && grep -q "Multi-profile Home Manager Flake" flake.nix; then
              HM_DIR="."
            elif [ -d "home-manager" ]; then
              HM_DIR="home-manager"
            else
              echo "Error: Run this from the root of the dotfiles or home-manager directory."
              exit 1
            fi

            BASE_DIR="$HM_DIR/profiles/$NAME"
            if [ -d "$BASE_DIR" ]; then
              echo "Error: Profile '$NAME' already exists."
              exit 1
            fi

            mkdir -p "$BASE_DIR"

            # Create default.nix
            cat > "$BASE_DIR/default.nix" <<EOF
                { config, pkgs, ... }:

                {
                  imports = [ ../../default.nix ];

                  home = {
                    username = "$NAME";
                    homeDirectory = "/home/$NAME";
                    stateVersion = "25.05";
                  };
                }
                EOF

                            # Create flake.nix
                            cat > "$BASE_DIR/flake.nix" <<EOF
                {
                  description = "Home Manager configuration for $NAME";

                  inputs = {
                    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
                    flake-parts.url = "github:hercules-ci/flake-parts";
                    home-manager = {
                      url = "github:nix-community/home-manager";
                      inputs.nixpkgs.follows = "nixpkgs";
                    };
                  };

                  outputs = inputs@{ flake-parts, nixpkgs, home-manager, ... }:
                    flake-parts.lib.mkFlake { inherit inputs; } {
                      systems = [ "$SYSTEM" ];
                      flake = {
                        homeConfigurations."$NAME" = home-manager.lib.homeManagerConfiguration {
                          pkgs = nixpkgs.legacyPackages."$SYSTEM";
                          modules = [ ./default.nix ];
                        };
                      };
                    };
                }
                EOF

                echo "Profile '$NAME' generated in '$BASE_DIR'"
            echo "Auto-detected by root flake. Staging changes in git..."
            git add "$HM_DIR/profiles/$NAME"
            echo "Done!"
          '').outPath
          + "/bin/gen-profile";
          };
        };

      flake = {
        homeConfigurations =
          let
            lib = nixpkgs.lib;
            profilesDir = ./profiles;
            # Get all directory names in profiles/
            dirs = lib.attrNames (lib.filterAttrs (n: v: v == "directory") (builtins.readDir profilesDir));

            # Merge homeConfigurations from each subdirectory's flake
            allConfigs = lib.foldl' (
              acc: name:
              let
                flakeFile = profilesDir + "/${name}/flake.nix";
                # Only import if flake.nix exists in the folder
                subFlake = if builtins.pathExists flakeFile then (import flakeFile).outputs inputs else { };
              in
              acc // (subFlake.homeConfigurations or { })
            ) { } dirs;
          in
          allConfigs;
      };
    };
}
