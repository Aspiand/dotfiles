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

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      disko,
      home-manager,
      impermanence,
      caelestia-shell,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      mountScript = ''
        set -euo pipefail

        if [[ "''${EUID}" -ne 0 ]]; then
          echo "Run this app as root." >&2
          exit 1
        fi

        enable_swap=0
        if [[ "''${1-}" == "--with-swap" ]]; then
          enable_swap=1
        fi

        esp="/dev/disk/by-partlabel/disk-main-ESP"
        swap_dev="/dev/disk/by-partlabel/disk-main-swap"
        luks_dev="/dev/disk/by-partlabel/disk-main-luks"
        mapper_name="cryptroot"
        mapper_dev="/dev/mapper/''${mapper_name}"

        for dev in "$esp" "$swap_dev" "$luks_dev"; do
          [[ -b "$dev" ]] || {
            echo "Device not found: $dev" >&2
            exit 1
          }
        done

        if [[ ! -e "$mapper_dev" ]]; then
          echo "Opening LUKS device $luks_dev as $mapper_name"
          cryptsetup open "$luks_dev" "$mapper_name" --allow-discards
        fi

        mount_btrfs_subvol() {
          local mountpoint="$1"
          local subvol="$2"
          local opts="$3"

          mkdir -p "$mountpoint"
          if ! findmnt "$mountpoint" >/dev/null 2>&1; then
            mount "$mapper_dev" "$mountpoint" -o "''${opts},subvol=''${subvol}"
          fi
        }

        mount_btrfs_subvol /mnt "@root" "compress=zstd,noatime"
        mount_btrfs_subvol /mnt/home "@home" "compress=zstd"
        mount_btrfs_subvol /mnt/nix "@nix" "compress=zstd,noatime"
        mount_btrfs_subvol /mnt/var/log "@log" "compress=zstd,noatime"
        mount_btrfs_subvol /mnt/persist "@persist" "compress=zstd"

        mkdir -p /mnt/boot
        if ! findmnt /mnt/boot >/dev/null 2>&1; then
          mount -t vfat -o umask=0077 "$esp" /mnt/boot
        fi

        if [[ "$enable_swap" -eq 1 ]]; then
          swapon "$swap_dev" 2>/dev/null || true
        fi

        echo "Mounted azel at /mnt"
        findmnt /mnt || true
        findmnt /mnt/boot || true
      '';

      umountScript = ''
        set -euo pipefail

        if [[ "''${EUID}" -ne 0 ]]; then
          echo "Run this app as root." >&2
          exit 1
        fi

        swap_dev="/dev/disk/by-partlabel/disk-main-swap"
        mapper_name="cryptroot"

        swapoff "$swap_dev" 2>/dev/null || true
        umount -R /mnt 2>/dev/null || true
        cryptsetup close "$mapper_name" 2>/dev/null || true

        echo "Unmounted azel from /mnt"
      '';

      buildScript = ''
        set -euo pipefail

        work_dir="$PWD"
        out_link="$work_dir/result"
        flake_ref="$work_dir#nixosConfigurations.azel.config.system.build.toplevel"

        if [[ ! -f "$work_dir/flake.nix" ]]; then
          echo "Run this command from nixos/hosts/azel so the current directory contains the azel flake." >&2
          exit 1
        fi

        ${pkgs.nix}/bin/nix build "$flake_ref" -o "$out_link"

        target="$(readlink -f "$out_link" || true)"
        case "$target" in
          *-nixos-system-azel-*)
            ;;
          *)
            echo "Unexpected build output: $target" >&2
            echo "Expected a nixos-system-azel closure, not a source tree." >&2
            exit 1
            ;;
        esac

        echo "Built azel system to $out_link"
        readlink -f "$out_link"
      '';

      mountApp = pkgs.writeShellApplication {
        name = "mount";
        runtimeInputs = with pkgs; [
          cryptsetup
          util-linux
        ];
        text = mountScript;
      };

      umountApp = pkgs.writeShellApplication {
        name = "umount";
        runtimeInputs = with pkgs; [
          cryptsetup
          util-linux
        ];
        text = umountScript;
      };

      buildApp = pkgs.writeShellApplication {
        name = "build";
        runtimeInputs = with pkgs; [
          nix
        ];
        text = ''
          set -euo pipefail

          ${buildScript}
        '';
      };

      deployApp = pkgs.writeShellApplication {
        name = "deploy";
        runtimeInputs = with pkgs; [
          cryptsetup
          nix
          util-linux
        ];
        text = ''
          set -euo pipefail

          if [[ "''${EUID}" -ne 0 ]]; then
            echo "Run this app as root." >&2
            exit 1
          fi

          if ! findmnt /mnt >/dev/null 2>&1 || ! findmnt /mnt/boot >/dev/null 2>&1; then
            echo "azel is not fully mounted at /mnt, mounting now"
            "${mountApp}/bin/mount"
          else
            echo "azel is already mounted at /mnt"
          fi

          "${buildApp}/bin/build"
          out_link="$PWD/result"
          ${pkgs.nix}/bin/nix-env -p /mnt/nix/var/nix/profiles/system --set "$out_link"
          ${pkgs.nixos-enter}/bin/nixos-enter --root /mnt -c 'NIXOS_INSTALL_BOOTLOADER=1 /nix/var/nix/profiles/system/bin/switch-to-configuration boot'
        '';
      };
    in
    {
      packages.${system} = {
        mount = mountApp;
        umount = umountApp;
        build = buildApp;
        deploy = deployApp;
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

        deploy = {
          type = "app";
          program = "${deployApp}/bin/deploy";
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
