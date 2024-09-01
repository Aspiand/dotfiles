#!/bin/bash

set -eu

readonly VERSION=3.0
readonly ROOT=$(dirname "${BASH_SOURCE[0]}")

get_permission() {
    local path=$1

    read -r user group permission <<< "$(stat -c "%U %G %a" "$path")"
    echo "$user" "$group" "$permission"
}

readonly CONFIG_PATH=(
    "/etc/ffm/config.sh"
    "/etc/ffm.conf"
    "$ROOT/env.sh"
    "$HOME/.config/ffm/config.sh"
    "$HOME/.config/ffm.d/*.sh"
)

for config_path in "${CONFIG_PATH[@]}"; do
    [ -f "$config_path" ] && source "$config_path"
done

for folder in "${FFM_FOLDERS[@]}"; do
    read -r path apermission auser agroup <<< "$folder" # After
    read -r buser bgroup bpermission <<< "$(get_permission "$path")" # Before

    if [ ! -d "$path" ]; then
        mkdir -vpm "$apermission" "$path"
    elif [ "$bpermission" != "$apermission" ]; then
        chmod --verbose "$apermission" "$path"
    fi

    if [ "$buser" != "$auser" ] || [ "$bgroup" != "$agroup" ]; then
        chown --verbose "${auser}:${agroup}" "$path"
    fi
done

for file in "${FFM_FILES[@]}"; do
    read -r path apermission auser agroup <<< "$file" # After
    read -r buser bgroup bpermission <<< "$(get_permission "$path")" # Before

    if [ ! -f "$path" ]; then
        echo "$path not found!"
    elif [ "$bpermission" != "$apermission" ]; then
        chmod --verbose "$apermission" "$path"
    fi

    if [ "$buser" != "$auser" ] || [ "$bgroup" != "$agroup" ]; then
        chown --verbose "${auser}:${agroup}" "$path"
    fi
done

for symlinks in "${FFM_SYMLINKS[@]}"; do
    read -r source destination <<< "$symlinks"

    if [ -e "$destination" ] && [ "$(readlink -f "$destination")" == "$source" ]; then
        echo "[ok]"
    elif [ ! -e "$source" ]; then
        echo "[source not found]"
    elif [ -e "$destination" ]; then
        echo "[destination is available]"
    elif [ ! -e "$destination" ] && [ "$(readlink -f "$destination")" != "$source" ]; then
        ln -vs "$source" "$destination"
    fi
done

for recursive in "${FFM_RECURSIVE[@]}"; do
    read -r path folder file <<< "$recursive"

    find "$path" -type d -not -perm "$folder" -exec chmod --verbose "$folder" {} \;
    find "$path" -type f -not -perm "$file" -exec chmod --verbose "$file" {} \;
done

echo -n ""