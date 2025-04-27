#########


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
  };

  config = mkMerge [

    (mkIf cfg.ssh.control {
      programs.ssh = {
        controlMaster = "auto";
        controlPersist = "30m";
        controlPath = "~/.ssh/control/%r@%n:%p";
      };
    })

    (mkIf cfg.ssh.enable {
      home.activation.sshSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ -d "$HOME/.ssh" ]; then
          find "$HOME/.ssh" -type d -not -perm "700" -exec chmod -v 700 {} \;
          find "$HOME/.ssh" -type f -not -perm "600" -exec chmod -v 600 {} \;
        fi
      '';
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
                                                                                                                                                              {
                                                                                                                                                                show_hidden = true;
                                                                                                                                                                sort_by = "alphabetical";
                                                                                                                                                                sort_dir_first = true;
                                                                                                                                                                sort_reverse = false;
                                                                                                                                                                show_symlink = true;
                                                                                                                                                              }
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