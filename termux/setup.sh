#!/data/data/com.termux/files/usr/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

source "$SCRIPT_DIR/env.sh"

export DEBIAN_FRONTEND=noninteractive
export SSH_DIR="$ROOT/etc/ssh"

apt update && apt upgrade -y && apt install -y \
    aria2 \
    bat \
    bash-completion \
    curl \
    fzf \
    git \
    git-delta \
    gitui \
    htop \
    micro \
    ncdu \
    nmap \
    openssh \
    restic \
    rsync \
    tmux \
    wget \
    zoxide \
    termux-services

sv-enable ssh-agent # sshd

# Generate SSH key untuk penggunaan harian (user)
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    mkdir -p "$HOME/.ssh"
    ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N ""
    ssh-add "$HOME/.ssh/id_ed25519"
fi

# Generate SSH key untuk sshd (host key)
if [ ! -f "$SSH_DIR/ssh_host_ed25519_key" ]; then
    mkdir -p "$SSH_DIR"
    ssh-keygen -t ed25519 -f "$SSH_DIR/ssh_host_ed25519_key" -N ""
fi

echo "source '$SCRIPT_DIR/init.sh' >> '$HOME/.bashrc'"