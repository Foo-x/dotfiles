#!/bin/bash

if ! type git &> /dev/null; then
    exit 0
fi

cd $(dirname ${BASH_SOURCE:-$0})

if [[ ! -f git-prompt.sh ]]; then
    curl -O https://github.com/git/git/raw/master/contrib/completion/git-prompt.sh
fi

if [[ ! -f git-completion.bash ]]; then
    curl -O https://github.com/git/git/raw/master/contrib/completion/git-completion.bash
    echo "__git_complete g __git_main" >> ${SCRIPT_DIR}/git-completion.bash
fi

if [[ ! -f hub.bash_completion.sh ]]; then
    curl -O https://github.com/github/hub/raw/master/etc/hub.bash_completion.sh
fi
