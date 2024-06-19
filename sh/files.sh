#!/bin/bash

set -eu

readonly FOLDERS=(
    # "/path/to/directory permission"

    "$HOME/.local/tor 700"
    "$HOME/.local/tor/config 700"
    "$HOME/.local/tor/service 700"

    "$HOME/.local/history 700"
)
readonly FILES=(
    # "/path/to/file permission"

    "$HOME/.local/history/zsh 600"
)

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

    if [ $(stat -c "%a" $path) != $permission ]; then
        echo "[chmod($(stat -c "%a" $path))]"
        chmod $permission $path
    else
        echo "[ok]"
    fi
done

echo -n ""