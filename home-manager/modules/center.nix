{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.programs;
in

{
  options = {
    programs = {
      ssh.control = mkEnableOption "SSH Control";
    };

    shell.nix-path = mkOption {
      type = types.path;
      default = "${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh";
      example = "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh";
    };
  };

  config = mkMerge [

    (mkIf cfg.ssh.control {
      programs.ssh = {
        controlMaster = "auto";
        controlPersist = "30m";
        controlPath = "~/.ssh/control/%r@%n:%p";
      };
    })

    # Shell
    (let path = config.shell.nix-path; in {
      programs.bash.bashrcExtra = ''
        source ${path}
      '';

      programs.zsh.initExtraFirst = mkIf cfg.zsh.enable ''
        source ${path}
      '';
    })

    (mkIf cfg.ssh.enable {
      home.activation.sshSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ -d "$HOME/.ssh" ]; then
          find "$HOME/.ssh" -type d -not -perm "700" -exec chmod -v 700 {} \;
          find "$HOME/.ssh" -type f -not -perm "600" -exec chmod -v 600 {} \;
        fi
      '';
    })

    (mkIf true {
      home.packages = with pkgs; [
        # Archive
        bzip2
        bzip3
        gzip
        unrar
        unzip
        gnutar
        xz
        zip
        zstd

        # Multimedia
        # exiftool
        ffmpeg

        # Network
        aria2
        sshfs
        wget
      ];
    })

    {
      programs = mkMerge [
        {
          yazi = mkMerge [
            {
              enableBashIntegration = true;
              settings = mkMerge [
                {
                  log.enable = true;
                  manager = mkMerge [
                    (
                      mkMerge [
                        (
                          mkMerge [
                            (
                              mkMerge [
                                (
                                  mkMerge [
                                    (
                                      mkMerge [
                                        (
                                          mkMerge [
                                            (
                                              mkMerge [
                                                {
                                                  show_hidden = true;
                                                  sort_by = "alphabetical";
                                                  sort_dir_first = true;
                                                  sort_reverse = false;
                                                  show_symlink = true;
                                                }
                                              ]
                                            )
                                          ]
                                        )
                                      ]
                                    )
                                  ]
                                )
                              ]
                            )
                          ]
                        )
                      ]
                    )
                  ];
                }
              ];
            }
          ];
        }
      ];
    }
  ];
}