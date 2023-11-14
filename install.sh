#!/usr/bin/env sh

DOT_DIR="${HOME}/.dotfiles"
XDG_CONFIG_HOME="${HOME}/.config"
XDG_CACHE_HOME="${HOME}/.cache"
XDG_DATA_HOME="${HOME}/.local/share"
XDG_STATE_HOME="${HOME}/.local/state"

has() {
    type "$1" > /dev/null 2>&1
}

if [ ! ${IS_UPDATED} ]; then
    if ! has git || ! has curl; then
        echo "curl or wget or git required" 1>&2
        exit 1
    fi

    if [ -d ${DOT_DIR} ]; then
        git -C ${DOT_DIR} pull
    else
        git clone --depth 1 https://github.com/Foo-x/dotfiles.git ${DOT_DIR}
    fi

    export IS_UPDATED=true
    ${DOT_DIR}/install.sh
    exit 0
fi

mkdir -p ${XDG_CONFIG_HOME}
mkdir -p ${XDG_CACHE_HOME}
mkdir -p ${XDG_DATA_HOME}
mkdir -p ${XDG_STATE_HOME}

# setup gh
if type gh > /dev/null 2>&1; then
    {
        gh alias set cl 'repo clone'
        gh alias set clp 'repo clone $1 -- --filter=blob:none --sparse'
        gh alias set cr 'repo create'
        gh alias set sync 'repo sync'
        gh alias set il 'issue list'
        gh alias set co 'pr checkout'
        gh alias set al 'alias list'
        gh alias set openr 'repo view -w'
        gh alias set openi 'issue view -w'
        gh alias set openp 'pr view -w'
    } > /dev/null 2>&1
fi

# install fzf
if [ ! -d ${HOME}/.fzf ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ${HOME}/.fzf
    ${HOME}/.fzf/install --key-bindings --completion --update-rc
fi
# include .bashrc
touch ${HOME}/.bashrc
source_bashrc=". ${DOT_DIR}/.bashrc"
sed -ie "\~${source_bashrc}~d" ${HOME}/.bashrc
if \grep -qF "fzf" ${HOME}/.bashrc; then
    # load bashrc before fzf because LS_COLORS must be set before loading inputrc and fzf use 'bind' which loads inputrc
    sed -ie "/fzf/i ${source_bashrc}" ${HOME}/.bashrc
else
    echo "${source_bashrc}" >> ${HOME}/.bashrc
fi

# install enhancd
if [ ! -d ${HOME}/enhancd ]; then
    git clone --depth 1 https://github.com/b4b4r07/enhancd ${HOME}/enhancd
fi

mkdir -p ${HOME}/.local/bin

touch ${HOME}/.user_profile

dotfiles="
.bash_profile
.inputrc
.profile
"
echo "${dotfiles}" | xargs -I{} ln -sf ${DOT_DIR}/{} ${HOME}/{}

# setup git
git config --global include.path ${DOT_DIR}/.config/git/config

mkdir -p ${XDG_CONFIG_HOME}/git
gitconfig_files="
commit_template
ignore
"
echo "${gitconfig_files}" | xargs -I{} ln -sf ${DOT_DIR}/.config/git/{} ${XDG_CONFIG_HOME}/git/{}
[ -f ${HOME}/.gitconfig ] && mv ${HOME}/.gitconfig ${XDG_CONFIG_HOME}/git/config

mkdir -p ${XDG_CONFIG_HOME}/git/hooks
githooks_files="
prepare-commit-msg
"
echo "${githooks_files}" | xargs -I{} ln -sf ${DOT_DIR}/.config/git/hooks/{} ${XDG_CONFIG_HOME}/git/hooks/{}

# setup tmux
mkdir -p ${XDG_CONFIG_HOME}/tmux
ln -sf ${DOT_DIR}/.config/tmux/tmux.conf ${XDG_CONFIG_HOME}/tmux/tmux.conf

exe_files="
fetch_completions.sh
fetch_git_prompt.sh
"
echo "${exe_files}" | xargs -I{} sh ${DOT_DIR}/{}

# setup bash history
mkdir -p ${XDG_STATE_HOME}/bash
if [ -f ${HOME}/.bash_history ]; then
  cat ${HOME}/.bash_history >> ${XDG_STATE_HOME}/bash/history
  rm ${HOME}/.bash_history
fi

sh ${DOT_DIR}/setup_vim.sh

echo "Done."
