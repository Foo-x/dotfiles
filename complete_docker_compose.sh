#!/bin/bash

if [[ -f /etc/bash_completion.d/docker-compose ]]; then
    exit 0
fi

cmd="curl \
    -L https://raw.githubusercontent.com/docker/compose/1.29.2/contrib/completion/bash/docker-compose \
    -o /etc/bash_completion.d/docker-compose"

if [ ${EUID:-${UID}} = 0 ]; then
    $(${cmd})
elif type sudo &> /dev/null; then
    sudo ${cmd}
fi
