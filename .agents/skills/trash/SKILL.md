---
name: trash
description: |
  Delete files with trash-cli, never `rm`. Use this skill whenever a task
  involves removing, deleting, cleaning up, moving away, or replacing files or
  directories in this repo — `rm` is deny-listed in opencode config, `trash-put`
  is the approved replacement. Also load it when the user asks what is in the
  trash, wants something restored, or an `rm`/`trash` command was denied.
---

`rm` is deny-listed. Deletion goes through `trash-put` (alias `trash`), which
moves the entry into the FreeDesktop trash (`~/.local/share/Trash`) instead of
unlinking it. Everything stays recoverable until the trash is emptied.

## Commands

| Task | Command |
| --- | --- |
| Trash a file or dir (recursive by default) | `trash-put <path>...` |
| Path starting with `-` | `trash-put -- -weird-name` |
| List trashed entries (date + original path) | `trash-list` |
| Filter the list | `trash-list \| rg <pattern>` |
| Restore by original path | `trash-restore <original-path>` |
| Overwrite on restore | `trash-restore --overwrite <path>` |
| Which trashcans exist | `trash-list --trash-dirs` |
| Which volumes are supported | `trash-list --volumes` |
| Custom trash dir | `trash-put --trash-dir <dir> <path>` |

`trash-put` accepts `-f` (ignore missing) and `-i` (prompt). `-r`, `-R`, `-d`
are accepted and ignored for GNU `rm` compatibility, so `rm -rf x` becomes
`trash-put x`.

## Hard rules

- Never use `rm`, and never reach it through any indirection: `find -delete`,
  `find -exec rm`, `xargs rm`, `sh -c`, `python -c os.remove`, `perl -e
  unlink`, or anything else that unlinks. The denial is about the action, not
  the binary name.
- Also deny-listed, for the same reason: `unlink`, `rmdir`, `shred`, `git rm`,
  `git clean`, `trash-empty`, `trash-rm`. If a task genuinely needs the trash
  emptied or history purged, stop and ask the user to run it themselves.
- Never run bare `trash-restore` or bare `trash-empty`: both are interactive
  prompt loops and will hang the session. Always pass a path.
- Recursive cleanup is `trash-put <paths>`, not `find ... -delete`. If a glob
  is needed, expand it in the shell first (`trash-put ./build/*.tmp`) or list
  candidates with `find`/`rg --files` and pass them to `trash-put`.

## Caveats

- Trashing a tracked file is still a worktree deletion — `git status` shows it
  as `D`. To undo that, `git restore <path>` is cheaper than a trash restore.
- trash-cli does not support Btrfs volumes; on such a mount `trash-put` fails
  instead of falling back to `rm`. Report it, do not substitute a hard delete.
- Files on another filesystem with no writable `.Trash` go to
  `<mount>/.Trash-$uid`; listing with plain `trash-list` may not show them —
  use `trash-list --volumes` / `--trash-dirs` to check.
- `trash-put` on a symlink trashes the link, not the target.
