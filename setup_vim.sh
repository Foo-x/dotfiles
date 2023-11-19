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
VIM_PACK_DIR=${XDG_CONFIG_HOME}/vim/pack/plugins/start
VIM_PACK_COLORS_DIR=${XDG_CONFIG_HOME}/vim/pack/colors/opt

mkdir -p ${VIM_PACK_DIR}
mkdir -p ${VIM_PACK_COLORS_DIR}
vimrc_files=$(cd ${DOT_DIR}/.config/vim && \ls -1 *vimrc)
printf "${vimrc_files}" | xargs -I{} ln -sf ${DOT_DIR}/.config/vim/{} ${XDG_CONFIG_HOME}/vim/{}

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

# install vim-markdown
if [ ! -d ${VIM_PACK_DIR}/vim-markdown ]; then
    git clone --depth 1 https://github.com/gabrielelana/vim-markdown.git ${VIM_PACK_DIR}/vim-markdown
fi

# install previm
if [ ! -d ${VIM_PACK_DIR}/previm ]; then
    git clone --depth 1 https://github.com/previm/previm.git ${VIM_PACK_DIR}/previm
fi

# install vim-table-mode
if [ ! -d ${VIM_PACK_DIR}/vim-table-mode ]; then
    git clone --depth 1 https://github.com/dhruvasagar/vim-table-mode.git ${VIM_PACK_DIR}/vim-table-mode
fi

# install vim-visual-multi
if [ ! -d ${VIM_PACK_DIR}/vim-visual-multi ]; then
    git clone --depth 1 https://github.com/mg979/vim-visual-multi.git ${VIM_PACK_DIR}/vim-visual-multi
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

# install everforest
if [ ! -d ${NVIM_PACK_COLORS_DIR}/everforest ]; then
    git clone --depth 1 https://github.com/sainnhe/everforest.git ${NVIM_PACK_COLORS_DIR}/everforest
fi

# install nightfox.nvim
if [ ! -d ${NVIM_PACK_COLORS_DIR}/nightfox.nvim ]; then
    git clone --depth 1 https://github.com/EdenEast/nightfox.nvim.git ${NVIM_PACK_COLORS_DIR}/nightfox.nvim
fi

# install kanagawa.nvim
if [ ! -d ${NVIM_PACK_COLORS_DIR}/kanagawa.nvim ]; then
    git clone --depth 1 https://github.com/rebelot/kanagawa.nvim.git ${NVIM_PACK_COLORS_DIR}/kanagawa.nvim
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

# install symbols-outline.nvim
if [ ! -d ${NVIM_PACK_DIR}/symbols-outline.nvim ]; then
    git clone --depth 1 https://github.com/simrat39/symbols-outline.nvim.git ${NVIM_PACK_DIR}/symbols-outline.nvim
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

nvim -es +"
set pp+=${XDG_CONFIG_HOME}/vim,${XDG_CONFIG_HOME}/vim/after |
  silent! packl! |
  packadd everforest |
  packadd nightfox.nvim |
  helptags ALL |
  q
"
