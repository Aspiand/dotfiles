readonly FFM_FOLDERS=(
    # "/path/to/directory permission"

    # ClamAV
    "$HOME/.local/share/clamav 700"
    "$HOME/.local/share/clamav/log 700"
    "$HOME/.local/share/clamav/database 700"

    # SSH
    "$HOME/.ssh 700"
    "$HOME/.ssh/control 700"
)
readonly FFM_FILES=(
    # "/path/to/file permission"
)
readonly FFM_SYMLINKS=(
    # "/path/to/source /path/to/destination"

    "/storage/emulated/0 /data/data/com.termux.nix/files/home/storage"
)
readonly FFM_RECURSIVE=(
    # "/path/to/folder (folder permission) (file permission)"

    "$HOME/.local/share/clamav 700 600"
    "$HOME/.ssh 700 600"
)