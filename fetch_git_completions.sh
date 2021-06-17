#!/bin/bash

if ! type git &> /dev/null; then
    return
fi

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

if [[ ! -f ${SCRIPT_DIR}/git-prompt.sh ]]; then
    wget -P ${SCRIPT_DIR} https://github.com/git/git/raw/master/contrib/completion/git-prompt.sh
fi

if [[ ! -f ${SCRIPT_DIR}/git-completion.bash ]]; then
    wget -P ${SCRIPT_DIR} https://github.com/git/git/raw/master/contrib/completion/git-completion.bash
    echo "__git_complete g __git_main" >> ${SCRIPT_DIR}/git-completion.bash
fi

if [[ ! -f ${SCRIPT_DIR}/hub.bash_completion.sh ]]; then
    wget -P ${SCRIPT_DIR} https://github.com/github/hub/raw/master/etc/hub.bash_completion.sh
fi
