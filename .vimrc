" use in your .vimrc like below
" source /path/to/dotfiles/.vimrc

syntax on
set nocompatible
set backspace=indent,eol,start
set encoding=utf-8
set cursorline
set smartindent
set shiftwidth=2
set tabstop=2
set noerrorbells
set number
set selection=exclusive

" show invisible chars
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
set list

" clipboard
set clipboard+=unnamed
set clipboard=unnamed

" source settings in this directory
set runtimepath+=<sfile>:h
source .vimrc.search
source .vimrc.keymap
