#!/bin/sh

fetchf() {
    if [ ! -f "$1.completion.bash" ]; then
        curl -fsSL "$2" -o "$1.completion.bash"
    fi
}

fetch() {
    if type "$1" > /dev/null 2>&1; then
        fetchf "$@"
    fi
}

cd $(dirname ${BASH_SOURCE:-$0})
mkdir -p completion
cd completion

fetch git https://github.com/git/git/raw/master/contrib/completion/git-completion.bash
fetch tmux https://raw.githubusercontent.com/Bash-it/bash-it/master/completion/available/tmux.completion.bash

if [ -f /usr/share/bash-completion/bash_completion ]; then
    fetchf cht.sh https://cht.sh/:bash_completion
fi
