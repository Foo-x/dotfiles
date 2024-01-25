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
    if ! has git; then
        echo "git required" 1>&2
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
if has gh; then
    {
        gh alias set --clobber cl 'repo clone'
        gh alias set --clobber clp 'repo clone $1 -- --filter=blob:none'
        gh alias set --clobber clps 'repo clone $1 -- --filter=blob:none --sparse'
        gh alias set --clobber cr 'repo create'
        gh alias set --clobber il 'issue list'
        gh alias set --clobber co 'pr checkout'
        gh alias set --clobber al 'alias list'
        gh alias set --clobber openr 'repo view -w'
        gh alias set --clobber openi 'issue view -w'
        gh alias set --clobber openp 'pr view -w'
        gh alias set --clobber --shell sync 'gh repo sync $(git config --get remote.origin.url | \grep -oP "(?<=:).+(?=\.)")'
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
    git clone --depth 1 https://github.com/b4b4r07/enhancd.git ${HOME}/enhancd
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
sh ${DOT_DIR}/.config/git/config_dynamic

mkdir -p ${XDG_CONFIG_HOME}/git/hooks
githooks_files="
prepare-commit-msg
"
echo "${githooks_files}" | xargs -I{} ln -sf ${DOT_DIR}/.config/git/hooks/{} ${XDG_CONFIG_HOME}/git/hooks/{}

# setup tmux
TMUX_DIR=${XDG_CONFIG_HOME}/tmux
mkdir -p ${TMUX_DIR}
ln -sf ${DOT_DIR}/.config/tmux/tmux.conf ${TMUX_DIR}/tmux.conf

# install tmux-resurrect
if [ ! -d ${TMUX_DIR}/tmux-resurrect ]; then
    git clone --depth 1 https://github.com/tmux-plugins/tmux-resurrect.git ${TMUX_DIR}/tmux-resurrect
fi

# install tmux-continuum
if [ ! -d ${TMUX_DIR}/tmux-continuum ]; then
    git clone --depth 1 https://github.com/tmux-plugins/tmux-continuum.git ${TMUX_DIR}/tmux-continuum
fi

# install mise
if ! type mise > /dev/null 2>&1; then
    curl https://mise.jdx.dev/install.sh | sh
fi

# install delta
if ! type delta > /dev/null 2>&1; then
    mise use -gy delta
fi

# install bat
if ! type bat > /dev/null 2>&1; then
    mise use -gy bat
fi

# install deno
if ! type deno > /dev/null 2>&1; then
    mise use -gy deno
fi

# install neovim
if ! type nvim > /dev/null 2>&1; then
    mise use -gy neovim@nightly
fi

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

# setup kanbanmd
if [ ! -d ${XDG_DATA_HOME}/kanbanmd ]; then
    cp -r kanbanmd ${XDG_DATA_HOME}
else
    \cp kanbanmd/README.md ${XDG_DATA_HOME}/kanbanmd
fi

sh ${DOT_DIR}/setup_vim.sh

echo "Done."
