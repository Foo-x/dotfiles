#!/usr/bin/env sh

DOT_DIR="${DOT_DIR:-${HOME}/.dotfiles}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"

# setup vim
VIM_PACK_DIR=${XDG_CONFIG_HOME}/vim/pack/plugins/start
VIM_PACK_COLORS_DIR=${XDG_CONFIG_HOME}/vim/pack/colors/opt

mkdir -p ${VIM_PACK_DIR}
mkdir -p ${VIM_PACK_COLORS_DIR}
vimrc_files=$(cd ${DOT_DIR}/.config/vim && \ls -1 *vimrc)
printf "${vimrc_files}" | xargs -I{} ln -sf ${DOT_DIR}/.config/vim/{} ${XDG_CONFIG_HOME}/vim/{}

# install everforest
if [ ! -d ${VIM_PACK_COLORS_DIR}/everforest ]; then
    git clone --depth 1 https://github.com/sainnhe/everforest.git ${VIM_PACK_COLORS_DIR}/everforest
fi

# install iceberg.vim
if [ ! -d ${VIM_PACK_COLORS_DIR}/iceberg.vim ]; then
    git clone --depth 1 https://github.com/cocopon/iceberg.vim.git ${VIM_PACK_COLORS_DIR}/iceberg.vim
fi

# install fzf.vim
if [ ! -d ${VIM_PACK_DIR}/fzf.vim ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.vim.git ${VIM_PACK_DIR}/fzf.vim
fi

# install vim-fugitive
if [ ! -d ${VIM_PACK_DIR}/vim-fugitive ]; then
    git clone --depth 1 https://github.com/tpope/vim-fugitive.git ${VIM_PACK_DIR}/vim-fugitive
fi

# install vim-rhubarb
if [ ! -d ${VIM_PACK_DIR}/vim-rhubarb ]; then
    git clone --depth 1 https://github.com/tpope/vim-rhubarb.git ${VIM_PACK_DIR}/vim-rhubarb
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

# install bullets.vim
if [ ! -d ${VIM_PACK_DIR}/bullets.vim ]; then
    git clone --depth 1 https://github.com/bullets-vim/bullets.vim.git ${VIM_PACK_DIR}/bullets.vim
fi

# install previm
if [ ! -d ${VIM_PACK_DIR}/previm ]; then
    git clone --depth 1 https://github.com/previm/previm.git ${VIM_PACK_DIR}/previm
fi

# install vim-table-mode
if [ ! -d ${VIM_PACK_DIR}/vim-table-mode ]; then
    git clone --depth 1 https://github.com/dhruvasagar/vim-table-mode.git ${VIM_PACK_DIR}/vim-table-mode
fi

# install linediff.vim
if [ ! -d ${VIM_PACK_DIR}/linediff.vim ]; then
    git clone --depth 1 https://github.com/AndrewRadev/linediff.vim.git ${VIM_PACK_DIR}/linediff.vim
fi

# install capture.vim
if [ ! -d ${VIM_PACK_DIR}/capture.vim ]; then
    git clone --depth 1 https://github.com/tyru/capture.vim.git ${VIM_PACK_DIR}/capture.vim
fi

# install rainbow_csv
if [ ! -d ${VIM_PACK_DIR}/rainbow_csv ]; then
    git clone --depth 1 https://github.com/mechatroner/rainbow_csv.git ${VIM_PACK_DIR}/rainbow_csv
fi

# install vimdoc-ja
if [ ! -d ${VIM_PACK_DIR}/vimdoc-ja ]; then
    git clone --depth 1 https://github.com/vim-jp/vimdoc-ja.git ${VIM_PACK_DIR}/vimdoc-ja
fi

# setup nvim
NVIM_PACK_DIR=${XDG_CONFIG_HOME}/nvim/pack/plugins/start
NVIM_PACK_COLORS_DIR=${XDG_CONFIG_HOME}/nvim/pack/colors/opt

mkdir -p ${NVIM_PACK_DIR}
mkdir -p ${NVIM_PACK_COLORS_DIR}
nvim_files=$(cd ${DOT_DIR}/.config/nvim && \ls -1)
printf "${nvim_files}" | xargs -I{} ln -sf ${DOT_DIR}/.config/nvim/{} ${XDG_CONFIG_HOME}/nvim/{}

# install nvim-base16
if [ ! -d ${NVIM_PACK_COLORS_DIR}/nvim-base16 ]; then
    git clone --depth 1 https://github.com/RRethy/nvim-base16.git ${NVIM_PACK_COLORS_DIR}/nvim-base16
fi

# install colorbuddy.nvim
if [ ! -d ${NVIM_PACK_DIR}/colorbuddy.nvim ]; then
    git clone --depth 1 https://github.com/tjdevries/colorbuddy.nvim.git ${NVIM_PACK_DIR}/colorbuddy.nvim
fi

# install nvim-noirbuddy
if [ ! -d ${NVIM_PACK_DIR}/nvim-noirbuddy ]; then
    git clone --depth 1 https://github.com/jesseleite/nvim-noirbuddy.git ${NVIM_PACK_DIR}/nvim-noirbuddy
fi

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

# install cmp-cmdline
if [ ! -d ${NVIM_PACK_DIR}/cmp-cmdline ]; then
    git clone --depth 1 https://github.com/hrsh7th/cmp-cmdline.git ${NVIM_PACK_DIR}/cmp-cmdline
fi

# install vim-vsnip
if [ ! -d ${NVIM_PACK_DIR}/vim-vsnip ]; then
    git clone --depth 1 https://github.com/hrsh7th/vim-vsnip.git ${NVIM_PACK_DIR}/vim-vsnip
fi

# install cmp-vsnip
if [ ! -d ${NVIM_PACK_DIR}/cmp-vsnip ]; then
    git clone --depth 1 https://github.com/hrsh7th/cmp-vsnip.git ${NVIM_PACK_DIR}/cmp-vsnip
fi

# install friendly-snippets
if [ ! -d ${NVIM_PACK_DIR}/friendly-snippets ]; then
    git clone --depth 1 https://github.com/rafamadriz/friendly-snippets.git ${NVIM_PACK_DIR}/friendly-snippets
fi

# install lspkind.nvim
if [ ! -d ${NVIM_PACK_DIR}/lspkind.nvim ]; then
    git clone --depth 1 https://github.com/onsails/lspkind.nvim.git ${NVIM_PACK_DIR}/lspkind.nvim
fi

# install none-ls.nvim
if [ ! -d ${NVIM_PACK_DIR}/none-ls.nvim ]; then
    git clone --depth 1 https://github.com/nvimtools/none-ls.nvim.git ${NVIM_PACK_DIR}/none-ls.nvim
fi

# install mason-null-ls.nvim
if [ ! -d ${NVIM_PACK_DIR}/mason-null-ls.nvim ]; then
    git clone --depth 1 https://github.com/jay-babu/mason-null-ls.nvim.git ${NVIM_PACK_DIR}/mason-null-ls.nvim
fi

# install plenary.nvim
if [ ! -d ${NVIM_PACK_DIR}/plenary.nvim ]; then
    git clone --depth 1 https://github.com/nvim-lua/plenary.nvim.git ${NVIM_PACK_DIR}/plenary.nvim
fi

# install lsp_signature.nvim
if [ ! -d ${NVIM_PACK_DIR}/lsp_signature.nvim ]; then
    git clone --depth 1 https://github.com/ray-x/lsp_signature.nvim ${NVIM_PACK_DIR}/lsp_signature.nvim
fi

# install nvim-treesitter
if [ ! -d ${NVIM_PACK_DIR}/nvim-treesitter ]; then
    git clone --depth 1 https://github.com/nvim-treesitter/nvim-treesitter.git ${NVIM_PACK_DIR}/nvim-treesitter
fi

# install nvim-treesitter-context
if [ ! -d ${NVIM_PACK_DIR}/nvim-treesitter-context ]; then
    git clone --depth 1 https://github.com/nvim-treesitter/nvim-treesitter-context.git ${NVIM_PACK_DIR}/nvim-treesitter-context
fi

# install nvim-treesitter-textobjects
if [ ! -d ${NVIM_PACK_DIR}/nvim-treesitter-textobjects ]; then
    git clone --depth 1 https://github.com/nvim-treesitter/nvim-treesitter-textobjects.git ${NVIM_PACK_DIR}/nvim-treesitter-textobjects
fi

# install nvim-ts-autotag
if [ ! -d ${NVIM_PACK_DIR}/nvim-ts-autotag ]; then
    git clone --depth 1 https://github.com/windwp/nvim-ts-autotag.git ${NVIM_PACK_DIR}/nvim-ts-autotag
fi

# install indent-blankline.nvim
if [ ! -d ${NVIM_PACK_DIR}/indent-blankline.nvim ]; then
    git clone --depth 1 https://github.com/lukas-reineke/indent-blankline.nvim.git ${NVIM_PACK_DIR}/indent-blankline.nvim
fi

# install fidget.nvim
if [ ! -d ${NVIM_PACK_DIR}/fidget.nvim ]; then
    git clone --depth 1 https://github.com/j-hui/fidget.nvim.git ${NVIM_PACK_DIR}/fidget.nvim
fi

# install aerial.nvim
if [ ! -d ${NVIM_PACK_DIR}/aerial.nvim ]; then
    git clone --depth 1 https://github.com/stevearc/aerial.nvim.git ${NVIM_PACK_DIR}/aerial.nvim
fi

# install nvim-bqf
if [ ! -d ${NVIM_PACK_DIR}/nvim-bqf ]; then
    git clone --depth 1 https://github.com/kevinhwang91/nvim-bqf.git ${NVIM_PACK_DIR}/nvim-bqf
fi

# install Comment.nvim
if [ ! -d ${NVIM_PACK_DIR}/Comment.nvim ]; then
    git clone --depth 1 https://github.com/numToStr/Comment.nvim.git ${NVIM_PACK_DIR}/Comment.nvim
fi

# install nvim-autopairs
if [ ! -d ${NVIM_PACK_DIR}/nvim-autopairs ]; then
    git clone --depth 1 https://github.com/windwp/nvim-autopairs.git ${NVIM_PACK_DIR}/nvim-autopairs
fi

# install other.nvim
if [ ! -d ${NVIM_PACK_DIR}/other.nvim ]; then
    git clone --depth 1 https://github.com/rgroli/other.nvim.git ${NVIM_PACK_DIR}/other.nvim
fi

# install stickybuf.nvim
if [ ! -d ${NVIM_PACK_DIR}/stickybuf.nvim ]; then
    git clone --depth 1 https://github.com/stevearc/stickybuf.nvim.git ${NVIM_PACK_DIR}/stickybuf.nvim
fi

# install leap.nvim
if [ ! -d ${NVIM_PACK_DIR}/leap.nvim ]; then
    git clone --depth 1 https://github.com/ggandor/leap.nvim.git ${NVIM_PACK_DIR}/leap.nvim
fi

# install nvim-colorizer.lua
if [ ! -d ${NVIM_PACK_DIR}/nvim-colorizer.lua ]; then
    git clone --depth 1 https://github.com/NvChad/nvim-colorizer.lua.git ${NVIM_PACK_DIR}/nvim-colorizer.lua
fi

# install diffview.nvim
if [ ! -d ${NVIM_PACK_DIR}/diffview.nvim ]; then
    git clone --depth 1 https://github.com/sindrets/diffview.nvim.git ${NVIM_PACK_DIR}/diffview.nvim
fi

# install nvim-web-devicons
if [ ! -d ${NVIM_PACK_DIR}/nvim-web-devicons ]; then
    git clone --depth 1 https://github.com/nvim-tree/nvim-web-devicons.git ${NVIM_PACK_DIR}/nvim-web-devicons
fi

# install nvim-surround
if [ ! -d ${NVIM_PACK_DIR}/nvim-surround ]; then
    git clone --depth 1 https://github.com/kylechui/nvim-surround.git ${NVIM_PACK_DIR}/nvim-surround
fi

# install nvim-various-textobjs
if [ ! -d ${NVIM_PACK_DIR}/nvim-various-textobjs ]; then
    git clone --depth 1 https://github.com/chrisgrieser/nvim-various-textobjs.git ${NVIM_PACK_DIR}/nvim-various-textobjs
fi

# install toggleterm.nvim
if [ ! -d ${NVIM_PACK_DIR}/toggleterm.nvim ]; then
    git clone --depth 1 https://github.com/akinsho/toggleterm.nvim.git ${NVIM_PACK_DIR}/toggleterm.nvim
fi

# install nvim-lsp-file-operations
if [ ! -d ${NVIM_PACK_DIR}/nvim-lsp-file-operations ]; then
    git clone --depth 1 https://github.com/antosha417/nvim-lsp-file-operations.git ${NVIM_PACK_DIR}/nvim-lsp-file-operations
fi

nvim -es +"
set pp+=${XDG_CONFIG_HOME}/vim,${XDG_CONFIG_HOME}/vim/after |
  silent! packl! |
  packadd everforest |
  helptags ALL |
  q
"
