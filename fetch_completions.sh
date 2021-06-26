#!/bin/bash

fetch() {
    if type "$1" &> /dev/null && [[ ! -f "$1" ]]; then
        curl -fsSL "$2" -o "$1.completion.bash"
    fi
}

cd $(dirname ${BASH_SOURCE:-$0})
mkdir -p completion
cd completion

fetch git https://github.com/git/git/raw/master/contrib/completion/git-completion.bash
fetch hub https://github.com/github/hub/raw/master/etc/hub.bash_completion.sh
fetch docker-compose https://raw.githubusercontent.com/docker/compose/master/contrib/completion/bash/docker-compose
fetch tmux https://raw.githubusercontent.com/Bash-it/bash-it/master/completion/available/tmux.completion.bash
fetch cht.sh https://cht.sh/:bash_completion
