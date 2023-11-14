#!/usr/bin/env sh

DOT_DIR="${DOT_DIR:-${HOME}/.dotfiles}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"

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

# install vimdoc-ja
if [ ! -d ${VIM_PACK_DIR}/vimdoc-ja ]; then
    git clone --depth 1 https://github.com/vim-jp/vimdoc-ja.git ${VIM_PACK_DIR}/vimdoc-ja
fi

mkdir -p ${XDG_CONFIG_HOME}/nvim
nvim_files="
init.vim
"
echo "${nvim_files}" | xargs -I{} ln -sf ${DOT_DIR}/.config/nvim/{} ${XDG_CONFIG_HOME}/nvim/{}

nvim -es +"set pp+=${XDG_CONFIG_HOME}/vim,${XDG_CONFIG_HOME}/vim/after | silent! packl! | helptags ALL | q"
