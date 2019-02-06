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

" clipboard
set clipboard+=unnamed
set clipboard=unnamed

" move on normal mode
nmap 1 0
nmap 0 ^
nmap 9 $

" move on insert mode
inoremap <C-e> <END>
inoremap <C-a> <HOME>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-h> <Left>
inoremap <C-l> <Right>

syntax on

