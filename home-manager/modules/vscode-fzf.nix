{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.vscode-fzf;
  workspaceDirs = lib.concatStringsSep ":" cfg.dirs;
in
{
  options.programs.vscode-fzf = {
    enable = lib.mkEnableOption "VS Code workspace selector using fzf";
    shortcut = lib.mkOption {
      type = lib.types.str;
      default = "\\C-w";
      description = ''
        Bash keybinding for launching VS Code workspace selector.
        Uses readline key syntax, e.g. \\C-w for Ctrl+W.
      '';
    };
    dirs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "$HOME/Code"
        "$HOME/Work"
      ];
      description = ''
        List of workspace root directories.
        Each directory is scanned one level deep to discover projects.
      '';
    };
  };

  config = lib.mkIf (cfg.enable && config.programs.bash.enable) {

    home.packages = [
      pkgs.fzf
    ];

    programs.bash.bashrcExtra = ''
      export VSCODE_FZF_WORKSPACES="${workspaceDirs}"

      fcode() {
        local roots workspaces selected
        roots=()
        workspaces=()

        IFS=":" read -ra roots <<< "$VSCODE_FZF_WORKSPACES"

        for root in "''${roots[@]}"; do
          [[ -d "$root" ]] || continue
          while IFS= read -r -d "" f; do
            workspaces+=("$f")
          done < <(find "$root" -maxdepth 1 -name "*.code-workspace" -print0)
        done

        [[ ''${#workspaces[@]} -eq 0 ]] && echo "No workspaces found" && return 1

        selected=$(printf '%s\n' "''${workspaces[@]}" | fzf --prompt="VSCode Workspaces > ")

        [[ -n "$selected" ]] && code "$selected"
      }

      bind -x '"${cfg.shortcut}": fcode'
    '';
  };
}
