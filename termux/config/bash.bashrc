HISTCONTROL=ignoreboth
HISTFILE="/home/ao/.local/history/bash"
HISTFILESIZE=100000
# HISTIGNORE=clear:history:ls
HISTSIZE=10000
mkdir -p "$(dirname "$HISTFILE")"

shopt -s histappend
shopt -s autocd

eval "$(zoxide init bash )"
eval "$(fzf --bash)"