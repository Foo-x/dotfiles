#!/bin/sh

if ! type git > /dev/null 2>&1; then
    exit 0
fi

cd $(dirname ${BASH_SOURCE:-$0})

if [ ! -f git-prompt.sh ]; then
    curl -fsSLO https://github.com/git/git/raw/master/contrib/completion/git-prompt.sh
fi
