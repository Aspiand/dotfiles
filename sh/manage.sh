#!/bin/bash

set -eu

readonly VERSION=1.1
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

# Parsing argument
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

echo "Folders:"

for folder in "${FOLDERS[@]}"; do
    read -r path permission <<< "$folder"
    echo -n "  $path/ ($permission): "

    if [ ! -d "$path" ]; then
        echo "[mkdir]"
        mkdir -p -m $permission $path
    elif [ $(stat -c "%a" $path) != $permission ]; then
        echo "[chmod($(stat -c "%a" $path))]"
        chmod $permission $path
    else
        echo "[ok]"
    fi
done

echo "Files:"

for file in "${FILES[@]}"; do
    read -r path permission <<< "$file"
    echo -n "  $path ($permission): "

    if [ ! -f $path ]; then
        echo "[not found]"
    elif [ $(stat -c "%a" $path) != $permission ]; then
        echo "[chmod($(stat -c "%a" $path))]"
        chmod $permission $path
    else
        echo "[ok]"
    fi
done


# readonly SYMLINKS=(
#     # "/path/to/source /path/to/destination"

#     "$(dirname $0)/../tor/torrc $(dirname $0)/test/torrrh"
# )
# echo "Symlinks:"

# for symlinks in "${SYMLINKS[@]}"; do
#     read -r source destination <<< "$symlinks"
#     echo -n "  $source -> $destination: "

#     # echo "  from $source"
#     # echo "  to   $destination"
#     # echo -n "  "

#     if [ ! -f $source ]; then
#         echo "[source not found]"
#     elif [ $(readlink -f $destination) != $source ]; then
#         ln -s $source $destination
#         echo "[create link]"
#     elif [ -e $destination ]; then
#         echo "[destination is available]"
#     else
#         echo "[ok]"
#     fi
# done

echo -n ""