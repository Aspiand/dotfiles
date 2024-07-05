#!/bin/bash

set -eu

readonly VERSION=1.3
readonly ROOT=$(dirname $BASH_SOURCE)

if [ -f "$ROOT/env.sh" ]; then
    source $ROOT/env.sh
fi

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

echo "Symlinks:"

for symlinks in "${SYMLINKS[@]}"; do
    read -r source destination <<< "$symlinks"
    echo -n "  $source -> $destination: "

    if [ -e $destination ] && [ $(readlink -f $destination) == $source ]; then
        echo "[ok]"
    elif [ ! -e $source ]; then
        echo "[source not found]"
    elif [ -e $destination ]; then
        echo "[destination is available]"
    elif [ ! -e $destination ] && [ $(readlink -f $destination) != $source ]; then
        ln -s $source $destination
        echo "[create link]"
    else
        echo "[ok]"
    fi
done

echo -n ""