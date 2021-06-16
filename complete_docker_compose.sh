#!/bin/bash

COMPLETION_DIR=${BASH_COMPLETION_USER_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/bash-completion}/completions

if [[ -f ${COMPLETION_DIR}/docker-compose ]]; then
    exit 0
fi

mkdir -p ${COMPLETION_DIR}
curl \
    -L https://raw.githubusercontent.com/docker/compose/1.29.2/contrib/completion/bash/docker-compose \
    -o ${COMPLETION_DIR}/docker-compose
