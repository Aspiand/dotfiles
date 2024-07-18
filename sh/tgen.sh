#!/bin/bash

set -ea

readonly ROOT=$(dirname "${BASH_SOURCE[0]}")

TORRC_TEMPLATE="$ROOT/../tor/torrc.template"
TORRC="$ROOT/../tor/torrc"
THOME="$HOME/.local/data/tor"
TLOG="$THOME/log/"

if [ ! -d "$THOME" ]; then
    mkdir -p "$THOME"
fi

if [ ! -d "$TLOG" ]; then
    mkdir -p "$TLOG"
fi

[ -z "$1" ] && TORRC=$1 || TORRC="$ROOT/../tor/torrc"

sed "s|\$THOME|$HOME|g; s|\$TLOG|$TLOG|g" "$TORRC_TEMPLATE" > "$TORRC"