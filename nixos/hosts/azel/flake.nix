{
  description = "NixOS configuration for azel";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    impermanence.url = "github:nix-community/impermanence";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    danksearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
  };

  outputs =
    inputs@{
      nixpkgs,
      disko,
      home-manager,
      impermanence,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      # Common shell library
      shLib = ''
        check_root() {
          if [[ "''${EUID}" -ne 0 ]]; then
            echo "Error: This command requires root privileges. Please run with 'sudo'." >&2
            exit 1
          fi
        }

        parse_confirm() {
          CONFIRM_YES=0
          for arg in "$@"; do
            [[ "$arg" == "-y" || "$arg" == "--yes" ]] && CONFIRM_YES=1
          done
        }

        confirm() {
          if [[ "''${CONFIRM_YES:-0}" -eq 1 ]]; then return 0; fi
          read -p "$1 [y/N] " -n 1 -r; echo
          [[ $REPLY =~ ^[Yy]$ ]] || { echo "Operation cancelled." >&2; exit 1; }
        }

        require_disko() {
          [[ -f "./disko.nix" ]] || {
            echo "Error: disko.nix not found in $PWD." >&2
            exit 1
          }
        }

        require_mounts() {
          local mountpoint
          for mountpoint in /mnt /mnt/boot /mnt/home /mnt/nix /mnt/persist; do
            findmnt "$mountpoint" >/dev/null 2>&1 || return 1
          done
        }

        ensure_mounted() {
          require_disko

          if ! require_mounts; then
            echo "azel is not fully mounted at /mnt. Attempting to mount now..."
            disko --mode mount ./disko.nix
          fi

          require_mounts || {
            echo "Error: azel is still not fully mounted. Expected /mnt, /mnt/boot, /mnt/home, /mnt/nix, and /mnt/persist." >&2
            exit 1
          }
        }
      '';

      # Helper for creating applications
      mkApp = name: { runtimeInputs ? [ ], text }: pkgs.writeShellApplication {
        inherit name runtimeInputs;
        text = ''
          set -euo pipefail
          ${shLib}
          ${text}
        '';
      };

      scripts = {
        mount = mkApp "mount" {
          runtimeInputs = [ pkgs.disko ];
          text = ''
            check_root
            require_disko
            echo "Mounting azel using disko..."
            disko --mode mount ./disko.nix
          '';
        };

        umount = mkApp "umount" {
          runtimeInputs = [ pkgs.disko ];
          text = ''
            check_root
            require_disko
            echo "Unmounting azel using disko..."
            disko --mode umount ./disko.nix
          '';
        };

        format = mkApp "format" {
          runtimeInputs = [ pkgs.disko ];
          text = ''
            check_root
            parse_confirm "$@"
            require_disko
            echo "WARNING: This will WIPEOUT and FORMAT your disks according to disko.nix!"
            confirm "Are you absolutely sure you want to format the disks?"
            disko --mode disko ./disko.nix
          '';
        };

        build = mkApp "build" {
          text = ''
            echo "Building azel system profile..."
            nix build ".#nixosConfigurations.azel.config.system.build.toplevel" -o "./result"
            echo "Build complete: $(readlink -f ./result)"
          '';
        };

        rebuild = mkApp "rebuild" {
          runtimeInputs = with pkgs; [ nix nixos-enter util-linux disko ];
          text = ''
            check_root
            parse_confirm "$@"
            confirm "This will overwrite the system profile and update the bootloader. Proceed?"
            ensure_mounted

            echo "Starting system rebuild..."
            nix build ".#nixosConfigurations.azel.config.system.build.toplevel" -o "./result"
            
            system_path="$(readlink -f ./result)"
            target_store='local?root=/mnt&require-sigs=false'

            echo "Copying closure to target store..."
            nix copy --no-check-sigs --to "$target_store" "$system_path"

            echo "Updating target system profile..."
            nix-env --store "$target_store" -p /nix/var/nix/profiles/system --set "$system_path"

            echo "Activating target system and updating bootloader..."
            nixos-enter --root /mnt --system /nix/var/nix/profiles/system -c \
              'NIXOS_INSTALL_BOOTLOADER=1 /nix/var/nix/profiles/system/bin/switch-to-configuration boot'
            echo "Rebuild finished successfully."
          '';
        };

        install = mkApp "install" {
          runtimeInputs = with pkgs; [ nixos-install disko ];
          text = ''
            check_root
            parse_confirm "$@"
            require_disko

            format_disk=0
            no_build=0
            install_args=()

            for arg in "$@"; do
              case "$arg" in
                --format)   format_disk=1 ;;
                --no-build) no_build=1 ;;
                -y|--yes)   ;;
                *)          install_args+=("$arg") ;;
              esac
            done

            if [[ "$format_disk" -eq 1 ]]; then
              echo "WARNING: --format requested. Disks will be WIPED before installation."
              confirm "Proceed with formatting and installation?"
              disko --mode disko ./disko.nix
            else
              confirm "Start NixOS installation on /mnt?"
            fi

            ensure_mounted

            if [[ "$no_build" -eq 1 ]]; then
              [[ -L "./result" ]] || {
                echo "Error: ./result not found. Run 'nix run .#build' first, or omit --no-build." >&2
                exit 1
              }
              system_path=$(readlink -f ./result)
              echo "Installing pre-built system from $system_path..."
              nixos-install --system "$system_path" --root /mnt "''${install_args[@]}"
            else
              echo "Installing azel system from flake..."
              nixos-install --flake ".#azel" --root /mnt "''${install_args[@]}"
            fi
          '';
        };
      };
    in
    {
      packages.${system} = scripts;
      apps.${system} = builtins.mapAttrs (name: pkg: {
        type = "app";
        program = "${pkg}/bin/${name}";
      }) scripts;

      nixosConfigurations.azel = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
          ./disko.nix
          ./hardware.nix
          ./impermanence.nix
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = { inherit inputs; };
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "bak";
              users.aka = ./home.nix;
            };
          }
        ];
      };
    };
}
