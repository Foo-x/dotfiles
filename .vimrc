set nocompatible
set backspace=indent,eol,start
set encoding=utf-8
set cursorline
set cindent
set shiftwidth=2
set tabstop=2
set expandtab
set noerrorbells
set number
set visualbell t_vb=
set shellcmdflag=-ic
set runtimepath+=$HOME/.vim
set wildmode=list:longest

" show invisible chars
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
set list

" clipboard
set clipboard&
set clipboard^=unnamedplus,unnamed

runtime! *.vimrc

" finish on vim-tiny
if !1 | finish | endif

syntax on

" selection color
hi Visual ctermbg=darkgrey ctermfg=none

" cursor shape
let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"

" netrw
let g:netrw_liststyle=1
let g:netrw_sizestyle="H"
let g:netrw_timefmt="%Y/%m/%d(%a) %H:%M:%S"
let g:netrw_altv = 1
let g:netrw_alto = 1
