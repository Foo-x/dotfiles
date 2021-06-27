umask 022

if [ -d "${HOME}/bin" ] ; then
    PATH="${HOME}/bin:${PATH}"
fi

if [ -d "${HOME}/.local/bin" ] ; then
    PATH="${HOME}/.local/bin:${PATH}"
fi

# for additional PATHs
if [ -f "${HOME}/.user_profile" ]; then
    . "${HOME}/.user_profile"
fi

# remove duplicates
export PATH=$(printf "${PATH}" | awk -v RS=: -v ORS=: '!arr[$0]++')

if type ssh-agent &> /dev/null && [[ -z "${SSH_AUTH_SOCK}" ]]; then
    # Check for a currently running instance of the agent
    RUNNING_AGENT="`ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]'`"
    if [ "$RUNNING_AGENT" = "0" ]; then
        # Launch a new instance of the agent
        ssh-agent -s &> $HOME/.ssh/ssh-agent
    fi
    {
        eval `cat $HOME/.ssh/ssh-agent`
        ssh-add
    } &> /dev/null
fi
