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

# install fern.vim
if [ ! -d ${VIM_PACK_DIR}/fern.vim ]; then
    git clone --depth 1 https://github.com/lambdalisue/fern.vim.git ${VIM_PACK_DIR}/fern.vim
fi

# install fern-git-status.vim
if [ ! -d ${VIM_PACK_DIR}/fern-git-status.vim ]; then
    git clone --depth 1 https://github.com/lambdalisue/fern-git-status.vim.git ${VIM_PACK_DIR}/fern-git-status.vim
fi

# install fern-renderer-nerdfont.vim
if [ ! -d ${VIM_PACK_DIR}/fern-renderer-nerdfont.vim ]; then
    git clone --depth 1 https://github.com/lambdalisue/fern-renderer-nerdfont.vim.git ${VIM_PACK_DIR}/fern-renderer-nerdfont.vim
fi

# install glyph-palette.vim
if [ ! -d ${VIM_PACK_DIR}/glyph-palette.vim ]; then
    git clone --depth 1 https://github.com/lambdalisue/glyph-palette.vim.git ${VIM_PACK_DIR}/glyph-palette.vim
fi

# install nerdfont.vim
if [ ! -d ${VIM_PACK_DIR}/nerdfont.vim ]; then
    git clone --depth 1 https://github.com/lambdalisue/nerdfont.vim.git ${VIM_PACK_DIR}/nerdfont.vim
fi

# install vimdoc-ja
if [ ! -d ${VIM_PACK_DIR}/vimdoc-ja ]; then
    git clone --depth 1 https://github.com/vim-jp/vimdoc-ja.git ${VIM_PACK_DIR}/vimdoc-ja
fi

# setup nvim
mkdir -p ${XDG_CONFIG_HOME}/nvim
mkdir -p ${XDG_CONFIG_HOME}/nvim/pack/plugins/start/
mkdir -p ${XDG_CONFIG_HOME}/nvim/pack/colors/start/

NVIM_PACK_DIR=${XDG_CONFIG_HOME}/nvim/pack/plugins/start
# install nvim-lspconfig
if [ ! -d ${NVIM_PACK_DIR}/nvim-lspconfig ]; then
    git clone --depth 1 https://github.com/neovim/nvim-lspconfig.git ${NVIM_PACK_DIR}/nvim-lspconfig
fi

# install mason.nvim
if [ ! -d ${NVIM_PACK_DIR}/mason.nvim ]; then
    git clone --depth 1 https://github.com/williamboman/mason.nvim.git ${NVIM_PACK_DIR}/mason.nvim
fi

# install mason-lspconfig.nvim
if [ ! -d ${NVIM_PACK_DIR}/mason-lspconfig.nvim ]; then
    git clone --depth 1 https://github.com/williamboman/mason-lspconfig.nvim.git ${NVIM_PACK_DIR}/mason-lspconfig.nvim
fi

# install nvim-cmp
if [ ! -d ${NVIM_PACK_DIR}/nvim-cmp ]; then
    git clone --depth 1 https://github.com/hrsh7th/nvim-cmp.git ${NVIM_PACK_DIR}/nvim-cmp
fi

# install cmp-nvim-lsp
if [ ! -d ${NVIM_PACK_DIR}/cmp-nvim-lsp ]; then
    git clone --depth 1 https://github.com/hrsh7th/cmp-nvim-lsp.git ${NVIM_PACK_DIR}/cmp-nvim-lsp
fi

# install cmp-buffer
if [ ! -d ${NVIM_PACK_DIR}/cmp-buffer ]; then
    git clone --depth 1 https://github.com/hrsh7th/cmp-buffer.git ${NVIM_PACK_DIR}/cmp-buffer
fi

# install cmp-path
if [ ! -d ${NVIM_PACK_DIR}/cmp-path ]; then
    git clone --depth 1 https://github.com/hrsh7th/cmp-path.git ${NVIM_PACK_DIR}/cmp-path
fi

# install vim-vsnip
if [ ! -d ${NVIM_PACK_DIR}/vim-vsnip ]; then
    git clone --depth 1 https://github.com/hrsh7th/vim-vsnip.git ${NVIM_PACK_DIR}/vim-vsnip
fi

# install cmp-vsnip
if [ ! -d ${NVIM_PACK_DIR}/cmp-vsnip ]; then
    git clone --depth 1 https://github.com/hrsh7th/cmp-vsnip.git ${NVIM_PACK_DIR}/cmp-vsnip
fi

# install lspkind.nvim
if [ ! -d ${NVIM_PACK_DIR}/lspkind.nvim ]; then
    git clone --depth 1 https://github.com/onsails/lspkind.nvim.git ${NVIM_PACK_DIR}/lspkind.nvim
fi

# install nvim-treesitter
if [ ! -d ${NVIM_PACK_DIR}/nvim-treesitter ]; then
    git clone --depth 1 https://github.com/nvim-treesitter/nvim-treesitter.git ${NVIM_PACK_DIR}/nvim-treesitter
fi

# install lspsaga.nvim
if [ ! -d ${NVIM_PACK_DIR}/lspsaga.nvim ]; then
    git clone --depth 1 https://github.com/kkharji/lspsaga.nvim.git ${NVIM_PACK_DIR}/lspsaga.nvim
fi

# install fidget.nvim
if [ ! -d ${NVIM_PACK_DIR}/fidget.nvim ]; then
    git clone --depth 1 https://github.com/j-hui/fidget.nvim.git ${NVIM_PACK_DIR}/fidget.nvim
fi

mkdir -p ${XDG_CONFIG_HOME}/nvim
nvim_files="
init.lua
"
echo "${nvim_files}" | xargs -I{} ln -sf ${DOT_DIR}/.config/nvim/{} ${XDG_CONFIG_HOME}/nvim/{}

nvim -es +"set pp+=${XDG_CONFIG_HOME}/vim,${XDG_CONFIG_HOME}/vim/after | silent! packl! | helptags ALL | q"
