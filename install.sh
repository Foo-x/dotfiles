#!/bin/sh

DOT_DIR="${HOME}/.dotfiles"

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

touch ${HOME}/.user_profile

files="
.bash_profile
.gitmessage
.inputrc
.profile
.vimrc
.tmux.conf
"
echo "${files}" | xargs -I{} ln -sf ${DOT_DIR}/{} ${HOME}/{}

mkdir -p ${HOME}/.config/git
gitconfig_files="
commit_template
config
ignore
"
echo "${gitconfig_files}" | xargs -I{} ln -sf ${DOT_DIR}/.config/git/{} ${HOME}/.config/git/{}

mkdir -p ${HOME}/.config/git/hooks
githooks_files="
prepare-commit-msg
"
echo "${githooks_files}" | xargs -I{} ln -sf ${DOT_DIR}/.config/git/hooks/{} ${HOME}/.config/git/hooks/{}

mkdir -p ${HOME}/.vim/pack/plugins/start/
mkdir -p ${HOME}/.vim/pack/colors/start/
vimrc_files="
command.vimrc
keymap.vimrc
search.vimrc
"
echo "${vimrc_files}" | xargs -I{} ln -sf ${DOT_DIR}/.vim/{} ${HOME}/.vim/{}

# install fzf.vim
if [ ! -d ${HOME}/.vim/pack/plugins/start/fzf.vim ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.vim.git ${HOME}/.vim/pack/plugins/start/fzf.vim
fi

# install vim-fugitive
if [ ! -d ${HOME}/.vim/pack/plugins/start/vim-fugitive ]; then
    git clone --depth 1 https://github.com/tpope/vim-fugitive.git ${HOME}/.vim/pack/plugins/start/vim-fugitive
fi

# install gv.vim
if [ ! -d ${HOME}/.vim/pack/plugins/start/gv.vim ]; then
    git clone --depth 1 https://github.com/junegunn/gv.vim.git  ${HOME}/.vim/pack/plugins/start/gv.vim
fi

# install vim-gitgutter
if [ ! -d ${HOME}/.vim/pack/plugins/start/vim-gitgutter ]; then
    git clone --depth 1 https://github.com/airblade/vim-gitgutter.git ${HOME}/.vim/pack/plugins/start/vim-gitgutter
fi

# install vim-sneak
if [ ! -d ${HOME}/.vim/pack/plugins/start/vim-sneak ]; then
    git clone --depth 1 https://github.com/justinmk/vim-sneak.git ${HOME}/.vim/pack/plugins/start/vim-sneak
fi

mkdir -p ${HOME}/.config/nvim
nvim_files="
init.vim
"
echo "${nvim_files}" | xargs -I{} ln -sf ${DOT_DIR}/.config/nvim/{} ${HOME}/.config/nvim/{}

exe_files="
fetch_completions.sh
fetch_git_prompt.sh
"
echo "${exe_files}" | xargs -I{} sh ${DOT_DIR}/{}

echo "Done."
