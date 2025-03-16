#!/usr/bin/env bash

if [ -u 0 ]; then
    echo "Please run this script as a non-root user."
    exit 1
fi

set -e

install_nix() {
    echo "Installing nix..."

    if [ ! -d /nix ]; then
        echo "Creating /nix directory..."
        sudo mkdir /nix
        sudo chown --verbose $USER: /nix
    fi

    echo "Choose nix installer:"
    echo "1. nix (original)"
    echo "2. nix-determinate (unofficial)"

    while true; do
        read -p "> " choice
        case $choice in
        1)
            sh <(curl -L https://nixos.org/nix/install) --no-daemon
            break
            ;;
        2)
            curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
            break
            ;;
        *)
            echo "Invalid choice, please select 1 or 2."
            ;;
        esac
    done

    [ ! -d ~/.config/nix ] && mkdir --verbose -p ~/.config/nix
    [ -f ~/.config/nix/nix.conf ] || mv --verbose ~/.config/nix/nix.conf ~/.config/nix/nix.conf.bak
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

    nix run nixpkgs.git -- clone https://github.com/Aspiand/dotfiles ~/.config/dotfiles
    nix run home-manager/master -- init --switch --flake ~/.config/dotfiles#mint
}

install_nix
