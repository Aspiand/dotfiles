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
      defaultBackupSubvolumes = [ "@home" "@persist" ];

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
          return 0
        }

        confirm() {
          if [[ "''${CONFIRM_YES:-0}" -eq 1 ]]; then return 0; fi
          if ! read -p "$1 [y/N] " -n 1 -r </dev/tty; then
            echo >&2
            echo "Error: confirmation prompt requires an interactive TTY, or pass -y/--yes." >&2
            exit 1
          fi
          echo
          [[ $REPLY =~ ^[Yy]$ ]] || { echo "Operation cancelled." >&2; exit 1; }
        }

        require_disko() {
          [[ -f "./disko.nix" ]] || {
            echo "Error: disko.nix not found in $PWD." >&2
            exit 1
          }
        }

        load_disko_metadata() {
          require_disko

          # shellcheck disable=SC2016
          DISKO_JSON="$(
            nix eval --impure --json --expr '
              let
                cfg = import ./disko.nix {};
                mapAttrsToList = f: attrs:
                  builtins.map (name: f name attrs.''${name}) (builtins.attrNames attrs);
                walkNode = diskName: diskDevice: node:
                  let
                    nodeType = node.type or null;
                  in
                    if nodeType == "btrfs" then
                      [
                        {
                          inherit diskName diskDevice;
                          fsSource = node._fsSource or null;
                          subvolumes = mapAttrsToList (subvolName: subvol: {
                            name = subvolName;
                            mountpoint = subvol.mountpoint or null;
                            mountOptions = subvol.mountOptions or [];
                          }) (node.subvolumes or {});
                        }
                      ]
                    else if nodeType == "luks" then
                      walkNode diskName diskDevice ((node.content or {}) // {
                        _fsSource = "/dev/mapper/''${node.name}";
                      })
                    else if node ? content then
                      walkNode diskName diskDevice node.content
                    else
                      [ ];
                diskEntries =
                  builtins.concatLists (
                    mapAttrsToList
                      (diskName: disk:
                        let
                          partitions = disk.content.partitions or {};
                        in
                          builtins.concatLists (
                            mapAttrsToList (partName: part: walkNode diskName (disk.device or null) (part.content or {})) partitions
                          )
                      )
                      (cfg.disko.devices.disk or {})
                  );
                subvolumes =
                  builtins.concatLists (
                    builtins.map
                      (entry:
                        builtins.map
                          (subvol:
                            subvol
                            // {
                              diskName = entry.diskName;
                              diskDevice = entry.diskDevice;
                              fsSource = entry.fsSource;
                              mountPath =
                                if subvol.mountpoint == null
                                then null
                                else "/mnt''${subvol.mountpoint}";
                              targetPath = "/mnt/''${subvol.name}";
                            }
                          )
                          entry.subvolumes
                      )
                      diskEntries
                  );
                requiredMounts = builtins.filter (path: path != null) (
                  [ "/mnt" "/mnt/boot" ] ++ builtins.map (subvol: subvol.mountPath) subvolumes
                );
              in
              {
                backupDefaults = [ ${builtins.concatStringsSep " " (map (name: ''"${name}"'') defaultBackupSubvolumes)} ];
                requiredMounts = requiredMounts;
                subvolumes = subvolumes;
              }
            '
          )"
        }

        get_subvolume_json() {
          local subvol_name="$1"

          jq -e --arg name "$subvol_name" '.subvolumes[] | select(.name == $name)' <<<"$DISKO_JSON"
        }

        get_subvolume_field() {
          local subvol_name="$1"
          local field="$2"

          get_subvolume_json "$subvol_name" | jq -r --arg field "$field" '.[$field]'
        }

        get_subvolume_mount_options_csv() {
          local subvol_name="$1"

          get_subvolume_json "$subvol_name" | jq -r '.mountOptions | join(",")'
        }

        require_mounts() {
          local mountpoint
          load_disko_metadata
          for mountpoint in $(jq -r '.requiredMounts[] | select(. != "/mnt")' <<<"$DISKO_JSON"); do
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
            echo "Error: azel is still not fully mounted according to disko.nix." >&2
            exit 1
          }
        }

        delete_subvolume_tree() {
          local target_path="$1"
          local child
          local filesystem_root

          if [[ ! -e "$target_path" ]]; then
            return 0
          fi

          filesystem_root="$(dirname "$target_path")"

          while IFS= read -r child; do
            btrfs property set -f -ts "$child" ro false >/dev/null 2>&1 || true
            btrfs subvolume delete "$child"
          done < <(btrfs subvolume list -o "$target_path" | awk '{print $NF}' | sed "s#^#$filesystem_root/#" | sort -r)

          btrfs property set -f -ts "$target_path" ro false >/dev/null 2>&1 || true
          btrfs subvolume delete "$target_path"
        }

        mount_btrfs_top_level() {
          local fs_source="$1"
          local mount_dir="$2"

          mkdir -p "$mount_dir"
          mount -t btrfs -o subvolid=5,rw "$fs_source" "$mount_dir"
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
            disko --mode unmount ./disko.nix
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
            disko_args=(--mode "destroy,format,mount" ./disko.nix)
            if [[ "$CONFIRM_YES" -eq 1 ]]; then
              disko_args=(--yes-wipe-all-disks "''${disko_args[@]}")
            fi
            disko "''${disko_args[@]}"
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
          runtimeInputs = with pkgs; [ nix nixos-enter util-linux ] ++ [ pkgs.disko ];
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
          runtimeInputs = with pkgs; [ nixos-install ] ++ [ pkgs.disko ];
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
              disko_args=(--mode "destroy,format,mount" ./disko.nix)
              if [[ "$CONFIRM_YES" -eq 1 ]]; then
                disko_args=(--yes-wipe-all-disks "''${disko_args[@]}")
              fi
              disko "''${disko_args[@]}"
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

        backup = mkApp "backup" {
          runtimeInputs = with pkgs; [ btrfs-progs coreutils jq nix zstd ] ++ [ pkgs.disko ];
          text = ''
            check_root
            require_disko
            ensure_mounted
            load_disko_metadata

            compress=1
            backup_root="$(readlink -f ./backups)"
            timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
            host_name="azel"
            declare -a requested_subvolumes=()
            declare -a snapshots_to_cleanup=()
            top_level_mount=""

            while [[ "$#" -gt 0 ]]; do
              case "$1" in
                --subvol)
                  [[ "$#" -ge 2 ]] || {
                    echo "Error: --subvol requires a subvolume name." >&2
                    exit 1
                  }
                  requested_subvolumes+=("$2")
                  shift 2
                  ;;
                --no-compress)
                  compress=0
                  shift
                  ;;
                *)
                  echo "Error: Unknown argument: $1" >&2
                  exit 1
                  ;;
              esac
            done

            if [[ "''${#requested_subvolumes[@]}" -eq 0 ]]; then
              mapfile -t requested_subvolumes < <(jq -r '.backupDefaults[]' <<<"$DISKO_JSON")
            fi

            mkdir -p "$backup_root"

            cleanup_snapshots() {
              local snapshot_path
              for snapshot_path in "''${snapshots_to_cleanup[@]}"; do
                if [[ -e "$snapshot_path" ]]; then
                  btrfs subvolume delete "$snapshot_path" >/dev/null
                fi
              done

              if [[ -n "$top_level_mount" ]]; then
                if findmnt "$top_level_mount" >/dev/null 2>&1; then
                  umount "$top_level_mount"
                fi
                rmdir "$top_level_mount" 2>/dev/null || true
              fi
            }

            trap cleanup_snapshots EXIT

            for subvol_name in "''${requested_subvolumes[@]}"; do
              get_subvolume_json "$subvol_name" >/dev/null || {
                echo "Error: $subvol_name is not defined in disko.nix." >&2
                exit 1
              }

              mount_path="$(get_subvolume_field "$subvol_name" mountPath)"
              target_path="$(get_subvolume_field "$subvol_name" targetPath)"
              mountpoint="$(get_subvolume_field "$subvol_name" mountpoint)"
              fs_source="$(get_subvolume_field "$subvol_name" fsSource)"
              snapshot_name="''${subvol_name#@}-$timestamp"
              backup_dir="$backup_root/$host_name/$subvol_name/$timestamp"

              [[ "$mount_path" != "null" ]] || {
                echo "Error: $subvol_name has no mountpoint in disko.nix." >&2
                exit 1
              }

              if [[ -z "$top_level_mount" ]]; then
                top_level_mount="$(mktemp -d /tmp/azel-btrfs-root.XXXXXX)"
                mount_btrfs_top_level "$fs_source" "$top_level_mount"
              fi

              snapshot_root="$top_level_mount/.snapshots/backup"
              snapshot_path="$snapshot_root/$snapshot_name"

              mkdir -p "$backup_dir"
              mkdir -p "$snapshot_root"

              echo "Creating readonly snapshot for $subvol_name from $mount_path..."
              btrfs subvolume snapshot -r "$top_level_mount/$subvol_name" "$snapshot_path"
              snapshots_to_cleanup+=("$snapshot_path")

              if [[ "$compress" -eq 1 ]]; then
                stream_file="$backup_dir/stream.btrfs.zst"
                echo "Sending $subvol_name with zstd compression..."
                btrfs send "$snapshot_path" | zstd -T0 -q -o "$stream_file"
                compression="zstd"
              else
                stream_file="$backup_dir/stream.btrfs"
                echo "Sending $subvol_name without compression..."
                btrfs send "$snapshot_path" >"$stream_file"
                compression="none"
              fi

              cat >"$backup_dir/meta.env" <<EOF
SUBVOLUME_NAME=$subvol_name
MOUNTPOINT=$mountpoint
MOUNT_PATH=$mount_path
TARGET_PATH=$target_path
SNAPSHOT_NAME=$snapshot_name
COMPRESSION=$compression
CREATED_AT=$timestamp
STREAM_FILE=$(basename "$stream_file")
EOF

              echo "Backup stored at $backup_dir"
            done
          '';
        };

        restore = mkApp "restore" {
          runtimeInputs = with pkgs; [ btrfs-progs jq nix util-linux zstd ] ++ [ pkgs.disko ];
          text = ''
            check_root
            parse_confirm "$@"
            require_disko
            ensure_mounted
            load_disko_metadata

            backup_dir_arg=""
            use_latest=0
            declare -a requested_subvolumes=()
            top_level_mount=""

            while [[ "$#" -gt 0 ]]; do
              case "$1" in
                --from)
                  [[ "$#" -ge 2 ]] || {
                    echo "Error: --from requires a backup directory." >&2
                    exit 1
                  }
                  backup_dir_arg="$2"
                  shift 2
                  ;;
                --latest)
                  use_latest=1
                  shift
                  ;;
                --subvol)
                  [[ "$#" -ge 2 ]] || {
                    echo "Error: --subvol requires a subvolume name." >&2
                    exit 1
                  }
                  requested_subvolumes+=("$2")
                  shift 2
                  ;;
                -y|--yes)
                  shift
                  ;;
                *)
                  echo "Error: Unknown argument: $1" >&2
                  exit 1
                  ;;
                esac
            done

            if [[ -n "$backup_dir_arg" && "$use_latest" -eq 1 ]]; then
              echo "Error: Use either --from or --latest, not both." >&2
              exit 1
            fi

            declare -a backups_to_restore=()

            if [[ -n "$backup_dir_arg" ]]; then
              backups_to_restore+=("$(readlink -f "$backup_dir_arg")")
            elif [[ "$use_latest" -eq 1 ]]; then
              if [[ "''${#requested_subvolumes[@]}" -eq 0 ]]; then
                mapfile -t requested_subvolumes < <(jq -r '.backupDefaults[]' <<<"$DISKO_JSON")
              fi

              for subvol_name in "''${requested_subvolumes[@]}"; do
                latest_root="./backups/azel/$subvol_name"
                if [[ ! -d "$latest_root" ]]; then
                  echo "Warning: No backup directory found for $subvol_name at $latest_root. Skipping." >&2
                  continue
                fi

                latest_timestamp="$(
                  find "$latest_root" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' \
                    | sort \
                    | tail -n 1
                )"

                if [[ -n "$latest_timestamp" ]]; then
                  backups_to_restore+=("$(readlink -f "$latest_root/$latest_timestamp")")
                else
                  echo "Warning: No backups found for $subvol_name in $latest_root. Skipping." >&2
                fi
              done
            else
              echo "Error: Provide --from <backup-directory> or --latest [--subvol <subvolume>]." >&2
              exit 1
            fi

            if [[ "''${#backups_to_restore[@]}" -eq 0 ]]; then
              echo "Error: No backups found to restore." >&2
              exit 1
            fi

            restore_mount_path=""
            restore_fs_source=""
            restore_mount_options=""
            top_level_target_path=""
            current_received_path=""
            rollback_path=""

            reset_restore_state() {
              restore_mount_path=""
              restore_fs_source=""
              restore_mount_options=""
              top_level_target_path=""
              current_received_path=""
              rollback_path=""
            }

            safe_remount_restore_target() {
              [[ -n "$restore_mount_path" && -n "$restore_fs_source" && -n "$restore_mount_options" ]] || return 0
              [[ -n "$top_level_target_path" && -e "$top_level_target_path" ]] || return 0

              if findmnt "$restore_mount_path" >/dev/null 2>&1; then
                return 0
              fi

              mkdir -p "$restore_mount_path"
              mount -t btrfs -o "$restore_mount_options" "$restore_fs_source" "$restore_mount_path"
            }

            cleanup_restore_mount() {
              local cleanup_status="$?"

              if [[ -n "$rollback_path" && -e "$rollback_path" ]]; then
                if [[ -n "$top_level_target_path" && -e "$top_level_target_path" ]]; then
                  echo "Removing incomplete restored subvolume at $top_level_target_path..."
                  delete_subvolume_tree "$top_level_target_path" || true
                fi

                if [[ -n "$top_level_target_path" && ! -e "$top_level_target_path" ]]; then
                  echo "Restoring original subvolume to $top_level_target_path..."
                  mv "$rollback_path" "$top_level_target_path" || true
                fi
              fi

              if [[ -n "$current_received_path" && -e "$current_received_path" ]]; then
                echo "Cleaning up staged subvolume at $current_received_path..."
                delete_subvolume_tree "$current_received_path" || true
              fi

              if [[ "$cleanup_status" -ne 0 ]]; then
                safe_remount_restore_target || true
              fi

              if [[ -n "''${top_level_mount:-}" ]]; then
                if findmnt "$top_level_mount" >/dev/null 2>&1; then
                  umount "$top_level_mount" || true
                fi
                rm -rf "$top_level_mount" 2>/dev/null || true
              fi

              return "$cleanup_status"
            }

            trap cleanup_restore_mount EXIT

            for backup_dir in "''${backups_to_restore[@]}"; do
              reset_restore_state

              meta_file="$backup_dir/meta.env"
              [[ -f "$meta_file" ]] || {
                echo "Error: Missing metadata file in $backup_dir: $meta_file" >&2
                exit 1
              }

              # shellcheck disable=SC1090
              source "$meta_file"
              # Strip any accidental whitespace
              SUBVOLUME_NAME="$(echo "$SUBVOLUME_NAME" | tr -d '[:space:]')"

              echo "--- Restoring $SUBVOLUME_NAME ---"
              echo "Source: $backup_dir"

              get_subvolume_json "$SUBVOLUME_NAME" >/dev/null || {
                echo "Error: $SUBVOLUME_NAME is not defined in disko.nix." >&2
                exit 1
              }

              target_path="$(get_subvolume_field "$SUBVOLUME_NAME" targetPath)"
              mount_path="$(get_subvolume_field "$SUBVOLUME_NAME" mountPath)"
              fs_source="$(get_subvolume_field "$SUBVOLUME_NAME" fsSource)"
              mount_options="$(get_subvolume_mount_options_csv "$SUBVOLUME_NAME")"
              stream_path="$backup_dir/$STREAM_FILE"
              restore_mount_path="$mount_path"
              restore_fs_source="$fs_source"
              restore_mount_options="$mount_options"

              [[ -f "$stream_path" ]] || {
                echo "Error: Missing stream file: $stream_path" >&2
                exit 1
              }

              if [[ -z "''${top_level_mount:-}" ]]; then
                top_level_mount="$(mktemp -d /tmp/azel-btrfs-root.XXXXXX)"
                mount_btrfs_top_level "$fs_source" "$top_level_mount"
              fi
              
              staging_root="$top_level_mount/.restore-staging"
              rollback_root="$top_level_mount/.restore-rollback"
              mkdir -p "$staging_root"
              mkdir -p "$rollback_root"

              top_level_target_path="$top_level_mount/$SUBVOLUME_NAME"
              restore_suffix="$(date -u +%Y%m%dT%H%M%SZ)-$$"

              if [[ -e "$top_level_target_path" ]]; then
                confirm "Subvolume $SUBVOLUME_NAME already exists at $top_level_target_path. Replace it with the restored backup?"
              fi

              current_received_path="$staging_root/$SNAPSHOT_NAME"
              if [[ -e "$current_received_path" ]]; then
                echo "Cleaning up previous staged subvolume at $current_received_path..."
                delete_subvolume_tree "$current_received_path"
              fi

              echo "Receiving backup for $SUBVOLUME_NAME..."
              if [[ "$COMPRESSION" == "zstd" ]]; then
                zstd -d -c "$stream_path" | btrfs receive "$staging_root"
              elif [[ "$COMPRESSION" == "none" ]]; then
                btrfs receive "$staging_root" <"$stream_path"
              else
                echo "Error: Unsupported compression type: $COMPRESSION" >&2
                exit 1
              fi

              [[ -e "$current_received_path" ]] || {
                echo "Error: Expected received subvolume at $current_received_path." >&2
                exit 1
              }

              echo "Making received subvolume read-write..."
              btrfs property set -f -ts "$current_received_path" ro false

              ro_property="$(btrfs property get -ts "$current_received_path" ro)"
              [[ "$ro_property" == "ro=false" ]] || {
                echo "Error: Restored subvolume is still read-only: $ro_property" >&2
                exit 1
              }

              if findmnt "$mount_path" >/dev/null 2>&1; then
                echo "Unmounting $mount_path before final swap..."
                umount "$mount_path"
              fi

              if [[ -e "$top_level_target_path" ]]; then
                rollback_path="$rollback_root/$SUBVOLUME_NAME.pre-restore-$restore_suffix"
                if [[ -e "$rollback_path" ]]; then
                  delete_subvolume_tree "$rollback_path"
                fi

                echo "Moving existing subvolume to rollback path $rollback_path..."
                mv "$top_level_target_path" "$rollback_path"
              fi

              echo "Promoting restored subvolume to $top_level_target_path..."
              mv "$current_received_path" "$top_level_target_path"
              current_received_path=""

              safe_remount_restore_target

              echo "Restore completed for $SUBVOLUME_NAME."

              if [[ -n "$rollback_path" && -e "$rollback_path" ]]; then
                echo "Deleting rollback subvolume at $rollback_path..."
                delete_subvolume_tree "$rollback_path"
              fi

              reset_restore_state
            done
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
