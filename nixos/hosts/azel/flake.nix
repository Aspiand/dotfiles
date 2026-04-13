{
  description = "NixOS configuration for azel";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
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

      sh = {
        checkRoot = ''
          if [[ "''${EUID}" -ne 0 ]]; then
            echo "Error: This command requires root privileges. Please run with 'sudo'." >&2
            exit 1
          fi
        '';
        ensureMounted = ''
          if ! findmnt /mnt >/dev/null 2>&1 || ! findmnt /mnt/boot >/dev/null 2>&1; then
            echo "azel is not fully mounted at /mnt. Attempting to mount now..."
            "${mountApp}/bin/mount"
          fi
        '';
        confirm = ''
          confirm_action() {
            if [[ "''${CONFIRM_YES:-0}" -eq 1 ]]; then return 0; fi
            read -p "$1 [y/N] " -n 1 -r; echo
            [[ $REPLY =~ ^[Yy]$ ]] || { echo "Operation cancelled." >&2; exit 1; }
          }
        '';
      };

      mountApp = pkgs.writeShellApplication {
        name = "mount";
        runtimeInputs = with pkgs; [ disko ];
        text = ''
          set -euo pipefail
          ${sh.checkRoot}
          [[ -f "./disko.nix" ]] || { echo "Error: disko.nix not found." >&2; exit 1; }

          echo "Mounting azel using disko..."
          ${pkgs.disko}/bin/disko --mode mount ./disko.nix
        '';
      };

      umountApp = pkgs.writeShellApplication {
        name = "umount";
        runtimeInputs = with pkgs; [ disko ];
        text = ''
          set -euo pipefail
          ${sh.checkRoot}
          [[ -f "./disko.nix" ]] || { echo "Error: disko.nix not found." >&2; exit 1; }

          echo "Unmounting azel using disko..."
          disko --mode umount ./disko.nix
        '';
      };

      formatApp = pkgs.writeShellApplication {
        name = "format";
        runtimeInputs = with pkgs; [ disko ];
        text = ''
          set -euo pipefail
          ${sh.checkRoot}
          ${sh.confirm}
          [[ -f "./disko.nix" ]] || { echo "Error: disko.nix not found in $PWD. Please run this command from the 'nixos/hosts/azel' directory." >&2; exit 1; }

          CONFIRM_YES=0
          for arg in "$@"; do
            case "$arg" in
              -y|--yes) CONFIRM_YES=1 ;;
            esac
          done

          echo "WARNING: This will WIPEOUT and FORMAT your disks according to disko.nix!"
          confirm_action "Are you absolutely sure you want to format the disks?"

          disko --mode disko ./disko.nix
        '';
      };

      buildApp = pkgs.writeShellApplication {
        name = "build";
        text = ''
          set -euo pipefail
          [[ -f "./flake.nix" ]] || { echo "Error: flake.nix not found in $PWD. Please run this command from the 'nixos/hosts/azel' directory." >&2; exit 1; }

          out_link="$PWD/result"
          echo "Building azel system profile..."
          nix build ".#nixosConfigurations.azel.config.system.build.toplevel" -o "$out_link"
          echo "Build complete: $(readlink -f "$out_link")"
        '';
      };

      rebuildApp = pkgs.writeShellApplication {
        name = "rebuild";
        runtimeInputs = with pkgs; [
          nix
          nixos-enter
          util-linux
        ];
        text = ''
          set -euo pipefail
          ${sh.checkRoot}
          ${sh.confirm}

          CONFIRM_YES=0
          for arg in "$@"; do
            case "$arg" in
              -y|--yes) CONFIRM_YES=1 ;;
            esac
          done

          confirm_action "This will overwrite the system profile and update the bootloader. Proceed?"
          ${sh.ensureMounted}

          echo "Starting system rebuild..."
          "${buildApp}/bin/build"
          out_link="$PWD/result"
          system_path="$(readlink -f "$out_link")"
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

      installApp = pkgs.writeShellApplication {
        name = "install";
        runtimeInputs = with pkgs; [
          nixos-install
        ];
        text = ''
          set -euo pipefail
          ${sh.checkRoot}
          ${sh.confirm}

          format_disk=0
          no_build=0
          CONFIRM_YES=0
          install_args=()

          for arg in "$@"; do
            case "$arg" in
              --format) format_disk=1 ;;
              --no-build) no_build=1 ;;
              -y|--yes) CONFIRM_YES=1 ;;
              *) install_args+=("$arg") ;;
            esac
          done

          if [[ "$format_disk" -eq 1 ]]; then
            echo "WARNING: --format requested. Disks will be WIPED before installation."
            confirm_action "Proceed with formatting and installation?"
            "${formatApp}/bin/format" --yes
          else
            confirm_action "Start NixOS installation on /mnt?"
          fi

          ${sh.ensureMounted}

          if [[ "$no_build" -eq 1 ]]; then
            if [[ ! -L "./result" ]]; then
              echo "Error: ./result link not found. Cannot proceed with --no-build." >&2
              echo "Direction: Run 'nix run .#build' first to generate the system closure, or run 'install' without --no-build." >&2
              exit 1
            fi
            system_path=$(readlink -f ./result)
            echo "Installing pre-built system from $system_path..."
            nixos-install --system "$system_path" --root /mnt "''${install_args[@]}"
          else
            echo "Installing azel system from flake..."
            nixos-install --flake ".#azel" --root /mnt "''${install_args[@]}"
          fi
        '';
      };
    in
    {
      packages.${system} = {
        mount = mountApp;
        umount = umountApp;
        build = buildApp;
        rebuild = rebuildApp;
        format = formatApp;
        install = installApp;
      };

      apps.${system} = {
        mount = {
          type = "app";
          program = "${mountApp}/bin/mount";
        };

        umount = {
          type = "app";
          program = "${umountApp}/bin/umount";
        };

        build = {
          type = "app";
          program = "${buildApp}/bin/build";
        };

        format = {
          type = "app";
          program = "${formatApp}/bin/format";
        };

        install = {
          type = "app";
          program = "${installApp}/bin/install";
        };

        rebuild = {
          type = "app";
          program = "${rebuildApp}/bin/rebuild";
        };
      };

      nixosConfigurations.azel = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
          ./configuration.nix
          ./disko.nix
          ./hardware-configuration.nix
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
