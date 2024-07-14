#!/bin/bash

set -eu

readonly VERSION=2.0
readonly ROOT=$(dirname "${BASH_SOURCE[0]}")

get_permission() {
    local path=$1

    read -r user group permission <<< "$(stat -c "%U %G %a" "$path")"
    echo "$user" "$group" "$permission"
}

# Parsing argument
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

echo "Folders:"

for folder in "${FFM_FOLDERS[@]}"; do
    read -r path permission <<< "$folder"
    echo -n "  $path/ ($permission): "

    if [ ! -d "$path" ]; then
        echo "[mkdir]"
        mkdir -pm "$permission" "$path"
    elif [ "$(stat -c "%a" "$path")" != "$permission" ]; then
        echo "[chmod($(stat -c "%a" "$path"))]"
        chmod "$permission" "$path"
    else
        echo "[ok]"
    fi
done

echo "Files:"

for file in "${FFM_FILES[@]}"; do
    read -r path permission <<< "$file"
    echo -n "  $path ($permission): "

    if [ ! -f "$path" ]; then
        echo "[not found]"
    elif [ "$(stat -c "%a" "$path")" != "$permission" ]; then
        echo "[chmod($(stat -c "%a" "$path"))]"
        chmod "$permission" "$path"
    else
        echo "[ok]"
    fi
done

echo "Symlinks:"

for symlinks in "${FFM_SYMLINKS[@]}"; do
    read -r source destination <<< "$symlinks"
    echo -n "  $source -> $destination: "

    if [ -e "$destination" ] && [ "$(readlink -f "$destination")" == "$source" ]; then
        echo "[ok]"
    elif [ ! -e "$source" ]; then
        echo "[source not found]"
    elif [ -e "$destination" ]; then
        echo "[destination is available]"
    elif [ ! -e "$destination" ] && [ "$(readlink -f "$destination")" != "$source" ]; then
        ln -s "$source" "$destination"
        echo "[create link]"
    else
        echo "[ok]"
    fi
done

echo "Recursive:"
for recursive in "${FFM_RECURSIVE[@]}"; do
    read -r path folder file <<< "$recursive"
    echo "  $path > $folder | $file"

    # find $path -type d -not -perm $folder -exec \
    #     echo "$path ($(stat -c "%a" "$path")): " \;

    find "$path" -type d -not -perm "$folder" -exec chmod --verbose "$folder" {} \;
    find "$path" -type f -not -perm "$file" -exec chmod --verbose "$file" {} \;
done

echo -n ""