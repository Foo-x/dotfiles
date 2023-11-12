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

# include .bashrc
touch ${HOME}/.bashrc
source_bashrc=". ${DOT_DIR}/.bashrc"
if ! \grep -q "${source_bashrc}" ${HOME}/.bashrc; then
    echo "${source_bashrc}" >> ${HOME}/.bashrc
fi

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
## source fzf last because LS_COLORS must be set before loading inputrc and fzf use 'bind' which loads inputrc
sed -i '$!{/fzf/{H;d}};$G' ${HOME}/.bashrc

# install enhancd
if [ ! -d ${HOME}/enhancd ]; then
    git clone --depth 1 https://github.com/b4b4r07/enhancd ${HOME}/enhancd
fi

mkdir -p ${HOME}/.local/bin
# install neovim
if [ ! -f ${HOME}/.local/bin/nvim ]; then
    curl -L https://github.com/neovim/neovim/releases/download/stable/nvim.appimage > ${HOME}/.local/bin/nvim.appimage
    chmod +x ${HOME}/.local/bin/nvim.appimage
    if ${HOME}/.local/bin/nvim.appimage -v > /dev/null 2>&1; then
        mv ${HOME}/.local/bin/nvim.appimage ${HOME}/.local/bin/nvim
    else
        (cd ${HOME}/.local/bin/; ./nvim.appimage --appimage-extract; ln -sf ./squashfs-root/usr/bin/nvim ./nvim; rm ./nvim.appimage) > /dev/null 2>&1
    fi
fi

binfiles="
nvimdirdiff
"
echo "${binfiles}" | xargs -I{} ln -sf ${DOT_DIR}/bin/{} ${HOME}/.local/bin/{}

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

# setup vim
mkdir -p ${XDG_CONFIG_HOME}/vim
mkdir -p ${XDG_CONFIG_HOME}/vim/pack/plugins/start/
mkdir -p ${XDG_CONFIG_HOME}/vim/pack/colors/start/
vimrc_files=$(cd ${DOT_DIR}/.config/vim && \ls -1 *vimrc)
printf "${vimrc_files}" | xargs -I{} ln -sf ${DOT_DIR}/.config/vim/{} ${XDG_CONFIG_HOME}/vim/{}

VIM_PACK_DIR=${XDG_CONFIG_HOME}/vim/pack/plugins/start
# install fzf.vim
if [ ! -d ${VIM_PACK_DIR}/fzf.vim ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.vim.git ${VIM_PACK_DIR}/fzf.vim
fi

# install vim-fugitive
if [ ! -d ${VIM_PACK_DIR}/vim-fugitive ]; then
    git clone --depth 1 https://github.com/tpope/vim-fugitive.git ${VIM_PACK_DIR}/vim-fugitive
fi

# install gv.vim
if [ ! -d ${VIM_PACK_DIR}/gv.vim ]; then
    git clone --depth 1 https://github.com/junegunn/gv.vim.git  ${VIM_PACK_DIR}/gv.vim
fi

# install vim-gitgutter
if [ ! -d ${VIM_PACK_DIR}/vim-gitgutter ]; then
    git clone --depth 1 https://github.com/airblade/vim-gitgutter.git ${VIM_PACK_DIR}/vim-gitgutter
fi

# install vim-sneak
if [ ! -d ${VIM_PACK_DIR}/vim-sneak ]; then
    git clone --depth 1 https://github.com/justinmk/vim-sneak.git ${VIM_PACK_DIR}/vim-sneak
fi

mkdir -p ${XDG_CONFIG_HOME}/nvim
nvim_files="
init.vim
"
echo "${nvim_files}" | xargs -I{} ln -sf ${DOT_DIR}/.config/nvim/{} ${XDG_CONFIG_HOME}/nvim/{}

nvim +'helptags ALL' +qa

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

echo "Done."
