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
