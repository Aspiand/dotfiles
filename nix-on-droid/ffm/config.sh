readonly FOLDERS=(
    # "/path/to/directory permission"

    # ClamAV
    "$HOME/.local/share/clamav 700"
    "$HOME/.local/share/clamav/log 700"
    "$HOME/.local/share/clamav/database 700"

    # SSH
    "$HOME/.ssh 700"
    "$HOME/.ssh/control 700"
)
readonly FILES=(
    # "/path/to/file permission"
)
readonly SYMLINKS=(
    # "/path/to/source /path/to/destination"

    "/storage/emulated/0 /data/data/com.termux.nix/files/home/storage"
)
readonly RECURSIVE=(
    # "/path/to/folder (folder permission) (file permission)"

    "$HOME/.local/share/clamav 700 600"
    "$HOME/.ssh 700 600"
)