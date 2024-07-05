readonly FOLDERS=(
    # "/path/to/directory permission"

    # Tor
    "$HOME/.local/tor 700"
    "$HOME/.local/tor/config 700"
    "$HOME/.local/tor/log 700"
    "$HOME/.local/tor/service 700"

    "$HOME/.local/history 700"

    # SSH
    "$HOME/.ssh 700"
    "$HOME/.ssh/control u+rwx,go-rwx"

    # GnuPG
    "$HOME/.gnupg 700"
)
readonly FILES=(
    # "/path/to/file permission"

    # Log
    "$HOME/.local/history/zsh 600"
    "$HOME/.local/tor/log/debug.log 600"
    "$HOME/.local/tor/log/notices.log 600"
)
readonly SYMLINKS=(
    # "/path/to/source /path/to/destination"
)
readonly RECURSIVE=(
    # "/path/to/folder (folder permission) (file permission)"
    "$HOME/test/code 755 644"
)