" use in your .vimrc like below
" source /path/to/dotfiles/.vimrc
set nocompatible
set backspace=indent,eol,start
set encoding=utf-8
set cursorline
set smartindent
set shiftwidth=2
set tabstop=2
set noerrorbells
set number

" highlight searches
set hlsearch

set ignorecase
set smartcase
set incsearch
set wrapscan

" disable highlight by double esc
nmap <Esc><Esc> :nohlsearch<CR><Esc>

" show invisible chars
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
set list

syntax on

