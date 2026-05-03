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

      sh = {
        checkRoot = ''
          if [[ "''${EUID}" -ne 0 ]]; then
            echo "Error: This command requires root privileges. Please run with 'sudo'." >&2
            exit 1
          fi
        '';

        parseConfirmFlag = ''
          CONFIRM_YES=0
          for arg in "$@"; do
            [[ "$arg" == "-y" || "$arg" == "--yes" ]] && CONFIRM_YES=1
          done
        '';

        confirm = ''
          confirm_action() {
            if [[ "''${CONFIRM_YES:-0}" -eq 1 ]]; then return 0; fi
            read -p "$1 [y/N] " -n 1 -r; echo
            [[ $REPLY =~ ^[Yy]$ ]] || { echo "Operation cancelled." >&2; exit 1; }
          }
        '';

        ensureMounted = ''
          if ! findmnt /mnt >/dev/null 2>&1 || ! findmnt /mnt/boot >/dev/null 2>&1; then
            echo "azel is not fully mounted at /mnt. Attempting to mount now..."
            "${mountApp}/bin/mount"
          fi
        '';
      };

      requireDiskoNix = ''
        [[ -f "./disko.nix" ]] || {
          echo "Error: disko.nix not found in $PWD." >&2
          exit 1
        }
      '';

      mountApp = pkgs.writeShellApplication {
        name = "mount";
        runtimeInputs = [ pkgs.disko ];
        text = ''
          set -euo pipefail
          ${sh.checkRoot}
          ${requireDiskoNix}
          echo "Mounting azel using disko..."
          ${pkgs.disko}/bin/disko --mode mount ./disko.nix
        '';
      };

      umountApp = pkgs.writeShellApplication {
        name = "umount";
        runtimeInputs = [ pkgs.disko ];
        text = ''
          set -euo pipefail
          ${sh.checkRoot}
          ${requireDiskoNix}
          echo "Unmounting azel using disko..."
          ${pkgs.disko}/bin/disko --mode umount ./disko.nix
        '';
      };

      formatApp = pkgs.writeShellApplication {
        name = "format";
        runtimeInputs = [ pkgs.disko ];
        text = ''
          set -euo pipefail
          ${sh.checkRoot}
          ${sh.confirm}
          ${sh.parseConfirmFlag}
          ${requireDiskoNix}
          echo "WARNING: This will WIPEOUT and FORMAT your disks according to disko.nix!"
          confirm_action "Are you absolutely sure you want to format the disks?"
          ${pkgs.disko}/bin/disko --mode disko ./disko.nix
        '';
      };

      buildApp = pkgs.writeShellApplication {
        name = "build";
        text = ''
          set -euo pipefail
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
          ${sh.parseConfirmFlag}
          confirm_action "This will overwrite the system profile and update the bootloader. Proceed?"
          ${sh.ensureMounted}

          echo "Starting system rebuild..."
          "${buildApp}/bin/build"
          system_path="$(readlink -f "$PWD/result")"
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
        runtimeInputs = with pkgs; [ nixos-install ];
        text = ''
          set -euo pipefail
          ${sh.checkRoot}
          ${sh.confirm}
          ${sh.parseConfirmFlag}

          format_disk=0
          no_build=0
          install_args=()

          for arg in "$@"; do
            case "$arg" in
              --format)   format_disk=1 ;;
              --no-build) no_build=1 ;;
              -y|--yes)   ;; # already handled by parseConfirmFlag
              *)          install_args+=("$arg") ;;
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
      appRegistry = {
        mount = mountApp;
        umount = umountApp;
        build = buildApp;
        rebuild = rebuildApp;
        format = formatApp;
        install = installApp;
      };

    in
    {
      packages.${system} = appRegistry;
      apps.${system} = builtins.mapAttrs (name: pkg: {
        type = "app";
        program = "${pkg}/bin/${name}";
      }) appRegistry;

      nixosConfigurations.azel = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
          ./disko.nix
          ./hardware.nix
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
